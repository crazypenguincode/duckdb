-- Template 12: 供应商库存分析
-- Parameterized Template: SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < ? GROUP BY supplier_id HAVING COUNT(*) > ?;

-- Variation 1
-- Parameters: {'stock_threshold': 22, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 22 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 2
-- Parameters: {'stock_threshold': 10, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 10 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 3
-- Parameters: {'stock_threshold': 23, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 23 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 4
-- Parameters: {'stock_threshold': 27, 'min_products': 1}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 27 GROUP BY supplier_id HAVING COUNT(*) > 1;

-- Variation 5
-- Parameters: {'stock_threshold': 19, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 19 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 6
-- Parameters: {'stock_threshold': 15, 'min_products': 1}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 15 GROUP BY supplier_id HAVING COUNT(*) > 1;

-- Variation 7
-- Parameters: {'stock_threshold': 17, 'min_products': 3}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 17 GROUP BY supplier_id HAVING COUNT(*) > 3;

-- Variation 8
-- Parameters: {'stock_threshold': 21, 'min_products': 3}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 21 GROUP BY supplier_id HAVING COUNT(*) > 3;

-- Variation 9
-- Parameters: {'stock_threshold': 28, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 28 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 10
-- Parameters: {'stock_threshold': 30, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 30 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 11
-- Parameters: {'stock_threshold': 24, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 24 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 12
-- Parameters: {'stock_threshold': 24, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 24 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 13
-- Parameters: {'stock_threshold': 19, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 19 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 14
-- Parameters: {'stock_threshold': 29, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 29 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 15
-- Parameters: {'stock_threshold': 17, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 17 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 16
-- Parameters: {'stock_threshold': 19, 'min_products': 1}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 19 GROUP BY supplier_id HAVING COUNT(*) > 1;

-- Variation 17
-- Parameters: {'stock_threshold': 28, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 28 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 18
-- Parameters: {'stock_threshold': 27, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 27 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 19
-- Parameters: {'stock_threshold': 15, 'min_products': 3}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 15 GROUP BY supplier_id HAVING COUNT(*) > 3;

-- Variation 20
-- Parameters: {'stock_threshold': 19, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 19 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 21
-- Parameters: {'stock_threshold': 12, 'min_products': 3}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 12 GROUP BY supplier_id HAVING COUNT(*) > 3;

-- Variation 22
-- Parameters: {'stock_threshold': 11, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 11 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 23
-- Parameters: {'stock_threshold': 18, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 18 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 24
-- Parameters: {'stock_threshold': 24, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 24 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 25
-- Parameters: {'stock_threshold': 22, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 22 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 26
-- Parameters: {'stock_threshold': 11, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 11 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 27
-- Parameters: {'stock_threshold': 15, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 15 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 28
-- Parameters: {'stock_threshold': 10, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 10 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 29
-- Parameters: {'stock_threshold': 27, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 27 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 30
-- Parameters: {'stock_threshold': 24, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 24 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 31
-- Parameters: {'stock_threshold': 14, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 14 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 32
-- Parameters: {'stock_threshold': 17, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 17 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 33
-- Parameters: {'stock_threshold': 15, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 15 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 34
-- Parameters: {'stock_threshold': 30, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 30 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 35
-- Parameters: {'stock_threshold': 29, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 29 GROUP BY supplier_id HAVING COUNT(*) > 5;

-- Variation 36
-- Parameters: {'stock_threshold': 10, 'min_products': 1}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 10 GROUP BY supplier_id HAVING COUNT(*) > 1;

-- Variation 37
-- Parameters: {'stock_threshold': 16, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 16 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 38
-- Parameters: {'stock_threshold': 24, 'min_products': 2}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 24 GROUP BY supplier_id HAVING COUNT(*) > 2;

-- Variation 39
-- Parameters: {'stock_threshold': 27, 'min_products': 4}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 27 GROUP BY supplier_id HAVING COUNT(*) > 4;

-- Variation 40
-- Parameters: {'stock_threshold': 23, 'min_products': 5}
SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < 23 GROUP BY supplier_id HAVING COUNT(*) > 5;

