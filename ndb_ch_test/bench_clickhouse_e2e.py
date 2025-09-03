#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ClickHouse e2e（端到端墙钟，不预热）
- 每轮：新进程 --multiquery 带同一批 settings
  DROP/CREATE ENGINE=Memory（7列schema）→ 从 Parquet INSERT → 执行 1 次查询
- 记录整段墙钟；重复 7 轮取平均
输出：bench_out_clickhouse_e2e/{results.csv, summary_avg.csv, summary_report.txt}
"""

import os, sys, csv, time, argparse, subprocess
from collections import defaultdict

DEFAULT_BASE="/home/bochengh/ndb_fisrt_stage"
SCALES=[1,3,5]
REPEATS=2
DEFAULT_MEM_GB=80
CLICKHOUSE_BIN=os.environ.get("CLICKHOUSE_BIN","clickhouse")

OUTDIR="bench_out_clickhouse_e2e"
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

def run_scale(parquet_path, mem_gb):
    mem_bytes=int(mem_gb*(1024**3))
    rows=[]
    for case, sql in SQLS.items():
        sql=sql.strip()
        print(f"[CH/e2e] {case} ：每轮新进程 + 建表 + 装载 + 执行一次")
        for run in range(1, REPEATS+1):
            setup=f"""
            SET output_format_write_statistics = 1;
            DROP TABLE IF EXISTS lineitem_mem;
            CREATE TABLE lineitem_mem ENGINE=Memory AS
              SELECT {PROJ_COLS}
              FROM file('{parquet_path}','Parquet') LIMIT 0;
            INSERT INTO lineitem_mem
              SELECT {PROJ_COLS}
              FROM file('{parquet_path}','Parquet');
            {sql}
            """
            cmd=[CLICKHOUSE_BIN,"local","--multiquery"]+ch_settings(mem_bytes)
            t0=time.perf_counter()
            subprocess.run(cmd, input=setup.encode(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True)
            ms=(time.perf_counter()-t0)*1000.0
            print(f"  - run {run}/{REPEATS}: {ms:.3f} ms")
            rows.append(("clickhouse","e2e",case,run,ms))
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
        w=csv.writer(f); w.writerow(["scale","system","mode","case","repeats","mem_gb","avg_ms"])
        for k in sorted(groups):
            scale,sysname,mode,case=k
            avg=sum(groups[k])/len(groups[k])
            w.writerow([scale,sysname,mode,case,REPEATS,mem_gb,f"{avg:.3f}"])
    with open(SUMMARY_TXT,"w") as f:
        f.write("ClickHouse e2e（端到端墙钟；不预热）\n")
        f.write("每轮：新进程→DROP/CREATE→INSERT Parquet(7列)→执行1次；重复7轮\n\n")
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
        print(f"\n=== ClickHouse e2e | SF{scale} ===")
        rows=run_scale(path, args.mem_gb)
        all_rows += [(scale,)+r for r in rows]
    write_out(all_rows, args.scales, args.mem_gb)
    print(f"\n[DONE] 输出到 {OUTDIR}/")

if __name__=="__main__":
    main()