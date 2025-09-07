-- 详细的缓存测试脚本
.timer on

-- 显示初始缓存设置
SELECT '=== Initial Settings ===' AS info;
SELECT name, value FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 启用查询缓存
SELECT '=== Enabling Cache ===' AS info;
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 显示更新后的缓存设置
SELECT '=== Updated Settings ===' AS info;
SELECT name, value FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 测试查询1：简单计数查询
SELECT '=== Test 1: First Execution ===' AS info;
SELECT COUNT(*) as customer_count FROM customer;

SELECT '=== Test 2: Second Execution (Should Use Cache) ===' AS info;
SELECT COUNT(*) as customer_count FROM customer;

SELECT '=== Test 3: Third Execution (Should Use Cache) ===' AS info;
SELECT COUNT(*) as customer_count FROM customer;

-- 测试查询2：带条件的查询
SELECT '=== Test 4: First Complex Query ===' AS info;
SELECT c_mktsegment, COUNT(*) as count FROM customer GROUP BY c_mktsegment ORDER BY count DESC;

SELECT '=== Test 5: Second Complex Query (Should Use Cache) ===' AS info;
SELECT c_mktsegment, COUNT(*) as count FROM customer GROUP BY c_mktsegment ORDER BY count DESC;

SELECT '=== Test 6: Third Complex Query (Should Use Cache) ===' AS info;
SELECT c_mktsegment, COUNT(*) as count FROM customer GROUP BY c_mktsegment ORDER BY count DESC;