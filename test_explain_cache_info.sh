#!/bin/bash

echo "=== 测试EXPLAIN ANALYZE中的缓存信息显示 ==="

# 测试1: 简单查询的缓存未命中
echo "--- 测试1: 第一次执行查询（缓存未命中）---"
echo "PRAGMA enable_query_cache = true; EXPLAIN ANALYZE SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;" | ./build/release/duckdb 2>/dev/null

echo ""
echo "--- 测试2: 第二次执行相同查询（仍然是缓存未命中，因为EXPLAIN ANALYZE不使用缓存）---"
echo "PRAGMA enable_query_cache = true; EXPLAIN ANALYZE SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;" | ./build/release/duckdb 2>/dev/null

echo ""
echo "--- 测试3: 显示缓存统计信息 ---"
echo "PRAGMA enable_query_cache = true; SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t; EXPLAIN CACHE;" | ./build/release/duckdb 2>/dev/null

echo ""
echo "=== 测试完成 ==="
echo ""
echo "注意：EXPLAIN ANALYZE显示的缓存信息反映的是查询执行时的缓存状态。"
echo "由于EXPLAIN ANALYZE需要实际执行查询来收集性能数据，它本身不会使用缓存的结果。"
echo "但是它会显示缓存的当前状态，包括是否命中缓存以及缓存统计信息。"