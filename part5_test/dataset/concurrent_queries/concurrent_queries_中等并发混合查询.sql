-- Concurrent Queries - Scenario: 中等并发混合查询
-- Total queries: 300

-- Query 1 (User 1)
-- Think Time: 0.84s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 2 ORDER BY stock_quantity;

-- Query 2 (User 2)
-- Think Time: 1.20s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-15'
  AND customer_id BETWEEN 2 AND 469
ORDER BY customer_id, order_date DESC;

-- Query 3 (User 3)
-- Think Time: 1.43s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-17' AND '2023-11-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 4 (User 4)
-- Think Time: 1.61s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 293 AND 494 GROUP BY c.customer_id, c.customer_name;

-- Query 5 (User 5)
-- Think Time: 0.94s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-11'
  AND customer_id BETWEEN 365 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 6 (User 6)
-- Think Time: 1.71s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 7 (User 7)
-- Think Time: 1.67s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 2 ORDER BY stock_quantity;

-- Query 8 (User 8)
-- Think Time: 1.74s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 274 GROUP BY status;

-- Query 9 (User 9)
-- Think Time: 1.74s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 10 (User 10)
-- Think Time: 1.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 188 AND 453 GROUP BY c.customer_id, c.customer_name;

-- Query 11 (User 11)
-- Think Time: 1.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 364 AND 463 GROUP BY c.customer_id, c.customer_name;

-- Query 12 (User 12)
-- Think Time: 0.74s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 13 (User 13)
-- Think Time: 0.54s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 381 GROUP BY status;

-- Query 14 (User 14)
-- Think Time: 1.96s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 15 (User 15)
-- Think Time: 1.85s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-14' AND '2023-10-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 16 (User 16)
-- Think Time: 1.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 17 (User 17)
-- Think Time: 1.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 18 (User 18)
-- Think Time: 0.77s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 229 AND 473 GROUP BY c.customer_id, c.customer_name;

-- Query 19 (User 19)
-- Think Time: 0.84s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 426 GROUP BY status;

-- Query 20 (User 20)
-- Think Time: 1.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 185;

-- Query 21 (User 1)
-- Think Time: 1.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 302 AND 428 GROUP BY c.customer_id, c.customer_name;

-- Query 22 (User 2)
-- Think Time: 1.93s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 390;

-- Query 23 (User 3)
-- Think Time: 0.51s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 288 GROUP BY status;

-- Query 24 (User 4)
-- Think Time: 1.73s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 651;

-- Query 25 (User 5)
-- Think Time: 1.89s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 26 (User 6)
-- Think Time: 0.99s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 27 (User 7)
-- Think Time: 1.59s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 441;

-- Query 28 (User 8)
-- Think Time: 1.65s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 4 ORDER BY stock_quantity;

-- Query 29 (User 9)
-- Think Time: 1.34s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 30 (User 10)
-- Think Time: 1.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 31 (User 11)
-- Think Time: 0.91s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 32 (User 12)
-- Think Time: 1.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 4 ORDER BY stock_quantity;

-- Query 33 (User 13)
-- Think Time: 1.65s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 126 AND 442 GROUP BY c.customer_id, c.customer_name;

-- Query 34 (User 14)
-- Think Time: 1.96s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 3 ORDER BY stock_quantity;

-- Query 35 (User 15)
-- Think Time: 1.87s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 329 GROUP BY status;

-- Query 36 (User 16)
-- Think Time: 1.60s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 1 ORDER BY stock_quantity;

-- Query 37 (User 17)
-- Think Time: 0.61s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 400 AND 415 GROUP BY c.customer_id, c.customer_name;

-- Query 38 (User 18)
-- Think Time: 1.73s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-09'
  AND customer_id BETWEEN 233 AND 468
ORDER BY customer_id, order_date DESC;

-- Query 39 (User 19)
-- Think Time: 0.89s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-17'
  AND customer_id BETWEEN 116 AND 442
ORDER BY customer_id, order_date DESC;

