-- 测试 EXPLAIN ANALYZE 缓存状态显示
.timer on
PRAGMA enable_query_cache = true;

-- 第一次查询（填充缓存）
SELECT COUNT(*) FROM nation;

-- 验证缓存命中
SELECT COUNT(*) FROM nation;

-- 测试 EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT COUNT(*) FROM nation;