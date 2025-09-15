-- Concurrent Queries - Scenario: 高并发轻量查询
-- Total queries: 1000

-- Query 1 (User 1)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 2 (User 2)
-- Think Time: 0.40s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 259 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 3 (User 3)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 175 AND 436 GROUP BY c.customer_id, c.customer_name;

-- Query 4 (User 4)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 5 ORDER BY stock_quantity;

-- Query 5 (User 5)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 41 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 6 (User 6)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 7 (User 7)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 162 GROUP BY status;

-- Query 8 (User 8)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 276 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 9 (User 9)
-- Think Time: 0.37s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 10 (User 10)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 11 (User 11)
-- Think Time: 0.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 652;

-- Query 12 (User 12)
-- Think Time: 0.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 680;

-- Query 13 (User 13)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 14 (User 14)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 446;

-- Query 15 (User 15)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 626;

-- Query 16 (User 16)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 2 ORDER BY stock_quantity;

-- Query 17 (User 17)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 335 GROUP BY status;

-- Query 18 (User 18)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 115;

-- Query 19 (User 19)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 209 AND 463 GROUP BY c.customer_id, c.customer_name;

-- Query 20 (User 20)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 588;

-- Query 21 (User 21)
-- Think Time: 0.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 352;

-- Query 22 (User 22)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 23 (User 23)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 2 ORDER BY stock_quantity;

-- Query 24 (User 24)
-- Think Time: 0.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 769;

-- Query 25 (User 25)
-- Think Time: 0.39s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 315;

-- Query 26 (User 26)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 259 AND 463 GROUP BY c.customer_id, c.customer_name;

-- Query 27 (User 27)
-- Think Time: 0.32s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 5 GROUP BY status;

-- Query 28 (User 28)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 2 ORDER BY stock_quantity;

-- Query 29 (User 29)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 84 AND 423 GROUP BY c.customer_id, c.customer_name;

-- Query 30 (User 30)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 31 (User 31)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 205 GROUP BY status;

-- Query 32 (User 32)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 403 GROUP BY status;

-- Query 33 (User 33)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 1 ORDER BY stock_quantity;

-- Query 34 (User 34)
-- Think Time: 0.37s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 357 GROUP BY status;

-- Query 35 (User 35)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 292 AND 439 GROUP BY c.customer_id, c.customer_name;

-- Query 36 (User 36)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 2 ORDER BY stock_quantity;

-- Query 37 (User 37)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 13 AND 406 GROUP BY c.customer_id, c.customer_name;

-- Query 38 (User 38)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 39 (User 39)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 40 (User 40)
-- Think Time: 0.35s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 596;

-- Query 41 (User 41)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 172 GROUP BY status;

-- Query 42 (User 42)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 33 AND 454 GROUP BY c.customer_id, c.customer_name;

-- Query 43 (User 43)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 324;

-- Query 44 (User 44)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 45 (User 45)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 46 (User 46)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 3 ORDER BY stock_quantity;

-- Query 47 (User 47)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 48 (User 48)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 494 GROUP BY status;

-- Query 49 (User 49)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 304 AND 489 GROUP BY c.customer_id, c.customer_name;

-- Query 50 (User 50)
-- Think Time: 0.16s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 422 GROUP BY status;

-- Query 51 (User 1)
-- Think Time: 0.45s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 334 AND 435 GROUP BY c.customer_id, c.customer_name;

-- Query 52 (User 2)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 292 AND 479 GROUP BY c.customer_id, c.customer_name;

-- Query 53 (User 3)
-- Think Time: 0.40s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 265 GROUP BY status;

-- Query 54 (User 4)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 4 ORDER BY stock_quantity;

-- Query 55 (User 5)
-- Think Time: 0.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 648;

-- Query 56 (User 6)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 111 AND 495 GROUP BY c.customer_id, c.customer_name;

-- Query 57 (User 7)
-- Think Time: 0.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 499 GROUP BY status;

-- Query 58 (User 8)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 59 (User 9)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 60 (User 10)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 4 ORDER BY stock_quantity;

-- Query 61 (User 11)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 62 (User 12)
-- Think Time: 0.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 1 ORDER BY stock_quantity;

-- Query 63 (User 13)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 31 AND 422 GROUP BY c.customer_id, c.customer_name;

-- Query 64 (User 14)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 3 ORDER BY stock_quantity;

-- Query 65 (User 15)
-- Think Time: 0.50s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 301 AND 403 GROUP BY c.customer_id, c.customer_name;

-- Query 66 (User 16)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 4 ORDER BY stock_quantity;

-- Query 67 (User 17)
-- Think Time: 0.28s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 5 ORDER BY stock_quantity;

-- Query 68 (User 18)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 69 (User 19)
-- Think Time: 0.50s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 1 ORDER BY stock_quantity;

-- Query 70 (User 20)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 71 (User 21)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 98 AND 477 GROUP BY c.customer_id, c.customer_name;

-- Query 72 (User 22)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 293;

-- Query 73 (User 23)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 197 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 74 (User 24)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 75 (User 25)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 241 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 76 (User 26)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 5 ORDER BY stock_quantity;

-- Query 77 (User 27)
-- Think Time: 0.31s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 13 AND category_id = 2 ORDER BY stock_quantity;

-- Query 78 (User 28)
-- Think Time: 0.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 360;

-- Query 79 (User 29)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 80 (User 30)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 293 GROUP BY status;

-- Query 81 (User 31)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 82 (User 32)
-- Think Time: 0.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 129 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 83 (User 33)
-- Think Time: 0.43s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 152 AND 442 GROUP BY c.customer_id, c.customer_name;

-- Query 84 (User 34)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 494 GROUP BY status;

-- Query 85 (User 35)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 480;

-- Query 86 (User 36)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 13 AND 480 GROUP BY c.customer_id, c.customer_name;

-- Query 87 (User 37)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 88 (User 38)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 133;

-- Query 89 (User 39)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 228 AND 431 GROUP BY c.customer_id, c.customer_name;

-- Query 90 (User 40)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 1 ORDER BY stock_quantity;

-- Query 91 (User 41)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 356;

-- Query 92 (User 42)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 93 (User 43)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 94 (User 44)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 95 (User 45)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 320 AND 482 GROUP BY c.customer_id, c.customer_name;

-- Query 96 (User 46)
-- Think Time: 0.23s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 97 (User 47)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 47 GROUP BY status;

-- Query 98 (User 48)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 714;

-- Query 99 (User 49)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 100 (User 50)
-- Think Time: 0.40s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 5 ORDER BY stock_quantity;

-- Query 101 (User 1)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 206 GROUP BY status;

-- Query 102 (User 2)
-- Think Time: 0.37s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 3 ORDER BY stock_quantity;

-- Query 103 (User 3)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 213 GROUP BY status;

-- Query 104 (User 4)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 885;

-- Query 105 (User 5)
-- Think Time: 0.32s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 221 GROUP BY status;

-- Query 106 (User 6)
-- Think Time: 0.38s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 236 GROUP BY status;

-- Query 107 (User 7)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 3 ORDER BY stock_quantity;

-- Query 108 (User 8)
-- Think Time: 0.18s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 5 ORDER BY stock_quantity;

-- Query 109 (User 9)
-- Think Time: 0.17s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 75 GROUP BY status;

-- Query 110 (User 10)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 4 ORDER BY stock_quantity;

-- Query 111 (User 11)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 3 ORDER BY stock_quantity;

-- Query 112 (User 12)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 113 (User 13)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 114 (User 14)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 191 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 115 (User 15)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 42 GROUP BY status;

-- Query 116 (User 16)
-- Think Time: 0.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 363 AND 411 GROUP BY c.customer_id, c.customer_name;

-- Query 117 (User 17)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 118 (User 18)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 119 (User 19)
-- Think Time: 0.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 339;

-- Query 120 (User 20)
-- Think Time: 0.43s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 237 GROUP BY status;

-- Query 121 (User 21)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 881;

-- Query 122 (User 22)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 32 AND category_id = 5 ORDER BY stock_quantity;

-- Query 123 (User 23)
-- Think Time: 0.38s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 1 ORDER BY stock_quantity;

-- Query 124 (User 24)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 230 AND 479 GROUP BY c.customer_id, c.customer_name;

-- Query 125 (User 25)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 328 GROUP BY status;

-- Query 126 (User 26)
-- Think Time: 0.37s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 780;

-- Query 127 (User 27)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 482;

-- Query 128 (User 28)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 129 (User 29)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 357 AND 462 GROUP BY c.customer_id, c.customer_name;

-- Query 130 (User 30)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 386 GROUP BY status;

-- Query 131 (User 31)
-- Think Time: 0.39s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 499 GROUP BY status;

-- Query 132 (User 32)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 133 (User 33)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 27 AND category_id = 3 ORDER BY stock_quantity;

-- Query 134 (User 34)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 74 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 135 (User 35)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 3 ORDER BY stock_quantity;

-- Query 136 (User 36)
-- Think Time: 0.47s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 137 (User 37)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 2 ORDER BY stock_quantity;