-- Query 40 (User 20)
-- Think Time: 1.66s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 41 (User 1)
-- Think Time: 1.81s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 42 (User 2)
-- Think Time: 1.75s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 43 (User 3)
-- Think Time: 1.72s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-09'
  AND customer_id BETWEEN 102 AND 427
ORDER BY customer_id, order_date DESC;

-- Query 44 (User 4)
-- Think Time: 1.99s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 260 AND 475 GROUP BY c.customer_id, c.customer_name;

-- Query 45 (User 5)
-- Think Time: 1.10s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-10'
  AND customer_id BETWEEN 9 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 46 (User 6)
-- Think Time: 0.52s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 185 AND 440 GROUP BY c.customer_id, c.customer_name;

-- Query 47 (User 7)
-- Think Time: 0.56s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 5 GROUP BY status;

-- Query 48 (User 8)
-- Think Time: 1.05s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 49 (User 9)
-- Think Time: 1.00s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 16 AND 464 GROUP BY c.customer_id, c.customer_name;

-- Query 50 (User 10)
-- Think Time: 1.02s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 115;

-- Query 51 (User 11)
-- Think Time: 1.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 52 (User 12)
-- Think Time: 0.83s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 343 GROUP BY status;

-- Query 53 (User 13)
-- Think Time: 1.60s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-22' AND '2023-08-13' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 54 (User 14)
-- Think Time: 1.06s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 265 GROUP BY status;

-- Query 55 (User 15)
-- Think Time: 0.74s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-11' AND '2023-10-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 56 (User 16)
-- Think Time: 1.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 1 ORDER BY stock_quantity;

-- Query 57 (User 17)
-- Think Time: 1.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 336 AND 499 GROUP BY c.customer_id, c.customer_name;

-- Query 58 (User 18)
-- Think Time: 0.68s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 5 ORDER BY stock_quantity;

-- Query 59 (User 19)
-- Think Time: 0.71s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 482 GROUP BY status;

-- Query 60 (User 20)
-- Think Time: 1.31s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 61 (User 1)
-- Think Time: 0.92s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-24' AND '2023-08-31' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 62 (User 2)
-- Think Time: 1.33s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-18'
  AND customer_id BETWEEN 1 AND 410
ORDER BY customer_id, order_date DESC;

-- Query 63 (User 3)
-- Think Time: 1.68s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 387 GROUP BY status;

-- Query 64 (User 4)
-- Think Time: 1.92s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-05'
  AND customer_id BETWEEN 64 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 65 (User 5)
-- Think Time: 1.44s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-22' AND '2023-09-28' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 66 (User 6)
-- Think Time: 1.81s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 449;

-- Query 67 (User 7)
-- Think Time: 0.65s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 68 (User 8)
-- Think Time: 1.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 2 ORDER BY stock_quantity;

-- Query 69 (User 9)
-- Think Time: 0.90s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 4 ORDER BY stock_quantity;

-- Query 70 (User 10)
-- Think Time: 0.64s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 689;

-- Query 71 (User 11)
-- Think Time: 1.36s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 72 (User 12)
-- Think Time: 0.94s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 73 (User 13)
-- Think Time: 1.55s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-06'
  AND customer_id BETWEEN 229 AND 407
ORDER BY customer_id, order_date DESC;

-- Query 74 (User 14)
-- Think Time: 1.00s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 165 GROUP BY status;

-- Query 75 (User 15)
-- Think Time: 0.90s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 76 (User 16)
-- Think Time: 1.46s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 817;

-- Query 77 (User 17)
-- Think Time: 1.78s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 39 GROUP BY status;

-- Query 78 (User 18)
-- Think Time: 0.87s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-12' AND '2023-08-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 79 (User 19)
-- Think Time: 1.95s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-27' AND '2023-09-14' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 80 (User 20)
-- Think Time: 1.83s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 689;

-- Query 81 (User 1)
-- Think Time: 0.98s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-09'
  AND customer_id BETWEEN 183 AND 410
ORDER BY customer_id, order_date DESC;

-- Query 82 (User 2)
-- Think Time: 1.58s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 83 (User 3)
-- Think Time: 1.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 84 (User 4)
-- Think Time: 1.57s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 85 (User 5)
-- Think Time: 0.85s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 438;

