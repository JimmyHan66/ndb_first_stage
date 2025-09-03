#include "../common/ndb_types.h"
#include "../../include/ndb_scan_runtime.h"
#include "../../include/ndb_arrow_batch.h"
#include "../../include/ndb_arrow_column.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// scan_filter_q6 完整 JIT 流水线
// 功能：扫描 + Q6 多级过滤（不做聚合）
// 输入：ScanHandle*
// 输出：过滤后的总行数
int32_t scan_filter_q6_pipeline_jit(ScanHandle *scan_handle) {
    if (!scan_handle) {
        return -1;
    }

    // Q6 过滤条件常量
    const int32_t shipdate_ge_threshold = 8766; // 1994-01-01
    const int32_t shipdate_lt_threshold = 9131; // 1995-01-01
    const int64_t discount_low = 5;             // 0.05 * 100
    const int64_t discount_high = 7;            // 0.07 * 100
    const int64_t quantity_threshold = 2400;    // 24 * 100

    // 声明过滤函数
    extern int32_t filter_ge_date32(const SimpleColumnView *col,
                                    int32_t threshold, uint32_t *output_idx);
    extern int32_t filter_lt_date32_on_sel(const uint32_t *input_sel, int32_t input_count,
                                           const SimpleColumnView *col, int32_t threshold,
                                           uint32_t *output_idx);
    extern int32_t filter_between_i64_on_sel(const uint32_t *input_sel, int32_t input_count,
                                             const SimpleColumnView *col, int64_t low, int64_t high,
                                             uint32_t *output_idx);
    extern int32_t filter_lt_i64_on_sel(const uint32_t *input_sel, int32_t input_count,
                                        const SimpleColumnView *col, int64_t threshold,
                                        uint32_t *output_idx);

    ArrowBatch arrow_batch;
    ndb_arrow_batch_init(&arrow_batch);

    int64_t total_rows_scanned = 0;
    int64_t total_rows_filtered = 0;
    int32_t batch_count = 0;
    int32_t result;

    printf("=== scan_filter_q6 JIT Pipeline ===\n");

    // ========== 主 Scan 循环 ==========
    while ((result = rt_scan_next(scan_handle, &arrow_batch)) > 0) {
        batch_count++;
        total_rows_scanned += arrow_batch.num_rows;

        if (arrow_batch.num_rows == 0) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 获取需要的列 (Q6优化列集合索引)
        ArrowColumnView arrow_shipdate_col, arrow_discount_col, arrow_quantity_col;
        if (ndb_get_arrow_column(&arrow_batch, 3, &arrow_shipdate_col) != 0 ||
            ndb_get_arrow_column(&arrow_batch, 2, &arrow_discount_col) != 0 ||
            ndb_get_arrow_column(&arrow_batch, 0, &arrow_quantity_col) != 0) {
            printf("Failed to get required columns in batch %d\n", batch_count);
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 转换为 SimpleBatch 格式
        SimpleColumnView simple_shipdate_col, simple_discount_col, simple_quantity_col;

        simple_shipdate_col.values = (const int32_t*)arrow_shipdate_col.values;
        simple_shipdate_col.validity = arrow_shipdate_col.validity;
        simple_shipdate_col.length = arrow_shipdate_col.length;
        simple_shipdate_col.offset = arrow_shipdate_col.offset;
        simple_shipdate_col.arrow_type_id = arrow_shipdate_col.arrow_type_id;

        simple_discount_col.values = (const int32_t*)arrow_discount_col.values;
        simple_discount_col.validity = arrow_discount_col.validity;
        simple_discount_col.length = arrow_discount_col.length;
        simple_discount_col.offset = arrow_discount_col.offset;
        simple_discount_col.arrow_type_id = arrow_discount_col.arrow_type_id;

        simple_quantity_col.values = (const int32_t*)arrow_quantity_col.values;
        simple_quantity_col.validity = arrow_quantity_col.validity;
        simple_quantity_col.length = arrow_quantity_col.length;
        simple_quantity_col.offset = arrow_quantity_col.offset;
        simple_quantity_col.arrow_type_id = arrow_quantity_col.arrow_type_id;

        // 分配过滤缓冲区
        uint32_t *final_output = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));
        uint32_t *temp_buffer1 = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));
        uint32_t *temp_buffer2 = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));
        uint32_t *temp_buffer3 = (uint32_t*)malloc(arrow_batch.num_rows * sizeof(uint32_t));

        if (!final_output || !temp_buffer1 || !temp_buffer2 || !temp_buffer3) {
            free(final_output);
            free(temp_buffer1);
            free(temp_buffer2);
            free(temp_buffer3);
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // ========== JIT Q6 多级过滤执行 ==========

        // Filter 1: l_shipdate >= '1994-01-01'
        int32_t count1 = filter_ge_date32(&simple_shipdate_col, shipdate_ge_threshold, temp_buffer1);

        int32_t final_filtered_count = 0;
        if (count1 > 0) {
            // Filter 2: l_shipdate < '1995-01-01' (链式过滤)
            int32_t count2 = filter_lt_date32_on_sel(temp_buffer1, count1, &simple_shipdate_col,
                                                     shipdate_lt_threshold, temp_buffer2);
            if (count2 > 0) {
                // Filter 3: l_discount BETWEEN 0.05 AND 0.07 (链式过滤)
                int32_t count3 = filter_between_i64_on_sel(temp_buffer2, count2, &simple_discount_col,
                                                           discount_low, discount_high, temp_buffer3);
                if (count3 > 0) {
                    // Filter 4: l_quantity < 24 (链式过滤，输出到final_output)
                    final_filtered_count = filter_lt_i64_on_sel(temp_buffer3, count3, &simple_quantity_col,
                                                                quantity_threshold, final_output);
                }
            }
        }

        if (final_filtered_count >= 0) {
            total_rows_filtered += final_filtered_count;

            if (batch_count % 100 == 0) {
                printf("Batch %d: %lld rows -> %d filtered (%.4f%%)\n",
                       batch_count, arrow_batch.num_rows, final_filtered_count,
                       100.0 * final_filtered_count / arrow_batch.num_rows);
            }
        }

        // 清理当前批次
        free(final_output);
        free(temp_buffer1);
        free(temp_buffer2);
        free(temp_buffer3);
        ndb_arrow_batch_cleanup(&arrow_batch);
    }

    // ========== 最终结果输出 ==========
    printf("\n=== scan_filter_q6 Results ===\n");
    printf("Total batches: %d\n", batch_count);
    printf("Total rows scanned: %lld\n", total_rows_scanned);
    printf("Total rows filtered: %lld\n", total_rows_filtered);
    printf("Overall selectivity: %.4f%%\n",
           total_rows_scanned > 0 ? (100.0 * total_rows_filtered / total_rows_scanned) : 0.0);

    if (result < 0) {
        printf("Error during scan: %d\n", result);
        return result;
    }

    return (int32_t)total_rows_filtered;
}
