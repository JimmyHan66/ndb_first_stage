#include "ndb_types.h"

// 简化的NULL检查函数
static inline int is_null(const uint8_t *validity, int64_t bit_offset,
                          int64_t idx) {
  if (!validity)
    return 0;

  int64_t actual_idx = bit_offset + idx;
  int64_t byte_idx = actual_idx / 8;
  int64_t bit_idx = actual_idx % 8;

  return !(validity[byte_idx] & (1 << bit_idx));
}

// Date32过滤：value <= threshold
int32_t filter_le_date32(const SimpleColumnView *col, int32_t threshold,
                         uint32_t *output_idx) {
  if (!col || !col->values || !output_idx)
    return -1;

  const int32_t *values = col->values;
  int32_t count = 0;

  for (int64_t i = 0; i < col->length; i++) {
    int64_t actual_idx = col->offset + i;

    if (!is_null(col->validity, col->offset, i)) {
      if (values[actual_idx] <= threshold) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Date32过滤：value >= threshold
int32_t filter_ge_date32(const SimpleColumnView *col, int32_t threshold,
                         uint32_t *output_idx) {
  if (!col || !col->values || !output_idx)
    return -1;

  const int32_t *values = col->values;
  int32_t count = 0;

  for (int64_t i = 0; i < col->length; i++) {
    int64_t actual_idx = col->offset + i;

    if (!is_null(col->validity, col->offset, i)) {
      if (values[actual_idx] >= threshold) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Date32过滤：value < threshold (链式，基于selection vector)
int32_t filter_lt_date32_on_sel(const uint32_t *input_sel, int32_t input_count,
                                const SimpleColumnView *col, int32_t threshold,
                                uint32_t *output_idx) {
  if (!input_sel || !col || !col->values || !output_idx || input_count <= 0)
    return -1;

  const int32_t *values = col->values;
  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    int64_t actual_idx = col->offset + row_idx;

    if (!is_null(col->validity, col->offset, row_idx)) {
      if (values[actual_idx] < threshold) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}

// Int64过滤：value BETWEEN low AND high (链式)
int32_t filter_between_i64_on_sel(const uint32_t *input_sel,
                                  int32_t input_count,
                                  const SimpleColumnView *col, int64_t low,
                                  int64_t high, uint32_t *output_idx) {
  if (!input_sel || !col || !col->values || !output_idx || input_count <= 0)
    return -1;

  const int64_t *values = (const int64_t *)col->values;
  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    int64_t actual_idx = col->offset + row_idx;

    if (!is_null(col->validity, col->offset, row_idx)) {
      int64_t val = values[actual_idx];
      if (val >= low && val <= high) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}

// Int64过滤：value < threshold (链式)
int32_t filter_lt_i64_on_sel(const uint32_t *input_sel, int32_t input_count,
                             const SimpleColumnView *col, int64_t threshold,
                             uint32_t *output_idx) {
  if (!input_sel || !col || !col->values || !output_idx || input_count <= 0)
    return -1;

  const int64_t *values = (const int64_t *)col->values;
  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    int64_t actual_idx = col->offset + row_idx;

    if (!is_null(col->validity, col->offset, row_idx)) {
      if (values[actual_idx] < threshold) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}