-- Query 86 (User 6)
-- Think Time: 0.68s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-24'
  AND customer_id BETWEEN 365 AND 497
ORDER BY customer_id, order_date DESC;

-- Query 87 (User 7)
-- Think Time: 1.59s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 33 AND 468 GROUP BY c.customer_id, c.customer_name;

-- Query 88 (User 8)
-- Think Time: 0.77s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 1 ORDER BY stock_quantity;

-- Query 89 (User 9)
-- Think Time: 0.89s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-17'
  AND customer_id BETWEEN 174 AND 458
ORDER BY customer_id, order_date DESC;

-- Query 90 (User 10)
-- Think Time: 1.70s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 91 (User 11)
-- Think Time: 1.06s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 1 ORDER BY stock_quantity;

-- Query 92 (User 12)
-- Think Time: 0.66s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-15' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 93 (User 13)
-- Think Time: 1.68s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-26' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 94 (User 14)
-- Think Time: 1.72s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 34 AND 444 GROUP BY c.customer_id, c.customer_name;

-- Query 95 (User 15)
-- Think Time: 0.80s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 47 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 96 (User 16)
-- Think Time: 0.66s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 2 ORDER BY stock_quantity;

-- Query 97 (User 17)
-- Think Time: 1.62s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 701;

-- Query 98 (User 18)
-- Think Time: 1.81s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-17' AND '2023-07-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 99 (User 19)
-- Think Time: 1.57s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-28' AND '2023-07-31' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 100 (User 20)
-- Think Time: 1.72s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 775;

-- Query 101 (User 1)
-- Think Time: 1.52s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 2 ORDER BY stock_quantity;

-- Query 102 (User 2)
-- Think Time: 1.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 6 GROUP BY status;

-- Query 103 (User 3)
-- Think Time: 0.78s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 104 (User 4)
-- Think Time: 1.73s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 2 ORDER BY stock_quantity;

-- Query 105 (User 5)
-- Think Time: 0.78s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 106 (User 6)
-- Think Time: 0.82s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 224 AND 479 GROUP BY c.customer_id, c.customer_name;

-- Query 107 (User 7)
-- Think Time: 1.07s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 1 ORDER BY stock_quantity;

-- Query 108 (User 8)
-- Think Time: 0.93s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 172 GROUP BY status;

-- Query 109 (User 9)
-- Think Time: 1.59s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-15' AND '2023-08-17' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 110 (User 10)
-- Think Time: 1.79s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 3 ORDER BY stock_quantity;

-- Query 111 (User 11)
-- Think Time: 1.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 112 (User 12)
-- Think Time: 1.94s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 275 GROUP BY status;

-- Query 113 (User 13)
-- Think Time: 1.78s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-09'
  AND customer_id BETWEEN 236 AND 453
ORDER BY customer_id, order_date DESC;

-- Query 114 (User 14)
-- Think Time: 1.01s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-23'
  AND customer_id BETWEEN 228 AND 450
ORDER BY customer_id, order_date DESC;

-- Query 115 (User 15)
-- Think Time: 1.85s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-22'
  AND customer_id BETWEEN 374 AND 485
ORDER BY customer_id, order_date DESC;

-- Query 116 (User 16)
-- Think Time: 0.58s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-24'
  AND customer_id BETWEEN 154 AND 500
ORDER BY customer_id, order_date DESC;

-- Query 117 (User 17)
-- Think Time: 1.35s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 118 (User 18)
-- Think Time: 0.87s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-25' AND '2023-08-28' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 119 (User 19)
-- Think Time: 0.53s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-15' AND '2023-12-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 120 (User 20)
-- Think Time: 1.86s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 121 (User 1)
-- Think Time: 1.87s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 645;

-- Query 122 (User 2)
-- Think Time: 1.82s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-10'
  AND customer_id BETWEEN 228 AND 413
ORDER BY customer_id, order_date DESC;

-- Query 123 (User 3)
-- Think Time: 1.84s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 558;

