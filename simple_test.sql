-- 简单的查询缓存测试
.timer on

-- 启用查询缓存
SET enable_query_cache=true;
SET query_cache_max_size='10MB';

-- 创建小测试表
CREATE TABLE test AS SELECT i FROM range(1000) t(i);

-- 第一次查询
SELECT '=== 第一次查询 ===' as message;
SELECT COUNT(*) FROM test WHERE i > 500;

-- 第二次相同查询
SELECT '=== 第二次查询（应该从缓存返回）===' as message;
SELECT COUNT(*) FROM test WHERE i > 500;