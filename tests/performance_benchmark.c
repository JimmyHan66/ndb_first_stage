#include "ndb_batch_driver.h"
#include "ndb_scan_runtime.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

// 高精度时间测量
double get_time_seconds() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + tv.tv_usec / 1000000.0;
}

// 性能统计结构
typedef struct {
  int64_t total_rows_processed;
  int64_t total_rows_filtered;
  int32_t batch_count;
  double scan_time;
  double filter_time;
  double total_time;
  int32_t batch_size;
} PerfStats;

// 性能测试回调
void perf_callback(const DataChunk *chunk, const SelVec *sel, void *stats_ptr) {
  PerfStats *stats = (PerfStats *)stats_ptr;

  if (!chunk || !sel)
    return;

  stats->total_rows_processed += chunk->length;
  stats->total_rows_filtered += sel->count;
  stats->batch_count++;

  // 每1000个batch报告一次进度
  if (stats->batch_count % 1000 == 0) {
    printf(
        "Processed %d batches, %.1fM rows, %.1f%% selectivity\n",
        stats->batch_count, stats->total_rows_processed / 1000000.0,
        stats->total_rows_processed > 0
            ? (100.0 * stats->total_rows_filtered / stats->total_rows_processed)
            : 0.0);
  }
}

void perf_finalize(void *stats_ptr, void *result) {
  // 最终统计在main函数中处理
}

// 测试不同batch size的性能
int test_batch_size_performance(const char *file_path) {
  printf("\n=== Batch Size Performance Test ===\n");

  int32_t batch_sizes[] = {512, 1024, 2048, 4096, 8192};
  int num_batch_sizes = sizeof(batch_sizes) / sizeof(batch_sizes[0]);

  const char *columns[] = {"l_orderkey",   "l_partkey",  "l_suppkey",
                           "l_linenumber", "l_quantity", "l_extendedprice",
                           "l_discount",   "l_tax",      "l_returnflag",
                           "l_linestatus", "l_shipdate"};

  printf("Testing batch sizes: ");
  for (int i = 0; i < num_batch_sizes; i++) {
    printf("%d%s", batch_sizes[i], (i < num_batch_sizes - 1) ? ", " : "\n");
  }
  printf("\n");

  for (int i = 0; i < num_batch_sizes; i++) {
    int32_t batch_size = batch_sizes[i];

    TableScanDesc scan_desc = {.file_paths = &file_path,
                               .num_files = 1,
                               .needed_cols = columns,
                               .num_cols = 11,
                               .batch_size = batch_size};

    printf("Testing batch_size=%d... ", batch_size);
    fflush(stdout);

    double start_time = get_time_seconds();

    ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);
    if (!scan_handle) {
      printf("FAILED to open scan\n");
      continue;
    }

    PerfStats stats = {0};
    stats.batch_size = batch_size;

    AggCallback callback = {.process_batch = perf_callback,
                            .finalize = perf_finalize,
                            .agg_state = &stats};

    double process_start = get_time_seconds();
    int32_t result = ndb_q1_batch_driver(scan_handle, &callback);
    double process_end = get_time_seconds();

    rt_scan_close(scan_handle);

    if (result >= 0) {
      stats.total_time = process_end - start_time;
      double throughput = stats.total_rows_processed / stats.total_time;
      double batches_per_sec = stats.batch_count / stats.total_time;

      printf("%.1fM rows/sec, %.0f batches/sec, %.3fs total\n",
             throughput / 1000000.0, batches_per_sec, stats.total_time);
    } else {
      printf("FAILED\n");
    }
  }

  return 0;
}

// 测试列裁剪性能影响
int test_column_projection_performance(const char *file_path) {
  printf("\n=== Column Projection Performance Test ===\n");

  // 不同的列选择策略
  struct {
    const char *name;
    const char **columns;
    int num_cols;
  } projection_tests[] = {
      {"All 13 columns",
       (const char *[]){"l_orderkey", "l_partkey", "l_suppkey", "l_linenumber",
                        "l_quantity", "l_extendedprice", "l_discount", "l_tax",
                        "l_returnflag", "l_linestatus", "l_shipdate",
                        "l_commitdate", "l_receiptdate"},
       13},
      {"Q1 columns (11)",
       (const char *[]){"l_orderkey", "l_partkey", "l_suppkey", "l_linenumber",
                        "l_quantity", "l_extendedprice", "l_discount", "l_tax",
                        "l_returnflag", "l_linestatus", "l_shipdate"},
       11},
      {"Q6 columns (4)",
       (const char *[]){"l_shipdate", "l_discount", "l_quantity",
                        "l_extendedprice"},
       4},
      {"Minimal (2)", (const char *[]){"l_shipdate", "l_quantity"}, 2}};

  int num_tests = sizeof(projection_tests) / sizeof(projection_tests[0]);

  for (int i = 0; i < num_tests; i++) {
    TableScanDesc scan_desc = {.file_paths = &file_path,
                               .num_files = 1,
                               .needed_cols = projection_tests[i].columns,
                               .num_cols = projection_tests[i].num_cols,
                               .batch_size = 2048};

    printf("Testing %s... ", projection_tests[i].name);
    fflush(stdout);

    double start_time = get_time_seconds();

    ScanHandle *scan_handle = rt_scan_open_parquet(&scan_desc);
    if (!scan_handle) {
      printf("FAILED to open scan\n");
      continue;
    }

    PerfStats stats = {0};
    AggCallback callback = {.process_batch = perf_callback,
                            .finalize = perf_finalize,
                            .agg_state = &stats};

    int32_t result = ndb_q1_batch_driver(scan_handle, &callback);
    double end_time = get_time_seconds();

    rt_scan_close(scan_handle);

    if (result >= 0) {
      stats.total_time = end_time - start_time;
      double throughput = stats.total_rows_processed / stats.total_time;

      printf("%.1fM rows/sec, %.3fs total\n", throughput / 1000000.0,
             stats.total_time);
    } else {
      printf("FAILED\n");
    }
  }

  return 0;
}

int main(int argc, char *argv[]) {
  const char *file_path = "sf1/lineitem.parquet";

  if (argc > 1) {
    file_path = argv[1];
  }

  printf("=== NDB Scan & Filter Performance Benchmark ===\n");
  printf("Data file: %s\n", file_path);

  // 检查文件是否存在
  FILE *f = fopen(file_path, "r");
  if (!f) {
    printf("Error: Cannot open %s\n", file_path);
    printf("Please run: python3 generate_real_tpch_data.py\n");
    return 1;
  }
  fclose(f);

  // 测试1: 不同batch size的性能
  int result1 = test_batch_size_performance(file_path);

  // 测试2: 列裁剪性能影响
  int result2 = test_column_projection_performance(file_path);

  printf("\n=== Benchmark Summary ===\n");
  printf("Batch size test: %s\n", result1 == 0 ? "PASSED" : "FAILED");
  printf("Column projection test: %s\n", result2 == 0 ? "PASSED" : "FAILED");
  printf("==========================\n");

  return (result1 == 0 && result2 == 0) ? 0 : 1;
}
