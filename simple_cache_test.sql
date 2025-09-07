-- 简单的缓存测试脚本
.timer on

-- 显示初始缓存设置
SELECT 'Initial cache settings:' AS info;
SELECT name, value FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 显示更新后的缓存设置
SELECT 'Updated cache settings:' AS info;
SELECT name, value FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 执行一个简单的查询3次
SELECT 'Test 1 - First execution:' AS test_info;
SELECT COUNT(*) FROM customer WHERE c_mktsegment = 'BUILDING';

SELECT 'Test 2 - Second execution (should use cache):' AS test_info;
SELECT COUNT(*) FROM customer WHERE c_mktsegment = 'BUILDING';

SELECT 'Test 3 - Third execution (should use cache):' AS test_info;
SELECT COUNT(*) FROM customer WHERE c_mktsegment = 'BUILDING';