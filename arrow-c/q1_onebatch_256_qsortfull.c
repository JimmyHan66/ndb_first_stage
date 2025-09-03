#include "abi.h"
#include "avx2_double_simd_sum.h"
#include "pdqsort.h"
#include "xxhash.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// HashAggregate 结构
#define HASH_TABLE_SIZE 1024

static inline void vectorized_compound_calc_4(const double *prices,
                                              const double *discounts,
                                              const double *taxes,
                                              double *disc_prices,
                                              double *charges) {

  __m256d price_vec = _mm256_loadu_pd(prices);
  __m256d discount_vec = _mm256_loadu_pd(discounts);
  __m256d tax_vec = _mm256_loadu_pd(taxes);

  // 计算 (1 - discount)
  __m256d one = _mm256_set1_pd(1.0);
  __m256d one_minus_discount = _mm256_sub_pd(one, discount_vec);

  // 计算 disc_price = price * (1 - discount)
  __m256d disc_price_vec = _mm256_mul_pd(price_vec, one_minus_discount);

  // 计算 (1 + tax)
  __m256d one_plus_tax = _mm256_add_pd(one, tax_vec);

  // 计算 charge = price * (1 - discount) * (1 + tax)
  __m256d charge_vec = _mm256_mul_pd(disc_price_vec, one_plus_tax);

  // 存储结果
  _mm256_storeu_pd(disc_prices, disc_price_vec);
  _mm256_storeu_pd(charges, charge_vec);
}

typedef struct {
  char returnflag;     // l_returnflag (1 byte)
  char linestatus;     // l_linestatus (1 byte)
  uint64_t hash_key;   // 64-bit hash key
  int64_t count_order; // count(*) - 订单计数

  // 使用AVX2缓冲区进行高效求和
  AVX2DoubleSumBuffer *sum_qty_buffer;        // sum(l_quantity)
  AVX2DoubleSumBuffer *sum_base_price_buffer; // sum(l_extendedprice)
  AVX2DoubleSumBuffer
      *sum_disc_price_buffer; // sum(l_extendedprice * (1 - l_discount))
  AVX2DoubleSumBuffer *sum_charge_buffer;   // sum(l_extendedprice * (1 -
                                            // l_discount) * (1 + l_tax))
  AVX2DoubleSumBuffer *sum_discount_buffer; // sum(l_discount)

  // 最终聚合结果
  double sum_qty;        // 数量总和
  double sum_base_price; // 基础价格总和
  double sum_disc_price; // 折扣后价格总和
  double sum_charge;     // 最终费用总和
  double sum_discount;   // 折扣总和（用于计算平均值）
} HashEntry;

typedef struct {
  HashEntry entries[HASH_TABLE_SIZE];
  int entry_count;
} HashTable;

// 批量提取decimal值的优化函数
static inline void extract_decimal_batch_4(uint8_t *data_base,
                                           int64_t start_row, double *output,
                                           double scale_factor) {

  for (int i = 0; i < 4; i++) {
    uint8_t *decimal_bytes = data_base + ((start_row + i) * 16);

    __int128 value = 0;
    for (int j = 0; j < 16; j++) {
      value |= ((__int128)decimal_bytes[j]) << (j * 8);
    }

    if (decimal_bytes[15] & 0x80) {
      for (int j = 16; j < sizeof(__int128); j++) {
        value |= ((__int128)0xFF) << (j * 8);
      }
    }

    output[i] = (double)value * scale_factor;
  }
}

