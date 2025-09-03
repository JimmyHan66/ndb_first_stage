#include "../common/ndb_types.h"

// Q1 批处理驱动函数 - 简化版用于LLVM JIT
// TPC-H Q1: SELECT ... FROM lineitem WHERE l_shipdate <= '1998-12-01'
int32_t q1_batch_driver_jit(const SimpleBatch *batch, uint32_t *final_output) {
  if (!batch || !final_output || batch->num_cols < 11)
    return -1;

  // Q1 只需要一个过滤条件: l_shipdate <= '1998-12-01'
  // '1998-12-01' 对应 date32 值为 10561 (days since 1970-01-01)
  const int32_t shipdate_threshold = 10561;

  // 获取 l_shipdate 列 (假设是第10列)
  const SimpleColumnView *shipdate_col = &batch->columns[10];

  // 验证列类型
  if (shipdate_col->arrow_type_id != ARROW_TYPE_DATE32) {
    return -1;
  }

  // 声明过滤函数
  extern int32_t filter_le_date32(const SimpleColumnView *col,
                                  int32_t threshold, uint32_t *output_idx);

  // 执行过滤: l_shipdate <= '1998-12-01'
  int32_t result_count =
      filter_le_date32(shipdate_col, shipdate_threshold, final_output);

  return result_count;
}

// Q1 批处理统计收集器
typedef struct {
  int64_t total_rows_scanned;
  int64_t total_rows_filtered;
  int32_t batch_count;
} Q1Stats;

// Q1 统计处理函数
void q1_process_batch_jit(const SimpleBatch *batch,
                          const uint32_t *selected_rows, int32_t selected_count,
                          Q1Stats *stats) {
  if (!batch || !stats)
    return;

  stats->total_rows_scanned += batch->num_rows;
  stats->total_rows_filtered += selected_count;
  stats->batch_count++;
}