-- Query 124 (User 4)
-- Think Time: 1.99s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 213;

-- Query 125 (User 5)
-- Think Time: 1.27s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 126 (User 6)
-- Think Time: 1.99s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 127 (User 7)
-- Think Time: 1.08s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 489;

-- Query 128 (User 8)
-- Think Time: 1.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 363 GROUP BY status;

-- Query 129 (User 9)
-- Think Time: 0.77s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 459 GROUP BY status;

-- Query 130 (User 10)
-- Think Time: 1.44s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 293 AND 431 GROUP BY c.customer_id, c.customer_name;

-- Query 131 (User 11)
-- Think Time: 0.51s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 193;

-- Query 132 (User 12)
-- Think Time: 1.56s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 133 (User 13)
-- Think Time: 1.82s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 247;

-- Query 134 (User 14)
-- Think Time: 0.95s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 135 (User 15)
-- Think Time: 0.88s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-25'
  AND customer_id BETWEEN 272 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 136 (User 16)
-- Think Time: 0.52s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-07' AND '2023-10-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 137 (User 17)
-- Think Time: 1.61s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 302 AND 499 GROUP BY c.customer_id, c.customer_name;

-- Query 138 (User 18)
-- Think Time: 1.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 519;

-- Query 139 (User 19)
-- Think Time: 0.72s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 747;

-- Query 140 (User 20)
-- Think Time: 0.91s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 1 ORDER BY stock_quantity;

-- Query 141 (User 1)
-- Think Time: 1.15s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 142 (User 2)
-- Think Time: 1.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-01' AND '2023-08-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 143 (User 3)
-- Think Time: 0.68s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 726;

-- Query 144 (User 4)
-- Think Time: 1.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-05' AND '2023-10-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 145 (User 5)
-- Think Time: 1.85s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 146 (User 6)
-- Think Time: 1.08s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 5 ORDER BY stock_quantity;

-- Query 147 (User 7)
-- Think Time: 0.91s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-16' AND '2023-11-22' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 148 (User 8)
-- Think Time: 1.68s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-02' AND '2023-09-21' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 149 (User 9)
-- Think Time: 1.83s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 4 ORDER BY stock_quantity;

-- Query 150 (User 10)
-- Think Time: 1.64s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 134 GROUP BY status;

-- Query 151 (User 11)
-- Think Time: 1.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 239 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 152 (User 12)
-- Think Time: 0.71s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 153 (User 13)
-- Think Time: 1.63s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-22'
  AND customer_id BETWEEN 330 AND 437
ORDER BY customer_id, order_date DESC;

-- Query 154 (User 14)
-- Think Time: 0.85s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 155 (User 15)
-- Think Time: 1.54s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 3 ORDER BY stock_quantity;

-- Query 156 (User 16)
-- Think Time: 1.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 230 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 157 (User 17)
-- Think Time: 0.54s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 158 (User 18)
-- Think Time: 1.37s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-21'
  AND customer_id BETWEEN 4 AND 445
ORDER BY customer_id, order_date DESC;

-- Query 159 (User 19)
-- Think Time: 1.08s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 5 ORDER BY stock_quantity;

-- Query 160 (User 20)
-- Think Time: 1.95s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 161 (User 1)
-- Think Time: 1.73s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-11'
  AND customer_id BETWEEN 354 AND 487
ORDER BY customer_id, order_date DESC;

-- Query 162 (User 2)
-- Think Time: 1.74s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 4 ORDER BY stock_quantity;

-- Query 163 (User 3)
-- Think Time: 0.93s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 2 ORDER BY stock_quantity;

-- Query 164 (User 4)
-- Think Time: 1.59s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 165 (User 5)
-- Think Time: 1.66s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-25' AND '2023-09-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 166 (User 6)
-- Think Time: 0.63s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 73 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 167 (User 7)
-- Think Time: 0.60s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 168 (User 8)
-- Think Time: 0.92s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-21'
  AND customer_id BETWEEN 337 AND 409
ORDER BY customer_id, order_date DESC;

