#!/bin/bash

# TPC-H JIT 基准测试批量运行脚本
# 测试所有 6 个用例在 SF1/SF3/SF5 下的 exec 和 e2e 性能

set -e

echo "=== TPC-H JIT Benchmark Suite ==="
echo "Starting comprehensive benchmark testing..."
echo ""

# 检查必要文件
if [ ! -f "benchmark_framework" ]; then
    echo "❌ benchmark_framework not found. Please compile it first."
    exit 1
fi

# 测试配置
SCALES=("SF1" "SF3" "SF5")
CASES=("scan_filter_q1" "scan_filter_q6" "agg_only_q1" "sort_only_shipdate" "q6_full" "q1_full")
MODES=("exec" "e2e")

# 输出文件
RESULTS_CSV="benchmark_results.csv"
SUMMARY_CSV="benchmark_summary.csv"
REPORT_TXT="benchmark_report.txt"

# 清理旧结果
rm -f "$RESULTS_CSV" "$SUMMARY_CSV" "$REPORT_TXT"

# 写入 CSV 头部
echo "scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity,throughput_rows_per_sec" > "$RESULTS_CSV"

# 开始测试
echo "🚀 Starting benchmark tests..."
echo ""

total_tests=$((${#SCALES[@]} * ${#CASES[@]} * ${#MODES[@]}))
current_test=0

for scale in "${SCALES[@]}"; do
    echo "📊 Testing scale: $scale"

    for case in "${CASES[@]}"; do
        echo "  📋 Testing case: $case"

        for mode in "${MODES[@]}"; do
            current_test=$((current_test + 1))
            echo "    ⏱️  Running $mode mode... ($current_test/$total_tests)"

            # 运行基准测试
            if ./benchmark_framework "$scale" "$case" "$mode" >> "$RESULTS_CSV" 2>/dev/null; then
                echo "    ✅ $scale $case $mode completed"
            else
                echo "    ❌ $scale $case $mode failed"
                echo "$scale,$case,$mode,error,0,0,0,0,0,0" >> "$RESULTS_CSV"
            fi
        done
        echo ""
    done
done

echo "🎉 All benchmark tests completed!"
echo ""

# 生成汇总报告
echo "📈 Generating summary report..."

cat > "$REPORT_TXT" << EOF
=== TPC-H JIT Benchmark Report ===
Generated on: $(date)

Environment:
- Single thread execution
- Batch size: 2048
- Warmup runs (exec): 3
- Measurement runs: 2 (minimum taken)
- JIT optimization: -O3 -march=native

Test Definitions:
- exec: Pure execution time (after JIT compilation, with warmup)
- e2e: End-to-end wallclock time (includes JIT compilation, no warmup)

Test Cases:
1. scan_filter_q1: Scan + Q1 date filter (l_shipdate <= '1998-12-01')
2. scan_filter_q6: Scan + Q6 multi-level filter (4-stage chain)
3. agg_only_q1: Scan + Full selection + Q1 aggregation + sorting
4. sort_only_shipdate: Scan + Extract shipdate + Global sorting
5. q6_full: Scan + Q6 filter + Q6 aggregation (complete pipeline)
6. q1_full: Scan + Q1 filter + Q1 aggregation + sorting (complete pipeline)

Detailed Results:
EOF

# 解析结果并生成汇总
python3 << 'PYTHON_SCRIPT' >> "$REPORT_TXT"
import csv
import sys

def parse_results():
    try:
        with open('benchmark_results.csv', 'r') as f:
            reader = csv.DictReader(f)
            results = list(reader)
    except:
        print("Error reading results file")
        return

    # 按scale和mode分组
    scales = ['SF1', 'SF3', 'SF5']
    cases = ['scan_filter_q1', 'scan_filter_q6', 'agg_only_q1',
             'sort_only_shipdate', 'q6_full', 'q1_full']
    modes = ['exec', 'e2e']

    for mode in modes:
        print(f"\n--- {mode.upper()} Mode Results ---")
        print(f"{'Case':<20} {'SF1':<12} {'SF3':<12} {'SF5':<12}")
        print("-" * 60)

        for case in cases:
            row = f"{case:<20}"
            for scale in scales:
                # 查找对应的结果
                found = False
                for result in results:
                    if (result['scale'] == scale and
                        result['case'] == case and
                        result['mode'] == mode):
                        ms = float(result['ms']) if result['ms'] != '0' else 0
                        if ms > 0:
                            row += f"{ms:>8.1f}ms   "
                        else:
                            row += f"{'FAILED':<12}"
                        found = True
                        break
                if not found:
                    row += f"{'MISSING':<12}"
            print(row)

    # 生成性能摘要
    print(f"\n--- Performance Summary ---")
    for mode in modes:
        print(f"\n{mode.upper()} Mode - Throughput (rows/sec):")
        print(f"{'Case':<20} {'SF1':<15} {'SF3':<15} {'SF5':<15}")
        print("-" * 70)

        for case in cases:
            row = f"{case:<20}"
            for scale in scales:
                found = False
                for result in results:
                    if (result['scale'] == scale and
                        result['case'] == case and
                        result['mode'] == mode):
                        throughput = float(result['throughput_rows_per_sec']) if result['throughput_rows_per_sec'] != '0' else 0
                        if throughput > 0:
                            if throughput >= 1e6:
                                row += f"{throughput/1e6:>10.1f}M      "
                            else:
                                row += f"{throughput/1e3:>10.1f}K      "
                        else:
                            row += f"{'FAILED':<15}"
                        found = True
                        break
                if not found:
                    row += f"{'MISSING':<15}"
            print(row)

parse_results()
PYTHON_SCRIPT

echo ""
echo "📋 Reports generated:"
echo "  - Detailed results: $RESULTS_CSV"
echo "  - Summary report: $REPORT_TXT"
echo ""
echo "🎯 To view results:"
echo "  cat $REPORT_TXT"
echo "  head -20 $RESULTS_CSV"
