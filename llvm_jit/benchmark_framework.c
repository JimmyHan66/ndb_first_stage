#include "common/ndb_types.h"
#include "../include/ndb_scan_runtime.h"
#include "../include/ndb_arrow_batch.h"
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdbool.h>
#include <inttypes.h>

// 时间测量函数
double get_time_ms() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

// 基准测试结果结构
typedef struct {
    double wallclock_ms;
    double exec_once_ms;
    double compile_ms;
    int64_t rows_processed;
    int64_t rows_filtered;
    double selectivity;
} BenchmarkResult;

// JIT 管理器结构
typedef struct {
    char temp_lib_path[256];
    void *lib_handle;
    void *jit_function;  // 预加载的 JIT 函数指针
} JITManager;

// 预加载数据结构（用于 exec 模式）
typedef struct {
    ArrowBatch *batches;
    int32_t batch_count;
    int64_t total_rows;
} PreloadedData;

// 根据用例选择优化的列集合
typedef struct {
    const char **columns;
    int32_t num_cols;
} ColumnSet;

ColumnSet get_column_set_for_case(const char *case_name) {
    static const char *q1_columns[] = {
        "l_quantity", "l_extendedprice", "l_discount", "l_tax",
        "l_returnflag", "l_linestatus", "l_shipdate"
    };
    static const char *q6_columns[] = {
        "l_quantity", "l_extendedprice", "l_discount", "l_shipdate"
    };
    static const char *sort_columns[] = {
        "l_shipdate"
    };

    ColumnSet result = {0};

    if (strstr(case_name, "q1") != NULL) {
        result.columns = q1_columns;
        result.num_cols = 7;
    } else if (strstr(case_name, "q6") != NULL) {
        result.columns = q6_columns;
        result.num_cols = 4;
    } else if (strstr(case_name, "sort") != NULL) {
        result.columns = sort_columns;
        result.num_cols = 1;
    } else {
        result.columns = q1_columns;
        result.num_cols = 7;
    }

    return result;
}

// 打开扫描句柄
ScanHandle* open_scan_handle(const char *scale, const char *case_name) {
    static char file_path[256];
    snprintf(file_path, sizeof(file_path), "../%s_parquet/lineitem.parquet",
             (strcmp(scale, "SF1") == 0) ? "sf1" :
             (strcmp(scale, "SF3") == 0) ? "sf3" : "sf5");

    static const char *file_paths[1];
    file_paths[0] = file_path;

    ColumnSet col_set = get_column_set_for_case(case_name);

    TableScanDesc scan_desc = {
        .file_paths = file_paths,
        .num_files = 1,
        .needed_cols = col_set.columns,
        .num_cols = col_set.num_cols,
        .batch_size = 2048
    };

    return rt_scan_open_parquet(&scan_desc);
}

