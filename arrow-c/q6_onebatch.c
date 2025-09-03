#include "abi.h"
#include "avx2_double_simd_sum.h"
#include "xxhash.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

// 实现 HashAggregate 操作
void q6_sum(struct ArrowArray *arr, struct ArrowSchema *schema) {
    int price_col = 3, discount_col = 2;  // l_extendedprice是第3列，l_discount是第2列
    AVX2DoubleSumBuffer* sum_revenue = avx2_double_sum_create(512);
    // 处理每一行
    for (int64_t row = 0; row < arr->length; row++) {
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
            // 使用AVX2缓冲区累加
        }
        avx2_double_sum_add(sum_revenue, price*discount);
    }
    double revenue = avx2_double_sum_get_result(sum_revenue);
    avx2_double_sum_destroy(sum_revenue);

    printf("\n=====================\n");
    printf("  sum_revenue: %.2f\n", revenue);
    printf("=====================\n");

    if (arr->release) {
        arr->release(arr);
        arr = NULL;
    }

    if (schema->release) {
        schema->release(schema);
        schema = NULL;
    }
}

// 新增函数：支持SelVec过滤的Q6聚合
void q6_sum_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                    const int32_t *sel_indices, int32_t sel_count) {
    int price_col = 3, discount_col = 2;  // l_extendedprice是第3列，l_discount是第2列
    AVX2DoubleSumBuffer* sum_revenue = avx2_double_sum_create(512);

    // 只处理sel_indices中的行
    for (int32_t i = 0; i < sel_count; i++) {
        int64_t row = sel_indices[i];  // 通过SelVec索引访问

        // 提取 l_extendedprice
        double price = 0;
        double discount = 0;
        if (arr->children[price_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[price_col]->buffers[1];
            uint8_t *decimal_bytes = data + (row * 16);  // 使用过滤后的row

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
        avx2_double_sum_add(sum_revenue, price*discount);
    }

    double revenue = avx2_double_sum_get_result(sum_revenue);
    avx2_double_sum_destroy(sum_revenue);

    printf("\n=====================\n");
    printf("  sum_revenue: %.2f\n", revenue);
    printf("=====================\n");

    // 注意：不释放arr和schema，因为调用者可能还需要使用
}
