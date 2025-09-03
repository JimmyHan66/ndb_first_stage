#pragma once
#include "ndb_arrow_batch.h"
#include "ndb_selvec.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  void (*process_batch)(const ArrowBatch *batch, const SelVec *sel,
                        void *agg_state);
  void (*finalize)(void *agg_state, void *result);
  void *agg_state;
} AggCallback;

#ifdef __cplusplus
}
#endif