-- Query 138 (User 38)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 407 GROUP BY status;

-- Query 139 (User 39)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 140 (User 40)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 629;

-- Query 141 (User 41)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 268;

-- Query 142 (User 42)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 266 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 143 (User 43)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 298 AND 420 GROUP BY c.customer_id, c.customer_name;

-- Query 144 (User 44)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 16 GROUP BY status;

-- Query 145 (User 45)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 36 AND category_id = 3 ORDER BY stock_quantity;

-- Query 146 (User 46)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 288 GROUP BY status;

-- Query 147 (User 47)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 148 (User 48)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 5 ORDER BY stock_quantity;

-- Query 149 (User 49)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 275 GROUP BY status;

-- Query 150 (User 50)
-- Think Time: 0.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 3 ORDER BY stock_quantity;

-- Query 151 (User 1)
-- Think Time: 0.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 202 GROUP BY status;

-- Query 152 (User 2)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 5 ORDER BY stock_quantity;

-- Query 153 (User 3)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 676;

-- Query 154 (User 4)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 155 (User 5)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 156 (User 6)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 3 ORDER BY stock_quantity;

-- Query 157 (User 7)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 167 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 158 (User 8)
-- Think Time: 0.38s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 153 GROUP BY status;

-- Query 159 (User 9)
-- Think Time: 0.42s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 3 ORDER BY stock_quantity;

-- Query 160 (User 10)
-- Think Time: 0.47s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 336 GROUP BY status;

-- Query 161 (User 11)
-- Think Time: 0.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 125 GROUP BY status;

-- Query 162 (User 12)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 494 GROUP BY status;

-- Query 163 (User 13)
-- Think Time: 0.50s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 294 GROUP BY status;

-- Query 164 (User 14)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 4 ORDER BY stock_quantity;

-- Query 165 (User 15)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 2 ORDER BY stock_quantity;

-- Query 166 (User 16)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 313 GROUP BY status;

-- Query 167 (User 17)
-- Think Time: 0.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 168 (User 18)
-- Think Time: 0.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 614;

-- Query 169 (User 19)
-- Think Time: 0.27s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 113 GROUP BY status;

-- Query 170 (User 20)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 820;

-- Query 171 (User 21)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 796;

-- Query 172 (User 22)
-- Think Time: 0.37s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 573;

-- Query 173 (User 23)
-- Think Time: 0.47s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 38 GROUP BY status;

-- Query 174 (User 24)
-- Think Time: 0.37s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 175 (User 25)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 405;

-- Query 176 (User 26)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 132;

-- Query 177 (User 27)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 5 ORDER BY stock_quantity;

-- Query 178 (User 28)
-- Think Time: 0.34s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 179 (User 29)
-- Think Time: 0.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 212 GROUP BY status;

-- Query 180 (User 30)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 5 ORDER BY stock_quantity;

-- Query 181 (User 31)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 237;

-- Query 182 (User 32)
-- Think Time: 0.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 48 GROUP BY status;

-- Query 183 (User 33)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 184 (User 34)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 185 (User 35)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 51 GROUP BY status;

-- Query 186 (User 36)
-- Think Time: 0.33s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 9 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 187 (User 37)
-- Think Time: 0.17s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 282 AND 484 GROUP BY c.customer_id, c.customer_name;

-- Query 188 (User 38)
-- Think Time: 0.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 240;

-- Query 189 (User 39)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 363 AND 420 GROUP BY c.customer_id, c.customer_name;

-- Query 190 (User 40)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 1 ORDER BY stock_quantity;

-- Query 191 (User 41)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 270 AND 433 GROUP BY c.customer_id, c.customer_name;

-- Query 192 (User 42)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 193 (User 43)
-- Think Time: 0.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 462 GROUP BY status;

-- Query 194 (User 44)
-- Think Time: 0.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 346;

-- Query 195 (User 45)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 5 ORDER BY stock_quantity;

-- Query 196 (User 46)
-- Think Time: 0.48s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 16 GROUP BY status;

-- Query 197 (User 47)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 2 ORDER BY stock_quantity;

-- Query 198 (User 48)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 163 AND 447 GROUP BY c.customer_id, c.customer_name;

-- Query 199 (User 49)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 4 ORDER BY stock_quantity;

-- Query 200 (User 50)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 4 ORDER BY stock_quantity;

-- Query 201 (User 1)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 86 AND 456 GROUP BY c.customer_id, c.customer_name;

-- Query 202 (User 2)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 55 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 203 (User 3)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 165 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 204 (User 4)
-- Think Time: 0.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 127;

-- Query 205 (User 5)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 206 (User 6)
-- Think Time: 0.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 1 ORDER BY stock_quantity;

-- Query 207 (User 7)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 762;

-- Query 208 (User 8)
-- Think Time: 0.41s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 262 GROUP BY status;

-- Query 209 (User 9)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 456;

-- Query 210 (User 10)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 2 ORDER BY stock_quantity;

-- Query 211 (User 11)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 90 GROUP BY status;

-- Query 212 (User 12)
-- Think Time: 0.10s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 328 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 213 (User 13)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 143 AND 497 GROUP BY c.customer_id, c.customer_name;

-- Query 214 (User 14)
-- Think Time: 0.43s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 5 ORDER BY stock_quantity;

-- Query 215 (User 15)
-- Think Time: 0.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 61 GROUP BY status;

-- Query 216 (User 16)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 5 ORDER BY stock_quantity;

-- Query 217 (User 17)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 70 GROUP BY status;

-- Query 218 (User 18)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 4 ORDER BY stock_quantity;

-- Query 219 (User 19)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 290 AND 496 GROUP BY c.customer_id, c.customer_name;

-- Query 220 (User 20)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 221 (User 21)
-- Think Time: 0.42s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 222 (User 22)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 238;

-- Query 223 (User 23)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 1 ORDER BY stock_quantity;

-- Query 224 (User 24)
-- Think Time: 0.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 207 GROUP BY status;

-- Query 225 (User 25)
-- Think Time: 0.23s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 226 (User 26)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 404 GROUP BY status;

-- Query 227 (User 27)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 234 AND 401 GROUP BY c.customer_id, c.customer_name;

-- Query 228 (User 28)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 229 (User 29)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 40 AND 417 GROUP BY c.customer_id, c.customer_name;

-- Query 230 (User 30)
-- Think Time: 0.50s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 1 ORDER BY stock_quantity;

-- Query 231 (User 31)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 272 AND 473 GROUP BY c.customer_id, c.customer_name;

-- Query 232 (User 32)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 34 AND category_id = 2 ORDER BY stock_quantity;

-- Query 233 (User 33)
-- Think Time: 0.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 308 AND 477 GROUP BY c.customer_id, c.customer_name;

-- Query 234 (User 34)
-- Think Time: 0.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 3 ORDER BY stock_quantity;

-- Query 235 (User 35)
-- Think Time: 0.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 236 (User 36)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 237 (User 37)
-- Think Time: 0.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 500;

-- Query 238 (User 38)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 239 (User 39)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 7 AND 491 GROUP BY c.customer_id, c.customer_name;

-- Query 240 (User 40)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 269 GROUP BY status;

-- Query 241 (User 41)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 350;

-- Query 242 (User 42)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 380 GROUP BY status;

-- Query 243 (User 43)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 244 (User 44)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 150 GROUP BY status;

-- Query 245 (User 45)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 36 AND category_id = 2 ORDER BY stock_quantity;

-- Query 246 (User 46)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 106 GROUP BY status;

-- Query 247 (User 47)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 248 (User 48)
-- Think Time: 0.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 425;

-- Query 249 (User 49)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 104 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 250 (User 50)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 158 AND 460 GROUP BY c.customer_id, c.customer_name;

-- Query 251 (User 1)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 420 GROUP BY status;

-- Query 252 (User 2)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 1 ORDER BY stock_quantity;

-- Query 253 (User 3)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 151;

-- Query 254 (User 4)
-- Think Time: 0.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 386;

-- Query 255 (User 5)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 315 AND 480 GROUP BY c.customer_id, c.customer_name;

-- Query 256 (User 6)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 128 AND 481 GROUP BY c.customer_id, c.customer_name;

-- Query 257 (User 7)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 459 GROUP BY status;

-- Query 258 (User 8)
-- Think Time: 0.34s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 259 (User 9)
-- Think Time: 0.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 289 GROUP BY status;

-- Query 260 (User 10)
-- Think Time: 0.47s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 261 (User 11)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 434 GROUP BY status;

-- Query 262 (User 12)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 263 (User 13)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 686;

-- Query 264 (User 14)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 179;

-- Query 265 (User 15)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 454 GROUP BY status;

-- Query 266 (User 16)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 376 GROUP BY status;

-- Query 267 (User 17)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 5 ORDER BY stock_quantity;

-- Query 268 (User 18)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 269 (User 19)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 2 ORDER BY stock_quantity;

-- Query 270 (User 20)
-- Think Time: 0.29s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 271 (User 21)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 272 (User 22)
-- Think Time: 0.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 375;

