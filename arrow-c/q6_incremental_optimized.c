#include "../include/ndb_agg_state.h"
#include "abi.h"
#include "avx2_double_simd_sum.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Q6 优化列索引映射 (4列)：
// l_quantity=0, l_extendedprice=1, l_discount=2, l_shipdate=3

// Q6 增量聚合实现 - 优化列版本
Q6AggregationState* q6_agg_init_optimized(void) {
    Q6AggregationState *state = (Q6AggregationState*)malloc(sizeof(Q6AggregationState));
    if (state) {
        state->sum_revenue = avx2_double_sum_create(512);
    }
    return state;
}

void q6_agg_process_batch_optimized(Q6AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count) {
    // Q6 优化列索引 (4列)
    int quantity_col = 0, price_col = 1, discount_col = 2;  // l_shipdate=3 (聚合不需要)

    // 只处理sel_indices中的行
    for (int32_t i = 0; i < sel_count; i++) {
        int64_t row = sel_indices[i];  // 通过SelVec索引访问

        // 提取 l_extendedprice
        double price = 0;
        double discount = 0;
        if (arr->children[price_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[price_col]->buffers[1];
            uint8_t *decimal_bytes = data + (row * 16);

            __int128 value = 0;
            for (int j = 0; j < 16; j++) {
                value |= ((__int128)decimal_bytes[j]) << (j * 8);
            }

            if (decimal_bytes[15] & 0x80) {
                for (int j = 16; j < sizeof(__int128); j++) {
                    value |= ((__int128)0xFF) << (j * 8);
                }
            }

            price = (double)value / 100.0;
        }

        // 提取 l_discount
        if (arr->children[discount_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[discount_col]->buffers[1];
            uint8_t *decimal_bytes = data + (row * 16);

            __int128 value = 0;
            for (int j = 0; j < 16; j++) {
                value |= ((__int128)decimal_bytes[j]) << (j * 8);
            }

            if (decimal_bytes[15] & 0x80) {
                for (int j = 16; j < sizeof(__int128); j++) {
                    value |= ((__int128)0xFF) << (j * 8);
                }
            }

            discount = (double)value / 100.0;
        }
        avx2_double_sum_add(state->sum_revenue, price * discount);
    }
}

void q6_agg_finalize_optimized(Q6AggregationState *state) {
    double revenue = avx2_double_sum_get_result(state->sum_revenue);

    printf("\n=== Q6 Optimized Results ===\n");
    printf("  sum_revenue: %.2f\n", revenue);
    printf("=============================\n");
}

void q6_agg_destroy_optimized(Q6AggregationState *state) {
    if (state) {
        if (state->sum_revenue) {
            avx2_double_sum_destroy(state->sum_revenue);
        }
        free(state);
    }
}
