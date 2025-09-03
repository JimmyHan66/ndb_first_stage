#include "../include/ndb_agg_state.h"
#include "abi.h"
#include "avx2_double_simd_sum.h"
#include "pdqsort.h"
#include "xxhash.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <immintrin.h>

// 从q1_onebatch_256_qsortfull.c复制的辅助函数
static inline uint64_t compute_combined_hash(char returnflag, char linestatus) {
  char input[2] = {returnflag, linestatus};
  return XXH3_64bits(input, 2);
}

static inline char extract_first_char_from_utf8(struct ArrowArray *array,
                                                int64_t row_index) {
  if (!array || !array->buffers[1] || !array->buffers[2]) {
    return '?';
  }

  int32_t *offsets = (int32_t *)array->buffers[1];
  uint8_t *string_data = (uint8_t *)array->buffers[2];

  if (row_index >= array->length) {
    return '?';
  }

  int32_t start_offset = offsets[row_index];
  int32_t end_offset = offsets[row_index + 1];

  if (end_offset <= start_offset) {
    return '?';
  }

  return (char)string_data[start_offset];
}

static void init_hash_entry(Q1HashEntry *entry, char returnflag,
                            char linestatus, uint64_t hash_key) {
  entry->returnflag = returnflag;
  entry->linestatus = linestatus;
  entry->hash_key = hash_key;
  entry->count_order = 0;

  // 初始化AVX2缓冲区
  entry->sum_qty_buffer = avx2_double_sum_create(512);
  entry->sum_base_price_buffer = avx2_double_sum_create(512);
  entry->sum_disc_price_buffer = avx2_double_sum_create(512);
  entry->sum_charge_buffer = avx2_double_sum_create(512);
  entry->sum_discount_buffer = avx2_double_sum_create(512);

  // 初始化聚合值
  entry->sum_qty = 0.0;
  entry->sum_base_price = 0.0;
  entry->sum_disc_price = 0.0;
  entry->sum_charge = 0.0;
  entry->sum_discount = 0.0;
}

static void finalize_hash_entry(Q1HashEntry *entry) {
  entry->sum_qty = avx2_double_sum_get_result(entry->sum_qty_buffer);
  avx2_double_sum_destroy(entry->sum_qty_buffer);
  entry->sum_qty_buffer = NULL;

  entry->sum_base_price = avx2_double_sum_get_result(entry->sum_base_price_buffer);
  avx2_double_sum_destroy(entry->sum_base_price_buffer);
  entry->sum_base_price_buffer = NULL;

  entry->sum_disc_price = avx2_double_sum_get_result(entry->sum_disc_price_buffer);
  avx2_double_sum_destroy(entry->sum_disc_price_buffer);
  entry->sum_disc_price_buffer = NULL;

  entry->sum_charge = avx2_double_sum_get_result(entry->sum_charge_buffer);
  avx2_double_sum_destroy(entry->sum_charge_buffer);
  entry->sum_charge_buffer = NULL;

  entry->sum_discount = avx2_double_sum_get_result(entry->sum_discount_buffer);
  avx2_double_sum_destroy(entry->sum_discount_buffer);
  entry->sum_discount_buffer = NULL;
}

static int compare_hash_entry(const void *a, const void *b) {
  const Q1HashEntry *entry_a = (const Q1HashEntry *)a;
  const Q1HashEntry *entry_b = (const Q1HashEntry *)b;

  if (entry_a->returnflag < entry_b->returnflag) {
    return -1;
  } else if (entry_a->returnflag > entry_b->returnflag) {
    return 1;
  }

  if (entry_a->linestatus < entry_b->linestatus) {
    return -1;
  } else if (entry_a->linestatus > entry_b->linestatus) {
    return 1;
  }

  return 0;
}

// Q1 增量聚合实现
Q1AggregationState* q1_agg_init(void) {
    Q1AggregationState *state = (Q1AggregationState*)malloc(sizeof(Q1AggregationState));
    if (state) {
        memset(&state->hash_table, 0, sizeof(Q1HashTable));
        state->finalized = false;
    }
    return state;
}

