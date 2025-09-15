-- Concurrent Queries - Scenario: 缓存命中测试
-- Total queries: 625

-- Query 1 (User 1)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 221 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 2 (User 2)
-- Think Time: 0.25s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-08'
  AND customer_id BETWEEN 234 AND 434
ORDER BY customer_id, order_date DESC;

-- Query 3 (User 3)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 144;

-- Query 4 (User 4)
-- Think Time: 0.15s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 5 (User 5)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 6 (User 6)
-- Think Time: 0.10s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 7 (User 7)
-- Think Time: 0.25s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-02'
  AND customer_id BETWEEN 2 AND 467
ORDER BY customer_id, order_date DESC;

-- Query 8 (User 8)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 130 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 9 (User 9)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 444;

-- Query 10 (User 10)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 218 AND 462 GROUP BY c.customer_id, c.customer_name;

-- Query 11 (User 11)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 229 AND 411 GROUP BY c.customer_id, c.customer_name;

-- Query 12 (User 12)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 7 GROUP BY status;

-- Query 13 (User 13)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 14 (User 14)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 15 (User 15)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 16 (User 16)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 17 (User 17)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-24' AND '2023-08-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 18 (User 18)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 3 ORDER BY stock_quantity;

-- Query 19 (User 19)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-02'
  AND customer_id BETWEEN 16 AND 412
ORDER BY customer_id, order_date DESC;

-- Query 20 (User 20)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 21 (User 21)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 770;

-- Query 22 (User 22)
-- Think Time: 0.20s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-12' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 23 (User 23)
-- Think Time: 0.29s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 24 (User 24)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 235 AND 486 GROUP BY c.customer_id, c.customer_name;

-- Query 25 (User 25)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-09' AND '2023-11-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 26 (User 1)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 297 AND 408 GROUP BY c.customer_id, c.customer_name;

-- Query 27 (User 2)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 158 GROUP BY status;

-- Query 28 (User 3)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 45 AND 444 GROUP BY c.customer_id, c.customer_name;

-- Query 29 (User 4)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 344 GROUP BY status;

-- Query 30 (User 5)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 31 (User 6)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 133 GROUP BY status;

-- Query 32 (User 7)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 3 ORDER BY stock_quantity;

-- Query 33 (User 8)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 34 (User 9)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 35 (User 10)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 524;

-- Query 36 (User 11)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 80 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 37 (User 12)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 3 ORDER BY stock_quantity;

-- Query 38 (User 13)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 878;

-- Query 39 (User 14)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 40 (User 15)
-- Think Time: 0.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-18'
  AND customer_id BETWEEN 21 AND 458
ORDER BY customer_id, order_date DESC;

-- Query 41 (User 16)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 42 (User 17)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 84 GROUP BY status;

-- Query 43 (User 18)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 44 (User 19)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 45 (User 20)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 46 (User 21)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 47 (User 22)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 48 (User 23)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 120 GROUP BY status;

-- Query 49 (User 24)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 259 GROUP BY status;

-- Query 50 (User 25)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 51 (User 1)
-- Think Time: 0.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 492;

-- Query 52 (User 2)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 217 GROUP BY status;

-- Query 53 (User 3)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 592;

-- Query 54 (User 4)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 55 (User 5)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 4 ORDER BY stock_quantity;

-- Query 56 (User 6)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-13' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 57 (User 7)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 58 (User 8)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 59 (User 9)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 60 (User 10)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 61 (User 11)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 62 (User 12)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 63 (User 13)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-04' AND '2023-08-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 64 (User 14)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 65 (User 15)
-- Think Time: 0.18s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 66 (User 16)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 67 (User 17)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 68 (User 18)
-- Think Time: 0.19s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-13'
  AND customer_id BETWEEN 82 AND 473
ORDER BY customer_id, order_date DESC;

-- Query 69 (User 19)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 70 (User 20)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 71 (User 21)
-- Think Time: 0.18s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-26' AND '2023-10-17' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 72 (User 22)
-- Think Time: 0.22s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-12'
  AND customer_id BETWEEN 136 AND 480
