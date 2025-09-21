.timer on
PRAGMA enable_query_cache = true;

-- First execution to populate cache
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- Second execution should hit cache
SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';

-- Now test EXPLAIN ANALYZE - should show cache status correctly
EXPLAIN ANALYZE SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01' AND l_shipdate < '1995-01-01';