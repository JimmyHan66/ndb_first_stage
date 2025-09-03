#include "abi.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

// HashAggregate 结构
#define HASH_TABLE_SIZE 1024

typedef struct {
    char returnflag;         // l_returnflag (1 byte)
    char linestatus;         // l_linestatus (1 byte)
    uint16_t hash_key;       // 16-bit hash key
    int64_t count_order;     // count(*) - 订单计数
    double sum_qty;          // sum(l_quantity) - 数量总和
    double sum_base_price;   // sum(l_extendedprice) - 基础价格总和
    double sum_disc_price;   // sum(l_extendedprice * (1 - l_discount)) - 折扣后价格总和
    double sum_charge;       // sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) - 最终费用总和
    double sum_discount;     // sum(l_discount) - 折扣总和（用于计算平均值）
} HashEntry;

typedef struct {
    HashEntry entries[HASH_TABLE_SIZE];
    int entry_count;
} HashTable;

// 存储字典的结构
struct DictionaryInfo {
    struct ArrowArray *dict_array;
    struct ArrowSchema *dict_schema;
};

// 全局字典存储
#define MAX_DICTIONARIES 16
struct DictionaryInfo dictionaries[MAX_DICTIONARIES];
int dict_count = 0;

// 添加字典的函数
void add_dictionary(struct ArrowArray *dict_array, struct ArrowSchema *dict_schema) {
    if (dict_count < MAX_DICTIONARIES) {
        dictionaries[dict_count].dict_array = dict_array;
        dictionaries[dict_count].dict_schema = dict_schema;
        
        printf("Added dictionary %d with %lld values:\n", dict_count, (long long)dict_array->length);
        
        // 打印字典内容
        if (dict_schema->format && strcmp(dict_schema->format, "u") == 0) {
            if (dict_array->buffers[1] && dict_array->buffers[2]) {
                int32_t *offsets = (int32_t *)dict_array->buffers[1];
                uint8_t *data = (uint8_t *)dict_array->buffers[2];
                
                for (int64_t i = 0; i < dict_array->length; i++) {
                    int32_t start_offset = offsets[i];
                    int32_t end_offset = offsets[i + 1];
                    int32_t str_length = end_offset - start_offset;
                    
                    if (str_length > 0) {
                        printf("  [%lld] = '%.*s'\n", (long long)i, str_length, (char *)(data + start_offset));
                    }
                }
            }
        }
        
        dict_count++;
    }
}

// 获取字典字符串值的函数
const char* get_dict_string_value(int dict_id, uint8_t index, char* buffer, size_t buffer_size) {
    if (dict_id >= dict_count || dict_id < 0) {
        snprintf(buffer, buffer_size, "Dict[%d]", index);
        return buffer;
    }
    
    struct ArrowArray *dict_array = dictionaries[dict_id].dict_array;
    struct ArrowSchema *dict_schema = dictionaries[dict_id].dict_schema;
    
    if (!dict_array || !dict_schema || !dict_schema->format) {
        snprintf(buffer, buffer_size, "Dict[%d]", index);
        return buffer;
    }
    
    // 检查索引范围
    if (index >= dict_array->length) {
        snprintf(buffer, buffer_size, "Dict[%d>%lld]", index, (long long)dict_array->length);
        return buffer;
    }
    
    // 检查是否为字符串字典
    if (strcmp(dict_schema->format, "u") == 0) {
        if (dict_array->buffers[1] && dict_array->buffers[2]) {
            int32_t *offsets = (int32_t *)dict_array->buffers[1];
            uint8_t *data = (uint8_t *)dict_array->buffers[2];
            
            int32_t start_offset = offsets[index];
            int32_t end_offset = offsets[index + 1];
            int32_t str_length = end_offset - start_offset;
            
            if (str_length > 0 && str_length < buffer_size - 1) {
                memcpy(buffer, data + start_offset, str_length);
                buffer[str_length] = '\0';
                printf("Dict[%d]=%s ", index, buffer);  // 添加调试信息
                return buffer;
            }
        }
    }
    
    snprintf(buffer, buffer_size, "Dict[%d]", index);
    return buffer;
}

void process_arrow_array(struct ArrowArray *arr, struct ArrowSchema *schema) {
  // 解析数据，比如假设是Int32
  int32_t *data = (int32_t *)arr->buffers[1];
  printf("This is on C!\n");
  for (int64_t i = 0; i < arr->length; ++i) {
    printf("%d\n", data[i]);
  }
}


