#include "ndb_arrow_column.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int32_t ndb_infer_arrow_type_id(const char *format) {
  if (!format)
    return ARROW_TYPE_UNKNOWN;

  // Arrow格式字符串到类型ID的映射
  if (strcmp(format, "b") == 0)
    return ARROW_TYPE_BOOL;
  if (strcmp(format, "i") == 0)
    return ARROW_TYPE_INT32;
  if (strcmp(format, "l") == 0)
    return ARROW_TYPE_INT64;
  if (strcmp(format, "f") == 0)
    return ARROW_TYPE_FLOAT;
  if (strcmp(format, "g") == 0)
    return ARROW_TYPE_DOUBLE;
  if (strcmp(format, "u") == 0)
    return ARROW_TYPE_STRING;
  if (strcmp(format, "U") == 0)
    return ARROW_TYPE_STRING;
  if (strcmp(format, "tdD") == 0)
    return ARROW_TYPE_DATE32;
  if (strncmp(format, "ts", 2) == 0)
    return ARROW_TYPE_TIMESTAMP;
  if (strncmp(format, "d:", 2) == 0)
    return ARROW_TYPE_DECIMAL128;

  return ARROW_TYPE_UNKNOWN;
}

int32_t ndb_get_arrow_column(const ArrowBatch *batch, int32_t col_idx,
                             ArrowColumnView *out_col) {
  if (!batch || !out_col || col_idx < 0 || col_idx >= batch->num_cols) {
    return -1;
  }

  if (!batch->c_array || !batch->c_schema) {
    printf("Error: ArrowBatch missing c_array or c_schema\n");
    return -1;
  }

  if (!batch->c_array->children || !batch->c_schema->children) {
    printf("Error: ArrowBatch missing children arrays\n");
    return -1;
  }

  // 获取指定列的Arrow数据
  out_col->arrow_array = batch->c_array->children[col_idx];
  out_col->arrow_schema = batch->c_schema->children[col_idx];

  if (!out_col->arrow_array || !out_col->arrow_schema) {
    printf("Error: Column %d has null array or schema\n", col_idx);
    return -1;
  }

  // 分析列并设置快速访问字段
  return ndb_analyze_arrow_column(out_col);
}

int32_t ndb_analyze_arrow_column(ArrowColumnView *col) {
  if (!col || !col->arrow_array || !col->arrow_schema) {
    return -1;
  }

  const struct ArrowArray *array = col->arrow_array;
  const struct ArrowSchema *schema = col->arrow_schema;

  // 推断类型
  col->arrow_type_id = ndb_infer_arrow_type_id(schema->format);
  col->length = array->length;
  col->offset = array->offset;

  // 检查缓冲区数量
  if (array->n_buffers < 2) {

    return -1;
  }

  // 设置快速访问字段
  col->validity =
      (array->buffers[0]) ? (const uint8_t *)array->buffers[0] : NULL;

  if (col->arrow_type_id == ARROW_TYPE_STRING) {
    // 变长类型需要3个缓冲区
    if (array->n_buffers < 3) {

      return -1;
    }
    col->elem_size = 0;
    col->offsets = (const int32_t *)array->buffers[1];
    col->data = (const uint8_t *)array->buffers[2];
    col->values = NULL;
  } else {
    // 定长类型
    switch (col->arrow_type_id) {
    case ARROW_TYPE_BOOL:
      col->elem_size = 1;
      break;
    case ARROW_TYPE_INT32:
    case ARROW_TYPE_FLOAT:
    case ARROW_TYPE_DATE32:
      col->elem_size = 4;
      break;
    case ARROW_TYPE_INT64:
    case ARROW_TYPE_DOUBLE:
    case ARROW_TYPE_TIMESTAMP:
      col->elem_size = 8;
      break;
    case ARROW_TYPE_DECIMAL128:
      col->elem_size = 8;
      break;
    default:
      col->elem_size = 8; 
      break;
    }

    col->values = (const void *)array->buffers[1];
    col->offsets = NULL;
    col->data = NULL;
  }

  return 0;
}
