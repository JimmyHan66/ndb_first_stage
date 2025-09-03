#ifndef NDB_AGG_CALLBACK_FACTORY_H
#define NDB_AGG_CALLBACK_FACTORY_H

#include "ndb_agg_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

// 工厂函数 - 创建Q1和Q6的AggCallback
AggCallback* create_q1_agg_callback(void);
AggCallback* create_q6_agg_callback(void);

// 销毁函数
void destroy_agg_callback(AggCallback* callback);

#ifdef __cplusplus
}
#endif

#endif // NDB_AGG_CALLBACK_FACTORY_H
