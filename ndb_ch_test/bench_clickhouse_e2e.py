#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ClickHouse e2e（端到端墙钟，不预热；稳健版）
- 每轮（每个用例/每次 run）：新进程 --multiquery（带相同 settings + --time）
  DROP/CREATE ENGINE=Memory（7列 schema）→ 从 Parquet INSERT → 执行 1 次查询 → 轻量收尾
- 记录整段墙钟（Python time.perf_counter 包裹子进程）；重复 N 轮取平均
- 不做交互读取；可选 --dump-stdout 将 stdout 落盘。可选 --timeout-sec 限制子进程最长执行时长。
输出：bench_out_clickhouse_e2e/{results.csv, summary_avg.csv, summary_report.txt, (可选)stdout_*}
"""

import os, sys, csv, time, argparse, subprocess, shutil

DEFAULT_BASE = "/home/bochengh/ndb_fisrt_stage"
SCALES       = [1, 3, 5]
REPEATS      = 7
DEFAULT_MEM_GB = 80
CLICKHOUSE_BIN = os.environ.get("CLICKHOUSE_BIN", "clickhouse")

OUTDIR     = "bench_out_clickhouse_e2e"
RESULT_CSV = os.path.join(OUTDIR, "results.csv")
SUMMARY_CSV= os.path.join(OUTDIR, "summary_avg.csv")
SUMMARY_TXT= os.path.join(OUTDIR, "summary_report.txt")

PROJ_COLS = "l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_discount, l_tax, l_shipdate"

def ch_settings(mem_bytes: int):
    return [
        "--max_threads=1",
        f"--max_memory_usage={mem_bytes}",
        "--max_bytes_before_external_sort=0",
        "--max_bytes_before_external_group_by=0",
        "--use_uncompressed_cache=0",
        "--load_marks_asynchronously=0",
        "--max_temporary_data_on_disk_size_for_query=0",
        "--max_temporary_data_on_disk_size_for_user=0",
        "--time",  # 与 exec 一致：每条语句打印耗时（我们 e2e 只取整体墙钟）
    ]

Q6_FILTER = """
l_shipdate >= toDate('1994-01-01')
AND l_shipdate <  toDate('1995-01-01')
AND l_discount BETWEEN 0.05 AND 0.07
AND l_quantity < 24
"""
Q1_PRED = "l_shipdate <= addDays(toDate('1998-12-01'), -90)"

SQLS = {
    "scan_filter_q6":    f"SELECT count() FROM lineitem_mem WHERE {Q6_FILTER} FORMAT Null",
    "scan_filter_q1":    f"SELECT count() FROM lineitem_mem WHERE {Q1_PRED} FORMAT Null",
    "agg_only_q1": f"""
        SELECT l_returnflag, l_linestatus,
               sum(l_quantity) AS sum_qty,
               sum(l_extendedprice) AS sum_base_price,
               sum(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
               sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
               avg(l_quantity) AS avg_qty,
               avg(l_extendedprice) AS avg_price,
               avg(l_discount) AS avg_disc,
               count() AS count_order
        FROM lineitem_mem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus
        ORDER BY l_returnflag, l_linestatus
        FORMAT Null
    """,
    "sort_only_shipdate": "SELECT l_shipdate FROM lineitem_mem ORDER BY l_shipdate FORMAT Null",
    "q6_full": f"SELECT sum(l_extendedprice * l_discount) AS revenue FROM lineitem_mem WHERE {Q6_FILTER} FORMAT Null",
    "q1_full": f"""
        SELECT l_returnflag, l_linestatus,
               sum(l_quantity) AS sum_qty,
               sum(l_extendedprice) AS sum_base_price,
               sum(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
               sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
               avg(l_quantity) AS avg_qty,
               avg(l_extendedprice) AS avg_price,
               avg(l_discount) AS avg_disc,
               count() AS count_order
        FROM lineitem_mem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus
        ORDER BY l_returnflag, l_linestatus
        FORMAT Null
    """,
}

def build_script(parquet_path: str, user_sql: str) -> str:
    """构造单轮 e2e 的 multiquery 脚本。"""
    return f"""
    SET output_format_write_statistics = 1;
    SET send_logs_level = 'error';
    DROP TABLE IF EXISTS lineitem_mem;
    CREATE TABLE lineitem_mem ENGINE=Memory AS
      SELECT {PROJ_COLS}
      FROM file('{parquet_path}','Parquet') LIMIT 0;
    INSERT INTO lineitem_mem
      SELECT {PROJ_COLS}
      FROM file('{parquet_path}','Parquet');
    {user_sql.strip()};
    SELECT 'DONE' FORMAT TSV;
    """

def run_scale(parquet_path: str, mem_gb: int, repeats: int, timeout_sec: int, dump_stdout: bool, scale: int):
    mem_bytes = int(mem_gb * (1024**3))
    rows = []
    for case, sql in SQLS.items():
        print(f"[CH/e2e] {case} ：每轮新进程 + 建表 + 装载 + 执行一次（重复 {repeats}）")
        for run in range(1, repeats+1):
            script = build_script(parquet_path, sql)
            cmd = [CLICKHOUSE_BIN, "local", "--multiquery"] + ch_settings(mem_bytes)
            print(f"  - run {run}/{repeats} ...", flush=True)
            t0 = time.perf_counter()
            try:
                proc = subprocess.run(
                    cmd,
                    input=script.encode(),
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    check=True,
                    timeout=timeout_sec
                )
                ms = (time.perf_counter() - t0) * 1000.0
                print(f"    完成：{ms:.3f} ms")
                rows.append(("clickhouse", "e2e", case, run, ms))

                if dump_stdout:
                    os.makedirs(OUTDIR, exist_ok=True)
                    with open(os.path.join(OUTDIR, f"stdout_sf{scale}_{case}_run{run}.txt"), "wb") as f:
                        f.write(proc.stdout)
            except subprocess.TimeoutExpired:
                print("    [TIMEOUT] 子进程超时，记录为 NaN，并继续下一轮。", file=sys.stderr)
                rows.append(("clickhouse", "e2e", case, run, float("nan")))
            except subprocess.CalledProcessError as e:
                print("    [ERROR] 子进程返回非零，记录为 NaN，并继续下一轮。", file=sys.stderr)
                if dump_stdout:
                    os.makedirs(OUTDIR, exist_ok=True)
                    with open(os.path.join(OUTDIR, f"stdout_sf{scale}_{case}_run{run}_ERR.txt"), "wb") as f:
                        f.write(e.stdout if e.stdout else b"")
                rows.append(("clickhouse", "e2e", case, run, float("nan")))
    return rows

def write_out(all_rows, mem_gb):
    os.makedirs(OUTDIR, exist_ok=True)
    # results.csv
    with open(RESULT_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["system","scale","case","mode","run","ms"])
        for (scale, sysname, mode, case, run, ms) in all_rows:
            w.writerow([sysname, scale, case, mode, run, f"{ms:.3f}" if ms == ms else "NaN"])

    # summary_avg.csv / report
    from collections import defaultdict
    groups = defaultdict(list)
    for (scale, sysname, mode, case, run, ms) in all_rows:
        if ms == ms:  # 排除 NaN
            groups[(scale, sysname, mode, case)].append(ms)

    with open(SUMMARY_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["scale","system","mode","case","repeats","mem_gb","avg_ms","valid_runs"])
        for k in sorted(groups):
            scale, sysname, mode, case = k
            vals = groups[k]
            avg = sum(vals) / len(vals) if vals else float("nan")
            w.writerow([scale, sysname, mode, case, len(vals), mem_gb, f"{avg:.3f}" if avg == avg else "NaN", len(vals)])

    lines = []
    lines.append("ClickHouse e2e（端到端墙钟；不预热）")
    lines.append("每轮：新进程→DROP/CREATE→INSERT Parquet(7列)→执行1次；重复 N 轮")
    lines.append("")
    lines.append(f"max_memory_usage ≈ {int(mem_gb*(1024**3))} bytes (~{mem_gb}GB)")
    lines.append("")
    lines.append("平均时间（ms）：")
    header = f"{'system':<11}{'scale':>5}  {'case':<22}  {'mode':<4}  {'avg_ms':>12}  {'valid':>6}"
    lines.append(header)
    lines.append("-"*len(header))
    for k in sorted(groups):
        scale, sysname, mode, case = k
        vals = groups[k]
        avg = sum(vals) / len(vals) if vals else float("nan")
        lines.append(f"{sysname:<11}{scale:>5}  {case:<22}  {mode:<4}  {avg:>12.3f}  {len(vals):>6}")
    with open(SUMMARY_TXT, "w") as f:
        f.write("\n".join(lines))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default=DEFAULT_BASE)
    ap.add_argument("--scales", nargs="+", type=int, default=SCALES)
    ap.add_argument("--mem-gb", type=int, default=DEFAULT_MEM_GB)
    ap.add_argument("--repeats", type=int, default=REPEATS)
    ap.add_argument("--timeout-sec", type=int, default=1800, help="单次 e2e 子进程的超时时长（秒）")
    ap.add_argument("--dump-stdout", action="store_true", help="保存每次 run 的 stdout 到 bench_out_clickhouse_e2e/")
    args = ap.parse_args()

    if not shutil.which(CLICKHOUSE_BIN) and CLICKHOUSE_BIN == "clickhouse":
        sys.stderr.write("ERROR: 找不到 clickhouse 可执行文件。请设置 CLICKHOUSE_BIN 环境变量或加入 PATH。\n")
        sys.exit(1)

    all_rows = []
    for scale in args.scales:
        path = os.path.join(args.base, f"sf{scale}_parquet", "lineitem.parquet")
        if not os.path.exists(path):
            print(f"[WARN] 缺失 {path}，跳过 SF{scale}")
            continue
        print(f"\n=== ClickHouse e2e | SF{scale} ===")
        rows = run_scale(path, args.mem_gb, args.repeats, args.timeout_sec, args.dump_stdout, scale)
        all_rows += [(scale,) + r for r in rows]

    write_out(all_rows, args.mem_gb)
    print(f"\n[DONE] 输出到 {OUTDIR}/")

if __name__ == "__main__":
    main()