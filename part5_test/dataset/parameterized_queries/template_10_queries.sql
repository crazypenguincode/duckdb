-- Template 10: 分类销售分析
-- Parameterized Template: SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN ? AND ? GROUP BY p.category_id HAVING COUNT(*) > ? ORDER BY total_sold DESC;

-- Variation 1
-- Parameters: {'min_price': 83, 'max_price': 313, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 83 AND 313 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 2
-- Parameters: {'min_price': 223, 'max_price': 771, 'min_count': 7}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 223 AND 771 GROUP BY p.category_id HAVING COUNT(*) > 7 ORDER BY total_sold DESC;

-- Variation 3
-- Parameters: {'min_price': 123, 'max_price': 431, 'min_count': 5}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 123 AND 431 GROUP BY p.category_id HAVING COUNT(*) > 5 ORDER BY total_sold DESC;

-- Variation 4
-- Parameters: {'min_price': 250, 'max_price': 421, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 250 AND 421 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 5
-- Parameters: {'min_price': 190, 'max_price': 464, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 190 AND 464 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 6
-- Parameters: {'min_price': 197, 'max_price': 903, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 197 AND 903 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 7
-- Parameters: {'min_price': 194, 'max_price': 595, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 194 AND 595 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 8
-- Parameters: {'min_price': 253, 'max_price': 995, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 253 AND 995 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 9
-- Parameters: {'min_price': 43, 'max_price': 672, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 43 AND 672 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 10
-- Parameters: {'min_price': 217, 'max_price': 796, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 217 AND 796 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 11
-- Parameters: {'min_price': 177, 'max_price': 456, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 177 AND 456 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 12
-- Parameters: {'min_price': 230, 'max_price': 421, 'min_count': 9}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 230 AND 421 GROUP BY p.category_id HAVING COUNT(*) > 9 ORDER BY total_sold DESC;

-- Variation 13
-- Parameters: {'min_price': 261, 'max_price': 975, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 261 AND 975 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 14
-- Parameters: {'min_price': 24, 'max_price': 904, 'min_count': 2}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 24 AND 904 GROUP BY p.category_id HAVING COUNT(*) > 2 ORDER BY total_sold DESC;

-- Variation 15
-- Parameters: {'min_price': 53, 'max_price': 367, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 53 AND 367 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 16
-- Parameters: {'min_price': 172, 'max_price': 686, 'min_count': 9}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 172 AND 686 GROUP BY p.category_id HAVING COUNT(*) > 9 ORDER BY total_sold DESC;

-- Variation 17
-- Parameters: {'min_price': 284, 'max_price': 519, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 284 AND 519 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 18
-- Parameters: {'min_price': 187, 'max_price': 378, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 187 AND 378 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 19
-- Parameters: {'min_price': 265, 'max_price': 518, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 265 AND 518 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 20
-- Parameters: {'min_price': 114, 'max_price': 722, 'min_count': 5}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 114 AND 722 GROUP BY p.category_id HAVING COUNT(*) > 5 ORDER BY total_sold DESC;

-- Variation 21
-- Parameters: {'min_price': 113, 'max_price': 463, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 113 AND 463 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 22
-- Parameters: {'min_price': 196, 'max_price': 987, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 196 AND 987 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 23
-- Parameters: {'min_price': 130, 'max_price': 733, 'min_count': 6}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 130 AND 733 GROUP BY p.category_id HAVING COUNT(*) > 6 ORDER BY total_sold DESC;

-- Variation 24
-- Parameters: {'min_price': 136, 'max_price': 584, 'min_count': 2}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 136 AND 584 GROUP BY p.category_id HAVING COUNT(*) > 2 ORDER BY total_sold DESC;

-- Variation 25
-- Parameters: {'min_price': 283, 'max_price': 542, 'min_count': 6}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 283 AND 542 GROUP BY p.category_id HAVING COUNT(*) > 6 ORDER BY total_sold DESC;

-- Variation 26
-- Parameters: {'min_price': 251, 'max_price': 722, 'min_count': 10}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 251 AND 722 GROUP BY p.category_id HAVING COUNT(*) > 10 ORDER BY total_sold DESC;

-- Variation 27
-- Parameters: {'min_price': 79, 'max_price': 303, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 79 AND 303 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

-- Variation 28
-- Parameters: {'min_price': 177, 'max_price': 588, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 177 AND 588 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 29
-- Parameters: {'min_price': 96, 'max_price': 350, 'min_count': 4}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 96 AND 350 GROUP BY p.category_id HAVING COUNT(*) > 4 ORDER BY total_sold DESC;

-- Variation 30
-- Parameters: {'min_price': 114, 'max_price': 495, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 114 AND 495 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 31
-- Parameters: {'min_price': 137, 'max_price': 678, 'min_count': 9}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 137 AND 678 GROUP BY p.category_id HAVING COUNT(*) > 9 ORDER BY total_sold DESC;

-- Variation 32
-- Parameters: {'min_price': 58, 'max_price': 870, 'min_count': 7}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 58 AND 870 GROUP BY p.category_id HAVING COUNT(*) > 7 ORDER BY total_sold DESC;

-- Variation 33
-- Parameters: {'min_price': 96, 'max_price': 815, 'min_count': 7}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 96 AND 815 GROUP BY p.category_id HAVING COUNT(*) > 7 ORDER BY total_sold DESC;

-- Variation 34
-- Parameters: {'min_price': 144, 'max_price': 927, 'min_count': 7}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 144 AND 927 GROUP BY p.category_id HAVING COUNT(*) > 7 ORDER BY total_sold DESC;

-- Variation 35
-- Parameters: {'min_price': 93, 'max_price': 778, 'min_count': 7}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 93 AND 778 GROUP BY p.category_id HAVING COUNT(*) > 7 ORDER BY total_sold DESC;

-- Variation 36
-- Parameters: {'min_price': 298, 'max_price': 979, 'min_count': 4}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 298 AND 979 GROUP BY p.category_id HAVING COUNT(*) > 4 ORDER BY total_sold DESC;

-- Variation 37
-- Parameters: {'min_price': 64, 'max_price': 631, 'min_count': 9}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 64 AND 631 GROUP BY p.category_id HAVING COUNT(*) > 9 ORDER BY total_sold DESC;

-- Variation 38
-- Parameters: {'min_price': 175, 'max_price': 356, 'min_count': 8}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 175 AND 356 GROUP BY p.category_id HAVING COUNT(*) > 8 ORDER BY total_sold DESC;

-- Variation 39
-- Parameters: {'min_price': 71, 'max_price': 605, 'min_count': 4}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 71 AND 605 GROUP BY p.category_id HAVING COUNT(*) > 4 ORDER BY total_sold DESC;

-- Variation 40
-- Parameters: {'min_price': 226, 'max_price': 677, 'min_count': 3}
SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN 226 AND 677 GROUP BY p.category_id HAVING COUNT(*) > 3 ORDER BY total_sold DESC;