ORDER BY customer_id, order_date DESC;

-- Query 73 (User 23)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 74 (User 24)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 75 (User 25)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 461 GROUP BY status;

-- Query 76 (User 1)
-- Think Time: 0.30s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 77 (User 2)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 78 (User 3)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 79 (User 4)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 80 (User 5)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 81 (User 6)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 82 (User 7)
-- Think Time: 0.16s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-28'
  AND customer_id BETWEEN 66 AND 455
ORDER BY customer_id, order_date DESC;

-- Query 83 (User 8)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 14 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 84 (User 9)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 362 GROUP BY status;

-- Query 85 (User 10)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 108 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 86 (User 11)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 613;

-- Query 87 (User 12)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 377 GROUP BY status;

-- Query 88 (User 13)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 89 (User 14)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 643;

-- Query 90 (User 15)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-01' AND '2023-11-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 91 (User 16)
-- Think Time: 0.14s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-19' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 92 (User 17)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 1 ORDER BY stock_quantity;

-- Query 93 (User 18)
-- Think Time: 0.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 94 (User 19)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-05' AND '2023-11-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 95 (User 20)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 1 ORDER BY stock_quantity;

-- Query 96 (User 21)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 378 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 97 (User 22)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 597;

-- Query 98 (User 23)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 99 (User 24)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 1 ORDER BY stock_quantity;

-- Query 100 (User 25)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 101 (User 1)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 102 (User 2)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 584;

-- Query 103 (User 3)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 104 (User 4)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-24' AND '2023-10-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 105 (User 5)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 2 ORDER BY stock_quantity;

-- Query 106 (User 6)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 265 AND 456
ORDER BY customer_id, order_date DESC;

-- Query 107 (User 7)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 108 (User 8)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 5 ORDER BY stock_quantity;

-- Query 109 (User 9)
-- Think Time: 0.12s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-27'
  AND customer_id BETWEEN 27 AND 451
ORDER BY customer_id, order_date DESC;

-- Query 110 (User 10)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 476;

-- Query 111 (User 11)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 112 (User 12)
-- Think Time: 0.25s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 113 (User 13)
-- Think Time: 0.20s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-28'
  AND customer_id BETWEEN 126 AND 428
ORDER BY customer_id, order_date DESC;

-- Query 114 (User 14)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 688;

-- Query 115 (User 15)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 9 AND 499 GROUP BY c.customer_id, c.customer_name;

-- Query 116 (User 16)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 117 (User 17)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 220;

-- Query 118 (User 18)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 119 (User 19)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 120 (User 20)
-- Think Time: 0.12s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 121 (User 21)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 122 (User 22)
-- Think Time: 0.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 123 (User 23)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-03'
  AND customer_id BETWEEN 225 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 124 (User 24)
-- Think Time: 0.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 125 (User 25)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 372 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 126 (User 1)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 5 ORDER BY stock_quantity;

-- Query 127 (User 2)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 131;

-- Query 128 (User 3)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 129 (User 4)
-- Think Time: 0.19s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 76 GROUP BY status;

-- Query 130 (User 5)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 480 GROUP BY status;

-- Query 131 (User 6)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 567;

-- Query 132 (User 7)
-- Think Time: 0.15s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-09' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 133 (User 8)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 517;

-- Query 134 (User 9)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 115 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 135 (User 10)
-- Think Time: 0.24s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-13'
  AND customer_id BETWEEN 22 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 136 (User 11)
-- Think Time: 0.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-21'
  AND customer_id BETWEEN 348 AND 403
ORDER BY customer_id, order_date DESC;

-- Query 137 (User 12)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 292 GROUP BY status;

-- Query 138 (User 13)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-20' AND '2023-07-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 139 (User 14)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 26 GROUP BY status;

-- Query 140 (User 15)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-12' AND '2023-08-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 141 (User 16)
-- Think Time: 0.24s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-07' AND '2023-12-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 142 (User 17)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 635;

