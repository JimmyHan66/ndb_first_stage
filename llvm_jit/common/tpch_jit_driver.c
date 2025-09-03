#include "../../include/ndb_arrow_batch.h"
#include "../../include/ndb_arrow_column.h"
#include "../../include/ndb_scan_runtime.h"
#include "ndb_types.h"
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

// TPC-H JIT 执行器
typedef struct {
  void *lib_handle;
  char *temp_lib_path;
} TPCHJitEngine;

// 声明过滤函数类型
typedef int32_t (*FilterLEDate32Func)(const SimpleColumnView *col,
                                      int32_t threshold, uint32_t *output_idx);
typedef int32_t (*FilterGEDate32Func)(const SimpleColumnView *col,
                                      int32_t threshold, uint32_t *output_idx);
typedef int32_t (*FilterLTDate32OnSelFunc)(const uint32_t *input_sel,
                                           int32_t input_count,
                                           const SimpleColumnView *col,
                                           int32_t threshold,
                                           uint32_t *output_idx);
typedef int32_t (*FilterBetweenI64OnSelFunc)(const uint32_t *input_sel,
                                             int32_t input_count,
                                             const SimpleColumnView *col,
                                             int64_t low, int64_t high,
                                             uint32_t *output_idx);
typedef int32_t (*FilterLTI64OnSelFunc)(const uint32_t *input_sel,
                                        int32_t input_count,
                                        const SimpleColumnView *col,
                                        int64_t threshold,
                                        uint32_t *output_idx);

// 转换函数：从你的 ArrowColumnView 到简化的 SimpleColumnView
void convert_arrow_to_simple_column(const ArrowColumnView *arrow_col,
                                    SimpleColumnView *simple_col) {
  simple_col->values = (const int32_t *)arrow_col->values;
  simple_col->validity = arrow_col->validity;
  simple_col->length = arrow_col->length;
  simple_col->offset = arrow_col->offset;
  simple_col->arrow_type_id = arrow_col->arrow_type_id;
}

// TPC-H JIT 引擎创建和编译函数
TPCHJitEngine *tpch_jit_create() {
  TPCHJitEngine *jit = malloc(sizeof(TPCHJitEngine));
  if (!jit)
    return NULL;
  jit->lib_handle = NULL;
  jit->temp_lib_path = NULL;
  return jit;
}

void tpch_jit_destroy(TPCHJitEngine *jit) {
  if (!jit)
    return;
  if (jit->lib_handle) {
    dlclose(jit->lib_handle);
  }
  if (jit->temp_lib_path) {
    unlink(jit->temp_lib_path);
    free(jit->temp_lib_path);
  }
  free(jit);
}

int tpch_jit_compile_and_load(TPCHJitEngine *jit, const char *ir_files[],
                              int num_files) {
  if (!jit || !ir_files || num_files <= 0)
    return -1;

  // 生成临时库文件
  char temp_template[] = "/tmp/jit_lib_XXXXXX.dylib";
  int fd = mkstemps(temp_template, 6);
  if (fd == -1) {
    perror("Failed to create temporary file");
    return -1;
  }
  close(fd);

  jit->temp_lib_path = strdup(temp_template);

  // 构建 clang 命令
  char cmd[2048];
  int pos = snprintf(cmd, sizeof(cmd),
                     "/usr/bin/clang -shared -O3 -march=native -fPIC -o %s",
                     jit->temp_lib_path);

  for (int i = 0; i < num_files; i++) {
    pos += snprintf(cmd + pos, sizeof(cmd) - pos, " %s", ir_files[i]);
  }

  printf("JIT compiling: %s\n", cmd);

  int result = system(cmd);
  if (result != 0) {
    printf("JIT compilation failed with code %d\n", result);
    return -1;
  }

  // 加载动态库
  jit->lib_handle = dlopen(jit->temp_lib_path, RTLD_LAZY);
  if (!jit->lib_handle) {
    printf("Failed to load JIT library: %s\n", dlerror());
    return -1;
  }

  printf("JIT compilation successful!\n");
  return 0;
}

