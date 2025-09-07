-- 调试缓存功能的简单脚本
.timer on

-- 显示当前缓存设置
SELECT 'Current cache settings:' AS info;
SELECT * FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 再次显示缓存设置
SELECT 'After enabling cache:' AS info;
SELECT * FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 简单的测试查询
SELECT 'First execution:' AS test_info;
SELECT COUNT(*) as total_customers FROM customer;

SELECT '---------' AS separator;

-- 第二次执行相同查询
SELECT 'Second execution (should use cache):' AS test_info;
SELECT COUNT(*) as total_customers FROM customer;

SELECT '---------' AS separator;

-- 第三次执行相同查询
SELECT 'Third execution (should use cache):' AS test_info;
SELECT COUNT(*) as total_customers FROM customer;