-- Query 143 (User 18)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 271 GROUP BY status;

-- Query 144 (User 19)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 153 AND 407 GROUP BY c.customer_id, c.customer_name;

-- Query 145 (User 20)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 146 (User 21)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 783;

-- Query 147 (User 22)
-- Think Time: 0.30s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-08' AND '2023-08-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 148 (User 23)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 149 (User 24)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 150 (User 25)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 223;

-- Query 151 (User 1)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 2 ORDER BY stock_quantity;

-- Query 152 (User 2)
-- Think Time: 0.27s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 153 (User 3)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 102 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 154 (User 4)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 155 (User 5)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 156 (User 6)
-- Think Time: 0.26s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 157 (User 7)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 158 (User 8)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 159 (User 9)
-- Think Time: 0.10s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 160 (User 10)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 161 (User 11)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 78 GROUP BY status;

-- Query 162 (User 12)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 163 (User 13)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 164 (User 14)
-- Think Time: 0.27s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 388;

-- Query 165 (User 15)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 103 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 166 (User 16)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 167 (User 17)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 27 AND category_id = 2 ORDER BY stock_quantity;

-- Query 168 (User 18)
-- Think Time: 0.25s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 169 (User 19)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 2 ORDER BY stock_quantity;

-- Query 170 (User 20)
-- Think Time: 0.20s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-04'
  AND customer_id BETWEEN 155 AND 403
ORDER BY customer_id, order_date DESC;

-- Query 171 (User 21)
-- Think Time: 0.19s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 344;

-- Query 172 (User 22)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 173 (User 23)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 174 (User 24)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 2 ORDER BY stock_quantity;

-- Query 175 (User 25)
-- Think Time: 0.16s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-03'
  AND customer_id BETWEEN 179 AND 464
ORDER BY customer_id, order_date DESC;

-- Query 176 (User 1)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 286 GROUP BY status;

-- Query 177 (User 2)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 178 (User 3)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 179 (User 4)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 180 (User 5)
-- Think Time: 0.11s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-01'
  AND customer_id BETWEEN 192 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 181 (User 6)
-- Think Time: 0.14s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 182 (User 7)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 227 GROUP BY status;

-- Query 183 (User 8)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 184 (User 9)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-03'
  AND customer_id BETWEEN 64 AND 471
ORDER BY customer_id, order_date DESC;

-- Query 185 (User 10)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 348;

-- Query 186 (User 11)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 126;

-- Query 187 (User 12)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-18'
  AND customer_id BETWEEN 109 AND 488
ORDER BY customer_id, order_date DESC;

-- Query 188 (User 13)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 189 (User 14)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 190 (User 15)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 191 (User 16)
-- Think Time: 0.14s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 192 (User 17)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 193 (User 18)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 194 (User 19)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 195 (User 20)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 221 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 196 (User 21)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 197 (User 22)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 198 (User 23)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 199 (User 24)
-- Think Time: 0.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 492;

-- Query 200 (User 25)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-03'
  AND customer_id BETWEEN 225 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 201 (User 1)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 223;

-- Query 202 (User 2)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 203 (User 3)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 480 GROUP BY status;

-- Query 204 (User 4)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 84 GROUP BY status;

-- Query 205 (User 5)
-- Think Time: 0.27s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 206 (User 6)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 158 GROUP BY status;

-- Query 207 (User 7)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 208 (User 8)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-20' AND '2023-07-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 209 (User 9)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 210 (User 10)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 378 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 211 (User 11)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 14 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 212 (User 12)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 3 ORDER BY stock_quantity;

-- Query 213 (User 13)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 214 (User 14)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 476;

-- Query 215 (User 15)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 4 ORDER BY stock_quantity;

-- Query 216 (User 16)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 217 (User 17)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 218 (User 18)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 688;

-- Query 219 (User 19)
-- Think Time: 0.20s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-12' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 220 (User 20)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 221 (User 21)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 222 (User 22)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 223 (User 23)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 224 (User 24)
-- Think Time: 0.12s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 225 (User 25)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 613;

