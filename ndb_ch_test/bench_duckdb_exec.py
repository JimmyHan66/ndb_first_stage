#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DuckDB exec（仅执行）
- 单线程：PRAGMA threads=1
- 内存：PRAGMA memory_limit
- 只装载 7 列到 TEMP 表（不计时）
- 每个用例：预热 3 次 + 正式 7 次（仅计执行时间）
输出：bench_out_duckdb_exec/{results.csv, summary_avg.csv, summary_report.txt}
"""

import os, sys, csv, time, argparse
from collections import defaultdict

DEFAULT_BASE = "/home/bochengh/ndb_fisrt_stage"
SCALES = [1,3,5]
WARMUPS = 3
REPEATS = 7
DEFAULT_MEM_GB = 80

OUTDIR = "bench_out_duckdb_exec"
RESULT_CSV = os.path.join(OUTDIR, "results.csv")
SUMMARY_CSV = os.path.join(OUTDIR, "summary_avg.csv")
SUMMARY_TXT = os.path.join(OUTDIR, "summary_report.txt")

PROJ_COLS = "l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_discount, l_tax, l_shipdate"

Q6_FILTER = """
l_shipdate >= DATE '1994-01-01'
AND l_shipdate <  DATE '1995-01-01'
AND l_discount BETWEEN 0.05 AND 0.07
AND l_quantity < 24
"""
Q1_PRED = "l_shipdate <= DATE '1998-12-01' - INTERVAL 90 DAY"

SQLS = {
    "scan_filter_q6": f"SELECT count(*) FROM lineitem WHERE {Q6_FILTER};",
    "scan_filter_q1": f"SELECT count(*) FROM lineitem WHERE {Q1_PRED};",
    "agg_only_q1": f"""
        SELECT l_returnflag, l_linestatus,
               SUM(l_quantity) AS sum_qty,
               SUM(l_extendedprice) AS sum_base_price,
               SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
               SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
               AVG(l_quantity) AS avg_qty,
               AVG(l_extendedprice) AS avg_price,
               AVG(l_discount) AS avg_disc,
               COUNT(*) AS count_order
        FROM lineitem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus;
    """,
    "sort_only_shipdate": "SELECT l_shipdate FROM lineitem ORDER BY l_shipdate;",
    "q6_full": f"SELECT SUM(l_extendedprice * l_discount) AS revenue FROM lineitem WHERE {Q6_FILTER};",
    "q1_full": f"""
        SELECT l_returnflag, l_linestatus,
               SUM(l_quantity) AS sum_qty,
               SUM(l_extendedprice) AS sum_base_price,
               SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
               SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
               AVG(l_quantity) AS avg_qty,
               AVG(l_extendedprice) AS avg_price,
               AVG(l_discount) AS avg_disc,
               COUNT(*) AS count_order
        FROM lineitem
        WHERE {Q1_PRED}
        GROUP BY l_returnflag, l_linestatus
        ORDER BY l_returnflag, l_linestatus;
    """,
}

def have_duckdb():
    try:
        import duckdb  # noqa
        return True
    except:
        return False

def run_scale(parquet_path, mem_gb):
    import duckdb
    con = duckdb.connect(database=":memory:")
    con.execute("PRAGMA threads=1;")
    con.execute("PRAGMA enable_progress_bar=false;")
    con.execute(f"PRAGMA memory_limit='{mem_gb}GB';")
    print(f"[DuckDB/exec] 建内存表（仅7列）: {parquet_path}")
    con.execute(f"""
        CREATE TEMP TABLE lineitem AS
        SELECT {PROJ_COLS}
        FROM read_parquet('{parquet_path}');
    """)
    rows=[]
    for case, sql in SQLS.items():
        sql = sql.strip()
        con.execute(f"PREPARE q AS {sql}")
        print(f"[DuckDB/exec] 预热 {case} x {WARMUPS} ...")
        for _ in range(WARMUPS):
            con.execute("EXECUTE q;")
        print(f"[DuckDB/exec] 正式 {case} x {REPEATS} 计时 ...")
        for run in range(1, REPEATS+1):
            t0 = time.perf_counter()
            con.execute("EXECUTE q;").fetchall()
            ms = (time.perf_counter() - t0) * 1000.0
            print(f"  - {case} run {run}/{REPEATS}: {ms:.3f} ms")
            rows.append(("duckdb","exec",case,run,ms))
    con.close()
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
            scale,sysname,mode,case = k
            avg = sum(groups[k])/len(groups[k])
            w.writerow([scale,sysname,mode,case,WARMUPS,REPEATS,mem_gb,f"{avg:.3f}"])
    with open(SUMMARY_TXT,"w") as f:
        f.write("DuckDB exec（仅执行）\n")
        f.write("单线程 threads=1；PRAGMA memory_limit；TEMP 表仅7列；预热3，统计7\n\n")
        f.write(f"内存上限：{mem_gb}GB\n\n平均时间（ms）：\n")
        f.write(f"{'scale':>5}  {'case':<22}  {'avg_ms':>12}\n")
        f.write("-"*44+"\n")
        for k in sorted(groups):
            scale,_,_,case = k
            avg = sum(groups[k])/len(groups[k])
            f.write(f"{scale:>5}  {case:<22}  {avg:>12.3f}\n")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--base", default=DEFAULT_BASE)
    ap.add_argument("--scales", nargs="+", type=int, default=SCALES)
    ap.add_argument("--mem-gb", type=int, default=DEFAULT_MEM_GB)
    args=ap.parse_args()
    if not have_duckdb():
        print("ERROR: 需要 duckdb Python 包", file=sys.stderr); sys.exit(1)
    all_rows=[]
    for scale in args.scales:
        path = os.path.join(args.base, f"sf{scale}_parquet","lineitem.parquet")
        if not os.path.exists(path):
            print(f"[WARN] 缺失 {path}，跳过 SF{scale}")
            continue
        print(f"\n=== DuckDB exec | SF{scale} ===")
        rows = run_scale(path, args.mem_gb)
        all_rows += [(scale,)+r for r in rows]
    write_out(all_rows, args.scales, args.mem_gb)
    print(f"\n[DONE] 输出到 {OUTDIR}/")

if __name__=="__main__":
    main()