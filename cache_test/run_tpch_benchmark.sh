#!/bin/bash

# TPC-H 缓存基准测试编译和运行脚本

echo "🔧 编译TPC-H缓存基准测试程序..."

# 设置编译参数
CXX_FLAGS="-std=c++17 -O2 -Wall -Wextra"
INCLUDE_DIRS="-I./src/include"
LIBRARY_DIRS="-L./build/release/src"
LIBRARIES="-lduckdb"
RPATH="-Wl,-rpath,./build/release/src"

# 编译程序
g++ $CXX_FLAGS $INCLUDE_DIRS cache_test/tpch_cache_benchmark_simple.cpp \
    $LIBRARY_DIRS $LIBRARIES $RPATH \
    -o cache_test/tpch_cache_benchmark_simple

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    
    echo ""
    echo "🚀 运行TPC-H缓存基准测试..."
    echo ""
    
    # 创建结果目录
    mkdir -p cache_test/results
    
    # 运行测试
    ./cache_test/tpch_cache_benchmark_simple
    
    echo ""
    echo "📊 测试完成！查看结果："
    echo "  - 控制台输出：上方显示的测试结果"
    echo "  - 详细报告：cache_test/results/tpch_benchmark_report.json"
    
    if [ -f "cache_test/results/tpch_benchmark_report.json" ]; then
        echo ""
        echo "📄 报告文件内容预览："
        head -20 cache_test/results/tpch_benchmark_report.json
    fi
    
else
    echo "❌ 编译失败！"
    echo ""
    echo "🔍 可能的解决方案："
    echo "1. 确保DuckDB已正确编译：make release"
    echo "2. 检查include路径是否正确"
    echo "3. 检查库文件路径是否正确"
    echo "4. 确保C++17编译器可用"
    exit 1
fi