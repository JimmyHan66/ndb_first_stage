#pragma once

#include "ndb_arrow_batch.h"
#include <arrow/c/abi.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ArrowColumnView {
  const struct ArrowArray *arrow_array;   // Arrow列数组
  const struct ArrowSchema *arrow_schema; // Arrow列模式

  const uint8_t *validity; // buffers[0] - 有效性位图
  const void *values;      // buffers[1] - 数据值(定长类型)
  const int32_t *offsets;  // buffers[1] - 偏移数组(变长类型)
  const uint8_t *data;     // buffers[2] - 数据区(变长类型)

  int32_t arrow_type_id; // Arrow类型ID (简化映射)
  int32_t elem_size;     // 元素大小
  int64_t length;        // 行数
  int64_t offset;        // 起始偏移
} ArrowColumnView;

enum ArrowTypeId {
  ARROW_TYPE_BOOL = 1,
  ARROW_TYPE_INT32 = 2,
  ARROW_TYPE_INT64 = 3,
  ARROW_TYPE_FLOAT = 4,
  ARROW_TYPE_DOUBLE = 5,
  ARROW_TYPE_STRING = 6,
  ARROW_TYPE_DATE32 = 7,
  ARROW_TYPE_TIMESTAMP = 8,
  ARROW_TYPE_DECIMAL128 = 9, 
  ARROW_TYPE_UNKNOWN = -1
};

int32_t ndb_get_arrow_column(const ArrowBatch *batch, int32_t col_idx,
                             ArrowColumnView *out_col);

int32_t ndb_analyze_arrow_column(ArrowColumnView *col);

int32_t ndb_infer_arrow_type_id(const char *format);

#ifdef __cplusplus
}
#endif
