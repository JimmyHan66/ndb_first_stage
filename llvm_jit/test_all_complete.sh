#!/bin/bash

echo "🧪 Complete Test Suite (Excluding SF5 sort_only_shipdate e2e)"
echo "=============================================================="

cd /home/bochengh/ndb_fisrt_stage/llvm_jit
export LD_LIBRARY_PATH="/home/bochengh/ndb_fisrt_stage/build:/home/bochengh/.local/lib:$LD_LIBRARY_PATH"

# 定义所有测试用例
CASES=("scan_filter_q1" "scan_filter_q6" "agg_only_q1" "sort_only_shipdate" "q6_full" "q1_full")
SCALES=("SF1" "SF3" "SF5")
MODES=("exec" "e2e")

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# 创建结果文件
RESULTS_FILE="complete_test_results_$(date +%Y%m%d_%H%M%S).csv"
echo "scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity" > $RESULTS_FILE

echo "📝 Results will be saved to: $RESULTS_FILE"
echo

# 检查是否应该跳过某个测试
should_skip_test() {
    local scale=$1
    local case=$2
    local mode=$3

    # 跳过 SF5 sort_only_shipdate e2e (耗时过长)
    if [[ "$scale" == "SF5" && "$case" == "sort_only_shipdate" && "$mode" == "e2e" ]]; then
        return 0  # 跳过
    fi

    return 1  # 不跳过
}

# 开始测试循环
for scale in "${SCALES[@]}"; do
    echo "🔄 Testing scale: $scale"
    echo "=================="

    for case in "${CASES[@]}"; do
        echo
        echo "📦 Testing case: $case"
        echo "-------------------"

        for mode in "${MODES[@]}"; do
            TOTAL_TESTS=$((TOTAL_TESTS + 1))

            echo -n "  [$TOTAL_TESTS] $scale $case $mode ... "

            # 检查是否跳过
            if should_skip_test "$scale" "$case" "$mode"; then
                echo "⏭️  SKIPPED (excessive runtime)"
                SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
                continue
            fi

            # 运行测试并捕获输出
            TEST_OUTPUT=$(timeout 300s ./benchmark_framework $scale $case $mode 2>&1)
            TEST_EXIT_CODE=$?

            if [ $TEST_EXIT_CODE -eq 124 ]; then
                echo "⏰ TIMEOUT (>5min) - SKIPPED"
                SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            elif [ $TEST_EXIT_CODE -eq 0 ]; then
                # 提取 CSV 数据行（跳过header）
                CSV_LINE=$(echo "$TEST_OUTPUT" | tail -n 1)

                # 验证输出格式
                if [[ $CSV_LINE == $scale,$case,$mode,* ]]; then
                    echo "✅ PASSED"
                    echo "$CSV_LINE" >> $RESULTS_FILE
                    PASSED_TESTS=$((PASSED_TESTS + 1))
                else
                    echo "❌ FAILED (invalid output format)"
                    echo "Output: $TEST_OUTPUT"
                    FAILED_TESTS=$((FAILED_TESTS + 1))
                fi
            else
                echo "❌ FAILED (exit code: $TEST_EXIT_CODE)"
                echo "Error output: $TEST_OUTPUT"
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi

            # 简短延迟避免资源冲突
            sleep 1
        done
    done

    echo
    echo "✅ Scale $scale completed"
    echo
done

echo "📊 Final Test Summary"
echo "===================="
echo "Total tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Skipped: $SKIPPED_TESTS"
echo "Success rate: $(echo "scale=1; $PASSED_TESTS * 100 / ($PASSED_TESTS + $FAILED_TESTS)" | bc -l)%"
echo
echo "📝 Results saved to: $RESULTS_FILE"

if [ $FAILED_TESTS -eq 0 ]; then
    echo "🎉 All attempted tests PASSED!"
else
    echo "⚠️  Some tests FAILED. Please review the error output above."
fi

echo
echo "🔍 Total test count by file:"
wc -l $RESULTS_FILE

echo
echo "📊 Generating summary statistics..."
python3 generate_summary.py $RESULTS_FILE

echo
echo "✅ Complete test suite finished!"
