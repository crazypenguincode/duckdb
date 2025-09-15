-- Template 4: 产品销量统计
-- Parameterized Template: SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = ? GROUP BY p.product_name HAVING SUM(oi.quantity) > ? ORDER BY total_sold DESC LIMIT ?;

-- Variation 1
-- Parameters: {'category_id': 4, 'min_quantity': 17, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 17 ORDER BY total_sold DESC LIMIT 100;

-- Variation 2
-- Parameters: {'category_id': 3, 'min_quantity': 15, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 15 ORDER BY total_sold DESC LIMIT 20;

-- Variation 3
-- Parameters: {'category_id': 4, 'min_quantity': 58, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 58 ORDER BY total_sold DESC LIMIT 20;

-- Variation 4
-- Parameters: {'category_id': 3, 'min_quantity': 80, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 80 ORDER BY total_sold DESC LIMIT 10;

-- Variation 5
-- Parameters: {'category_id': 3, 'min_quantity': 27, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 27 ORDER BY total_sold DESC LIMIT 100;

-- Variation 6
-- Parameters: {'category_id': 4, 'min_quantity': 68, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 68 ORDER BY total_sold DESC LIMIT 20;

-- Variation 7
-- Parameters: {'category_id': 1, 'min_quantity': 40, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 40 ORDER BY total_sold DESC LIMIT 100;

-- Variation 8
-- Parameters: {'category_id': 2, 'min_quantity': 80, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 80 ORDER BY total_sold DESC LIMIT 10;

-- Variation 9
-- Parameters: {'category_id': 1, 'min_quantity': 97, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 97 ORDER BY total_sold DESC LIMIT 20;

-- Variation 10
-- Parameters: {'category_id': 1, 'min_quantity': 52, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 52 ORDER BY total_sold DESC LIMIT 20;

-- Variation 11
-- Parameters: {'category_id': 5, 'min_quantity': 72, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_name HAVING SUM(oi.quantity) > 72 ORDER BY total_sold DESC LIMIT 100;

-- Variation 12
-- Parameters: {'category_id': 1, 'min_quantity': 59, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 59 ORDER BY total_sold DESC LIMIT 50;

-- Variation 13
-- Parameters: {'category_id': 2, 'min_quantity': 13, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 13 ORDER BY total_sold DESC LIMIT 100;

-- Variation 14
-- Parameters: {'category_id': 5, 'min_quantity': 44, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_name HAVING SUM(oi.quantity) > 44 ORDER BY total_sold DESC LIMIT 20;

-- Variation 15
-- Parameters: {'category_id': 4, 'min_quantity': 60, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 60 ORDER BY total_sold DESC LIMIT 20;

-- Variation 16
-- Parameters: {'category_id': 3, 'min_quantity': 83, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 83 ORDER BY total_sold DESC LIMIT 100;

-- Variation 17
-- Parameters: {'category_id': 2, 'min_quantity': 62, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 62 ORDER BY total_sold DESC LIMIT 10;

-- Variation 18
-- Parameters: {'category_id': 4, 'min_quantity': 14, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 14 ORDER BY total_sold DESC LIMIT 100;

-- Variation 19
-- Parameters: {'category_id': 4, 'min_quantity': 38, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 38 ORDER BY total_sold DESC LIMIT 50;

-- Variation 20
-- Parameters: {'category_id': 3, 'min_quantity': 28, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 28 ORDER BY total_sold DESC LIMIT 100;

-- Variation 21
-- Parameters: {'category_id': 3, 'min_quantity': 96, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 96 ORDER BY total_sold DESC LIMIT 50;

-- Variation 22
-- Parameters: {'category_id': 2, 'min_quantity': 85, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 85 ORDER BY total_sold DESC LIMIT 100;

-- Variation 23
-- Parameters: {'category_id': 2, 'min_quantity': 86, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 86 ORDER BY total_sold DESC LIMIT 10;

-- Variation 24
-- Parameters: {'category_id': 2, 'min_quantity': 98, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 98 ORDER BY total_sold DESC LIMIT 10;

-- Variation 25
-- Parameters: {'category_id': 2, 'min_quantity': 67, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 67 ORDER BY total_sold DESC LIMIT 20;

-- Variation 26
-- Parameters: {'category_id': 4, 'min_quantity': 38, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 38 ORDER BY total_sold DESC LIMIT 100;

-- Variation 27
-- Parameters: {'category_id': 1, 'min_quantity': 66, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 66 ORDER BY total_sold DESC LIMIT 10;

-- Variation 28
-- Parameters: {'category_id': 4, 'min_quantity': 90, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 90 ORDER BY total_sold DESC LIMIT 20;

-- Variation 29
-- Parameters: {'category_id': 2, 'min_quantity': 27, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 27 ORDER BY total_sold DESC LIMIT 50;

-- Variation 30
-- Parameters: {'category_id': 4, 'min_quantity': 61, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 61 ORDER BY total_sold DESC LIMIT 50;

-- Variation 31
-- Parameters: {'category_id': 3, 'min_quantity': 51, 'limit': 100}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 51 ORDER BY total_sold DESC LIMIT 100;

-- Variation 32
-- Parameters: {'category_id': 4, 'min_quantity': 35, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 35 ORDER BY total_sold DESC LIMIT 10;

-- Variation 33
-- Parameters: {'category_id': 1, 'min_quantity': 10, 'limit': 50}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 10 ORDER BY total_sold DESC LIMIT 50;

-- Variation 34
-- Parameters: {'category_id': 2, 'min_quantity': 50, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 2 GROUP BY p.product_name HAVING SUM(oi.quantity) > 50 ORDER BY total_sold DESC LIMIT 10;

-- Variation 35
-- Parameters: {'category_id': 1, 'min_quantity': 62, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 62 ORDER BY total_sold DESC LIMIT 20;

-- Variation 36
-- Parameters: {'category_id': 3, 'min_quantity': 86, 'limit': 20}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 3 GROUP BY p.product_name HAVING SUM(oi.quantity) > 86 ORDER BY total_sold DESC LIMIT 20;

-- Variation 37
-- Parameters: {'category_id': 4, 'min_quantity': 77, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 4 GROUP BY p.product_name HAVING SUM(oi.quantity) > 77 ORDER BY total_sold DESC LIMIT 10;

-- Variation 38
-- Parameters: {'category_id': 5, 'min_quantity': 74, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_name HAVING SUM(oi.quantity) > 74 ORDER BY total_sold DESC LIMIT 10;

-- Variation 39
-- Parameters: {'category_id': 1, 'min_quantity': 60, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 1 GROUP BY p.product_name HAVING SUM(oi.quantity) > 60 ORDER BY total_sold DESC LIMIT 10;

-- Variation 40
-- Parameters: {'category_id': 5, 'min_quantity': 11, 'limit': 10}
SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = 5 GROUP BY p.product_name HAVING SUM(oi.quantity) > 11 ORDER BY total_sold DESC LIMIT 10;