-- Query 273 (User 23)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 44 AND 486 GROUP BY c.customer_id, c.customer_name;

-- Query 274 (User 24)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 5 ORDER BY stock_quantity;

-- Query 275 (User 25)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 2 ORDER BY stock_quantity;

-- Query 276 (User 26)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 277 (User 27)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 1 ORDER BY stock_quantity;

-- Query 278 (User 28)
-- Think Time: 0.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 312 GROUP BY status;

-- Query 279 (User 29)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 1 ORDER BY stock_quantity;

-- Query 280 (User 30)
-- Think Time: 0.40s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 36 AND category_id = 1 ORDER BY stock_quantity;

-- Query 281 (User 31)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 129;

-- Query 282 (User 32)
-- Think Time: 0.47s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 128 AND 405 GROUP BY c.customer_id, c.customer_name;

-- Query 283 (User 33)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 284 (User 34)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 285 (User 35)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 5 ORDER BY stock_quantity;

-- Query 286 (User 36)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 112 GROUP BY status;

-- Query 287 (User 37)
-- Think Time: 0.44s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 351 GROUP BY status;

-- Query 288 (User 38)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 413 GROUP BY status;

-- Query 289 (User 39)
-- Think Time: 0.37s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 363 GROUP BY status;

-- Query 290 (User 40)
-- Think Time: 0.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 3 ORDER BY stock_quantity;

-- Query 291 (User 41)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 336 AND 412 GROUP BY c.customer_id, c.customer_name;

-- Query 292 (User 42)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 293 (User 43)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 1 ORDER BY stock_quantity;

-- Query 294 (User 44)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 325 AND 408 GROUP BY c.customer_id, c.customer_name;

-- Query 295 (User 45)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 4 ORDER BY stock_quantity;

-- Query 296 (User 46)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 297 (User 47)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 5 ORDER BY stock_quantity;

-- Query 298 (User 48)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 1 ORDER BY stock_quantity;

-- Query 299 (User 49)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 300 (User 50)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 4 ORDER BY stock_quantity;

-- Query 301 (User 1)
-- Think Time: 0.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 262 GROUP BY status;

-- Query 302 (User 2)
-- Think Time: 0.19s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 83 GROUP BY status;

-- Query 303 (User 3)
-- Think Time: 0.46s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 304 (User 4)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 152 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 305 (User 5)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 306 (User 6)
-- Think Time: 0.15s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 428 GROUP BY status;

-- Query 307 (User 7)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 308 (User 8)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 250 AND 415 GROUP BY c.customer_id, c.customer_name;

-- Query 309 (User 9)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 593;

-- Query 310 (User 10)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 2 ORDER BY stock_quantity;

-- Query 311 (User 11)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 143 AND 407 GROUP BY c.customer_id, c.customer_name;

-- Query 312 (User 12)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 36 AND category_id = 4 ORDER BY stock_quantity;

-- Query 313 (User 13)
-- Think Time: 0.35s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 885;

-- Query 314 (User 14)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 3 ORDER BY stock_quantity;

-- Query 315 (User 15)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 316 (User 16)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 56 AND 497 GROUP BY c.customer_id, c.customer_name;

-- Query 317 (User 17)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 1 ORDER BY stock_quantity;

-- Query 318 (User 18)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 199 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 319 (User 19)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 212 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 320 (User 20)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 366 AND 438 GROUP BY c.customer_id, c.customer_name;

-- Query 321 (User 21)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 383 GROUP BY status;

-- Query 322 (User 22)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 323 (User 23)
-- Think Time: 0.37s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 381 GROUP BY status;

-- Query 324 (User 24)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 4 ORDER BY stock_quantity;

-- Query 325 (User 25)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 626;

-- Query 326 (User 26)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 327 (User 27)
-- Think Time: 0.19s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 155 GROUP BY status;

-- Query 328 (User 28)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 35 AND 465 GROUP BY c.customer_id, c.customer_name;

-- Query 329 (User 29)
-- Think Time: 0.47s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 422 GROUP BY status;

-- Query 330 (User 30)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 350 AND 442 GROUP BY c.customer_id, c.customer_name;

-- Query 331 (User 31)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 4 ORDER BY stock_quantity;

-- Query 332 (User 32)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 333 (User 33)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 334 (User 34)
-- Think Time: 0.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 162 GROUP BY status;

-- Query 335 (User 35)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 490;

-- Query 336 (User 36)
-- Think Time: 0.25s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 337 (User 37)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 338 (User 38)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 95 GROUP BY status;

-- Query 339 (User 39)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 340 (User 40)
-- Think Time: 0.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 318 GROUP BY status;

-- Query 341 (User 41)
-- Think Time: 0.40s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 491 GROUP BY status;

-- Query 342 (User 42)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 38 AND category_id = 3 ORDER BY stock_quantity;

-- Query 343 (User 43)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 344 (User 44)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 474;

-- Query 345 (User 45)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 800;

-- Query 346 (User 46)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 879;

-- Query 347 (User 47)
-- Think Time: 0.23s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 348 (User 48)
-- Think Time: 0.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 179;

-- Query 349 (User 49)
-- Think Time: 0.19s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 2 ORDER BY stock_quantity;

-- Query 350 (User 50)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 216;

-- Query 351 (User 1)
-- Think Time: 0.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 4 ORDER BY stock_quantity;

-- Query 352 (User 2)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 86 AND 434 GROUP BY c.customer_id, c.customer_name;

-- Query 353 (User 3)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 311 AND 461 GROUP BY c.customer_id, c.customer_name;

-- Query 354 (User 4)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 303 GROUP BY status;

-- Query 355 (User 5)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 195;

-- Query 356 (User 6)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 277 AND 401 GROUP BY c.customer_id, c.customer_name;

-- Query 357 (User 7)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 4 ORDER BY stock_quantity;

-- Query 358 (User 8)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 804;

-- Query 359 (User 9)
-- Think Time: 0.40s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 3 ORDER BY stock_quantity;

-- Query 360 (User 10)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 5 ORDER BY stock_quantity;

-- Query 361 (User 11)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 362 (User 12)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 326 AND 401 GROUP BY c.customer_id, c.customer_name;

-- Query 363 (User 13)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 364 (User 14)
-- Think Time: 0.36s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 344;

-- Query 365 (User 15)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 142 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 366 (User 16)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 367 (User 17)
-- Think Time: 0.38s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 5 ORDER BY stock_quantity;

-- Query 368 (User 18)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 5 ORDER BY stock_quantity;

-- Query 369 (User 19)
-- Think Time: 0.43s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 453 GROUP BY c.customer_id, c.customer_name;

-- Query 370 (User 20)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 371 (User 21)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 136 AND 427 GROUP BY c.customer_id, c.customer_name;

-- Query 372 (User 22)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 5 ORDER BY stock_quantity;

-- Query 373 (User 23)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 614;

-- Query 374 (User 24)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 62 AND 490 GROUP BY c.customer_id, c.customer_name;

-- Query 375 (User 25)
-- Think Time: 0.27s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 491 GROUP BY status;

-- Query 376 (User 26)
-- Think Time: 0.32s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 68 GROUP BY status;

-- Query 377 (User 27)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 36 AND category_id = 2 ORDER BY stock_quantity;

-- Query 378 (User 28)
-- Think Time: 0.28s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 3 ORDER BY stock_quantity;

-- Query 379 (User 29)
-- Think Time: 0.33s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 177 GROUP BY status;

-- Query 380 (User 30)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 393;

-- Query 381 (User 31)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 328 AND 444 GROUP BY c.customer_id, c.customer_name;

-- Query 382 (User 32)
-- Think Time: 0.44s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 400 GROUP BY status;

-- Query 383 (User 33)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 339 AND 433 GROUP BY c.customer_id, c.customer_name;

-- Query 384 (User 34)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 5 ORDER BY stock_quantity;

-- Query 385 (User 35)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 270 AND 422 GROUP BY c.customer_id, c.customer_name;

-- Query 386 (User 36)
-- Think Time: 0.46s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 417;

-- Query 387 (User 37)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 5 ORDER BY stock_quantity;

-- Query 388 (User 38)
-- Think Time: 0.32s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 154 GROUP BY status;

-- Query 389 (User 39)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 288 AND 456 GROUP BY c.customer_id, c.customer_name;

-- Query 390 (User 40)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 286;

-- Query 391 (User 41)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 392 (User 42)
-- Think Time: 0.41s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 47 GROUP BY status;

-- Query 393 (User 43)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 3 ORDER BY stock_quantity;

-- Query 394 (User 44)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 196 AND 402 GROUP BY c.customer_id, c.customer_name;

-- Query 395 (User 45)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 200 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 396 (User 46)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 223 GROUP BY status;

-- Query 397 (User 47)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 398 (User 48)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 399 (User 49)
-- Think Time: 0.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 400 (User 50)
-- Think Time: 0.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 402;

-- Query 401 (User 1)
-- Think Time: 0.23s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 344;

