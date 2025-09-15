-- Concurrent Queries - Scenario: 混合负载测试
-- Total queries: 360

-- Query 1 (User 1)
-- Think Time: 0.97s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 91 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 2 (User 2)
-- Think Time: 1.25s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-27'
  AND p.price > 450
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9134
ORDER BY total_revenue DESC;

-- Query 3 (User 3)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 4 (User 4)
-- Think Time: 0.29s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-03-27'
  AND p.price > 361
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5340
ORDER BY total_revenue DESC;

-- Query 5 (User 5)
-- Think Time: 1.09s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-25' AND '2023-12-12' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 6 (User 6)
-- Think Time: 1.44s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 7 (User 7)
-- Think Time: 0.99s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 8 (User 8)
-- Think Time: 0.77s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 269
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 20;

-- Query 9 (User 9)
-- Think Time: 0.69s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 2 ORDER BY stock_quantity;

-- Query 10 (User 10)
-- Think Time: 1.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 33 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 11 (User 11)
-- Think Time: 0.88s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 262
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 50;

-- Query 12 (User 12)
-- Think Time: 1.15s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-03-02'
  AND p.price > 462
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1489
ORDER BY total_revenue DESC;

-- Query 13 (User 13)
-- Think Time: 1.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 4 ORDER BY stock_quantity;

-- Query 14 (User 14)
-- Think Time: 1.09s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-20'
  AND p.price > 160
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4042
ORDER BY total_revenue DESC;

-- Query 15 (User 15)
-- Think Time: 1.08s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 800;

-- Query 16 (User 16)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 2 ORDER BY stock_quantity;

-- Query 17 (User 17)
-- Think Time: 0.84s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 18 (User 18)
-- Think Time: 0.60s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 388 GROUP BY status;

-- Query 19 (User 19)
-- Think Time: 1.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 634;

-- Query 20 (User 20)
-- Think Time: 0.62s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 5 ORDER BY stock_quantity;

-- Query 21 (User 21)
-- Think Time: 0.51s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 2 ORDER BY stock_quantity;

-- Query 22 (User 22)
-- Think Time: 1.21s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-05'
  AND p.price > 366
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 2787
ORDER BY total_revenue DESC;

-- Query 23 (User 23)
-- Think Time: 0.82s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-16' AND '2023-08-20' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 24 (User 24)
-- Think Time: 0.76s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 439 GROUP BY status;

-- Query 25 (User 25)
-- Think Time: 0.64s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 26 (User 26)
-- Think Time: 0.85s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 3 ORDER BY stock_quantity;

-- Query 27 (User 27)
-- Think Time: 0.68s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 14 GROUP BY status;

-- Query 28 (User 28)
-- Think Time: 0.62s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 29 (User 29)
-- Think Time: 0.88s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-12'
  AND customer_id BETWEEN 146 AND 439
ORDER BY customer_id, order_date DESC;

-- Query 30 (User 30)
-- Think Time: 1.04s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-03'
  AND p.price > 226
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8356
ORDER BY total_revenue DESC;

-- Query 31 (User 1)
-- Think Time: 0.91s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-08-31' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 32 (User 2)
-- Think Time: 1.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 98 AND 409 GROUP BY c.customer_id, c.customer_name;

-- Query 33 (User 3)
-- Think Time: 0.81s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 126 AND 454 GROUP BY c.customer_id, c.customer_name;

-- Query 34 (User 4)
-- Think Time: 0.55s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 174
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 20;

-- Query 35 (User 5)
-- Think Time: 1.15s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-09' AND '2023-10-11' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 36 (User 6)
-- Think Time: 0.78s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-03'
  AND p.price > 99
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 2037
ORDER BY total_revenue DESC;

-- Query 37 (User 7)
-- Think Time: 1.15s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 38 (User 8)
-- Think Time: 1.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 5 ORDER BY stock_quantity;

-- Query 39 (User 9)
-- Think Time: 0.41s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 324;

-- Query 40 (User 10)
-- Think Time: 0.43s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-27'
  AND p.price > 305
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9161
ORDER BY total_revenue DESC;

-- Query 41 (User 11)
-- Think Time: 1.37s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-01'
  AND customer_id BETWEEN 29 AND 443
ORDER BY customer_id, order_date DESC;

