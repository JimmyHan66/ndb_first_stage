#include "ndb_arrow_batch.h"
#include "ndb_scan_runtime.h"
#include <arrow/api.h>
#include <arrow/c/bridge.h>
#include <arrow/io/api.h>
#include <cstring>
#include <iostream>
#include <memory>
#include <parquet/arrow/reader.h>
#include <string>
#include <vector>

extern "C" {

// ScanHandle结构体(C++实现)
struct ScanHandle {
  std::shared_ptr<arrow::RecordBatchReader> reader;
  std::shared_ptr<arrow::Table> table; // 添加table存储
  std::vector<std::string> column_names;
  int32_t batch_size;
  bool eof_reached;
  int64_t current_offset; // 当前读取偏移

  ScanHandle() : batch_size(2048), eof_reached(false), current_offset(0) {}
};

ScanHandle *rt_scan_open_parquet(const TableScanDesc *desc) {
  if (!desc || !desc->file_paths || desc->num_files == 0) {
    std::cerr << "Error: Invalid scan descriptor" << std::endl;
    return nullptr;
  }

  try {

    auto handle = std::make_unique<ScanHandle>();
    handle->batch_size = desc->batch_size;

    // 保存列名
    handle->column_names.clear();
    for (int32_t i = 0; i < desc->num_cols; i++) {
      handle->column_names.push_back(desc->needed_cols[i]);
    }

    // 打开Parquet文件
    std::shared_ptr<arrow::io::ReadableFile> infile;
    auto file_result = arrow::io::ReadableFile::Open(desc->file_paths[0]);
    if (!file_result.ok()) {
      std::cerr << "Failed to open file: " << file_result.status().ToString()
                << std::endl;
      return nullptr;
    }
    infile = file_result.ValueOrDie();

    // 创建Parquet reader
    std::unique_ptr<parquet::arrow::FileReader> parquet_reader;
    auto reader_result =
        parquet::arrow::OpenFile(infile, arrow::default_memory_pool());
    if (!reader_result.ok()) {
      std::cerr << "Failed to create parquet reader: "
                << reader_result.status().ToString() << std::endl;
      return nullptr;
    }
    parquet_reader = std::move(reader_result.ValueOrDie());

    // 获取schema并打印信息
    std::shared_ptr<arrow::Schema> schema;
    auto schema_status = parquet_reader->GetSchema(&schema);
    if (!schema_status.ok()) {
      std::cerr << "Failed to get schema: " << schema_status.ToString()
                << std::endl;
      return nullptr;
    }

    // 创建列索引映射
    std::vector<int> column_indices;
    for (const auto &col_name : handle->column_names) {
      int field_idx = schema->GetFieldIndex(col_name);
      if (field_idx == -1) {
        std::cerr << "Column '" << col_name << "' not found in schema"
                  << std::endl;
        return nullptr;
      }
      column_indices.push_back(field_idx);
    }

    // 创建RecordBatch reader (尝试更安全的API)

    // 读取完整table并存储，避免使用RecordBatchReader
    auto table_status =
        parquet_reader->ReadTable(column_indices, &handle->table);
    if (!table_status.ok()) {
      std::cerr << "Failed to read table: " << table_status.ToString()
                << std::endl;
      return nullptr;
    }

    // 不再使用RecordBatchReader，直接从Table生成批次
    handle->reader = nullptr; // 暂时不使用reader

    return handle.release();

  } catch (const std::exception &e) {
    std::cerr << "Exception in rt_scan_open_parquet: " << e.what() << std::endl;
    return nullptr;
  }
}

int32_t rt_scan_next(ScanHandle *handle, ArrowBatch *out_batch) {
  if (!handle || !out_batch) {
    std::cerr << "Error: Invalid parameters to rt_scan_next" << std::endl;
    return -1;
  }

  if (!handle->table) {
    std::cerr << "Error: Table is null" << std::endl;
    return -1;
  }

  if (handle->eof_reached) {
    return 0; // EOF
  }

  try {
    // 从Table切片生成RecordBatch

    int64_t start = handle->current_offset;
    int64_t length = std::min((int64_t)handle->batch_size,
                              handle->table->num_rows() - start);

    if (length <= 0) {
      // EOF
      handle->eof_reached = true;
      ndb_arrow_batch_init(out_batch);
      return 0;
    }

    // 从Table创建RecordBatch
    auto table_slice = handle->table->Slice(start, length);

    // 使用TableBatchReader来转换
    auto reader_result = arrow::TableBatchReader(*table_slice);
    auto batch_reader = std::make_shared<arrow::TableBatchReader>(*table_slice);

    std::shared_ptr<arrow::RecordBatch> batch;
    auto read_status = batch_reader->ReadNext(&batch);
    if (!read_status.ok()) {
      std::cerr << "Failed to read batch from table reader: "
                << read_status.ToString() << std::endl;
      return -1;
    }

    if (!batch) {
      handle->eof_reached = true;
      ndb_arrow_batch_init(out_batch);
      return 0;
    }
    handle->current_offset += length;

    // batch已经确认非空，继续处理

    // 初始化ArrowBatch
    if (ndb_arrow_batch_init(out_batch) != 0) {
      std::cerr << "Failed to initialize ArrowBatch" << std::endl;
      return -1;
    }

    // 分配Arrow C Data Interface结构
    out_batch->c_array = (struct ArrowArray *)malloc(sizeof(struct ArrowArray));
    out_batch->c_schema =
        (struct ArrowSchema *)malloc(sizeof(struct ArrowSchema));

    if (!out_batch->c_array || !out_batch->c_schema) {
      std::cerr << "Failed to allocate Arrow C structures" << std::endl;
      ndb_arrow_batch_cleanup(out_batch);
      return -1;
    }

    memset(out_batch->c_array, 0, sizeof(struct ArrowArray));
    memset(out_batch->c_schema, 0, sizeof(struct ArrowSchema));

    // 使用Arrow C Bridge导出数据
    auto export_status = arrow::ExportRecordBatch(*batch, out_batch->c_array,
                                                  out_batch->c_schema);
    if (!export_status.ok()) {
      std::cerr << "Failed to export record batch: " << export_status.ToString()
                << std::endl;
      free(out_batch->c_array);
      free(out_batch->c_schema);
      out_batch->c_array = nullptr;
      out_batch->c_schema = nullptr;
      return -1;
    }

    // 设置ArrowBatch字段
    out_batch->num_rows = batch->num_rows();
    out_batch->num_cols = batch->num_columns();
    out_batch->arrow_batch_ptr = nullptr; // 不需要保持C++对象引用

    return 1; // 成功读取到batch

  } catch (const std::exception &e) {
    std::cerr << "Exception in rt_scan_next: " << e.what() << std::endl;
    return -1;
  }
}

void rt_scan_close(ScanHandle *handle) {
  if (handle) {

    delete handle;
  }
}

} // extern "C"
