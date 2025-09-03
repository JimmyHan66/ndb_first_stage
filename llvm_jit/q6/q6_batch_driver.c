#include "../common/ndb_types.h"

// Q6 批处理驱动函数 - 简化版用于LLVM JIT
// TPC-H Q6: 复杂的多重过滤条件
int32_t q6_batch_driver_jit(const SimpleBatch *batch, uint32_t *final_output,
                            uint32_t *temp_buffer1, uint32_t *temp_buffer2,
                            uint32_t *temp_buffer3) {
  if (!batch || !final_output || batch->num_cols < 16)
    return -1;

  if (!temp_buffer1 || !temp_buffer2 || !temp_buffer3)
    return -1;

  // Q6过滤条件:
  // l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01'
  // l_discount BETWEEN 0.05 AND 0.07 (scaled: 5 AND 7)
  // l_quantity < 24 (scaled: 2400)

  const int32_t shipdate_ge_threshold = 8766; // 1994-01-01
  const int32_t shipdate_lt_threshold = 9131; // 1995-01-01
  const int64_t discount_low = 5;             // 0.05 * 100
  const int64_t discount_high = 7;            // 0.07 * 100
  const int64_t quantity_threshold = 2400;    // 24 * 100

  // 获取需要的列
  const SimpleColumnView *shipdate_col = &batch->columns[10]; // l_shipdate
  const SimpleColumnView *discount_col = &batch->columns[6];  // l_discount
  const SimpleColumnView *quantity_col = &batch->columns[4];  // l_quantity

  // 验证列类型
  if (shipdate_col->arrow_type_id != ARROW_TYPE_DATE32 ||
      (discount_col->arrow_type_id != ARROW_TYPE_INT64 &&
       discount_col->arrow_type_id != ARROW_TYPE_DECIMAL128) ||
      (quantity_col->arrow_type_id != ARROW_TYPE_INT64 &&
       quantity_col->arrow_type_id != ARROW_TYPE_DECIMAL128)) {
    return -1;
  }

  // 声明过滤函数
  extern int32_t filter_ge_date32(const SimpleColumnView *col,
                                  int32_t threshold, uint32_t *output_idx);
  extern int32_t filter_lt_date32_on_sel(
      const uint32_t *input_sel, int32_t input_count,
      const SimpleColumnView *col, int32_t threshold, uint32_t *output_idx);
  extern int32_t filter_between_i64_on_sel(
      const uint32_t *input_sel, int32_t input_count,
      const SimpleColumnView *col, int64_t low, int64_t high,
      uint32_t *output_idx);
  extern int32_t filter_lt_i64_on_sel(
      const uint32_t *input_sel, int32_t input_count,
      const SimpleColumnView *col, int64_t threshold, uint32_t *output_idx);

  // Filter 1: l_shipdate >= '1994-01-01'
  int32_t count1 =
      filter_ge_date32(shipdate_col, shipdate_ge_threshold, temp_buffer1);
  if (count1 <= 0) {
    return count1;
  }

  // Filter 2: l_shipdate < '1995-01-01' (链式过滤)
  int32_t count2 = filter_lt_date32_on_sel(temp_buffer1, count1, shipdate_col,
                                           shipdate_lt_threshold, temp_buffer2);
  if (count2 <= 0) {
    return count2;
  }

  // Filter 3: l_discount BETWEEN 0.05 AND 0.07 (链式过滤)
  int32_t count3 =
      filter_between_i64_on_sel(temp_buffer2, count2, discount_col,
                                discount_low, discount_high, temp_buffer3);
  if (count3 <= 0) {
    return count3;
  }

  // Filter 4: l_quantity < 24 (链式过滤，输出到final_output)
  int32_t count4 = filter_lt_i64_on_sel(temp_buffer3, count3, quantity_col,
                                        quantity_threshold, final_output);

  return count4;
}

// Q6 批处理统计收集器
typedef struct {
  int64_t total_rows_scanned;
  int64_t total_rows_filtered;
  int32_t batch_count;

  // Q6特定的中间统计
  int64_t filter1_passed;
  int64_t filter2_passed;
  int64_t filter3_passed;
  int64_t filter4_passed;
} Q6Stats;

// Q6 统计处理函数
void q6_process_batch_jit(const SimpleBatch *batch,
                          const uint32_t *selected_rows, int32_t selected_count,
                          Q6Stats *stats) {
  if (!batch || !stats)
    return;

  stats->total_rows_scanned += batch->num_rows;
  stats->total_rows_filtered += selected_count;
  stats->batch_count++;
  stats->filter4_passed += selected_count; // 最终通过所有过滤器的行数
}