-- Query 42 (User 12)
-- Think Time: 1.26s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-29'
  AND customer_id BETWEEN 125 AND 417
ORDER BY customer_id, order_date DESC;

-- Query 43 (User 13)
-- Think Time: 0.99s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 187 AND 451 GROUP BY c.customer_id, c.customer_name;

-- Query 44 (User 14)
-- Think Time: 0.51s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 342 AND 466
ORDER BY customer_id, order_date DESC;

-- Query 45 (User 15)
-- Think Time: 1.31s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 164
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 10;

-- Query 46 (User 16)
-- Think Time: 0.95s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 758;

-- Query 47 (User 17)
-- Think Time: 1.39s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 301;

-- Query 48 (User 18)
-- Think Time: 1.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 254;

-- Query 49 (User 19)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 81 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 50 (User 20)
-- Think Time: 1.06s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 207 AND 414 GROUP BY c.customer_id, c.customer_name;

-- Query 51 (User 21)
-- Think Time: 0.22s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 108
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 10;

-- Query 52 (User 22)
-- Think Time: 1.09s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-19' AND '2023-11-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 53 (User 23)
-- Think Time: 1.11s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 156
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 10;

-- Query 54 (User 24)
-- Think Time: 0.85s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 3 ORDER BY stock_quantity;

-- Query 55 (User 25)
-- Think Time: 0.70s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 56 (User 26)
-- Think Time: 0.41s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-20' AND '2023-08-28' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 57 (User 27)
-- Think Time: 0.74s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 58 (User 28)
-- Think Time: 0.49s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-16' AND '2023-08-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 59 (User 29)
-- Think Time: 0.68s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 186 GROUP BY status;

-- Query 60 (User 30)
-- Think Time: 0.82s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 399 GROUP BY status;

-- Query 61 (User 1)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 129 AND 460 GROUP BY c.customer_id, c.customer_name;

-- Query 62 (User 2)
-- Think Time: 0.22s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-26'
  AND p.price > 260
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 3652
ORDER BY total_revenue DESC;

-- Query 63 (User 3)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 230 AND 414 GROUP BY c.customer_id, c.customer_name;

-- Query 64 (User 4)
-- Think Time: 0.59s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-29'
  AND customer_id BETWEEN 185 AND 468
ORDER BY customer_id, order_date DESC;

-- Query 65 (User 5)
-- Think Time: 0.78s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-20'
  AND p.price > 103
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 6716
ORDER BY total_revenue DESC;

-- Query 66 (User 6)
-- Think Time: 0.72s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-08'
  AND p.price > 180
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4259
ORDER BY total_revenue DESC;

-- Query 67 (User 7)
-- Think Time: 0.22s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-22'
  AND customer_id BETWEEN 124 AND 418
ORDER BY customer_id, order_date DESC;

-- Query 68 (User 8)
-- Think Time: 0.78s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 69 (User 9)
-- Think Time: 1.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-10'
  AND customer_id BETWEEN 279 AND 499
ORDER BY customer_id, order_date DESC;

-- Query 70 (User 10)
-- Think Time: 0.85s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 723;

-- Query 71 (User 11)
-- Think Time: 0.97s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 574;

-- Query 72 (User 12)
-- Think Time: 1.44s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 196 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 73 (User 13)
-- Think Time: 1.07s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-05'
  AND customer_id BETWEEN 108 AND 495
ORDER BY customer_id, order_date DESC;

-- Query 74 (User 14)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 242;

-- Query 75 (User 15)
-- Think Time: 1.02s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-19'
  AND customer_id BETWEEN 339 AND 486
ORDER BY customer_id, order_date DESC;

-- Query 76 (User 16)
-- Think Time: 1.37s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 360 GROUP BY status;

-- Query 77 (User 17)
-- Think Time: 1.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 228 AND 403 GROUP BY c.customer_id, c.customer_name;

-- Query 78 (User 18)
-- Think Time: 1.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 485 GROUP BY status;

-- Query 79 (User 19)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 4 ORDER BY stock_quantity;

-- Query 80 (User 20)
-- Think Time: 1.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-22' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 81 (User 21)
-- Think Time: 1.03s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 78 GROUP BY status;

-- Query 82 (User 22)
-- Think Time: 0.84s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 464 GROUP BY status;

-- Query 83 (User 23)
-- Think Time: 1.24s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 380
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 50;

