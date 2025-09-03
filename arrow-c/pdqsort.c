#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// 常量定义
#define INSERTION_SORT_THRESHOLD 24
#define NINTHER_THRESHOLD 128
#define PARTIAL_INSERTION_SORT_LIMIT 8
#define BLOCK_SIZE 64

// 比较函数类型定义
typedef int (*compare_func_t)(const void *a, const void *b);

// 交换两个元素
static inline void swap_elements(void *a, void *b, size_t size) {
  if (a == b)
    return;

  char *pa = (char *)a;
  char *pb = (char *)b;

  // 对于小尺寸，直接交换
  if (size <= 8) {
    char temp[8];
    memcpy(temp, pa, size);
    memcpy(pa, pb, size);
    memcpy(pb, temp, size);
  } else {
    // 对于大尺寸，使用临时缓冲区
    char *temp = malloc(size);
    memcpy(temp, pa, size);
    memcpy(pa, pb, size);
    memcpy(pb, temp, size);
    free(temp);
  }
}

// 获取数组中指定位置的元素指针
static inline void *get_element(void *base, size_t index, size_t size) {
  return (char *)base + index * size;
}

// 插入排序 - 用于小数组
static void insertion_sort(void *base, size_t left, size_t right, size_t size,
                           compare_func_t cmp) {
  for (size_t i = left + 1; i <= right; i++) {
    void *key = get_element(base, i, size);
    char *temp = malloc(size);
    memcpy(temp, key, size);

    size_t j = i;
    while (j > left && cmp(get_element(base, j - 1, size), temp) > 0) {
      memcpy(get_element(base, j, size), get_element(base, j - 1, size), size);
      j--;
    }
    memcpy(get_element(base, j, size), temp, size);
    free(temp);
  }
}

// 部分插入排序 - 用于接近排序的数组
static bool partial_insertion_sort(void *base, size_t left, size_t right,
                                   size_t size, compare_func_t cmp) {
  if (right - left <= 1)
    return true;

  size_t limit = 0;
  for (size_t i = left + 1; i <= right; i++) {
    if (limit > PARTIAL_INSERTION_SORT_LIMIT)
      return false;

    void *key = get_element(base, i, size);
    if (cmp(get_element(base, i - 1, size), key) <= 0)
      continue;

    char *temp = malloc(size);
    memcpy(temp, key, size);

    size_t j = i;
    while (j > left) {
      if (cmp(get_element(base, j - 1, size), temp) <= 0)
        break;
      memcpy(get_element(base, j, size), get_element(base, j - 1, size), size);
      j--;
    }
    memcpy(get_element(base, j, size), temp, size);
    free(temp);

    limit += i - j;
  }
  return true;
}

// 堆化操作
static void sift_down(void *base, size_t start, size_t end, size_t size,
                      compare_func_t cmp) {
  size_t root = start;

  while (2 * root + 1 <= end) {
    size_t child = 2 * root + 1;
    size_t swap_idx = root;

    if (cmp(get_element(base, swap_idx, size), get_element(base, child, size)) <
        0) {
      swap_idx = child;
    }
    if (child + 1 <= end && cmp(get_element(base, swap_idx, size),
                                get_element(base, child + 1, size)) < 0) {
      swap_idx = child + 1;
    }

    if (swap_idx == root) {
      return;
    } else {
      swap_elements(get_element(base, root, size),
                    get_element(base, swap_idx, size), size);
      root = swap_idx;
    }
  }
}

// 堆排序
static void heapsort(void *base, size_t left, size_t right, size_t size,
                     compare_func_t cmp) {
  if (right <= left)
    return;

  size_t len = right - left + 1;

  // 构建堆
  for (size_t i = (len - 2) / 2; i != (size_t)-1; i--) {
    sift_down(base, left + i, right, size, cmp);
  }

  // 排序
  for (size_t i = right; i > left; i--) {
    swap_elements(get_element(base, left, size), get_element(base, i, size),
                  size);
    sift_down(base, left, i - 1, size, cmp);
  }
}