// 批量处理SIMD优化的聚合函数
static inline void process_batch_simd(HashEntry *entry,
                                      const double *quantities,
                                      const double *prices,
                                      const double *discounts,
                                      const double *taxes, int count) {

  // 批量添加数量和基础价格
  avx2_double_sum_add_batch(entry->sum_qty_buffer, quantities, count);
  avx2_double_sum_add_batch(entry->sum_base_price_buffer, prices, count);
  avx2_double_sum_add_batch(entry->sum_discount_buffer, discounts, count);

  // 使用SIMD向量化计算复合值
  for (int i = 0; i < count; i += 4) {
    double disc_prices[4], charges[4];
    int batch_size = (count - i >= 4) ? 4 : (count - i);

    if (batch_size == 4) {
      // 使用完整的4元素SIMD计算
      vectorized_compound_calc_4(prices + i, discounts + i, taxes + i,
                                 disc_prices, charges);

      // 批量添加到AVX2缓冲区
      avx2_double_sum_add_batch(entry->sum_disc_price_buffer, disc_prices, 4);
      avx2_double_sum_add_batch(entry->sum_charge_buffer, charges, 4);
    } else {
      // 处理剩余的元素
      for (int j = 0; j < batch_size; j++) {
        double disc_price = prices[i + j] * (1.0 - discounts[i + j]);
        double charge =
            prices[i + j] * (1.0 - discounts[i + j]) * (1.0 + taxes[i + j]);

        avx2_double_sum_add(entry->sum_disc_price_buffer, disc_price);
        avx2_double_sum_add(entry->sum_charge_buffer, charge);
      }
    }
  }
}

// 使用 xxHash 的哈希函数
static inline uint64_t simple_hash(char returnflag, char linestatus) {
  // 创建输入数据：将两个字符组合成一个短字符串
  char input[2] = {returnflag, linestatus};

  // 使用 XXH3_64bits 计算哈希值
  return XXH3_64bits(input, 2);
}

// 初始化哈希条目的AVX2缓冲区
static inline void init_hash_entry(HashEntry *entry, char returnflag,
                                   char linestatus) {
  entry->returnflag = returnflag;
  entry->linestatus = linestatus;
  entry->hash_key = simple_hash(returnflag, linestatus);
  entry->count_order = 0;

  // 创建AVX2缓冲区，每个缓冲区初始容量为64，有助于批处理
  entry->sum_qty_buffer = avx2_double_sum_create(64);
  entry->sum_base_price_buffer = avx2_double_sum_create(64);
  entry->sum_disc_price_buffer = avx2_double_sum_create(64);
  entry->sum_charge_buffer = avx2_double_sum_create(64);
  entry->sum_discount_buffer = avx2_double_sum_create(64);

  // 初始化最终结果
  entry->sum_qty = 0.0;
  entry->sum_base_price = 0.0;
  entry->sum_disc_price = 0.0;
  entry->sum_charge = 0.0;
  entry->sum_discount = 0.0;
}

// 销毁哈希条目的AVX2缓冲区并计算最终结果
static inline void finalize_hash_entry(HashEntry *entry) {
  // if (entry->sum_qty_buffer) {
  entry->sum_qty = avx2_double_sum_get_result(entry->sum_qty_buffer);
  avx2_double_sum_destroy(entry->sum_qty_buffer);
  entry->sum_qty_buffer = NULL;
  // }

  // if (entry->sum_base_price_buffer) {
  entry->sum_base_price =
      avx2_double_sum_get_result(entry->sum_base_price_buffer);
  avx2_double_sum_destroy(entry->sum_base_price_buffer);
  entry->sum_base_price_buffer = NULL;
  // }

  // if (entry->sum_disc_price_buffer) {
  entry->sum_disc_price =
      avx2_double_sum_get_result(entry->sum_disc_price_buffer);
  avx2_double_sum_destroy(entry->sum_disc_price_buffer);
  entry->sum_disc_price_buffer = NULL;
  // }

  // if (entry->sum_charge_buffer) {
  entry->sum_charge = avx2_double_sum_get_result(entry->sum_charge_buffer);
  avx2_double_sum_destroy(entry->sum_charge_buffer);
  entry->sum_charge_buffer = NULL;
  // }

  // if (entry->sum_discount_buffer) {
  entry->sum_discount = avx2_double_sum_get_result(entry->sum_discount_buffer);
  avx2_double_sum_destroy(entry->sum_discount_buffer);
  entry->sum_discount_buffer = NULL;
  // }
}

