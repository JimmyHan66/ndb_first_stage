# NDB JIT Benchmark Framework 使用指南

本文档详细说明如何编译、运行和分析 NDB JIT 基准测试框架。

## 目录
1. [环境准备](#环境准备)
2. [编译 LLVM IR 文件](#编译-llvm-ir-文件)
3. [编译 benchmark_framework](#编译-benchmark_framework)
4. [运行测试](#运行测试)
5. [生成统计报告](#生成统计报告)
6. [文件结构说明](#文件结构说明)
7. [故障排除](#故障排除)

## 环境准备

### 系统要求
- **操作系统**: Linux (推荐 Ubuntu 18.04+)
- **编译器**: Clang 18+ (支持 LLVM IR 和 AVX2)
- **Python**: Python 3.6+ (用于统计脚本)
- **库依赖**: Arrow, Parquet, NDB scan runtime

### 环境变量设置
```bash
# 必须设置库路径
export LD_LIBRARY_PATH="/home/bochengh/ndb_fisrt_stage/build:/home/bochengh/.local/lib:$LD_LIBRARY_PATH"

# 确认 clang 版本
clang --version  # 应该是 clang 18+
```

## 编译 LLVM IR 文件

### 1. 编译基础组件 (arrow-c 目录)

```bash
cd /home/bochengh/ndb_fisrt_stage/arrow-c

# 编译 Q1 聚合组件
clang -S -emit-llvm -O2 -I../include -o q1_incremental_optimized.ll q1_incremental_optimized.c

# 编译 Q6 聚合组件
clang -S -emit-llvm -O2 -I../include -o q6_incremental_optimized.ll q6_incremental_optimized.c

# 编译 AVX2 SIMD 组件 (需要 -mavx2)
clang -S -emit-llvm -O2 -mavx2 -o avx2_double_simd_sum.ll avx2_double_simd_sum.c

# 编译排序组件
clang -S -emit-llvm -O2 -o pdqsort.ll pdqsort.c
```

### 2. 编译过滤内核 (llvm_jit/common 目录)

```bash
cd /home/bochengh/ndb_fisrt_stage/llvm_jit/common

# 编译过滤内核
clang -S -emit-llvm -O2 -I../../include -o filter_kernels.ll filter_kernels.c
```

### 3. 编译 JIT 流水线 (llvm_jit/pipelines 目录)

```bash
cd /home/bochengh/ndb_fisrt_stage/llvm_jit/pipelines

# 使用自动化脚本 (推荐)
./generate_all_ir.sh -O2

# 或者手动编译每个流水线:
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o scan_filter_q1_pipeline.ll scan_filter_q1_pipeline.c
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o scan_filter_q6_pipeline.ll scan_filter_q6_pipeline.c
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o agg_only_q1_pipeline.ll agg_only_q1_pipeline.c
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o sort_only_shipdate_pipeline.ll sort_only_shipdate_pipeline.c
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o q6_full_pipeline.ll q6_full_pipeline.c
clang -S -emit-llvm -O2 -I../common -I../../include -I../../arrow-c -o q1_full_pipeline.ll q1_full_pipeline.c
```

### 4. 验证 IR 文件生成

```bash
# 检查所有 .ll 文件是否生成
find /home/bochengh/ndb_fisrt_stage -name "*.ll" | wc -l
# 应该有 10 个 .ll 文件:
# - 4 个基础组件 (arrow-c/)
# - 1 个过滤内核 (llvm_jit/common/)
# - 6 个流水线 (llvm_jit/pipelines/)
```

## 编译 benchmark_framework

### 编译命令

```bash
cd /home/bochengh/ndb_fisrt_stage/llvm_jit

# 编译主测试框架
gcc -o benchmark_framework benchmark_framework.c \
    -I../include \
    -L../build -L/home/bochengh/.local/lib \
    -lndb_scan_filter -larrow -lparquet -ldl -lm -pthread
```

### 验证编译

```bash
# 检查可执行文件
ls -la benchmark_framework

# 测试基本功能
./benchmark_framework
# 应该显示用法说明
```

## 运行测试

### 1. 单个测试用例

```bash
# EXEC 模式 (只计时 JIT kernel 执行)
./benchmark_framework SF1 scan_filter_q1 exec

# E2E 模式 (端到端墙钟时间)
./benchmark_framework SF1 scan_filter_q1 e2e
```

### 2. 支持的测试用例

```bash
# 6 个测试用例:
scan_filter_q1      # Q1 扫描过滤
scan_filter_q6      # Q6 扫描过滤
agg_only_q1         # Q1 仅聚合
sort_only_shipdate  # 仅按日期排序
q6_full             # Q6 完整流水线
q1_full             # Q1 完整流水线

# 3 个数据规模:
SF1                 # 6M 行
SF3                 # 18M 行
SF5                 # 30M 行

# 2 种测试模式:
exec                # 只计时 JIT kernel
e2e                 # 端到端墙钟时间
```

### 3. 完整测试套件

```bash
# 运行所有测试 (排除耗时过长的 SF5 sort e2e)
./test_all_complete.sh

# 输出文件: complete_test_results_YYYYMMDD_HHMMSS.csv
```

### 4. 输出格式

```csv
scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity
SF1,scan_filter_q1,exec,min,30.346,,,6001215,1.0000
SF1,scan_filter_q1,e2e,min,1007.2,54.8,198.7,6001215,1.0000
```

**字段说明**：
- `scale`: 数据规模 (SF1/SF3/SF5)
- `case`: 测试用例名称
- `mode`: 测试模式 (exec/e2e)
- `run`: 运行标识 (min=取最小值)
- `ms`: 主要计时指标
- `exec_once_ms`: 纯执行时间 (仅 e2e 模式)
- `compile_ms`: JIT 编译时间 (仅 e2e 模式)
- `rows_processed`: 处理的行数
- `selectivity`: 选择率 (过滤后/总行数)

## 生成统计报告

### 1. 使用 Python 脚本生成汇总

```bash
# 基于 CSV 结果生成汇总统计
python3 generate_summary.py complete_test_results_YYYYMMDD_HHMMSS.csv

# 生成两个文件:
# - summary_min.csv     (汇总性能指标)
# - summary_report.txt  (详细性能报告)
```

### 2. 汇总文件说明

**summary_min.csv** - 按 (scale, case, mode) 聚合的最小值:
```csv
scale,case,mode,warmups,repeats,min_ms,throughput_rows_per_sec
SF1,scan_filter_q1,exec,3,2,30.346,197760000
```

**summary_report.txt** - 详细性能分析报告:
- 环境配置信息
- 测试模式定义
- 按规模分组的性能表格
- 性能亮点和统计信息

### 3. 性能分析要点

```bash
# 查看吞吐量对比
grep "throughput" summary_min.csv | sort -k6 -n

# 查看扩展性 (相同用例不同规模)
grep "scan_filter_q1,exec" complete_test_results_*.csv

# 查看模式对比 (exec vs e2e)
grep "SF1,scan_filter_q1" complete_test_results_*.csv
```

## 文件结构说明

```
llvm_jit/
├── benchmark_framework.c           # 主测试框架
├── benchmark_framework             # 编译后的可执行文件
├── test_all_complete.sh           # 完整测试套件脚本
├── generate_summary.py            # 统计分析脚本
├── common/
│   ├── ndb_types.h                # JIT 类型定义
│   ├── filter_kernels.c           # 过滤内核源码
│   └── filter_kernels.ll          # 过滤内核 IR
├── pipelines/
│   ├── generate_all_ir.sh         # IR 批量生成脚本
│   ├── *_pipeline.c               # 6 个流水线源码
│   └── *_pipeline.ll              # 6 个流水线 IR
├── complete_test_results_*.csv    # 测试结果数据
├── summary_min.csv               # 汇总性能指标
└── summary_report.txt            # 详细性能报告

../arrow-c/
├── q1_incremental_optimized.c/.ll # Q1 聚合组件
├── q6_incremental_optimized.c/.ll # Q6 聚合组件
├── avx2_double_simd_sum.c/.ll     # AVX2 SIMD 组件
└── pdqsort.c/.ll                  # 排序组件
```

## 故障排除

### 1. 编译错误

**问题**: `clang: command not found`
```bash
# 安装 clang 18
sudo apt install clang-18
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100
```

**问题**: `arrow/c/abi.h: No such file or directory`
```bash
# 检查 Arrow 安装
find /usr -name "abi.h" 2>/dev/null | grep arrow
# 或检查本地安装
ls ../arrow-c/abi.h
```

**问题**: AVX2 指令错误
```bash
# 确保使用 -mavx2 标志
clang -S -emit-llvm -O2 -mavx2 -o avx2_double_simd_sum.ll avx2_double_simd_sum.c
```

### 2. 运行时错误

**问题**: `libndb_scan_filter.so: cannot open shared object file`
```bash
# 设置正确的库路径
export LD_LIBRARY_PATH="/home/bochengh/ndb_fisrt_stage/build:/home/bochengh/.local/lib:$LD_LIBRARY_PATH"

# 验证库存在
ls -la /home/bochengh/ndb_fisrt_stage/build/libndb_scan_filter.so
```

**问题**: `JIT function not found`
```bash
# 检查 .ll 文件是否正确生成
ls -la pipelines/*.ll

# 重新生成 IR 文件
cd pipelines && ./generate_all_ir.sh -O2
```

### 3. 性能异常

**问题**: 所有规模执行时间相同
- 确保使用修复后的 `benchmark_framework.c`
- 检查是否传递了正确的 `scale` 参数

**问题**: SF5 测试超时
- 这是正常的，特别是 `sort_only_shipdate` 用例
- 测试脚本会自动跳过超时的测试

### 4. 数据验证

```bash
# 验证数据规模正确性
grep "rows_processed" complete_test_results_*.csv | head -10

# SF1 应该是 ~6M 行
# SF3 应该是 ~18M 行
# SF5 应该是 ~30M 行
```

## 性能基准参考

### 典型性能数据 (单线程, Clang -O3)

| Case | Scale | Exec (ms) | Throughput (M rows/s) |
|------|-------|-----------|----------------------|
| scan_filter_q1 | SF1 | 30.3 | 197.8 |
| scan_filter_q1 | SF3 | 91.8 | 196.0 |
| scan_filter_q1 | SF5 | 123.3 | 243.3 |
| scan_filter_q6 | SF1 | 43.9 | 1.29 |
| agg_only_q1 | SF1 | 314.5 | 19.1 |
| sort_only_shipdate | SF1 | 1668.2 | 3.6 |

### 扩展性指标

- **扫描过滤**: 线性扩展，吞吐量稳定在 ~200M rows/s
- **聚合**: 线性扩展，吞吐量稳定在 ~20M rows/s
- **排序**: 超线性增长 (O(n log n))，大规模数据性能下降明显

---

## 总结

本框架实现了完全 JIT 化的 TPC-H 查询基准测试，支持：

✅ **6 个测试用例** - 涵盖扫描、过滤、聚合、排序操作
✅ **3 个数据规模** - SF1/SF3/SF5 验证扩展性
✅ **2 种测试模式** - exec (纯 JIT) 和 e2e (完整流水线)
✅ **精确计时边界** - 严格按照 test_design.md 规范
✅ **自动化测试** - 一键运行所有测试组合
✅ **详细统计分析** - CSV 数据 + 汇总报告

使用本框架可以准确评估 JIT 编译器在不同工作负载下的性能表现。
