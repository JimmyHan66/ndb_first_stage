**口径**：对每个用例，分别统计 exec（仅执行） 与 e2e（端到端墙钟） 两种口径。

**数据**：TPC-H SF=1/3/5，**按需选择列**以精确测试：

- **Q1 相关列（7 列）**：`l_returnflag`, `l_linestatus`, `l_quantity`, `l_extendedprice`, `l_discount`, `l_tax`, `l_shipdate`
- **Q6 相关列（4 列）**：`l_shipdate`, `l_discount`, `l_quantity`, `l_extendedprice`
- **原则**：避免无关列的 I/O 和内存开销，精确测试算子性能

**项目架构**：基于现有 NDB 项目，包含：

- 自研批处理驱动和过滤内核 以及 Agg和sort在arrow-c里
- 高性能聚合回调系统

## 2. 测试用例集合（每个规模都要测）

### 2.1 算子分解测试

- **scan_filter_q6**：按 TPC-H Q6 谓词过滤，`SELECT *`

  - l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01'
  - l_discount BETWEEN 0.05 AND 0.07
  - l_quantity < 24

- **scan_filter_q1**：按 TPC-H Q1 日期谓词过滤，`SELECT *`

  - l_shipdate <= '1998-12-01'

- **agg_only_q1**：Q1 的 GROUP BY (l_returnflag, l_linestatus) + 聚合（不带 ORDER BY）

  - sum(l_quantity), sum(l_extendedprice), sum(l_discount), etc.

- **sort_only_shipdate**：`SELECT l_shipdate FROM lineitem ORDER BY l_shipdate`（无 LIMIT）

### 2.2 整条查询测试

- **q6_full**：完整 TPC-H Q6 查询（扫描+过滤+聚合）
- **q1_full**：完整 TPC-H Q1 查询（扫描+过滤+聚合+排序）

**重要**：Q6/Q1 谓词常量作为函数参数传入（不要强制重新生成 IR），确保可复用 JIT 产物。

## 3. 两种统计口径（定义要"钉死"）

### 3.1 exec（仅执行）模式

**目的**：只衡量算子执行能力，排除读取与转换、以及首次 JIT 编译的影响。

**前置条件（不计时）**：
1. **Parquet → Arrow**：使用现有 `rt_scan_open_parquet()` 读取所需列
2. **Arrow → NDB in-memory**：通过 `ArrowBatch` 和 `ArrowColumnView` 完成列落地
3. **JIT 已完成**：.ll 文件编译为动态库，函数指针已获取

**计时流程**：

- **Warm-up（预热）**：在相同数据与 JIT 函数上运行 3 次（不计时），稳定 CPU cache/分支预测
- **Repeat（统计）**：连续执行 2 次，每次只计 JIT kernel 调用的执行时间（start→end），取最小值作为结果报告

**exec 计入什么？**

- ✅ 你的算子执行时间（`ndb_q1_batch_driver`, `ndb_q6_batch_driver` 等）
- ✅ JIT 生成后的调用开销（函数指针调用本身）
- ❌ **不计** Parquet→Arrow、Arrow→in-mem、JIT 编译阶段、任何 warm-up

### 3.2 e2e（端到端墙钟）模式

**目的**：衡量真实工作流的总成本（加载 + 转换 + JIT + 首次执行）。

**计时流程（不预热）**：
对同一用例重复 2 轮，每轮都从零开始，取最小值作为结果：

1. **t0 记时**
2. **Parquet → Arrow**：`rt_scan_open_parquet()` 读取
3. **Arrow → NDB in-memory**：`ArrowBatch` 转换
4. **JIT 编译**：加载 .ll 文件并编译为动态库（每轮都重新 JIT：`--jit=every`）
5. **执行 1 次**算子/查询（不做 warm-up），同时记录纯执行时间 `exec_once_ms`
6. **t1 停止**：`e2e_wallclock_ms = (t1 - t0)`
7. **记录该轮**：`e2e_wallclock_ms`（主指标），外加 `exec_once_ms` 与 `compile_ms`（用于拆解）
8. **最终结果**：取 2 轮中的最小值作为报告结果

**e2e 计入什么？**

- ✅ Parquet 解码（→ Arrow）
- ✅ Arrow → NDB in-memory 转换
- ✅ JIT 编译（IR/opt/codegen）
- ✅ 一次执行（不预热）
- ❌ **不计**额外 warm-up（本口径不做预热）

## 4. 输出与统计

### 4.1 数据输出格式

**单条运行明细**（CSV 格式）：

```csv
scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity
SF1,scan_filter_q6,exec,1,45.23,,23.1,6001215,0.023
SF1,scan_filter_q6,e2e,1,123.45,45.23,67.8,6001215,0.023
```

**字段说明**：

