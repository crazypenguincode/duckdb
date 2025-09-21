-- 最终验证 EXPLAIN 缓存状态显示
.timer on
PRAGMA enable_query_cache = true;

-- 执行查询以填充缓存
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- 现在 EXPLAIN 应该显示缓存命中
EXPLAIN SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';