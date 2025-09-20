#!/bin/bash

# DuckDB 跨进程缓存持久化测试编译和运行脚本

set -e

echo "🚀 DuckDB 跨进程缓存持久化测试"
echo "=================================="

# 检查是否在DuckDB源码目录
if [ ! -f "CMakeLists.txt" ] || [ ! -d "src" ]; then
    echo "❌ 错误: 请在DuckDB源码根目录下运行此脚本"
    exit 1
fi

# 设置编译参数
BUILD_DIR="build/release"
TEST_EXECUTABLE="cross_process_cache_test"

echo "📁 构建目录: $BUILD_DIR"

# 创建构建目录
mkdir -p $BUILD_DIR

echo "🔨 编译DuckDB和测试程序..."

# 进入构建目录
cd $BUILD_DIR

# 配置CMake
if [ ! -f "Makefile" ]; then
    echo "⚙️  配置CMake..."
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_EXTENSIONS="json;tpch;tpcds" \
          -DENABLE_SANITIZER=FALSE \
          -DENABLE_UBSAN=FALSE \
          ../..
fi

# 编译DuckDB
echo "🔧 编译DuckDB核心库..."
make -j$(nproc) duckdb

# 编译测试程序
echo "🔧 编译跨进程缓存测试程序..."

# 获取DuckDB包含目录和库文件
DUCKDB_INCLUDE_DIR="../../src/include"
DUCKDB_LIB_DIR="./src"
DUCKDB_LIB="libduckdb.so"

# 编译C++测试程序
g++ -std=c++17 -O3 \
    -I$DUCKDB_INCLUDE_DIR \
    -L$DUCKDB_LIB_DIR \
    ../../cross_process_cache_test.cpp \
    -lduckdb \
    -lpthread \
    -o $TEST_EXECUTABLE

if [ $? -eq 0 ]; then
    echo "✅ 编译成功!"
else
    echo "❌ 编译失败!"
    exit 1
fi

# 设置库路径
export LD_LIBRARY_PATH="$PWD/src:$LD_LIBRARY_PATH"

echo ""
echo "🧪 运行跨进程缓存持久化测试..."
echo "=================================="

# 运行C++测试程序
./$TEST_EXECUTABLE

echo ""
echo "🐍 运行Python测试脚本..."
echo "========================="

# 回到根目录运行Python脚本
cd ../..

# 检查Python脚本是否存在
if [ -f "cross_process_cache_persistence_test.py" ]; then
    # 设置DuckDB可执行文件路径
    export PATH="$PWD/$BUILD_DIR/tools/shell:$PATH"
    
    # 运行Python测试脚本
    python3 cross_process_cache_persistence_test.py
else
    echo "⚠️  Python测试脚本不存在，跳过Python测试"
fi

echo ""
echo "📊 测试完成!"
echo "============"
echo "📄 C++测试报告: $BUILD_DIR/cross_process_cache_performance_report.md"
echo "📄 Python测试报告: cross_process_cache_persistence_report.md"
echo "📊 详细数据: cross_process_cache_test_data.json"

# 显示报告摘要
echo ""
echo "📈 测试结果摘要:"
echo "================"

if [ -f "$BUILD_DIR/cross_process_cache_performance_report.md" ]; then
    echo "C++测试结果:"
    grep -A 10 "策略性能对比" "$BUILD_DIR/cross_process_cache_performance_report.md" | head -15
fi

if [ -f "cross_process_cache_persistence_report.md" ]; then
    echo ""
    echo "Python测试结果:"
    grep -A 10 "策略性能对比" "cross_process_cache_persistence_report.md" | head -15
fi

echo ""
echo "🎉 所有测试完成! 请查看详细报告了解性能对比结果。"