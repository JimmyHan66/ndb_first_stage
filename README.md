# NDB Scan & Filter Engine - 项目指南

## 项目概述

本项目实现了一个基于 Arrow/Parquet 的高性能扫描和过滤引擎，专注于以下核心功能：

- **Scan Runtime**: Arrow/Parquet 数据读取
- **Filter Kernels**: 高效的谓词过滤
- **Selection Vector**: 避免数据拷贝的索引向量
- **Batch Driver**: 批处理驱动器，协调 Scan + Filter + Aggregation

## 📦 环境依赖

### 系统要求

- macOS / Linux
- CMake 3.16+
- Apache Arrow 21.0.0+
- Apache Parquet
- C++17 编译器
- C99 编译器

### 安装依赖 (macOS)

```bash
# 使用Homebrew安装Arrow/Parquet
brew install apache-arrow

# 验证安装
pkg-config --cflags --libs arrow parquet
```

## 🚀 快速开始

### 1. 编译项目

```bash
# 创建构建目录
mkdir build && cd build

# 配置CMake (会自动检测Arrow/Parquet路径)
cmake ..

# 编译静态库
make ndb_scan_filter_static -j4

# 编译测试程序
make test_scan_filter_q1_arrow test_scan_filter_q6_arrow -j4
```

#### 🔧 **链接问题故障排除**

如果遇到链接错误 `ld: library not found for -larrow`，CMakeLists.txt 会自动尝试以下解决方案：

1. **自动检测**: CMake 会尝试 pkg-config，如果失败则自动检测 Homebrew 路径
2. **手动编译** (仅在 CMake 完全失败时使用):

```bash
# 编译静态库
make ndb_scan_filter_static

# 手动编译测试程序 (fallback方案)
g++ -I../include -I/opt/homebrew/Cellar/apache-arrow/21.0.0_5/include \
    -c ../tests/test_scan_filter_q1_arrow.c -o test_q1.o
g++ -o test_scan_filter_q1_arrow test_q1.o libndb_scan_filter.a \
    -L/opt/homebrew/Cellar/apache-arrow/21.0.0_5/lib -larrow -lparquet
```

3. **检查 Arrow 安装**:

```bash
# 验证Arrow安装
pkg-config --exists arrow && echo "Arrow OK"
ls /opt/homebrew/Cellar/apache-arrow/*/lib/libarrow.dylib
```

### 2. 准备测试数据

```bash
# 确保有TPC-H数据
# sf1/lineitem.parquet 应该在项目根目录
ls -la sf1/lineitem.parquet
```

### 3. 运行测试

```bash
# 运行Q1扫描和过滤测试
./build/test_scan_filter_q1_arrow

# 运行Q6扫描和过滤测试
./build/test_scan_filter_q6_arrow
```

## 🏗️ 核心架构

### 数据流

```
Parquet Files
    │
    ▼
[Arrow Parquet Reader] → Arrow RecordBatch
    │
    ▼
rt_scan_next() → ArrowBatch (C-compatible wrapper)
    │
    ▼
Filter Kernels → SelVec (selection vector with indices)
    │
    ▼
Aggregation Callback ← Batch Driver (ArrowBatch + SelVec)
```

### 核心数据结构

#### ArrowBatch

```c
typedef struct ArrowBatch {
  struct ArrowArray *c_array;    // Arrow C Data Interface
  struct ArrowSchema *c_schema;  // Arrow Schema
  int64_t num_rows;              // 行数
  int32_t num_cols;              // 列数
  void *arrow_batch_ptr;         // 生命周期管理
} ArrowBatch;
```

#### SelVec (Selection Vector)

```c
typedef struct {
  uint32_t *idx;    // 选中行号数组
  int32_t count;    // 选中行数
  int32_t cap;      // 容量
} SelVec;
```

## 🔧 聚合模块接入指南

### ⚠️ **聚合同学必读：接入 API 要求**

**作为聚合模块开发者，您需要实现以下标准接口来融入批处理流水线：**

#### **必须实现的 API:**

