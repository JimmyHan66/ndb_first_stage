#include "ndb_filter_kernels_arrow.h"
#include <stdint.h>
#include <stdio.h>

static inline int is_null(const uint8_t *validity, int64_t bit_offset,
                          int64_t idx) {
  if (!validity)
    return 0;

  int64_t actual_idx = bit_offset + idx;
  int64_t byte_idx = actual_idx / 8;
  int64_t bit_idx = actual_idx % 8;

  return !(validity[byte_idx] & (1 << bit_idx));
}

// Date32过滤：l_shipdate <= threshold
int32_t ndb_filter_le_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length, int32_t threshold,
                                   uint32_t *output_idx) {
  if (!col || !output_idx)
    return -1;

  if (batch_length < 0 || col->length < 0)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_DATE32 &&
      col->arrow_type_id != ARROW_TYPE_INT32) {
    printf("Error: Expected DATE32/INT32 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int32_t *values = (const int32_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;
  int64_t length = (batch_length > 0) ? batch_length : col->length;

  for (int64_t i = 0; i < length; i++) {
    int64_t actual_idx = col->offset + i;

    int is_null_val = is_null(col->validity, col->offset, i);
    if (!is_null_val) {
      int32_t value = values[actual_idx];
      int matches = (value <= threshold);

      if (matches) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Date32过滤：l_shipdate >= threshold
int32_t ndb_filter_ge_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length, int32_t threshold,
                                   uint32_t *output_idx) {
  if (!col || !output_idx)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_DATE32 &&
      col->arrow_type_id != ARROW_TYPE_INT32) {
    printf("Error: Expected DATE32/INT32 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int32_t *values = (const int32_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;
  int64_t length = (batch_length > 0) ? batch_length : col->length;

  for (int64_t i = 0; i < length; i++) {
    if (!is_null(col->validity, col->offset, i)) {
      if (values[col->offset + i] >= threshold) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Int32过滤：value < threshold
int32_t ndb_filter_lt_arrow_i32(const ArrowColumnView *col,
                                int64_t batch_length, int32_t threshold,
                                uint32_t *output_idx) {
  if (!col || !output_idx)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT32) {
    printf("Error: Expected INT32 column, got type %d\n", col->arrow_type_id);
    return -1;
  }

  const int32_t *values = (const int32_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;
  int64_t length = (batch_length > 0) ? batch_length : col->length;

  for (int64_t i = 0; i < length; i++) {
    if (!is_null(col->validity, col->offset, i)) {
      if (values[col->offset + i] < threshold) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Int64过滤：value < threshold
int32_t ndb_filter_lt_arrow_i64(const ArrowColumnView *col,
                                int64_t batch_length, int64_t threshold,
                                uint32_t *output_idx) {
  if (!col || !output_idx)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT64 &&
      col->arrow_type_id != ARROW_TYPE_DECIMAL128) {
    printf("Error: Expected INT64 or DECIMAL128 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int64_t *values = (const int64_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;
  int64_t length = (batch_length > 0) ? batch_length : col->length;

  for (int64_t i = 0; i < length; i++) {
    if (!is_null(col->validity, col->offset, i)) {
      if (values[col->offset + i] < threshold) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// Int64过滤：value BETWEEN low AND high
int32_t ndb_filter_between_arrow_i64(const ArrowColumnView *col,
                                     int64_t batch_length, int64_t low,
                                     int64_t high, uint32_t *output_idx) {
  if (!col || !output_idx)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT64 &&
      col->arrow_type_id != ARROW_TYPE_DECIMAL128) {
    printf("Error: Expected INT64 or DECIMAL128 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int64_t *values = (const int64_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;
  int64_t length = (batch_length > 0) ? batch_length : col->length;

  for (int64_t i = 0; i < length; i++) {
    if (!is_null(col->validity, col->offset, i)) {
      int64_t val = values[col->offset + i];
      if (val >= low && val <= high) {
        output_idx[count++] = (uint32_t)i;
      }
    }
  }

  return count;
}

// 链式过滤：Int64 < threshold (在selection vector基础上)
int32_t ndb_filter_lt_arrow_i64_on_sel(const uint32_t *input_sel,
                                       int32_t input_count,
                                       const ArrowColumnView *col,
                                       int64_t threshold,
                                       uint32_t *output_idx) {
  if (!input_sel || !col || !output_idx || input_count <= 0)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT64 &&
      col->arrow_type_id != ARROW_TYPE_DECIMAL128) {
    printf("Error: Expected INT64 or DECIMAL128 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int64_t *values = (const int64_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    if (!is_null(col->validity, col->offset, row_idx)) {
      if (values[col->offset + row_idx] < threshold) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}

// 链式过滤：Int64 BETWEEN (在selection vector基础上)
int32_t ndb_filter_between_arrow_i64_on_sel(const uint32_t *input_sel,
                                            int32_t input_count,
                                            const ArrowColumnView *col,
                                            int64_t low, int64_t high,
                                            uint32_t *output_idx) {
  if (!input_sel || !col || !output_idx || input_count <= 0)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT64 &&
      col->arrow_type_id != ARROW_TYPE_DECIMAL128) {
    printf("Error: Expected INT64 or DECIMAL128 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int64_t *values = (const int64_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    if (!is_null(col->validity, col->offset, row_idx)) {
      int64_t val = values[col->offset + row_idx];
      if (val >= low && val <= high) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}

// 链式过滤：Int32 < threshold (在selection vector基础上)
int32_t ndb_filter_lt_arrow_i32_on_sel(const uint32_t *input_sel,
                                       int32_t input_count,
                                       const ArrowColumnView *col,
                                       int32_t threshold,
                                       uint32_t *output_idx) {
  if (!input_sel || !col || !output_idx || input_count <= 0)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_INT32) {
    printf("Error: Expected INT32 column, got type %d\n", col->arrow_type_id);
    return -1;
  }

  const int32_t *values = (const int32_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    if (!is_null(col->validity, col->offset, row_idx)) {
      if (values[col->offset + row_idx] < threshold) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}

// 链式过滤：Date32 < threshold (在selection vector基础上)
int32_t ndb_filter_lt_arrow_date32_on_sel(const uint32_t *input_sel,
                                          int32_t input_count,
                                          const ArrowColumnView *col,
                                          int32_t threshold,
                                          uint32_t *output_idx) {
  if (!input_sel || !col || !output_idx || input_count <= 0)
    return -1;

  if (col->arrow_type_id != ARROW_TYPE_DATE32 &&
      col->arrow_type_id != ARROW_TYPE_INT32) {
    printf("Error: Expected DATE32/INT32 column, got type %d\n",
           col->arrow_type_id);
    return -1;
  }

  const int32_t *values = (const int32_t *)col->values;
  if (!values)
    return -1;

  int32_t count = 0;

  for (int32_t i = 0; i < input_count; i++) {
    uint32_t row_idx = input_sel[i];
    if (!is_null(col->validity, col->offset, row_idx)) {
      if (values[col->offset + row_idx] < threshold) {
        output_idx[count++] = row_idx;
      }
    }
  }

  return count;
}
