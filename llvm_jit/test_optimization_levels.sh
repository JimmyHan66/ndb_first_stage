#!/bin/bash

# 测试不同优化级别的性能对比脚本
echo "🧪 Testing Different Optimization Levels for JIT Compilation"
echo "============================================================="

CASE_NAME="scan_filter_q1"
SCALE="SF1"

echo
echo "📊 Test Configuration:"
echo "  - Case: $CASE_NAME"
echo "  - Scale: $SCALE"
echo "  - Iterations per mode: 3"
echo

# 创建结果目录
mkdir -p optimization_test_results
cd optimization_test_results

echo "🔄 Step 1: Generate LLVM IR with different optimization levels..."

# 生成 O2 优化的 IR
echo "  - Generating O2 IR..."
cd ../pipelines
./generate_all_ir.sh O2 > /dev/null 2>&1
cp scan_filter_q1_pipeline.ll ../optimization_test_results/scan_filter_q1_O2.ll

# 生成 O3 优化的 IR
echo "  - Generating O3 IR..."
./generate_all_ir.sh O3 > /dev/null 2>&1
cp scan_filter_q1_pipeline.ll ../optimization_test_results/scan_filter_q1_O3.ll

cd ../optimization_test_results

echo "✅ IR generation complete"

echo
echo "📈 Step 2: Size Comparison of Generated IR"
echo "----------------------------------------"
echo "O2 IR size: $(wc -l scan_filter_q1_O2.ll | awk '{print $1}') lines"
echo "O3 IR size: $(wc -l scan_filter_q1_O3.ll | awk '{print $1}') lines"

echo
echo "🚀 Step 3: Performance Testing"
echo "-----------------------------"

echo
echo "📋 Testing EXEC mode (O3 optimization):"
echo "  - JIT compilation uses -O3 (maximum execution performance)"
echo "  - Compilation time NOT included in measurement"
echo
for i in {1..3}; do
    echo "  Run $i:"
    cd ..
    ./benchmark_framework $SCALE $CASE_NAME exec 2>/dev/null | grep -E "(Total execution time|Performance)"
    cd optimization_test_results
done

echo
echo "📋 Testing E2E mode (O2 optimization):"
echo "  - JIT compilation uses -O2 (balanced compile+exec performance)"
echo "  - Compilation time IS included in measurement"
echo
for i in {1..3}; do
    echo "  Run $i:"
    cd ..
    ./benchmark_framework $SCALE $CASE_NAME e2e 2>/dev/null | grep -E "(Total wall-clock time|JIT compilation time|Performance)"
    cd optimization_test_results
done

echo
echo "🎯 Summary:"
echo "========="
echo "✅ EXEC mode: Uses -O3 → Maximum execution speed (ignores compile time)"
echo "✅ E2E mode:  Uses -O2 → Balanced performance (includes compile time)"
echo
echo "💡 This design ensures:"
echo "   - Fair comparison of pure execution performance in EXEC mode"
echo "   - Realistic end-to-end JIT performance in E2E mode"
echo
echo "📁 Generated files in optimization_test_results/:"
ls -la *.ll

cd ..
echo
echo "🏁 Testing complete!"
