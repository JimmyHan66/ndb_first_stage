# TPC-H JIT Benchmark Framework

## 🎯 概述

完全 JIT 化的 TPC-H 基准测试框架，测试 6 个算子组合在 3 个数据规模下的性能。

## 📋 测试用例

| 用例 | 功能 | 包含算子 |
|------|------|----------|
| `scan_filter_q1` | Q1 过滤测试 | Scan + Q1 Date Filter |
| `scan_filter_q6` | Q6 过滤测试 | Scan + Q6 Multi-level Filter |
| `agg_only_q1` | Q1 聚合测试 | Scan + Full Selection + Q1 Agg + Sort |
| `sort_only_shipdate` | 排序测试 | Scan + Extract + Global Sort |
| `q6_full` | Q6 完整流水线 | Scan + Q6 Filter + Q6 Agg |
| `q1_full` | Q1 完整流水线 | Scan + Q1 Filter + Q1 Agg + Sort |

## 📊 测试规模

- **SF1**: 约 600 万行
- **SF3**: 约 1800 万行
- **SF5**: 约 3000 万行

## ⏱️ 测量模式

### exec 模式 (纯执行时间)
- **前置准备** (不计时): Parquet→Arrow、JIT 编译
- **Warm-up**: 3 次预热运行
- **测量**: 2 次执行取最小值
- **计时范围**: 仅 JIT 函数执行时间

### e2e 模式 (端到端时间)
- **测量**: 2 次完整流程取最小值
- **计时范围**: JIT 编译 + 数据加载 + 执行
- **每轮重新**: 重新编译 JIT、重新加载数据

## 🚀 快速开始

### 1. 编译框架
```bash
cd llvm_jit
make all
```

### 2. 运行完整测试
```bash
make benchmark
```

### 3. 运行快速测试 (仅 SF1)
```bash
make quick-test
```

### 4. 运行单个测试
```bash
# 格式: make test-<scale>-<case>-<mode>
make test-sf1-scan_filter_q1-exec
make test-sf3-q6_full-e2e
make test-sf5-q1_full-exec
```

### 5. 验证所有用例
```bash
make validate
```

## 📈 结果输出

### CSV 格式输出
```csv
scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity,throughput_rows_per_sec
SF1,scan_filter_q1,exec,min,45.23,,23.1,6001215,0.023,132000000
SF1,scan_filter_q1,e2e,min,123.45,45.23,67.8,6001215,0.023,48600000
```

### 字段说明
- `scale`: 数据规模 (SF1/SF3/SF5)
- `case`: 测试用例名称
- `mode`: 测量模式 (exec/e2e)
- `run`: 运行标识 (min=最小值)
- `ms`: 主要计时 (exec=执行时间, e2e=端到端时间)
- `exec_once_ms`: 纯执行时间 (仅 e2e 模式有效)
- `compile_ms`: JIT 编译时间 (仅 e2e 模式有效)
- `rows_processed`: 处理的行数
- `selectivity`: 选择率 (过滤用例)
- `throughput_rows_per_sec`: 吞吐量 (行/秒)

## 🔧 架构特点

### 完全 JIT 化
- 所有 6 个用例都是独立的完整 JIT 流水线
- 包含完整的 scan 循环、数据转换、算子执行
- 无混合架构，最大化 JIT 性能优势

### 精确计时
- **exec 模式**: 排除编译和 I/O 开销，精确测量算子性能
- **e2e 模式**: 测量真实工作流的总成本
- 高精度时间测量 (毫秒级别)

### 组件化设计
```
scan_filter_q1 = filter_kernels.ll + scan_filter_q1_pipeline.ll
q1_full = filter_kernels.ll + q1_full_pipeline.ll + q1_incremental.ll + pdqsort.ll + avx2_double_simd_sum.ll
```

## 📁 文件结构

```
llvm_jit/
├── benchmark_framework.c          # 基准测试框架主程序
├── run_all_benchmarks.sh         # 批量测试脚本
├── Makefile                       # 构建系统
├── pipelines/                     # JIT 流水线实现
│   ├── scan_filter_q1_pipeline.c/.ll
│   ├── scan_filter_q6_pipeline.c/.ll
│   ├── agg_only_q1_pipeline.c/.ll
│   ├── sort_only_shipdate_pipeline.c/.ll
│   ├── q6_full_pipeline.c/.ll
│   ├── q1_full_pipeline.c/.ll
│   └── generate_all_ir.sh
├── common/
│   ├── filter_kernels.c/.ll      # 基础过滤内核
│   └── ndb_types.h               # 数据类型定义
└── 输出文件:
    ├── benchmark_results.csv      # 详细结果
    └── benchmark_report.txt       # 汇总报告
```

## 🐛 故障排除

### 编译问题
```bash
# 检查 Arrow 依赖
pkg-config --exists arrow && echo "Arrow OK"

# 检查数据文件
ls -la ../sf1_parquet/lineitem.parquet
ls -la ../sf3_parquet/lineitem.parquet
ls -la ../sf5_parquet/lineitem.parquet
```

### 运行问题
```bash
# 验证单个用例
make validate

# 检查 JIT 编译
make ir

# 清理重新构建
make clean-all && make all
```

### 性能问题
- 确保使用 `-O3 -march=native` 优化
- 检查 CPU 频率scaling 设置
- 确认单线程运行 (无并行干扰)

## 📞 使用示例

```bash
# 完整基准测试
make benchmark

# 查看结果
cat benchmark_report.txt
head -20 benchmark_results.csv

# 特定测试
./benchmark_framework SF1 q1_full exec
./benchmark_framework SF3 scan_filter_q6 e2e
```

基准测试框架现已准备就绪！🚀