-- Query 402 (User 2)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 403 (User 3)
-- Think Time: 0.30s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 404 (User 4)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 579;

-- Query 405 (User 5)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 406 (User 6)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 50 AND 413 GROUP BY c.customer_id, c.customer_name;

-- Query 407 (User 7)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 663;

-- Query 408 (User 8)
-- Think Time: 0.43s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 282 GROUP BY status;

-- Query 409 (User 9)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 393 GROUP BY status;

-- Query 410 (User 10)
-- Think Time: 0.47s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 411 (User 11)
-- Think Time: 0.19s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 355;

-- Query 412 (User 12)
-- Think Time: 0.33s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 40 GROUP BY status;

-- Query 413 (User 13)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 414 (User 14)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 6 AND 482 GROUP BY c.customer_id, c.customer_name;

-- Query 415 (User 15)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 26 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 416 (User 16)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 173 AND 411 GROUP BY c.customer_id, c.customer_name;

-- Query 417 (User 17)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 247 AND 472 GROUP BY c.customer_id, c.customer_name;

-- Query 418 (User 18)
-- Think Time: 0.41s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 188 GROUP BY status;

-- Query 419 (User 19)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 316 AND 457 GROUP BY c.customer_id, c.customer_name;

-- Query 420 (User 20)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 421 (User 21)
-- Think Time: 0.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 280 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 422 (User 22)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 168;

-- Query 423 (User 23)
-- Think Time: 0.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 195 GROUP BY status;

-- Query 424 (User 24)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 235 AND 472 GROUP BY c.customer_id, c.customer_name;

-- Query 425 (User 25)
-- Think Time: 0.19s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 416 GROUP BY status;

-- Query 426 (User 26)
-- Think Time: 0.27s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 492 GROUP BY status;

-- Query 427 (User 27)
-- Think Time: 0.38s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 335 GROUP BY status;

-- Query 428 (User 28)
-- Think Time: 0.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 425;

-- Query 429 (User 29)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 392 AND 441 GROUP BY c.customer_id, c.customer_name;

-- Query 430 (User 30)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 431 (User 31)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 34 AND category_id = 2 ORDER BY stock_quantity;

-- Query 432 (User 32)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 433 (User 33)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 208 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 434 (User 34)
-- Think Time: 0.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 671;

-- Query 435 (User 35)
-- Think Time: 0.46s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 436 (User 36)
-- Think Time: 0.28s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 4 ORDER BY stock_quantity;

-- Query 437 (User 37)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 303 AND 492 GROUP BY c.customer_id, c.customer_name;

-- Query 438 (User 38)
-- Think Time: 0.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 3 ORDER BY stock_quantity;

-- Query 439 (User 39)
-- Think Time: 0.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 394 GROUP BY status;

-- Query 440 (User 40)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 441 (User 41)
-- Think Time: 0.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 670;

-- Query 442 (User 42)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 95 AND 419 GROUP BY c.customer_id, c.customer_name;

-- Query 443 (User 43)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 345 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 444 (User 44)
-- Think Time: 0.31s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 34 GROUP BY status;

-- Query 445 (User 45)
-- Think Time: 0.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 719;

-- Query 446 (User 46)
-- Think Time: 0.39s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 320 GROUP BY status;

-- Query 447 (User 47)
-- Think Time: 0.42s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 4 ORDER BY stock_quantity;

-- Query 448 (User 48)
-- Think Time: 0.22s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 4 ORDER BY stock_quantity;

-- Query 449 (User 49)
-- Think Time: 0.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 446;

-- Query 450 (User 50)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 4 ORDER BY stock_quantity;

-- Query 451 (User 1)
-- Think Time: 0.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 387;

-- Query 452 (User 2)
-- Think Time: 0.38s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 200 GROUP BY status;

-- Query 453 (User 3)
-- Think Time: 0.41s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 425 GROUP BY status;

-- Query 454 (User 4)
-- Think Time: 0.23s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 228 AND 465 GROUP BY c.customer_id, c.customer_name;

-- Query 455 (User 5)
-- Think Time: 0.45s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 456 (User 6)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 296 GROUP BY status;

-- Query 457 (User 7)
-- Think Time: 0.32s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 141 GROUP BY status;

-- Query 458 (User 8)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 37 GROUP BY status;

-- Query 459 (User 9)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 460 (User 10)
-- Think Time: 0.41s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 827;

-- Query 461 (User 11)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 2 ORDER BY stock_quantity;

-- Query 462 (User 12)
-- Think Time: 0.23s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 463 (User 13)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 464 (User 14)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 598;

-- Query 465 (User 15)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 435;

-- Query 466 (User 16)
-- Think Time: 0.35s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 467 (User 17)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 468 (User 18)
-- Think Time: 0.27s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 340;

-- Query 469 (User 19)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 242;

-- Query 470 (User 20)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 3 ORDER BY stock_quantity;

-- Query 471 (User 21)
-- Think Time: 0.43s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 71 AND 483 GROUP BY c.customer_id, c.customer_name;

-- Query 472 (User 22)
-- Think Time: 0.47s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 3 ORDER BY stock_quantity;

-- Query 473 (User 23)
-- Think Time: 0.39s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 847;

-- Query 474 (User 24)
-- Think Time: 0.22s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 126 GROUP BY status;

-- Query 475 (User 25)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 476 (User 26)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 739;

-- Query 477 (User 27)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 1 ORDER BY stock_quantity;

-- Query 478 (User 28)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 186;

-- Query 479 (User 29)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 453;

-- Query 480 (User 30)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 155 GROUP BY status;

-- Query 481 (User 31)
-- Think Time: 0.48s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 196 GROUP BY status;

-- Query 482 (User 32)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 5 ORDER BY stock_quantity;

-- Query 483 (User 33)
-- Think Time: 0.31s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 200;

-- Query 484 (User 34)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 3 ORDER BY stock_quantity;

-- Query 485 (User 35)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 486 (User 36)
-- Think Time: 0.20s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 487 (User 37)
-- Think Time: 0.27s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 202 GROUP BY status;

-- Query 488 (User 38)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 609;

-- Query 489 (User 39)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 490 (User 40)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 491 (User 41)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 492 (User 42)
-- Think Time: 0.30s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 493 (User 43)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 494 (User 44)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 235 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 495 (User 45)
-- Think Time: 0.43s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 5 ORDER BY stock_quantity;

-- Query 496 (User 46)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 497 (User 47)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 272;

-- Query 498 (User 48)
-- Think Time: 0.13s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 598;

-- Query 499 (User 49)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 500 (User 50)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 501 (User 1)
-- Think Time: 0.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 61 AND 468 GROUP BY c.customer_id, c.customer_name;

-- Query 502 (User 2)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 503 (User 3)
-- Think Time: 0.31s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 380 GROUP BY status;

-- Query 504 (User 4)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 505 (User 5)
-- Think Time: 0.17s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 103 AND 449 GROUP BY c.customer_id, c.customer_name;

-- Query 506 (User 6)
-- Think Time: 0.12s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 500 GROUP BY status;

-- Query 507 (User 7)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 239 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 508 (User 8)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 211 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 509 (User 9)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 5 ORDER BY stock_quantity;

-- Query 510 (User 10)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 4 ORDER BY stock_quantity;

-- Query 511 (User 11)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 157 GROUP BY status;

-- Query 512 (User 12)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 2 ORDER BY stock_quantity;

-- Query 513 (User 13)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 3 ORDER BY stock_quantity;

-- Query 514 (User 14)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 515 (User 15)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 59 AND 484 GROUP BY c.customer_id, c.customer_name;

-- Query 516 (User 16)
-- Think Time: 0.35s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 517 (User 17)
-- Think Time: 0.30s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 518 (User 18)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 322 AND 403 GROUP BY c.customer_id, c.customer_name;

-- Query 519 (User 19)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 12 AND 430 GROUP BY c.customer_id, c.customer_name;

-- Query 520 (User 20)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 251;

-- Query 521 (User 21)
-- Think Time: 0.50s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 2 ORDER BY stock_quantity;

-- Query 522 (User 22)
-- Think Time: 0.32s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 559;

-- Query 523 (User 23)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 155 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 524 (User 24)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 446;

-- Query 525 (User 25)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 1 ORDER BY stock_quantity;

-- Query 526 (User 26)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 270 AND 429 GROUP BY c.customer_id, c.customer_name;

-- Query 527 (User 27)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 35 AND category_id = 3 ORDER BY stock_quantity;

-- Query 528 (User 28)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 455 GROUP BY status;

-- Query 529 (User 29)
-- Think Time: 0.25s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 4 ORDER BY stock_quantity;

-- Query 530 (User 30)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 531 (User 31)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 532 (User 32)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 1 ORDER BY stock_quantity;

-- Query 533 (User 33)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 352 GROUP BY status;

-- Query 534 (User 34)
-- Think Time: 0.35s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 450 GROUP BY status;

-- Query 535 (User 35)
-- Think Time: 0.17s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 264 GROUP BY status;