// 选择pivot的ninther方法
static size_t ninther(void *base, size_t a, size_t b, size_t c, size_t d,
                      size_t e, size_t f, size_t g, size_t h, size_t i,
                      size_t size, compare_func_t cmp) {
  // 找到每组的中位数
  if (cmp(get_element(base, a, size), get_element(base, b, size)) > 0) {
    size_t temp = a;
    a = b;
    b = temp;
  }
  if (cmp(get_element(base, b, size), get_element(base, c, size)) > 0) {
    size_t temp = b;
    b = c;
    c = temp;
  }
  if (cmp(get_element(base, a, size), get_element(base, b, size)) > 0) {
    b = a;
  }

  if (cmp(get_element(base, d, size), get_element(base, e, size)) > 0) {
    size_t temp = d;
    d = e;
    e = temp;
  }
  if (cmp(get_element(base, e, size), get_element(base, f, size)) > 0) {
    size_t temp = e;
    e = f;
    f = temp;
  }
  if (cmp(get_element(base, d, size), get_element(base, e, size)) > 0) {
    e = d;
  }

  if (cmp(get_element(base, g, size), get_element(base, h, size)) > 0) {
    size_t temp = g;
    g = h;
    h = temp;
  }
  if (cmp(get_element(base, h, size), get_element(base, i, size)) > 0) {
    size_t temp = h;
    h = i;
    i = temp;
  }
  if (cmp(get_element(base, g, size), get_element(base, h, size)) > 0) {
    h = g;
  }

  // 找到三个中位数的中位数
  if (cmp(get_element(base, b, size), get_element(base, e, size)) > 0) {
    size_t temp = b;
    b = e;
    e = temp;
  }
  if (cmp(get_element(base, e, size), get_element(base, h, size)) > 0) {
    size_t temp = e;
    e = h;
    h = temp;
  }
  if (cmp(get_element(base, b, size), get_element(base, e, size)) > 0) {
    e = b;
  }

  return e;
}

// 三路分区
static void partition_3way(void *base, size_t left, size_t right,
                           size_t pivot_idx, size_t *eq_left, size_t *eq_right,
                           size_t size, compare_func_t cmp) {
  // 将pivot移到开头
  swap_elements(get_element(base, left, size),
                get_element(base, pivot_idx, size), size);
  void *pivot = get_element(base, left, size);

  size_t i = left + 1;
  size_t lt = left;
  size_t gt = right;

  while (i <= gt) {
    int cmp_result = cmp(get_element(base, i, size), pivot);

    if (cmp_result < 0) {
      swap_elements(get_element(base, lt, size), get_element(base, i, size),
                    size);
      lt++;
      i++;
    } else if (cmp_result > 0) {
      swap_elements(get_element(base, i, size), get_element(base, gt, size),
                    size);
      gt--;
    } else {
      i++;
    }
  }

  *eq_left = lt;
  *eq_right = gt;
}

// 检查是否为坏pivot（导致不平衡分区）
static bool is_bad_pivot(size_t left, size_t right, size_t eq_left,
                         size_t eq_right) {
  size_t len = right - left + 1;
  size_t left_size = eq_left - left;
  size_t right_size = right - eq_right;

  // 如果一边太小（少于1/8），认为是坏pivot
  return left_size < len / 8 || right_size < len / 8;
}