-- Query 84 (User 24)
-- Think Time: 0.54s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-12'
  AND p.price > 154
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 7165
ORDER BY total_revenue DESC;

-- Query 85 (User 25)
-- Think Time: 0.70s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 204;

-- Query 86 (User 26)
-- Think Time: 0.49s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-12-28' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 87 (User 27)
-- Think Time: 0.89s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 80
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 50;

-- Query 88 (User 28)
-- Think Time: 0.67s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 354;

-- Query 89 (User 29)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 354;

-- Query 90 (User 30)
-- Think Time: 0.39s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 400 GROUP BY status;

-- Query 91 (User 1)
-- Think Time: 0.81s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 50 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 92 (User 2)
-- Think Time: 1.44s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-02'
  AND customer_id BETWEEN 323 AND 406
ORDER BY customer_id, order_date DESC;

-- Query 93 (User 3)
-- Think Time: 1.01s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 94 (User 4)
-- Think Time: 1.00s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-19'
  AND p.price > 422
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5079
ORDER BY total_revenue DESC;

-- Query 95 (User 5)
-- Think Time: 0.26s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 302 AND 434
ORDER BY customer_id, order_date DESC;

-- Query 96 (User 6)
-- Think Time: 0.66s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 70 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 97 (User 7)
-- Think Time: 0.73s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 41 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 98 (User 8)
-- Think Time: 1.05s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-08' AND '2023-10-11' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 99 (User 9)
-- Think Time: 1.32s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 858;

-- Query 100 (User 10)
-- Think Time: 1.32s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 533;

-- Query 101 (User 11)
-- Think Time: 0.24s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-08'
  AND customer_id BETWEEN 114 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 102 (User 12)
-- Think Time: 0.34s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-14' AND '2023-10-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 103 (User 13)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 5 ORDER BY stock_quantity;

-- Query 104 (User 14)
-- Think Time: 0.33s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-18'
  AND customer_id BETWEEN 314 AND 409
ORDER BY customer_id, order_date DESC;

-- Query 105 (User 15)
-- Think Time: 1.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-24' AND '2023-10-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 106 (User 16)
-- Think Time: 0.97s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 296
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 20;

-- Query 107 (User 17)
-- Think Time: 1.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 4 ORDER BY stock_quantity;

-- Query 108 (User 18)
-- Think Time: 1.15s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-06' AND '2023-09-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 109 (User 19)
-- Think Time: 1.07s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 495
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 10;

-- Query 110 (User 20)
-- Think Time: 0.81s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 111 (User 21)
-- Think Time: 1.47s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-05' AND '2023-09-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 112 (User 22)
-- Think Time: 1.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 296;

-- Query 113 (User 23)
-- Think Time: 1.45s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 345
  AND p.category_id = 5
ORDER BY p.price DESC
LIMIT 20;

-- Query 114 (User 24)
-- Think Time: 1.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 115 (User 25)
-- Think Time: 0.77s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 19 GROUP BY status;

-- Query 116 (User 26)
-- Think Time: 1.27s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 140
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 10;

-- Query 117 (User 27)
-- Think Time: 1.18s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 118 (User 28)
-- Think Time: 0.94s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 2 ORDER BY stock_quantity;

-- Query 119 (User 29)
-- Think Time: 1.29s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-18'
  AND p.price > 166
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 6152
ORDER BY total_revenue DESC;

-- Query 120 (User 30)
-- Think Time: 1.45s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 231 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 121 (User 1)
-- Think Time: 1.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 116 GROUP BY status;

-- Query 122 (User 2)
-- Think Time: 1.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-21' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 123 (User 3)
-- Think Time: 0.88s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 127
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 10;

-- Query 124 (User 4)
-- Think Time: 0.91s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-12'
  AND customer_id BETWEEN 367 AND 450
ORDER BY customer_id, order_date DESC;

-- Query 125 (User 5)
-- Think Time: 1.43s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 470 GROUP BY status;

-- Query 126 (User 6)
-- Think Time: 1.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 518;

-- Query 127 (User 7)
-- Think Time: 1.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 385;

-- Query 128 (User 8)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 175;

-- Query 129 (User 9)
-- Think Time: 0.72s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-01'
  AND p.price > 154
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1025
ORDER BY total_revenue DESC;

-- Query 130 (User 10)
-- Think Time: 0.58s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 307;

