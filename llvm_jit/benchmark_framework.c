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

// 基准测试配置
typedef struct {
    const char *scale;        // "SF1", "SF3", "SF5"
    const char *case_name;    // "scan_filter_q1", etc.
    const char *mode;         // "exec", "e2e"
    int32_t warmup_runs;      // warmup 次数 (exec模式)
    int32_t repeat_runs;      // 测量次数
} BenchmarkConfig;

// 时间测量结果
typedef struct {
    double wallclock_ms;      // 墙钟时间
    double exec_once_ms;      // 纯执行时间 (仅e2e模式有效)
    double compile_ms;        // JIT编译时间 (仅e2e模式有效)
    int64_t rows_processed;   // 处理的行数
    double selectivity;       // 选择率 (过滤用例)
} BenchmarkResult;

// JIT 管理器
typedef struct {
    void *lib_handle;
    char temp_lib_path[256];
    bool is_compiled;
} JITManager;

// 获取高精度时间 (毫秒)
double get_time_ms() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

// JIT 管理器初始化
JITManager* jit_manager_create() {
    JITManager *jit = (JITManager*)malloc(sizeof(JITManager));
    if (jit) {
        jit->lib_handle = NULL;
        jit->temp_lib_path[0] = '\0';
        jit->is_compiled = false;
    }
    return jit;
}

void jit_manager_destroy(JITManager *jit) {
    if (!jit) return;

    if (jit->lib_handle) {
        dlclose(jit->lib_handle);
        jit->lib_handle = NULL;
    }

    if (jit->temp_lib_path[0] != '\0') {
        unlink(jit->temp_lib_path);
        jit->temp_lib_path[0] = '\0';
    }

    free(jit);
}

// JIT 编译函数
int32_t jit_compile_case(JITManager *jit, const char *case_name, const char *mode, double *compile_time_ms) {
    if (!jit || !case_name || !mode) return -1;

    // 智能选择优化级别：exec模式用O3 (最大化执行性能)，e2e模式用O2 (平衡编译+执行时间)
    const char *opt_level = (strcmp(mode, "exec") == 0) ? "O3" : "O2";

    double compile_start = get_time_ms();

    // 生成唯一的临时库文件名
    snprintf(jit->temp_lib_path, sizeof(jit->temp_lib_path),
             "/tmp/jit_%s_%d.so", case_name, getpid());

    // 构建编译命令 - 根据不同用例链接不同的 IR 文件
    char cmd[2048];
    if (strcmp(case_name, "scan_filter_q1") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -fPIC -o %s "
            "common/filter_kernels.ll pipelines/scan_filter_q1_pipeline.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "scan_filter_q6") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -fPIC -o %s "
            "common/filter_kernels.ll pipelines/scan_filter_q6_pipeline.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "agg_only_q1") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -mavx2 -fPIC -o %s "
            "pipelines/agg_only_q1_pipeline.ll ../arrow-c/q1_incremental_optimized.ll "
            "../arrow-c/avx2_double_simd_sum.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "sort_only_shipdate") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -fPIC -o %s "
            "pipelines/sort_only_shipdate_pipeline.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "q6_full") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -mavx2 -fPIC -o %s "
            "common/filter_kernels.ll pipelines/q6_full_pipeline.ll "
            "../arrow-c/q6_incremental_optimized.ll ../arrow-c/avx2_double_simd_sum.ll",
            opt_level, jit->temp_lib_path);
    } else if (strcmp(case_name, "q1_full") == 0) {
        snprintf(cmd, sizeof(cmd),
            "/usr/bin/clang -shared -%s -march=native -mavx2 -fPIC -o %s "
            "common/filter_kernels.ll pipelines/q1_full_pipeline.ll "
            "../arrow-c/q1_incremental_optimized.ll ../arrow-c/avx2_double_simd_sum.ll ../arrow-c/pdqsort.ll",
            opt_level, jit->temp_lib_path);
    } else {
        printf("❌ Unknown case: %s\n", case_name);
        return -1;
    }

    // 执行编译
    printf("🔨 Compiling with -%s optimization for %s mode\n", opt_level, mode);
    int result = system(cmd);
    if (result != 0) {
        printf("❌ JIT compilation failed for %s (-%s)\n", case_name, opt_level);
        return -1;
    }

    printf("✅ JIT compilation successful with -%s\n", opt_level);

    // 加载动态库
    jit->lib_handle = dlopen(jit->temp_lib_path, RTLD_LAZY);
    if (!jit->lib_handle) {
        printf("❌ Failed to load JIT library: %s\n", dlerror());
        return -1;
    }

    double compile_end = get_time_ms();
    if (compile_time_ms) {
        *compile_time_ms = compile_end - compile_start;
    }

    jit->is_compiled = true;
    return 0;
}

