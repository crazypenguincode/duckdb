#!/bin/bash

# TPC-H 缓存性能测试运行脚本
# 自动运行TPC-H缓存性能测试并生成报告

echo "🎯 TPC-H 缓存性能测试启动器"
echo "=================================="

# 检查当前目录
if [ ! -d "part5_test" ]; then
    echo "❌ 请在 duckdb 根目录下运行此脚本"
    exit 1
fi

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 检查DuckDB可执行文件
DUCKDB_PATH="/Users/max/src/duckdb/build/release/duckdb"
if [ ! -f "$DUCKDB_PATH" ]; then
    echo "❌ DuckDB可执行文件不存在: $DUCKDB_PATH"
    echo "请先编译DuckDB: make release"
    exit 1
fi

# 检查TPC-H数据库
TPCH_DB="/Users/max/test/tpc/tpch-sf1.db"
if [ ! -f "$TPCH_DB" ]; then
    echo "❌ TPC-H数据库文件不存在: $TPCH_DB"
    echo "请先创建TPC-H数据库"
    exit 1
fi

# 检查TPC-H查询文件
QUERIES_DIR="/Users/max/src/duckdb/extension/tpch/dbgen/queries"
if [ ! -d "$QUERIES_DIR" ]; then
    echo "❌ TPC-H查询目录不存在: $QUERIES_DIR"
    exit 1
fi

echo "✅ 环境检查通过"
echo ""

# 创建结果目录
mkdir -p part5_test/tpch_cache_results

# 运行测试
echo "🚀 开始TPC-H缓存性能测试..."
echo "⏰ 预计耗时: 10-30分钟 (取决于查询复杂度)"
echo ""

cd part5_test

python3 tpch_cache_performance_test.py

# 检查测试结果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 测试完成!"
    echo "📁 结果文件位置: part5_test/tpch_cache_results/"
    echo ""
    echo "📊 生成的文件包括:"
    echo "   - JSON格式的详细结果"
    echo "   - CSV格式的汇总数据" 
    echo "   - Markdown格式的测试报告"
    echo "   - Mermaid图表文件"
    echo ""
    echo "📈 查看图表:"
    echo "   1. 打开生成的 .md 文件"
    echo "   2. 使用支持Mermaid的Markdown查看器"
    echo "   3. 或使用VS Code的Mermaid插件"
else
    echo "❌ 测试失败"
    exit 1
fi