#include "ndb_arrow_batch.h"
#include "ndb_batch_driver.h"
#include "ndb_scan_runtime.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// 简单的统计收集器（不做聚合，只统计过滤效果）
typedef struct {
  int64_t total_rows_scanned;
  int64_t total_rows_filtered;
  int32_t batch_count;
  double total_scan_time;
  double total_filter_time;
} FilterStats;

// 简化的处理函数：只统计，不聚合 (Arrow版本)
void q1_filter_stats_collector(const ArrowBatch *batch, const SelVec *sel,
                               void *stats_ptr) {
  FilterStats *stats = (FilterStats *)stats_ptr;

  if (!batch || !sel)
    return;

  stats->total_rows_scanned += batch->num_rows;
  stats->total_rows_filtered += sel->count;
  stats->batch_count++;

  printf("Batch %d: Scanned %lld rows, Filtered %d rows (%.1f%% selectivity)\n",
         stats->batch_count, batch->num_rows, sel->count,
         batch->num_rows > 0 ? (100.0 * sel->count / batch->num_rows) : 0.0);
}

void q1_stats_finalize(void *stats_ptr, void *result) {
  FilterStats *stats = (FilterStats *)stats_ptr;

  printf("\n=== Q1 Arrow Scan & Filter Performance ===\n");
  printf("Total batches processed: %d\n", stats->batch_count);
  printf("Total rows scanned: %lld\n", stats->total_rows_scanned);
  printf("Total rows after filter: %lld\n", stats->total_rows_filtered);
  printf("Overall selectivity: %.2f%%\n",
         stats->total_rows_scanned > 0
             ? (100.0 * stats->total_rows_filtered / stats->total_rows_scanned)
             : 0.0);
  printf("Average batch size: %.1f rows\n",
         stats->batch_count > 0
             ? ((double)stats->total_rows_scanned / stats->batch_count)
             : 0.0);
  printf("Total scan time: %.3f seconds\n", stats->total_scan_time);
  printf("Total filter time: %.3f seconds\n", stats->total_filter_time);
  printf("=====================================\n");
}

int main(int argc, char *argv[]) {
  printf("=== TPC-H Q1 Arrow Scan & Filter Test ===\n");

  // 使用真实的SF=1数据
  const char *files[] = {"../sf1/lineitem.parquet"};
  const char *columns[] = {"l_orderkey",   "l_partkey",  "l_suppkey",
                           "l_linenumber", "l_quantity", "l_extendedprice",
                           "l_discount",   "l_tax",      "l_returnflag",
                           "l_linestatus", "l_shipdate"};

  TableScanDesc scan_desc = {
      .file_paths = files,
      .num_files = 1,
      .needed_cols = columns,
      .num_cols = 11,
      .batch_size = 2048 // 测试batch机制
  };

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

  // 初始化统计收集器
  FilterStats stats = {0};

  AggCallback stats_callback = {.process_batch = q1_filter_stats_collector,
                                .finalize = q1_stats_finalize,
                                .agg_state = &stats};

  // 测量Q1批循环性能
  printf("\nStarting Q1 Arrow batch processing...\n");
  clock_t batch_start = clock();

  int32_t result = ndb_q1_batch_driver(scan_handle, &stats_callback);

  clock_t batch_end = clock();
  stats.total_scan_time = (double)(batch_end - batch_start) / CLOCKS_PER_SEC;

  if (result >= 0) {
    stats_callback.finalize(&stats, NULL);

    // 计算吞吐量
    if (stats.total_scan_time > 0) {
      double throughput_rows = stats.total_rows_scanned / stats.total_scan_time;
      double throughput_mb = (stats.total_rows_scanned * sizeof(int64_t) * 11) /
                             (1024 * 1024 * stats.total_scan_time);
      printf("Throughput: %.0f rows/sec, %.1f MB/sec\n", throughput_rows,
             throughput_mb);
    }

    printf("Q1 Arrow scan & filter test completed successfully\n");
  } else {
    printf("Q1 test failed with error: %d\n", result);
  }

  // 清理
  rt_scan_close(scan_handle);

  return result >= 0 ? 0 : 1;
}