-- Query 226 (User 1)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 227 (User 2)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 228 (User 3)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 229 (User 4)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 344 GROUP BY status;

-- Query 230 (User 5)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 231 (User 6)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 232 (User 7)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 233 (User 8)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 153 AND 407 GROUP BY c.customer_id, c.customer_name;

-- Query 234 (User 9)
-- Think Time: 0.12s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 235 (User 10)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 236 (User 11)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 223;

-- Query 237 (User 12)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 265 AND 456
ORDER BY customer_id, order_date DESC;

-- Query 238 (User 13)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 239 (User 14)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 1 ORDER BY stock_quantity;

-- Query 240 (User 15)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 241 (User 16)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 643;

-- Query 242 (User 17)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 243 (User 18)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 770;

-- Query 244 (User 19)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 517;

-- Query 245 (User 20)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-12' AND '2023-08-07' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 246 (User 21)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 247 (User 22)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 248 (User 23)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 3 ORDER BY stock_quantity;

-- Query 249 (User 24)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 250 (User 25)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 251 (User 1)
-- Think Time: 0.25s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 252 (User 2)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 253 (User 3)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 254 (User 4)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-18'
  AND customer_id BETWEEN 109 AND 488
ORDER BY customer_id, order_date DESC;

-- Query 255 (User 5)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 256 (User 6)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 257 (User 7)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 258 (User 8)
-- Think Time: 0.25s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 259 (User 9)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 227 GROUP BY status;

-- Query 260 (User 10)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 261 (User 11)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-03'
  AND customer_id BETWEEN 225 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 262 (User 12)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 263 (User 13)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 264 (User 14)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 265 (User 15)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 259 GROUP BY status;

-- Query 266 (User 16)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 267 (User 17)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 268 (User 18)
-- Think Time: 0.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 492;

-- Query 269 (User 19)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 270 (User 20)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 271 (User 21)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 272 (User 22)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 273 (User 23)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 274 (User 24)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 517;

-- Query 275 (User 25)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 131;

-- Query 276 (User 1)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 277 (User 2)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 278 (User 3)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 597;

-- Query 279 (User 4)
-- Think Time: 0.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 280 (User 5)
-- Think Time: 0.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 281 (User 6)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 344 GROUP BY status;

-- Query 282 (User 7)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 377 GROUP BY status;

-- Query 283 (User 8)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-24' AND '2023-10-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 284 (User 9)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 285 (User 10)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 286 (User 11)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 287 (User 12)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 517;

-- Query 288 (User 13)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 2 ORDER BY stock_quantity;

-- Query 289 (User 14)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 290 (User 15)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 7 GROUP BY status;

-- Query 291 (User 16)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 292 (User 17)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 293 (User 18)
-- Think Time: 0.30s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-08' AND '2023-08-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 294 (User 19)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 295 (User 20)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 296 (User 21)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 297 (User 22)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 292 GROUP BY status;

-- Query 298 (User 23)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 299 (User 24)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 300 (User 25)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 103 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 301 (User 1)
-- Think Time: 0.30s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 302 (User 2)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 303 (User 3)
-- Think Time: 0.30s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 304 (User 4)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 305 (User 5)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 306 (User 6)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 5 ORDER BY stock_quantity;

-- Query 307 (User 7)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 308 (User 8)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 78 GROUP BY status;

-- Query 309 (User 9)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 130 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 310 (User 10)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 348;

-- Query 311 (User 11)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 312 (User 12)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 783;

-- Query 313 (User 13)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 314 (User 14)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 144;

-- Query 315 (User 15)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 316 (User 16)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-24' AND '2023-08-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 317 (User 17)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 5 ORDER BY stock_quantity;

