#!/bin/bash

echo "=== DuckDB查询缓存性能测试 ==="
echo "编译版本: $(./build/release/duckdb --version)"
echo ""

# 创建临时数据库文件
TEMP_DB="/tmp/cache_test.db"
rm -f $TEMP_DB

echo "=== 创建测试数据 ==="
./build/release/duckdb $TEMP_DB -c "
PRAGMA enable_query_cache=true;
CREATE TABLE test_orders AS SELECT 
    range AS o_orderkey,
    (range % 1000) AS o_custkey,
    (range * 1.5 + 100) AS o_totalprice,
    CASE (range % 3) 
        WHEN 0 THEN 'O' 
        WHEN 1 THEN 'F' 
        ELSE 'P' 
    END AS o_orderstatus
FROM range(50000);
"

echo "测试数据创建完成"
echo ""

echo "=== 测试1: 简单COUNT查询 ==="
echo "初始缓存状态:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "第一次执行 SELECT COUNT(*) FROM test_orders:"
time ./build/release/duckdb $TEMP_DB -c "SELECT COUNT(*) FROM test_orders;"

echo ""
echo "缓存状态:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "第二次执行 SELECT COUNT(*) FROM test_orders:"
time ./build/release/duckdb $TEMP_DB -c "SELECT COUNT(*) FROM test_orders;"

echo ""
echo "缓存状态:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "第三次执行 SELECT COUNT(*) FROM test_orders:"
time ./build/release/duckdb $TEMP_DB -c "SELECT COUNT(*) FROM test_orders;"

echo ""
echo "最终缓存状态:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "=== 测试2: 聚合查询 ==="
echo "第一次执行 SELECT AVG(o_totalprice) FROM test_orders:"
time ./build/release/duckdb $TEMP_DB -c "SELECT AVG(o_totalprice) FROM test_orders;"

echo ""
echo "第二次执行 SELECT AVG(o_totalprice) FROM test_orders:"
time ./build/release/duckdb $TEMP_DB -c "SELECT AVG(o_totalprice) FROM test_orders;"

echo ""
echo "缓存状态:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "=== 测试3: 复杂查询 ==="
echo "第一次执行复杂查询:"
time ./build/release/duckdb $TEMP_DB -c "
SELECT 
    o_orderstatus,
    COUNT(*) as order_count,
    AVG(o_totalprice) as avg_price,
    SUM(o_totalprice) as total_price
FROM test_orders 
GROUP BY o_orderstatus 
ORDER BY o_orderstatus;
"

echo ""
echo "第二次执行复杂查询:"
time ./build/release/duckdb $TEMP_DB -c "
SELECT 
    o_orderstatus,
    COUNT(*) as order_count,
    AVG(o_totalprice) as avg_price,
    SUM(o_totalprice) as total_price
FROM test_orders 
GROUP BY o_orderstatus 
ORDER BY o_orderstatus;
"

echo ""
echo "最终缓存统计:"
./build/release/duckdb $TEMP_DB -c "SELECT * FROM pragma_query_cache_stats();"

echo ""
echo "=== 测试完成 ==="
echo "清理临时文件..."
rm -f $TEMP_DB
echo "测试结束"