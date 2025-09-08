#!/bin/bash

echo "=== DuckDB查询缓存测试 (单会话) ==="

DB_PATH="/Users/max/test/tpc/tpch-sf1.db"
DUCKDB_BIN="./build/release/duckdb"

# 创建一个包含多个查询的SQL脚本
cat > /tmp/cache_test.sql << 'EOF'
-- 检查初始缓存状态
.print "1. 初始缓存状态:"
SELECT * FROM pragma_query_cache_stats();

-- 第一次执行测试查询
.print ""
.print "2. 第一次执行查询:"
.timer on
SELECT COUNT(*) FROM orders;
.timer off

-- 检查缓存状态
.print ""
.print "3. 第一次执行后的缓存状态:"
SELECT * FROM pragma_query_cache_stats();

-- 第二次执行相同查询
.print ""
.print "4. 第二次执行查询:"
.timer on
SELECT COUNT(*) FROM orders;
.timer off

-- 检查缓存状态
.print ""
.print "5. 第二次执行后的缓存状态:"
SELECT * FROM pragma_query_cache_stats();

-- 第三次执行相同查询
.print ""
.print "6. 第三次执行查询:"
.timer on
SELECT COUNT(*) FROM orders;
.timer off

-- 最终缓存状态
.print ""
.print "7. 最终缓存状态:"
SELECT * FROM pragma_query_cache_stats();

-- 测试不同的查询
.print ""
.print "8. 执行不同的查询:"
.timer on
SELECT AVG(o_totalprice) FROM orders;
.timer off

-- 最终缓存状态
.print ""
.print "9. 执行不同查询后的缓存状态:"
SELECT * FROM pragma_query_cache_stats();
EOF

echo "在单个DuckDB会话中执行测试..."
$DUCKDB_BIN $DB_PATH < /tmp/cache_test.sql

# 清理临时文件
rm -f /tmp/cache_test.sql