// 比较函数：用于pdqsort对HashEntry进行排序
// 先按 returnflag，再按 linestatus 排序
static int compare_hash_entry(const void *a, const void *b) {
  const HashEntry *entry_a = (const HashEntry *)a;
  const HashEntry *entry_b = (const HashEntry *)b;

  // 先比较 returnflag
  if (entry_a->returnflag < entry_b->returnflag) {
    return -1;
  } else if (entry_a->returnflag > entry_b->returnflag) {
    return 1;
  }

  // returnflag 相等，比较 linestatus
  if (entry_a->linestatus < entry_b->linestatus) {
    return -1;
  } else if (entry_a->linestatus > entry_b->linestatus) {
    return 1;
  }

  return 0; // 完全相等
}

// 从 Utf8 数组中提取字符串的第一个字符
static inline char extract_first_char_from_utf8(struct ArrowArray *array,
                                                int64_t row_index) {
  if (!array || !array->buffers[1] || !array->buffers[2]) {
    return '?';
  }

  // Utf8 格式：buffers[1] 是偏移数组，buffers[2] 是字符串数据
  int32_t *offsets = (int32_t *)array->buffers[1];
  uint8_t *string_data = (uint8_t *)array->buffers[2];

  if (row_index >= array->length) {
    return '?';
  }

  // 获取字符串的开始和结束偏移
  int32_t start_offset = offsets[row_index];
  int32_t end_offset = offsets[row_index + 1];

  // 检查字符串长度
  if (end_offset <= start_offset) {
    return '?';
  }

  // 返回第一个字符
  return (char)string_data[start_offset];
}

