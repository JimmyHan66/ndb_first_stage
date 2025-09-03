#!/bin/bash

# Q6 LLVM IR 编译脚本

echo "=== Generating Q6 LLVM IR ==="

# 编译 filter kernels 到 LLVM IR (如果还没有编译)
if [ ! -f "../common/filter_kernels.ll" ]; then
    echo "Compiling common filter kernels..."
    /usr/bin/clang -S -emit-llvm -O3 -o ../common/filter_kernels.ll ../common/filter_kernels.c
else
    echo "Using existing filter kernels IR..."
fi

# 编译 Q6 批处理驱动到 LLVM IR
echo "Compiling Q6 batch driver..."
/usr/bin/clang -S -emit-llvm -O3 -I../common -o q6_batch_driver.ll q6_batch_driver.c

echo "=== Q6 LLVM IR files generated ==="
echo "Files:"
ls -la *.ll ../common/*.ll

echo ""
echo "=== Q6 LLVM IR Content Preview ==="
echo "--- Filter Kernels IR (first 30 lines) ---"
head -30 ../common/filter_kernels.ll

echo ""
echo "--- Q6 Batch Driver IR (first 30 lines) ---"
head -30 q6_batch_driver.ll

echo ""
echo "=== Q6 IR compilation completed ==="