void *tpch_jit_get_function(TPCHJitEngine *jit, const char *function_name) {
  if (!jit || !jit->lib_handle || !function_name)
    return NULL;

  void *func = dlsym(jit->lib_handle, function_name);
  if (!func) {
    printf("JIT function '%s' not found: %s\n", function_name, dlerror());
  }
  return func;
}

// Q1 JIT 批处理驱动 - 使用真实的 scan 系统
int32_t q1_jit_real_batch_driver(ScanHandle *scan_handle) {
  if (!scan_handle)
    return -1;

  // 创建 JIT 执行器
  TPCHJitEngine *jit = tpch_jit_create();
  if (!jit)
    return -1;

  // 编译 JIT 代码
  const char *ir_files[] = {"llvm_jit/common/filter_kernels.ll",
                            "llvm_jit/q1/q1_batch_driver.ll"};

  if (tpch_jit_compile_and_load(jit, ir_files, 2) != 0) {
    tpch_jit_destroy(jit);
    return -1;
  }

  // 获取 JIT 函数
  FilterLEDate32Func filter_le_date32 =
      (FilterLEDate32Func)tpch_jit_get_function(jit, "filter_le_date32");
  if (!filter_le_date32) {
    tpch_jit_destroy(jit);
    return -1;
  }

  // 分配输出缓冲区
  uint32_t *output_buffer = malloc(100000 * sizeof(uint32_t));
  if (!output_buffer) {
    tpch_jit_destroy(jit);
    return -1;
  }

  // 处理所有批次
  ArrowBatch batch;
  int64_t total_rows = 0;
  int64_t total_filtered = 0;
  int32_t batch_count = 0;

  printf("Starting Q1 JIT execution with real data...\n");

  while (true) {
    int32_t scan_result = rt_scan_next(scan_handle, &batch);
    if (scan_result <= 0)
      break; // EOF or error

    batch_count++;
    total_rows += batch.num_rows;

    // 获取 l_shipdate 列
    ArrowColumnView shipdate_col;
    if (ndb_get_arrow_column(&batch, 10, &shipdate_col) == 0) {
      // 转换为简化格式
      SimpleColumnView simple_shipdate;
      convert_arrow_to_simple_column(&shipdate_col, &simple_shipdate);

      // 执行 JIT 编译的过滤器
      int32_t filtered_count =
          filter_le_date32(&simple_shipdate, 10561, output_buffer);

      if (filtered_count >= 0) {
        total_filtered += filtered_count;

        if (batch_count % 50 == 0) {
          printf("Batch %d: %lld rows -> %d filtered (%.1f%%)\n", batch_count,
                 batch.num_rows, filtered_count,
                 100.0 * filtered_count / batch.num_rows);
        }
      }
    }

    // 清理批次
    ndb_arrow_batch_cleanup(&batch);
  }

  printf("\n=== Q1 JIT Results with Real Data ===\n");
  printf("Total batches: %d\n", batch_count);
  printf("Total rows: %lld\n", total_rows);
  printf("Total filtered: %lld\n", total_filtered);
  printf("Selectivity: %.2f%%\n",
         total_rows > 0 ? (100.0 * total_filtered / total_rows) : 0.0);

  // 清理
  free(output_buffer);
  tpch_jit_destroy(jit);

  return 0;
}

