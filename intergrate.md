# Q1/Q6 高性能聚合方案集成设计

## 1. 现状分析

### 1.1 当前架构分析

**你的 Batch 处理流水线（src/ndb_batch_driver_arrow.c）:**

```
rt_scan_next() -> Filter Pipeline -> agg_callback->process_batch()
```

**现有的高性能聚合实现（arrow-c/）:**

- **Q1 实现**: `q1_hash_aggregate()` 在 `q1_onebatch_256_qsortfull.c`
- **Q6 实现**: `q6_sum()` 在 `q6_onebatch.c`
- **核心组件**: AVX2 SIMD 求和、xxHash、pdqsort 排序

### 1.2 现有聚合实现的关键函数分析

**Q1 实现 (`q1_onebatch_256_qsortfull.c`):**

```c
void q1_hash_aggregate(struct ArrowArray *arr, struct ArrowSchema *schema)
```

- 哈希聚合 + AVX2DoubleSumBuffer + pdqsort 排序
- 完整的 TPC-H Q1 逻辑：分组、聚合、排序、输出
- **性能特点**: 高度优化的 SIMD 操作，零拷贝 decimal 解析

**Q6 实现 (`q6_onebatch.c`):**

```c
void q6_sum(struct ArrowArray *arr, struct ArrowSchema *schema)
```

- 简单累计求和 + AVX2DoubleSumBuffer
- 完整的 TPC-H Q6 逻辑：聚合求和
- **性能特点**: 直接内存访问，AVX2 向量化累加

## 2. 高性能集成策略

### 2.1 设计目标

**目标**: 以最小的性能开销集成现有聚合实现到你的 batch 处理框架

```
┌─────────────────┐    ┌──────────────────────┐    ┌─────────────────┐
│ Your Scan+Filter│    │ Existing Agg Logic   │    │ Performance     │
│                 │───▶│ (Direct Integration)  │───▶│ Benchmark       │
│ (existing src/) │    │ (from arrow-c/)      │    │                 │
└─────────────────┘    └──────────────────────┘    └─────────────────┘
```

### 2.2 批处理层次架构说明

**重要澄清: 两个不同层次的"batch"概念**

1. **外层 Batch (I/O 层次)**:

   - **大小**: 2048 行 (在 ScanHandle 中配置: `batch_size(2048)`)
   - **作用**: `rt_scan_next()` 每次从 Parquet 文件读取的数据块
   - **流程**: `while (rt_scan_next(scan_handle, &batch) > 0)`

2. **内层 Batch (SIMD 优化层次)**:
   - **Q1 大小**: 8 行 (在 Q1 聚合函数中的 `BATCH_SIZE = 8`)
   - **Q6 大小**: 1 行 (逐行处理，`for (row++; row < arr->length)`)
   - **作用**: Q1 将外层 batch 的 2048 行按每 8 行一组进行 SIMD 向量化处理；Q6 逐行处理
   - **流程**:
     - Q1: `for (row = 0; row < arr->length; row += 8)`
     - Q6: `for (row = 0; row < arr->length; row++)`

**数据流示意**:

```
Q1: Parquet文件 → rt_scan_next(2048行) → Q1聚合(8行×256组) → AVX2 SIMD处理
Q6: Parquet文件 → rt_scan_next(2048行) → Q6聚合(逐行×2048次) → 单个AVX2累加
```

**不会冲突**: 这是嵌套的批处理设计，内层 8 行批处理是在外层 2048 行基础上的进一步向量化优化。

### 2.3 关键性能考虑

#### 2.3.1 数据转换开销分析

**问题**: ArrowBatch + SelVec → ArrowArray 转换成本
**解决方案**: 修改现有聚合函数，支持 SelVec 直接过滤

**性能对比:**

```c
// 方案A: 数据转换 (性能损失大)
ArrowArray* converted = convert_batch_to_arrow(batch, sel);  // 拷贝开销
q1_hash_aggregate(converted, schema);

// 方案B: 函数改造 (推荐，性能最优)
q1_hash_aggregate_with_filter(batch->c_array, batch->c_schema, sel);
```