// pdqsort主递归函数(这部分JIT化)
static void pdqsort_loop(void *base, size_t left, size_t right, size_t size,
                         compare_func_t cmp, int bad_allowed, bool leftmost) {
  while (true) {
    size_t len = right - left + 1;

    // 小数组使用插入排序
    if (len <= INSERTION_SORT_THRESHOLD) {
      insertion_sort(base, left, right, size, cmp);
      return;
    }

    // 尝试部分插入排序
    if (leftmost && partial_insertion_sort(base, left, right, size, cmp)) {
      return;
    }

    // 如果坏pivot太多，使用堆排序
    if (bad_allowed == 0) {
      heapsort(base, left, right, size, cmp);
      return;
    }

    // 选择pivot
    size_t pivot_idx;
    if (len > NINTHER_THRESHOLD) {
      size_t step = len / 8;
      pivot_idx = ninther(base, left, left + step, left + 2 * step,
                          left + 3 * step, left + 4 * step, left + 5 * step,
                          left + 6 * step, left + 7 * step, right, size, cmp);
    } else {
      // 简单的三数取中
      size_t mid = left + len / 2;
      if (cmp(get_element(base, left, size), get_element(base, mid, size)) >
          0) {
        if (cmp(get_element(base, mid, size), get_element(base, right, size)) >
            0) {
          pivot_idx = mid;
        } else if (cmp(get_element(base, left, size),
                       get_element(base, right, size)) > 0) {
          pivot_idx = right;
        } else {
          pivot_idx = left;
        }
      } else {
        if (cmp(get_element(base, left, size), get_element(base, right, size)) >
            0) {
          pivot_idx = left;
        } else if (cmp(get_element(base, mid, size),
                       get_element(base, right, size)) > 0) {
          pivot_idx = right;
        } else {
          pivot_idx = mid;
        }
      }
    }

    // 三路分区
    size_t eq_left, eq_right;
    partition_3way(base, left, right, pivot_idx, &eq_left, &eq_right, size,
                   cmp);

    // 检查是否为坏pivot
    bool bad_pivot = is_bad_pivot(left, right, eq_left, eq_right);
    if (bad_pivot)
      bad_allowed--;

    // 递归处理较小的一边，迭代处理较大的一边
    size_t left_size = eq_left - left;
    size_t right_size = right - eq_right;

    if (left_size < right_size) {
      pdqsort_loop(base, left, eq_left - 1, size, cmp, bad_allowed, leftmost);
      left = eq_right + 1;
      leftmost = false;
    } else {
      pdqsort_loop(base, eq_right + 1, right, size, cmp, bad_allowed, false);
      right = eq_left - 1;
    }
  }
}

// pdqsort入口函数
void pdqsort(void *base, size_t nmemb, size_t size, compare_func_t cmp) {
  if (nmemb <= 1)
    return;

  // bad_allowed计算：log2(n)
  int bad_allowed = 0;
  size_t temp = nmemb;
  while (temp > 1) {
    temp /= 2;
    bad_allowed++;
  }

  pdqsort_loop(base, 0, nmemb - 1, size, cmp, bad_allowed, true);
}

// 示例比较函数
int compare_int(const void *a, const void *b) {
  int ia = *(const int *)a;
  int ib = *(const int *)b;
  return (ia > ib) - (ia < ib);
}

int compare_double(const void *a, const void *b) {
  double da = *(const double *)a;
  double db = *(const double *)b;
  return (da > db) - (da < db);
}

// 字符串比较函数
int compare_string(const void *a, const void *b) {
  const char *sa = *(const char **)a;
  const char *sb = *(const char **)b;
  return strcmp(sa, sb);
}

// 字符串长度比较函数（按长度排序）
int compare_string_length(const void *a, const void *b) {
  const char *sa = *(const char **)a;
  const char *sb = *(const char **)b;
  size_t len_a = strlen(sa);
  size_t len_b = strlen(sb);

  if (len_a < len_b)
    return -1;
  if (len_a > len_b)
    return 1;
  return strcmp(sa, sb); // 长度相同时按字典序
}

// 性能测试辅助函数
double get_time_diff(clock_t start, clock_t end) {
  return ((double)(end - start)) / CLOCKS_PER_SEC;
}

void generate_random_array(int *arr, size_t n) {
  for (size_t i = 0; i < n; i++) {
    arr[i] = rand() % 10000;
  }
}

void generate_sorted_array(int *arr, size_t n) {
  for (size_t i = 0; i < n; i++) {
    arr[i] = (int)i;
  }
}

void generate_reverse_sorted_array(int *arr, size_t n) {
  for (size_t i = 0; i < n; i++) {
    arr[i] = (int)(n - i - 1);
  }
}

void generate_nearly_sorted_array(int *arr, size_t n) {
  generate_sorted_array(arr, n);
  // 随机交换少量元素
  for (size_t i = 0; i < n / 20; i++) {
    size_t a = rand() % n;
    size_t b = rand() % n;
    int temp = arr[a];
    arr[a] = arr[b];
    arr[b] = temp;
  }
}

void generate_duplicate_array(int *arr, size_t n) {
  int values[] = {1, 2, 3, 4, 5};
  for (size_t i = 0; i < n; i++) {
    arr[i] = values[rand() % 5];
  }
}

bool is_sorted(int *arr, size_t n) {
  for (size_t i = 1; i < n; i++) {
    if (arr[i] < arr[i - 1])
      return false;
  }
  return true;
}

void copy_array(int *dest, int *src, size_t n) {
  memcpy(dest, src, n * sizeof(int));
}

