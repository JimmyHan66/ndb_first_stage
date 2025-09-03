#!/bin/bash

# 生成所有 6 个完整 JIT 流水线的 LLVM IR - 支持不同优化级别

# 获取优化级别参数 (默认 O2)
OPT_LEVEL=${1:-O2}
echo "=== Generating LLVM IR with -$OPT_LEVEL optimization ==="

# 检查必要的依赖
if [ ! -f "../common/filter_kernels.ll" ]; then
    echo "❌ Missing filter_kernels.ll - please generate it first"
    exit 1
fi

if [ ! -f "../../arrow-c/q1_incremental.ll" ]; then
    echo "❌ Missing q1_incremental.ll - please generate arrow-c IR first"
    exit 1
fi

if [ ! -f "../../arrow-c/q6_incremental.ll" ]; then
    echo "❌ Missing q6_incremental.ll - please generate arrow-c IR first"
    exit 1
fi

# 编译所有流水线
PIPELINES=("scan_filter_q1" "scan_filter_q6" "agg_only_q1" "sort_only_shipdate" "q6_full" "q1_full")

for pipeline in "${PIPELINES[@]}"; do
    echo "Compiling ${pipeline}_pipeline.c..."
    /usr/bin/clang -S -emit-llvm -$OPT_LEVEL \
      -I../common \
      -I../../include \
      -I../../arrow-c \
      -o ${pipeline}_pipeline.ll \
      ${pipeline}_pipeline.c

    if [ $? -eq 0 ]; then
        echo "✅ ${pipeline}_pipeline.ll generated successfully"
    else
        echo "❌ Failed to generate ${pipeline}_pipeline.ll"
        exit 1
    fi
done

echo ""
echo "=== All Pipeline IR Files Generated ==="
ls -la *.ll

echo ""
echo "=== JIT Pipeline Components Summary ==="
echo "Filter Kernels: ../common/filter_kernels.ll"
echo "Q1 Aggregation: ../../arrow-c/q1_incremental.ll"
echo "Q6 Aggregation: ../../arrow-c/q6_incremental.ll"
echo "AVX2 SIMD Sum: ../../arrow-c/avx2_double_simd_sum.ll"
echo "Sorting: ../../arrow-c/pdqsort.ll"
echo ""
echo "Pipeline IR files:"
for pipeline in "${PIPELINES[@]}"; do
    echo "  ${pipeline}_pipeline.ll"
done

echo ""
echo "🎉 Complete JIT architecture ready for testing!"