1. **`process_batch`** - 批处理函数，处理过滤后的数据
2. **`finalize`** - 结果输出函数，生成最终聚合结果
3. **`agg_state`** - 聚合状态结构，维护中间计算结果

#### **核心接入流程:**

```
Scan → Filter → SelVec → 您的process_batch → 您的finalize → 结果
```

#### **标准 API 签名 (必须严格遵守):**

```c
// 在 include/ndb_agg_callback.h 中定义
typedef struct {
  // 1. 批处理函数 - 处理每个批次的过滤数据
  void (*process_batch)(const ArrowBatch *batch,    // Arrow数据批次
                        const SelVec *sel,          // 过滤后的行索引
                        void *agg_state);           // 您的聚合状态

  // 2. 结果输出函数 - 生成最终聚合结果
  void (*finalize)(void *agg_state,                 // 您的聚合状态
                   void *result);                   // 输出结果缓冲区

  // 3. 聚合状态指针 - 指向您的状态结构
  void *agg_state;                                  // 您维护的中间状态
} AggCallback;
```

#### **接入检查清单:**

- [ ] ✅ 实现`process_batch`函数，正确处理 ArrowBatch + SelVec
- [ ] ✅ 实现`finalize`函数，输出最终聚合结果
- [ ] ✅ 定义`agg_state`结构，维护聚合中间状态
- [ ] ✅ 使用`ndb_get_arrow_column`访问列数据
- [ ] ✅ 使用 Selection Vector 避免全表扫描
- [ ] ✅ 添加边界检查，防止数组越界

### 1. 快速接入模板 (复制即用)

```c
#include "ndb_agg_callback.h"
#include "ndb_arrow_batch.h"
#include "ndb_selvec.h"

// 步骤1: 定义您的聚合状态结构
typedef struct {
  double sum;       // 累加值
  int64_t count;    // 行数
  double min_val;   // 最小值
  double max_val;   // 最大值
  // ... 添加您需要的聚合字段
} MyAggState;

// 步骤2: 实现批处理函数 (核心逻辑)
void my_process_batch(const ArrowBatch *batch, const SelVec *sel, void *agg_state) {
  MyAggState *state = (MyAggState *)agg_state;

  // 获取需要的列 (根据您的查询需求修改列索引)
  ArrowColumnView price_col;
  if (ndb_get_arrow_column(batch, 0, &price_col) != 0) return;  // 第0列
  ndb_analyze_arrow_column(&price_col);

  const double *prices = (const double *)price_col.values;

  // 使用Selection Vector高效聚合 (关键!)
  for (int32_t i = 0; i < sel->count; i++) {
    uint32_t row_idx = sel->idx[i];
    if (row_idx < batch->num_rows) {  // 边界检查
      double val = prices[row_idx];
      state->sum += val;
      state->count++;
      if (val < state->min_val) state->min_val = val;
      if (val > state->max_val) state->max_val = val;
    }
  }
}

// 步骤3: 实现结果输出函数
void my_finalize(void *agg_state, void *result) {
  MyAggState *state = (MyAggState *)agg_state;
  double *output = (double *)result;

  *output = (state->count > 0) ? state->sum / state->count : 0.0;
}

// 步骤4: 组装回调并运行
int main() {
  // 初始化状态
  MyAggState agg_state = {0.0, 0, DBL_MAX, -DBL_MAX};

  // 创建回调
  AggCallback agg_callback = {
    .process_batch = my_process_batch,
    .finalize = my_finalize,
    .agg_state = &agg_state
  };

  // 配置扫描
  const char *files[] = {"sf1/lineitem.parquet"};
  const char *columns[] = {"l_extendedprice", "l_shipdate"};  // 根据需要修改
  TableScanDesc scan_desc = {files, 1, columns, 2, 2048};

  ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);

  // 运行批处理驱动 (这里会调用您的函数!)
  int32_t result = ndb_q1_batch_driver(scan_handle, &agg_callback);

  // 获取结果
  double final_result;
  my_finalize(&agg_state, &final_result);
  printf("聚合结果: %f\n", final_result);

  rt_scan_close(scan_handle);
  return 0;
}
```

### 2. 详细实现指南

