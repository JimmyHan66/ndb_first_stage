#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ClickHouse exec（仅执行，非交互批量运行 + 事后解析）
- 单线程：--max_threads=1
- 内存：--max_memory_usage（字节） + 禁外部落盘
- 单进程：一次性执行多语句脚本（建 Memory 表→装载→预热→正式计时）
- 计时：开启 --time；每次正式计时前插入 'BEGIN|case|run' 标记行
       解析规则：遇到标记后，跳过紧随其后的一个 Elapsed（属于标记本身），再取下一个 Elapsed 作为本次用例耗时
- 避免任何交互式读取，彻底规避卡住问题
输出：bench_out_clickhouse_exec/{results.csv, summary_avg.csv, summary_report.txt}
"""

import os, sys, csv, time, argparse, subprocess, re, shutil
from collections import defaultdict

DEFAULT_BASE = "/home/bochengh/ndb_fisrt_stage"
SCALES       = [1, 3, 5]
WARMUPS      = 3
REPEATS      = 2
DEFAULT_MEM_GB = 80
CLICKHOUSE_BIN = os.environ.get("CLICKHOUSE_BIN", "clickhouse")

OUTDIR     = "bench_out_clickhouse_exec"
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
        "--time",  # 强制输出每条语句的 Elapsed
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

def build_script(parquet_path: str, warmups: int, repeats: int) -> str:
    lines = []
    lines.append("SET output_format_write_statistics = 1")
    lines.append("SET send_logs_level = 'error'")
    lines.append("DROP TABLE IF EXISTS lineitem_mem")
    lines.append(f"""
    CREATE TABLE lineitem_mem ENGINE=Memory AS
    SELECT {PROJ_COLS}
    FROM file('{parquet_path}','Parquet') LIMIT 0
    """)
    # 装载到内存表（这步不计入任一用例，但会打印自身 Elapsed，没关系）
    lines.append(f"""
    INSERT INTO lineitem_mem
    SELECT {PROJ_COLS}
    FROM file('{parquet_path}','Parquet')
    """)

    # 预热
    for case, sql in SQLS.items():
        sql = sql.strip()
        for _ in range(warmups):
            lines.append(sql)

    # 正式计时（加 BEGIN 标记）
    for case, sql in SQLS.items():
        sql = sql.strip()
        for run in range(1, repeats+1):
            lines.append(f"SELECT 'BEGIN|{case}|{run}' FORMAT TSV")
            lines.append(sql)

    # 用一个轻量 SELECT 做脚本收尾（不影响计时，只为稳定输出）
    lines.append("SELECT 'DONE' FORMAT TSV")
    # 拼接
    return ";\n".join(lines) + ";\n"

def run_scale(parquet_path: str, mem_gb: int, warmups: int, repeats: int):
    mem_bytes = int(mem_gb * (1024**3))
    script = build_script(parquet_path, warmups, repeats)

    cmd = [CLICKHOUSE_BIN, "local", "--multiquery"] + ch_settings(mem_bytes)
    print(f"[CH/exec] 启动 clickhouse-local（单进程批量执行）")
    t0 = time.perf_counter()
    proc = subprocess.run(
        cmd,
        input=script.encode(),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=True,
    )
    wall_ms = (time.perf_counter() - t0) * 1000.0
    print(f"[CH/exec] 批量执行完成，墙钟 ~ {wall_ms:.1f} ms")

    stdout = proc.stdout.decode(errors="ignore").splitlines()

    # 解析：支持两种输出
    # 1) "Elapsed: 0.123 sec"
    # 2) "0.123"（单位秒，clickhouse 某些版本/设置会输出这种）
    rows = []
    pending = None  # (case, run, seen_marker_elapsed: 0/1)
    re_begin   = re.compile(r"^BEGIN\|([a-z0-9_]+)\|([0-9]+)$")
    re_elapsed = re.compile(r"Elapsed:\s*([0-9.]+)\s*sec")
    re_number  = re.compile(r"^\s*([0-9]+(?:\.[0-9]+)?)\s*$")

    def parse_secs(line: str):
        m = re_elapsed.search(line)
        if m:
            return float(m.group(1))
        m = re_number.match(line)
        if m:
            return float(m.group(1))
        return None

    for line in stdout:
        line = line.strip()
        m = re_begin.match(line)
        if m:
            pending = (m.group(1), int(m.group(2)), 0)
            continue

        secs = parse_secs(line)
        if secs is None or pending is None:
            continue

        # 第一个时间属于 BEGIN 标记本身；第二个时间才是该用例本次 run 的执行时间
        if pending[2] == 0:
            pending = (pending[0], pending[1], 1)
        else:
            ms = secs * 1000.0
            case, run = pending[0], pending[1]
            rows.append(("clickhouse", "exec", case, run, ms))
            pending = None

    expected = len(SQLS) * repeats
    if len(rows) != expected:
        print(f"[WARN] 解析到的计时条目 {len(rows)} != 预期 {expected}，请检查 stdout（可以用 --dump-stdout 保存）。")

    return rows, stdout

def write_out(all_rows, scales, mem_gb):
    os.makedirs(OUTDIR, exist_ok=True)
    with open(RESULT_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["system","scale","case","mode","run","ms"])
        for (scale, sysname, mode, case, run, ms) in all_rows:
            w.writerow([sysname, scale, case, mode, run, f"{ms:.3f}"])

    groups = defaultdict(list)
    for (scale, sysname, mode, case, run, ms) in all_rows:
        groups[(scale, sysname, mode, case)].append(ms)

    with open(SUMMARY_CSV, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["scale","system","mode","case","warmups","repeats","mem_gb","avg_ms"])
        for k in sorted(groups):
            scale, sysname, mode, case = k
            avg = sum(groups[k]) / len(groups[k])
            w.writerow([scale, sysname, mode, case, WARMUPS, REPEATS, mem_gb, f"{avg:.3f}"])

    with open(SUMMARY_TXT, "w") as f:
        f.write("ClickHouse exec（仅执行；批量执行+事后解析）\n")
        f.write("--max_threads=1; ENGINE=Memory; 预热3，统计7；只读7列；--time 强制输出耗时\n\n")
        f.write(f"max_memory_usage ≈ {int(mem_gb*(1024**3))} bytes (~{mem_gb}GB)\n\n平均时间（ms）：\n")
        f.write(f"{'scale':>5}  {'case':<22}  {'avg_ms':>12}\n")
        f.write("-"*44 + "\n")
        for k in sorted(groups):
            scale, _, _, case = k
            avg = sum(groups[k]) / len(groups[k])
            f.write(f"{scale:>5}  {case:<22}  {avg:>12.3f}\n")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default=DEFAULT_BASE)
    ap.add_argument("--scales", nargs="+", type=int, default=SCALES)
    ap.add_argument("--mem-gb", type=int, default=DEFAULT_MEM_GB)
    ap.add_argument("--warmups", type=int, default=WARMUPS)
    ap.add_argument("--repeats", type=int, default=REPEATS)
    ap.add_argument("--dump-stdout", action="store_true", help="将 clickhouse-local 的完整 stdout 保存到 bench_out_clickhouse_exec/stdout.txt")
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
        print(f"\n=== ClickHouse exec | SF{scale} ===")
        rows, stdout_lines = run_scale(path, args.mem_gb, args.warmups, args.repeats)
        all_rows += [(scale,) + r for r in rows]

        if args.dump_stdout:
            os.makedirs(OUTDIR, exist_ok=True)
            with open(os.path.join(OUTDIR, f"stdout_sf{scale}.txt"), "w") as f:
                f.write("\n".join(stdout_lines))

    write_out(all_rows, args.scales, args.mem_gb)
    print(f"\n[DONE] 输出到 {OUTDIR}/")

if __name__ == "__main__":
    main()