- `scale`：数据规模（SF1/SF3/SF5）
- `case`：测试用例名称
- `mode`：测量模式（exec/e2e）
- `run`：运行标识（min=2 次运行的最小值）
- `ms`：本次口径的计时（exec=执行时间；e2e=端到端墙钟）
- `exec_once_ms`：纯执行时间（仅在 e2e 模式有效）
- `compile_ms`：JIT 编译时间（仅在 e2e 模式有效）
- `rows_processed`：处理的行数
- `selectivity`：选择率（过滤后行数/总行数）

### 4.2 汇总统计

**summary_min.csv**：按 (scale, case, mode) 聚合输出最小值结果

```csv
scale,case,mode,warmups,repeats,min_ms,throughput_rows_per_sec
SF1,scan_filter_q6,exec,3,2,45.23,132000000
```

**summary_report.txt**：

- 环境配置：单线程、内存预算、批大小、绑核情况
- exec/e2e 的定义（包含/不包含项）
- 每个规模 × 用例 × 口径的性能表格

## 5. 详细技术实现指南

### 5.1 项目架构解析

**核心组件**：

```
ndb_fisrt_stage/
├── include/                    # 头文件
│   ├── ndb_scan_runtime.h     # 扫描运行时 API
│   ├── ndb_batch_driver.h     # 批处理驱动
│   ├── ndb_agg_callback.h     # 聚合回调接口
│   └── ndb_agg_state.h        # 聚合状态管理
├── src/                       # 核心实现
│   ├── ndb_batch_driver_arrow.c    # Q1/Q6 批处理驱动
│   ├── ndb_filter_kernels_arrow.c  # 过滤内核
│   └── ndb_agg_callback_factory.c  # 聚合回调工厂
├── llvm_jit/                  # JIT 编译
│   ├── common/filter_kernels.c     # 过滤内核 C 源码
│   ├── q1/q1_batch_driver.c        # Q1 filter的JIT 版本
│   └── q6/q6_batch_driver.c        # Q6 filter的 JIT 版本
└── tests/                     # 集成测试
    ├── test_q1_agg_integration.c
    └── test_q6_agg_integration.c
```

### 5.2 LLVM IR 生成流程

**现有 JIT 架构分析**：

- **JIT 部分**：仅限于**纯过滤操作**（`llvm_jit/`）
  - `filter_kernels.c`：基础过滤内核
  - `q1_batch_driver.c`：Q1 过滤驱动（单条件：`l_shipdate <= '1998-12-01'`）
  - `q6_batch_driver.c`：Q6 过滤驱动（多条件链式过滤）
- **需要编成JIT的部分**：**聚合与排序**（`arrow-c/`）
  - `q1_incremental.c`：Q1 哈希聚合 + AVX2 向量化 + 排序
  - `q6_incremental.c`：Q6 简单求和聚合
  - `avx2_double_simd_sum.c`：SIMD 优化的浮点求和

**步骤 1：理解 JIT 过滤内核**
现有过滤内核位于 `llvm_jit/common/filter_kernels.c`：

```c
// 基础过滤：Date32 <=
int32_t filter_le_date32(const SimpleColumnView *col, int32_t threshold, uint32_t *output_idx);

// 链式过滤：在选择向量基础上继续过滤
int32_t filter_lt_date32_on_sel(const uint32_t *input_sel, int32_t input_count,
                                const SimpleColumnView *col, int32_t threshold, uint32_t *output_idx);

// Q6 专用过滤器
int32_t filter_between_i64_on_sel(...);  // BETWEEN 过滤
int32_t filter_lt_i64_on_sel(...);       // 数值 < 过滤
```

**步骤 2：生成 LLVM IR**
使用项目提供的脚本：

```bash
cd llvm_jit/q1
./generate_ir.sh   # 生成 Q1 相关 IR

cd ../q6
./generate_ir.sh   # 生成 Q6 相关 IR
```

实际执行的命令：

```bash
# 编译过滤内核到 LLVM IR
/usr/bin/clang -S -emit-llvm -O3 -o filter_kernels.ll filter_kernels.c

# 编译批处理驱动到 LLVM IR
/usr/bin/clang -S -emit-llvm -O3 -I../common -o q1_batch_driver.ll q1_batch_driver.c
```
为保证 6 个测试用例均可在 JIT 下运行，需要为以下目标生成 `.ll` 并在链接时组合：
- **agg_only_q1**：新增 `llvm_jit/common/selvec_kernels.c`（生成全选 selvec 等原语）→ `selvec_kernels.ll`；与 `arrow-c/q1_incremental.ll`、`arrow-c/avx2_double_simd_sum.ll` 链接
- **sort_only_shipdate**：新增排序驱动 `llvm_jit/sort/sort_shipdate_driver.c` → `sort_shipdate_driver.ll`
- **q6_full**：新增全流程驱动 `llvm_jit/full/q6_full_driver.c` → `q6_full_driver.ll`，与 `common/filter_kernels.ll`、`q6/q6_batch_driver.ll`、`arrow-c/q6_incremental.ll`、`arrow-c/avx2_double_simd_sum.ll` 链接
- **q1_full**：新增全流程驱动 `llvm_jit/full/q1_full_driver.c` → `q1_full_driver.ll`，与 `common/filter_kernels.ll`、`q1/q1_batch_driver.ll`、`arrow-c/q1_incremental.ll`、`arrow-c/avx2_double_simd_sum.ll` 链接