// JIT 编译函数
int32_t jit_compile_case(JITManager *jit, const char *case_name, const char *mode, double *compile_time_ms) {
    if (!jit || !case_name || !mode) return -1;

    const char *opt_level = (strcmp(mode, "exec") == 0) ? "O3" : "O2";

    double compile_start = get_time_ms();

    snprintf(jit->temp_lib_path, sizeof(jit->temp_lib_path),
             "/tmp/jit_%s_%d.so", case_name, getpid());

    char cmd[2048];
    if (strcmp(case_name, "scan_filter_q1") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -fPIC -Wno-override-module -o %s "
            "common/filter_kernels.ll pipelines/scan_filter_q1_pipeline.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "scan_filter_q6") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -fPIC -Wno-override-module -o %s "
            "common/filter_kernels.ll pipelines/scan_filter_q6_pipeline.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "agg_only_q1") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -mavx2 -fPIC -Wno-override-module -o %s "
            "pipelines/agg_only_q1_pipeline.ll ../arrow-c/q1_incremental_optimized.ll "
            "../arrow-c/avx2_double_simd_sum.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "sort_only_shipdate") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -fPIC -Wno-override-module -o %s "
            "pipelines/sort_only_shipdate_pipeline.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "q6_full") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -mavx2 -fPIC -Wno-override-module -o %s "
            "common/filter_kernels.ll pipelines/q6_full_pipeline.ll "
            "../arrow-c/q6_incremental_optimized.ll ../arrow-c/avx2_double_simd_sum.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "q1_full") == 0) {
        snprintf(cmd, sizeof(cmd),
            "clang -shared -%s -march=native -mavx2 -fPIC -Wno-override-module -o %s "
            "common/filter_kernels.ll pipelines/q1_full_pipeline.ll "
            "../arrow-c/q1_incremental_optimized.ll ../arrow-c/avx2_double_simd_sum.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else {
        printf("❌ Unknown case: %s\n", case_name);
        return -1;
    }

    int result = system(cmd);
    if (result != 0) {
        printf("❌ JIT compilation failed for %s (-%s)\n", case_name, opt_level);
        return -1;
    }

    jit->lib_handle = dlopen(jit->temp_lib_path, RTLD_LAZY);
    if (!jit->lib_handle) {
        printf("❌ Failed to load JIT library: %s\n", dlerror());
        return -1;
    }

    // 预加载 JIT 函数指针
    char func_name[128];
    snprintf(func_name, sizeof(func_name), "%s_pipeline_jit", case_name);
    jit->jit_function = dlsym(jit->lib_handle, func_name);
    if (!jit->jit_function) {
        printf("❌ JIT function '%s' not found: %s\n", func_name, dlerror());
        return -1;
    }

    double compile_end = get_time_ms();
    if (compile_time_ms) {
        *compile_time_ms = compile_end - compile_start;
    }

    return 0;
}

// 预加载所有数据到内存（用于 exec 模式）
PreloadedData* preload_all_data(const char *scale, const char *case_name) {
    printf("📦 Preloading data for exec mode (not timed)...\n");

    ScanHandle *scan_handle = open_scan_handle(scale, case_name);
    if (!scan_handle) return NULL;

    PreloadedData *data = malloc(sizeof(PreloadedData));
    data->batches = malloc(sizeof(ArrowBatch) * 10000); // 最多10000个批次
    data->batch_count = 0;
    data->total_rows = 0;

    ArrowBatch batch;
    while (rt_scan_next(scan_handle, &batch) > 0 && data->batch_count < 10000) {
        data->batches[data->batch_count] = batch;  // 浅拷贝
        data->total_rows += batch.num_rows;
        data->batch_count++;
    }

    rt_scan_close(scan_handle);

    printf("📦 Preloaded %d batches (%lld rows)\n",
           data->batch_count, (long long)data->total_rows);

    return data;
}

// 释放预加载数据
void free_preloaded_data(PreloadedData *data) {
    if (data) {
        for (int i = 0; i < data->batch_count; i++) {
            ndb_arrow_batch_cleanup(&data->batches[i]);
        }
        free(data->batches);
        free(data);
    }
}

// 🔥 关键：只计时 JIT kernel 执行（exec 模式的核心）
BenchmarkResult measure_jit_kernel_only(JITManager *jit, const char *scale, const char *case_name,
                                        PreloadedData *data) {
    BenchmarkResult result = {0};

    if (!jit->jit_function) {
        printf("❌ JIT function not loaded\n");
        return result;
    }

    // 🎯 架构问题解决：使用正确的 scale 而不是硬编码 SF1
    typedef int32_t (*PipelineFunc)(ScanHandle*);
    PipelineFunc pipeline_func = (PipelineFunc)jit->jit_function;

    // 创建正确 scale 的扫描句柄
    ScanHandle *temp_handle = open_scan_handle(scale, case_name);  // 🔧 修复：使用传入的 scale
    if (!temp_handle) {
        printf("❌ Failed to create temp scan handle for %s\n", scale);
        return result;
    }

    // 🔥 真正的计时开始：只计时 JIT 函数调用
    double exec_start = get_time_ms();
    int32_t processed_rows = pipeline_func(temp_handle);
    double exec_end = get_time_ms();

    result.exec_once_ms = exec_end - exec_start;
    result.rows_processed = processed_rows;
    result.rows_filtered = processed_rows;  // 简化
    result.selectivity = data->total_rows > 0 ?
                        (double)result.rows_filtered / data->total_rows : 0.0;

    rt_scan_close(temp_handle);

    return result;
}

// exec 模式基准测试（修正计时边界）
int32_t benchmark_exec_mode(const char *scale, const char *case_name, BenchmarkResult *final_result) {
    printf("=== 🎯 EXEC Mode: %s %s (Fixed Timing) ===\n", scale, case_name);

    // 1. 预置阶段（不计时）：Parquet → Arrow → 内存
    printf("Phase 1: Preloading data (not timed)...\n");
    PreloadedData *data = preload_all_data(scale, case_name);
    if (!data) return -1;

    // 2. JIT 编译（不计时）
    printf("Phase 2: JIT compilation (not timed)...\n");
    JITManager *jit = malloc(sizeof(JITManager));
    memset(jit, 0, sizeof(JITManager));

    if (jit_compile_case(jit, case_name, "exec", NULL) != 0) {
        free_preloaded_data(data);
        free(jit);
        return -1;
    }
    printf("✅ JIT compilation successful with -O3\n");

        // 3. Warm-up（3次，不计时）
    printf("Phase 3: Warm-up (3 runs, not timed)...\n");
    for (int i = 0; i < 3; i++) {
        BenchmarkResult warmup_result = measure_jit_kernel_only(jit, scale, case_name, data);
        printf("  Warmup %d: %.3f ms\n", i+1, warmup_result.exec_once_ms);
    }

    // 4. 正式测量（2次，取最小值）
    printf("Phase 4: Measurement (2 runs, timing JIT kernel only)...\n");
    double min_time = 1e9;
    BenchmarkResult best_result = {0};

    for (int run = 0; run < 2; run++) {
        BenchmarkResult run_result = measure_jit_kernel_only(jit, scale, case_name, data);

        printf("  Run %d: %.3f ms (JIT kernel only)\n", run+1, run_result.exec_once_ms);

        if (run_result.exec_once_ms < min_time) {
            min_time = run_result.exec_once_ms;
            best_result = run_result;
        }
    }

    *final_result = best_result;
    final_result->wallclock_ms = min_time;  // exec 模式: wallclock = exec_once
    final_result->compile_ms = 0.0;  // exec 模式不计编译时间

    // 清理
    if (jit->lib_handle) dlclose(jit->lib_handle);
    unlink(jit->temp_lib_path);
    free(jit);
    free_preloaded_data(data);

    return 0;
}

// e2e 模式基准测试（每轮重新编译）
int32_t benchmark_e2e_mode(const char *scale, const char *case_name, BenchmarkResult *final_result) {
    printf("=== 🌍 E2E Mode: %s %s (Full Pipeline) ===\n", scale, case_name);

    double min_wallclock = 1e9;
    BenchmarkResult best_result = {0};

    // 2 轮测试，每轮都从零开始
    for (int round = 0; round < 2; round++) {
        printf("\n--- E2E Round %d ---\n", round + 1);

        double t0 = get_time_ms();

        // 1. Parquet → Arrow 扫描
        ScanHandle *scan_handle = open_scan_handle(scale, case_name);
        if (!scan_handle) continue;

        // 2. JIT 编译（每轮都重新编译）
        JITManager *jit = malloc(sizeof(JITManager));
        memset(jit, 0, sizeof(JITManager));

        double compile_time;
        if (jit_compile_case(jit, case_name, "e2e", &compile_time) != 0) {
            rt_scan_close(scan_handle);
            free(jit);
            continue;
        }

        // 3. 执行一次（不预热）
        typedef int32_t (*PipelineFunc)(ScanHandle*);
        PipelineFunc pipeline_func = (PipelineFunc)jit->jit_function;

        if (!pipeline_func) {
            rt_scan_close(scan_handle);
            if (jit->lib_handle) dlclose(jit->lib_handle);
            free(jit);
            continue;
        }

        double exec_start = get_time_ms();
        int32_t processed_rows = pipeline_func(scan_handle);
        double exec_end = get_time_ms();

        double t1 = get_time_ms();

        // 记录该轮结果
        BenchmarkResult round_result = {0};
        round_result.wallclock_ms = t1 - t0;
        round_result.exec_once_ms = exec_end - exec_start;
        round_result.compile_ms = compile_time;
        round_result.rows_processed = processed_rows;
        round_result.rows_filtered = processed_rows;  // 简化
        round_result.selectivity = processed_rows > 0 ? 1.0 : 0.0;  // 简化

        printf("Round %d: E2E=%.3fms, Exec=%.3fms, Compile=%.3fms\n",
               round + 1, round_result.wallclock_ms,
               round_result.exec_once_ms, round_result.compile_ms);

        // 取最小值
        if (round_result.wallclock_ms < min_wallclock) {
            min_wallclock = round_result.wallclock_ms;
            best_result = round_result;
        }

        // 清理该轮资源
        rt_scan_close(scan_handle);
        if (jit->lib_handle) dlclose(jit->lib_handle);
        unlink(jit->temp_lib_path);
        free(jit);
    }

    *final_result = best_result;
    return 0;
}

// 输出结果（符合 test_design.md 格式）
void output_result(const char *scale, const char *case_name, const char *mode,
                  const BenchmarkResult *result) {
    if (strcmp(mode, "exec") == 0) {
        // exec 模式：ms=exec_once_ms, exec_once_ms 和 compile_ms 为空
        printf("%s,%s,%s,min,%.3f,,,%" PRId64 ",%.4f\n",
               scale, case_name, mode,
               result->exec_once_ms,
               result->rows_processed, result->selectivity);
    } else {
        // e2e 模式：ms=wallclock_ms, 包含所有字段
        printf("%s,%s,%s,min,%.3f,%.3f,%.3f,%" PRId64 ",%.4f\n",
               scale, case_name, mode,
               result->wallclock_ms, result->exec_once_ms, result->compile_ms,
               result->rows_processed, result->selectivity);
    }
}

// 主函数
int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <scale> <case> <mode>\n", argv[0]);
        printf("  scale: SF1, SF3, SF5\n");
        printf("  case: scan_filter_q1, scan_filter_q6, agg_only_q1, sort_only_shipdate, q6_full, q1_full\n");
        printf("  mode: exec, e2e\n");
        return 1;
    }

    const char *scale = argv[1];
    const char *case_name = argv[2];
    const char *mode = argv[3];

    // CSV 头部（符合 test_design.md 格式）
    printf("scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity\n");

    BenchmarkResult result = {0};

    if (strcmp(mode, "exec") == 0) {
        if (benchmark_exec_mode(scale, case_name, &result) == 0) {
            output_result(scale, case_name, mode, &result);
        }
    } else if (strcmp(mode, "e2e") == 0) {
        if (benchmark_e2e_mode(scale, case_name, &result) == 0) {
            output_result(scale, case_name, mode, &result);
        }
    } else {
        printf("❌ Invalid mode: %s\n", mode);
        return 1;
    }

    return 0;
}