void process_arrow_array_b(struct ArrowArray *arr, struct ArrowSchema *schema) {
    printf("This is on C!\n");
    printf("Processing Decimal(15,2) array with %lld elements:\n", (long long)arr->length);
    
    // Decimal128 数据
    uint8_t *data = (uint8_t *)arr->buffers[1];
    
    for (int64_t i = 0; i < arr->length; ++i) {
        // 每个 Decimal128 值占用 16 字节
        uint8_t *decimal_bytes = data + (i * 16);
        
        // 读取为 128 位有符号整数 (little-endian)
        __int128 value = 0;
        for (int j = 0; j < 16; j++) {
            value |= ((__int128)decimal_bytes[j]) << (j * 8);
        }
        
        // 处理符号扩展
        if (decimal_bytes[15] & 0x80) {
            // 负数，进行符号扩展
            for (int j = 16; j < sizeof(__int128); j++) {
                value |= ((__int128)0xFF) << (j * 8);
            }
        }
        
        // 转换为浮点数 (scale=2)
        double decimal_value = (double)value / 100.0;
        
        printf("Element %lld: decimal_value=%.2f\n", (long long)i, decimal_value);
    }
}

void process_record_batch(struct ArrowArray *arr, struct ArrowSchema *schema) {
    printf("Processing RecordBatch with %lld rows and %lld columns:\n", 
           (long long)arr->length, (long long)arr->n_children);
    
    // 遍历每一列
    for (int64_t col = 0; col < arr->n_children; col++) {
        struct ArrowArray *child_array = arr->children[col];
        struct ArrowSchema *child_schema = schema->children[col];
        
        printf("\nColumn %lld (%s):\n", (long long)col, child_schema->name);
        
        // 根据数据类型处理不同的列
        if (strcmp(child_schema->format, "i") == 0) {
            // Int32 类型
            printf("  Type: Int32\n");
            int32_t *data = (int32_t *)child_array->buffers[1];
            for (int64_t i = 0; i < child_array->length; ++i) {
                printf("  Row %lld: %d\n", (long long)i, data[i]);
            }
        } 
        else if (strncmp(child_schema->format, "d:", 2) == 0) {
            // Decimal128 类型 (格式类似 "d:15,2")
            printf("  Type: Decimal128(15,2)\n");
            uint8_t *data = (uint8_t *)child_array->buffers[1];
            
            for (int64_t i = 0; i < child_array->length; ++i) {
                // 每个 Decimal128 值占用 16 字节
                uint8_t *decimal_bytes = data + (i * 16);
                
                // 读取为 128 位有符号整数 (little-endian)
                __int128 value = 0;
                for (int j = 0; j < 16; j++) {
                    value |= ((__int128)decimal_bytes[j]) << (j * 8);
                }
                
                // 处理符号扩展
                if (decimal_bytes[15] & 0x80) {
                    // 负数，进行符号扩展
                    for (int j = 16; j < sizeof(__int128); j++) {
                        value |= ((__int128)0xFF) << (j * 8);
                    }
                }
                
                // 转换为浮点数 (scale=2)
                double decimal_value = (double)value / 100.0;
                
                printf("  Row %lld: %.2f\n", (long long)i, decimal_value);
            }
        }
        else {
            printf("  Type: Unknown (%s)\n", child_schema->format);
        }
    }
    
    printf("\nSummary: Processed %lld rows across %lld columns\n", 
           (long long)arr->length, (long long)arr->n_children);
}

