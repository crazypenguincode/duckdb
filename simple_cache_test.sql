-- 简单测试查询缓存设置
.timer on

-- 测试设置是否被识别
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 显示设置是否生效
SELECT current_setting('enable_query_cache') as enable_cache;
SELECT current_setting('query_cache_max_size') as max_size;