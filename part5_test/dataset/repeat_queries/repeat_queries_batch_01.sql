-- Query 1
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 2
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 3
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 4
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 5
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 6
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 7
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 8
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 9
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 10
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 11
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 12
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 13
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 14
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 15
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 16
SELECT * FROM simple_test WHERE category = 'B' ORDER BY id LIMIT 100;

-- Query 17
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 18
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 19
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 20
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 21
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 22
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 23
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 24
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 25
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3502);

-- Query 26
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 27
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 28
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 29
SELECT * FROM orders WHERE order_date = '2023-11-10';

-- Query 30
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 31
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 32
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 33
SELECT COUNT(*) FROM products WHERE stock_quantity < 45;

-- Query 34
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 35
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 36
SELECT name, value FROM simple_test WHERE created_date >= '2023-06-05';

-- Query 37
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 38
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 39
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 40
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 41
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 42
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 43
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 44
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 45
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 46
SELECT COUNT(*) FROM products WHERE stock_quantity < 45;

-- Query 47
SELECT product_name, price FROM products WHERE price BETWEEN 244 AND 818;

-- Query 48
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 49
SELECT SUM(total_amount) FROM orders WHERE status = 'shipped';

-- Query 50
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 51
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 52
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 53
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 54
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 55
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 56
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 57
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 58
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 59
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 60
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 61
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 62
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 63
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 64
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 65
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 66
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 67
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 68
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 69
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-26';

-- Query 70
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 71
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-21';

-- Query 72
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 73
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 74
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-09-13' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 75
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 76
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-01' AND '2023-12-31' ORDER BY sales_amount DESC;

-- Query 77
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 78
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 79
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 80
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 81
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 82
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 83
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 84
SELECT SUM(total_amount) FROM orders WHERE status = 'shipped';

-- Query 85
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 86
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 87
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 88
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 89
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 90
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 91
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 92
SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;

-- Query 93
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 94
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 95
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 96
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 2083);

-- Query 97
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 98
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-21' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 99
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 100
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

