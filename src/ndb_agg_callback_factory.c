#include "ndb_agg_callback_factory.h"
#include "ndb_agg_state.h"
#include <stdlib.h>
#include <stdio.h>

// Q6包装器结构
typedef struct {
    Q6AggregationState *agg_state;
} Q6CallbackWrapper;

// Q1包装器结构
typedef struct {
    Q1AggregationState *agg_state;
} Q1CallbackWrapper;

// Q6回调函数实现
void q6_process_batch_callback(const ArrowBatch *batch, const SelVec *sel, void *state) {
    Q6CallbackWrapper *wrapper = (Q6CallbackWrapper*)state;

    // 直接调用增量聚合函数，零拷贝
    q6_agg_process_batch(wrapper->agg_state,
                        batch->c_array,
                        sel->idx,
                        sel->count);
}

void q6_finalize_callback(void *state, void *result) {
    Q6CallbackWrapper *wrapper = (Q6CallbackWrapper*)state;
    q6_agg_finalize(wrapper->agg_state);
    // result参数这里暂时不使用，结果直接打印输出
}

// Q1回调函数实现
void q1_process_batch_callback(const ArrowBatch *batch, const SelVec *sel, void *state) {
    Q1CallbackWrapper *wrapper = (Q1CallbackWrapper*)state;

    q1_agg_process_batch(wrapper->agg_state,
                        batch->c_array,
                        sel->idx,
                        sel->count);
}

void q1_finalize_callback(void *state, void *result) {
    Q1CallbackWrapper *wrapper = (Q1CallbackWrapper*)state;
    q1_agg_finalize(wrapper->agg_state);  // 内部执行pdqsort + 输出
    // result参数这里暂时不使用，结果直接打印输出
}

// 工厂函数实现
AggCallback* create_q1_agg_callback(void) {
    AggCallback *callback = (AggCallback*)malloc(sizeof(AggCallback));
    if (!callback) {
        return NULL;
    }

    Q1CallbackWrapper *wrapper = (Q1CallbackWrapper*)malloc(sizeof(Q1CallbackWrapper));
    if (!wrapper) {
        free(callback);
        return NULL;
    }

    wrapper->agg_state = q1_agg_init();
    if (!wrapper->agg_state) {
        free(wrapper);
        free(callback);
        return NULL;
    }

    callback->process_batch = q1_process_batch_callback;
    callback->finalize = q1_finalize_callback;
    callback->agg_state = wrapper;

    return callback;
}

AggCallback* create_q6_agg_callback(void) {
    AggCallback *callback = (AggCallback*)malloc(sizeof(AggCallback));
    if (!callback) {
        return NULL;
    }

    Q6CallbackWrapper *wrapper = (Q6CallbackWrapper*)malloc(sizeof(Q6CallbackWrapper));
    if (!wrapper) {
        free(callback);
        return NULL;
    }

    wrapper->agg_state = q6_agg_init();
    if (!wrapper->agg_state) {
        free(wrapper);
        free(callback);
        return NULL;
    }

    callback->process_batch = q6_process_batch_callback;
    callback->finalize = q6_finalize_callback;
    callback->agg_state = wrapper;

    return callback;
}

// 销毁函数
void destroy_agg_callback(AggCallback* callback) {
    if (!callback) {
        return;
    }

    if (callback->agg_state) {
        // 需要判断是Q1还是Q6的wrapper
        // 这里简单处理，实际可能需要更好的类型识别机制
        // 暂时通过尝试两种类型的销毁来处理
        Q1CallbackWrapper *q1_wrapper = (Q1CallbackWrapper*)callback->agg_state;
        if (q1_wrapper && q1_wrapper->agg_state) {
            q1_agg_destroy(q1_wrapper->agg_state);
        } else {
            Q6CallbackWrapper *q6_wrapper = (Q6CallbackWrapper*)callback->agg_state;
            if (q6_wrapper && q6_wrapper->agg_state) {
                q6_agg_destroy(q6_wrapper->agg_state);
            }
        }
        free(callback->agg_state);
    }

    free(callback);
}
