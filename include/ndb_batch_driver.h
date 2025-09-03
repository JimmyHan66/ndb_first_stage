#pragma once
#include "ndb_agg_callback.h"
#include "ndb_scan_runtime.h"

#include "ndb_selvec.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int32_t ndb_q1_batch_driver(ScanHandle *scan_handle, AggCallback *agg_callback);

int32_t ndb_q6_batch_driver(ScanHandle *scan_handle, AggCallback *agg_callback);

#ifdef __cplusplus
}
#endif
