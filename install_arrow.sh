#!/usr/bin/env bash
set -euo pipefail

# ==== 配置 ====
ARROW_VERSION="${ARROW_VERSION:-apache-arrow-21.0.0}"   # 可改为 master 或其它 tag
PREFIX="${PREFIX:-$HOME/.local}"                        # 安装前缀（免 sudo）
SRC_ROOT="${SRC_ROOT:-$HOME/ndb_fisrt_stage}"           # 代码放这里
ARROW_SRC="$SRC_ROOT/arrow"
BUILD_DIR="$ARROW_SRC/cpp/build"

# ==== 准备环境（避免被 conda 等干扰）====
if command -v conda >/dev/null 2>&1; then
  conda deactivate || true
fi
# 临时从 PATH/LD_LIBRARY_PATH 移除 anaconda3 目录（仅当前进程）
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$HOME/anaconda3" | paste -sd:)
export PATH
if [[ -n "${LD_LIBRARY_PATH-}" ]]; then
  LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | grep -v "$HOME/anaconda3" | paste -sd:)
  export LD_LIBRARY_PATH
fi

# ==== 确保 cmake 足够新 ====
if ! command -v cmake >/dev/null 2>&1; then
  echo "[INFO] cmake 不在 PATH，尝试使用 pip 用户安装目录"
  export PATH="$HOME/.local/bin:$PATH"
fi
cmake --version

# ==== 获取 Arrow 源码 ====
mkdir -p "$SRC_ROOT"
if [[ ! -d "$ARROW_SRC/.git" ]]; then
  echo "[INFO] 克隆 Arrow 源码到 $ARROW_SRC"
  git clone https://github.com/apache/arrow.git "$ARROW_SRC"
fi
pushd "$ARROW_SRC" >/dev/null
# 切到指定版本（如果已在该版本会自动跳过）
git fetch --tags
git checkout "$ARROW_VERSION" || true
popd >/dev/null

# ==== 全新构建目录 ====
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ==== CMake 配置（只构建 Arrow+Parquet，Bundled 依赖，免 OpenSSL/AWS/LLVM）====
pushd "$BUILD_DIR" >/dev/null
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DARROW_BUILD_SHARED=ON \
  -DARROW_BUILD_STATIC=OFF \
  -DARROW_PARQUET=ON \
  -DPARQUET_BUILD_ENCRYPTION=OFF \
  -DARROW_FLIGHT=OFF \
  -DARROW_S3=OFF \
  -DARROW_GANDIVA=OFF \
  -DARROW_WITH_OPENSSL=OFF \
  -DARROW_WITH_ZLIB=ON \
  -DARROW_WITH_BROTLI=ON \
  -DARROW_WITH_LZ4=ON \
  -DARROW_WITH_SNAPPY=ON \
  -DARROW_WITH_ZSTD=ON \
  -DARROW_DEPENDENCY_SOURCE=BUNDLED \
  -DThrift_SOURCE=BUNDLED

# ==== 编译与安装 ====
make -j"$(nproc)"
make install
popd >/dev/null

# ==== 写入环境变量（当前 shell & 提示永久生效的添加方式）====
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig:$PREFIX/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH-}"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64:$PREFIX/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH-}"
echo
echo "[INFO] 临时环境变量已设置到当前会话："
echo "export PKG_CONFIG_PATH=\"$PKG_CONFIG_PATH\""
echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH\""
echo
echo "[HINT] 建议把下面两行追加到 ~/.bashrc 或 ~/.zshrc："
echo "export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig:$PREFIX/lib/x86_64-linux-gnu/pkgconfig:\$PKG_CONFIG_PATH"
echo "export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/lib64:$PREFIX/lib/x86_64-linux-gnu:\$LD_LIBRARY_PATH"

# ==== 验证 ====
echo
echo "[VERIFY] pkg-config:"
pkg-config --modversion arrow || { echo "arrow.pc 未找到，请检查 PKG_CONFIG_PATH"; exit 1; }
pkg-config --modversion parquet || { echo "parquet.pc 未找到，请检查 PKG_CONFIG_PATH"; exit 1; }
echo "[OK] Arrow/Parquet pkg-config 可用"

# 小测试（可选）
cat > /tmp/arrow_test.cc <<'CPP'
#include <arrow/api.h>
#include <parquet/arrow/writer.h>
#include <iostream>
int main(){ std::cout << "Arrow OK\n"; return 0; }
CPP
g++ /tmp/arrow_test.cc $(pkg-config --cflags --libs arrow parquet) -o /tmp/arrow_test
/tmp/arrow_test
echo "[DONE] 一切就绪"