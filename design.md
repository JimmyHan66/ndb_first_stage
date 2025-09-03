# NDB Scan & Filter Engine - 优化设计

## 范围（Scope）

- 以 Arrow/Parquet 为存储与解码（仅列裁剪，不做谓词下推）。
- 代码全部用 C 编写；需要 JIT 时，用 clang -S -emit-llvm 直接产出 LLVM IR（.ll）。
- 你的职责：Scan（运行时模块）、Filter（C 内核）、批循环 Driver（C 函数：在一个 batch 内完成 "Filter → 调用外部 Agg"的工作）。
- 不在本设计内：Agg/Sort 的实现（由他人负责；本设计只定义 Agg 的回调 ABI，供批循环调用）。

## 1. 优化目标与架构

### 1.1 核心优化原则

- **零拷贝设计**：直接使用 Arrow 数据结构，避免不必要的转换
- **Selection Vector 价值最大化**：这是我们相对 Arrow 的核心价值
- **消除 arrow_to_datachunk 开销**：直接在 Arrow buffers 上操作

### 1.2 数据流（优化版）

```
Parquet files
    │
    ▼
[Arrow Parquet Reader (C++)] → Arrow RecordBatch
    │
    ▼
rt_scan_next(handle, &ArrowBatch)    // 直接包装Arrow C Data Interface
    │
    ▼
Filter Kernels (C) → SelVec(indices)   // 直接操作Arrow buffers
    │
    ▼
Agg 回调 ← 由批循环 Driver (C) 调用 (ArrowBatch + SelVec)
```

## 2. 核心数据结构（优化版）

### 2.1 ArrowBatch - Arrow 数据批次包装

```c
// include/ndb_arrow_batch.h
typedef struct ArrowBatch {
  struct ArrowArray *c_array;    // Arrow C Data Interface数组
  struct ArrowSchema *c_schema;  // Arrow C Data Interface模式
  int64_t num_rows;              // 行数
  int32_t num_cols;              // 列数
  void *arrow_batch_ptr;         // 原始Arrow RecordBatch指针(用于生命周期管理)
} ArrowBatch;
```

### 2.2 ArrowColumnView - 直接访问 Arrow 列

```c
// include/ndb_arrow_column.h
typedef struct ArrowColumnView {
  const struct ArrowArray *arrow_array;   // Arrow列数组
  const struct ArrowSchema *arrow_schema; // Arrow列模式

  // 缓存的快速访问字段
  const uint8_t *validity;     // buffers[0] - 有效性位图
  const void *values;          // buffers[1] - 数据值(定长类型)
  const int32_t *offsets;      // buffers[1] - 偏移数组(变长类型)
  const uint8_t *data;         // buffers[2] - 数据区(变长类型)

  int32_t arrow_type_id;       // Arrow类型ID
  int32_t elem_size;           // 元素大小
  int64_t length;              // 行数
  int64_t offset;              // 起始偏移
} ArrowColumnView;
```

### 2.3 Selection Vector 保持不变

```c
// include/ndb_selvec.h
typedef struct SelVec {
  uint32_t *idx;     // 选中行号 [0..N-1]
  int32_t count;     // 选中个数
  int32_t cap;       // 预分配容量
} SelVec;
```

## 3. Scan 运行时 API（优化版）

### 3.1 扫描描述符

```c
// include/ndb_scan_runtime.h
typedef struct TableScanDesc {
  const char **file_paths;    // Parquet文件路径数组
  int32_t num_files;          // 文件数量
  const char **needed_cols;   // 需要的列名数组
  int32_t num_cols;           // 列数量
  int32_t batch_size;         // 批大小
} TableScanDesc;

typedef struct ScanHandle ScanHandle;  // 不透明句柄
```

### 3.2 扫描 API

```c
// 打开扫描
ScanHandle* rt_scan_open_parquet(const TableScanDesc *desc);

// 获取下一批（直接返回Arrow数据）
int32_t rt_scan_next(ScanHandle *handle, ArrowBatch *out_batch);

// 关闭扫描
void rt_scan_close(ScanHandle *handle);

// 清理ArrowBatch资源
void ndb_arrow_batch_cleanup(ArrowBatch *batch);
```