#### 2.2.2 增量聚合必要性分析

**现有实现处理方式**: 一次性处理完整的 ArrowArray
**你的架构**: 多个 batch 分批处理

**性能影响评估:**

- **无需改造**: 如果数据集较小，可以合并所有 batch 后一次性聚合
- **需要改造**: 如果数据集很大，必须支持跨 batch 的状态保持

## 3. 具体集成方案

### 3.1 方案选择说明

**本设计选择方案 B: 函数改造支持 SelVec (推荐，性能最优)**

**选择原因:**

1. **零拷贝**: 直接在原始数据上操作，避免 ArrowBatch→ArrowArray 转换开销
2. **保持优化**: 完全保留 AVX2 SIMD、pdqsort 等性能优化
3. **内存效率**: 无需累积所有 batch 数据，支持流式处理
4. **修改最小**: 只需在现有函数基础上添加 SelVec 支持

### 3.2 方案 B: 函数改造支持 SelVec (选定方案)

#### 3.2.1 需要改造的具体文件

**改造位置明确说明:**

1. **Q6 聚合改造**: 修改 `arrow-c/q6_onebatch.c` 文件

   - 原始函数: `q6_sum(struct ArrowArray *arr, struct ArrowSchema *schema)`
   - 新增函数: `q6_sum_with_sel(...)` 支持 SelVec 过滤

2. **Q1 聚合改造**: 修改 `arrow-c/q1_onebatch_256_qsortfull.c` 文件
   - 原始函数: `q1_hash_aggregate(struct ArrowArray *arr, struct ArrowSchema *schema)`
   - 新增函数: `q1_hash_aggregate_with_sel(...)` 支持 SelVec 过滤

#### 3.2.2 新增函数签名

```c
// 在 arrow-c/q6_onebatch.c 中新增
void q6_sum_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                    const int32_t *sel_indices, int32_t sel_count);

// 在 arrow-c/q1_onebatch_256_qsortfull.c 中新增
void q1_hash_aggregate_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                                const int32_t *sel_indices, int32_t sel_count);
```

#### 3.2.3 具体改造要点

**以 Q6 为例，修改 `arrow-c/q6_onebatch.c`:**

```c
void q6_sum_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                    const int32_t *sel_indices, int32_t sel_count) {
    int price_col = 3, discount_col = 2;
    AVX2DoubleSumBuffer* sum_revenue = avx2_double_sum_create(512);

    // 原来: for (int64_t row = 0; row < arr->length; row++)
    // 修改为: 只处理 sel_indices 中的行
    for (int32_t i = 0; i < sel_count; i++) {
        int64_t row = sel_indices[i];  // 通过 SelVec 索引访问

        // 其余逻辑保持不变...
        // 提取 l_extendedprice
        double price = 0;
        if (arr->children[price_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[price_col]->buffers[1];
            uint8_t *decimal_bytes = data + (row * 16);  // 使用过滤后的row
            // ... decimal解析逻辑不变
        }

        // 提取 l_discount 和聚合逻辑不变...
    }

    double revenue = avx2_double_sum_get_result(sum_revenue);
    printf("sum_revenue: %.2f\n", revenue);
    avx2_double_sum_destroy(sum_revenue);
}
```

**Q1 改造要点 (修改 `arrow-c/q1_onebatch_256_qsortfull.c`):**

原始函数中的关键循环：

```c
// 原始代码 (第316行左右)
for (int64_t row = 0; row < arr->length; row += BATCH_SIZE) {
    // 处理每个batch...
}
```

改造为：

