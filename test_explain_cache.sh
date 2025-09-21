#!/bin/bash

# 测试EXPLAIN CACHE功能的脚本

echo "=== 测试EXPLAIN CACHE功能 ==="

# 启动DuckDB并执行测试
./build/debug/duckdb << 'EOF'
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 执行一些查询来填充缓存
SELECT 1 as test_value;
SELECT 2 as another_value;
SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2) t;

-- 查看缓存状态
EXPLAIN CACHE;

-- 使用JSON格式查看缓存状态
EXPLAIN (CACHE, FORMAT JSON);

.quit
EOF

echo "=== 测试完成 ==="