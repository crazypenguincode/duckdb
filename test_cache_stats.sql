-- 测试缓存统计功能
CREATE TABLE test_table(id INTEGER, value VARCHAR);
INSERT INTO test_table VALUES (1, 'A'), (2, 'B'), (3, 'C');

-- 启用查询缓存
PRAGMA enable_query_cache;

-- 检查初始状态
SELECT 'Initial stats:' as status;
SELECT * FROM pragma_query_cache_stats();

-- 执行第一次查询（应该缓存）
SELECT 'First query execution:' as status;
SELECT * FROM test_table WHERE id < 3;

-- 检查缓存状态
SELECT 'After first query:' as status;
SELECT * FROM pragma_query_cache_stats();

-- 执行相同查询（应该命中缓存）
SELECT 'Second query execution (should hit cache):' as status;
SELECT * FROM test_table WHERE id < 3;

-- 检查最终缓存状态
SELECT 'Final stats:' as status;
SELECT * FROM pragma_query_cache_stats();