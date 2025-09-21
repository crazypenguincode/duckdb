#!/bin/bash

# 编译和测试 EXPLAIN 缓存修复的脚本

echo "=== 编译 DuckDB ==="
cd /Users/max/src/duckdb

# 清理之前的构建
rm -rf build/release

# 重新构建
make release

if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi

echo "=== 编译成功 ==="

echo "=== 运行测试 ==="

# 检查测试数据库是否存在
if [ ! -f ~/test/tpc/tpch-sf1.db ]; then
    echo "错误：测试数据库 ~/test/tpc/tpch-sf1.db 不存在"
    echo "请先创建 TPC-H 测试数据库"
    exit 1
fi

# 运行测试
echo "运行 EXPLAIN 缓存修复测试..."
./build/release/duckdb ~/test/tpc/tpch-sf1.db < test_explain_cache_fix.sql

echo "=== 测试完成 ==="

echo ""
echo "预期结果："
echo "1. 第一次查询应该显示缓存未命中（较长执行时间）"
echo "2. 第二次查询应该显示缓存命中（很短执行时间）"
echo "3. EXPLAIN 应该显示 'Underlying Query Cache: HIT'"
echo "4. EXPLAIN ANALYZE 应该显示 'Underlying Query Cache: HIT'"
echo "5. 缓存统计应该显示命中率 > 0"