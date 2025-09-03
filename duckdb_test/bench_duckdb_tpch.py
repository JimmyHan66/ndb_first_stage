#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DuckDB 单线程 TPC-H Q1/Q6 基准（含算子切分）
- 支持 SF=1/3/5
- 数据路径形如：/home/bochengh/ndb_fisrt_stage/sf{scale}_parquet/lineitem.parquet
- 产出：
  - bench_out/results.csv：按 scale/case/mode/run 的单次用时（ms）与 profile 路径
  - bench_out/prof_out/*.json：每次执行的 DuckDB profiling（便于深挖算子）
  - bench_out/summary_avg.csv：平均时间统计（本次需求的最终汇总）
  - bench_out/summary_report.txt：带解释的人类可读报告（说明 e2e/exec、warmups/repeats 等）
"""

import os, sys, time, json, csv, shutil, subprocess, argparse
from datetime import datetime
from collections import defaultdict

# ---------- 配置 ----------
DEFAULT_BASE = "/home/bochengh/ndb_fisrt_stage"
SCALES = [1, 3, 5]
REPEATS = 7           # 正式统计次数
WARMUPS = 3           # 预热次数
MEM_LIMIT = "100GB"    # 你机器内存允许的话设大点，避免溢写
OUTDIR = "bench_out"
PROFDIR = os.path.join(OUTDIR, "prof_out")
RESULT_CSV = os.path.join(OUTDIR, "results.csv")
SUMMARY_CSV = os.path.join(OUTDIR, "summary_avg.csv")
SUMMARY_TXT = os.path.join(OUTDIR, "summary_report.txt")

# 对每个用例给一句简短说明（会写入 summary 文件里）
CASE_DESC = {
    "scan_filter_q6":       "算子：Scan + Filter（Q6 条件）",
    "scan_filter_q1":       "算子：Scan + Filter（Q1 时间条件）",
    "agg_only_q1":          "算子：Group By + Aggregations（Q1 聚合，去排序）",
    "sort_only_shipdate":   "算子：全局排序（ORDER BY l_shipdate，无 LIMIT）",
    "q6_full":              "整条查询：TPC-H Q6",
    "q1_full":              "整条查询：TPC-H Q1（含 ORDER BY）",
}
MODE_DESC = {
    "e2e":  "端到端：解析 + 优化 + 编译 + 执行 的总时间（预热不计入，只统计 REPEATS 次）。",
    "exec": "仅执行：先 PREPARE，然后 EXECUTE 复用执行计划，仅统计执行阶段（预热不计入，只统计 REPEATS 次）。",
}

# ---------- DuckDB 获取：尽量用 Python 包，否则退回 CLI ----------
def have_duckdb_python():
    try:
        import duckdb  # noqa
        return True
    except Exception:
        return False

def have_duckdb_cli():
    return shutil.which("duckdb") is not None

# ---------- SQL 用例 ----------
# Q6 过滤条件（经典）
Q6_FILTER = """
l_shipdate >= DATE '1994-01-01'
AND l_shipdate <  DATE '1995-01-01'
AND l_discount BETWEEN 0.05 AND 0.07
AND l_quantity < 24
"""

# Q1 时间条件（经典语义）
Q1_PRED = "l_shipdate <= DATE '1998-12-01' - INTERVAL 90 DAY"

# ——算子切分用例——
SQLS = {
    # scan+filter：Q6 风格（用 count(*) 作为轻量汇总，profiling 看 Scan/Filter）
    "scan_filter_q6": f"""
        SELECT count(*) FROM lineitem WHERE {Q6_FILTER};
    """,

    # scan+filter：Q1 风格（仅日期条件）
    "scan_filter_q1": f"""
        SELECT count(*) FROM lineitem WHERE {Q1_PRED};
    """,

    # agg-only：Q1 核心聚合（去掉排序）
    "agg_only_q1": f"""
        SELECT
          l_returnflag,
          l_linestatus,
          SUM(l_quantity)                              AS sum_qty,
          SUM(l_extendedprice)                         AS sum_base_price,
          SUM(l_extendedprice * (1 - l_discount))      AS sum_disc_price,
          SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
          AVG(l_quantity)                              AS avg_qty,
          AVG(l_extendedprice)                         AS avg_price,
          AVG(l_discount)                              AS avg_disc,
          COUNT(*)                                     AS count_order
        FROM lineitem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus;
    """,

    # sort-only：对原表做全局排序（无 LIMIT），尽量测纯排序
    "sort_only_shipdate": """
        SELECT l_shipdate
        FROM lineitem
        ORDER BY l_shipdate;
    """,

    # ——整条查询——
    # Q6 全量
    "q6_full": f"""
        SELECT SUM(l_extendedprice * l_discount) AS revenue
        FROM lineitem
        WHERE {Q6_FILTER};
    """,

    # Q1 全量（含 ORDER BY）
    "q1_full": f"""
        SELECT
          l_returnflag,
          l_linestatus,
          SUM(l_quantity)                              AS sum_qty,
          SUM(l_extendedprice)                         AS sum_base_price,
          SUM(l_extendedprice * (1 - l_discount))      AS sum_disc_price,
          SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
          AVG(l_quantity)                              AS avg_qty,
          AVG(l_extendedprice)                         AS avg_price,
          AVG(l_discount)                              AS avg_disc,
          COUNT(*)                                     AS count_order
        FROM lineitem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus
        ORDER BY l_returnflag, l_linestatus;
    """,
}

def mk_dirs():
    os.makedirs(PROFDIR, exist_ok=True)

def now_tag():
    return datetime.now().strftime("%Y%m%d_%H%M%S_%f")

# ---------- 执行（Python duckdb 路径） ----------
def run_with_duckdb_python(scale, parquet_path, case_name, sql_text, mode):
    """
    mode in {"e2e","exec"}; 返回 (本次多轮执行用时列表ms, profiling文件路径列表)
    """
    import duckdb
    prof_file = os.path.join(PROFDIR, f"{case_name}_sf{scale}_{mode}_{now_tag()}.json")

    con = duckdb.connect(database=":memory:")
    # 统一环境
    con.execute("PRAGMA threads=1;")
    con.execute("PRAGMA enable_progress_bar=false;")
    con.execute(f"PRAGMA memory_limit='{MEM_LIMIT}';")
    con.execute("PRAGMA profiling_mode='detailed';")
    con.execute("PRAGMA enable_profiling='json';")
    # 纯内存模式：把 Parquet 读入 TEMP 表
    con.execute(f"CREATE TEMP TABLE lineitem AS SELECT * FROM read_parquet('{parquet_path}');")

    def _one_exec():
        con.execute(f"PRAGMA profiling_output='{prof_file}';")
        t0 = time.perf_counter()
        con.execute(sql_text).fetchall()
        t1 = time.perf_counter()
        return (t1 - t0) * 1000.0

    if mode == "e2e":
        for _ in range(WARMUPS):
            _one_exec()
        times, profs = [], []
        for _ in range(REPEATS):
            prof_file = os.path.join(PROFDIR, f"{case_name}_sf{scale}_e2e_{now_tag()}.json")
            ms = _one_exec()
            times.append(ms)
            profs.append(prof_file)
        return times, profs

    elif mode == "exec":
        con.execute(f"PREPARE q AS {sql_text}")
        for _ in range(WARMUPS):
            con.execute(f"PRAGMA profiling_output='{prof_file}';")
            con.execute("EXECUTE q;")
        times, profs = [], []
        for _ in range(REPEATS):
            prof_file = os.path.join(PROFDIR, f"{case_name}_sf{scale}_exec_{now_tag()}.json")
            con.execute(f"PRAGMA profiling_output='{prof_file}';")
            t0 = time.perf_counter()
            con.execute("EXECUTE q;")
            t1 = time.perf_counter()
            times.append((t1 - t0) * 1000.0)
            profs.append(prof_file)
        return times, profs
    else:
        raise ValueError("mode must be 'e2e' or 'exec'")

# ---------- 执行（CLI 回退，已修掉之前的小 bug） ----------
def run_with_cli(scale, parquet_path, case_name, sql_text, mode):
    """
    通过 duckdb CLI 执行；用进程时间粗略计时（包含进程启动少量开销）
    """
    prof_file = os.path.join(PROFDIR, f"{case_name}_sf{scale}_{mode}_{now_tag()}.json")
    setup = f"""
    PRAGMA threads=1;
    PRAGMA enable_progress_bar=false;
    PRAGMA memory_limit='{MEM_LIMIT}';
    PRAGMA profiling_mode='detailed';
    PRAGMA enable_profiling='json';
    CREATE TEMP TABLE lineitem AS SELECT * FROM read_parquet('{parquet_path}');
    """

    times, profs = [], []
    for i in range(REPEATS):
        if mode == "e2e":
            run_sql = setup + f"PRAGMA profiling_output='{prof_file}';\n" + sql_text + ";"
        else:
            run_sql = (
                setup +
                f"PREPARE q AS {sql_text};\n" +
                ("EXECUTE q;\n" * WARMUPS) +
                f"PRAGMA profiling_output='{prof_file}';\n" +
                "EXECUTE q;"
            )
        cmd = ["duckdb", "-cmd", run_sql]
        t0 = time.perf_counter()
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        t1 = time.perf_counter()
        times.append((t1 - t0) * 1000.0)
        profs.append(prof_file)
        # 更新文件名，确保下一轮不覆盖
        prof_file = os.path.join(PROFDIR, f"{case_name}_sf{scale}_{mode}_{now_tag()}_{i+1}.json")

    return times, profs

# ---------- 统计输出 ----------
def write_results_csv(rows):
    os.makedirs(OUTDIR, exist_ok=True)
    with open(RESULT_CSV, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["scale","case","mode","run","ms","profile"])
        writer.writeheader()
        for r in rows:
            writer.writerow(r)

def write_summary_avg(rows):
    """
    生成两个文件：
    - bench_out/summary_avg.csv：结构化统计
      列：scale, case, case_desc, mode, mode_desc, warmups, repeats, avg_ms
    - bench_out/summary_report.txt：带说明的可读文本表格
    """
    # 聚合平均
    groups = defaultdict(list)
    for r in rows:
        key = (int(r["scale"]), r["case"], r["mode"])
        groups[key].append(float(r["ms"]))

    # 写 CSV
    with open(SUMMARY_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["scale","case","case_desc","mode","mode_desc","warmups","repeats","avg_ms"])
        for (scale, case, mode) in sorted(groups.keys()):
            avg_ms = sum(groups[(scale, case, mode)]) / len(groups[(scale, case, mode)])
            w.writerow([
                scale,
                case,
                CASE_DESC.get(case, ""),
                mode,
                MODE_DESC.get(mode, ""),
                WARMUPS,
                REPEATS,
                f"{avg_ms:.3f}",
            ])

    # 写人类可读报告
    lines = []
    lines.append("DuckDB 单线程 TPC-H Q1/Q6 基准：平均时间统计")
    lines.append("="*50)
    lines.append(f"环境约束：threads=1, memory_limit='{MEM_LIMIT}', 内存表=read_parquet(...) -> TEMP table")
    lines.append(f"Warm-ups（预热次数） = {WARMUPS}")
    lines.append(f"Repeats（正式统计次数） = {REPEATS}")
    lines.append("")
    lines.append("模式说明：")
    lines.append(f"- e2e  : {MODE_DESC['e2e']}")
    lines.append(f"- exec : {MODE_DESC['exec']}")
    lines.append("")
    lines.append("用例说明：")
    for k in ["scan_filter_q6","scan_filter_q1","agg_only_q1","sort_only_shipdate","q6_full","q1_full"]:
        lines.append(f"- {k:20s} : {CASE_DESC.get(k,'')}")
    lines.append("")
    lines.append("平均时间（ms）：")
    # 宽表头
    header = f"{'scale':>5}  {'case':<22}  {'mode':<4}  {'avg_ms':>12}"
    lines.append(header)
    lines.append("-"*len(header))
    for (scale, case, mode) in sorted(groups.keys()):
        avg_ms = sum(groups[(scale, case, mode)]) / len(groups[(scale, case, mode)])
        lines.append(f"{scale:>5}  {case:<22}  {mode:<4}  {avg_ms:>12.3f}")

    with open(SUMMARY_TXT, "w") as f:
        f.write("\n".join(lines))

# ---------- 主流程 ----------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=DEFAULT_BASE, help="数据根目录（包含 sf{scale}_parquet/lineitem.parquet）")
    parser.add_argument("--scales", nargs="+", type=int, default=SCALES, help="要测的 SF 列表，例如: --scales 1 3 5")
    args = parser.parse_args()

    mk_dirs()

    use_py = have_duckdb_python()
    use_cli = have_duckdb_cli()
    if not (use_py or use_cli):
        print("ERROR: 既没有 duckdb Python 包也没有 duckdb CLI，请先安装其一。", file=sys.stderr)
        sys.exit(1)

    if use_py:
        import duckdb  # noqa
        runner = run_with_duckdb_python
        print("[INFO] 使用 duckdb Python 包执行")
    else:
        runner = run_with_cli
        print("[INFO] 使用 duckdb CLI 执行")

    rows = []
    for scale in args.scales:
        parquet_path = os.path.join(args.base, f"sf{scale}_parquet", "lineitem.parquet")
        if not os.path.exists(parquet_path):
            print(f"[WARN] 找不到 {parquet_path}，跳过 SF{scale}")
            continue

        cases_in_order = [
            "scan_filter_q6",
            "scan_filter_q1",
            "agg_only_q1",
            "sort_only_shipdate",
            "q6_full",
            "q1_full",
        ]

        for case in cases_in_order:
            sql_text = SQLS[case].strip()
            for mode in ("e2e", "exec"):
                times_ms, prof_paths = runner(scale, parquet_path, case, sql_text, mode)
                for i, ms in enumerate(times_ms, 1):
                    rows.append({
                        "scale": scale,
                        "case": case,
                        "mode": mode,
                        "run": i,
                        "ms": f"{ms:.3f}",
                        "profile": prof_paths[i-1],
                    })
                # 控制台也给个简单提示
                avg_ms = sum(times_ms) / len(times_ms) if times_ms else float("nan")
                print(f"[OK] SF{scale} {case} {mode}: avg={avg_ms:.2f} ms over {len(times_ms)} runs")

    # 输出明细与汇总
    write_results_csv(rows)
    write_summary_avg(rows)

    print(f"\n[DONE] 结果已生成：\n- {RESULT_CSV}\n- {SUMMARY_CSV}\n- {SUMMARY_TXT}\nProfiling JSON 在：{PROFDIR}")

if __name__ == "__main__":
    main()