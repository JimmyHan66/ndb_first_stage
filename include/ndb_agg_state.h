#ifndef NDB_AGG_STATE_H
#define NDB_AGG_STATE_H

#include <stdint.h>
#include <stdbool.h>
#include "ndb_arrow_column.h"
// Forward declaration instead of include
struct AVX2DoubleSumBuffer;

// Forward declarations
struct ArrowArray;
struct ArrowSchema;

// Q6 增量聚合状态
typedef struct {
    struct AVX2DoubleSumBuffer *sum_revenue;
} Q6AggregationState;

// Q1 增量聚合状态 - 需要包含完整的HashTable定义
#define HASH_TABLE_SIZE 1024

typedef struct {
    char returnflag;
    char linestatus;
    uint64_t hash_key;
    int64_t count_order;

    // 使用AVX2缓冲区进行高效求和
    struct AVX2DoubleSumBuffer *sum_qty_buffer;
    struct AVX2DoubleSumBuffer *sum_base_price_buffer;
    struct AVX2DoubleSumBuffer *sum_disc_price_buffer;
    struct AVX2DoubleSumBuffer *sum_charge_buffer;
    struct AVX2DoubleSumBuffer *sum_discount_buffer;

    // 最终聚合结果
    double sum_qty;
    double sum_base_price;
    double sum_disc_price;
    double sum_charge;
    double sum_discount;
} Q1HashEntry;

typedef struct {
    Q1HashEntry entries[HASH_TABLE_SIZE];
    int entry_count;
} Q1HashTable;

typedef struct {
    Q1HashTable hash_table;
    bool finalized;
} Q1AggregationState;

// Q6 增量聚合 API
Q6AggregationState* q6_agg_init(void);
void q6_agg_process_batch(Q6AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count);
void q6_agg_finalize(Q6AggregationState *state);
void q6_agg_destroy(Q6AggregationState *state);

// Q1 增量聚合 API
Q1AggregationState* q1_agg_init(void);
void q1_agg_process_batch(Q1AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count);
void q1_agg_finalize(Q1AggregationState *state);
void q1_agg_destroy(Q1AggregationState *state);

#endif // NDB_AGG_STATE_H