-- Query 131 (User 11)
-- Think Time: 0.76s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-26' AND '2023-12-11' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 132 (User 12)
-- Think Time: 0.76s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 410
  AND p.category_id = 5
ORDER BY p.price DESC
LIMIT 50;

-- Query 133 (User 13)
-- Think Time: 1.35s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 4 ORDER BY stock_quantity;

-- Query 134 (User 14)
-- Think Time: 1.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 4 ORDER BY stock_quantity;

-- Query 135 (User 15)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 185 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 136 (User 16)
-- Think Time: 0.72s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 278 GROUP BY status;

-- Query 137 (User 17)
-- Think Time: 1.25s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-11' AND '2023-08-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 138 (User 18)
-- Think Time: 0.86s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 349 GROUP BY status;

-- Query 139 (User 19)
-- Think Time: 1.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 140 (User 20)
-- Think Time: 0.99s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 4 ORDER BY stock_quantity;

-- Query 141 (User 21)
-- Think Time: 0.51s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 485 GROUP BY status;

-- Query 142 (User 22)
-- Think Time: 1.43s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-19' AND '2023-10-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 143 (User 23)
-- Think Time: 0.76s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 295 AND 448 GROUP BY c.customer_id, c.customer_name;

-- Query 144 (User 24)
-- Think Time: 1.08s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 145 (User 25)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 146 (User 26)
-- Think Time: 1.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 583;

-- Query 147 (User 27)
-- Think Time: 0.29s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-12'
  AND p.price > 425
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9821
ORDER BY total_revenue DESC;

-- Query 148 (User 28)
-- Think Time: 1.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 313 GROUP BY status;

-- Query 149 (User 29)
-- Think Time: 0.77s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 4 ORDER BY stock_quantity;

-- Query 150 (User 30)
-- Think Time: 1.46s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-21'
  AND p.price > 486
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9879
ORDER BY total_revenue DESC;

-- Query 151 (User 1)
-- Think Time: 1.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 13 AND category_id = 2 ORDER BY stock_quantity;

-- Query 152 (User 2)
-- Think Time: 0.97s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-03-27'
  AND p.price > 91
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4374
ORDER BY total_revenue DESC;

-- Query 153 (User 3)
-- Think Time: 0.33s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 384
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 20;

-- Query 154 (User 4)
-- Think Time: 0.71s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 237 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 155 (User 5)
-- Think Time: 1.50s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-14' AND '2023-12-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 156 (User 6)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 94 AND 457 GROUP BY c.customer_id, c.customer_name;

-- Query 157 (User 7)
-- Think Time: 0.77s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 110 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 158 (User 8)
-- Think Time: 1.08s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 159 (User 9)
-- Think Time: 0.46s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 160 (User 10)
-- Think Time: 0.57s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 878;

-- Query 161 (User 11)
-- Think Time: 1.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 154 AND 481 GROUP BY c.customer_id, c.customer_name;

-- Query 162 (User 12)
-- Think Time: 1.04s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 5 ORDER BY stock_quantity;

-- Query 163 (User 13)
-- Think Time: 1.49s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-16'
  AND p.price > 254
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5305
ORDER BY total_revenue DESC;

-- Query 164 (User 14)
-- Think Time: 1.32s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 444
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 50;

-- Query 165 (User 15)
-- Think Time: 0.29s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 166 (User 16)
-- Think Time: 1.02s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 167 (User 17)
-- Think Time: 1.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 531;

-- Query 168 (User 18)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 169 (User 19)
-- Think Time: 1.23s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-07'
  AND p.price > 500
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8479
ORDER BY total_revenue DESC;

-- Query 170 (User 20)
-- Think Time: 0.50s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 404
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 10;

-- Query 171 (User 21)
-- Think Time: 1.36s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 172 (User 22)
-- Think Time: 1.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 817;

-- Query 173 (User 23)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 372 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 174 (User 24)
-- Think Time: 1.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 5 ORDER BY stock_quantity;

-- Query 175 (User 25)
-- Think Time: 1.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 5 ORDER BY stock_quantity;

-- Query 176 (User 26)
-- Think Time: 1.24s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 2 ORDER BY stock_quantity;

-- Query 177 (User 27)
-- Think Time: 0.92s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 71 GROUP BY status;

