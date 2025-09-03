#pragma once
#include "ndb_arrow_batch.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Parquet扫描描述符
typedef struct {
  const char *const *file_paths;  // Parquet文件路径数组
  int32_t num_files;              // 文件数量
  const char *const *needed_cols; // 需要的列名数组
  int32_t num_cols;               // 列数量
  int32_t batch_size;             // 批大小
} TableScanDesc;

typedef struct ScanHandle ScanHandle; // 不透明句柄

// C-compatible API for scan runtime (优化版 - 直接返回ArrowBatch)
ScanHandle *rt_scan_open_parquet(const TableScanDesc *desc);

// 1=有批；0=eof；<0=err
int32_t rt_scan_next(ScanHandle *handle, ArrowBatch *out_batch);

// 关闭/释放
void rt_scan_close(ScanHandle *handle);

#ifdef __cplusplus
}
#endif