// 测试和示例代码
void print_array(int *arr, size_t n) {
  printf("[");
  for (size_t i = 0; i < n; i++) {
    printf("%d", arr[i]);
    if (i < n - 1)
      printf(", ");
  }
  printf("]\n");
}

void print_string_array(const char **arr, size_t n) {
  printf("[");
  for (size_t i = 0; i < n; i++) {
    printf("\"%s\"", arr[i]);
    if (i < n - 1)
      printf(", ");
  }
  printf("]\n");
}

int main() {
  // 测试整数数组
  printf("Testing pdqsort with integers:\n");
  int arr1[] = {64, 34, 25, 12, 22, 11, 90, 88, 76, 50, 42};
  size_t n1 = sizeof(arr1) / sizeof(arr1[0]);

  printf("Original: ");
  print_array(arr1, n1);

  pdqsort(arr1, n1, sizeof(int), compare_int);

  printf("Sorted:   ");
  print_array(arr1, n1);

  // 测试浮点数数组
  printf("\nTesting pdqsort with doubles:\n");
  double arr2[] = {3.14, 2.71, 1.41, 1.73, 0.57, 2.23};
  size_t n2 = sizeof(arr2) / sizeof(arr2[0]);

  printf("Original: [");
  for (size_t i = 0; i < n2; i++) {
    printf("%.2f", arr2[i]);
    if (i < n2 - 1)
      printf(", ");
  }
  printf("]\n");

  pdqsort(arr2, n2, sizeof(double), compare_double);

  printf("Sorted:   [");
  for (size_t i = 0; i < n2; i++) {
    printf("%.2f", arr2[i]);
    if (i < n2 - 1)
      printf(", ");
  }
  printf("]\n");

  // 测试大数组性能
  printf("\nTesting with larger array (1000 elements):\n");
  int *large_arr = malloc(1000 * sizeof(int));
  for (int i = 0; i < 1000; i++) {
    large_arr[i] = rand() % 1000;
  }

  printf("Sorting 1000 random integers...\n");
  pdqsort(large_arr, 1000, sizeof(int), compare_int);
  printf("Done! First 10 elements: ");
  for (int i = 0; i < 10; i++) {
    printf("%d ", large_arr[i]);
  }
  printf("\n");

  free(large_arr);

  // 测试字符串数组 - 英文单词字典序排序
  printf("\nTesting pdqsort with English words (dictionary order):\n");
  const char *words[] = {"apple",      "banana",    "cherry",     "date",
                         "elderberry", "fig",       "grape",      "honeydew",
                         "kiwi",       "lemon",     "mango",      "nectarine",
                         "orange",     "papaya",    "quince",     "raspberry",
                         "strawberry", "tangerine", "watermelon", "zucchini"};
  size_t n_words = sizeof(words) / sizeof(words[0]);

  // 创建可修改的字符串数组副本
  const char **word_ptrs = malloc(n_words * sizeof(char *));
  for (size_t i = 0; i < n_words; i++) {
    word_ptrs[i] = words[i];
  }

  // 打乱顺序以便演示排序效果
  srand((unsigned int)time(NULL));
  for (size_t i = n_words - 1; i > 0; i--) {
    size_t j = rand() % (i + 1);
    const char *temp = word_ptrs[i];
    word_ptrs[i] = word_ptrs[j];
    word_ptrs[j] = temp;
  }

  printf("Original: ");
  print_string_array(word_ptrs, n_words);

  pdqsort(word_ptrs, n_words, sizeof(char *), compare_string);

  printf("Sorted:   ");
  print_string_array(word_ptrs, n_words);

  // 测试按字符串长度排序
  printf("\nTesting pdqsort with words sorted by length:\n");

  // 重新打乱顺序
  for (size_t i = n_words - 1; i > 0; i--) {
    size_t j = rand() % (i + 1);
    const char *temp = word_ptrs[i];
    word_ptrs[i] = word_ptrs[j];
    word_ptrs[j] = temp;
  }

  printf("Original: ");
  print_string_array(word_ptrs, n_words);

  pdqsort(word_ptrs, n_words, sizeof(char *), compare_string_length);

  printf("By length:");
  print_string_array(word_ptrs, n_words);

  free(word_ptrs);

  return 0;
}