-- Query 536 (User 36)
-- Think Time: 0.25s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 274 GROUP BY status;

-- Query 537 (User 37)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 4 ORDER BY stock_quantity;

-- Query 538 (User 38)
-- Think Time: 0.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 242;

-- Query 539 (User 39)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 332;

-- Query 540 (User 40)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 41 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 541 (User 41)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 716;

-- Query 542 (User 42)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 344 AND 445 GROUP BY c.customer_id, c.customer_name;

-- Query 543 (User 43)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 292 AND 409 GROUP BY c.customer_id, c.customer_name;

-- Query 544 (User 44)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 545 (User 45)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 58 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 546 (User 46)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 547 (User 47)
-- Think Time: 0.37s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 548 (User 48)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 549 (User 49)
-- Think Time: 0.29s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 1 ORDER BY stock_quantity;

-- Query 550 (User 50)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 237;

-- Query 551 (User 1)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 552 (User 2)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 882;

-- Query 553 (User 3)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 1 ORDER BY stock_quantity;

-- Query 554 (User 4)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 2 ORDER BY stock_quantity;

-- Query 555 (User 5)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 704;

-- Query 556 (User 6)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 195 GROUP BY status;

-- Query 557 (User 7)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 332 AND 440 GROUP BY c.customer_id, c.customer_name;

-- Query 558 (User 8)
-- Think Time: 0.33s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 5 ORDER BY stock_quantity;

-- Query 559 (User 9)
-- Think Time: 0.35s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 1 ORDER BY stock_quantity;

-- Query 560 (User 10)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 561 (User 11)
-- Think Time: 0.42s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 562 (User 12)
-- Think Time: 0.31s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 5 ORDER BY stock_quantity;

-- Query 563 (User 13)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 256 AND 428 GROUP BY c.customer_id, c.customer_name;

-- Query 564 (User 14)
-- Think Time: 0.43s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 211 GROUP BY status;

-- Query 565 (User 15)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 352 AND 477 GROUP BY c.customer_id, c.customer_name;

-- Query 566 (User 16)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 4 ORDER BY stock_quantity;

-- Query 567 (User 17)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 1 ORDER BY stock_quantity;

-- Query 568 (User 18)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 58 AND 474 GROUP BY c.customer_id, c.customer_name;

-- Query 569 (User 19)
-- Think Time: 0.20s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 112 GROUP BY status;

-- Query 570 (User 20)
-- Think Time: 0.39s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 586;

-- Query 571 (User 21)
-- Think Time: 0.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 470 GROUP BY status;

-- Query 572 (User 22)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 573 (User 23)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 324 AND 441 GROUP BY c.customer_id, c.customer_name;

-- Query 574 (User 24)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 34 GROUP BY status;

-- Query 575 (User 25)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 576 (User 26)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 388;

-- Query 577 (User 27)
-- Think Time: 0.38s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 3 ORDER BY stock_quantity;

-- Query 578 (User 28)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 206 AND 480 GROUP BY c.customer_id, c.customer_name;

-- Query 579 (User 29)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 4 ORDER BY stock_quantity;

-- Query 580 (User 30)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 111 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 581 (User 31)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 299 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 582 (User 32)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 5 ORDER BY stock_quantity;

-- Query 583 (User 33)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 694;

-- Query 584 (User 34)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 253 AND 444 GROUP BY c.customer_id, c.customer_name;

-- Query 585 (User 35)
-- Think Time: 0.50s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 3 ORDER BY stock_quantity;

-- Query 586 (User 36)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 337 AND 482 GROUP BY c.customer_id, c.customer_name;

-- Query 587 (User 37)
-- Think Time: 0.24s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 1 ORDER BY stock_quantity;

-- Query 588 (User 38)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 93 AND 422 GROUP BY c.customer_id, c.customer_name;

-- Query 589 (User 39)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 590 (User 40)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 42 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 591 (User 41)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 166 GROUP BY status;

-- Query 592 (User 42)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 395 AND 452 GROUP BY c.customer_id, c.customer_name;

-- Query 593 (User 43)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 4 ORDER BY stock_quantity;

-- Query 594 (User 44)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 3 ORDER BY stock_quantity;

-- Query 595 (User 45)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 270 GROUP BY status;

-- Query 596 (User 46)
-- Think Time: 0.14s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 3 ORDER BY stock_quantity;

-- Query 597 (User 47)
-- Think Time: 0.40s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 4 ORDER BY stock_quantity;

-- Query 598 (User 48)
-- Think Time: 0.42s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 2 ORDER BY stock_quantity;

-- Query 599 (User 49)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 447 GROUP BY status;

-- Query 600 (User 50)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 4 ORDER BY stock_quantity;

-- Query 601 (User 1)
-- Think Time: 0.16s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 418 GROUP BY status;

-- Query 602 (User 2)
-- Think Time: 0.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 321 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 603 (User 3)
-- Think Time: 0.35s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 4 ORDER BY stock_quantity;

-- Query 604 (User 4)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 4 ORDER BY stock_quantity;

-- Query 605 (User 5)
-- Think Time: 0.15s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 30 AND category_id = 2 ORDER BY stock_quantity;

-- Query 606 (User 6)
-- Think Time: 0.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 324;

-- Query 607 (User 7)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 371 GROUP BY status;

-- Query 608 (User 8)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 609 (User 9)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 610 (User 10)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 785;

-- Query 611 (User 11)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 612 (User 12)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 81 AND 494 GROUP BY c.customer_id, c.customer_name;

-- Query 613 (User 13)
-- Think Time: 0.35s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 1 ORDER BY stock_quantity;

-- Query 614 (User 14)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 386 AND 497 GROUP BY c.customer_id, c.customer_name;

-- Query 615 (User 15)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 2 ORDER BY stock_quantity;

-- Query 616 (User 16)
-- Think Time: 0.10s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 617 (User 17)
-- Think Time: 0.38s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 330 GROUP BY status;

-- Query 618 (User 18)
-- Think Time: 0.32s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 2 ORDER BY stock_quantity;

-- Query 619 (User 19)
-- Think Time: 0.27s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 843;

-- Query 620 (User 20)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 559;

-- Query 621 (User 21)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 622 (User 22)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 200;

-- Query 623 (User 23)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 4 ORDER BY stock_quantity;

-- Query 624 (User 24)
-- Think Time: 0.29s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 230;

-- Query 625 (User 25)
-- Think Time: 0.47s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 39 AND category_id = 2 ORDER BY stock_quantity;

-- Query 626 (User 26)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 627 (User 27)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 1 ORDER BY stock_quantity;

-- Query 628 (User 28)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 720;

-- Query 629 (User 29)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 326 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 630 (User 30)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 174 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 631 (User 31)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 99 GROUP BY status;

-- Query 632 (User 32)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 633 (User 33)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 634 (User 34)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 158 GROUP BY status;

-- Query 635 (User 35)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 636 (User 36)
-- Think Time: 0.13s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 516;

-- Query 637 (User 37)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 638 (User 38)
-- Think Time: 0.48s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 105 GROUP BY status;

-- Query 639 (User 39)
-- Think Time: 0.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 356;

-- Query 640 (User 40)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 3 ORDER BY stock_quantity;

-- Query 641 (User 41)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 642 (User 42)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 3 ORDER BY stock_quantity;

-- Query 643 (User 43)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 644 (User 44)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 645 (User 45)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 389 AND 436 GROUP BY c.customer_id, c.customer_name;

-- Query 646 (User 46)
-- Think Time: 0.30s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 647 (User 47)
-- Think Time: 0.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 365;

-- Query 648 (User 48)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 374 AND 436 GROUP BY c.customer_id, c.customer_name;

-- Query 649 (User 49)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 650 (User 50)
-- Think Time: 0.48s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 100 GROUP BY status;

-- Query 651 (User 1)
-- Think Time: 0.47s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 85 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 652 (User 2)
-- Think Time: 0.28s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 421 GROUP BY status;

-- Query 653 (User 3)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 654 (User 4)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 34 AND category_id = 1 ORDER BY stock_quantity;

-- Query 655 (User 5)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 701;

-- Query 656 (User 6)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 657 (User 7)
-- Think Time: 0.33s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 2 ORDER BY stock_quantity;

-- Query 658 (User 8)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 248;

-- Query 659 (User 9)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 587;

-- Query 660 (User 10)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 29 AND category_id = 5 ORDER BY stock_quantity;

-- Query 661 (User 11)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 662 (User 12)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 663 (User 13)
-- Think Time: 0.44s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 664 (User 14)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 665 (User 15)
-- Think Time: 0.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 811;

-- Query 666 (User 16)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 744;

-- Query 667 (User 17)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 300 AND 463 GROUP BY c.customer_id, c.customer_name;

-- Query 668 (User 18)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 40 AND category_id = 5 ORDER BY stock_quantity;

-- Query 669 (User 19)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 483;

-- Query 670 (User 20)
-- Think Time: 0.27s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 671 (User 21)
-- Think Time: 0.24s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 11 AND category_id = 4 ORDER BY stock_quantity;

