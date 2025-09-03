# clang -shared -fPIC main.c -o main.o -O3 -march=native -fvectorize -o libmain.so
rm -rf libq1.so libq6.so libq1_inc.so libq6_inc.so

# 编译原始的聚合函数（包含新增的*_with_sel函数）
clang -shared -fPIC q6_onebatch.c avx2_double_simd_sum.c libxxhash.a -O3 -march=native -mfma -funroll-loops -fvectorize -o libq6.so
# clang -shared -fPIC q6_onebatch.ll avx2_double_simd_sum.c libxxhash.a -O3 -march=native -mfma -funroll-loops -fvectorize -o libq6_ll.so

# clang -shared -fPIC q1_onebatch_256.c avx2_double_simd_sum.c libxxhash.a -O3 -march=native -mfma -funroll-loops -o libq1.so
clang -shared -fPIC q1_onebatch_256_qsortfull.c pdqsort.c avx2_double_simd_sum.c libxxhash.a -O3 -march=native -mfma -funroll-loops -o libq1.so

# 编译增量聚合函数
# 手动指定Arrow include路径
ARROW_INCLUDE="-I/home/bochengh/.local/include"

clang -shared -fPIC q6_incremental.c avx2_double_simd_sum.c libxxhash.a -I../include ${ARROW_INCLUDE} -O3 -march=native -mfma -funroll-loops -fvectorize -o libq6_inc.so
clang -shared -fPIC q1_incremental.c pdqsort.c avx2_double_simd_sum.c libxxhash.a -I../include ${ARROW_INCLUDE} -O3 -march=native -mfma -funroll-loops -o libq1_inc.so