-- Query 178 (User 28)
-- Think Time: 1.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 598;

-- Query 179 (User 29)
-- Think Time: 1.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 180 (User 30)
-- Think Time: 0.67s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 181 (User 1)
-- Think Time: 0.53s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-03' AND '2023-09-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 182 (User 2)
-- Think Time: 0.99s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 183 (User 3)
-- Think Time: 0.81s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 184 (User 4)
-- Think Time: 1.01s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-30'
  AND p.price > 144
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5062
ORDER BY total_revenue DESC;

-- Query 185 (User 5)
-- Think Time: 1.35s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-21'
  AND p.price > 17
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9209
ORDER BY total_revenue DESC;

-- Query 186 (User 6)
-- Think Time: 0.67s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-11'
  AND p.price > 486
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 3506
ORDER BY total_revenue DESC;

-- Query 187 (User 7)
-- Think Time: 0.99s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 188 (User 8)
-- Think Time: 0.70s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 189 (User 9)
-- Think Time: 1.10s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-07'
  AND p.price > 350
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 3251
ORDER BY total_revenue DESC;

-- Query 190 (User 10)
-- Think Time: 1.16s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 454 GROUP BY status;

-- Query 191 (User 11)
-- Think Time: 0.64s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-05'
  AND p.price > 302
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 7230
ORDER BY total_revenue DESC;

-- Query 192 (User 12)
-- Think Time: 1.43s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 193 (User 13)
-- Think Time: 1.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 194 (User 14)
-- Think Time: 1.43s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-08'
  AND p.price > 374
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5395
ORDER BY total_revenue DESC;

-- Query 195 (User 15)
-- Think Time: 1.38s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 34 AND category_id = 2 ORDER BY stock_quantity;

-- Query 196 (User 16)
-- Think Time: 1.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-15' AND '2023-10-22' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 197 (User 17)
-- Think Time: 0.79s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-24' AND '2023-10-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 198 (User 18)
-- Think Time: 1.05s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 137 GROUP BY status;

-- Query 199 (User 19)
-- Think Time: 0.94s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 563;

-- Query 200 (User 20)
-- Think Time: 0.30s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 201 (User 21)
-- Think Time: 1.24s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 427
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 10;

-- Query 202 (User 22)
-- Think Time: 0.89s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 58 GROUP BY status;

-- Query 203 (User 23)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 2 ORDER BY stock_quantity;

-- Query 204 (User 24)
-- Think Time: 0.62s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 183 GROUP BY status;

-- Query 205 (User 25)
-- Think Time: 1.30s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 43
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 50;

-- Query 206 (User 26)
-- Think Time: 1.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 207 (User 27)
-- Think Time: 0.71s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 85 AND 405 GROUP BY c.customer_id, c.customer_name;

-- Query 208 (User 28)
-- Think Time: 1.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 209 (User 29)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 210 (User 30)
-- Think Time: 1.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 4 ORDER BY stock_quantity;

-- Query 211 (User 1)
-- Think Time: 1.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-22'
  AND customer_id BETWEEN 62 AND 498
ORDER BY customer_id, order_date DESC;

-- Query 212 (User 2)
-- Think Time: 1.08s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 213 (User 3)
-- Think Time: 0.62s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-11' AND '2023-11-08' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 214 (User 4)
-- Think Time: 0.99s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 488 GROUP BY status;

-- Query 215 (User 5)
-- Think Time: 0.27s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 368 GROUP BY status;

-- Query 216 (User 6)
-- Think Time: 0.89s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-06' AND '2023-08-01' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 217 (User 7)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 4 GROUP BY status;

-- Query 218 (User 8)
-- Think Time: 1.06s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 99
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 10;

-- Query 219 (User 9)
-- Think Time: 0.53s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 220 (User 10)
-- Think Time: 0.63s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 321 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 221 (User 11)
-- Think Time: 1.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 193 GROUP BY status;

-- Query 222 (User 12)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 223 (User 13)
-- Think Time: 0.79s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 158 AND 410 GROUP BY c.customer_id, c.customer_name;

-- Query 224 (User 14)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 225 (User 15)
-- Think Time: 0.75s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-08'
  AND customer_id BETWEEN 319 AND 461
ORDER BY customer_id, order_date DESC;

-- Query 226 (User 16)
-- Think Time: 1.44s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 227 (User 17)
-- Think Time: 1.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 597;