-- Query 169 (User 9)
-- Think Time: 1.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 545;

-- Query 170 (User 10)
-- Think Time: 1.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 482;

-- Query 171 (User 11)
-- Think Time: 0.94s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 5 ORDER BY stock_quantity;

-- Query 172 (User 12)
-- Think Time: 1.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 871;

-- Query 173 (User 13)
-- Think Time: 1.09s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-10' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 174 (User 14)
-- Think Time: 1.68s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-11'
  AND customer_id BETWEEN 379 AND 430
ORDER BY customer_id, order_date DESC;

-- Query 175 (User 15)
-- Think Time: 1.98s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 869;

-- Query 176 (User 16)
-- Think Time: 1.93s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 177 (User 17)
-- Think Time: 0.78s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 178 (User 18)
-- Think Time: 0.96s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 130 AND 458 GROUP BY c.customer_id, c.customer_name;

-- Query 179 (User 19)
-- Think Time: 1.63s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 492;

-- Query 180 (User 20)
-- Think Time: 0.88s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 353 AND 476 GROUP BY c.customer_id, c.customer_name;

-- Query 181 (User 1)
-- Think Time: 0.98s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 126 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 182 (User 2)
-- Think Time: 0.77s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 614;

-- Query 183 (User 3)
-- Think Time: 1.78s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 300 GROUP BY status;

-- Query 184 (User 4)
-- Think Time: 1.66s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 185 (User 5)
-- Think Time: 1.92s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-16' AND '2023-09-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 186 (User 6)
-- Think Time: 1.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 85 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 187 (User 7)
-- Think Time: 1.82s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 5 ORDER BY stock_quantity;

-- Query 188 (User 8)
-- Think Time: 1.99s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 4 ORDER BY stock_quantity;

-- Query 189 (User 9)
-- Think Time: 0.70s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 5 ORDER BY stock_quantity;

-- Query 190 (User 10)
-- Think Time: 1.88s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-11'
  AND customer_id BETWEEN 5 AND 439
ORDER BY customer_id, order_date DESC;

-- Query 191 (User 11)
-- Think Time: 1.79s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 654;

-- Query 192 (User 12)
-- Think Time: 1.04s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 342 AND 417 GROUP BY c.customer_id, c.customer_name;

-- Query 193 (User 13)
-- Think Time: 1.90s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 194 (User 14)
-- Think Time: 0.86s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-11'
  AND customer_id BETWEEN 331 AND 497
ORDER BY customer_id, order_date DESC;

-- Query 195 (User 15)
-- Think Time: 1.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 214 GROUP BY status;

-- Query 196 (User 16)
-- Think Time: 1.08s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 3 ORDER BY stock_quantity;

-- Query 197 (User 17)
-- Think Time: 1.81s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-27' AND '2023-11-22' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 198 (User 18)
-- Think Time: 0.90s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 199 (User 19)
-- Think Time: 1.37s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-05'
  AND customer_id BETWEEN 284 AND 442
ORDER BY customer_id, order_date DESC;

-- Query 200 (User 20)
-- Think Time: 0.87s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-16' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 201 (User 1)
-- Think Time: 0.50s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 502;

-- Query 202 (User 2)
-- Think Time: 1.97s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 203 (User 3)
-- Think Time: 1.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 224 AND 450 GROUP BY c.customer_id, c.customer_name;

-- Query 204 (User 4)
-- Think Time: 0.92s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 21 GROUP BY status;

-- Query 205 (User 5)
-- Think Time: 1.38s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-08'
  AND customer_id BETWEEN 122 AND 420
ORDER BY customer_id, order_date DESC;

-- Query 206 (User 6)
-- Think Time: 1.77s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 207 (User 7)
-- Think Time: 1.79s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 208 (User 8)
-- Think Time: 1.07s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-26'
  AND customer_id BETWEEN 379 AND 450
ORDER BY customer_id, order_date DESC;

-- Query 209 (User 9)
-- Think Time: 0.81s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 165 GROUP BY status;

-- Query 210 (User 10)
-- Think Time: 0.87s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-24' AND '2023-10-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 211 (User 11)
-- Think Time: 1.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 479 GROUP BY status;

