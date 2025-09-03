#include <stdio.h>
#include <dlfcn.h>
#include <sys/time.h>

// 简单的时间函数
double get_time_ms() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

int main() {
    printf("🧪 Minimal JIT Test\n");
    printf("==================\n");

    // 测试基本的动态库功能
    void *handle = dlopen(NULL, RTLD_LAZY);
    if (handle) {
        printf("✅ dlopen works\n");
        dlclose(handle);
    } else {
        printf("❌ dlopen failed: %s\n", dlerror());
        return 1;
    }

    // 测试时间函数
    double start = get_time_ms();
    // 简单的延时
    for (volatile int i = 0; i < 1000000; i++);
    double end = get_time_ms();

    printf("✅ Timing works: %.2f ms\n", end - start);

    printf("🎉 Basic functionality verified!\n");
    return 0;
}