-- Query 318 (User 18)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 319 (User 19)
-- Think Time: 0.14s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-19' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 320 (User 20)
-- Think Time: 0.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 321 (User 21)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 322 (User 22)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-03'
  AND customer_id BETWEEN 225 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 323 (User 23)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 324 (User 24)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 325 (User 25)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 326 (User 1)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 327 (User 2)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-24' AND '2023-10-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 328 (User 3)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 329 (User 4)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 330 (User 5)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 331 (User 6)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 80 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 332 (User 7)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 333 (User 8)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-05' AND '2023-11-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 334 (User 9)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 335 (User 10)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 102 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 336 (User 11)
-- Think Time: 0.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-18'
  AND customer_id BETWEEN 21 AND 458
ORDER BY customer_id, order_date DESC;

-- Query 337 (User 12)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 444;

-- Query 338 (User 13)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 339 (User 14)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 265 AND 456
ORDER BY customer_id, order_date DESC;

-- Query 340 (User 15)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 341 (User 16)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 342 (User 17)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 343 (User 18)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 102 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 344 (User 19)
-- Think Time: 0.20s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-12' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 345 (User 20)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-03'
  AND customer_id BETWEEN 64 AND 471
ORDER BY customer_id, order_date DESC;

-- Query 346 (User 21)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 347 (User 22)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 348 (User 23)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 349 (User 24)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 297 AND 408 GROUP BY c.customer_id, c.customer_name;

-- Query 350 (User 25)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 2 ORDER BY stock_quantity;

-- Query 351 (User 1)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 613;

-- Query 352 (User 2)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 878;

-- Query 353 (User 3)
-- Think Time: 0.12s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 354 (User 4)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 355 (User 5)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 45 AND 444 GROUP BY c.customer_id, c.customer_name;

-- Query 356 (User 6)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 227 GROUP BY status;

-- Query 357 (User 7)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 358 (User 8)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 359 (User 9)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 120 GROUP BY status;

-- Query 360 (User 10)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 361 (User 11)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 584;

-- Query 362 (User 12)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 363 (User 13)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-24' AND '2023-08-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 364 (User 14)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 365 (User 15)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 5 ORDER BY stock_quantity;

-- Query 366 (User 16)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 108 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 367 (User 17)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 5 ORDER BY stock_quantity;

-- Query 368 (User 18)
-- Think Time: 0.30s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-08' AND '2023-08-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 369 (User 19)
-- Think Time: 0.15s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 370 (User 20)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 144;

-- Query 371 (User 21)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 372 (User 22)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-24' AND '2023-08-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 373 (User 23)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 115 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 374 (User 24)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 375 (User 25)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 376 (User 1)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 377 (User 2)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 378 (User 3)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-13' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 379 (User 4)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 108 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 380 (User 5)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 381 (User 6)
-- Think Time: 0.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-01-21'
  AND customer_id BETWEEN 348 AND 403
ORDER BY customer_id, order_date DESC;

-- Query 382 (User 7)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 383 (User 8)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 9 AND 499 GROUP BY c.customer_id, c.customer_name;

-- Query 384 (User 9)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 385 (User 10)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 84 GROUP BY status;

-- Query 386 (User 11)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 387 (User 12)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 388 (User 13)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-20' AND '2023-07-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 389 (User 14)
-- Think Time: 0.27s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 388;

-- Query 390 (User 15)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-04' AND '2023-08-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 391 (User 16)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 392 (User 17)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 14 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 393 (User 18)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 394 (User 19)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 395 (User 20)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 286 GROUP BY status;

-- Query 396 (User 21)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 397 (User 22)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 398 (User 23)
-- Think Time: 0.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 399 (User 24)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-03'
  AND customer_id BETWEEN 225 AND 425
ORDER BY customer_id, order_date DESC;

-- Query 400 (User 25)
-- Think Time: 0.20s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-12' AND '2023-10-04' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 401 (User 1)
-- Think Time: 0.14s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-19' AND '2023-12-30' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 402 (User 2)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 403 (User 3)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 102 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 404 (User 4)
-- Think Time: 0.10s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 405 (User 5)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 406 (User 6)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 4 ORDER BY stock_quantity;

-- Query 407 (User 7)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 408 (User 8)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 84 GROUP BY status;

