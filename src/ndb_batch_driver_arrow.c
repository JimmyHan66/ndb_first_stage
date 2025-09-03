#include "ndb_arrow_column.h"
#include "ndb_batch_driver.h"
#include "ndb_filter_kernels_arrow.h"
#include "ndb_selvec.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// TPC-H Q1 批处理驱动 (Arrow版本)
int32_t ndb_q1_batch_driver(ScanHandle *scan_handle,
                            AggCallback *agg_callback) {
  if (!scan_handle || !agg_callback) {
    printf("Error: Invalid parameters to Q1 batch driver\n");
    return -1;
  }

  ArrowBatch batch;
  ndb_arrow_batch_init(&batch); // 初始化ArrowBatch

  SelVec *sel1 = selvec_create(4096); // 第一级过滤结果
  SelVec *sel2 = selvec_create(4096); // 第二级过滤结果

  if (!sel1 || !sel2) {
    printf("Error: Failed to create selection vectors\n");
    if (sel1)
      selvec_destroy(sel1);
    if (sel2)
      selvec_destroy(sel2);
    return -1;
  }

  int32_t total_batches = 0;
  int32_t result;

  printf("Starting Q1 Arrow batch processing...\n");

  printf("About to call rt_scan_next...\n");
  while ((result = rt_scan_next(scan_handle, &batch)) > 0) {
    printf("rt_scan_next returned success, processing batch...\n");
    total_batches++;

    printf("Batch: %lld rows, %d columns\n", batch.num_rows, batch.num_cols);

    if (batch.num_rows == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // 重置selection vectors
    selvec_reset(sel1);
    selvec_reset(sel2);

    // Q1过滤条件: l_shipdate <= '1998-12-01'
    // '1998-12-01' 对应 date32 值为 10561 (days since 1970-01-01)

    // 获取 l_shipdate 列 (假设是第10列)
    ArrowColumnView shipdate_col;
    if (ndb_get_arrow_column(&batch, 10, &shipdate_col) != 0) {
      printf("Error: Failed to get shipdate column\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    printf("Shipdate column: type=%d, length=%lld\n",
           shipdate_col.arrow_type_id, shipdate_col.length);

    // Filter 1: l_shipdate <= '1998-12-01' (date32 = 10561)
    int32_t count1 = ndb_filter_le_arrow_date32(&shipdate_col, batch.num_rows,
                                                10561, sel1->idx);
    if (count1 < 0) {
      printf("Error: Filter 1 failed\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    sel1->count = count1;
    printf("Filter 1 (shipdate <= 1998-12-01): %d/%lld rows passed\n", count1,
           batch.num_rows);

    if (count1 == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // Q1通常只有一个过滤条件，直接传递给聚合回调
    agg_callback->process_batch(&batch, sel1, agg_callback->agg_state);

    // 清理当前批次
    ndb_arrow_batch_cleanup(&batch);
  }

  printf("\nQ1 batch processing completed. Total batches: %d\n", total_batches);

  // 清理
  selvec_destroy(sel1);
  selvec_destroy(sel2);

  if (result < 0) {
    printf("Error occurred during scan: %d\n", result);
    return result;
  }

  return total_batches;
}

// TPC-H Q6 批处理驱动 (Arrow版本)
int32_t ndb_q6_batch_driver(ScanHandle *scan_handle,
                            AggCallback *agg_callback) {
  if (!scan_handle || !agg_callback) {
    printf("Error: Invalid parameters to Q6 batch driver\n");
    return -1;
  }

  ArrowBatch batch;
  ndb_arrow_batch_init(&batch); // 初始化ArrowBatch

  SelVec *sel1 = selvec_create(4096); // 第一级过滤结果
  SelVec *sel2 = selvec_create(4096); // 第二级过滤结果
  SelVec *sel3 = selvec_create(4096); // 第三级过滤结果

  if (!sel1 || !sel2 || !sel3) {
    printf("Error: Failed to create selection vectors\n");
    if (sel1)
      selvec_destroy(sel1);
    if (sel2)
      selvec_destroy(sel2);
    if (sel3)
      selvec_destroy(sel3);
    return -1;
  }

  int32_t total_batches = 0;
  int32_t result;

  printf("Starting Q6 Arrow batch processing...\n");

  while ((result = rt_scan_next(scan_handle, &batch)) > 0) {
    total_batches++;

    printf("Batch: %lld rows, %d columns\n", batch.num_rows, batch.num_cols);

    if (batch.num_rows == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // 重置selection vectors
    selvec_reset(sel1);
    selvec_reset(sel2);
    selvec_reset(sel3);

    // Q6过滤条件:
    // l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01'
    // l_discount BETWEEN 0.05 AND 0.07
    // l_quantity < 24

    // 获取需要的列
    ArrowColumnView shipdate_col, discount_col, quantity_col;

    if (ndb_get_arrow_column(&batch, 10, &shipdate_col) != 0) { // l_shipdate
      printf("Error: Failed to get shipdate column\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    if (ndb_get_arrow_column(&batch, 6, &discount_col) != 0) { // l_discount
      printf("Error: Failed to get discount column\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    if (ndb_get_arrow_column(&batch, 4, &quantity_col) != 0) { // l_quantity
      printf("Error: Failed to get quantity column\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // Filter 1: l_shipdate >= '1994-01-01' (date32 ≈ 8766)
    int32_t count1 = ndb_filter_ge_arrow_date32(&shipdate_col, batch.num_rows,
                                                8766, sel1->idx);
    if (count1 < 0) {
      printf("Error: Filter 1 failed\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    sel1->count = count1;
    printf("Filter 1 (shipdate >= 1994-01-01): %d/%lld rows passed\n", count1,
           batch.num_rows);

    if (count1 == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // Filter 2: l_shipdate < '1995-01-01' (date32 ≈ 9131) - 链式过滤
    int32_t count2 = ndb_filter_lt_arrow_date32_on_sel(
        sel1->idx, sel1->count, &shipdate_col, 9131, sel2->idx);
    if (count2 < 0) {
      printf("Error: Filter 2 failed\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    sel2->count = count2;
    printf("Filter 2 (shipdate < 1995-01-01): %d/%d rows passed\n", count2,
           count1);

    if (count2 == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // Filter 3: l_discount BETWEEN 0.05 AND 0.07
    // Decimal128(15,2) 在底层存储为scaled INT64 (scale=2, 即 ×100)
    // 0.05 * 100 = 5, 0.07 * 100 = 7
    int32_t count3 = ndb_filter_between_arrow_i64_on_sel(
        sel2->idx, sel2->count, &discount_col, 5, 7, sel3->idx);
    if (count3 < 0) {
      printf("Error: Filter 3 failed\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    sel3->count = count3;
    printf("Filter 3 (discount BETWEEN 0.05 AND 0.07): %d/%d rows passed\n",
           count3, count2);

    if (count3 == 0) {
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    // Filter 4: l_quantity < 24 (在sel3基础上继续过滤，复用sel1)
    // l_quantity 也是 Decimal128(15,2)，需要转换为scaled值: 24 * 100 = 2400
    selvec_reset(sel1);
    int32_t count4;

    if (quantity_col.arrow_type_id == ARROW_TYPE_INT64 ||
        quantity_col.arrow_type_id == ARROW_TYPE_DECIMAL128) {
      count4 =
          ndb_filter_lt_arrow_i64_on_sel(sel3->idx, sel3->count, &quantity_col,
                                         2400, sel1->idx); // 24 * 100 = 2400
    } else {
      count4 =
          ndb_filter_lt_arrow_i32_on_sel(sel3->idx, sel3->count, &quantity_col,
                                         2400, sel1->idx); // 24 * 100 = 2400
    }

    if (count4 < 0) {
      printf("Error: Filter 4 failed\n");
      ndb_arrow_batch_cleanup(&batch);
      continue;
    }

    sel1->count = count4;
    printf("Filter 4 (quantity < 24): %d/%d rows passed\n", count4, count3);

    if (count4 > 0) {
      // 传递最终过滤结果给聚合回调
      agg_callback->process_batch(&batch, sel1, agg_callback->agg_state);
    }

    // 清理当前批次
    ndb_arrow_batch_cleanup(&batch);
  }

  printf("\nQ6 batch processing completed. Total batches: %d\n", total_batches);

  // 清理
  selvec_destroy(sel1);
  selvec_destroy(sel2);
  selvec_destroy(sel3);

  if (result < 0) {
    printf("Error occurred during scan: %d\n", result);
    return result;
  }

  return total_batches;
}
