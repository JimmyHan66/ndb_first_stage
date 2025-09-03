#include "ndb_arrow_batch.h"
#include "ndb_batch_driver.h"
#include "ndb_scan_runtime.h"
#include "ndb_agg_callback_factory.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main(int argc, char *argv[]) {
  printf("=== TPC-H Q6 Aggregation Integration Test ===\n");

  // 使用真实的SF=3数据
  const char *files[] = {"../sf3_parquet/lineitem.parquet"};
  const char *columns[] = {
      "l_orderkey",    "l_partkey",       "l_suppkey",  "l_linenumber",
      "l_quantity",    "l_extendedprice", "l_discount", "l_tax",
      "l_returnflag",  "l_linestatus",    "l_shipdate", "l_commitdate",
      "l_receiptdate", "l_shipinstruct",  "l_shipmode", "l_comment"};

  TableScanDesc scan_desc = {.file_paths = files,
                             .num_files = 1,
                             .needed_cols = columns,
                             .num_cols = 16,
                             .batch_size = 2048};

  printf("Opening scan handle for %s...\n", files[0]);

  // 测量扫描打开时间
  clock_t start_time = clock();
  ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);
  if (!scan_handle) {
    printf("Failed to open scan handle for %s\n", files[0]);
    printf("Make sure to run: python3 generate_real_tpch_data.py\n");
    return 1;
  }
  clock_t open_time = clock();
  printf("Scan opened in %.3f seconds\n",
         (double)(open_time - start_time) / CLOCKS_PER_SEC);

  // 创建Q6聚合callback
  AggCallback *q6_callback = create_q6_agg_callback();
  if (!q6_callback) {
    printf("Failed to create Q6 aggregation callback\n");
    rt_scan_close(scan_handle);
    return 1;
  }

  // 测量Q6批循环性能（包含聚合）
  printf("\nStarting Q6 batch processing with aggregation...\n");
  clock_t batch_start = clock();

  int32_t result = ndb_q6_batch_driver(scan_handle, q6_callback);

  clock_t batch_end = clock();
  double total_time = (double)(batch_end - batch_start) / CLOCKS_PER_SEC;

  if (result >= 0) {
    // 触发最终聚合结果输出
    q6_callback->finalize(q6_callback->agg_state, NULL);

    printf("\nTotal processing time: %.3f seconds\n", total_time);
    printf("Q6 aggregation test completed successfully\n");
  } else {
    printf("Q6 test failed with error: %d\n", result);
  }

  // 清理
  destroy_agg_callback(q6_callback);
  rt_scan_close(scan_handle);

  return result >= 0 ? 0 : 1;
}