// 实现 HashAggregate 操作
void q1_hash_aggregate(struct ArrowArray *arr, struct ArrowSchema *schema) {
  // if (!arr || !schema) {
  //     printf("Array or Schema is NULL\n");
  //     return;
  // }

  // printf("=== Hash Aggregate Operation ===\n");
  // printf("Processing %lld rows with %lld columns\n",
  //        (long long)arr->length, (long long)arr->n_children);

  // 初始化哈希表
  HashTable hash_table;
  memset(&hash_table, 0, sizeof(HashTable));

  int returnflag_col = 1, linestatus_col = 2;
  int quantity_col = 3, price_col = 4, discount_col = 5, tax_col = 6;

  // 找到需要的列的索引
  // int returnflag_col = -1, linestatus_col = -1;
  // int quantity_col = -1, price_col = -1, discount_col = -1, tax_col = -1;

  // for (int64_t col = 0; col < schema->n_children; col++) {
  //     const char *name = schema->children[col]->name;
  //     if (name) {
  //         if (strcmp(name, "l_returnflag") == 0) {
  //             returnflag_col = col;
  //             printf("Found l_returnflag at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         } else if (strcmp(name, "l_linestatus") == 0) {
  //             linestatus_col = col;
  //             printf("Found l_linestatus at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         } else if (strcmp(name, "l_quantity") == 0) {
  //             quantity_col = col;
  //             printf("Found l_quantity at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         } else if (strcmp(name, "l_extendedprice") == 0) {
  //             price_col = col;
  //             printf("Found l_extendedprice at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         } else if (strcmp(name, "l_discount") == 0) {
  //             discount_col = col;
  //             printf("Found l_discount at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         } else if (strcmp(name, "l_tax") == 0) {
  //             tax_col = col;
  //             printf("Found l_tax at column %d (format: %s)\n",
  //                    (int)col, schema->children[col]->format);
  //         }
  //     }
  // }

  // if (returnflag_col == -1 || linestatus_col == -1) {
  //     printf("ERROR: Could not find required columns l_returnflag or
  //     l_linestatus\n"); return;
  // }

  // printf("\nProcessing rows for aggregation...\n");

  // 批量处理配置
  const int BATCH_SIZE = 8; // 每批处理8行，支持2个4元素SIMD操作
  double batch_quantities[BATCH_SIZE], batch_prices[BATCH_SIZE];
  double batch_discounts[BATCH_SIZE], batch_taxes[BATCH_SIZE];
  char batch_returnflags[BATCH_SIZE], batch_linestatuses[BATCH_SIZE];

  // 处理每一行 - 改为批量处理
  for (int64_t row = 0; row < arr->length; row += BATCH_SIZE) {
    int current_batch_size =
        (arr->length - row >= BATCH_SIZE) ? BATCH_SIZE : (arr->length - row);

    // 批量提取分组键
    for (int i = 0; i < current_batch_size; i++) {
      batch_returnflags[i] =
          extract_first_char_from_utf8(arr->children[returnflag_col], row + i);
      batch_linestatuses[i] =
          extract_first_char_from_utf8(arr->children[linestatus_col], row + i);
    }

    // 批量提取数值列 - 使用优化的decimal提取函数
    if (arr->children[quantity_col]->buffers[1]) {
      uint8_t *quantity_data =
          (uint8_t *)arr->children[quantity_col]->buffers[1];
      for (int i = 0; i < current_batch_size; i += 4) {
        int sub_batch =
            (current_batch_size - i >= 4) ? 4 : (current_batch_size - i);
        if (sub_batch == 4) {
          extract_decimal_batch_4(quantity_data, row + i, batch_quantities + i,
                                  0.01);
        } else {
          // 处理剩余元素
          for (int j = 0; j < sub_batch; j++) {
            uint8_t *decimal_bytes = quantity_data + ((row + i + j) * 16);
            __int128 value = 0;
            for (int k = 0; k < 16; k++) {
              value |= ((__int128)decimal_bytes[k]) << (k * 8);
            }
            if (decimal_bytes[15] & 0x80) {
              for (int k = 16; k < sizeof(__int128); k++) {
                value |= ((__int128)0xFF) << (k * 8);
              }
            }
            batch_quantities[i + j] = (double)value * 0.01;
          }
        }
      }
    }

    if (arr->children[price_col]->buffers[1]) {
      uint8_t *price_data = (uint8_t *)arr->children[price_col]->buffers[1];
      for (int i = 0; i < current_batch_size; i += 4) {
        int sub_batch =
            (current_batch_size - i >= 4) ? 4 : (current_batch_size - i);
        if (sub_batch == 4) {
          extract_decimal_batch_4(price_data, row + i, batch_prices + i, 0.01);
        } else {
          for (int j = 0; j < sub_batch; j++) {
            uint8_t *decimal_bytes = price_data + ((row + i + j) * 16);
            __int128 value = 0;
            for (int k = 0; k < 16; k++) {
              value |= ((__int128)decimal_bytes[k]) << (k * 8);
            }
            if (decimal_bytes[15] & 0x80) {
              for (int k = 16; k < sizeof(__int128); k++) {
                value |= ((__int128)0xFF) << (k * 8);
              }
            }
            batch_prices[i + j] = (double)value * 0.01;
          }
        }
      }
    }

    if (arr->children[discount_col]->buffers[1]) {
      uint8_t *discount_data =
          (uint8_t *)arr->children[discount_col]->buffers[1];
      for (int i = 0; i < current_batch_size; i += 4) {
        int sub_batch =
            (current_batch_size - i >= 4) ? 4 : (current_batch_size - i);
        if (sub_batch == 4) {
          extract_decimal_batch_4(discount_data, row + i, batch_discounts + i,
                                  0.01);
        } else {
          for (int j = 0; j < sub_batch; j++) {
            uint8_t *decimal_bytes = discount_data + ((row + i + j) * 16);
            __int128 value = 0;
            for (int k = 0; k < 16; k++) {
              value |= ((__int128)decimal_bytes[k]) << (k * 8);
            }
            if (decimal_bytes[15] & 0x80) {
              for (int k = 16; k < sizeof(__int128); k++) {
                value |= ((__int128)0xFF) << (k * 8);
              }
            }
            batch_discounts[i + j] = (double)value * 0.01;
          }
        }
      }
    }

    if (arr->children[tax_col]->buffers[1]) {
      uint8_t *tax_data = (uint8_t *)arr->children[tax_col]->buffers[1];
      for (int i = 0; i < current_batch_size; i += 4) {
        int sub_batch =
            (current_batch_size - i >= 4) ? 4 : (current_batch_size - i);
        if (sub_batch == 4) {
          extract_decimal_batch_4(tax_data, row + i, batch_taxes + i, 0.01);
        } else {
          for (int j = 0; j < sub_batch; j++) {
            uint8_t *decimal_bytes = tax_data + ((row + i + j) * 16);
            __int128 value = 0;
            for (int k = 0; k < 16; k++) {
              value |= ((__int128)decimal_bytes[k]) << (k * 8);
            }
            if (decimal_bytes[15] & 0x80) {
              for (int k = 16; k < sizeof(__int128); k++) {
                value |= ((__int128)0xFF) << (k * 8);
              }
            }
            batch_taxes[i + j] = (double)value * 0.01;
          }
        }
      }
    }

    // 按分组键组织批次数据并进行聚合
    for (int i = 0; i < current_batch_size; i++) {
      char returnflag = batch_returnflags[i];
      char linestatus = batch_linestatuses[i];

      // 计算哈希键
      uint64_t hash_key = simple_hash(returnflag, linestatus);

      // 在哈希表中查找或创建条目
      HashEntry *entry = NULL;
      for (int j = 0; j < hash_table.entry_count; j++) {
        if (hash_table.entries[j].hash_key == hash_key) {
          entry = &hash_table.entries[j];
          break;
        }
      }

      if (!entry) {
        // 创建新条目并初始化AVX2缓冲区
        entry = &hash_table.entries[hash_table.entry_count];
        init_hash_entry(entry, returnflag, linestatus);
        hash_table.entry_count++;
      }

      if (entry) {
        // 更新聚合值
        entry->count_order++;

        // 使用优化的单元素添加
        avx2_double_sum_add(entry->sum_qty_buffer, batch_quantities[i]);
        avx2_double_sum_add(entry->sum_base_price_buffer, batch_prices[i]);
        avx2_double_sum_add(entry->sum_discount_buffer, batch_discounts[i]);

        // 使用SIMD计算复合值
        double prices[4] = {batch_prices[i], batch_prices[i], batch_prices[i],
                            batch_prices[i]};
        double discounts[4] = {batch_discounts[i], batch_discounts[i],
                               batch_discounts[i], batch_discounts[i]};
        double taxes[4] = {batch_taxes[i], batch_taxes[i], batch_taxes[i],
                           batch_taxes[i]};
        double disc_prices[4], charges[4];

        vectorized_compound_calc_4(prices, discounts, taxes, disc_prices,
                                   charges);

        avx2_double_sum_add(entry->sum_disc_price_buffer, disc_prices[0]);
        avx2_double_sum_add(entry->sum_charge_buffer, charges[0]);
      }
    }
  }

  // 在排序之前，完成所有AVX2缓冲区的计算并获取最终结果
  for (int i = 0; i < hash_table.entry_count; i++) {
    finalize_hash_entry(&hash_table.entries[i]);
  }

  // 使用pdqsort对结果按 l_returnflag, l_linestatus 排序
  pdqsort(hash_table.entries, hash_table.entry_count, sizeof(HashEntry),
          compare_hash_entry);

  // 输出聚合结果
  // printf("\n=== Hash Aggregate Results (TPC-H Query 1) ===\n");
  // printf("Found %d unique groups:\n\n", hash_table.entry_count);

  printf("%-12s %-12s %-12s %-15s %-15s %-15s %-12s %-12s %-12s %-12s %-10s\n",
         "l_returnflag", "l_linestatus", "sum_qty", "sum_base_price",
         "sum_disc_price", "sum_charge", "avg_qty", "avg_price", "avg_disc",
         "count_order", "HashKey");
  printf("%-12s %-12s %-12s %-15s %-15s %-15s %-12s %-12s %-12s %-12s %-10s\n",
         "------------", "------------", "--------", "---------------",
         "---------------", "-----------", "--------", "----------", "--------",
         "----------", "--------");

  for (int i = 0; i < hash_table.entry_count; i++) {
    HashEntry *entry = &hash_table.entries[i];

    // 计算平均值
    // double avg_qty = entry->count_order > 0 ? entry->sum_qty /
    // entry->count_order : 0.0; double avg_price = entry->count_order > 0 ?
    // entry->sum_base_price / entry->count_order : 0.0; double avg_disc =
    // entry->count_order > 0 ? entry->sum_discount / entry->count_order : 0.0;

    double avg_qty = entry->sum_qty / entry->count_order;
    double avg_price = entry->sum_base_price / entry->count_order;
    double avg_disc = entry->sum_discount / entry->count_order;

    printf("%-12c %-12c %-12.2f %-15.2f %-15.2f %-15.2f %-12.2f %-12.2f "
           "%-12.4f %-12ld 0x%-8lX\n",
           entry->returnflag, entry->linestatus, entry->sum_qty,
           entry->sum_base_price, entry->sum_disc_price, entry->sum_charge,
           avg_qty, avg_price, avg_disc, entry->count_order, entry->hash_key);
  }
  if (arr->release) {
    arr->release(arr);
    arr = NULL;
  }

  if (schema->release) {
    schema->release(schema);
    schema = NULL;
  }

  // printf("\n=== End Hash Aggregate ===\n");
}

