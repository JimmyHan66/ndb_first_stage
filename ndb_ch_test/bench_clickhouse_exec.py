#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ClickHouse exec（仅执行）
- 单线程：--max_threads=1
- 内存：--max_memory_usage（字节） + 禁外部落盘
- 单会话：建 ENGINE=Memory 表并从 Parquet 装载（不计时）
- 每个用例：预热 3 次 + 正式 7 次（从 'Elapsed: X sec' 解析执行时间）
输出：bench_out_clickhouse_exec/{results.csv, summary_avg.csv, summary_report.txt}
"""

import os, sys, csv, time, argparse, subprocess, re
from collections import defaultdict

DEFAULT_BASE="/home/bochengh/ndb_fisrt_stage"
SCALES=[1,3,5]
WARMUPS=3
REPEATS=2
DEFAULT_MEM_GB=80
CLICKHOUSE_BIN=os.environ.get("CLICKHOUSE_BIN","clickhouse")

OUTDIR="bench_out_clickhouse_exec"
RESULT_CSV=os.path.join(OUTDIR,"results.csv")
SUMMARY_CSV=os.path.join(OUTDIR,"summary_avg.csv")
SUMMARY_TXT=os.path.join(OUTDIR,"summary_report.txt")

PROJ_COLS="l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_discount, l_tax, l_shipdate"

def ch_settings(mem_bytes:int):
    return [
        "--max_threads=1",
        f"--max_memory_usage={mem_bytes}",
        "--max_bytes_before_external_sort=0",
        "--max_bytes_before_external_group_by=0",
        "--use_uncompressed_cache=0",
        "--load_marks_asynchronously=0",
        "--max_temporary_data_on_disk_size_for_query=0",
        "--max_temporary_data_on_disk_size_for_user=0",
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

def ch_open(mem_bytes:int):
    cmd=[CLICKHOUSE_BIN,"local","--multiquery"]+ch_settings(mem_bytes)
    return subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

def ch_exec_elapsed(sess, stmt:str):
    """写入一条语句，解析 'Elapsed: X sec' 为毫秒。"""
    sess.stdin.write(stmt.rstrip(";\n")+";\n")
    sess.stdin.flush()
    ms=None
    while True:
        line=sess.stdout.readline()
        if not line: break
        m=re.search(r"Elapsed:\s*([0-9.]+)\s*sec", line)
        if m:
            ms=float(m.group(1))*1000.0
            break
    return ms

def run_scale(parquet_path, mem_gb):
    mem_bytes=int(mem_gb*(1024**3))
    s=ch_open(mem_bytes)
    ch_exec_elapsed(s, "SET output_format_write_statistics = 1")
    print(f"[CH/exec] 建内存表（仅7列）")
    ch_exec_elapsed(s, "DROP TABLE IF EXISTS lineitem_mem")
    ch_exec_elapsed(s, f"""
        CREATE TABLE lineitem_mem ENGINE=Memory AS
        SELECT {PROJ_COLS} FROM file('{parquet_path}','Parquet') LIMIT 0
    """)
    print(f"[CH/exec] 从 Parquet 装载进内存表（不计时）")
    ch_exec_elapsed(s, f"""
        INSERT INTO lineitem_mem
        SELECT {PROJ_COLS} FROM file('{parquet_path}','Parquet')
    """)
    rows=[]
    for case, sql in SQLS.items():
        sql=sql.strip()
        print(f"[CH/exec] 预热 {case} x {WARMUPS} ...")
        for _ in range(WARMUPS):
            ch_exec_elapsed(s, sql)
        print(f"[CH/exec] 正式 {case} x {REPEATS} 计时 ...")
        for run in range(1, REPEATS+1):
            ms = ch_exec_elapsed(s, sql)
            if ms is None:
                # 兜底：极少数情况下未解析到 Elapsed，用墙钟再跑一次
                t0=time.perf_counter(); ch_exec_elapsed(s, sql)
                ms=(time.perf_counter()-t0)*1000.0
            print(f"  - {case} run {run}/{REPEATS}: {ms:.3f} ms")
            rows.append(("clickhouse","exec",case,run,ms))
    try:
        s.stdin.close(); s.terminate()
    except Exception:
        pass
    return rows

def write_out(all_rows, scales, mem_gb):
    os.makedirs(OUTDIR, exist_ok=True)
    with open(RESULT_CSV,"w",newline="") as f:
        w=csv.writer(f); w.writerow(["system","scale","case","mode","run","ms"])
        for (scale,sysname,mode,case,run,ms) in all_rows:
            w.writerow([sysname,scale,case,mode,run,f"{ms:.3f}"])
    groups=defaultdict(list)
    for (scale,sysname,mode,case,run,ms) in all_rows:
        groups[(scale,sysname,mode,case)].append(ms)
    with open(SUMMARY_CSV,"w",newline="") as f:
        w=csv.writer(f); w.writerow(["scale","system","mode","case","warmups","repeats","mem_gb","avg_ms"])
        for k in sorted(groups):
            scale,sysname,mode,case=k
            avg=sum(groups[k])/len(groups[k])
            w.writerow([scale,sysname,mode,case,WARMUPS,REPEATS,mem_gb,f"{avg:.3f}"])
    with open(SUMMARY_TXT,"w") as f:
        f.write("ClickHouse exec（仅执行）\n")
        f.write("--max_threads=1; ENGINE=Memory; 预热3，统计7；只 7 列\n\n")
        f.write(f"max_memory_usage ≈ {int(mem_gb*(1024**3))} bytes (~{mem_gb}GB)\n\n平均时间（ms）：\n")
        f.write(f"{'scale':>5}  {'case':<22}  {'avg_ms':>12}\n")
        f.write("-"*44+"\n")
        for k in sorted(groups):
            scale,_,_,case=k
            avg=sum(groups[k])/len(groups[k])
            f.write(f"{scale:>5}  {case:<22}  {avg:>12.3f}\n")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--base", default=DEFAULT_BASE)
    ap.add_argument("--scales", nargs="+", type=int, default=SCALES)
    ap.add_argument("--mem-gb", type=int, default=DEFAULT_MEM_GB)
    args=ap.parse_args()
    all_rows=[]
    for scale in args.scales:
        path=os.path.join(args.base, f"sf{scale}_parquet","lineitem.parquet")
        if not os.path.exists(path):
            print(f"[WARN] 缺失 {path}，跳过 SF{scale}"); continue
        print(f"\n=== ClickHouse exec | SF{scale} ===")
        rows=run_scale(path, args.mem_gb)
        all_rows += [(scale,)+r for r in rows]
    write_out(all_rows, args.scales, args.mem_gb)
    print(f"\n[DONE] 输出到 {OUTDIR}/")

if __name__=="__main__":
    main()