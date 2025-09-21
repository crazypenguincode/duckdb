#!/bin/bash

# 测试TPC-H Q05查询的EXPLAIN功能

echo "=== 测试TPC-H Q05查询的EXPLAIN功能 ==="

# 定义查询
Q05_QUERY="SELECT
    n_name,
    sum(l_extendedprice * (1 - l_discount)) AS revenue
FROM
    customer,
    orders,
    lineitem,
    supplier,
    nation,
    region
WHERE
    c_custkey = o_custkey
    AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey
    AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey
    AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= CAST('1994-01-01' AS date)
    AND o_orderdate < CAST('1995-01-01' AS date)
GROUP BY
    n_name
ORDER BY
    revenue DESC;"

echo "1. 基本EXPLAIN (物理计划):"
echo "EXPLAIN $Q05_QUERY" | ./build/release/duckdb ~/test/tpc/tpch-sf1.db

echo ""
echo "2. EXPLAIN ANALYZE (带执行时间和实际行数):"
echo "EXPLAIN ANALYZE $Q05_QUERY" | ./build/release/duckdb ~/test/tpc/tpch-sf1.db

echo ""
echo "3. EXPLAIN (FORMAT JSON) (JSON格式):"
echo "EXPLAIN (FORMAT JSON) $Q05_QUERY" | ./build/release/duckdb ~/test/tpc/tpch-sf1.db

echo ""
echo "4. 实际执行查询 (验证结果):"
echo "$Q05_QUERY" | ./build/release/duckdb ~/test/tpc/tpch-sf1.db

echo ""
echo "=== 测试完成 ==="