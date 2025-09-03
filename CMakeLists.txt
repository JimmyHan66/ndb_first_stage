cmake_minimum_required(VERSION 3.10)
project(ndb_scan_filter C CXX)

# 设置C和C++标准
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -O2")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0 -DDEBUG")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -O2")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0 -DDEBUG")

# 查找Arrow库 - 支持多种方式
find_package(PkgConfig REQUIRED)
pkg_check_modules(ARROW REQUIRED arrow)
pkg_check_modules(PARQUET REQUIRED parquet)

# 如果pkg-config失败，尝试手动查找
if(NOT ARROW_FOUND OR NOT PARQUET_FOUND)
    message(STATUS "pkg-config failed, trying manual detection...")

    # macOS Homebrew路径
    if(APPLE)
        set(ARROW_ROOT "/opt/homebrew/Cellar/apache-arrow/21.0.0_5")

        if(EXISTS "${ARROW_ROOT}")
            set(ARROW_INCLUDE_DIRS "${ARROW_ROOT}/include")
            set(ARROW_LIBRARY_DIRS "${ARROW_ROOT}/lib")
            set(ARROW_LIBRARIES "arrow")
            set(PARQUET_LIBRARIES "parquet")
            message(STATUS "Found Arrow at: ${ARROW_ROOT}")
        endif()
    endif()
endif()

# 包含目录
include_directories(include)
include_directories(${ARROW_INCLUDE_DIRS})
include_directories(${PARQUET_INCLUDE_DIRS})
include_directories(arrow-c)

# 链接目录
if(ARROW_LIBRARY_DIRS)
    link_directories(${ARROW_LIBRARY_DIRS})
endif()

if(PARQUET_LIBRARY_DIRS)
    link_directories(${PARQUET_LIBRARY_DIRS})
endif()

# 源文件 (Arrow优化版本)
set(NDB_SOURCES
    src/ndb_selvec.c
    src/ndb_arrow_batch.c
    src/ndb_arrow_column.c
    src/ndb_parquet_reader_arrow.cpp
    src/ndb_filter_kernels_arrow.c
    src/ndb_batch_driver_arrow.c
    src/ndb_agg_callback_factory.c
)

# 创建静态库
add_library(ndb_scan_filter_static STATIC ${NDB_SOURCES})
set_target_properties(ndb_scan_filter_static PROPERTIES OUTPUT_NAME ndb_scan_filter)
target_link_libraries(ndb_scan_filter_static
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES}
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6_inc.so)

# 创建动态库
add_library(ndb_scan_filter_shared SHARED ${NDB_SOURCES})
set_target_properties(ndb_scan_filter_shared PROPERTIES OUTPUT_NAME ndb_scan_filter)
target_link_libraries(ndb_scan_filter_shared
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES}
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6_inc.so)

# 测试可执行文件 (Arrow优化版本)
add_executable(test_scan_filter_q1_arrow tests/test_scan_filter_q1_arrow.c)
target_link_libraries(test_scan_filter_q1_arrow
    ndb_scan_filter_static
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1.so
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES})

add_executable(test_scan_filter_q6_arrow tests/test_scan_filter_q6_arrow.c)
target_link_libraries(test_scan_filter_q6_arrow
    ndb_scan_filter_static
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6.so
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES})

# 集成测试
add_executable(test_q1_agg_integration tests/test_q1_agg_integration.c)
target_link_libraries(test_q1_agg_integration
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq1.so
    ndb_scan_filter_static
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES})

add_executable(test_q6_agg_integration tests/test_q6_agg_integration.c)
target_link_libraries(test_q6_agg_integration
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6_inc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/arrow-c/libq6.so
    ndb_scan_filter_static
    ${ARROW_LIBRARIES}
    ${PARQUET_LIBRARIES})

# LLVM IR生成目标 (Arrow优化版本)
add_custom_target(llvm_ir
    COMMAND clang -S -emit-llvm -I${CMAKE_SOURCE_DIR}/include -O2 -o ${CMAKE_BINARY_DIR}/ndb_filter_kernels_arrow.ll ${CMAKE_SOURCE_DIR}/src/ndb_filter_kernels_arrow.c
    COMMAND clang -S -emit-llvm -I${CMAKE_SOURCE_DIR}/include -O2 -o ${CMAKE_BINARY_DIR}/ndb_batch_driver_arrow.ll ${CMAKE_SOURCE_DIR}/src/ndb_batch_driver_arrow.c
    COMMENT "Generating LLVM IR files for JIT compilation (Arrow optimized)"
)

# 安装目标
install(TARGETS ndb_scan_filter_static ndb_scan_filter_shared
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(DIRECTORY include/ DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)
