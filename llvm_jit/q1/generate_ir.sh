#!/bin/bash

# Q1 LLVM IR 编译脚本

echo "=== Generating Q1 LLVM IR ==="

# 编译 filter kernels 到 LLVM IR
echo "Compiling common filter kernels..."
/usr/bin/clang -S -emit-llvm -O3 -o ../common/filter_kernels.ll ../common/filter_kernels.c

# 编译 Q1 批处理驱动到 LLVM IR
echo "Compiling Q1 batch driver..."
/usr/bin/clang -S -emit-llvm -O3 -I../common -o q1_batch_driver.ll q1_batch_driver.c

echo "=== Q1 LLVM IR files generated ==="
echo "Files:"
ls -la *.ll ../common/*.ll

echo ""
echo "=== Q1 LLVM IR Content Preview ==="
echo "--- Filter Kernels IR (first 30 lines) ---"
head -30 ../common/filter_kernels.ll

echo ""
echo "--- Q1 Batch Driver IR (first 30 lines) ---"
head -30 q1_batch_driver.ll

echo ""
echo "=== Q1 IR compilation completed ==="