void q1_agg_process_batch(Q1AggregationState *state, struct ArrowArray *arr,
                         const int32_t *sel_indices, int32_t sel_count) {
    if (state->finalized) {
        return; // 已经finalize，不再处理新数据
    }

    int returnflag_col = 1, linestatus_col = 2;
    int quantity_col = 3, price_col = 4, discount_col = 5, tax_col = 6;

    // 处理每一行
    for (int32_t i = 0; i < sel_count; i++) {
        int64_t row = sel_indices[i];

        // 提取分组键
        char returnflag = extract_first_char_from_utf8(arr->children[returnflag_col], row);
        char linestatus = extract_first_char_from_utf8(arr->children[linestatus_col], row);

        // 计算哈希
        uint64_t hash_key = compute_combined_hash(returnflag, linestatus);

        // 在哈希表中查找或创建条目
        Q1HashEntry *entry = NULL;
        for (int k = 0; k < state->hash_table.entry_count; k++) {
            if (state->hash_table.entries[k].hash_key == hash_key) {
                entry = &state->hash_table.entries[k];
                break;
            }
        }

        if (!entry) {
            entry = &state->hash_table.entries[state->hash_table.entry_count++];
            init_hash_entry(entry, returnflag, linestatus, hash_key);
        }

        // 提取数值并聚合
        double quantity = 0, price = 0, discount = 0, tax = 0;

        // 提取quantity
        if (arr->children[quantity_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[quantity_col]->buffers[1];
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
            quantity = (double)value * 0.01;
        }

        // 提取price
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
            price = (double)value * 0.01;
        }

        // 提取discount
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
            discount = (double)value * 0.01;
        }

        // 提取tax
        if (arr->children[tax_col]->buffers[1]) {
            uint8_t *data = (uint8_t *)arr->children[tax_col]->buffers[1];
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
            tax = (double)value * 0.01;
        }

        // 计算派生值并聚合
        double disc_price = price * (1 - discount);
        double charge = disc_price * (1 + tax);

        entry->count_order++;
        avx2_double_sum_add(entry->sum_qty_buffer, quantity);
        avx2_double_sum_add(entry->sum_base_price_buffer, price);
        avx2_double_sum_add(entry->sum_disc_price_buffer, disc_price);
        avx2_double_sum_add(entry->sum_charge_buffer, charge);
        avx2_double_sum_add(entry->sum_discount_buffer, discount);
    }
}

void q1_agg_finalize(Q1AggregationState *state) {
    if (state->finalized) {
        return; // 已经finalize过了
    }

    // 获取最终结果
    for (int i = 0; i < state->hash_table.entry_count; i++) {
        finalize_hash_entry(&state->hash_table.entries[i]);
    }

    // 使用 pdqsort 进行排序
    pdqsort(state->hash_table.entries, state->hash_table.entry_count,
            sizeof(Q1HashEntry), compare_hash_entry);

    // 输出结果
    printf("\n=== Aggregation Results ===\n");
    printf("%-15s %-15s %-8s %-15s %-15s %-15s %-15s %-15s %-15s\n",
           "l_returnflag", "l_linestatus", "count", "sum_qty", "sum_price",
           "sum_disc_price", "sum_charge", "avg_qty", "avg_disc");

    for (int i = 0; i < state->hash_table.entry_count; i++) {
        Q1HashEntry *entry = &state->hash_table.entries[i];
        double avg_qty = entry->sum_qty / entry->count_order;
        double avg_disc = entry->sum_discount / entry->count_order;

        printf("%-15c %-15c %-8lld %-15.2f %-15.2f %-15.2f %-15.2f %-15.2f "
               "%-15.2f\n",
               entry->returnflag, entry->linestatus, entry->count_order,
               entry->sum_qty, entry->sum_base_price, entry->sum_disc_price,
               entry->sum_charge, avg_qty, avg_disc);
    }
    printf("===========================\n");

    state->finalized = true;
}

void q1_agg_destroy(Q1AggregationState *state) {
    if (state) {
        // 如果还没有finalize，先清理缓冲区
        if (!state->finalized) {
            for (int i = 0; i < state->hash_table.entry_count; i++) {
                Q1HashEntry *entry = &state->hash_table.entries[i];
                if (entry->sum_qty_buffer) avx2_double_sum_destroy(entry->sum_qty_buffer);
                if (entry->sum_base_price_buffer) avx2_double_sum_destroy(entry->sum_base_price_buffer);
                if (entry->sum_disc_price_buffer) avx2_double_sum_destroy(entry->sum_disc_price_buffer);
                if (entry->sum_charge_buffer) avx2_double_sum_destroy(entry->sum_charge_buffer);
                if (entry->sum_discount_buffer) avx2_double_sum_destroy(entry->sum_discount_buffer);
            }
        }
        free(state);
    }
}
