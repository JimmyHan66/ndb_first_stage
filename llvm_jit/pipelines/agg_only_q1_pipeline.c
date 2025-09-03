#include "../common/ndb_types.h"
#include "../../include/ndb_scan_runtime.h"
#include "../../include/ndb_arrow_batch.h"
#include "../../include/ndb_arrow_column.h"
#include "../../include/ndb_agg_state.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// agg_only_q1 完整 JIT 流水线
// 功能：扫描 + 全选（不过滤）+ Q1 聚合 + 排序
// 输入：ScanHandle*
// 输出：聚合处理的总行数
int32_t agg_only_q1_pipeline_jit(ScanHandle *scan_handle) {
    if (!scan_handle) {
        return -1;
    }

    // 初始化 Q1 聚合状态 (优化版本)
    extern Q1AggregationState* q1_agg_init_optimized(void);
    Q1AggregationState *agg_state = q1_agg_init_optimized();
    if (!agg_state) {
        printf("Failed to initialize Q1 aggregation state\n");
        return -1;
    }

    ArrowBatch arrow_batch;
    ndb_arrow_batch_init(&arrow_batch);

    int64_t total_rows_scanned = 0;
    int64_t total_rows_aggregated = 0;
    int32_t batch_count = 0;
    int32_t result;

    printf("=== agg_only_q1 JIT Pipeline ===\n");

    // ========== 主 Scan 循环 ==========
    while ((result = rt_scan_next(scan_handle, &arrow_batch)) > 0) {
        batch_count++;
        total_rows_scanned += arrow_batch.num_rows;

        if (arrow_batch.num_rows == 0) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // ========== 生成全选选择向量（跳过过滤）==========
        uint32_t *all_indices = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));
        if (!all_indices) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // JIT 化的全选向量生成
        for (int64_t i = 0; i < arrow_batch.num_rows; i++) {
            all_indices[i] = (uint32_t)i;
        }

                // ========== Q1 聚合处理 (优化版本) ==========
        extern void q1_agg_process_batch_optimized(Q1AggregationState *state, struct ArrowArray *arr,
                                                   const int32_t *sel_indices, int32_t sel_count);
        q1_agg_process_batch_optimized(agg_state, arrow_batch.c_array,
                                      (const int32_t*)all_indices, (int32_t)arrow_batch.num_rows);

        total_rows_aggregated += arrow_batch.num_rows;

        if (batch_count % 100 == 0) {
            printf("Batch %d: %lld rows -> %lld aggregated (100.00%%)\n",
                   batch_count, arrow_batch.num_rows, arrow_batch.num_rows);
        }

        // 清理当前批次
        free(all_indices);
        ndb_arrow_batch_cleanup(&arrow_batch);
    }

    // ========== 最终聚合和排序 (优化版本) ==========
    printf("\nFinalizing Q1 aggregation and sorting...\n");
    extern void q1_agg_finalize_optimized(Q1AggregationState *state);
    q1_agg_finalize_optimized(agg_state);  // 包含 pdqsort 排序

    // ========== 最终结果输出 ==========
    printf("\n=== agg_only_q1 Results ===\n");
    printf("Total batches: %d\n", batch_count);
    printf("Total rows scanned: %lld\n", total_rows_scanned);
    printf("Total rows aggregated: %lld\n", total_rows_aggregated);
    printf("Aggregation groups: %d\n", agg_state->hash_table.entry_count);

    extern void q1_agg_destroy_optimized(Q1AggregationState *state);
    q1_agg_destroy_optimized(agg_state);

    if (result < 0) {
        printf("Error during scan: %d\n", result);
        return result;
    }

    return (int32_t)total_rows_aggregated;
}