// Q6 JIT 批处理驱动 - 使用真实的 scan 系统
int32_t q6_jit_real_batch_driver(ScanHandle *scan_handle) {
  if (!scan_handle)
    return -1;

  // 创建 JIT 执行器
  TPCHJitEngine *jit = tpch_jit_create();
  if (!jit)
    return -1;

  // 编译 JIT 代码
  const char *ir_files[] = {"llvm_jit/common/filter_kernels.ll",
                            "llvm_jit/q6/q6_batch_driver.ll"};

  if (tpch_jit_compile_and_load(jit, ir_files, 2) != 0) {
    tpch_jit_destroy(jit);
    return -1;
  }

  // 获取 JIT 函数
  FilterGEDate32Func filter_ge_date32 =
      (FilterGEDate32Func)tpch_jit_get_function(jit, "filter_ge_date32");
  FilterLTDate32OnSelFunc filter_lt_date32_on_sel =
      (FilterLTDate32OnSelFunc)tpch_jit_get_function(jit,
                                                     "filter_lt_date32_on_sel");
  FilterBetweenI64OnSelFunc filter_between_i64_on_sel =
      (FilterBetweenI64OnSelFunc)tpch_jit_get_function(
          jit, "filter_between_i64_on_sel");
  FilterLTI64OnSelFunc filter_lt_i64_on_sel =
      (FilterLTI64OnSelFunc)tpch_jit_get_function(jit, "filter_lt_i64_on_sel");

  if (!filter_ge_date32 || !filter_lt_date32_on_sel ||
      !filter_between_i64_on_sel || !filter_lt_i64_on_sel) {
    tpch_jit_destroy(jit);
    return -1;
  }

  // 分配缓冲区
  uint32_t *output_buffer = malloc(100000 * sizeof(uint32_t));
  uint32_t *temp_buffer1 = malloc(100000 * sizeof(uint32_t));
  uint32_t *temp_buffer2 = malloc(100000 * sizeof(uint32_t));
  uint32_t *temp_buffer3 = malloc(100000 * sizeof(uint32_t));

  if (!output_buffer || !temp_buffer1 || !temp_buffer2 || !temp_buffer3) {
    free(output_buffer);
    free(temp_buffer1);
    free(temp_buffer2);
    free(temp_buffer3);
    tpch_jit_destroy(jit);
    return -1;
  }

  // 处理所有批次
  ArrowBatch batch;
  int64_t total_rows = 0;
  int64_t total_filtered = 0;
  int32_t batch_count = 0;

  printf("Starting Q6 JIT execution with real data...\n");

  while (true) {
    int32_t scan_result = rt_scan_next(scan_handle, &batch);
    if (scan_result <= 0)
      break; // EOF or error

    batch_count++;
    total_rows += batch.num_rows;

    // 获取需要的列
    ArrowColumnView shipdate_col, discount_col, quantity_col;
    if (ndb_get_arrow_column(&batch, 10, &shipdate_col) == 0 &&
        ndb_get_arrow_column(&batch, 6, &discount_col) == 0 &&
        ndb_get_arrow_column(&batch, 4, &quantity_col) == 0) {

      // 转换为简化格式
      SimpleColumnView simple_shipdate, simple_discount, simple_quantity;
      convert_arrow_to_simple_column(&shipdate_col, &simple_shipdate);
      convert_arrow_to_simple_column(&discount_col, &simple_discount);
      convert_arrow_to_simple_column(&quantity_col, &simple_quantity);

      // 执行 Q6 的 4 重过滤链
      int32_t count1 = filter_ge_date32(&simple_shipdate, 8766,
                                        temp_buffer1); // >= 1994-01-01
      if (count1 > 0) {
        int32_t count2 =
            filter_lt_date32_on_sel(temp_buffer1, count1, &simple_shipdate,
                                    9131, temp_buffer2); // < 1995-01-01
        if (count2 > 0) {
          int32_t count3 = filter_between_i64_on_sel(
              temp_buffer2, count2, &simple_discount, 5, 7,
              temp_buffer3); // BETWEEN 0.05 AND 0.07
          if (count3 > 0) {
            int32_t count4 =
                filter_lt_i64_on_sel(temp_buffer3, count3, &simple_quantity,
                                     2400, output_buffer); // < 24

            if (count4 >= 0) {
              total_filtered += count4;

              if (batch_count % 50 == 0) {
                printf("Batch %d: %lld rows -> %d filtered (%.3f%%)\n",
                       batch_count, batch.num_rows, count4,
                       100.0 * count4 / batch.num_rows);
              }
            }
          }
        }
      }
    }

    // 清理批次
    ndb_arrow_batch_cleanup(&batch);
  }

  printf("\n=== Q6 JIT Results with Real Data ===\n");
  printf("Total batches: %d\n", batch_count);
  printf("Total rows: %lld\n", total_rows);
  printf("Total filtered: %lld\n", total_filtered);
  printf("Selectivity: %.4f%%\n",
         total_rows > 0 ? (100.0 * total_filtered / total_rows) : 0.0);

  // 清理
  free(output_buffer);
  free(temp_buffer1);
  free(temp_buffer2);
  free(temp_buffer3);
  tpch_jit_destroy(jit);

  return 0;
}