-- Query 409 (User 9)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 410 (User 10)
-- Think Time: 0.12s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 275 AND 421 GROUP BY c.customer_id, c.customer_name;

-- Query 411 (User 11)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-18'
  AND customer_id BETWEEN 109 AND 488
ORDER BY customer_id, order_date DESC;

-- Query 412 (User 12)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 413 (User 13)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-24' AND '2023-10-06' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 414 (User 14)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 362 GROUP BY status;

-- Query 415 (User 15)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 144;

-- Query 416 (User 16)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 229 AND 411 GROUP BY c.customer_id, c.customer_name;

-- Query 417 (User 17)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 348;

-- Query 418 (User 18)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 217 GROUP BY status;

-- Query 419 (User 19)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 3 ORDER BY stock_quantity;

-- Query 420 (User 20)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 421 (User 21)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 422 (User 22)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 423 (User 23)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 424 (User 24)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 218 AND 462 GROUP BY c.customer_id, c.customer_name;

-- Query 425 (User 25)
-- Think Time: 0.14s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 426 (User 1)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 427 (User 2)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 428 (User 3)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 429 (User 4)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 430 (User 5)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 220;

-- Query 431 (User 6)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 2 ORDER BY stock_quantity;

-- Query 432 (User 7)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 3 ORDER BY stock_quantity;

-- Query 433 (User 8)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 434 (User 9)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 435 (User 10)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 436 (User 11)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 878;

-- Query 437 (User 12)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 438 (User 13)
-- Think Time: 0.19s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 76 GROUP BY status;

-- Query 439 (User 14)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 5 ORDER BY stock_quantity;

-- Query 440 (User 15)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 441 (User 16)
-- Think Time: 0.14s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 442 (User 17)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 362 GROUP BY status;

-- Query 443 (User 18)
-- Think Time: 0.16s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-28'
  AND customer_id BETWEEN 66 AND 455
ORDER BY customer_id, order_date DESC;

-- Query 444 (User 19)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 445 (User 20)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 2 ORDER BY stock_quantity;

-- Query 446 (User 21)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 447 (User 22)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 448 (User 23)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 449 (User 24)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 450 (User 25)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 103 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 451 (User 1)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 452 (User 2)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 3 ORDER BY stock_quantity;

-- Query 453 (User 3)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 454 (User 4)
-- Think Time: 0.10s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 455 (User 5)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 131;

-- Query 456 (User 6)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 422;

-- Query 457 (User 7)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 3 ORDER BY stock_quantity;

-- Query 458 (User 8)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 126;

-- Query 459 (User 9)
-- Think Time: 0.14s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 460 (User 10)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 461 (User 11)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 462 (User 12)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 688;

-- Query 463 (User 13)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-05' AND '2023-11-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 464 (User 14)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 465 (User 15)
-- Think Time: 0.30s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-08' AND '2023-08-27' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 466 (User 16)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 467 (User 17)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 468 (User 18)
-- Think Time: 0.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 492;

-- Query 469 (User 19)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 470 (User 20)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 471 (User 21)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 286 GROUP BY status;

-- Query 472 (User 22)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-08'
  AND customer_id BETWEEN 18 AND 484
ORDER BY customer_id, order_date DESC;

-- Query 473 (User 23)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 474 (User 24)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 2 ORDER BY stock_quantity;

-- Query 475 (User 25)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 476 (User 1)
-- Think Time: 0.18s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-26' AND '2023-10-17' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 477 (User 2)
-- Think Time: 0.16s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-28'
  AND customer_id BETWEEN 66 AND 455
ORDER BY customer_id, order_date DESC;

-- Query 478 (User 3)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 4 ORDER BY stock_quantity;

-- Query 479 (User 4)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 480 (User 5)
-- Think Time: 0.27s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 481 (User 6)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 482 (User 7)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 483 (User 8)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 643;

-- Query 484 (User 9)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 485 (User 10)
-- Think Time: 0.15s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-09' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 486 (User 11)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 487 (User 12)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 271 GROUP BY status;