说明：`scan_filter_q6`、`scan_filter_q1` 已有 `.ll`（过滤-only），其余 4 个需按上面新增生成。

**步骤 3：JIT 编译与加载**
在测试代码中动态编译和加载：

```c
// 编译 JIT 代码（参考 tpch_jit_test.c）
char cmd[1024];
snprintf(cmd, sizeof(cmd),
    "/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/test_jit.so "
    "common/filter_kernels.ll q1/q1_batch_driver.ll");
system(cmd);

// 加载动态库
void *jit_lib = dlopen("/tmp/test_jit.so", RTLD_LAZY);
FilterFunc filter_func = (FilterFunc)dlsym(jit_lib, "filter_le_date32");
```

#### 5.2.1 按用例的 .ll 组合与链接命令

- scan_filter_q1（过滤-only）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/scan_filter_q1.so \
  llvm_jit/common/filter_kernels.ll \
  llvm_jit/q1/q1_batch_driver.ll
```

- scan_filter_q6（过滤-only）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/scan_filter_q6.so \
  llvm_jit/common/filter_kernels.ll \
  llvm_jit/q6/q6_batch_driver.ll
```

- agg_only_q1（聚合-only）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/agg_only_q1.so \
  arrow-c/q1_incremental.ll \
  arrow-c/avx2_double_simd_sum.ll \
  arrow-c/pdqsort.ll \
  llvm_jit/common/selvec_kernels.ll
```

- sort_only_shipdate（排序-only）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/sort_only_shipdate.so \
  arrow-c/pdqsort.ll \
  llvm_jit/sort/sort_shipdate_driver.ll
```

- q6_full（过滤+聚合）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/q6_full.so \
  llvm_jit/common/filter_kernels.ll \
  llvm_jit/q6/q6_batch_driver.ll \
  arrow-c/q6_incremental.ll \
  arrow-c/avx2_double_simd_sum.ll \
  llvm_jit/full/q6_full_driver.ll
```

- q1_full（过滤+聚合+排序）：
```bash
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/q1_full.so \
  llvm_jit/common/filter_kernels.ll \
  llvm_jit/q1/q1_batch_driver.ll \
  arrow-c/q1_incremental.ll \
  arrow-c/avx2_double_simd_sum.ll \
  arrow-c/pdqsort.ll \
  llvm_jit/full/q1_full_driver.ll
```

### 5.3 性能测量实现

**高精度时间测量**（基于现有 `performance_benchmark.c`）：

```c
#include <sys/time.h>

double get_time_seconds() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000.0;
}
```

**exec 模式实现**（统一到 6 个用例）：

```c
// 前置准备（不计时）
ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);

// JIT 编译和加载（不计时）
system("/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/scan_filter_q1.so "
       "llvm_jit/common/filter_kernels.ll llvm_jit/q1/q1_batch_driver.ll");
void *jit_lib = dlopen("/tmp/scan_filter_q1.so", RTLD_LAZY);
typedef int32_t (*Q1BatchDriverFunc)(const SimpleBatch*, uint32_t*);
Q1BatchDriverFunc jit_q1_driver = (Q1BatchDriverFunc)dlsym(jit_lib, "q1_batch_driver_jit");

// 聚合状态（不计时）
Q1AggregationState *agg_state = q1_agg_init();  // 来自 arrow-c/q1_incremental.c

// Warm-up（3次，不计时）
for (int i = 0; i < 3; i++) {
    ArrowBatch batch;
    while (rt_scan_next(scan_handle, &batch) > 0) {
        uint32_t selected_indices[batch.num_rows];
        SimpleBatch simple = convert_arrow_to_simple(&batch);
        int32_t selected_count = jit_q1_driver(&simple, selected_indices);  // JIT 过滤
        q1_agg_process_batch(agg_state, &batch.arrow_array, selected_indices, selected_count);
        ndb_arrow_batch_cleanup(&batch);
    }
    reset_states_for_next_run();
}

// 正式测量（2次）- JIT过滤 + 非JIT聚合流水线
double times[2];
for (int run = 0; run < 2; run++) {
    double start = get_time_seconds();

    // === 仅此部分计时：热路径执行 ===
    ArrowBatch batch;
    while (rt_scan_next(scan_handle, &batch) > 0) {
        uint32_t selected_indices[batch.num_rows];
        SimpleBatch simple = convert_arrow_to_simple(&batch);
        int32_t selected_count = jit_q1_driver(&simple, selected_indices);
        q1_agg_process_batch(agg_state, &batch.arrow_array, selected_indices, selected_count);
        ndb_arrow_batch_cleanup(&batch);
    }
    // === 计时结束 ===

    double end = get_time_seconds();
    times[run] = (end - start) * 1000.0;
    reset_states_for_next_run();
}

