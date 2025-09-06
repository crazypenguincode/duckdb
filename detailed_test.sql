-- 详细的查询缓存测试
.timer on

-- 检查默认设置
SELECT 'enable_query_cache: ' || current_setting('enable_query_cache') as setting;
SELECT 'query_cache_max_size: ' || current_setting('query_cache_max_size') as setting;

-- 启用查询缓存
SET enable_query_cache=true;
SET query_cache_max_size='10MB';

-- 再次检查设置
SELECT 'enable_query_cache: ' || current_setting('enable_query_cache') as setting;
SELECT 'query_cache_max_size: ' || current_setting('query_cache_max_size') as setting;

-- 创建测试表
CREATE TABLE test AS SELECT i, i*2 as doubled FROM range(10000) t(i);

-- 第一次查询（复杂一些的查询）
SELECT '=== 第一次查询 ===' as message;
SELECT COUNT(*), SUM(doubled), AVG(i) FROM test WHERE i > 5000;

-- 第二次相同查询
SELECT '=== 第二次查询（应该从缓存返回）===' as message;
SELECT COUNT(*), SUM(doubled), AVG(i) FROM test WHERE i > 5000;

-- 第三次相同查询
SELECT '=== 第三次查询（应该从缓存返回）===' as message;
SELECT COUNT(*), SUM(doubled), AVG(i) FROM test WHERE i > 5000;