```c
// 新增函数 q1_hash_aggregate_with_sel
void q1_hash_aggregate_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                               const int32_t *sel_indices, int32_t sel_count) {
    // 只处理 sel_indices 中指定的行
    for (int32_t i = 0; i < sel_count; i += BATCH_SIZE) {
        int current_batch_size = (sel_count - i >= BATCH_SIZE) ? BATCH_SIZE : (sel_count - i);

        // 批量提取分组键 - 使用 sel_indices[i+j] 而不是 row+j
        for (int j = 0; j < current_batch_size; j++) {
            int64_t actual_row = sel_indices[i + j];  // 关键修改点
            batch_returnflags[j] = extract_first_char_from_utf8(arr->children[returnflag_col], actual_row);
            // ... 其余提取逻辑使用 actual_row
        }

        // 聚合逻辑保持不变...
    }

    // 排序和输出逻辑完全不变
    pdqsort(hash_table.entries, hash_table.entry_count, sizeof(HashEntry), compare_hash_entry);
    // ... 输出逻辑
}
```

### 3.3 增量聚合状态管理 (可选，大数据集)

#### 3.3.1 状态结构设计

```c
// Q1 增量聚合状态
typedef struct {
    HashTable hash_table;
    bool finalized;
} Q1AggregationState;

// Q6 增量聚合状态
typedef struct {
    AVX2DoubleSumBuffer *sum_revenue;
} Q6AggregationState;
```

#### 3.3.2 增量函数设计

```c
// Q1 增量聚合 API
Q1AggregationState* q1_agg_init(void);
void q1_agg_process_batch(Q1AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count);
void q1_agg_finalize(Q1AggregationState *state);  // 排序 + 输出
void q1_agg_destroy(Q1AggregationState *state);

// Q6 增量聚合 API
Q6AggregationState* q6_agg_init(void);
void q6_agg_process_batch(Q6AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count);
void q6_agg_finalize(Q6AggregationState *state);   // 输出结果
void q6_agg_destroy(Q6AggregationState *state);
```

## 4. AggCallback 包装器实现

### 4.1 Q6 包装器 (方案 B)

```c
typedef struct {
    Q6AggregationState *agg_state;
} Q6CallbackWrapper;

void q6_process_batch_callback(const ArrowBatch *batch, const SelVec *sel, void *state) {
    Q6CallbackWrapper *wrapper = (Q6CallbackWrapper*)state;

    // 直接调用修改后的函数，零拷贝
    q6_agg_process_batch(wrapper->agg_state,
                        batch->c_array,
                        sel->idx,
                        sel->count);
}

void q6_finalize_callback(void *state, void *result) {
    Q6CallbackWrapper *wrapper = (Q6CallbackWrapper*)state;
    q6_agg_finalize(wrapper->agg_state);
}
```

### 4.2 Q1 包装器 (方案 B)

```c
typedef struct {
    Q1AggregationState *agg_state;
} Q1CallbackWrapper;

void q1_process_batch_callback(const ArrowBatch *batch, const SelVec *sel, void *state) {
    Q1CallbackWrapper *wrapper = (Q1CallbackWrapper*)state;

    q1_agg_process_batch(wrapper->agg_state,
                        batch->c_array,
                        sel->idx,
                        sel->count);
}

void q1_finalize_callback(void *state, void *result) {
    Q1CallbackWrapper *wrapper = (Q1CallbackWrapper*)state;
    q1_agg_finalize(wrapper->agg_state);  // 内部执行 pdqsort + 输出
}
```

## 5. 工厂函数和使用接口

### 5.1 工厂函数

```c
// src/agg_callback_factory.h
AggCallback* create_q1_agg_callback(void) {
    AggCallback *callback = malloc(sizeof(AggCallback));
    Q1CallbackWrapper *wrapper = malloc(sizeof(Q1CallbackWrapper));

    wrapper->agg_state = q1_agg_init();

    callback->process_batch = q1_process_batch_callback;
    callback->finalize = q1_finalize_callback;
    callback->agg_state = wrapper;

    return callback;
}

AggCallback* create_q6_agg_callback(void) {
    // 类似实现...
}
```

### 5.2 使用方式

```c
// 在你的测试代码中
AggCallback *q1_callback = create_q1_agg_callback();
int32_t result = ndb_q1_batch_driver(scan_handle, q1_callback);

AggCallback *q6_callback = create_q6_agg_callback();
int32_t result = ndb_q6_batch_driver(scan_handle, q6_callback);
```

## 6. 文件组织和构建

### 6.1 文件结构

