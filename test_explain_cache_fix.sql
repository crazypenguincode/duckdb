-- 测试 EXPLAIN 语句缓存状态显示修复
-- 
-- 使用方法：
-- 1. 编译修复后的 DuckDB
-- 2. 运行: ./build/release/duckdb ~/test/tpc/tpch-sf1.db < test_explain_cache_fix.sql

-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 启用计时器
.timer on

-- 首次执行查询（应该是缓存未命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';

-- 第二次执行相同查询（应该是缓存命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';

-- 使用 EXPLAIN 查看第三次执行（修复后应该正确显示缓存命中）
EXPLAIN SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';

-- 使用 EXPLAIN ANALYZE 查看第四次执行（修复后应该正确显示缓存命中）
EXPLAIN ANALYZE SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';

-- 显示缓存统计信息
SELECT * FROM pragma_query_cache_stats();