// 取最小值作为结果报告
double min_time = times[0] < times[1] ? times[0] : times[1];
printf("Exec mode result: %.3f ms (minimum of 2 runs)\n", min_time);
```

**e2e 模式实现**（统一到 6 个用例）：

```c
double e2e_times[2];
double exec_times[2];
double compile_times[2];

for (int run = 0; run < 2; run++) {
    double t0 = get_time_seconds();

    // 1. Parquet → Arrow
    ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);

    // 2. Arrow → NDB (通过批处理驱动隐式完成)

    // 3. JIT 编译
    double compile_start = get_time_seconds();
    compile_and_load_jit();
    double compile_end = get_time_seconds();

    // 4. 执行一次（根据用例选择入口，例如 q1_full_driver_jit/scan_filter_q1 等）
    double exec_start = get_time_seconds();
    invoke_selected_case_entrypoint(scan_handle);
    double exec_end = get_time_seconds();

    double t1 = get_time_seconds();

    // 记录本轮结果
    e2e_times[run] = (t1-t0)*1000.0;
    exec_times[run] = (exec_end-exec_start)*1000.0;
    compile_times[run] = (compile_end-compile_start)*1000.0;
}

// 取最小值作为结果报告
double min_e2e = e2e_times[0] < e2e_times[1] ? e2e_times[0] : e2e_times[1];
double min_exec = exec_times[0] < exec_times[1] ? exec_times[0] : exec_times[1];
double min_compile = compile_times[0] < compile_times[1] ? compile_times[0] : compile_times[1];

printf("SF%d,%s,e2e,min,%.3f,%.3f,%.3f\n",
       scale, case_name, min_e2e, min_exec, min_compile);
```

6 个用例的入口差异：
- scan_filter_q1 / scan_filter_q6：仅加载并调用对应 JIT 过滤入口（不做聚合）
- agg_only_q1：不做过滤，使用 `selvec_kernels` 生成全选 selvec，然后 `q1_agg_process_batch()`/`q1_agg_finalize()`
- sort_only_shipdate：仅调用 `sort_shipdate_driver_jit()`，不输出排序结果（只计时）
- q6_full / q1_full：加载 full 驱动入口，内部串联过滤与聚合（及排序）

### 5.4 测试用例具体实现

**Q1 过滤测试**（scan_filter_q1）：

```c
// 基于现有 test_q1_agg_integration.c 修改
int32_t test_scan_filter_q1(const char *scale, const char *mode) {
    TableScanDesc scan_desc = {
        .file_paths = {"../sf1/lineitem.parquet"},  // 根据 scale 调整
        .needed_cols = q1_columns,
        .num_cols = 16,
        .batch_size = 2048
    };

    if (strcmp(mode, "exec") == 0) {
        return run_exec_benchmark(&scan_desc, ndb_q1_batch_driver);
    } else {
        return run_e2e_benchmark(&scan_desc, ndb_q1_batch_driver);
    }
}
```

**Q6 过滤测试**（scan_filter_q6）：

```c
// 基于现有 test_q6_agg_integration.c 修改
int32_t test_scan_filter_q6(const char *scale, const char *mode) {
    // 类似 Q1，但使用 ndb_q6_batch_driver
    return run_benchmark(&scan_desc, ndb_q6_batch_driver, mode);
}
```

### 5.5 环境配置

**目标环境**：x86 Linux 服务器

**编译设置**：

- 单线程：确保所有测试都在单线程环境下运行
- 批大小固定：2048（所有用例一致）
- 优化级别：-O3 -march=native（针对 x86 架构优化）
- 动态库格式：.so（Linux 标准格式，非 macOS 的.dylib）
- 内存预算：~80 GB，避免溢写

**常量参数化**：

```c
// Q6 谓词常量
const int32_t Q6_SHIPDATE_GE = 8766;   // 1994-01-01
const int32_t Q6_SHIPDATE_LT = 9131;   // 1995-01-01
const int64_t Q6_DISCOUNT_LOW = 5;     // 0.05 * 100
const int64_t Q6_DISCOUNT_HIGH = 7;    // 0.07 * 100
const int64_t Q6_QUANTITY_LT = 2400;   // 24 * 100

// Q1 谓词常量
const int32_t Q1_SHIPDATE_LE = 10561;  // 1998-12-01
```

## 6. 最终交付物

### 6.1 输出文件

- **results.csv**：详细的运行数据（2 次测试的最小值）
- **summary_min.csv**：聚合的最小值结果
- **summary_report.txt**：测试环境和结果报告

### 6.2 构建与运行

```bash
# 构建项目
mkdir build && cd build
cmake ..
make

# 生成测试数据
python3 ../generate_real_tpch_data.py

# 生成/更新 IR（过滤 + 新增 full/agg/sort 目标）
(cd ../llvm_jit/q1 && ./generate_ir.sh)
(cd ../llvm_jit/q6 && ./generate_ir.sh)

