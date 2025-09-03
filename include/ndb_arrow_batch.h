#pragma once

#include <arrow/c/abi.h>
#include <stdint.h>

// 统一错误码定义
#define NDB_SUCCESS 0
#define NDB_ERROR_NULL_PARAM -1
#define NDB_ERROR_INVALID_TYPE -2
#define NDB_ERROR_BOUNDS_CHECK -3
#define NDB_ERROR_MEMORY_ALLOC -4
#define NDB_ERROR_ARROW_EXPORT -5

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ArrowBatch {
  struct ArrowArray *c_array;   // Arrow C Data Interface数组
  struct ArrowSchema *c_schema; // Arrow C Data Interface模式
  int64_t num_rows;             // 行数
  int32_t num_cols;             // 列数
  void *arrow_batch_ptr;
} ArrowBatch;

int32_t ndb_arrow_batch_init(ArrowBatch *batch);
void ndb_arrow_batch_cleanup(ArrowBatch *batch);

#ifdef __cplusplus
}
#endif