```
src/
├── agg_callback_factory.c/.h    # AggCallback 工厂函数
└── ndb_batch_driver_arrow.c     # 你的驱动 (使用新callbacks)

arrow-c/  (只需添加新函数，其他文件保持不变)
├── q1_onebatch_256_qsortfull.c  # 添加 q1_hash_aggregate_with_sel() 函数
├── q6_onebatch.c                # 添加 q6_sum_with_sel() 函数
├── avx2_double_simd_sum.*       # 保持不变
├── pdqsort.*                    # 保持不变
├── xxhash.h                     # 保持不变
└── abi.h                        # 保持不变
```

**改造工作量说明:**

- **Q6 改造**: 在 `q6_onebatch.c` 中添加约 20 行代码 (复制原函数+修改循环)
- **Q1 改造**: 在 `q1_onebatch_256_qsortfull.c` 中添加约 50 行代码 (复制原函数+修改循环)
- **总计**: 仅需添加约 70 行代码，无需修改现有函数

### 6.2 构建配置

```cmake
# CMakeLists.txt 中添加
target_link_libraries(your_target
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6.so
)
```

## 7. 性能优化策略

### 7.1 零拷贝优化

- **避免 ArrowBatch → ArrowArray 转换**
- **直接使用 batch->c_array 指针**
- **SelVec 索引直接传递给聚合函数**

### 7.2 内存访问优化

- **保持 AVX2 SIMD 向量化**
- **利用现有的批量 decimal 解析**
- **复用 xxHash 和 pdqsort 优化**

### 7.3 缓存友好性

- **保持聚合状态的内存局部性**
- **最小化跨 batch 的状态同步开销**

## 8. 验证和基准测试

### 8.1 正确性验证

1. **单独测试**: 独立运行 arrow-c 中的原始实现
2. **集成测试**: 在你的框架中运行包装后的实现
3. **结果对比**: 确保输出完全一致

### 8.2 性能基准测试

```c
// 性能测试框架
clock_t start = clock();
ndb_q1_batch_driver(scan_handle, q1_callback);
clock_t end = clock();
double cpu_time = ((double)(end - start)) / CLOCKS_PER_SEC;
```

**测试指标:**

- **聚合吞吐量** (rows/second)
- **内存使用峰值**
- **与原始实现的性能对比**

## 9. 总结

### 9.1 选定方案: 方案 B (函数改造 + SelVec 支持)

**为什么选择方案 B:**

1. **性能最优**: 零拷贝，直接内存访问，无数据转换开销
2. **改造最小**: 只需在 arrow-c 中添加约 70 行代码
3. **保持优化**: 完全保留 AVX2 SIMD、pdqsort 等性能优化
4. **易于理解**: 改造逻辑简单，就是把循环索引从 `row` 改为 `sel_indices[i]`

### 9.2 具体改造位置

**明确告诉实施者需要改哪里:**

1. **修改 `arrow-c/q6_onebatch.c`**: 添加 `q6_sum_with_sel()` 函数

   - 复制原 `q6_sum()` 函数
   - 修改循环: `for (int32_t i = 0; i < sel_count; i++)`
   - 使用 `sel_indices[i]` 作为行索引

2. **修改 `arrow-c/q1_onebatch_256_qsortfull.c`**: 添加 `q1_hash_aggregate_with_sel()` 函数

   - 复制原 `q1_hash_aggregate()` 函数
   - 修改外层循环和内层行索引访问
   - 使用 `sel_indices[i + j]` 作为实际行号

3. **创建 `src/agg_callback_factory.c/.h`**: AggCallback 包装器和工厂函数

### 9.3 实施步骤

1. **第一步**: 在 arrow-c 中添加上述两个 `*_with_sel` 函数
2. **第二步**: 创建 AggCallback 包装器
3. **第三步**: 集成测试验证正确性
4. **第四步**: 性能基准测试对比

**预期效果**: 能够在你的 batch 处理框架中直接使用现有的高性能聚合实现，实现客观的性能测试对比，同时保持所有 SIMD 优化效果。