# 为 arrow-c 产出 .ll（可新增脚本 arrow-c/generate_ir.sh）
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../arrow-c/q1_incremental.ll ../arrow-c/q1_incremental.c
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../arrow-c/q6_incremental.ll ../arrow-c/q6_incremental.c
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../arrow-c/avx2_double_simd_sum.ll ../arrow-c/avx2_double_simd_sum.c

# 生成新增 JIT 驱动的 .ll（需新增对应 .c 源后执行）
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../llvm_jit/common/selvec_kernels.ll ../llvm_jit/common/selvec_kernels.c
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../llvm_jit/sort/sort_shipdate_driver.ll ../llvm_jit/sort/sort_shipdate_driver.c
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../llvm_jit/full/q1_full_driver.ll ../llvm_jit/full/q1_full_driver.c
/usr/bin/clang -S -emit-llvm -O3 -I../include -o ../llvm_jit/full/q6_full_driver.ll ../llvm_jit/full/q6_full_driver.c

# 链接 6 个 .so（示例：scan_filter_q6）
/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/scan_filter_q6.so \
  ../llvm_jit/common/filter_kernels.ll \
  ../llvm_jit/q6/q6_batch_driver.ll

# 运行基准测试（六用例 × 三规模 × 两口径）
./benchmark_tpch_jit --scale=SF1,SF3,SF5 \
  --cases=scan_filter_q6,scan_filter_q1,agg_only_q1,sort_only_shipdate,q6_full,q1_full \
  --mode=both --output=results.csv
```

## 7. 基于 llvm_jit 学习的全新测试思路

### 7.1 llvm_jit 代码分析与问题识别

通过分析 `llvm_jit/` 代码，发现**现有实现的关键问题**：

#### 7.1.1 数据结构不匹配问题

```c
// llvm_jit/common/ndb_types.h - 简化结构
typedef struct {
  const int32_t *values;   // 只支持int32_t
  const uint8_t *validity;
  int64_t length;
  int32_t arrow_type_id;
} SimpleColumnView;

// 问题：与真实Arrow结构gap巨大
// - 缺乏对Decimal128的支持
// - 硬编码int32_t，不支持多种数据类型
// - 缺乏与ArrowBatch的转换逻辑
```

#### 7.1.2 硬编码列索引问题

```c
// llvm_jit/q1/q1_batch_driver.c - 硬编码列位置
const SimpleColumnView *shipdate_col = &batch->columns[10];  // 假设第10列！

// 问题：
// - 假设shipdate是第10列，在仅选择7列时会崩溃
// - 缺乏列名到索引的映射
// - 不支持动态列选择
```

#### 7.1.3 JIT 编译流程不完整

```c
// llvm_jit/tpch_jit_test.c - 编译命令
snprintf(cmd, sizeof(cmd),
          "/usr/bin/clang -shared -O3 -march=native -fPIC -o /tmp/test_jit.so "
  "common/filter_kernels.ll %s/%s_batch_driver.ll");

// 问题：
// - 每次都重新编译，无缓存机制
// - 临时文件管理混乱
// - 缺乏编译错误处理
```

### 7.2 从 llvm_jit 学到的核心思路

#### 7.2.1 **分层设计思路**

- **第 1 层：基础过滤内核**（`filter_kernels.c`）- 可复用的原子操作
- **第 2 层：查询特定驱动**（`q1_batch_driver.c`）- 组合原子操作
- **第 3 层：JIT 编译管理** - 动态编译和加载

#### 7.2.2 **参数化过滤思路**

```c
// 学习：谓词常量参数化
const int32_t shipdate_threshold = 10561;  // Q1: '1998-12-01'
const int32_t shipdate_ge_threshold = 8766; // Q6: '1994-01-01'
const int32_t shipdate_lt_threshold = 9131; // Q6: '1995-01-01'

// 思路：避免为不同常量重新生成IR
```

#### 7.2.3 **链式过滤思路**

```c
// Q6的4级链式过滤模式
int32_t count1 = filter_ge_date32(shipdate_col, ge_threshold, temp_buffer1);
int32_t count2 = filter_lt_date32_on_sel(temp_buffer1, count1, shipdate_col, lt_threshold, temp_buffer2);
int32_t count3 = filter_between_i64_on_sel(temp_buffer2, count2, discount_col, low, high, temp_buffer3);
int32_t count4 = filter_lt_i64_on_sel(temp_buffer3, count3, quantity_col, threshold, final_output);
```

### 7.3 全新测试方案设计

基于 llvm_jit 学习，提出**重新设计**的测试方案：

#### 7.3.1 修复数据结构 gap 的策略

**问题**：现有`SimpleBatch`与`ArrowBatch`不兼容
**解决方案**：构建适配层

```c
// 新增：ArrowBatch → SimpleBatch 适配器
typedef struct {
    SimpleColumnView columns[16];  // 最多16列
    int32_t num_cols;
    int64_t num_rows;
    int32_t col_mapping[16];       // 列名到索引映射
} AdaptedBatch;

