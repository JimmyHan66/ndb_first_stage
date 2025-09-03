#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  uint32_t *idx; // 选中行号 [0..N-1]
  int32_t count; // 选中个数
  int32_t cap;   // 预分配容量（>= batch_size）
} SelVec;

// SelVec 管理函数
SelVec *selvec_create(int32_t capacity);
void selvec_destroy(SelVec *sel);
void selvec_reset(SelVec *sel);

// 安全的添加函数，带容量检查
int32_t selvec_add_index(SelVec *sel, uint32_t idx);

#ifdef __cplusplus
}
#endif
