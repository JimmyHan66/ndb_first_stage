#pragma once

#include <stdint.h>

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

typedef struct {
  SimpleColumnView *columns; // 列数组
  int32_t num_cols;          // 列数
  int64_t num_rows;          // 行数
} SimpleBatch;

// Arrow 类型常量
#define ARROW_TYPE_DATE32 7
#define ARROW_TYPE_INT64 3
#define ARROW_TYPE_DECIMAL128 9