// 关键函数：支持多种数据类型
int32_t adapt_arrow_column_to_simple(const ArrowColumnView *arrow_col,
                                     SimpleColumnView *simple_col) {
    switch (arrow_col->arrow_type_id) {
        case ARROW_TYPE_DATE32:
            simple_col->values = (const int32_t*)arrow_col->buffers[1];
            break;
        case ARROW_TYPE_DECIMAL128:
            // 转换Decimal128为scaled int64
            simple_col->values = convert_decimal128_to_scaled_int64(arrow_col);
            break;
        default:
            return -1;
    }
    return 0;
}
```

#### 7.3.2 解决列索引硬编码问题

**问题**：`&batch->columns[10]` 硬编码
**解决方案**：动态列映射

```c
// 构建列映射表（基于实际读取的列）
typedef struct {
    const char *col_names[16];
    int32_t col_indices[16];
    int32_t num_cols;
} ColumnMapping;

// Q1测试：仅读取7列
ColumnMapping q1_mapping = {
    .col_names = {"l_returnflag", "l_linestatus", "l_quantity", "l_extendedprice",
                  "l_discount", "l_tax", "l_shipdate"},
    .col_indices = {0, 1, 2, 3, 4, 5, 6},  // 真实索引
    .num_cols = 7
};

// 动态获取列索引
int32_t get_column_index(const ColumnMapping *mapping, const char *col_name) {
    for (int i = 0; i < mapping->num_cols; i++) {
        if (strcmp(mapping->col_names[i], col_name) == 0) {
            return mapping->col_indices[i];
        }
    }
    return -1;
}

// 说明：实际现状使用 q1_batch_driver_jit(SimpleBatch*, uint32_t*)，
// 通过适配器把列映射到 JIT 期望的槽位（如 l_shipdate → index=10），
// 因此不需要该示例函数在现阶段存在于 .ll 中。
```

#### 7.3.3 优化 JIT 编译管理

**学习 llvm_jit 思路，但改进缺陷**：

```c
typedef struct {
    char jit_lib_path[256];
    void *jit_handle;
    bool is_compiled;
    uint64_t code_hash;  // 用于缓存判断
} JITManager;