// 获取 JIT 函数指针
void* jit_get_function(JITManager *jit, const char *function_name) {
    if (!jit || !jit->lib_handle || !function_name) {
        return NULL;
    }

    void *func = dlsym(jit->lib_handle, function_name);
    if (!func) {
        printf("❌ JIT function '%s' not found: %s\n", function_name, dlerror());
    }
    return func;
}

// 根据用例选择优化的列集合
typedef struct {
    const char **columns;
    int32_t num_cols;
} ColumnSet;

// 获取用例对应的列集合
ColumnSet get_column_set_for_case(const char *case_name) {
    // Q1 相关列（7 列）- 按原始 lineitem 表顺序排列
    static const char *q1_columns[] = {
        "l_quantity",      // index 0 -> original index 4
        "l_extendedprice", // index 1 -> original index 5
        "l_discount",      // index 2 -> original index 6
        "l_tax",           // index 3 -> original index 7
        "l_returnflag",    // index 4 -> original index 8
        "l_linestatus",    // index 5 -> original index 9
        "l_shipdate"       // index 6 -> original index 10
    };

    // Q6 相关列（4 列）- 按原始 lineitem 表顺序排列
    static const char *q6_columns[] = {
        "l_quantity",      // index 0 -> original index 4
        "l_extendedprice", // index 1 -> original index 5
        "l_discount",      // index 2 -> original index 6
        "l_shipdate"       // index 3 -> original index 10
    };

    // Sort 相关列（1 列）
    static const char *sort_columns[] = {
        "l_shipdate"       // index 0 -> original index 10
    };

    ColumnSet result = {0};

    if (strstr(case_name, "q1") != NULL) {
        // Q1 相关用例：scan_filter_q1, agg_only_q1, q1_full
        result.columns = q1_columns;
        result.num_cols = 7;
    } else if (strstr(case_name, "q6") != NULL) {
        // Q6 相关用例：scan_filter_q6, q6_full
        result.columns = q6_columns;
        result.num_cols = 4;
    } else if (strstr(case_name, "sort") != NULL) {
        // Sort 相关用例：sort_only_shipdate
        result.columns = sort_columns;
        result.num_cols = 1;
    } else {
        // 默认使用 Q1 列集合
        result.columns = q1_columns;
        result.num_cols = 7;
    }

    return result;
}

// 打开扫描句柄 - 根据用例选择精确列
ScanHandle* open_scan_handle(const char *scale, const char *case_name) {
    char file_path[256];
    snprintf(file_path, sizeof(file_path), "../%s_parquet/lineitem.parquet",
             (strcmp(scale, "SF1") == 0) ? "sf1" :
             (strcmp(scale, "SF3") == 0) ? "sf3" : "sf5");

    // 根据用例获取优化的列集合
    ColumnSet col_set = get_column_set_for_case(case_name);

    TableScanDesc scan_desc = {
        .file_paths = &file_path,
        .num_files = 1,
        .needed_cols = col_set.columns,  // 使用优化的列集合
        .num_cols = col_set.num_cols,    // 精确的列数
        .batch_size = 2048
    };

    printf("📋 Scanning %s with %d optimized columns for case '%s'\n",
           file_path, col_set.num_cols, case_name);

    return rt_scan_open_parquet(&scan_desc);
}

// 执行单次测试
int32_t run_single_test(const char *case_name, const char *scale,
                       JITManager *jit, BenchmarkResult *result) {
    // 打开扫描句柄 (传入用例名以选择优化列)
    ScanHandle *scan_handle = open_scan_handle(scale, case_name);
    if (!scan_handle) {
        printf("❌ Failed to open scan handle for %s with case %s\n", scale, case_name);
        return -1;
    }

    // 获取对应的 JIT 函数
    char func_name[128];
    snprintf(func_name, sizeof(func_name), "%s_pipeline_jit", case_name);

    typedef int32_t (*PipelineFunc)(ScanHandle*);
    PipelineFunc pipeline_func = (PipelineFunc)jit_get_function(jit, func_name);

    if (!pipeline_func) {
        rt_scan_close(scan_handle);
        return -1;
    }

    // 执行测试
    double exec_start = get_time_ms();
    int32_t processed_rows = pipeline_func(scan_handle);
    double exec_end = get_time_ms();

    result->exec_once_ms = exec_end - exec_start;
    result->rows_processed = processed_rows;
    result->selectivity = 0.0; // 需要根据具体用例计算

    rt_scan_close(scan_handle);
    return processed_rows >= 0 ? 0 : -1;
}

