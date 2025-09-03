#pragma once

#include "ndb_arrow_column.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Date32过滤：l_shipdate <= threshold
int32_t ndb_filter_le_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length, int32_t threshold,
                                   uint32_t *output_idx);

// Date32过滤：l_shipdate >= threshold
int32_t ndb_filter_ge_arrow_date32(const ArrowColumnView *col,
                                   int64_t batch_length, int32_t threshold,
                                   uint32_t *output_idx);

// Int32过滤：value < threshold
int32_t ndb_filter_lt_arrow_i32(const ArrowColumnView *col,
                                int64_t batch_length, int32_t threshold,
                                uint32_t *output_idx);

// Int64过滤：value BETWEEN low AND high
int32_t ndb_filter_between_arrow_i64(const ArrowColumnView *col,
                                     int64_t batch_length, int64_t low,
                                     int64_t high, uint32_t *output_idx);

// Int64过滤：value < threshold
int32_t ndb_filter_lt_arrow_i64(const ArrowColumnView *col,
                                int64_t batch_length, int64_t threshold,
                                uint32_t *output_idx);

// 链式过滤版本：在已有selection vector基础上继续过滤
int32_t ndb_filter_lt_arrow_i64_on_sel(const uint32_t *input_sel,
                                       int32_t input_count,
                                       const ArrowColumnView *col,
                                       int64_t threshold, uint32_t *output_idx);

int32_t ndb_filter_between_arrow_i64_on_sel(const uint32_t *input_sel,
                                            int32_t input_count,
                                            const ArrowColumnView *col,
                                            int64_t low, int64_t high,
                                            uint32_t *output_idx);

int32_t ndb_filter_lt_arrow_i32_on_sel(const uint32_t *input_sel,
                                       int32_t input_count,
                                       const ArrowColumnView *col,
                                       int32_t threshold, uint32_t *output_idx);

int32_t ndb_filter_lt_arrow_date32_on_sel(const uint32_t *input_sel,
                                          int32_t input_count,
                                          const ArrowColumnView *col,
                                          int32_t threshold,
                                          uint32_t *output_idx);

#ifdef __cplusplus
}
#endif