```c
#include "ndb_agg_callback.h"
#include "ndb_arrow_batch.h"
#include "ndb_selvec.h"

// 定义您的聚合状态
typedef struct {
  double sum;
  int64_t count;
  // ... 其他聚合字段
} MyAggState;

// 实现批处理函数
void my_process_batch(const ArrowBatch *batch, const SelVec *sel, void *agg_state) {
  MyAggState *state = (MyAggState *)agg_state;

  // 1. 获取需要的列视图
  ArrowColumnView price_col, qty_col;
  ndb_get_arrow_column(batch, 0, &price_col);  // l_extendedprice
  ndb_get_arrow_column(batch, 1, &qty_col);    // l_quantity

  // 2. 分析列数据结构
  ndb_analyze_arrow_column(&price_col);
  ndb_analyze_arrow_column(&qty_col);

  // 3. 使用Selection Vector进行聚合
  const double *prices = (const double *)price_col.values;
  const double *quantities = (const double *)qty_col.values;

  for (int32_t i = 0; i < sel->count; i++) {
    uint32_t row_idx = sel->idx[i];
    // 边界检查
    if (row_idx < batch->num_rows) {
      state->sum += prices[row_idx] * quantities[row_idx];
      state->count++;
    }
  }
}

// 实现结果输出函数
void my_finalize(void *agg_state, void *result) {
  MyAggState *state = (MyAggState *)agg_state;
  double *output = (double *)result;

  *output = (state->count > 0) ? state->sum / state->count : 0.0;
}
```

### 2. 创建并注册回调

```c
int main() {
  // 初始化聚合状态
  MyAggState agg_state = {0.0, 0};

  // 创建回调结构
  AggCallback agg_callback = {
    .process_batch = my_process_batch,
    .finalize = my_finalize,
    .agg_state = &agg_state
  };

  // 打开扫描句柄
  const char *files[] = {"sf1/lineitem.parquet"};
  const char *columns[] = {"l_extendedprice", "l_quantity", "l_shipdate"};
  TableScanDesc scan_desc = {
    .file_paths = files,
    .num_files = 1,
    .needed_cols = columns,
    .num_cols = 3,
    .batch_size = 2048
  };

  ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);
  if (!scan_handle) {
    fprintf(stderr, "Failed to open scan handle\n");
    return 1;
  }

  // 运行批处理驱动（这里会调用您的聚合函数）
  int32_t result = ndb_q1_batch_driver(scan_handle, &agg_callback);
  if (result != 0) {
    fprintf(stderr, "Batch driver failed\n");
  }

  // 获取最终结果
  double final_result;
  my_finalize(&agg_state, &final_result);
  printf("Aggregation result: %f\n", final_result);

  // 清理
  rt_scan_close(scan_handle);
  return 0;
}
```

### 3. Selection Vector 使用技巧

#### 高效访问模式

```c
// ✅ 推荐：使用Selection Vector
for (int32_t i = 0; i < sel->count; i++) {
  uint32_t row_idx = sel->idx[i];
  // 处理 values[row_idx]
}

// ❌ 避免：全扫描然后判断
for (int64_t i = 0; i < batch->num_rows; i++) {
  if (is_selected(i)) {  // 低效
    // 处理 values[i]
  }
}
```

#### 容量保护机制 (selvec_add_index)

```c
// ✅ 安全的SelVec操作
SelVec *sel = selvec_create(batch_size);

for (int64_t i = 0; i < length; i++) {
  if (condition_matches(values[i])) {
    // 安全添加，自动检查容量
    if (selvec_add_index(sel, i) != 0) {
      // 容量不足，处理错误
      printf("警告：SelVec容量不足，已处理 %d 个元素\n", sel->count);
      break;
    }
  }
}

// ❌ 危险：直接写入可能越界
// sel->idx[sel->count++] = i;  // 可能缓冲区溢出
```

#### 边界安全检查

```c
for (int32_t i = 0; i < sel->count; i++) {
  uint32_t row_idx = sel->idx[i];

  // 必要的边界检查
  if (row_idx >= batch->num_rows) {
    continue;  // 或报错
  }

  // 安全访问
  process_value(values[row_idx]);
}
```

