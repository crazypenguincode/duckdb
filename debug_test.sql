-- 调试缓存测试
.timer on
SET enable_query_cache = true;
SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM customer;