// exec 模式基准测试
int32_t benchmark_exec_mode(const BenchmarkConfig *config, BenchmarkResult *result) {
    printf("=== Running %s %s in EXEC mode ===\n", config->scale, config->case_name);

    // 1. 预编译 JIT (不计时)
    JITManager *jit = jit_manager_create();
    if (!jit) return -1;

    printf("Pre-compiling JIT code (not timed)...\n");
    if (jit_compile_case(jit, config->case_name, "exec", NULL) != 0) {
        jit_manager_destroy(jit);
        return -1;
    }

    // 2. Warm-up (不计时)
    printf("Warming up (%d runs)...\n", config->warmup_runs);
    for (int i = 0; i < config->warmup_runs; i++) {
        BenchmarkResult warmup_result = {0};
        run_single_test(config->case_name, config->scale, jit, &warmup_result);
    }

    // 3. 正式测量 (取最小值)
    printf("Running measurements (%d runs)...\n", config->repeat_runs);
    double min_time = 1e9;
    int64_t total_rows = 0;

    for (int i = 0; i < config->repeat_runs; i++) {
        BenchmarkResult run_result = {0};
        if (run_single_test(config->case_name, config->scale, jit, &run_result) == 0) {
            if (run_result.exec_once_ms < min_time) {
                min_time = run_result.exec_once_ms;
                total_rows = run_result.rows_processed;
            }
        }
    }

    result->wallclock_ms = min_time;
    result->exec_once_ms = min_time;
    result->compile_ms = 0.0;
    result->rows_processed = total_rows;

    jit_manager_destroy(jit);
    return 0;
}

// e2e 模式基准测试
int32_t benchmark_e2e_mode(const BenchmarkConfig *config, BenchmarkResult *result) {
    printf("=== Running %s %s in E2E mode ===\n", config->scale, config->case_name);

    double min_e2e_time = 1e9;
    double min_exec_time = 1e9;
    double min_compile_time = 1e9;
    int64_t total_rows = 0;

    // 每轮都从零开始 (包含JIT编译)
    for (int run = 0; run < config->repeat_runs; run++) {
        printf("E2E run %d/%d...\n", run + 1, config->repeat_runs);

        double e2e_start = get_time_ms();

        // 1. JIT 编译 (计时)
        JITManager *jit = jit_manager_create();
        if (!jit) continue;

        double compile_time;
        if (jit_compile_case(jit, config->case_name, "e2e", &compile_time) != 0) {
            jit_manager_destroy(jit);
            continue;
        }

        // 2. 执行一次 (计时)
        BenchmarkResult run_result = {0};
        if (run_single_test(config->case_name, config->scale, jit, &run_result) == 0) {
            double e2e_end = get_time_ms();
            double e2e_time = e2e_end - e2e_start;

            // 更新最小值
            if (e2e_time < min_e2e_time) {
                min_e2e_time = e2e_time;
                min_exec_time = run_result.exec_once_ms;
                min_compile_time = compile_time;
                total_rows = run_result.rows_processed;
            }
        }

        jit_manager_destroy(jit);
    }

    result->wallclock_ms = min_e2e_time;
    result->exec_once_ms = min_exec_time;
    result->compile_ms = min_compile_time;
    result->rows_processed = total_rows;

    return 0;
}

// 输出结果 (CSV 格式)
void output_result(const BenchmarkConfig *config, const BenchmarkResult *result) {
    double throughput = 0.0;
    if (result->exec_once_ms > 0) {
        throughput = result->rows_processed / (result->exec_once_ms / 1000.0);
    }

    printf("%s,%s,%s,min,%.3f,%.3f,%.3f,%lld,%.4f,%.0f\n",
           config->scale, config->case_name, config->mode,
           result->wallclock_ms, result->exec_once_ms, result->compile_ms,
           result->rows_processed, result->selectivity, throughput);
}

// 主基准测试函数
int32_t run_benchmark(const char *scale, const char *case_name, const char *mode) {
    BenchmarkConfig config = {
        .scale = scale,
        .case_name = case_name,
        .mode = mode,
        .warmup_runs = 3,
        .repeat_runs = 2
    };

    BenchmarkResult result = {0};
    int32_t status;

    if (strcmp(mode, "exec") == 0) {
        status = benchmark_exec_mode(&config, &result);
    } else if (strcmp(mode, "e2e") == 0) {
        status = benchmark_e2e_mode(&config, &result);
    } else {
        printf("❌ Unknown mode: %s\n", mode);
        return -1;
    }

    if (status == 0) {
        output_result(&config, &result);
    }

    return status;
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

    printf("scale,case,mode,run,ms,exec_once_ms,compile_ms,rows_processed,selectivity,throughput_rows_per_sec\n");

    return run_benchmark(scale, case_name, mode);
}