-- Query 228 (User 18)
-- Think Time: 0.60s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 4 GROUP BY status;

-- Query 229 (User 19)
-- Think Time: 1.36s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 482
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 20;

-- Query 230 (User 20)
-- Think Time: 1.16s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-09'
  AND p.price > 171
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4614
ORDER BY total_revenue DESC;

-- Query 231 (User 21)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 41 GROUP BY status;

-- Query 232 (User 22)
-- Think Time: 0.80s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 233 (User 23)
-- Think Time: 0.74s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 234 (User 24)
-- Think Time: 0.71s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-12'
  AND p.price > 167
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5217
ORDER BY total_revenue DESC;

-- Query 235 (User 25)
-- Think Time: 1.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 376;

-- Query 236 (User 26)
-- Think Time: 1.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 75 GROUP BY status;

-- Query 237 (User 27)
-- Think Time: 0.94s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 238 (User 28)
-- Think Time: 1.12s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-30' AND '2023-11-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 239 (User 29)
-- Think Time: 1.30s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-30'
  AND p.price > 15
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1703
ORDER BY total_revenue DESC;

-- Query 240 (User 30)
-- Think Time: 1.15s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-06'
  AND p.price > 82
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 6828
ORDER BY total_revenue DESC;

-- Query 241 (User 1)
-- Think Time: 0.92s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-16'
  AND customer_id BETWEEN 322 AND 487
ORDER BY customer_id, order_date DESC;

-- Query 242 (User 2)
-- Think Time: 0.72s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-25'
  AND p.price > 292
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5888
ORDER BY total_revenue DESC;

-- Query 243 (User 3)
-- Think Time: 1.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 244 (User 4)
-- Think Time: 0.79s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 245 (User 5)
-- Think Time: 1.32s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 682;

-- Query 246 (User 6)
-- Think Time: 1.49s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-17'
  AND p.price > 234
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5686
ORDER BY total_revenue DESC;

-- Query 247 (User 7)
-- Think Time: 1.43s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 407 GROUP BY status;

-- Query 248 (User 8)
-- Think Time: 1.23s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-25'
  AND p.price > 111
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4293
ORDER BY total_revenue DESC;

-- Query 249 (User 9)
-- Think Time: 0.53s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 250 (User 10)
-- Think Time: 0.38s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-27'
  AND customer_id BETWEEN 187 AND 402
ORDER BY customer_id, order_date DESC;

-- Query 251 (User 11)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-12'
  AND customer_id BETWEEN 329 AND 448
ORDER BY customer_id, order_date DESC;

-- Query 252 (User 12)
-- Think Time: 0.37s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-23' AND '2023-09-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 253 (User 13)
-- Think Time: 1.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 233 GROUP BY status;

-- Query 254 (User 14)
-- Think Time: 0.62s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 255 (User 15)
-- Think Time: 1.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 26 GROUP BY status;

-- Query 256 (User 16)
-- Think Time: 1.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-17'
  AND customer_id BETWEEN 198 AND 451
ORDER BY customer_id, order_date DESC;

-- Query 257 (User 17)
-- Think Time: 0.31s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 403
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 10;

-- Query 258 (User 18)
-- Think Time: 1.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 259 (User 19)
-- Think Time: 1.00s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 26 AND 463 GROUP BY c.customer_id, c.customer_name;

-- Query 260 (User 20)
-- Think Time: 0.52s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 2 ORDER BY stock_quantity;

-- Query 261 (User 21)
-- Think Time: 1.09s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 67
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 20;

-- Query 262 (User 22)
-- Think Time: 0.59s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 377 GROUP BY status;

-- Query 263 (User 23)
-- Think Time: 1.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 264 (User 24)
-- Think Time: 1.37s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 818;

-- Query 265 (User 25)
-- Think Time: 0.82s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-23'
  AND p.price > 222
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4820
ORDER BY total_revenue DESC;

-- Query 266 (User 26)
-- Think Time: 0.24s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-09' AND '2023-07-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 267 (User 27)
-- Think Time: 0.61s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 5 ORDER BY stock_quantity;

-- Query 268 (User 28)
-- Think Time: 1.06s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 403;

