.timer on
PRAGMA enable_query_cache = true;

-- First execution - should cache the result
SELECT COUNT(*) FROM (SELECT 1 as x UNION ALL SELECT 2 as x UNION ALL SELECT 3 as x);

-- Second execution - should hit cache
SELECT COUNT(*) FROM (SELECT 1 as x UNION ALL SELECT 2 as x UNION ALL SELECT 3 as x);

-- EXPLAIN should show underlying query cache status
EXPLAIN SELECT COUNT(*) FROM (SELECT 1 as x UNION ALL SELECT 2 as x UNION ALL SELECT 3 as x);

-- EXPLAIN ANALYZE should show that underlying query was cached but executed for analysis
EXPLAIN ANALYZE SELECT COUNT(*) FROM (SELECT 1 as x UNION ALL SELECT 2 as x UNION ALL SELECT 3 as x);