-- Query 672 (User 22)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 673 (User 23)
-- Think Time: 0.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 101 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 674 (User 24)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 675 (User 25)
-- Think Time: 0.23s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 2 ORDER BY stock_quantity;

-- Query 676 (User 26)
-- Think Time: 0.48s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 395 AND 490 GROUP BY c.customer_id, c.customer_name;

-- Query 677 (User 27)
-- Think Time: 0.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 678 (User 28)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 679 (User 29)
-- Think Time: 0.11s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 56 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 680 (User 30)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 565;

-- Query 681 (User 31)
-- Think Time: 0.48s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 498;

-- Query 682 (User 32)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 106 AND 440 GROUP BY c.customer_id, c.customer_name;

-- Query 683 (User 33)
-- Think Time: 0.33s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 310 GROUP BY status;

-- Query 684 (User 34)
-- Think Time: 0.28s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 685 (User 35)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 49 AND 451 GROUP BY c.customer_id, c.customer_name;

-- Query 686 (User 36)
-- Think Time: 0.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 211 AND 498 GROUP BY c.customer_id, c.customer_name;

-- Query 687 (User 37)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 688 (User 38)
-- Think Time: 0.43s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 344 AND 496 GROUP BY c.customer_id, c.customer_name;

-- Query 689 (User 39)
-- Think Time: 0.10s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 10 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 690 (User 40)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 18 GROUP BY status;

-- Query 691 (User 41)
-- Think Time: 0.46s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 692 (User 42)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 9 AND 454 GROUP BY c.customer_id, c.customer_name;

-- Query 693 (User 43)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 694 (User 44)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 695 (User 45)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 275;

-- Query 696 (User 46)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 697 (User 47)
-- Think Time: 0.19s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 1 ORDER BY stock_quantity;

-- Query 698 (User 48)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 306;

-- Query 699 (User 49)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 122 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 700 (User 50)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 23 AND category_id = 3 ORDER BY stock_quantity;

-- Query 701 (User 1)
-- Think Time: 0.50s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 749;

-- Query 702 (User 2)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 47 AND 423 GROUP BY c.customer_id, c.customer_name;

-- Query 703 (User 3)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 91 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 704 (User 4)
-- Think Time: 0.44s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 226 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 705 (User 5)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 195 GROUP BY status;

-- Query 706 (User 6)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 3 GROUP BY status;

-- Query 707 (User 7)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 4 ORDER BY stock_quantity;

-- Query 708 (User 8)
-- Think Time: 0.47s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 3 ORDER BY stock_quantity;

-- Query 709 (User 9)
-- Think Time: 0.16s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 245 AND 405 GROUP BY c.customer_id, c.customer_name;

-- Query 710 (User 10)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 297 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 711 (User 11)
-- Think Time: 0.40s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 85 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 712 (User 12)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 713 (User 13)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 714 (User 14)
-- Think Time: 0.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 94 AND 465 GROUP BY c.customer_id, c.customer_name;

-- Query 715 (User 15)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 28 AND category_id = 4 ORDER BY stock_quantity;

-- Query 716 (User 16)
-- Think Time: 0.18s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 249 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 717 (User 17)
-- Think Time: 0.50s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 718 (User 18)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 341 AND 452 GROUP BY c.customer_id, c.customer_name;

-- Query 719 (User 19)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 309 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 720 (User 20)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 327 AND 442 GROUP BY c.customer_id, c.customer_name;

-- Query 721 (User 21)
-- Think Time: 0.41s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 685;

-- Query 722 (User 22)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 653;

-- Query 723 (User 23)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 386 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 724 (User 24)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 1 ORDER BY stock_quantity;

-- Query 725 (User 25)
-- Think Time: 0.14s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 4 ORDER BY stock_quantity;

-- Query 726 (User 26)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 418;

-- Query 727 (User 27)
-- Think Time: 0.44s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 651;

-- Query 728 (User 28)
-- Think Time: 0.50s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 308 GROUP BY status;

-- Query 729 (User 29)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 730 (User 30)
-- Think Time: 0.29s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 398 AND 423 GROUP BY c.customer_id, c.customer_name;

-- Query 731 (User 31)
-- Think Time: 0.40s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 357 GROUP BY status;

-- Query 732 (User 32)
-- Think Time: 0.42s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 323;

-- Query 733 (User 33)
-- Think Time: 0.24s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 186 AND 493 GROUP BY c.customer_id, c.customer_name;

-- Query 734 (User 34)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 2 ORDER BY stock_quantity;

-- Query 735 (User 35)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 408 GROUP BY status;

-- Query 736 (User 36)
-- Think Time: 0.21s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 329 GROUP BY status;

-- Query 737 (User 37)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 738 (User 38)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 739 (User 39)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 740 (User 40)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 354;

-- Query 741 (User 41)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 314;

-- Query 742 (User 42)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 743 (User 43)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 20 AND category_id = 1 ORDER BY stock_quantity;

-- Query 744 (User 44)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 105 AND 410 GROUP BY c.customer_id, c.customer_name;

-- Query 745 (User 45)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 2 ORDER BY stock_quantity;

-- Query 746 (User 46)
-- Think Time: 0.48s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 445 GROUP BY status;

-- Query 747 (User 47)
-- Think Time: 0.46s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 748 (User 48)
-- Think Time: 0.10s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 385 AND 450 GROUP BY c.customer_id, c.customer_name;

-- Query 749 (User 49)
-- Think Time: 0.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 794;

-- Query 750 (User 50)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 2 ORDER BY stock_quantity;

-- Query 751 (User 1)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 85 GROUP BY status;

-- Query 752 (User 2)
-- Think Time: 0.35s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 753 (User 3)
-- Think Time: 0.47s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 754 (User 4)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 215;

-- Query 755 (User 5)
-- Think Time: 0.19s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 393 AND 416 GROUP BY c.customer_id, c.customer_name;

-- Query 756 (User 6)
-- Think Time: 0.10s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 183 GROUP BY status;

-- Query 757 (User 7)
-- Think Time: 0.10s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 182 AND 402 GROUP BY c.customer_id, c.customer_name;

-- Query 758 (User 8)
-- Think Time: 0.16s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 220 GROUP BY status;

-- Query 759 (User 9)
-- Think Time: 0.46s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 98 GROUP BY status;

-- Query 760 (User 10)
-- Think Time: 0.39s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 246 AND 486 GROUP BY c.customer_id, c.customer_name;

-- Query 761 (User 11)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 42 AND category_id = 2 ORDER BY stock_quantity;

-- Query 762 (User 12)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 763 (User 13)
-- Think Time: 0.35s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 764 (User 14)
-- Think Time: 0.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 62 AND 417 GROUP BY c.customer_id, c.customer_name;

-- Query 765 (User 15)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 411;

-- Query 766 (User 16)
-- Think Time: 0.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 459 GROUP BY status;

-- Query 767 (User 17)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 130 GROUP BY status;

-- Query 768 (User 18)
-- Think Time: 0.33s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 315;

-- Query 769 (User 19)
-- Think Time: 0.13s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 770 (User 20)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 828;

-- Query 771 (User 21)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 713;

-- Query 772 (User 22)
-- Think Time: 0.40s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 24 AND 473 GROUP BY c.customer_id, c.customer_name;

-- Query 773 (User 23)
-- Think Time: 0.10s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 5 ORDER BY stock_quantity;

-- Query 774 (User 24)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 329;

-- Query 775 (User 25)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 21 AND 482 GROUP BY c.customer_id, c.customer_name;

-- Query 776 (User 26)
-- Think Time: 0.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 110;

-- Query 777 (User 27)
-- Think Time: 0.34s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 91 AND 433 GROUP BY c.customer_id, c.customer_name;

-- Query 778 (User 28)
-- Think Time: 0.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 113 AND 442 GROUP BY c.customer_id, c.customer_name;

-- Query 779 (User 29)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 46 AND category_id = 1 ORDER BY stock_quantity;

-- Query 780 (User 30)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 352 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 781 (User 31)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 782 (User 32)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 267;

-- Query 783 (User 33)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 2 ORDER BY stock_quantity;

-- Query 784 (User 34)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 2 ORDER BY stock_quantity;

-- Query 785 (User 35)
-- Think Time: 0.34s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 786 (User 36)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 272 AND 443 GROUP BY c.customer_id, c.customer_name;

-- Query 787 (User 37)
-- Think Time: 0.43s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 3 ORDER BY stock_quantity;

-- Query 788 (User 38)
-- Think Time: 0.29s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 789 (User 39)
-- Think Time: 0.43s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 5 ORDER BY stock_quantity;

-- Query 790 (User 40)
-- Think Time: 0.50s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 1 ORDER BY stock_quantity;

-- Query 791 (User 41)
-- Think Time: 0.49s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 792 (User 42)
-- Think Time: 0.38s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 19 AND category_id = 2 ORDER BY stock_quantity;

-- Query 793 (User 43)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 526;

-- Query 794 (User 44)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 381 AND 418 GROUP BY c.customer_id, c.customer_name;

