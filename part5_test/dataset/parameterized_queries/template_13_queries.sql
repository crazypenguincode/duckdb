-- Template 13: 小时订单分布
-- Parameterized Template: SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = ? GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 1
-- Parameters: {'target_date': '2023-01-16'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-01-16' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 2
-- Parameters: {'target_date': '2023-09-06'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-09-06' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 3
-- Parameters: {'target_date': '2023-07-25'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-07-25' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 4
-- Parameters: {'target_date': '2023-07-04'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-07-04' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 5
-- Parameters: {'target_date': '2023-10-20'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-10-20' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 6
-- Parameters: {'target_date': '2023-08-11'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-11' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 7
-- Parameters: {'target_date': '2023-11-26'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-11-26' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 8
-- Parameters: {'target_date': '2023-03-07'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-03-07' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 9
-- Parameters: {'target_date': '2023-08-24'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-24' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 10
-- Parameters: {'target_date': '2023-11-20'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-11-20' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 11
-- Parameters: {'target_date': '2023-08-05'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-05' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 12
-- Parameters: {'target_date': '2023-03-25'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-03-25' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 13
-- Parameters: {'target_date': '2023-07-02'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-07-02' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 14
-- Parameters: {'target_date': '2023-12-01'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-12-01' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 15
-- Parameters: {'target_date': '2023-09-03'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-09-03' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 16
-- Parameters: {'target_date': '2023-10-12'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-10-12' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 17
-- Parameters: {'target_date': '2023-04-16'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-04-16' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 18
-- Parameters: {'target_date': '2023-10-01'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-10-01' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 19
-- Parameters: {'target_date': '2023-10-10'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-10-10' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 20
-- Parameters: {'target_date': '2023-04-15'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-04-15' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 21
-- Parameters: {'target_date': '2023-05-19'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-05-19' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 22
-- Parameters: {'target_date': '2023-03-31'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-03-31' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 23
-- Parameters: {'target_date': '2023-11-01'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-11-01' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 24
-- Parameters: {'target_date': '2023-11-08'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-11-08' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 25
-- Parameters: {'target_date': '2023-02-10'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-02-10' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 26
-- Parameters: {'target_date': '2023-01-04'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-01-04' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 27
-- Parameters: {'target_date': '2023-08-05'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-05' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 28
-- Parameters: {'target_date': '2023-04-22'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-04-22' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 29
-- Parameters: {'target_date': '2023-08-09'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-09' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 30
-- Parameters: {'target_date': '2023-02-25'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-02-25' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 31
-- Parameters: {'target_date': '2023-12-07'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-12-07' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 32
-- Parameters: {'target_date': '2023-01-07'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-01-07' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 33
-- Parameters: {'target_date': '2023-05-24'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-05-24' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 34
-- Parameters: {'target_date': '2023-08-07'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-08-07' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 35
-- Parameters: {'target_date': '2023-05-18'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-05-18' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 36
-- Parameters: {'target_date': '2023-07-06'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-07-06' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 37
-- Parameters: {'target_date': '2023-03-08'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-03-08' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 38
-- Parameters: {'target_date': '2023-10-09'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-10-09' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 39
-- Parameters: {'target_date': '2023-01-24'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-01-24' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

-- Variation 40
-- Parameters: {'target_date': '2023-04-05'}
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '2023-04-05' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;

