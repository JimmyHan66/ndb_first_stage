#include "ndb_arrow_batch.h"
#include <stdlib.h>
#include <string.h>

int32_t ndb_arrow_batch_init(ArrowBatch *batch) {
  if (!batch)
    return -1;

  memset(batch, 0, sizeof(ArrowBatch));
  return 0;
}

void ndb_arrow_batch_cleanup(ArrowBatch *batch) {
  if (!batch)
    return;

  // 清理Arrow C Data Interface资源
  if (batch->c_array) {
    if (batch->c_array->release) {
      batch->c_array->release(batch->c_array);
    }
    free(batch->c_array);
    batch->c_array = NULL;
  }

  if (batch->c_schema) {
    if (batch->c_schema->release) {
      batch->c_schema->release(batch->c_schema);
    }
    free(batch->c_schema);
    batch->c_schema = NULL;
  }

  // 注意：arrow_batch_ptr的清理由C++端负责
  memset(batch, 0, sizeof(ArrowBatch));
}
