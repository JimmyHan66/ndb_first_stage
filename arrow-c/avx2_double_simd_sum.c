#include "avx2_double_simd_sum.h"

// 内部函数：对4个double进行AVX2水平求和
static double avx2_horizontal_sum_4_double(const double *data) {
  __m256d avx_data = _mm256_loadu_pd(data);

  // 水平求和
  __m128d sum1 = _mm_add_pd(_mm256_castpd256_pd128(avx_data),
                            _mm256_extractf128_pd(avx_data, 1));
  __m128d sum2 = _mm_add_pd(sum1, _mm_unpackhi_pd(sum1, sum1));

  return _mm_cvtsd_f64(sum2);
}

// 内部函数：对缓冲区进行垂直AVX2运算，结果存入前4个位置
static void avx2_vertical_accumulate(double *buffer, int count) {
  // count必须是4的倍数且大于4
  if (count < 8 || count % 4 != 0)
    return;

  // 加载前4个double作为累加器
  __m256d accumulator = _mm256_loadu_pd(buffer);

  // 从第5个位置开始，每4个double进行垂直相加
  for (int i = 4; i < count; i += 4) {
    __m256d current = _mm256_loadu_pd(buffer + i);
    accumulator = _mm256_add_pd(accumulator, current);
  }

  // 将结果存回前4个位置
  _mm256_storeu_pd(buffer, accumulator);
}

AVX2DoubleSumBuffer *avx2_double_sum_create(int initial_capacity) {
  if (initial_capacity <= 0) {
    initial_capacity = 8; // 默认容量
  }

  // 确保容量是4的倍数，以优化AVX2性能
  initial_capacity = ((initial_capacity + 3) / 4) * 4;

  AVX2DoubleSumBuffer *buffer =
      (AVX2DoubleSumBuffer *)malloc(sizeof(AVX2DoubleSumBuffer));
  if (!buffer)
    return NULL;

  buffer->data = (double *)aligned_alloc(32, initial_capacity * sizeof(double));
  if (!buffer->data) {
    free(buffer);
    return NULL;
  }

  buffer->capacity = initial_capacity;
  buffer->count = 0;

  return buffer;
}

void avx2_double_sum_destroy(AVX2DoubleSumBuffer *buffer) {
  if (buffer) {
    if (buffer->data) {
      free(buffer->data);
    }
    free(buffer);
  }
}

void avx2_double_sum_add(AVX2DoubleSumBuffer *buffer, double value) {
  if (!buffer)
    return;

  // 检查缓冲区是否已满
  if (buffer->count >= buffer->capacity) {
    // 当缓冲区满时，进行AVX2垂直运算
    if (buffer->count >= 4) {
      avx2_vertical_accumulate(buffer->data, buffer->count);
      // 运算结果已存入前4个位置，新数据从第5个位置开始写入
      buffer->count = 4;
    }
  }

  // 添加新值
  buffer->data[buffer->count] = value;
  buffer->count++;
}

void avx2_double_sum_add_batch(AVX2DoubleSumBuffer *buffer,
                               const double *values, int count) {
  if (!buffer || !values || count <= 0)
    return;

  for (int i = 0; i < count; i++) {
    avx2_double_sum_add(buffer, values[i]);
  }
}

double avx2_double_sum_get_result(AVX2DoubleSumBuffer *buffer) {
  if (!buffer || buffer->count == 0)
    return 0.0;

  double result = 0.0;

  // 根据缓冲区中数据的数量进行不同处理
  if (buffer->count < 4) {
    // 小于4个double，直接相加
    for (int i = 0; i < buffer->count; i++) {
      result += buffer->data[i];
    }
  } else if (buffer->count % 4 == 0) {
    // 4个的整数倍，直接AVX2垂直相加后水平相加
    __m256d accumulator = _mm256_loadu_pd(buffer->data);

    for (int i = 4; i < buffer->count; i += 4) {
      __m256d current = _mm256_loadu_pd(buffer->data + i);
      accumulator = _mm256_add_pd(accumulator, current);
    }

    // 水平求和accumulator
    result += avx2_horizontal_sum_4_double((double *)&accumulator);
  } else {
    // 4个的整数倍有余，先处理整数倍部分
    int aligned_count = (buffer->count / 4) * 4;
    __m256d accumulator = _mm256_loadu_pd(buffer->data);

    for (int i = 4; i < aligned_count; i += 4) {
      __m256d current = _mm256_loadu_pd(buffer->data + i);
      accumulator = _mm256_add_pd(accumulator, current);
    }

    // 处理剩余部分，不足4个的补零
    double padded[4] = {0.0, 0.0, 0.0, 0.0};
    int remaining = buffer->count - aligned_count;
    for (int i = 0; i < remaining; i++) {
      padded[i] = buffer->data[aligned_count + i];
    }

    __m256d remainder = _mm256_loadu_pd(padded);
    accumulator = _mm256_add_pd(accumulator, remainder);

    // 水平求和accumulator
    result += avx2_horizontal_sum_4_double((double *)&accumulator);
  }

  return result;
}

void avx2_double_sum_reset(AVX2DoubleSumBuffer *buffer) {
  if (!buffer)
    return;

  buffer->count = 0;
}

void avx2_double_sum_flush(AVX2DoubleSumBuffer *buffer) {
  if (!buffer || buffer->count <= 4)
    return;

  // 强制进行垂直累积，将结果存入前4个位置
  avx2_vertical_accumulate(buffer->data, buffer->count);
  buffer->count = 4;
}