-- Query 269 (User 29)
-- Think Time: 0.33s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-20' AND '2023-10-13' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 270 (User 30)
-- Think Time: 0.31s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 271 (User 1)
-- Think Time: 0.74s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-06' AND '2023-10-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 272 (User 2)
-- Think Time: 1.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-27'
  AND customer_id BETWEEN 30 AND 450
ORDER BY customer_id, order_date DESC;

-- Query 273 (User 3)
-- Think Time: 1.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 274 (User 4)
-- Think Time: 0.35s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-11'
  AND p.price > 232
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 3118
ORDER BY total_revenue DESC;

-- Query 275 (User 5)
-- Think Time: 0.53s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-20' AND '2023-09-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 276 (User 6)
-- Think Time: 0.73s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 277 (User 7)
-- Think Time: 0.27s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 120;

-- Query 278 (User 8)
-- Think Time: 0.64s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-08'
  AND p.price > 12
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 6698
ORDER BY total_revenue DESC;

-- Query 279 (User 9)
-- Think Time: 0.91s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 424
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 50;

-- Query 280 (User 10)
-- Think Time: 1.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 281 (User 11)
-- Think Time: 1.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-09-16' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 282 (User 12)
-- Think Time: 0.72s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 283 (User 13)
-- Think Time: 1.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 223 AND 471 GROUP BY c.customer_id, c.customer_name;

-- Query 284 (User 14)
-- Think Time: 1.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 845;

-- Query 285 (User 15)
-- Think Time: 1.18s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 262
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 20;

-- Query 286 (User 16)
-- Think Time: 0.78s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 27 AND category_id = 5 ORDER BY stock_quantity;

-- Query 287 (User 17)
-- Think Time: 0.59s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-27'
  AND p.price > 224
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9736
ORDER BY total_revenue DESC;

-- Query 288 (User 18)
-- Think Time: 1.33s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-05'
  AND customer_id BETWEEN 274 AND 450
ORDER BY customer_id, order_date DESC;

-- Query 289 (User 19)
-- Think Time: 0.55s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 716;

-- Query 290 (User 20)
-- Think Time: 1.19s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-08'
  AND p.price > 21
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8291
ORDER BY total_revenue DESC;

-- Query 291 (User 21)
-- Think Time: 0.97s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-17'
  AND p.price > 258
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1353
ORDER BY total_revenue DESC;

-- Query 292 (User 22)
-- Think Time: 1.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 146 GROUP BY status;

-- Query 293 (User 23)
-- Think Time: 1.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 237 AND 432 GROUP BY c.customer_id, c.customer_name;

-- Query 294 (User 24)
-- Think Time: 0.87s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 150 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 295 (User 25)
-- Think Time: 0.98s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-31'
  AND p.price > 244
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1640
ORDER BY total_revenue DESC;

-- Query 296 (User 26)
-- Think Time: 0.92s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 297 (User 27)
-- Think Time: 0.65s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 298 (User 28)
-- Think Time: 0.33s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 299 (User 29)
-- Think Time: 1.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 548;

-- Query 300 (User 30)
-- Think Time: 1.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 468 GROUP BY status;

-- Query 301 (User 1)
-- Think Time: 0.37s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 302 (User 2)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 486;

-- Query 303 (User 3)
-- Think Time: 1.42s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-06' AND '2023-12-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 304 (User 4)
-- Think Time: 0.60s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-26' AND '2023-09-18' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 305 (User 5)
-- Think Time: 0.89s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-25'
  AND p.price > 317
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8161
ORDER BY total_revenue DESC;

-- Query 306 (User 6)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 32 AND category_id = 1 ORDER BY stock_quantity;

-- Query 307 (User 7)
-- Think Time: 0.75s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 308 (User 8)
-- Think Time: 0.96s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 178 GROUP BY status;

-- Query 309 (User 9)
-- Think Time: 0.78s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 208 GROUP BY status;

-- Query 310 (User 10)
-- Think Time: 0.81s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 311 (User 11)
-- Think Time: 0.95s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 2 ORDER BY stock_quantity;

-- Query 312 (User 12)
-- Think Time: 0.45s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 327;

-- Query 313 (User 13)
-- Think Time: 0.86s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 480
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 10;

-- Query 314 (User 14)
-- Think Time: 1.09s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-14' AND '2023-11-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 315 (User 15)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 2 ORDER BY stock_quantity;