-- Query 212 (User 12)
-- Think Time: 1.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 213 (User 13)
-- Think Time: 0.84s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-13' AND '2023-12-20' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 214 (User 14)
-- Think Time: 1.79s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-22' AND '2023-08-01' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 215 (User 15)
-- Think Time: 1.67s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 35 GROUP BY status;

-- Query 216 (User 16)
-- Think Time: 1.73s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-19' AND '2023-08-31' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 217 (User 17)
-- Think Time: 1.78s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-29' AND '2023-12-08' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 218 (User 18)
-- Think Time: 1.75s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 70 GROUP BY status;

-- Query 219 (User 19)
-- Think Time: 0.93s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 128 GROUP BY status;

-- Query 220 (User 20)
-- Think Time: 0.75s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 517;

-- Query 221 (User 1)
-- Think Time: 0.54s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 482;

-- Query 222 (User 2)
-- Think Time: 0.71s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 350;

-- Query 223 (User 3)
-- Think Time: 0.87s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 224 (User 4)
-- Think Time: 1.73s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-14' AND '2023-10-17' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 225 (User 5)
-- Think Time: 1.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 828;

-- Query 226 (User 6)
-- Think Time: 0.99s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 227 (User 7)
-- Think Time: 0.60s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 1 ORDER BY stock_quantity;

-- Query 228 (User 8)
-- Think Time: 1.43s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-02' AND '2023-11-09' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 229 (User 9)
-- Think Time: 1.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 489 GROUP BY status;

-- Query 230 (User 10)
-- Think Time: 1.24s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 373 GROUP BY status;

-- Query 231 (User 11)
-- Think Time: 0.99s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 176 AND 479 GROUP BY c.customer_id, c.customer_name;

-- Query 232 (User 12)
-- Think Time: 1.25s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-13' AND '2023-12-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 233 (User 13)
-- Think Time: 1.55s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-07'
  AND customer_id BETWEEN 128 AND 460
ORDER BY customer_id, order_date DESC;

-- Query 234 (User 14)
-- Think Time: 1.66s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 4 ORDER BY stock_quantity;

-- Query 235 (User 15)
-- Think Time: 1.82s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 236 (User 16)
-- Think Time: 1.39s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 434;

-- Query 237 (User 17)
-- Think Time: 0.50s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 43 AND 411 GROUP BY c.customer_id, c.customer_name;

-- Query 238 (User 18)
-- Think Time: 1.99s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-04' AND '2023-10-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 239 (User 19)
-- Think Time: 0.61s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 315 AND 401 GROUP BY c.customer_id, c.customer_name;

-- Query 240 (User 20)
-- Think Time: 0.55s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 330 GROUP BY status;

-- Query 241 (User 1)
-- Think Time: 0.99s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 2 ORDER BY stock_quantity;

-- Query 242 (User 2)
-- Think Time: 0.72s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 243 (User 3)
-- Think Time: 1.33s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 395 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 244 (User 4)
-- Think Time: 0.78s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 201 GROUP BY status;

-- Query 245 (User 5)
-- Think Time: 0.78s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 816;

-- Query 246 (User 6)
-- Think Time: 1.58s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-05' AND '2023-10-13' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 247 (User 7)
-- Think Time: 1.74s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-11'
  AND customer_id BETWEEN 2 AND 414
ORDER BY customer_id, order_date DESC;

-- Query 248 (User 8)
-- Think Time: 1.15s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 249 (User 9)
-- Think Time: 1.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 250 (User 10)
-- Think Time: 1.78s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 214 AND 460 GROUP BY c.customer_id, c.customer_name;

-- Query 251 (User 11)
-- Think Time: 0.57s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 252 (User 12)
-- Think Time: 1.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 253 (User 13)
-- Think Time: 0.52s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 254 (User 14)
-- Think Time: 0.89s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-04'
  AND customer_id BETWEEN 87 AND 485
ORDER BY customer_id, order_date DESC;