### 4. Arrow 列数据访问

#### 获取列数据

```c
// 获取指定列
ArrowColumnView column;
int32_t status = ndb_get_arrow_column(batch, column_index, &column);
if (status != 0) {
  // 错误处理
}

// 分析列结构
status = ndb_analyze_arrow_column(&column);
if (status != 0) {
  // 错误处理
}
```

#### 根据数据类型访问

```c
switch (column.arrow_type_id) {
  case ARROW_TYPE_INT32:
    const int32_t *int_values = (const int32_t *)column.values;
    break;

  case ARROW_TYPE_INT64:
    const int64_t *long_values = (const int64_t *)column.values;
    break;

  case ARROW_TYPE_DOUBLE:
    const double *double_values = (const double *)column.values;
    break;

  case ARROW_TYPE_STRING:
    // 字符串需要特殊处理
    const int32_t *offsets = column.offsets;
    const uint8_t *data = column.data;
    break;

  default:
    // 未支持的类型
    return -1;
}
```

## 🧪 测试和性能验证

### 运行现有测试

```bash
# Q1测试（日期过滤）
./build/test_scan_filter_q1_arrow

# Q6测试（多条件过滤）
./build/test_scan_filter_q6_arrow

# 性能基准测试
./build/performance_benchmark
```

### 预期性能指标

- **吞吐量**: >70M rows/sec (在 TPC-H SF1 上)
- **内存效率**: 零拷贝设计，最小内存开销
- **选择性**: 支持 0.1%-100%的过滤选择性

## ⚠️ 已知限制和改进点

### 1. Table 方式的性能开销 (待优化)

**问题**: 当前使用`Table`方式一次性加载整个数据集到内存

- **内存占用**: 约 6M 行数据完全加载
- **启动延迟**: `rt_scan_open_parquet`需要读取完整 table
- **建议优化**: 迁移回 RecordBatchReader 的 lazy loading 方式

### 2. 错误处理完善 (部分完成)

**已改进**:

- 添加了统一错误码定义
- 增强了边界检查
  **待改进**:
- 更详细的错误信息
- 错误恢复机制

### 3. 内存管理优化

**已改进**:

- SelVec 容量检查
- ArrowBatch 生命周期管理
  **待改进**:
- 内存池化
- 更智能的批大小调整

## 🔍 调试和故障排除

### 常见问题

#### 1. "Failed to open scan handle"

```bash
# 检查文件权限
ls -la sf1/lineitem.parquet

# 检查Arrow安装
pkg-config --exists arrow && echo "Arrow OK"
```

#### 2. "Segmentation fault"

```bash
# 使用调试版本
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j4

# 运行gdb
gdb ./build/test_scan_filter_q1_arrow
```

#### 3. 性能问题

- 检查批大小设置 (推荐 2048-4096)
- 确认列投影正确 (只选择需要的列)
- 验证 Selection Vector 使用效率

### 开发工具

#### 生成 LLVM IR (用于 JIT 优化)

```bash
# 编译C代码为LLVM IR
clang -S -emit-llvm -I include src/ndb_filter_kernels_arrow.c -o filter_kernels.ll

# 查看生成的IR
cat filter_kernels.ll
```

#### 性能分析

```bash
# 使用perf分析热点
perf record ./build/test_scan_filter_q1_arrow
perf report
```

## 📞 技术支持

### 目录结构

```
├── include/           # 头文件
├── src/              # 源代码
├── tests/            # 测试程序
├── build/            # 构建输出
├── sf1/              # 测试数据
└── PROJECT_GUIDE.md  # 本文档
```

### 关键文件

- `include/ndb_agg_callback.h` - 聚合接口定义
- `include/ndb_selvec.h` - Selection Vector API
- `src/ndb_parquet_reader_arrow.cpp` - Parquet 读取实现
- `src/ndb_filter_kernels_arrow.c` - 过滤内核
- `tests/test_scan_filter_q1_arrow.c` - Q1 测试示例

有问题请参考测试用例或提 issue！
