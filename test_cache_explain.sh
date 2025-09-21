#!/bin/bash

echo "=== 测试EXPLAIN中的缓存信息显示功能 ==="

# 启动DuckDB并执行测试
./build/release/duckdb ~/test/tpc/tpch-sf1.db << 'EOF'
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 第一次执行查询（应该是缓存未命中）
EXPLAIN ANALYZE SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue 
FROM customer, orders, lineitem, supplier, nation, region 
WHERE c_custkey = o_custkey 
  AND l_orderkey = o_orderkey 
  AND l_suppkey = s_suppkey 
  AND c_nationkey = s_nationkey 
  AND s_nationkey = n_nationkey 
  AND n_regionkey = r_regionkey 
  AND r_name = 'ASIA' 
  AND o_orderdate >= CAST('1994-01-01' AS date) 
  AND o_orderdate < CAST('1995-01-01' AS date) 
GROUP BY n_name 
ORDER BY revenue DESC;

-- 等待一下
.timer on

-- 第二次执行相同查询（应该是缓存命中）
EXPLAIN ANALYZE SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue 
FROM customer, orders, lineitem, supplier, nation, region 
WHERE c_custkey = o_custkey 
  AND l_orderkey = o_orderkey 
  AND l_suppkey = s_suppkey 
  AND c_nationkey = s_nationkey 
  AND s_nationkey = n_nationkey 
  AND n_regionkey = r_regionkey 
  AND r_name = 'ASIA' 
  AND o_orderdate >= CAST('1994-01-01' AS date) 
  AND o_orderdate < CAST('1995-01-01' AS date) 
GROUP BY n_name 
ORDER BY revenue DESC;

-- 测试JSON格式
EXPLAIN (ANALYZE, FORMAT JSON) SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue 
FROM customer, orders, lineitem, supplier, nation, region 
WHERE c_custkey = o_custkey 
  AND l_orderkey = o_orderkey 
  AND l_suppkey = s_suppkey 
  AND c_nationkey = s_nationkey 
  AND s_nationkey = n_nationkey 
  AND n_regionkey = r_regionkey 
  AND r_name = 'ASIA' 
  AND o_orderdate >= CAST('1994-01-01' AS date) 
  AND o_orderdate < CAST('1995-01-01' AS date) 
GROUP BY n_name 
ORDER BY revenue DESC;

.quit
EOF

echo "=== 测试完成 ==="