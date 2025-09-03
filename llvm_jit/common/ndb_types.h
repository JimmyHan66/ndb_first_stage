#pragma once

#include <stdint.h>
// Include Arrow column definitions for consistent type IDs
#include "../../include/ndb_arrow_column.h"

// 简化的数据结构，用于 LLVM JIT
typedef struct {
  const int32_t *values;   // 数据指针
  const uint8_t *validity; // NULL bitmap
  int64_t length;          // 数组长度
  int64_t offset;          // 偏移量
  int32_t arrow_type_id;   // Arrow 类型ID
} SimpleColumnView;

typedef struct {
  uint32_t *idx;    // 选中行号
  int32_t count;    // 选中个数
  int32_t capacity; // 容量
} SimpleSelVec;

#define MAX_COLUMNS 16

typedef struct {
  SimpleColumnView columns[MAX_COLUMNS]; // 固定大小的列数组
  int32_t num_cols;          // 列数
  int64_t num_rows;          // 行数
} SimpleBatch;

// Arrow 类型常量已在 ndb_arrow_column.h 中定义为 enum ArrowTypeId