## 4. Filter 内核（直接操作 Arrow）

### 4.1 Arrow 列访问辅助函数

```c
// include/ndb_arrow_column.h
// 从ArrowBatch中获取列视图
int32_t ndb_get_arrow_column(const ArrowBatch *batch, int32_t col_idx,
                             ArrowColumnView *out_col);

// 检查Arrow类型并获取访问参数
int32_t ndb_analyze_arrow_column(const ArrowColumnView *col);
```

### 4.2 Filter 内核（直接操作 Arrow buffers）

```c
// include/ndb_filter_kernels.h
// 日期过滤（直接操作Arrow INT32数组）
int32_t ndb_filter_le_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length,
                                   int32_t threshold,
                                   uint32_t *output_idx);

int32_t ndb_filter_ge_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length,
                                   int32_t threshold,
                                   uint32_t *output_idx);

// 数值过滤（直接操作Arrow INT64数组）
int32_t ndb_filter_lt_arrow_i64(const ArrowColumnView *col,
                                int64_t batch_length,
                                int64_t threshold,
                                uint32_t *output_idx);

// 链式过滤（在selection vector基础上过滤）
int32_t ndb_filter_lt_arrow_i64_on_sel(const uint32_t *input_sel,
                                       int32_t input_count,
                                       const ArrowColumnView *col,
                                       int64_t threshold,
                                       uint32_t *output_idx);
```

## 5. 批循环 Driver（优化版）

### 5.1 聚合回调 ABI

```c
// include/ndb_agg_callback.h
typedef struct AggCallback {
  void (*process_batch)(const ArrowBatch *batch, const SelVec *sel, void *agg_state);
  void (*finalize)(void *agg_state, void *result);
  void *agg_state;
} AggCallback;
```

### 5.2 批 Driver 函数

```c
// include/ndb_batch_driver.h
// TPC-H Q1批处理驱动
int32_t ndb_q1_batch_driver(ScanHandle *scan_handle, AggCallback *agg_callback);

// TPC-H Q6批处理驱动
int32_t ndb_q6_batch_driver(ScanHandle *scan_handle, AggCallback *agg_callback);
```

## 6. 实现优势

### 6.1 性能优势

- **消除转换开销**：不再需要 arrow_to_datachunk 转换
- **减少内存分配**：直接使用 Arrow 的内存布局
- **更好的缓存局部性**：减少指针间接访问
- **利用 Arrow 优化**：继承 Arrow 的 SIMD 等优化

### 6.2 代码简化

- **更少的数据结构**：只需维护 Selection Vector
- **更简单的内存管理**：Arrow 负责数据生命周期
- **更直接的类型映射**：直接使用 Arrow 类型系统

### 6.3 保留核心价值

- **Selection Vector**：仍然是我们的核心差异化功能
- **链式过滤**：零拷贝的多谓词过滤
- **批处理驱动**：高效的 Scan+Filter+Agg 协调

## 7. 文件结构

```
include/
├── ndb_arrow_batch.h      // ArrowBatch结构定义
├── ndb_arrow_column.h     // Arrow列访问辅助
├── ndb_selvec.h           // Selection Vector（不变）
├── ndb_scan_runtime.h     // 扫描运行时API
├── ndb_filter_kernels.h   // Filter内核（Arrow版）
├── ndb_batch_driver.h     // 批处理驱动
└── ndb_agg_callback.h     // 聚合回调ABI

src/
├── ndb_arrow_batch.c      // ArrowBatch操作实现
├── ndb_arrow_column.c     // Arrow列访问实现
├── ndb_selvec.c           // Selection Vector实现（不变）
├── ndb_parquet_reader.cpp // Arrow/Parquet读取（简化）
├── ndb_filter_kernels.c   // Filter内核实现（Arrow版）
└── ndb_batch_driver.c     // 批处理驱动实现
```

这个优化设计的核心思想是：**直接在 Arrow 的数据结构上添加 Selection Vector 功能，而不是创建平行的数据结构**。
