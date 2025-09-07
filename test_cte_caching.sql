-- CTE缓存测试脚本
CREATE TABLE users(id INTEGER, name VARCHAR);
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'David'), (5, 'Eve'), (6, 'Frank');

-- 启用查询缓存
PRAGMA enable_query_cache;

-- 测试1: 基础CTE查询
WITH cte AS (SELECT * FROM users WHERE id < 3)
SELECT * FROM cte;
SELECT * FROM pragma_query_cache_stats();  -- 检查缓存状态

-- 测试2: 再次执行相同的CTE查询（应该命中缓存）
WITH cte AS (SELECT * FROM users WHERE id < 3)
SELECT * FROM cte;
SELECT * FROM pragma_query_cache_stats();  -- 检查缓存状态

-- 测试3: 嵌套CTE
WITH cte1 AS (SELECT * FROM users WHERE id > 3),
     cte2 AS (SELECT * FROM cte1 WHERE name LIKE 'D%')
SELECT * FROM cte2;
SELECT * FROM pragma_query_cache_stats();  -- 检查缓存状态

-- 测试4: CTE结果变更后的缓存失效
WITH cte AS (SELECT * FROM users WHERE id < 4)
SELECT * FROM cte;

-- 更新数据
UPDATE users SET name = 'Updated' WHERE id = 3;

-- 再次执行相同CTE（缓存应该仍然有效，因为我们没有实现表依赖检查）
WITH cte AS (SELECT * FROM users WHERE id < 4)
SELECT * FROM cte;
SELECT * FROM pragma_query_cache_stats();  -- 检查缓存状态

-- 清除缓存
PRAGMA clear_query_cache;
SELECT * FROM pragma_query_cache_stats();  -- 检查缓存状态