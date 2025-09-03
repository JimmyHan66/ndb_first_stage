#include "ndb_selvec.h"
#include <stdlib.h>
#include <string.h>

SelVec *selvec_create(int32_t capacity) {
  SelVec *sel = (SelVec *)malloc(sizeof(SelVec));
  if (!sel)
    return NULL;

  sel->idx = (uint32_t *)malloc(capacity * sizeof(uint32_t));
  if (!sel->idx) {
    free(sel);
    return NULL;
  }

  sel->count = 0;
  sel->cap = capacity;
  return sel;
}

void selvec_destroy(SelVec *sel) {
  if (sel) {
    free(sel->idx);
    free(sel);
  }
}

void selvec_reset(SelVec *sel) {
  if (sel) {
    sel->count = 0;
  }
}

int32_t selvec_add_index(SelVec *sel, uint32_t idx) {
  if (!sel || !sel->idx)
    return -1;

  if (sel->count >= sel->cap)
    return -1; // 容量不足

  sel->idx[sel->count++] = idx;
  return 0;
}
