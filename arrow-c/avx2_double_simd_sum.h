#ifndef AVX2_DOUBLE_SIMD_SUM_H
#define AVX2_DOUBLE_SIMD_SUM_H

#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// AVX2 double SIMD缓冲区结构体
typedef struct {
  double *data; // 数据缓冲区
  int capacity; // 缓冲区容量
  int count;    // 当前数据个数
} AVX2DoubleSumBuffer;

// 接口函数声明

/**
 * 创建AVX2 double SIMD求和缓冲区
 * @param initial_capacity 初始容量，建议为8的倍数以优化SIMD性能
 * @return 初始化的缓冲区指针，失败返回NULL
 */
AVX2DoubleSumBuffer *avx2_double_sum_create(int initial_capacity);

/**
 * 销毁AVX2 double SIMD求和缓冲区
 * @param buffer 要销毁的缓冲区
 */
void avx2_double_sum_destroy(AVX2DoubleSumBuffer *buffer);

/**
 * 添加单个double值到缓冲区并进行AVX2优化的累加
 * @param buffer 缓冲区
 * @param value 要添加的double值
 */
void avx2_double_sum_add(AVX2DoubleSumBuffer *buffer, double value);

/**
 * 批量添加多个double值到缓冲区
 * @param buffer 缓冲区
 * @param values double值数组
 * @param count 值的个数
 */
void avx2_double_sum_add_batch(AVX2DoubleSumBuffer *buffer,
                               const double *values, int count);

/**
 * 获取当前的累计和
 * @param buffer 缓冲区
 * @return 当前累计和
 */
double avx2_double_sum_get_result(AVX2DoubleSumBuffer *buffer);

/**
 * 重置缓冲区，清空所有数据
 * @param buffer 缓冲区
 */
void avx2_double_sum_reset(AVX2DoubleSumBuffer *buffer);

/**
 * 强制处理缓冲区中剩余的数据
 * @param buffer 缓冲区
 */
void avx2_double_sum_flush(AVX2DoubleSumBuffer *buffer);

#endif // AVX2_DOUBLE_SIMD_SUM_H
