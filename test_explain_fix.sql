-- 测试 EXPLAIN 缓存修复
.timer on
PRAGMA enable_query_cache = true;

-- 第一次执行查询（应该缓存未命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 第二次执行相同查询（应该缓存命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 现在测试 EXPLAIN（应该显示底层查询缓存命中）
EXPLAIN SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';