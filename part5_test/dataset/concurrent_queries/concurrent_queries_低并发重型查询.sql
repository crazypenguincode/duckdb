-- Concurrent Queries - Scenario: 低并发重型查询
-- Total queries: 50

-- Query 1 (User 1)
-- Think Time: 2.02s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-13'
  AND p.price > 203
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 3014
ORDER BY total_revenue DESC;

-- Query 2 (User 2)
-- Think Time: 1.94s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-04'
  AND p.price > 202
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 1686
ORDER BY total_revenue DESC;

-- Query 3 (User 3)
-- Think Time: 1.37s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-04'
  AND customer_id BETWEEN 396 AND 480
ORDER BY customer_id, order_date DESC;

-- Query 4 (User 4)
-- Think Time: 2.47s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-01' AND '2023-10-28' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 5 (User 5)
-- Think Time: 2.35s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 6 (User 1)
-- Think Time: 2.51s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 7 (User 2)
-- Think Time: 1.58s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 8 (User 3)
-- Think Time: 2.09s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-06'
  AND customer_id BETWEEN 370 AND 487
ORDER BY customer_id, order_date DESC;

-- Query 9 (User 4)
-- Think Time: 2.01s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 10 (User 5)
-- Think Time: 1.93s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-05' AND '2023-09-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 11 (User 1)
-- Think Time: 2.66s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-25' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 12 (User 2)
-- Think Time: 1.91s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-01'
  AND p.price > 422
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 2674
ORDER BY total_revenue DESC;

-- Query 13 (User 3)
-- Think Time: 2.29s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-05'
  AND customer_id BETWEEN 253 AND 428
ORDER BY customer_id, order_date DESC;

-- Query 14 (User 4)
-- Think Time: 1.19s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 15 (User 5)
-- Think Time: 2.56s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 116
  AND p.category_id = 4
ORDER BY p.price DESC
LIMIT 10;

-- Query 16 (User 1)
-- Think Time: 2.46s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-15' AND '2023-07-23' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 17 (User 2)
-- Think Time: 2.21s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 198
  AND p.category_id = 1
ORDER BY p.price DESC
LIMIT 50;

-- Query 18 (User 3)
-- Think Time: 2.68s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-28' AND '2023-10-01' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 19 (User 4)
-- Think Time: 1.55s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 320
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 50;

-- Query 20 (User 5)
-- Think Time: 2.66s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-03-07'
  AND p.price > 76
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9514
ORDER BY total_revenue DESC;

-- Query 21 (User 1)
-- Think Time: 2.56s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-12' AND '2023-11-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 22 (User 2)
-- Think Time: 2.37s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-14' AND '2023-09-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 23 (User 3)
-- Think Time: 1.87s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-26' AND '2023-09-02' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 24 (User 4)
-- Think Time: 2.93s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-19' AND '2023-12-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 25 (User 5)
-- Think Time: 2.47s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-02' AND '2023-12-02' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 26 (User 1)
-- Think Time: 1.90s
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

-- Query 27 (User 2)
-- Think Time: 2.43s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-05' AND '2023-12-11' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 28 (User 3)
-- Think Time: 2.74s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-14'
  AND customer_id BETWEEN 393 AND 480
ORDER BY customer_id, order_date DESC;

-- Query 29 (User 4)
-- Think Time: 2.16s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-07-14'
  AND p.price > 55
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 9555
ORDER BY total_revenue DESC;

-- Query 30 (User 5)
-- Think Time: 2.78s
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > 464
  AND p.category_id = 2
ORDER BY p.price DESC
LIMIT 20;

-- Query 31 (User 1)
-- Think Time: 2.98s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-17' AND '2023-08-25' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 32 (User 2)
-- Think Time: 2.12s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-31'
  AND customer_id BETWEEN 90 AND 496
ORDER BY customer_id, order_date DESC;

-- Query 33 (User 3)
-- Think Time: 1.03s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 34 (User 4)
-- Think Time: 1.81s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-06-19'
  AND p.price > 322
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 8113
ORDER BY total_revenue DESC;

-- Query 35 (User 5)
-- Think Time: 2.85s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-04-22'
  AND p.price > 205
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 7198
ORDER BY total_revenue DESC;

-- Query 36 (User 1)
-- Think Time: 2.96s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 37 (User 2)
-- Think Time: 2.71s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-10' AND '2023-10-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 38 (User 3)
-- Think Time: 2.67s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 39 (User 4)
-- Think Time: 2.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-21'
  AND customer_id BETWEEN 193 AND 468
ORDER BY customer_id, order_date DESC;

-- Query 40 (User 5)
-- Think Time: 2.90s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-01-19' AND '2023-10-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 41 (User 1)
-- Think Time: 1.78s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-05'
  AND customer_id BETWEEN 226 AND 457
ORDER BY customer_id, order_date DESC;

-- Query 42 (User 2)
-- Think Time: 2.74s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-14' AND '2023-11-02' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 43 (User 3)
-- Think Time: 1.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-25'
  AND customer_id BETWEEN 269 AND 487
ORDER BY customer_id, order_date DESC;

-- Query 44 (User 4)
-- Think Time: 1.93s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 45 (User 5)
-- Think Time: 2.65s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-12' AND '2023-08-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 46 (User 1)
-- Think Time: 1.59s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-05-20'
  AND p.price > 107
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 4575
ORDER BY total_revenue DESC;

-- Query 47 (User 2)
-- Think Time: 1.86s
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
  AND p.price > 452
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 7481
ORDER BY total_revenue DESC;

-- Query 48 (User 3)
-- Think Time: 2.33s
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-02-22'
  AND p.price > 283
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > 2774
ORDER BY total_revenue DESC;

-- Query 49 (User 4)
-- Think Time: 1.52s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 50 (User 5)
-- Think Time: 1.49s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-29'
  AND customer_id BETWEEN 389 AND 455
ORDER BY customer_id, order_date DESC;