-- Query 795 (User 45)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 796 (User 46)
-- Think Time: 0.49s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 5 ORDER BY stock_quantity;

-- Query 797 (User 47)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 206 AND 480 GROUP BY c.customer_id, c.customer_name;

-- Query 798 (User 48)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 16 AND category_id = 4 ORDER BY stock_quantity;

-- Query 799 (User 49)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 55 AND 409 GROUP BY c.customer_id, c.customer_name;

-- Query 800 (User 50)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 507;

-- Query 801 (User 1)
-- Think Time: 0.42s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 209 GROUP BY status;

-- Query 802 (User 2)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 5 ORDER BY stock_quantity;

-- Query 803 (User 3)
-- Think Time: 0.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 265 AND 494 GROUP BY c.customer_id, c.customer_name;

-- Query 804 (User 4)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 50 AND category_id = 2 ORDER BY stock_quantity;

-- Query 805 (User 5)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 806 (User 6)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 3 ORDER BY stock_quantity;

-- Query 807 (User 7)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 4 ORDER BY stock_quantity;

-- Query 808 (User 8)
-- Think Time: 0.33s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 421 GROUP BY status;

-- Query 809 (User 9)
-- Think Time: 0.39s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 810 (User 10)
-- Think Time: 0.21s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 4 ORDER BY stock_quantity;

-- Query 811 (User 11)
-- Think Time: 0.19s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 812 (User 12)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 389 AND 488 GROUP BY c.customer_id, c.customer_name;

-- Query 813 (User 13)
-- Think Time: 0.18s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 13 AND category_id = 4 ORDER BY stock_quantity;

-- Query 814 (User 14)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 32 AND category_id = 4 ORDER BY stock_quantity;

-- Query 815 (User 15)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 790;

-- Query 816 (User 16)
-- Think Time: 0.38s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 530;

-- Query 817 (User 17)
-- Think Time: 0.46s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 194 AND 428 GROUP BY c.customer_id, c.customer_name;

-- Query 818 (User 18)
-- Think Time: 0.47s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 216;

-- Query 819 (User 19)
-- Think Time: 0.35s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 820 (User 20)
-- Think Time: 0.14s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 657;

-- Query 821 (User 21)
-- Think Time: 0.44s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 5 ORDER BY stock_quantity;

-- Query 822 (User 22)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 823 (User 23)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 2 ORDER BY stock_quantity;

-- Query 824 (User 24)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 751;

-- Query 825 (User 25)
-- Think Time: 0.35s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 163 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 826 (User 26)
-- Think Time: 0.47s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 14 GROUP BY status;

-- Query 827 (User 27)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 828 (User 28)
-- Think Time: 0.45s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 693;

-- Query 829 (User 29)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 830 (User 30)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 831 (User 31)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 324 AND 478 GROUP BY c.customer_id, c.customer_name;

-- Query 832 (User 32)
-- Think Time: 0.16s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 833 (User 33)
-- Think Time: 0.31s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 834 (User 34)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 2 ORDER BY stock_quantity;

-- Query 835 (User 35)
-- Think Time: 0.46s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 4 ORDER BY stock_quantity;

-- Query 836 (User 36)
-- Think Time: 0.17s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 837 (User 37)
-- Think Time: 0.23s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 337 GROUP BY status;

-- Query 838 (User 38)
-- Think Time: 0.14s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 839 (User 39)
-- Think Time: 0.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 388 GROUP BY status;

-- Query 840 (User 40)
-- Think Time: 0.36s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 168 GROUP BY status;

-- Query 841 (User 41)
-- Think Time: 0.13s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 116;

-- Query 842 (User 42)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 843 (User 43)
-- Think Time: 0.39s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 4 ORDER BY stock_quantity;

-- Query 844 (User 44)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 46 AND 425 GROUP BY c.customer_id, c.customer_name;

-- Query 845 (User 45)
-- Think Time: 0.35s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 523;

-- Query 846 (User 46)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 847 (User 47)
-- Think Time: 0.29s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 848 (User 48)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 2 ORDER BY stock_quantity;

-- Query 849 (User 49)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 170;

-- Query 850 (User 50)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 296 AND 483 GROUP BY c.customer_id, c.customer_name;

-- Query 851 (User 1)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 32 AND category_id = 5 ORDER BY stock_quantity;

-- Query 852 (User 2)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 853 (User 3)
-- Think Time: 0.20s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 372;

-- Query 854 (User 4)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 308;

-- Query 855 (User 5)
-- Think Time: 0.37s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 258 GROUP BY status;

-- Query 856 (User 6)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 171 AND 459 GROUP BY c.customer_id, c.customer_name;

-- Query 857 (User 7)
-- Think Time: 0.50s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 858 (User 8)
-- Think Time: 0.50s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 258 AND 422 GROUP BY c.customer_id, c.customer_name;

-- Query 859 (User 9)
-- Think Time: 0.15s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 155 GROUP BY status;

-- Query 860 (User 10)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 191;

-- Query 861 (User 11)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 43 AND category_id = 1 ORDER BY stock_quantity;

-- Query 862 (User 12)
-- Think Time: 0.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 176 GROUP BY status;

-- Query 863 (User 13)
-- Think Time: 0.42s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 864 (User 14)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 865 (User 15)
-- Think Time: 0.33s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 146 AND 465 GROUP BY c.customer_id, c.customer_name;

-- Query 866 (User 16)
-- Think Time: 0.34s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 867 (User 17)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 224 AND 487 GROUP BY c.customer_id, c.customer_name;

-- Query 868 (User 18)
-- Think Time: 0.30s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 401 GROUP BY status;

-- Query 869 (User 19)
-- Think Time: 0.16s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 237 GROUP BY status;

-- Query 870 (User 20)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 279 GROUP BY status;

-- Query 871 (User 21)
-- Think Time: 0.33s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 872 (User 22)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 368 GROUP BY status;

-- Query 873 (User 23)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 346 AND 482 GROUP BY c.customer_id, c.customer_name;

-- Query 874 (User 24)
-- Think Time: 0.22s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 62 AND 467 GROUP BY c.customer_id, c.customer_name;

-- Query 875 (User 25)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 49 AND category_id = 2 ORDER BY stock_quantity;

-- Query 876 (User 26)
-- Think Time: 0.25s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 262 AND 495 GROUP BY c.customer_id, c.customer_name;

-- Query 877 (User 27)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 417 GROUP BY status;

-- Query 878 (User 28)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 109;

-- Query 879 (User 29)
-- Think Time: 0.24s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 263 GROUP BY status;

-- Query 880 (User 30)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 391 AND 485 GROUP BY c.customer_id, c.customer_name;

-- Query 881 (User 31)
-- Think Time: 0.16s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 850;

-- Query 882 (User 32)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 883 (User 33)
-- Think Time: 0.28s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 311 GROUP BY status;

-- Query 884 (User 34)
-- Think Time: 0.42s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 285 AND 426 GROUP BY c.customer_id, c.customer_name;

-- Query 885 (User 35)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 299 AND 404 GROUP BY c.customer_id, c.customer_name;

-- Query 886 (User 36)
-- Think Time: 0.24s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 887 (User 37)
-- Think Time: 0.15s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 203;

-- Query 888 (User 38)
-- Think Time: 0.45s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 308 AND 470 GROUP BY c.customer_id, c.customer_name;

-- Query 889 (User 39)
-- Think Time: 0.38s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 39 AND 469 GROUP BY c.customer_id, c.customer_name;

-- Query 890 (User 40)
-- Think Time: 0.18s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 891 (User 41)
-- Think Time: 0.47s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 360 GROUP BY status;

-- Query 892 (User 42)
-- Think Time: 0.22s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 589;

-- Query 893 (User 43)
-- Think Time: 0.41s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 29 AND 404 GROUP BY c.customer_id, c.customer_name;

-- Query 894 (User 44)
-- Think Time: 0.47s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 360 AND 455 GROUP BY c.customer_id, c.customer_name;

-- Query 895 (User 45)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 48 AND 476 GROUP BY c.customer_id, c.customer_name;

-- Query 896 (User 46)
-- Think Time: 0.15s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 93 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 897 (User 47)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 898 (User 48)
-- Think Time: 0.13s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 54 GROUP BY status;

-- Query 899 (User 49)
-- Think Time: 0.36s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 119 AND 440 GROUP BY c.customer_id, c.customer_name;

-- Query 900 (User 50)
-- Think Time: 0.30s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 34 AND category_id = 1 ORDER BY stock_quantity;

-- Query 901 (User 1)
-- Think Time: 0.41s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 37 AND category_id = 4 ORDER BY stock_quantity;

-- Query 902 (User 2)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 903 (User 3)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 904 (User 4)
-- Think Time: 0.21s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 8 AND 436 GROUP BY c.customer_id, c.customer_name;

-- Query 905 (User 5)
-- Think Time: 0.11s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 158 GROUP BY status;

