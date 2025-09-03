#!/usr/bin/env python3

import csv
import sys
from datetime import datetime
from collections import defaultdict

def read_results(filename):
    """读取测试结果CSV文件"""
    results = []
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            results.append(row)
    return results

def generate_summary_min_csv(results, output_file):
    """生成 summary_min.csv"""
    # 按 (scale, case, mode) 聚合数据
    grouped = defaultdict(list)

    for result in results:
        key = (result['scale'], result['case'], result['mode'])
        grouped[key].append(result)

    # 生成汇总数据
    summary_data = []
    for (scale, case, mode), group in grouped.items():
        if not group:
            continue

        # 取第一条记录的基本信息
        first = group[0]
        ms = float(first['ms'])
        rows_processed = int(first['rows_processed'])

        # 计算吞吐量 (rows/sec)
        throughput = int(rows_processed / (ms / 1000.0)) if ms > 0 else 0

        summary_data.append({
            'scale': scale,
            'case': case,
            'mode': mode,
            'warmups': 3 if mode == 'exec' else 0,
            'repeats': 2,
            'min_ms': ms,
            'throughput_rows_per_sec': throughput
        })

    # 写入 CSV
    with open(output_file, 'w', newline='') as f:
        fieldnames = ['scale', 'case', 'mode', 'warmups', 'repeats', 'min_ms', 'throughput_rows_per_sec']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in sorted(summary_data, key=lambda x: (x['scale'], x['case'], x['mode'])):
            writer.writerow(row)

def generate_summary_report_txt(results, output_file):
    """生成 summary_report.txt"""

    with open(output_file, 'w') as f:
        f.write("NDB JIT Benchmark Summary Report\n")
        f.write("=" * 50 + "\n\n")

        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        # 环境配置
        f.write("Environment Configuration:\n")
        f.write("-" * 25 + "\n")
        f.write("• Single-threaded execution\n")
        f.write("• Batch size: 2048 rows\n")
        f.write("• JIT optimization: -O3 (exec), -O2 (e2e)\n")
        f.write("• Hardware: Native CPU with AVX2 support\n\n")

        # 测试模式定义
        f.write("Test Mode Definitions:\n")
        f.write("-" * 22 + "\n")
        f.write("• EXEC Mode:\n")
        f.write("  - Only times JIT kernel execution\n")
        f.write("  - Excludes: Parquet reading, Arrow conversion, JIT compilation\n")
        f.write("  - Includes: 3 warmup runs + 2 measurement runs (min reported)\n\n")
        f.write("• E2E Mode:\n")
        f.write("  - Times complete end-to-end pipeline\n")
        f.write("  - Includes: Parquet → Arrow → JIT compilation → execution\n")
        f.write("  - No warmup, 2 rounds with fresh JIT compilation each time\n\n")

        # 按规模分组显示结果
        scales = ['SF1', 'SF3', 'SF5']
        cases = ['scan_filter_q1', 'scan_filter_q6', 'agg_only_q1', 'sort_only_shipdate', 'q6_full', 'q1_full']

        for scale in scales:
            f.write(f"Performance Results - {scale}:\n")
            f.write("-" * (22 + len(scale)) + "\n")

            # 表头
            f.write(f"{'Case':<20} {'Exec(ms)':<12} {'E2E(ms)':<12} {'Throughput(M rows/s)':<20} {'Selectivity':<12}\n")
            f.write("-" * 80 + "\n")

            for case in cases:
                exec_result = None
                e2e_result = None

                for result in results:
                    if result['scale'] == scale and result['case'] == case:
                        if result['mode'] == 'exec':
                            exec_result = result
                        elif result['mode'] == 'e2e':
                            e2e_result = result

                if exec_result or e2e_result:
                    case_name = case.replace('_', ' ')

                    exec_ms = f"{float(exec_result['ms']):.1f}" if exec_result else "N/A"
                    e2e_ms = f"{float(e2e_result['ms']):.1f}" if e2e_result else "N/A"

                    # 计算吞吐量 (使用 exec 时间，如果没有则用 e2e 的 exec_once_ms)
                    if exec_result:
                        throughput = int(exec_result['rows_processed']) / (float(exec_result['ms']) / 1000.0) / 1e6
                    elif e2e_result and e2e_result['exec_once_ms']:
                        throughput = int(e2e_result['rows_processed']) / (float(e2e_result['exec_once_ms']) / 1000.0) / 1e6
                    else:
                        throughput = 0

                    throughput_str = f"{throughput:.2f}" if throughput > 0 else "N/A"

                    selectivity = exec_result['selectivity'] if exec_result else (e2e_result['selectivity'] if e2e_result else "N/A")

                    f.write(f"{case_name:<20} {exec_ms:<12} {e2e_ms:<12} {throughput_str:<20} {selectivity:<12}\n")

            f.write("\n")

        # 总体统计
        f.write("Summary Statistics:\n")
        f.write("-" * 19 + "\n")

        total_tests = len(results)
        exec_tests = len([r for r in results if r['mode'] == 'exec'])
        e2e_tests = len([r for r in results if r['mode'] == 'e2e'])

        f.write(f"Total tests completed: {total_tests}\n")
        f.write(f"• EXEC mode tests: {exec_tests}\n")
        f.write(f"• E2E mode tests: {e2e_tests}\n\n")

        # 性能亮点
        f.write("Performance Highlights:\n")
        f.write("-" * 20 + "\n")

        # 找出最快和最慢的测试
        exec_results = [r for r in results if r['mode'] == 'exec']
        if exec_results:
            fastest = min(exec_results, key=lambda x: float(x['ms']))
            slowest = max(exec_results, key=lambda x: float(x['ms']))

            f.write(f"• Fastest EXEC: {fastest['case']} ({fastest['scale']}) - {float(fastest['ms']):.1f}ms\n")
            f.write(f"• Slowest EXEC: {slowest['case']} ({slowest['scale']}) - {float(slowest['ms']):.1f}ms\n")

        f.write("\nNote: SF5 sort_only_shipdate tests were excluded due to excessive runtime.\n")

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 generate_summary.py <results_csv_file>")
        sys.exit(1)

    results_file = sys.argv[1]

    try:
        # 读取结果
        results = read_results(results_file)
        print(f"📊 Loaded {len(results)} test results from {results_file}")

        # 过滤掉问题测试 (SF5 sort_only_shipdate)
        filtered_results = []
        excluded_count = 0

        for result in results:
            if result['scale'] == 'SF5' and 'sort_only_shipdate' in result['case']:
                excluded_count += 1
                print(f"⚠️  Excluding {result['scale']} {result['case']} {result['mode']} (excessive runtime)")
            else:
                filtered_results.append(result)

        print(f"📋 Using {len(filtered_results)} results ({excluded_count} excluded)")

        # 生成汇总文件
        summary_csv = "summary_min.csv"
        summary_txt = "summary_report.txt"

        generate_summary_min_csv(filtered_results, summary_csv)
        print(f"✅ Generated {summary_csv}")

        generate_summary_report_txt(filtered_results, summary_txt)
        print(f"✅ Generated {summary_txt}")

        print("\n🎉 Summary generation completed!")

    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
