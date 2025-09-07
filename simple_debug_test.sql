-- 简单的缓存测试
.timer on

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 验证设置
SELECT current_setting('enable_query_cache') as cache_enabled;
SELECT current_setting('query_cache_max_size') as cache_size;

-- 执行一个简单的查询
SELECT COUNT(*) FROM generate_series(1, 100000);
SELECT '---------' as separator;

-- 再次执行相同的查询
SELECT COUNT(*) FROM generate_series(1, 100000);
SELECT '---------' as separator;

-- 第三次执行
SELECT COUNT(*) FROM generate_series(1, 100000);
SELECT '---------' as separator;