-- Query 906 (User 6)
-- Think Time: 0.48s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 907 (User 7)
-- Think Time: 0.19s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 2 ORDER BY stock_quantity;

-- Query 908 (User 8)
-- Think Time: 0.11s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 909 (User 9)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 56 GROUP BY status;

-- Query 910 (User 10)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 443;

-- Query 911 (User 11)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 23 GROUP BY status;

-- Query 912 (User 12)
-- Think Time: 0.39s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 365 GROUP BY status;

-- Query 913 (User 13)
-- Think Time: 0.42s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 1 ORDER BY stock_quantity;

-- Query 914 (User 14)
-- Think Time: 0.49s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 886;

-- Query 915 (User 15)
-- Think Time: 0.47s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 162 AND 496 GROUP BY c.customer_id, c.customer_name;

-- Query 916 (User 16)
-- Think Time: 0.33s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 5 ORDER BY stock_quantity;

-- Query 917 (User 17)
-- Think Time: 0.45s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 134 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 918 (User 18)
-- Think Time: 0.43s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 233 AND 402 GROUP BY c.customer_id, c.customer_name;

-- Query 919 (User 19)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 920 (User 20)
-- Think Time: 0.40s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 921 (User 21)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 47 AND category_id = 3 ORDER BY stock_quantity;

-- Query 922 (User 22)
-- Think Time: 0.12s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 27 AND category_id = 4 ORDER BY stock_quantity;

-- Query 923 (User 23)
-- Think Time: 0.18s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 848;

-- Query 924 (User 24)
-- Think Time: 0.45s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 329;

-- Query 925 (User 25)
-- Think Time: 0.34s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 143 GROUP BY status;

-- Query 926 (User 26)
-- Think Time: 0.43s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 5;

-- Query 927 (User 27)
-- Think Time: 0.49s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 253 GROUP BY status;

-- Query 928 (User 28)
-- Think Time: 0.38s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 929 (User 29)
-- Think Time: 0.15s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 930 (User 30)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 21 AND category_id = 2 ORDER BY stock_quantity;

-- Query 931 (User 31)
-- Think Time: 0.35s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 369;

-- Query 932 (User 32)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 596;

-- Query 933 (User 33)
-- Think Time: 0.36s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 17 AND category_id = 5 ORDER BY stock_quantity;

-- Query 934 (User 34)
-- Think Time: 0.26s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 935 (User 35)
-- Think Time: 0.26s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 149 AND 435 GROUP BY c.customer_id, c.customer_name;

-- Query 936 (User 36)
-- Think Time: 0.33s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 24 AND category_id = 4 ORDER BY stock_quantity;

-- Query 937 (User 37)
-- Think Time: 0.14s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 106 AND 500 GROUP BY c.customer_id, c.customer_name;

-- Query 938 (User 38)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 26 GROUP BY status;

-- Query 939 (User 39)
-- Think Time: 0.30s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 83 AND 448 GROUP BY c.customer_id, c.customer_name;

-- Query 940 (User 40)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 25 AND category_id = 1 ORDER BY stock_quantity;

-- Query 941 (User 41)
-- Think Time: 0.18s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 8 GROUP BY status;

-- Query 942 (User 42)
-- Think Time: 0.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 582;

-- Query 943 (User 43)
-- Think Time: 0.26s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 44 AND category_id = 1 ORDER BY stock_quantity;

-- Query 944 (User 44)
-- Think Time: 0.14s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 500 GROUP BY status;

-- Query 945 (User 45)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 87 GROUP BY status;

-- Query 946 (User 46)
-- Think Time: 0.11s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 5 ORDER BY stock_quantity;

-- Query 947 (User 47)
-- Think Time: 0.28s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 429;

-- Query 948 (User 48)
-- Think Time: 0.40s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 14 AND category_id = 5 ORDER BY stock_quantity;

-- Query 949 (User 49)
-- Think Time: 0.27s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 225 AND 415 GROUP BY c.customer_id, c.customer_name;

-- Query 950 (User 50)
-- Think Time: 0.22s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 951 (User 1)
-- Think Time: 0.31s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 366 AND 448 GROUP BY c.customer_id, c.customer_name;

-- Query 952 (User 2)
-- Think Time: 0.28s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 10 AND category_id = 1 ORDER BY stock_quantity;

-- Query 953 (User 3)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 954 (User 4)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 26 AND category_id = 5 ORDER BY stock_quantity;

-- Query 955 (User 5)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 956 (User 6)
-- Think Time: 0.13s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 431;

-- Query 957 (User 7)
-- Think Time: 0.41s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 958 (User 8)
-- Think Time: 0.16s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 48 AND category_id = 3 ORDER BY stock_quantity;

-- Query 959 (User 9)
-- Think Time: 0.45s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 45 AND category_id = 5 ORDER BY stock_quantity;

-- Query 960 (User 10)
-- Think Time: 0.28s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 22 AND category_id = 3 ORDER BY stock_quantity;

-- Query 961 (User 11)
-- Think Time: 0.11s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 379;

-- Query 962 (User 12)
-- Think Time: 0.28s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 321 GROUP BY status;

-- Query 963 (User 13)
-- Think Time: 0.13s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 384 AND 483 GROUP BY c.customer_id, c.customer_name;

-- Query 964 (User 14)
-- Think Time: 0.23s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

-- Query 965 (User 15)
-- Think Time: 0.39s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 482 GROUP BY status;

-- Query 966 (User 16)
-- Think Time: 0.21s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 2;

-- Query 967 (User 17)
-- Think Time: 0.17s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 477 GROUP BY status;

-- Query 968 (User 18)
-- Think Time: 0.40s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 295;

-- Query 969 (User 19)
-- Think Time: 0.45s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 28 AND 449 GROUP BY c.customer_id, c.customer_name;

-- Query 970 (User 20)
-- Think Time: 0.28s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 133 AND 490 GROUP BY c.customer_id, c.customer_name;

-- Query 971 (User 21)
-- Think Time: 0.32s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 300 AND 450 GROUP BY c.customer_id, c.customer_name;

-- Query 972 (User 22)
-- Think Time: 0.29s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 240 GROUP BY status;

-- Query 973 (User 23)
-- Think Time: 0.27s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 12 AND category_id = 5 ORDER BY stock_quantity;

-- Query 974 (User 24)
-- Think Time: 0.28s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 84 GROUP BY status;

-- Query 975 (User 25)
-- Think Time: 0.12s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 407;

-- Query 976 (User 26)
-- Think Time: 0.49s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 56 AND 454 GROUP BY c.customer_id, c.customer_name;

-- Query 977 (User 27)
-- Think Time: 0.26s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 569;

-- Query 978 (User 28)
-- Think Time: 0.20s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 15 AND category_id = 1 ORDER BY stock_quantity;

-- Query 979 (User 29)
-- Think Time: 0.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 784;

-- Query 980 (User 30)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 18 AND category_id = 2 ORDER BY stock_quantity;

-- Query 981 (User 31)
-- Think Time: 0.43s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 613;

-- Query 982 (User 32)
-- Think Time: 0.25s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 447;

-- Query 983 (User 33)
-- Think Time: 0.37s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 78 AND 437 GROUP BY c.customer_id, c.customer_name;

-- Query 984 (User 34)
-- Think Time: 0.30s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 4;

-- Query 985 (User 35)
-- Think Time: 0.34s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 13 AND category_id = 1 ORDER BY stock_quantity;

-- Query 986 (User 36)
-- Think Time: 0.13s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 33 AND category_id = 5 ORDER BY stock_quantity;

-- Query 987 (User 37)
-- Think Time: 0.12s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 3;

-- Query 988 (User 38)
-- Think Time: 0.17s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 31 AND category_id = 4 ORDER BY stock_quantity;

-- Query 989 (User 39)
-- Think Time: 0.26s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 19 GROUP BY status;

-- Query 990 (User 40)
-- Think Time: 0.20s
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN 274 AND 413 GROUP BY c.customer_id, c.customer_name;

-- Query 991 (User 41)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 180;

-- Query 992 (User 42)
-- Think Time: 0.50s
SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = 335 GROUP BY status;

-- Query 993 (User 43)
-- Think Time: 0.17s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 896;

-- Query 994 (User 44)
-- Think Time: 0.21s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 381;

-- Query 995 (User 45)
-- Think Time: 0.34s
SELECT COUNT(*) FROM simple_test WHERE category = 'C' AND value > 571;

-- Query 996 (User 46)
-- Think Time: 0.30s
SELECT COUNT(*) FROM simple_test WHERE category = 'B' AND value > 860;

-- Query 997 (User 47)
-- Think Time: 0.40s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 312;

-- Query 998 (User 48)
-- Think Time: 0.24s
SELECT COUNT(*) FROM simple_test WHERE category = 'A' AND value > 739;

-- Query 999 (User 49)
-- Think Time: 0.48s
SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < 41 AND category_id = 4 ORDER BY stock_quantity;

-- Query 1000 (User 50)
-- Think Time: 0.32s
SELECT COUNT(*), AVG(price) FROM products WHERE category_id = 1;

