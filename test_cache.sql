-- 启用查询缓存
PRAGMA enable_query_cache=true;

-- 创建测试表
CREATE TABLE test_table AS SELECT range AS id, range * 2 AS value FROM range(10000);

-- 检查初始状态
.print "=== 初始缓存状态 ==="
SELECT * FROM pragma_query_cache_stats();

-- 第一次执行查询
.print "=== 第一次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 第二次执行相同查询
.print "=== 第二次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 第三次执行相同查询
.print "=== 第三次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 最终缓存状态
.print "=== 最终缓存状态 ==="
SELECT * FROM pragma_query_cache_stats();