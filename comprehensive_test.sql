-- 全面测试 EXPLAIN 缓存修复
.timer on
PRAGMA enable_query_cache = true;

-- 测试 1: 第一次执行查询（缓存未命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 测试 2: 第二次执行相同查询（缓存命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 测试 3: EXPLAIN 查询（应该显示底层查询缓存命中）
EXPLAIN SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 测试 4: EXPLAIN ANALYZE 查询（应该显示底层查询缓存命中）
EXPLAIN ANALYZE SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 测试 5: 新查询（缓存未命中）
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';

-- 测试 6: EXPLAIN 新查询（应该显示底层查询缓存未命中）
EXPLAIN SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1996-01-01';