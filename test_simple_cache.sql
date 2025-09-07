-- 简单的查询缓存测试脚本
.timer on

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 显示设置状态
SELECT 'Cache Settings:' AS info;
SELECT * FROM duckdb_settings() WHERE name LIKE '%cache%';

-- 创建测试表
CREATE TABLE test_table AS SELECT i, i*2 as value FROM range(1000000) t(i);

-- 第一次查询（冷缓存）
SELECT '第1次查询 - 冷缓存' AS test_info;
SELECT COUNT(*), SUM(value) FROM test_table WHERE i % 100 = 0;

SELECT '---------' AS separator;

-- 第二次查询（应该使用缓存）
SELECT '第2次查询 - 应该命中缓存' AS test_info;
SELECT COUNT(*), SUM(value) FROM test_table WHERE i % 100 = 0;

SELECT '---------' AS separator;

-- 第三次查询（应该使用缓存）
SELECT '第3次查询 - 应该命中缓存' AS test_info;
SELECT COUNT(*), SUM(value) FROM test_table WHERE i % 100 = 0;

SELECT '---------' AS separator;

-- 显示缓存状态
SELECT 'Final Cache Settings:' AS info;
SELECT * FROM duckdb_settings() WHERE name LIKE '%cache%';