// 改进的JIT编译
int32_t compile_query_jit(JITManager *mgr, const char *query_type) {
    // 1. 检查缓存
    uint64_t new_hash = compute_code_hash(query_type);
    if (mgr->is_compiled && mgr->code_hash == new_hash) {
        return 0;  // 复用已编译版本
    }

    // 2. 生成唯一文件名（避免冲突）
    snprintf(mgr->jit_lib_path, sizeof(mgr->jit_lib_path),
             "/tmp/ndb_jit_%s_%lu.so", query_type, new_hash);

    // 3. 编译命令（使用更精确的路径）
    char cmd[1024];
    snprintf(cmd, sizeof(cmd),
        "/usr/bin/clang -shared -O3 -march=native -fPIC "
        "-o %s llvm_jit/common/filter_kernels.ll llvm_jit/%s/%s_batch_driver.ll",
        mgr->jit_lib_path, query_type, query_type);

    int result = system(cmd);
    if (result != 0) {
        printf("❌ JIT compilation failed for %s\n", query_type);
        return -1;
    }

    // 4. 加载动态库
    mgr->jit_handle = dlopen(mgr->jit_lib_path, RTLD_LAZY);
    if (!mgr->jit_handle) {
        printf("❌ Failed to load JIT library: %s\n", dlerror());
        return -1;
    }

    mgr->is_compiled = true;
    mgr->code_hash = new_hash;
    return 0;
}
```

### 7.4 基于学习的精确测试用例

#### 7.4.1 scan_filter_q1（纯 JIT 过滤测试）

```c
// 仅测试 JIT 过滤性能，基于改进的架构
int32_t benchmark_scan_filter_q1_improved(const char *scale, const char *mode) {
    // 1. 精确列选择（仅Q1需要的7列）
    const char *q1_columns[] = {
        "l_returnflag", "l_linestatus", "l_quantity", "l_extendedprice",
        "l_discount", "l_tax", "l_shipdate"
    };

    TableScanDesc scan_desc = {
        .file_paths = {get_file_path(scale)},  // SF1/SF3/SF5
        .num_files = 1,
        .needed_cols = q1_columns,
        .num_cols = 7,  // 仅7列，避免无关I/O
        .batch_size = 2048
    };

    // 2. 构建列映射（解决硬编码问题）
    ColumnMapping q1_mapping = {
        .col_names = {"l_returnflag", "l_linestatus", "l_quantity", "l_extendedprice",
                      "l_discount", "l_tax", "l_shipdate"},
        .col_indices = {0, 1, 2, 3, 4, 5, 6},
        .num_cols = 7
    };

    // 3. JIT编译管理（改进缓存）
    JITManager jit_mgr = {0};
    if (compile_query_jit(&jit_mgr, "q1") != 0) {
        return -1;
    }

    // 4. 获取JIT函数指针
    typedef int32_t (*Q1FilterJIT)(const AdaptedBatch *batch,
                                   const ColumnMapping *mapping, uint32_t *output);
    Q1BatchDriverFunc jit_filter = (Q1BatchDriverFunc)dlsym(jit_mgr.jit_handle, "q1_batch_driver_jit");

    // 5. 扫描句柄
    ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);

    // === exec模式：仅计时过滤执行 ===
    if (strcmp(mode, "exec") == 0) {
        // Warm-up
        for (int i = 0; i < 3; i++) {
            run_filter_pipeline(scan_handle, jit_filter, &q1_mapping);
            reset_scan_position(scan_handle);
        }

        // 正式测量（2次取最小值）
        double times[2];
        for (int run = 0; run < 2; run++) {
            double start = get_time_seconds();

            // === 仅计时JIT过滤热路径 ===
            ArrowBatch arrow_batch;
            int64_t total_filtered = 0;
            while (rt_scan_next(scan_handle, &arrow_batch) > 0) {
                // 数据适配（ArrowBatch → AdaptedBatch）
                AdaptedBatch adapted_batch;
                adapt_arrow_batch(&arrow_batch, &adapted_batch, &q1_mapping);

                // JIT过滤（核心计时部分）
                uint32_t filter_output[adapted_batch.num_rows];
                int32_t filtered_count = jit_filter(&adapted_batch, &q1_mapping, filter_output);

                total_filtered += filtered_count;
                ndb_arrow_batch_cleanup(&arrow_batch);
            }
            // === JIT过滤计时结束 ===

            double end = get_time_seconds();
            times[run] = (end - start) * 1000.0;

            reset_scan_position(scan_handle);
        }

        // 取最小值作为结果报告
        double min_time = times[0] < times[1] ? times[0] : times[1];
        printf("SF%s,scan_filter_q1,exec,min,%.3f,,%.3f,%ld,%.4f\n",
               scale, min_time, min_time, total_filtered,
               calculate_selectivity(total_filtered));
    }

    // === e2e模式：包含编译开销 ===
    else if (strcmp(mode, "e2e") == 0) {
        double times[2];
        for (int run = 0; run < 2; run++) {
            double t0 = get_time_seconds();

            // 1. 重新编译JIT（每轮都编译）
            JITManager fresh_jit = {0};
            double compile_start = get_time_seconds();
            compile_query_jit(&fresh_jit, "q1");
            double compile_end = get_time_seconds();

            Q1BatchDriverFunc fresh_filter = (Q1BatchDriverFunc)dlsym(fresh_jit.jit_handle, "q1_batch_driver_jit");

            // 2. 执行一次过滤
            double exec_start = get_time_seconds();
            int64_t filtered = run_filter_pipeline(scan_handle, fresh_filter, &q1_mapping);
            double exec_end = get_time_seconds();

            double t1 = get_time_seconds();

            cleanup_jit_manager(&fresh_jit);
            reset_scan_position(scan_handle);
        }

        // 取最小值作为结果报告
        double min_e2e_time = times[0] < times[1] ? times[0] : times[1];
        printf("SF%s,scan_filter_q1,e2e,min,%.3f,%.3f,%.3f,%ld,%.4f\n",
               scale, min_e2e_time,
               min_e2e_time, min_e2e_time, // 简化输出，实际可记录详细分解
               filtered, calculate_selectivity(filtered));
    }

    cleanup_jit_manager(&jit_mgr);
    rt_scan_close(scan_handle);
    return 0;
}
```

#### 7.4.2 关键改进总结

**基于 llvm_jit 学习的核心改进**：

1. **精确列选择**：Q1 仅读 7 列，Q6 仅读 4 列，避免无关 I/O 开销
2. **动态列映射**：解决硬编码`columns[10]`问题，支持不同列布局
3. **数据适配层**：解决`SimpleBatch`与`ArrowBatch`的 gap
4. **改进 JIT 管理**：缓存机制、错误处理、唯一文件名
5. **分离测量边界**：精确区分 JIT 编译、数据转换、过滤执行的开销


这样的设计既学习了 llvm_jit 的核心思路（分层设计、参数化、链式过滤），又解决了现有实现的关键问题（硬编码、数据结构 gap、JIT 管理），能够提供精确和可靠的性能测试结果。
int32_t benchmark_scan_filter_q1_jit(const char *scale, const char *mode) {
// 加载 Q1 JIT 过滤函数
void *jit_lib = dlopen("/tmp/q1_jit.so", RTLD_LAZY);
typedef int32_t (*Q1FilterJIT)(const SimpleBatch *batch, uint32_t *output);
Q1FilterJIT jit_filter = (Q1FilterJIT)dlsym(jit_lib, "q1_batch_driver_jit");

    double times[2];
    for (int run = 0; run < 2; run++) {
        double start = get_time_seconds();

        // === 仅计时 JIT 过滤部分 ===
        ArrowBatch batch;
        int64_t total_filtered = 0;
        while (rt_scan_next(scan_handle, &batch) > 0) {
            uint32_t filter_output[batch.num_rows];
            SimpleBatch simple_batch = convert_arrow_to_simple(&batch);

            int32_t filtered_count = jit_filter(&simple_batch, filter_output);
            total_filtered += filtered_count;

            ndb_arrow_batch_cleanup(&batch);
        }
        // === JIT 过滤计时结束 ===

        double end = get_time_seconds();
        times[run] = (end - start) * 1000.0;
    }

    // 取最小值作为结果报告
    double min_time = times[0] < times[1] ? times[0] : times[1];
    printf("SF%s,scan_filter_q1,%s,min,%.3f,,%.3f,%ld,%.4f\n",
           scale, mode, min_time, min_time, total_filtered,
           calculate_selectivity(total_filtered));

    return 0;

}

````

## 7.5 基于学习的精确测试用例实现

#### 7.5.1 q1_full（完整 Q1 流水线：JIT 过滤 + JIT 聚合 + 排序）

```c
int32_t benchmark_q1_full_pipeline(const char *scale, const char *mode) {
    // JIT 过滤函数
    Q1BatchDriverFunc jit_filter = (Q1BatchDriverFunc)load_symbol("/tmp/scan_filter_q1.so", "q1_batch_driver_jit");

    double times[2];
    for (int run = 0; run < 2; run++) {
        double start = get_time_seconds();

        // === 计时完整流水线：JIT过滤 + 聚合 + 排序 ===
        Q1AggregationState *agg_state = q1_agg_init();

        ArrowBatch batch;
        while (rt_scan_next(scan_handle, &batch) > 0) {
            // Step 1: JIT 过滤（来自 llvm_jit/q1/q1_batch_driver.c）
            uint32_t filter_output[batch.num_rows];
            SimpleBatch simple_batch = convert_arrow_to_simple(&batch);
            int32_t filtered_count = jit_filter(&simple_batch, filter_output);

            // Step 2: 哈希聚合（来自 arrow-c/q1_incremental.c）
            q1_agg_process_batch(agg_state, &batch.arrow_array, filter_output, filtered_count);

            ndb_arrow_batch_cleanup(&batch);
        }

        // Step 3: 排序和输出（来自 arrow-c/q1_incremental.c）
        q1_agg_finalize(agg_state);  // 内部包含 pdqsort 排序
        // === 完整流水线计时结束 ===

        double end = get_time_seconds();
        times[run] = (end - start) * 1000.0;

        q1_agg_destroy(agg_state);
        reset_scan_position(scan_handle);
    }

    // 取最小值作为结果报告
    double min_time = times[0] < times[1] ? times[0] : times[1];
    printf("SF%s,q1_full,%s,min,%.3f\n", scale, mode, min_time);

    return 0;
}
````