void print_arrow_schema_and_array(struct ArrowArray *arr, struct ArrowSchema *schema) {
    if (!schema) {
        printf("Schema is NULL\n");
        return;
    }
    
    if (!arr) {
        printf("Array is NULL\n");
        return;
    }
    
    printf("=== Arrow Schema and Array Information ===\n");
    
    // Schema 信息
    printf("\nSchema Information:\n");
    printf("  Format: %s\n", schema->format ? schema->format : "NULL");
    printf("  Name: %s\n", schema->name ? schema->name : "NULL");
    printf("  Metadata: %s\n", schema->metadata ? schema->metadata : "NULL");
    printf("  Flags: 0x%llx\n", (unsigned long long)schema->flags);
    printf("  Number of children: %lld\n", (long long)schema->n_children);
    
    // Array 信息
    printf("\nArray Information:\n");
    printf("  Length: %lld\n", (long long)arr->length);
    printf("  Null count: %lld\n", (long long)arr->null_count);
    printf("  Offset: %lld\n", (long long)arr->offset);
    printf("  Number of buffers: %lld\n", (long long)arr->n_buffers);
    printf("  Number of children: %lld\n", (long long)arr->n_children);
    
    // 数据类型详细信息
    if (schema->format) {
        printf("\nData Type Details:\n");
        if (strcmp(schema->format, "i") == 0) {
            printf("  - Int32\n");
        } else if (strcmp(schema->format, "l") == 0) {
            printf("  - Int64\n");
        } else if (strcmp(schema->format, "f") == 0) {
            printf("  - Float32\n");
        } else if (strcmp(schema->format, "g") == 0) {
            printf("  - Float64\n");
        } else if (strcmp(schema->format, "u") == 0) {
            printf("  - UTF-8 String\n");
        } else if (strncmp(schema->format, "d:", 2) == 0) {
            printf("  - Decimal128 (%s)\n", schema->format + 2);
        } else if (strcmp(schema->format, "+s") == 0) {
            printf("  - Struct\n");
        } else if (strcmp(schema->format, "+l") == 0) {
            printf("  - List\n");
        } else {
            printf("  - Other/Unknown: %s\n", schema->format);
        }
    }
    
    // 如果有子项，递归显示
    if (schema->n_children > 0 && schema->children && arr->children) {
        printf("\nChildren Information:\n");
        for (int64_t i = 0; i < schema->n_children; i++) {
            printf("  Child %lld (%s):\n", (long long)i, 
                   schema->children[i]->name ? schema->children[i]->name : "unnamed");
            printf("    Format: %s\n", schema->children[i]->format);
            printf("    Length: %lld\n", (long long)arr->children[i]->length);
        }
    }
    
    // Dictionary 信息
    if (schema->dictionary) {
        printf("\nDictionary Present\n");
    }
    
    printf("\n=== End of Schema and Array Information ===\n");
}

