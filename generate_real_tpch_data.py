#!/usr/bin/env python3
"""
使用tpchgen-cli生成真实的TPC-H SF=1数据集
参考: https://github.com/clflushopt/tpchgen-rs/blob/main/tpchgen-cli/README.md
"""

import os
import subprocess
import sys

def check_tpchgen_cli():
    """检查tpchgen-cli是否已安装"""
    try:
        result = subprocess.run(['tpchgen-cli', '--version'],
                              capture_output=True, text=True, check=True)
        print(f"✓ tpchgen-cli found: {result.stdout.strip()}")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def install_tpchgen_cli():
    """安装tpchgen-cli"""
    print("Installing tpchgen-cli...")
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'install', 'tpchgen_cli'],
                      check=True)
        print("✓ tpchgen-cli installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to install tpchgen-cli: {e}")
        return False

def generate_tpch_sf1_data(output_dir="sf1"):
    """生成TPC-H SF=1数据集"""
    print(f"Generating TPC-H SF=1 data to {output_dir}/...")

    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)

    try:
        # 生成SF=1数据集，输出parquet格式
        cmd = ['tpchgen-cli', '-s', '1', '--output-dir', output_dir, '--format', 'parquet']
        print(f"Running: {' '.join(cmd)}")

        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("✓ TPC-H SF=1 data generated successfully")
        print(result.stdout)

        # 列出生成的文件
        files = os.listdir(output_dir)
        parquet_files = [f for f in files if f.endswith('.parquet')]

        print(f"\nGenerated {len(parquet_files)} parquet files:")
        for f in sorted(parquet_files):
            file_path = os.path.join(output_dir, f)
            size_mb = os.path.getsize(file_path) / (1024 * 1024)
            print(f"  - {f} ({size_mb:.1f} MB)")

        return True

    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to generate data: {e}")
        if e.stderr:
            print(f"Error output: {e.stderr}")
        return False

def verify_lineitem_file(output_dir="sf1"):
    """验证lineitem.parquet文件"""
    lineitem_path = os.path.join(output_dir, "lineitem.parquet")

    if not os.path.exists(lineitem_path):
        print(f"✗ lineitem.parquet not found in {output_dir}/")
        return False

    try:
        import pandas as pd
        import pyarrow.parquet as pq

        # 读取parquet文件信息
        parquet_file = pq.ParquetFile(lineitem_path)
        schema = parquet_file.schema
        num_rows = parquet_file.metadata.num_rows

        print(f"\n✓ lineitem.parquet verification:")
        print(f"  Rows: {num_rows:,}")
        print(f"  Columns: {len(schema)}")
        print(f"  Size: {os.path.getsize(lineitem_path) / (1024*1024):.1f} MB")

        # 显示列信息
        print("  Columns:")
        for i, field in enumerate(schema):
            print(f"    {i}: {field.name} ({field.physical_type})")

        return True

    except ImportError:
        print("  (Install pandas and pyarrow to verify file details)")
        return True
    except Exception as e:
        print(f"✗ Error reading lineitem.parquet: {e}")
        return False

def main():
    print("=== TPC-H SF=1 Data Generation ===")
    print()

    # 检查并安装tpchgen-cli
    if not check_tpchgen_cli():
        print("tpchgen-cli not found, installing...")
        if not install_tpchgen_cli():
            print("Failed to install tpchgen-cli. Please install manually:")
            print("  pip install tpchgen_cli")
            return 1

    # 生成数据
    if not generate_tpch_sf1_data():
        return 1

    # 验证数据
    verify_lineitem_file()

    print("\n=== Generation Complete ===")
    print("Files generated in sf1/ directory")
    print("Use sf1/lineitem.parquet for testing Q1 and Q6")

    return 0

if __name__ == "__main__":
    sys.exit(main())
