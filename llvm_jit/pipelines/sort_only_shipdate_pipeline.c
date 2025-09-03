#include "../common/ndb_types.h"
#include "../../include/ndb_scan_runtime.h"
#include "../../include/ndb_arrow_batch.h"
#include "../../include/ndb_arrow_column.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

// 排序专用的数据结构
typedef struct {
    int32_t shipdate_value;
    uint32_t original_index;
    int32_t batch_id;  // 跨 batch 的全局索引需要 batch 信息
} ShipdateRowGlobal;

// 排序比较函数
static int compare_shipdate_rows_global(const void *a, const void *b) {
    const ShipdateRowGlobal *row_a = (const ShipdateRowGlobal *)a;
    const ShipdateRowGlobal *row_b = (const ShipdateRowGlobal *)b;

    if (row_a->shipdate_value < row_b->shipdate_value) {
        return -1;
    } else if (row_a->shipdate_value > row_b->shipdate_value) {
        return 1;
    }
    return 0;
}

// 声明 pdqsort 函数
extern void pdqsort(void *base, size_t nmemb, size_t size,
                    int (*compar)(const void *, const void *));

// sort_only_shipdate 完整 JIT 流水线
// 功能：扫描 + 提取 l_shipdate + 全局排序
// 输入：ScanHandle*
// 输出：排序处理的总行数
int32_t sort_only_shipdate_pipeline_jit(ScanHandle *scan_handle) {
    if (!scan_handle) {
        return -1;
    }

    ArrowBatch arrow_batch;
    ndb_arrow_batch_init(&arrow_batch);

    // 用于收集所有 batch 的 shipdate 数据
    ShipdateRowGlobal *global_sort_array = NULL;
    int64_t total_rows_collected = 0;
    int64_t array_capacity = 0;
    int32_t batch_count = 0;
    int32_t result;

    printf("=== sort_only_shipdate JIT Pipeline ===\n");

    // ========== 第一阶段：收集所有数据 ==========
    while ((result = rt_scan_next(scan_handle, &arrow_batch)) > 0) {
        batch_count++;

        if (arrow_batch.num_rows == 0) {
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 获取 l_shipdate 列 (Sort优化列集合中的第0列)
        ArrowColumnView arrow_shipdate_col;
        if (ndb_get_arrow_column(&arrow_batch, 0, &arrow_shipdate_col) != 0) {
            printf("Failed to get shipdate column in batch %d\n", batch_count);
            ndb_arrow_batch_cleanup(&arrow_batch);
            continue;
        }

        // 扩展全局数组容量
        int64_t new_total = total_rows_collected + arrow_batch.num_rows;
        if (new_total > array_capacity) {
            array_capacity = new_total * 2;  // 预留空间
            global_sort_array = (ShipdateRowGlobal*)realloc(global_sort_array,
                                                            array_capacity * sizeof(ShipdateRowGlobal));
            if (!global_sort_array) {
                printf("Failed to allocate memory for global sort array\n");
                ndb_arrow_batch_cleanup(&arrow_batch);
                return -1;
            }
        }

        // ========== JIT 化的数据提取和转换 ==========
        const int32_t *shipdate_values = (const int32_t*)arrow_shipdate_col.values;
        const uint8_t *validity = arrow_shipdate_col.validity;

        for (int64_t i = 0; i < arrow_batch.num_rows; i++) {
            int64_t actual_idx = arrow_shipdate_col.offset + i;

            // JIT 化的 NULL 检查
            bool is_null = false;
            if (validity) {
                int64_t bit_idx = actual_idx;
                int64_t byte_idx = bit_idx / 8;
                int64_t bit_offset = bit_idx % 8;
                is_null = !(validity[byte_idx] & (1 << bit_offset));
            }

            // 填充全局排序数组
            ShipdateRowGlobal *global_row = &global_sort_array[total_rows_collected];
            if (!is_null) {
                global_row->shipdate_value = shipdate_values[actual_idx];
            } else {
                global_row->shipdate_value = INT32_MAX;  // NULL 排到最后
            }
            global_row->original_index = (uint32_t)i;
            global_row->batch_id = batch_count;

            total_rows_collected++;
        }

        if (batch_count % 100 == 0) {
            printf("Collected batch %d: %lld rows (total: %lld)\n",
                   batch_count, arrow_batch.num_rows, total_rows_collected);
        }

        // 清理当前批次
        ndb_arrow_batch_cleanup(&arrow_batch);
    }

    // ========== 第二阶段：全局排序 ==========
    if (total_rows_collected > 0 && global_sort_array) {
        printf("\nSorting %lld rows globally...\n", total_rows_collected);

        // JIT 化的 pdqsort 调用
        pdqsort(global_sort_array, total_rows_collected, sizeof(ShipdateRowGlobal),
                compare_shipdate_rows_global);

        printf("Global sorting completed!\n");

        // 可选：输出前几个和后几个结果进行验证
        printf("First 5 sorted dates: ");
        for (int i = 0; i < 5 && i < total_rows_collected; i++) {
            if (global_sort_array[i].shipdate_value != INT32_MAX) {
                printf("%d ", global_sort_array[i].shipdate_value);
            } else {
                printf("NULL ");
            }
        }
        printf("\n");
    }

    // ========== 最终结果输出 ==========
    printf("\n=== sort_only_shipdate Results ===\n");
    printf("Total batches: %d\n", batch_count);
    printf("Total rows collected: %lld\n", total_rows_collected);
    printf("Total rows sorted: %lld\n", total_rows_collected);

    // 清理全局排序数组
    free(global_sort_array);

    if (result < 0) {
        printf("Error during scan: %d\n", result);
        return result;
    }

    return (int32_t)total_rows_collected;
}