-- Query 488 (User 13)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 489 (User 14)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 490 (User 15)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 613;

-- Query 491 (User 16)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 220;

-- Query 492 (User 17)
-- Think Time: 0.10s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 492;

-- Query 493 (User 18)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 494 (User 19)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 567;

-- Query 495 (User 20)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 297 AND 408 GROUP BY c.customer_id, c.customer_name;

-- Query 496 (User 21)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 497 (User 22)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 498 (User 23)
-- Think Time: 0.10s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 499 (User 24)
-- Think Time: 0.26s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 500 (User 25)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 501 (User 1)
-- Think Time: 0.18s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-02-26' AND '2023-10-17' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 502 (User 2)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 503 (User 3)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 504 (User 4)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 505 (User 5)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 2 ORDER BY stock_quantity;

-- Query 506 (User 6)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 507 (User 7)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 508 (User 8)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 509 (User 9)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 510 (User 10)
-- Think Time: 0.12s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-04-27'
  AND customer_id BETWEEN 27 AND 451
ORDER BY customer_id, order_date DESC;

-- Query 511 (User 11)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 512 (User 12)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 297 AND 408 GROUP BY c.customer_id, c.customer_name;

-- Query 513 (User 13)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 514 (User 14)
-- Think Time: 0.27s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-18'
  AND customer_id BETWEEN 21 AND 458
ORDER BY customer_id, order_date DESC;

-- Query 515 (User 15)
-- Think Time: 0.30s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 516 (User 16)
-- Think Time: 0.21s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 517 (User 17)
-- Think Time: 0.18s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 518 (User 18)
-- Think Time: 0.10s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 519 (User 19)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 520 (User 20)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 783;

-- Query 521 (User 21)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-04-20' AND '2023-07-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 522 (User 22)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 378 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 523 (User 23)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 259 GROUP BY status;

-- Query 524 (User 24)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 525 (User 25)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 526 (User 1)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 527 (User 2)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 528 (User 3)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 529 (User 4)
-- Think Time: 0.13s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 530 (User 5)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 643;

-- Query 531 (User 6)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 7 GROUP BY status;

-- Query 532 (User 7)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 14 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 533 (User 8)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-02'
  AND customer_id BETWEEN 16 AND 412
ORDER BY customer_id, order_date DESC;

-- Query 534 (User 9)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 535 (User 10)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 536 (User 11)
-- Think Time: 0.30s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 30 AND 426
ORDER BY customer_id, order_date DESC;

-- Query 537 (User 12)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 538 (User 13)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 539 (User 14)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 362 GROUP BY status;

-- Query 540 (User 15)
-- Think Time: 0.19s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-09' AND '2023-11-10' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 541 (User 16)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 130 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 542 (User 17)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 372 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 543 (User 18)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 227 GROUP BY status;

-- Query 544 (User 19)
-- Think Time: 0.29s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 545 (User 20)
-- Think Time: 0.28s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-05' AND '2023-11-03' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 546 (User 21)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 1 ORDER BY stock_quantity;

-- Query 547 (User 22)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 362 GROUP BY status;

-- Query 548 (User 23)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 292 GROUP BY status;

-- Query 549 (User 24)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 550 (User 25)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 551 (User 1)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 2 ORDER BY stock_quantity;

-- Query 552 (User 2)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 553 (User 3)
-- Think Time: 0.11s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 554 (User 4)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 555 (User 5)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 556 (User 6)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 557 (User 7)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 558 (User 8)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 559 (User 9)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-06-18' AND '2023-08-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 560 (User 10)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 286 GROUP BY status;

-- Query 561 (User 11)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 562 (User 12)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 298 GROUP BY status;

-- Query 563 (User 13)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-03-02'
  AND customer_id BETWEEN 49 AND 446
ORDER BY customer_id, order_date DESC;

-- Query 564 (User 14)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 565 (User 15)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 566 (User 16)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-02'
  AND customer_id BETWEEN 16 AND 412
ORDER BY customer_id, order_date DESC;

