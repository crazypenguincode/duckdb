-- 测试查询缓存功能
.timer on

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 验证设置
SELECT 'Cache enabled: ' || current_setting('enable_query_cache') as status;
SELECT 'Cache max size: ' || current_setting('query_cache_max_size') as status;

-- 执行一个计算密集的查询
SELECT 'First execution (should be slow):' as info;
SELECT COUNT(*) as count FROM generate_series(1, 2000000) WHERE generate_series % 2 = 0;

-- 再次执行相同的查询（应该更快，如果缓存工作的话）
SELECT 'Second execution (should be faster if cached):' as info;
SELECT COUNT(*) as count FROM generate_series(1, 2000000) WHERE generate_series % 2 = 0;

-- 第三次执行
SELECT 'Third execution (should be faster if cached):' as info;
SELECT COUNT(*) as count FROM generate_series(1, 2000000) WHERE generate_series % 2 = 0;