#### 7.5.2 agg_only_q1（纯聚合测试，跳过过滤）

```c
int32_t benchmark_agg_only_q1(const char *scale, const char *mode) {
    double times[2];
    for (int run = 0; run < 2; run++) {
        double start = get_time_seconds();

        // === 仅计时聚合部分（跳过JIT过滤）===
        Q1AggregationState *agg_state = q1_agg_init();

        ArrowBatch batch;
        while (rt_scan_next(scan_handle, &batch) > 0) {
            // 构造全选选择向量（模拟无过滤场景）
            uint32_t all_indices[batch.num_rows];
            for (int64_t i = 0; i < batch.num_rows; i++) {
                all_indices[i] = i;
            }

            // 仅测试哈希聚合性能（AVX2 SIMD + 哈希表）
            q1_agg_process_batch(agg_state, &batch.arrow_array, all_indices, batch.num_rows);

            ndb_arrow_batch_cleanup(&batch);
        }

        q1_agg_finalize(agg_state);  // 包含排序
        // === 聚合计时结束 ===

        double end = get_time_seconds();
        times[run] = (end - start) * 1000.0;

        q1_agg_destroy(agg_state);
        reset_scan_position(scan_handle);
    }

    // 取最小值作为结果报告
    double min_time = times[0] < times[1] ? times[0] : times[1];
    printf("SF%s,agg_only_q1,%s,min,%.3f\n", scale, mode, min_time);

    return 0;
}
```

### 7.5.3 实现要点

1. **JIT 编译**：复用现有的 `generate_ir.sh` 脚本和 `tpch_jit_test.c` 中的编译逻辑
2. **数据转换**：需要实现 `ArrowBatch` → `SimpleBatch` 的转换函数
3. **状态管理**：利用现有的 `q1_agg_init/process_batch/finalize/destroy` API


通过这套精确的测试方案，可以准确评估现有 JIT 过滤器与非 JIT 聚合系统的协同性能。