-- Query 567 (User 17)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 770;

-- Query 568 (User 18)
-- Think Time: 0.27s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 569 (User 19)
-- Think Time: 0.10s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 570 (User 20)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 571 (User 21)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 378 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 572 (User 22)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 378 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 573 (User 23)
-- Think Time: 0.29s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 574 (User 24)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 575 (User 25)
-- Think Time: 0.13s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-06'
  AND customer_id BETWEEN 14 AND 401
ORDER BY customer_id, order_date DESC;

-- Query 576 (User 1)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 577 (User 2)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 567;

-- Query 578 (User 3)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 218 AND 462 GROUP BY c.customer_id, c.customer_name;

-- Query 579 (User 4)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 372 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 580 (User 5)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 517;

-- Query 581 (User 6)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 582 (User 7)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 2 ORDER BY stock_quantity;

-- Query 583 (User 8)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 235 AND 486 GROUP BY c.customer_id, c.customer_name;

-- Query 584 (User 9)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 513;

-- Query 585 (User 10)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 643;

-- Query 586 (User 11)
-- Think Time: 0.10s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-06' AND '2023-08-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 587 (User 12)
-- Think Time: 0.23s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-01' AND '2023-11-19' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 588 (User 13)
-- Think Time: 0.28s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-03'
  AND customer_id BETWEEN 64 AND 471
ORDER BY customer_id, order_date DESC;

-- Query 589 (User 14)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-07-04' AND '2023-11-26' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 590 (User 15)
-- Think Time: 0.21s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-18'
  AND customer_id BETWEEN 109 AND 488
ORDER BY customer_id, order_date DESC;

-- Query 591 (User 16)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 592 (User 17)
-- Think Time: 0.13s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-04' AND '2023-11-24' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 593 (User 18)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 594 (User 19)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 595 (User 20)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 3 ORDER BY stock_quantity;

-- Query 596 (User 21)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 597 (User 22)
-- Think Time: 0.25s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 598 (User 23)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 599 (User 24)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 344 GROUP BY status;

-- Query 600 (User 25)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 613;

-- Query 601 (User 1)
-- Think Time: 0.18s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-06-25'
  AND customer_id BETWEEN 27 AND 441
ORDER BY customer_id, order_date DESC;

-- Query 602 (User 2)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 603 (User 3)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 604 (User 4)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 1 ORDER BY stock_quantity;

-- Query 605 (User 5)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 606 (User 6)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 3 ORDER BY stock_quantity;

-- Query 607 (User 7)
-- Think Time: 0.20s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 608 (User 8)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 609 (User 9)
-- Think Time: 0.24s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 610 (User 10)
-- Think Time: 0.22s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 20;

-- Query 611 (User 11)
-- Think Time: 0.15s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-03-09' AND '2023-09-29' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 612 (User 12)
-- Think Time: 0.14s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-07-01'
  AND customer_id BETWEEN 176 AND 493
ORDER BY customer_id, order_date DESC;

-- Query 613 (User 13)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 27 AND category_id = 2 ORDER BY stock_quantity;

-- Query 614 (User 14)
-- Think Time: 0.16s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 50;

-- Query 615 (User 15)
-- Think Time: 0.22s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-02-12'
  AND customer_id BETWEEN 136 AND 480
ORDER BY customer_id, order_date DESC;

-- Query 616 (User 16)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 2 ORDER BY stock_quantity;

-- Query 617 (User 17)
-- Think Time: 0.22s
SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '2023-05-04' AND '2023-08-15' GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 618 (User 18)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 619 (User 19)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 620 (User 20)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 133 GROUP BY status;

-- Query 621 (User 21)
-- Think Time: 0.15s
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '2023-05-26'
  AND customer_id BETWEEN 265 AND 456
ORDER BY customer_id, order_date DESC;

-- Query 622 (User 22)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 524;

-- Query 623 (User 23)
-- Think Time: 0.17s
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT 10;

-- Query 624 (User 24)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 625 (User 25)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

