#!/bin/bash

echo "🧪 Quick TPC-H JIT Test Verification"
echo "==================================="

# 检查必要文件
echo "📋 Checking prerequisites..."

if [ ! -f "benchmark_framework" ]; then
    echo "❌ benchmark_framework not found, attempting to compile..."
    gcc -o benchmark_framework benchmark_framework.c \
        -I../include -L/home/bochengh/.local/lib \
        -larrow -lparquet -ldl -lm -pthread

    if [ $? -eq 0 ]; then
        echo "✅ benchmark_framework compiled successfully"
    else
        echo "❌ Failed to compile benchmark_framework"
        exit 1
    fi
fi

echo "✅ benchmark_framework ready"

# 检查parquet文件
echo "📁 Checking parquet files..."
for scale in sf1 sf3 sf5; do
    file="../${scale}_parquet/lineitem.parquet"
    if [ -f "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        echo "✅ $scale: $size"
    else
        echo "❌ Missing: $file"
    fi
done

# 检查IR文件
echo "⚙️ Checking LLVM IR files..."
cd pipelines
missing_ir=false
for pipeline in scan_filter_q1 scan_filter_q6 agg_only_q1 sort_only_shipdate q6_full q1_full; do
    if [ -f "${pipeline}_pipeline.ll" ]; then
        lines=$(wc -l < "${pipeline}_pipeline.ll")
        echo "✅ ${pipeline}_pipeline.ll ($lines lines)"
    else
        echo "❌ Missing: ${pipeline}_pipeline.ll"
        missing_ir=true
    fi
done

if [ "$missing_ir" = true ]; then
    echo "🔄 Generating missing IR files..."
    ./generate_all_ir.sh O2
fi

cd ..

echo ""
echo "🚀 Running test: scan_filter_q1 on SF1"
echo "======================================"

# 测试单个用例
./benchmark_framework SF1 scan_filter_q1 exec

echo ""
echo "🏁 Quick test complete!"
