-- 快速缓存测试
.timer on

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 简单的SELECT查询
SELECT '第1次执行' AS test_info;
SELECT COUNT(*) FROM customer;

SELECT '第2次执行' AS test_info;
SELECT COUNT(*) FROM customer;

SELECT '第3次执行' AS test_info;
SELECT COUNT(*) FROM customer;