-- Query 255 (User 15)
-- Think Time: 0.61s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-11' AND '2023-10-20' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 256 (User 16)
-- Think Time: 1.27s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-17' AND '2023-09-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 257 (User 17)
-- Think Time: 1.87s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 118;

-- Query 258 (User 18)
-- Think Time: 1.01s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 84 AND 419 GROUP BY c.customer_id, c.customer_name;

-- Query 259 (User 19)
-- Think Time: 0.60s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-18'
  AND customer_id BETWEEN 397 AND 476
ORDER BY customer_id, order_date DESC;

-- Query 260 (User 20)
-- Think Time: 1.36s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 261 (User 1)
-- Think Time: 1.65s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 262 (User 2)
-- Think Time: 0.94s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-22' AND '2023-10-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 263 (User 3)
-- Think Time: 1.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 154 AND 486 GROUP BY c.customer_id, c.customer_name;

-- Query 264 (User 4)
-- Think Time: 1.04s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 365 GROUP BY status;

-- Query 265 (User 5)
-- Think Time: 1.76s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 394 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 266 (User 6)
-- Think Time: 0.64s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 296 AND 489 GROUP BY c.customer_id, c.customer_name;

-- Query 267 (User 7)
-- Think Time: 1.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 3 ORDER BY stock_quantity;

-- Query 268 (User 8)
-- Think Time: 1.59s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 82 AND 476 GROUP BY c.customer_id, c.customer_name;

-- Query 269 (User 9)
-- Think Time: 1.32s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-11' AND '2023-09-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 270 (User 10)
-- Think Time: 1.87s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 271 (User 11)
-- Think Time: 1.62s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 332 GROUP BY status;

-- Query 272 (User 12)
-- Think Time: 1.60s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-29' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 273 (User 13)
-- Think Time: 1.01s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-29'
  AND customer_id BETWEEN 357 AND 402
ORDER BY customer_id, order_date DESC;

-- Query 274 (User 14)
-- Think Time: 0.80s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 779;

-- Query 275 (User 15)
-- Think Time: 0.74s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-18' AND '2023-09-20' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 276 (User 16)
-- Think Time: 0.52s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 277 (User 17)
-- Think Time: 1.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 233 AND 445 GROUP BY c.customer_id, c.customer_name;

-- Query 278 (User 18)
-- Think Time: 1.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 479;

-- Query 279 (User 19)
-- Think Time: 1.64s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 338 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 280 (User 20)
-- Think Time: 0.66s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-08' AND '2023-07-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 281 (User 1)
-- Think Time: 0.79s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 322 GROUP BY status;

-- Query 282 (User 2)
-- Think Time: 0.61s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 283 (User 3)
-- Think Time: 1.61s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-22' AND '2023-11-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 284 (User 4)
-- Think Time: 1.42s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 285 (User 5)
-- Think Time: 1.54s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 307 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 286 (User 6)
-- Think Time: 1.90s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 287 (User 7)
-- Think Time: 1.61s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 339;

-- Query 288 (User 8)
-- Think Time: 0.81s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-03' AND '2023-10-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 289 (User 9)
-- Think Time: 1.76s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 194 GROUP BY status;

-- Query 290 (User 10)
-- Think Time: 1.57s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-10'
  AND customer_id BETWEEN 118 AND 490
ORDER BY customer_id, order_date DESC;

-- Query 291 (User 11)
-- Think Time: 0.89s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 292 (User 12)
-- Think Time: 1.61s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 293 (User 13)
-- Think Time: 0.86s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 246 AND 451 GROUP BY c.customer_id, c.customer_name;

-- Query 294 (User 14)
-- Think Time: 1.00s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 295 (User 15)
-- Think Time: 0.61s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-09-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 296 (User 16)
-- Think Time: 0.54s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 236 AND 422 GROUP BY c.customer_id, c.customer_name;

-- Query 297 (User 17)
-- Think Time: 1.47s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 298 (User 18)
-- Think Time: 0.74s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 299 (User 19)
-- Think Time: 1.43s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-19' AND '2023-11-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 300 (User 20)
-- Think Time: 1.07s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

