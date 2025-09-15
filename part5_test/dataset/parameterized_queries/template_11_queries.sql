-- Template 11: 客户订单历史
-- Parameterized Template: SELECT * FROM orders WHERE customer_id = ? AND order_date >= ? ORDER BY order_date DESC LIMIT ?;

-- Variation 1
-- Parameters: {'customer_id': 219, 'order_date': '2023-09-20', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 219 AND order_date >= '2023-09-20' ORDER BY order_date DESC LIMIT 50;

-- Variation 2
-- Parameters: {'customer_id': 59, 'order_date': '2023-01-24', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 59 AND order_date >= '2023-01-24' ORDER BY order_date DESC LIMIT 10;

-- Variation 3
-- Parameters: {'customer_id': 223, 'order_date': '2023-01-07', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 223 AND order_date >= '2023-01-07' ORDER BY order_date DESC LIMIT 100;

-- Variation 4
-- Parameters: {'customer_id': 70, 'order_date': '2023-01-14', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 70 AND order_date >= '2023-01-14' ORDER BY order_date DESC LIMIT 100;

-- Variation 5
-- Parameters: {'customer_id': 12, 'order_date': '2023-09-06', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 12 AND order_date >= '2023-09-06' ORDER BY order_date DESC LIMIT 20;

-- Variation 6
-- Parameters: {'customer_id': 435, 'order_date': '2023-09-06', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 435 AND order_date >= '2023-09-06' ORDER BY order_date DESC LIMIT 20;

-- Variation 7
-- Parameters: {'customer_id': 458, 'order_date': '2023-11-15', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 458 AND order_date >= '2023-11-15' ORDER BY order_date DESC LIMIT 100;

-- Variation 8
-- Parameters: {'customer_id': 301, 'order_date': '2023-03-09', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 301 AND order_date >= '2023-03-09' ORDER BY order_date DESC LIMIT 100;

-- Variation 9
-- Parameters: {'customer_id': 103, 'order_date': '2023-06-05', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 103 AND order_date >= '2023-06-05' ORDER BY order_date DESC LIMIT 50;

-- Variation 10
-- Parameters: {'customer_id': 59, 'order_date': '2023-09-07', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 59 AND order_date >= '2023-09-07' ORDER BY order_date DESC LIMIT 10;

-- Variation 11
-- Parameters: {'customer_id': 493, 'order_date': '2023-11-09', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 493 AND order_date >= '2023-11-09' ORDER BY order_date DESC LIMIT 10;

-- Variation 12
-- Parameters: {'customer_id': 376, 'order_date': '2023-06-21', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 376 AND order_date >= '2023-06-21' ORDER BY order_date DESC LIMIT 10;

-- Variation 13
-- Parameters: {'customer_id': 367, 'order_date': '2023-03-19', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 367 AND order_date >= '2023-03-19' ORDER BY order_date DESC LIMIT 100;

-- Variation 14
-- Parameters: {'customer_id': 484, 'order_date': '2023-03-26', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 484 AND order_date >= '2023-03-26' ORDER BY order_date DESC LIMIT 100;

-- Variation 15
-- Parameters: {'customer_id': 466, 'order_date': '2023-03-17', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 466 AND order_date >= '2023-03-17' ORDER BY order_date DESC LIMIT 10;

-- Variation 16
-- Parameters: {'customer_id': 44, 'order_date': '2023-09-24', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 44 AND order_date >= '2023-09-24' ORDER BY order_date DESC LIMIT 20;

-- Variation 17
-- Parameters: {'customer_id': 372, 'order_date': '2023-05-13', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 372 AND order_date >= '2023-05-13' ORDER BY order_date DESC LIMIT 50;

-- Variation 18
-- Parameters: {'customer_id': 180, 'order_date': '2023-12-11', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 180 AND order_date >= '2023-12-11' ORDER BY order_date DESC LIMIT 10;

-- Variation 19
-- Parameters: {'customer_id': 425, 'order_date': '2023-03-08', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 425 AND order_date >= '2023-03-08' ORDER BY order_date DESC LIMIT 20;

-- Variation 20
-- Parameters: {'customer_id': 353, 'order_date': '2023-03-15', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 353 AND order_date >= '2023-03-15' ORDER BY order_date DESC LIMIT 50;

-- Variation 21
-- Parameters: {'customer_id': 472, 'order_date': '2023-03-03', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 472 AND order_date >= '2023-03-03' ORDER BY order_date DESC LIMIT 100;

-- Variation 22
-- Parameters: {'customer_id': 402, 'order_date': '2023-04-21', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 402 AND order_date >= '2023-04-21' ORDER BY order_date DESC LIMIT 20;

-- Variation 23
-- Parameters: {'customer_id': 401, 'order_date': '2023-03-12', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 401 AND order_date >= '2023-03-12' ORDER BY order_date DESC LIMIT 10;

-- Variation 24
-- Parameters: {'customer_id': 461, 'order_date': '2023-05-23', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 461 AND order_date >= '2023-05-23' ORDER BY order_date DESC LIMIT 100;

-- Variation 25
-- Parameters: {'customer_id': 97, 'order_date': '2023-12-04', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 97 AND order_date >= '2023-12-04' ORDER BY order_date DESC LIMIT 10;

-- Variation 26
-- Parameters: {'customer_id': 442, 'order_date': '2023-08-01', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 442 AND order_date >= '2023-08-01' ORDER BY order_date DESC LIMIT 20;

-- Variation 27
-- Parameters: {'customer_id': 79, 'order_date': '2023-11-11', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 79 AND order_date >= '2023-11-11' ORDER BY order_date DESC LIMIT 50;

-- Variation 28
-- Parameters: {'customer_id': 27, 'order_date': '2023-05-02', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 27 AND order_date >= '2023-05-02' ORDER BY order_date DESC LIMIT 10;

-- Variation 29
-- Parameters: {'customer_id': 325, 'order_date': '2023-12-12', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 325 AND order_date >= '2023-12-12' ORDER BY order_date DESC LIMIT 10;

-- Variation 30
-- Parameters: {'customer_id': 277, 'order_date': '2023-08-20', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 277 AND order_date >= '2023-08-20' ORDER BY order_date DESC LIMIT 20;

-- Variation 31
-- Parameters: {'customer_id': 300, 'order_date': '2023-10-16', 'limit': 50}
SELECT * FROM orders WHERE customer_id = 300 AND order_date >= '2023-10-16' ORDER BY order_date DESC LIMIT 50;

-- Variation 32
-- Parameters: {'customer_id': 386, 'order_date': '2023-06-24', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 386 AND order_date >= '2023-06-24' ORDER BY order_date DESC LIMIT 10;

-- Variation 33
-- Parameters: {'customer_id': 391, 'order_date': '2023-10-03', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 391 AND order_date >= '2023-10-03' ORDER BY order_date DESC LIMIT 10;

-- Variation 34
-- Parameters: {'customer_id': 480, 'order_date': '2023-05-24', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 480 AND order_date >= '2023-05-24' ORDER BY order_date DESC LIMIT 10;

-- Variation 35
-- Parameters: {'customer_id': 101, 'order_date': '2023-09-14', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 101 AND order_date >= '2023-09-14' ORDER BY order_date DESC LIMIT 10;

-- Variation 36
-- Parameters: {'customer_id': 99, 'order_date': '2023-11-11', 'limit': 20}
SELECT * FROM orders WHERE customer_id = 99 AND order_date >= '2023-11-11' ORDER BY order_date DESC LIMIT 20;

-- Variation 37
-- Parameters: {'customer_id': 349, 'order_date': '2023-01-23', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 349 AND order_date >= '2023-01-23' ORDER BY order_date DESC LIMIT 10;

-- Variation 38
-- Parameters: {'customer_id': 491, 'order_date': '2023-06-09', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 491 AND order_date >= '2023-06-09' ORDER BY order_date DESC LIMIT 100;

-- Variation 39
-- Parameters: {'customer_id': 491, 'order_date': '2023-02-07', 'limit': 100}
SELECT * FROM orders WHERE customer_id = 491 AND order_date >= '2023-02-07' ORDER BY order_date DESC LIMIT 100;

-- Variation 40
-- Parameters: {'customer_id': 32, 'order_date': '2023-11-17', 'limit': 10}
SELECT * FROM orders WHERE customer_id = 32 AND order_date >= '2023-11-17' ORDER BY order_date DESC LIMIT 10;

