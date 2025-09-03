#include "../common/ndb_types.h"
#include "../../include/ndb_scan_runtime.h"
#include "../../include/ndb_arrow_batch.h"
#include "../../include/ndb_arrow_column.h"
#include "../../include/ndb_agg_state.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// q1_full 完整 JIT 流水线
// 功能：扫描 + Q1 过滤 + Q1 聚合 + 排序
// 输入：ScanHandle*
// 输出：聚合处理的总行数
int32_t q1_full_pipeline_jit(ScanHandle *scan_handle) {
    if (!scan_handle) {
        return -1;
    }

    // Q1 过滤条件: l_shipdate <= '1998-12-01'
    const int32_t shipdate_threshold = 10561;

    // 声明过滤函数
    extern int32_t filter_le_date32(const SimpleColumnView *col,
                                    int32_t threshold, uint32_t *output_idx);

    extern Q1AggregationState* q1_agg_init_optimized(void);
    Q1AggregationState *agg_state = q1_agg_init_optimized();
    if (!agg_state) {
        printf("Failed to initialize Q1 aggregation state\n");
        return -1;
    }

    ArrowBatch arrow_batch;
    ndb_arrow_batch_init(&arrow_batch);

    int64_t total_rows_scanned = 0;
    int64_t total_rows_filtered = 0;
    int64_t total_rows_aggregated = 0;
    int32_t batch_count = 0;
    int32_t result;

    printf("=== q1_full JIT Pipeline ===\n");

    // ========== 主 Scan 循环 ==========
    while ((result = rt_scan_next(scan_handle, &arrow_batch)) > 0) {
        batch_count++;
        total_rows_scanned += arrow_batch.num_rows;

        if (arrow_batch.num_rows == 0) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 获取 l_shipdate 列 (Q1优化列集合中的第6列)
        ArrowColumnView arrow_shipdate_col;
        if (ndb_get_arrow_column(&arrow_batch, 6, &arrow_shipdate_col) != 0) {
            printf("Failed to get shipdate column in batch %d\n", batch_count);
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 转换为 SimpleBatch 格式
        SimpleColumnView simple_shipdate_col;
        simple_shipdate_col.values = (const int32_t*)arrow_shipdate_col.values;
        simple_shipdate_col.validity = arrow_shipdate_col.validity;
        simple_shipdate_col.length = arrow_shipdate_col.length;
        simple_shipdate_col.offset = arrow_shipdate_col.offset;
        simple_shipdate_col.arrow_type_id = arrow_shipdate_col.arrow_type_id;

        // 分配过滤输出缓冲区
        uint32_t *filter_output = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));
        if (!filter_output) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // ========== JIT Q1 过滤执行 ==========
        int32_t filtered_count = filter_le_date32(&simple_shipdate_col,
                                                  shipdate_threshold,
                                                  filter_output);

        if (filtered_count > 0) {
            total_rows_filtered += filtered_count;

            // ========== Q1 聚合处理 (优化版本) ==========
            extern void q1_agg_process_batch_optimized(Q1AggregationState *state, struct ArrowArray *arr,
                                                       const int32_t *sel_indices, int32_t sel_count);
            q1_agg_process_batch_optimized(agg_state, arrow_batch.c_array,
                                          (const int32_t*)filter_output, filtered_count);

            total_rows_aggregated += filtered_count;

            if (batch_count % 100 == 0) {
                printf("Batch %d: %lld rows -> %d filtered -> %d aggregated (%.2f%%)\n",
                       batch_count, arrow_batch.num_rows, filtered_count, filtered_count,
                       100.0 * filtered_count / arrow_batch.num_rows);
            }
        }

        // 清理当前批次
        free(filter_output);
        ndb_arrow_batch_cleanup(&arrow_batch);
    }

    // ========== 最终聚合和排序 (优化版本) ==========
    printf("\nFinalizing Q1 aggregation and sorting...\n");
    extern void q1_agg_finalize_optimized(Q1AggregationState *state);
    q1_agg_finalize_optimized(agg_state);  // 包含 pdqsort 排序和结果输出

    // ========== 最终结果输出 ==========
    printf("\n=== q1_full Results ===\n");
    printf("Total batches: %d\n", batch_count);
    printf("Total rows scanned: %lld\n", total_rows_scanned);
    printf("Total rows filtered: %lld\n", total_rows_filtered);
    printf("Total rows aggregated: %lld\n", total_rows_aggregated);
    printf("Aggregation groups: %d\n", agg_state->hash_table.entry_count);
    printf("Overall selectivity: %.3f%%\n",
           total_rows_scanned > 0 ? (100.0 * total_rows_filtered / total_rows_scanned) : 0.0);

    // 清理聚合状态
    // 清理 (优化版本)
    extern void q1_agg_destroy_optimized(Q1AggregationState *state);
    q1_agg_destroy_optimized(agg_state);

    if (result < 0) {
        printf("Error during scan: %d\n", result);
        return result;
    }

    return (int32_t)total_rows_aggregated;
}