void print_first_10_rows(struct ArrowArray *arr, struct ArrowSchema *schema) {
    if (!schema) {
        printf("Schema is NULL\n");
        return;
    }
    
    if (!arr) {
        printf("Array is NULL\n");
        return;
    }
    
    printf("=== First 10 Rows of Data ===\n");
    
    // 确定要显示的行数（最多10行）
    int64_t rows_to_show = arr->length < 10 ? arr->length : 10;
    
    if (rows_to_show == 0) {
        printf("No data to display (array length is 0)\n");
        return;
    }
    
    // 调试信息：打印列的格式
    printf("Debug: Columns and their formats:\n");
    for (int64_t col = 0; col < schema->n_children; col++) {
        printf("  Column %lld: %s (format: %s)", 
               (long long)col,
               schema->children[col]->name ? schema->children[col]->name : "unnamed",
               schema->children[col]->format ? schema->children[col]->format : "NULL");
        
        // 检查是否有字典
        if (schema->children[col]->dictionary) {
            printf(" [has dictionary]");
        }
        if (arr->children && arr->children[col] && arr->children[col]->dictionary) {
            printf(" [has dict array]");
        }
        printf("\n");
    }
    printf("\n");
    
    // 如果是 RecordBatch（有多个子列）
    if (schema->n_children > 0 && arr->n_children > 0) {
        // 只处理前3列以避免崩溃
        int64_t cols_to_show = schema->n_children < 3 ? schema->n_children : 3;
        
        // 打印列标题
        printf("Row |");
        for (int64_t col = 0; col < cols_to_show; col++) {
            const char *col_name = schema->children[col]->name ? schema->children[col]->name : "unnamed";
            printf(" %-15s |", col_name);
        }
        printf("\n");
        
        // 打印分隔线
        printf("----+");
        for (int64_t col = 0; col < cols_to_show; col++) {
            printf("-----------------+");
        }
        printf("\n");
        
        // 打印数据行
        for (int64_t row = 0; row < rows_to_show; row++) {
            printf("%3lld |", (long long)row);
            
            // 遍历每一列 (只显示前几列)
            for (int64_t col = 0; col < cols_to_show; col++) {
                struct ArrowArray *child_array = arr->children[col];
                struct ArrowSchema *child_schema = schema->children[col];
                
                // 添加安全检查
                if (!child_array || !child_schema) {
                    printf(" %-15s |", "NULL_PTR");
                    continue;
                }
                
                if (row >= child_array->length) {
                    printf(" %-15s |", "OUT_OF_BOUNDS");
                    continue;
                }
                
                // 根据数据类型显示值
                if (strcmp(child_schema->format, "i") == 0) {
                    // Int32
                    if (child_array->buffers[1] != NULL) {
                        int32_t *data = (int32_t *)child_array->buffers[1];
                        printf(" %-15d |", data[row]);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                } 
                else if (strcmp(child_schema->format, "l") == 0) {
                    // Int64
                    if (child_array->buffers[1] != NULL) {
                        int64_t *data = (int64_t *)child_array->buffers[1];
                        printf(" %-15lld |", (long long)data[row]);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strcmp(child_schema->format, "f") == 0) {
                    // Float32
                    if (child_array->buffers[1] != NULL) {
                        float *data = (float *)child_array->buffers[1];
                        printf(" %-15.2f |", data[row]);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strcmp(child_schema->format, "g") == 0) {
                    // Float64
                    if (child_array->buffers[1] != NULL) {
                        double *data = (double *)child_array->buffers[1];
                        printf(" %-15.2f |", data[row]);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strncmp(child_schema->format, "d:", 2) == 0) {
                    // Decimal128
                    if (child_array->buffers[1] != NULL) {
                        uint8_t *data = (uint8_t *)child_array->buffers[1];
                        uint8_t *decimal_bytes = data + (row * 16);
                        
                        __int128 value = 0;
                        for (int j = 0; j < 16; j++) {
                            value |= ((__int128)decimal_bytes[j]) << (j * 8);
                        }
                        
                        if (decimal_bytes[15] & 0x80) {
                            for (int j = 16; j < sizeof(__int128); j++) {
                                value |= ((__int128)0xFF) << (j * 8);
                            }
                        }
                        
                        double decimal_value = (double)value / 100.0;
                        printf(" %-15.2f |", decimal_value);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strcmp(child_schema->format, "u") == 0) {
                    // UTF-8 String - 需要处理偏移量缓冲区
                    if (child_array->buffers[1] != NULL && child_array->buffers[2] != NULL) {
                        int32_t *offsets = (int32_t *)child_array->buffers[1];  // 偏移量缓冲区
                        uint8_t *data = (uint8_t *)child_array->buffers[2];     // 字符串数据缓冲区
                        
                        // 计算字符串长度
                        int32_t start_offset = offsets[row];
                        int32_t end_offset = offsets[row + 1];
                        int32_t str_length = end_offset - start_offset;
                        
                        if (str_length > 0 && str_length < 15) {
                            // 如果字符串不太长，直接显示
                            printf(" %-15.*s |", str_length, (char *)(data + start_offset));
                        } else if (str_length > 0) {
                            // 如果字符串太长，截断显示
                            printf(" %-12.*s... |", 12, (char *)(data + start_offset));
                        } else {
                            // 空字符串
                            printf(" %-15s |", "");
                        }
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strcmp(child_schema->format, "tdD") == 0) {
                    // Date32 - 天数，从1970-01-01开始
                    if (child_array->buffers[1] != NULL) {
                        int32_t *data = (int32_t *)child_array->buffers[1];
                        int32_t days = data[row];
                        
                        // 将天数转换为年月日
                        // 这是一个简化的日期计算
                        int year = 1970;
                        int month = 1;
                        int day = 1;
                        int remaining_days = days;
                        
                        // 简化的年份计算
                        while (remaining_days >= 365) {
                            int days_in_year = 365;
                            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                                days_in_year = 366;
                            }
                            
                            if (remaining_days >= days_in_year) {
                                remaining_days -= days_in_year;
                                year++;
                            } else {
                                break;
                            }
                        }
                        
                        // 简化的月份计算
                        int days_in_month[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
                        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                            days_in_month[1] = 29; // 闰年2月
                        }
                        
                        while (remaining_days >= days_in_month[month - 1] && month <= 12) {
                            remaining_days -= days_in_month[month - 1];
                            month++;
                        }
                        day += remaining_days;
                        
                        printf(" %04d-%02d-%02d    |", year, month, day);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else if (strcmp(child_schema->format, "vu") == 0) {
                    // Dictionary encoded with UInt8 indices
                    // vu 表示字典编码，索引是 UInt8 类型
                    if (child_array->buffers[1] != NULL) {
                        uint8_t *indices = (uint8_t *)child_array->buffers[1];
                        uint8_t index = indices[row];
                        
                        // 尝试从全局字典存储中获取值
                        char buffer[16];
                        const char* dict_value = get_dict_string_value(col - 1, index, buffer, sizeof(buffer)); // col-1 因为第0列不是字典
                        printf(" %-15s |", dict_value);
                    } else {
                        printf(" %-15s |", "NULL");
                    }
                }
                else {
                    printf(" %-10s(%s) |", "Unknown", child_schema->format ? child_schema->format : "NULL");
                }
            }
            printf("\n");
        }
    }
    else {
        // 单列数组
        printf("Single column array (%s):\n", schema->format ? schema->format : "unknown");
        
        for (int64_t i = 0; i < rows_to_show; i++) {
            printf("Row %3lld: ", (long long)i);
            
            if (strcmp(schema->format, "i") == 0) {
                int32_t *data = (int32_t *)arr->buffers[1];
                printf("%d\n", data[i]);
            }
            else if (strcmp(schema->format, "l") == 0) {
                int64_t *data = (int64_t *)arr->buffers[1];
                printf("%lld\n", (long long)data[i]);
            }
            else if (strcmp(schema->format, "f") == 0) {
                float *data = (float *)arr->buffers[1];
                printf("%.2f\n", data[i]);
            }
            else if (strcmp(schema->format, "g") == 0) {
                double *data = (double *)arr->buffers[1];
                printf("%.2f\n", data[i]);
            }
            else if (strncmp(schema->format, "d:", 2) == 0) {
                uint8_t *data = (uint8_t *)arr->buffers[1];
                uint8_t *decimal_bytes = data + (i * 16);
                
                __int128 value = 0;
                for (int j = 0; j < 16; j++) {
                    value |= ((__int128)decimal_bytes[j]) << (j * 8);
                }
                
                if (decimal_bytes[15] & 0x80) {
                    for (int j = 16; j < sizeof(__int128); j++) {
                        value |= ((__int128)0xFF) << (j * 8);
                    }
                }
                
                double decimal_value = (double)value / 100.0;
                printf("%.2f\n", decimal_value);
            }
            else if (strcmp(schema->format, "u") == 0) {
                // UTF-8 String
                int32_t *offsets = (int32_t *)arr->buffers[1];
                uint8_t *data = (uint8_t *)arr->buffers[2];
                
                int32_t start_offset = offsets[i];
                int32_t end_offset = offsets[i + 1];
                int32_t str_length = end_offset - start_offset;
                
                if (str_length > 0) {
                    printf("%.*s\n", str_length, (char *)(data + start_offset));
                } else {
                    printf("(empty string)\n");
                }
            }
            else if (strcmp(schema->format, "tdD") == 0) {
                // Date32 - 单列数组
                if (arr->buffers[1] != NULL) {
                    int32_t *data = (int32_t *)arr->buffers[1];
                    int32_t days = data[i];
                    
                    // 将天数转换为年月日
                    int year = 1970;
                    int month = 1;
                    int day = 1;
                    int remaining_days = days;
                    
                    // 简化的年份计算
                    while (remaining_days >= 365) {
                        int days_in_year = 365;
                        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                            days_in_year = 366;
                        }
                        
                        if (remaining_days >= days_in_year) {
                            remaining_days -= days_in_year;
                            year++;
                        } else {
                            break;
                        }
                    }
                    
                    // 简化的月份计算
                    int days_in_month[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
                    if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                        days_in_month[1] = 29; // 闰年2月
                    }
                    
                    while (remaining_days >= days_in_month[month - 1] && month <= 12) {
                        remaining_days -= days_in_month[month - 1];
                        month++;
                    }
                    day += remaining_days;
                    
                    printf("%04d-%02d-%02d\n", year, month, day);
                } else {
                    printf("NULL\n");
                }
            }
            else if (strcmp(schema->format, "vu") == 0) {
                // Dictionary encoded with UInt8 indices - 单列数组
                if (arr->buffers[1] != NULL) {
                    uint8_t *indices = (uint8_t *)arr->buffers[1];
                    uint8_t index = indices[i];
                    printf("Dictionary index: %d\n", index);
                } else {
                    printf("NULL\n");
                }
            }
            else {
                printf("Unknown type: %s\n", schema->format ? schema->format : "NULL");
            }
        }
    }
    
    if (arr->length > 10) {
        printf("\n... and %lld more rows\n", (long long)(arr->length - 10));
    }
    
    printf("\n=== End of First 10 Rows ===\n");
}

