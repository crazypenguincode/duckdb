-- 测试单个查询的缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 第一次执行
SELECT COUNT(*) FROM customer;

-- 第二次执行（应该使用缓存）
SELECT COUNT(*) FROM customer;