# 🚀 TPC-H JIT 测试指南

## 📋 测试准备清单

### ✅ 已完成的组件

1. **JIT 流水线** (6个完整实现)
   - `scan_filter_q1_pipeline.ll` ✅
   - `scan_filter_q6_pipeline.ll` ✅ 
   - `agg_only_q1_pipeline.ll` ✅
   - `sort_only_shipdate_pipeline.ll` ✅
   - `q6_full_pipeline.ll` ✅
   - `q1_full_pipeline.ll` ✅

2. **聚合函数** (优化版本)
   - `q1_incremental_optimized.ll` ✅
   - `q6_incremental_optimized.ll` ✅
   - `avx2_double_simd_sum.ll` ✅
   - `pdqsort.ll` ✅

3. **基准测试框架**
   - `benchmark_framework.c` ✅ (智能O2/O3优化)
   - `run_all_benchmarks.sh` ✅
   - 列选择优化 ✅

4. **数据文件**
   - `sf1_parquet/lineitem.parquet` ✅ (231MB)
   - `sf3_parquet/lineitem.parquet` ✅ (724MB)
   - `sf5_parquet/lineitem.parquet` ✅ (1.2GB)

## 🧪 测试执行步骤

### Step 1: 编译基准测试框架

```bash
cd /home/bochengh/ndb_fisrt_stage/llvm_jit

# 方法1: 使用Makefile
make benchmark_framework

# 方法2: 直接编译 (如果Makefile有问题)
gcc -o benchmark_framework benchmark_framework.c \
    -I../include -L/home/bochengh/.local/lib \
    -larrow -lparquet -ldl -lm -pthread
```

### Step 2: 验证单个测试用例

```bash
# 测试 scan_filter_q1 (O3优化，exec模式)
./benchmark_framework SF1 scan_filter_q1 exec

# 测试 scan_filter_q1 (O2优化，e2e模式)  
./benchmark_framework SF1 scan_filter_q1 e2e
```

### Step 3: 运行完整基准测试

```bash
# 运行所有6个用例 × 3个规模 × 2个模式 = 36个测试
./run_all_benchmarks.sh
```

## 📊 预期测试结果

### **测试矩阵** (6 × 3 × 2 = 36 组测试)

| 用例 | SF1 exec | SF1 e2e | SF3 exec | SF3 e2e | SF5 exec | SF5 e2e |
|------|----------|---------|----------|---------|----------|---------|
| scan_filter_q1 | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |
| scan_filter_q6 | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |
| agg_only_q1 | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |
| sort_only_shipdate | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |
| q6_full | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |
| q1_full | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ | ⏱️ |

### **性能指标说明**

- **exec 模式**: 纯执行时间 (使用 O3 优化)
- **e2e 模式**: 端到端时间 = JIT编译时间 + 执行时间 (使用 O2 优化)

### **预期性能范围**

| 用例类型 | SF1 预期时间 | SF3 预期时间 | SF5 预期时间 |
|---------|-------------|-------------|-------------|
| scan_filter | 50-200ms | 150-600ms | 250-1000ms |
| agg_only | 100-400ms | 300-1200ms | 500-2000ms |
| sort_only | 200-800ms | 600-2400ms | 1000-4000ms |
| full pipeline | 300-1200ms | 900-3600ms | 1500-6000ms |

## 🎯 关键优化验证点

1. **列选择优化效果**
   - Q1用例: 16列 → 7列 (56%减少)
   - Q6用例: 16列 → 4列 (75%减少)
   - Sort用例: 16列 → 1列 (93%减少)

2. **JIT优化级别效果**
   - exec模式: O3优化带来的性能提升
   - e2e模式: O2平衡编译时间与性能

3. **完全JIT化收益**
   - 所有组件都是JIT编译
   - 没有非JIT的C++运行时开销

## 🐛 故障排除

### 如果编译失败:
```bash
# 检查Arrow/Parquet库
ls /home/bochengh/.local/lib/libarrow*
ls /home/bochengh/.local/lib/libparquet*

# 检查头文件
ls ../include/ndb_*
```

### 如果运行时失败:
```bash
# 检查parquet文件
ls -la ../sf*_parquet/lineitem.parquet

# 检查IR文件
ls -la pipelines/*.ll
ls -la ../arrow-c/*.ll
```

### 调试单个组件:
```bash
# 测试单个IR编译
clang -shared -O3 -march=native -fPIC -o test.so \
    pipelines/scan_filter_q1_pipeline.ll common/filter_kernels.ll

# 测试动态库加载
ldd test.so
```

## 📈 结果分析

运行完成后，你将获得:

1. **性能对比数据**: exec vs e2e 模式
2. **可扩展性分析**: SF1 vs SF3 vs SF5
3. **JIT优化效果**: O2 vs O3 编译时间和性能权衡
4. **列选择优化收益**: I/O减少带来的性能提升

这将为你的TPC-H JIT实现提供全面的性能基线！
