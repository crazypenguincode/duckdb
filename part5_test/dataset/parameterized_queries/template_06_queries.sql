-- Template 6: 客户价值分析
-- Parameterized Template: SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= ? GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= ? ORDER BY avg_order_value DESC LIMIT ?;

-- Variation 1
-- Parameters: {'reg_date': '2023-02-01', 'min_orders': 1, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-01' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 2
-- Parameters: {'reg_date': '2023-03-14', 'min_orders': 5, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-03-14' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 3
-- Parameters: {'reg_date': '2023-03-26', 'min_orders': 1, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-03-26' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 4
-- Parameters: {'reg_date': '2023-02-14', 'min_orders': 2, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-14' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 5
-- Parameters: {'reg_date': '2023-02-16', 'min_orders': 3, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-16' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 6
-- Parameters: {'reg_date': '2023-05-26', 'min_orders': 1, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-26' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 7
-- Parameters: {'reg_date': '2023-06-21', 'min_orders': 1, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-21' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 8
-- Parameters: {'reg_date': '2023-05-07', 'min_orders': 5, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-07' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 9
-- Parameters: {'reg_date': '2023-01-23', 'min_orders': 2, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-23' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 10
-- Parameters: {'reg_date': '2023-03-29', 'min_orders': 5, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-03-29' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 11
-- Parameters: {'reg_date': '2023-01-12', 'min_orders': 3, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-12' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 12
-- Parameters: {'reg_date': '2023-07-17', 'min_orders': 3, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-07-17' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 13
-- Parameters: {'reg_date': '2023-05-10', 'min_orders': 5, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-10' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 14
-- Parameters: {'reg_date': '2023-02-21', 'min_orders': 5, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-21' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 15
-- Parameters: {'reg_date': '2023-04-19', 'min_orders': 1, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-04-19' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 16
-- Parameters: {'reg_date': '2023-01-27', 'min_orders': 1, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-27' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 17
-- Parameters: {'reg_date': '2023-02-27', 'min_orders': 1, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-27' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 18
-- Parameters: {'reg_date': '2023-02-03', 'min_orders': 5, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-03' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 19
-- Parameters: {'reg_date': '2023-05-15', 'min_orders': 5, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-15' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 20
-- Parameters: {'reg_date': '2023-01-30', 'min_orders': 3, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-30' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 21
-- Parameters: {'reg_date': '2023-05-12', 'min_orders': 3, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-12' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 22
-- Parameters: {'reg_date': '2023-05-18', 'min_orders': 1, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-18' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 23
-- Parameters: {'reg_date': '2023-04-10', 'min_orders': 3, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-04-10' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 24
-- Parameters: {'reg_date': '2023-06-05', 'min_orders': 1, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-05' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 25
-- Parameters: {'reg_date': '2023-02-01', 'min_orders': 2, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-01' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 26
-- Parameters: {'reg_date': '2023-02-19', 'min_orders': 5, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-19' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 27
-- Parameters: {'reg_date': '2023-01-26', 'min_orders': 5, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-26' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 28
-- Parameters: {'reg_date': '2023-07-02', 'min_orders': 3, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-07-02' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 29
-- Parameters: {'reg_date': '2023-05-18', 'min_orders': 5, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-18' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 30
-- Parameters: {'reg_date': '2023-07-17', 'min_orders': 5, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-07-17' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 31
-- Parameters: {'reg_date': '2023-07-08', 'min_orders': 2, 'limit': 100}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-07-08' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 100;

-- Variation 32
-- Parameters: {'reg_date': '2023-06-16', 'min_orders': 3, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-16' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 33
-- Parameters: {'reg_date': '2023-05-13', 'min_orders': 5, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-13' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 50;

-- Variation 34
-- Parameters: {'reg_date': '2023-06-19', 'min_orders': 3, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-19' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 35
-- Parameters: {'reg_date': '2023-01-15', 'min_orders': 2, 'limit': 20}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-01-15' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 20;

-- Variation 36
-- Parameters: {'reg_date': '2023-06-09', 'min_orders': 4, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-09' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 4 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 37
-- Parameters: {'reg_date': '2023-02-15', 'min_orders': 2, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-02-15' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 2 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 38
-- Parameters: {'reg_date': '2023-06-28', 'min_orders': 1, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-28' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 1 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 39
-- Parameters: {'reg_date': '2023-05-28', 'min_orders': 3, 'limit': 10}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-05-28' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 3 ORDER BY avg_order_value DESC LIMIT 10;

-- Variation 40
-- Parameters: {'reg_date': '2023-06-06', 'min_orders': 5, 'limit': 50}
SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '2023-06-06' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= 5 ORDER BY avg_order_value DESC LIMIT 50;

