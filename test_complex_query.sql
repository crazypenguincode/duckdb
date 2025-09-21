.timer on
PRAGMA enable_query_cache = true;

-- 第一次执行复杂查询
SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue
  FROM customer, orders, lineitem, supplier, nation, region
  WHERE c_custkey = o_custkey AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= CAST('1994-01-01' AS date)
    AND o_orderdate < CAST('1995-01-01' AS date)
  GROUP BY n_name ORDER BY revenue DESC;

-- 第二次执行相同查询（应该缓存命中）
SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue
  FROM customer, orders, lineitem, supplier, nation, region
  WHERE c_custkey = o_custkey AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= CAST('1994-01-01' AS date)
    AND o_orderdate < CAST('1995-01-01' AS date)
  GROUP BY n_name ORDER BY revenue DESC;

-- 测试普通 EXPLAIN（应该显示缓存命中）
EXPLAIN SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue
  FROM customer, orders, lineitem, supplier, nation, region
  WHERE c_custkey = o_custkey AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= CAST('1994-01-01' AS date)
    AND o_orderdate < CAST('1995-01-01' AS date)
  GROUP BY n_name ORDER BY revenue DESC;

-- 测试 EXPLAIN ANALYZE（这个会重新执行查询）
EXPLAIN ANALYZE SELECT n_name, sum(l_extendedprice * (1 - l_discount)) AS revenue
  FROM customer, orders, lineitem, supplier, nation, region
  WHERE c_custkey = o_custkey AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= CAST('1994-01-01' AS date)
    AND o_orderdate < CAST('1995-01-01' AS date)
  GROUP BY n_name ORDER BY revenue DESC;