-- Query 316 (User 16)
-- Think Time: 0.78s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 455
  AND p.category_id = 5
ORDER BY p.price DESC
LIMIT 10;

-- Query 317 (User 17)
-- Think Time: 0.53s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-31'
  AND p.price > 426
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 7488
ORDER BY total_revenue DESC;

-- Query 318 (User 18)
-- Think Time: 0.89s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-14'
  AND p.price > 414
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1475
ORDER BY total_revenue DESC;

-- Query 319 (User 19)
-- Think Time: 0.90s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 436
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 50;

-- Query 320 (User 20)
-- Think Time: 1.14s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-13'
  AND p.price > 407
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9465
ORDER BY total_revenue DESC;

-- Query 321 (User 21)
-- Think Time: 1.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 630;

-- Query 322 (User 22)
-- Think Time: 1.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 746;

-- Query 323 (User 23)
-- Think Time: 0.95s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-18' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 324 (User 24)
-- Think Time: 1.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 255 GROUP BY status;

-- Query 325 (User 25)
-- Think Time: 0.56s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 326 (User 26)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 5 ORDER BY stock_quantity;

-- Query 327 (User 27)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 2 ORDER BY stock_quantity;

-- Query 328 (User 28)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-23'
  AND customer_id BETWEEN 63 AND 474
ORDER BY customer_id, order_date DESC;

-- Query 329 (User 29)
-- Think Time: 0.95s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 330 (User 30)
-- Think Time: 0.47s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 41
  AND p.category_id = 3
ORDER BY p.price DESC
LIMIT 10;

-- Query 331 (User 1)
-- Think Time: 0.86s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 357 AND 468 GROUP BY c.customer_id, c.customer_name;

-- Query 332 (User 2)
-- Think Time: 1.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 429;

-- Query 333 (User 3)
-- Think Time: 0.83s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-03-16'
  AND p.price > 343
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 6477
ORDER BY total_revenue DESC;

-- Query 334 (User 4)
-- Think Time: 0.81s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-26' AND '2023-10-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 335 (User 5)
-- Think Time: 0.88s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-20' AND '2023-12-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 336 (User 6)
-- Think Time: 0.90s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-30'
  AND p.price > 329
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8566
ORDER BY total_revenue DESC;

-- Query 337 (User 7)
-- Think Time: 0.54s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 97 GROUP BY status;

-- Query 338 (User 8)
-- Think Time: 0.95s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-04'
  AND customer_id BETWEEN 233 AND 415
ORDER BY customer_id, order_date DESC;

-- Query 339 (User 9)
-- Think Time: 1.32s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 874;

-- Query 340 (User 10)
-- Think Time: 1.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 427;

-- Query 341 (User 11)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 342 (User 12)
-- Think Time: 0.88s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-28'
  AND p.price > 113
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 5998
ORDER BY total_revenue DESC;

-- Query 343 (User 13)
-- Think Time: 0.57s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 253 AND 427 GROUP BY c.customer_id, c.customer_name;

-- Query 344 (User 14)
-- Think Time: 1.34s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-25'
  AND customer_id BETWEEN 179 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 345 (User 15)
-- Think Time: 1.36s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 346 (User 16)
-- Think Time: 1.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 824;

-- Query 347 (User 17)
-- Think Time: 1.00s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 831;

-- Query 348 (User 18)
-- Think Time: 1.33s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 74 AND 497 GROUP BY c.customer_id, c.customer_name;

-- Query 349 (User 19)
-- Think Time: 1.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 371;

-- Query 350 (User 20)
-- Think Time: 1.09s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 351 (User 21)
-- Think Time: 0.64s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 352 (User 22)
-- Think Time: 0.80s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 353 (User 23)
-- Think Time: 0.80s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 730;

-- Query 354 (User 24)
-- Think Time: 0.81s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 355 (User 25)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 254 AND 419 GROUP BY c.customer_id, c.customer_name;

-- Query 356 (User 26)
-- Think Time: 1.31s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-02' AND '2023-11-13' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 357 (User 27)
-- Think Time: 1.44s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-24' AND '2023-10-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 358 (User 28)
-- Think Time: 1.03s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 359 (User 29)
-- Think Time: 0.37s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 3 ORDER BY stock_quantity;

-- Query 360 (User 30)
-- Think Time: 1.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 3 ORDER BY stock_quantity;