// 新增函数：支持SelVec过滤的Q1聚合
void q1_hash_aggregate_with_sel(struct ArrowArray *arr, struct ArrowSchema *schema,
                               const int32_t *sel_indices, int32_t sel_count) {
  // 初始化哈希表
  HashTable hash_table;
  memset(&hash_table, 0, sizeof(HashTable));

  int returnflag_col = 1, linestatus_col = 2;
  int quantity_col = 3, price_col = 4, discount_col = 5, tax_col = 6;

  // 批量处理配置
  const int BATCH_SIZE = 8; // 每批处理8行，支持2个4元素SIMD操作
  double batch_quantities[BATCH_SIZE], batch_prices[BATCH_SIZE];
  double batch_discounts[BATCH_SIZE], batch_taxes[BATCH_SIZE];
  char batch_returnflags[BATCH_SIZE], batch_linestatuses[BATCH_SIZE];

  // 只处理sel_indices中指定的行
  for (int32_t i = 0; i < sel_count; i += BATCH_SIZE) {
    int current_batch_size =
        (sel_count - i >= BATCH_SIZE) ? BATCH_SIZE : (sel_count - i);

    // 批量提取分组键 - 使用sel_indices[i+j]而不是row+j
    for (int j = 0; j < current_batch_size; j++) {
      int64_t actual_row = sel_indices[i + j];  // 关键修改点
      batch_returnflags[j] =
          extract_first_char_from_utf8(arr->children[returnflag_col], actual_row);
      batch_linestatuses[j] =
          extract_first_char_from_utf8(arr->children[linestatus_col], actual_row);
    }

    // 批量提取数值列 - 使用优化的decimal提取函数
    if (arr->children[quantity_col]->buffers[1]) {
      uint8_t *quantity_data =
          (uint8_t *)arr->children[quantity_col]->buffers[1];
      for (int j = 0; j < current_batch_size; j++) {
        int64_t actual_row = sel_indices[i + j];
        uint8_t *decimal_bytes = quantity_data + (actual_row * 16);
        __int128 value = 0;
        for (int k = 0; k < 16; k++) {
          value |= ((__int128)decimal_bytes[k]) << (k * 8);
        }
        if (decimal_bytes[15] & 0x80) {
          for (int k = 16; k < sizeof(__int128); k++) {
            value |= ((__int128)0xFF) << (k * 8);
          }
        }
        batch_quantities[j] = (double)value * 0.01;
      }
    }

    // 类似地提取price
    if (arr->children[price_col]->buffers[1]) {
      uint8_t *price_data = (uint8_t *)arr->children[price_col]->buffers[1];
      for (int j = 0; j < current_batch_size; j++) {
        int64_t actual_row = sel_indices[i + j];
        uint8_t *decimal_bytes = price_data + (actual_row * 16);
        __int128 value = 0;
        for (int k = 0; k < 16; k++) {
          value |= ((__int128)decimal_bytes[k]) << (k * 8);
        }
        if (decimal_bytes[15] & 0x80) {
          for (int k = 16; k < sizeof(__int128); k++) {
            value |= ((__int128)0xFF) << (k * 8);
          }
        }
        batch_prices[j] = (double)value * 0.01;
      }
    }

    // 提取discount
    if (arr->children[discount_col]->buffers[1]) {
      uint8_t *discount_data = (uint8_t *)arr->children[discount_col]->buffers[1];
      for (int j = 0; j < current_batch_size; j++) {
        int64_t actual_row = sel_indices[i + j];
        uint8_t *decimal_bytes = discount_data + (actual_row * 16);
        __int128 value = 0;
        for (int k = 0; k < 16; k++) {
          value |= ((__int128)decimal_bytes[k]) << (k * 8);
        }
        if (decimal_bytes[15] & 0x80) {
          for (int k = 16; k < sizeof(__int128); k++) {
            value |= ((__int128)0xFF) << (k * 8);
          }
        }
        batch_discounts[j] = (double)value * 0.01;
      }
    }

    // 提取tax
    if (arr->children[tax_col]->buffers[1]) {
      uint8_t *tax_data = (uint8_t *)arr->children[tax_col]->buffers[1];
      for (int j = 0; j < current_batch_size; j++) {
        int64_t actual_row = sel_indices[i + j];
        uint8_t *decimal_bytes = tax_data + (actual_row * 16);
        __int128 value = 0;
        for (int k = 0; k < 16; k++) {
          value |= ((__int128)decimal_bytes[k]) << (k * 8);
        }
        if (decimal_bytes[15] & 0x80) {
          for (int k = 16; k < sizeof(__int128); k++) {
            value |= ((__int128)0xFF) << (k * 8);
          }
        }
        batch_taxes[j] = (double)value * 0.01;
      }
    }

    // 批量聚合到哈希表
    for (int j = 0; j < current_batch_size; j++) {
      char returnflag = batch_returnflags[j];
      char linestatus = batch_linestatuses[j];

      // 在哈希表中查找或创建条目
      HashEntry *entry = NULL;
      uint64_t hash_key = simple_hash(returnflag, linestatus);
      for (int k = 0; k < hash_table.entry_count; k++) {
        if (hash_table.entries[k].hash_key == hash_key) {
          entry = &hash_table.entries[k];
          break;
        }
      }

      if (!entry) {
        entry = &hash_table.entries[hash_table.entry_count++];
        init_hash_entry(entry, returnflag, linestatus);
      }

      // 使用批量SIMD处理更新聚合值
      process_batch_simd(entry, &batch_quantities[j], &batch_prices[j],
                         &batch_discounts[j], &batch_taxes[j], 1);
    }
  }

  // 获取最终结果并排序
  for (int i = 0; i < hash_table.entry_count; i++) {
    finalize_hash_entry(&hash_table.entries[i]);
  }

  // 使用 pdqsort 进行排序
  pdqsort(hash_table.entries, hash_table.entry_count, sizeof(HashEntry),
          compare_hash_entry);

  // 输出结果
  printf("\n=== Aggregation Results ===\n");
  printf("%-15s %-15s %-8s %-15s %-15s %-15s %-15s %-15s %-15s\n",
         "l_returnflag", "l_linestatus", "count", "sum_qty", "sum_price",
         "sum_disc_price", "sum_charge", "avg_qty", "avg_disc");

  for (int i = 0; i < hash_table.entry_count; i++) {
    HashEntry *entry = &hash_table.entries[i];
    double avg_qty = entry->sum_qty / entry->count_order;
    double avg_disc = entry->sum_discount / entry->count_order;

    printf("%-15c %-15c %-8lld %-15.2f %-15.2f %-15.2f %-15.2f %-15.2f "
           "%-15.2f\n",
           entry->returnflag, entry->linestatus, entry->count_order,
           entry->sum_qty, entry->sum_base_price, entry->sum_disc_price,
           entry->sum_charge, avg_qty, avg_disc);
  }
  printf("===========================\n");

  // 注意：不释放arr和schema，因为调用者可能还需要使用
}
