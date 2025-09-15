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

-- Query 101
SELECT name, value FROM simple_test WHERE created_date >= '2023-06-05';

-- Query 102
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 103
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 104
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 105
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

-- Query 106
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 107
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 108
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 109
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 110
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

-- Query 111
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 2083);

-- Query 112
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

-- Query 113
SELECT product_name, price FROM products WHERE price BETWEEN 348 AND 672;

-- Query 114
SELECT name, value FROM simple_test WHERE created_date >= '2023-06-05';

-- Query 115
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 116
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 117
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 118
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 119
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-25' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 120
SELECT COUNT(*) FROM simple_test WHERE value > 730;

-- Query 121
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 122
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 123
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 124
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 125
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4643);

-- Query 126
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 127
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 128
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 129
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 130
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

-- Query 131
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 132
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

-- Query 133
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-21';

-- Query 134
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 135
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 136
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 137
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

-- Query 138
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 139
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 140
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 141
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 142
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 143
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 144
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-25';

-- Query 145
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 146
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 147
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 148
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 149
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 150
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

-- Query 151
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 152
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

-- Query 153
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

-- Query 154
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 155
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

-- Query 156
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 157
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 158
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 159
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 160
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-07-28' AND '2023-11-21' ORDER BY sales_amount DESC;

-- Query 161
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

-- Query 162
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 163
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 164
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 165
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 166
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 167
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 168
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 169
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 170
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 4;

-- Query 171
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 172
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 173
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 174
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 175
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 176
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 177
SELECT SUM(total_amount) FROM orders WHERE status = 'shipped';

-- Query 178
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 179
SELECT SUM(total_amount) FROM orders WHERE status = 'shipped';

-- Query 180
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 181
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 182
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 183
SELECT COUNT(*) FROM simple_test WHERE value > 730;

-- Query 184
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

-- Query 185
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-16';

-- Query 186
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 187
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 188
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 189
SELECT name, value FROM simple_test WHERE created_date >= '2023-06-05';

-- Query 190
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 191
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 192
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 193
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 194
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 195
SELECT COUNT(*) FROM simple_test WHERE value > 631;

-- Query 196
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 197
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 198
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

-- Query 199
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 200
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 201
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 202
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-09-13' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 203
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 204
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-01-15' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 205
SELECT product_name, price FROM products WHERE price BETWEEN 244 AND 818;

-- Query 206
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 207
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 208
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 209
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 210
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 211
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 212
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 213
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 214
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 215
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1665);

-- Query 216
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-10-09' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 217
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 218
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

-- Query 219
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-18' AND '2023-12-30' ORDER BY sales_amount DESC;

-- Query 220
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 5;

-- Query 221
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 222
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 223
SELECT product_name, price FROM products WHERE price BETWEEN 359 AND 627;

-- Query 224
SELECT name, value FROM simple_test WHERE created_date >= '2023-01-16';

-- Query 225
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 226
SELECT COUNT(*) FROM simple_test WHERE value > 814;

-- Query 227
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 228
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 229
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 230
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-25';

-- Query 231
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 232
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-08-05' AND '2023-12-10' ORDER BY sales_amount DESC;

-- Query 233
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 234
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 235
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

-- Query 236
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 237
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 238
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 239
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 240
SELECT COUNT(*) FROM simple_test WHERE value > 631;

-- Query 241
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-10';

-- Query 242
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 243
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 244
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-08-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 245
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 246
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 247
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3813);

-- Query 248
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 249
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 250
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 251
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 252
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 253
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-22' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 254
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 255
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 256
SELECT * FROM orders WHERE order_date = '2023-04-02';

-- Query 257
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 258
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-08-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 259
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 260
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 261
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 262
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 263
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 264
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-25';

-- Query 265
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 266
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 267
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 268
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 269
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 270
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

-- Query 271
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 272
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 273
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 274
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

-- Query 275
SELECT COUNT(*) FROM products WHERE stock_quantity < 43;

-- Query 276
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 277
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 278
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 279
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

-- Query 280
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 281
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 282
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 283
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 284
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 285
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 286
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 287
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 288
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 289
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 290
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 291
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 292
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 4;

-- Query 293
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 294
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 295
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 296
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 297
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 298
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 299
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 300
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-21';

-- Query 301
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 302
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 303
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 304
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 305
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 306
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

-- Query 307
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 308
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 309
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 310
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4643);

-- Query 311
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 312
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 313
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 314
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 315
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 316
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 317
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 318
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 319
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 320
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 321
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

-- Query 322
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 323
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 324
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-07-28' AND '2023-11-21' ORDER BY sales_amount DESC;

-- Query 325
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 5;

-- Query 326
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 327
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 328
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 329
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 330
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 331
SELECT COUNT(*) FROM products WHERE stock_quantity < 43;

-- Query 332
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

-- Query 333
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-25';

-- Query 334
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 335
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3502);

-- Query 336
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 337
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 338
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

-- Query 339
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 340
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 341
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 342
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 343
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

-- Query 344
SELECT SUM(total_amount) FROM orders WHERE status = 'shipped';

-- Query 345
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 346
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 347
SELECT * FROM orders WHERE order_date = '2023-01-25';

-- Query 348
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 349
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 350
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 351
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 352
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 353
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 354
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 355
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

-- Query 356
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 357
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

-- Query 358
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 359
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-21' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 360
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 4;

-- Query 361
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 362
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 363
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 364
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 365
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 366
SELECT name, value FROM simple_test WHERE created_date >= '2023-01-16';

-- Query 367
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 368
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

-- Query 369
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

-- Query 370
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 371
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 372
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 373
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

-- Query 374
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 375
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 376
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 377
SELECT product_name, price FROM products WHERE price BETWEEN 244 AND 818;

-- Query 378
SELECT COUNT(*) FROM products WHERE stock_quantity < 46;

-- Query 379
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 380
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 381
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 382
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 383
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 384
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 385
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 386
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 387
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 388
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 389
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 390
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 391
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 392
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 393
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 394
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 395
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

-- Query 396
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-26';

-- Query 397
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

-- Query 398
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 399
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 5;

-- Query 400
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 401
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 402
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 403
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 404
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 405
SELECT * FROM orders WHERE order_date = '2023-04-02';

-- Query 406
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 407
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

-- Query 408
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 409
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 410
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 411
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 412
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 413
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 414
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-25';

-- Query 415
SELECT COUNT(*) FROM simple_test WHERE value > 483;

-- Query 416
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 417
SELECT * FROM orders WHERE order_date = '2023-11-10';

-- Query 418
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 419
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 420
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 421
SELECT COUNT(*) FROM simple_test WHERE value > 631;

-- Query 422
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 423
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 424
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 425
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

-- Query 426
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-21' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 427
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-04-17' AND '2023-11-24' ORDER BY sales_amount DESC;

-- Query 428
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 429
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 430
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 431
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 432
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

-- Query 433
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

-- Query 434
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 435
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 436
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 437
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 438
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

-- Query 439
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 440
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 441
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 442
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

-- Query 443
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 444
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 445
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 446
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 447
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 448
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 449
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 450
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 451
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 452
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 453
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 454
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 455
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 456
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 457
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 458
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 459
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 460
SELECT product_name, price FROM products WHERE price BETWEEN 457 AND 932;

-- Query 461
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-21' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 462
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

-- Query 463
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 464
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 465
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 466
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 467
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 468
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

-- Query 469
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 470
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 471
SELECT * FROM simple_test WHERE category = 'B' ORDER BY id LIMIT 100;

-- Query 472
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 473
SELECT COUNT(*) FROM simple_test WHERE value > 814;

-- Query 474
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 475
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 476
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 477
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 478
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 479
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 480
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 481
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 482
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 483
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 484
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 485
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 486
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

-- Query 487
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 488
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 489
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 490
SELECT COUNT(*) FROM products WHERE stock_quantity < 46;

-- Query 491
SELECT COUNT(*) FROM simple_test WHERE value > 814;

-- Query 492
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 493
SELECT COUNT(*) FROM simple_test WHERE value > 483;

-- Query 494
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 495
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 496
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 497
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 498
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 499
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 500
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 501
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 502
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 503
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 504
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-26';

-- Query 505
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 506
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 507
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

-- Query 508
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 509
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 510
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

-- Query 511
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 512
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

-- Query 513
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 514
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 515
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 516
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 517
SELECT name, value FROM simple_test WHERE created_date >= '2023-01-16';

-- Query 518
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 519
SELECT COUNT(*) FROM simple_test WHERE value > 730;

-- Query 520
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 521
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 522
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 523
SELECT COUNT(*) FROM products WHERE stock_quantity < 45;

-- Query 524
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3619);

-- Query 525
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 526
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

-- Query 527
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 528
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-10';

-- Query 529
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

-- Query 530
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 531
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 532
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 533
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 534
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 535
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 536
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

-- Query 537
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 538
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 539
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 540
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

-- Query 541
SELECT product_name, price FROM products WHERE price BETWEEN 329 AND 854;

-- Query 542
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 543
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 544
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 545
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 546
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 547
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 548
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 549
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 550
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 551
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 552
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 553
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 554
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 555
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 556
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 557
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 558
SELECT * FROM simple_test WHERE category = 'B' ORDER BY id LIMIT 100;

-- Query 559
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-22' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 560
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 561
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 562
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 563
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 564
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 565
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 566
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 567
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-25' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 568
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

-- Query 569
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

-- Query 570
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-06-19' AND '2023-11-11' ORDER BY sales_amount DESC;

-- Query 571
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 572
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 573
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 4;

-- Query 574
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 575
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 576
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 577
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-10';

-- Query 578
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 579
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

-- Query 580
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3502);

-- Query 581
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 582
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 583
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 584
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 585
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

-- Query 586
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 587
SELECT * FROM orders WHERE order_date = '2023-04-02';

-- Query 588
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

-- Query 589
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 590
SELECT COUNT(*) FROM products WHERE stock_quantity < 45;

-- Query 591
SELECT * FROM orders WHERE order_date = '2023-01-25';

-- Query 592
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 593
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 594
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3502);

-- Query 595
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 596
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 597
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 598
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 599
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 600
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4643);

-- Query 601
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 602
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 603
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 604
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 605
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 606
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 607
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 608
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-06-19' AND '2023-11-11' ORDER BY sales_amount DESC;

-- Query 609
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 610
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 611
SELECT COUNT(*) FROM simple_test WHERE value > 631;

-- Query 612
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 613
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 614
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 615
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-05';

-- Query 616
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 617
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 618
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 619
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 620
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3363);

-- Query 621
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 622
SELECT COUNT(*) FROM products WHERE stock_quantity < 43;

-- Query 623
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 624
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 625
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 626
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-01' AND '2023-12-31' ORDER BY sales_amount DESC;

-- Query 627
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 628
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

-- Query 629
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 630
SELECT product_name, price FROM products WHERE price BETWEEN 457 AND 932;

-- Query 631
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

-- Query 632
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-16';

-- Query 633
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 634
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

-- Query 635
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-26';

-- Query 636
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

-- Query 637
SELECT product_name, price FROM products WHERE price BETWEEN 457 AND 932;

-- Query 638
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 639
SELECT * FROM orders WHERE order_date = '2023-01-25';

-- Query 640
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 641
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 642
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 643
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-07-28' AND '2023-11-21' ORDER BY sales_amount DESC;

-- Query 644
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 645
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 646
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 647
SELECT product_name, price FROM products WHERE price BETWEEN 359 AND 627;

-- Query 648
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 649
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 2083);

-- Query 650
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

-- Query 651
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 652
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 653
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 654
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 655
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 656
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 657
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 658
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3813);

-- Query 659
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 660
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 661
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 662
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 663
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 664
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 665
SELECT * FROM orders WHERE order_date = '2023-01-25';

-- Query 666
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 667
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 668
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-08-05' AND '2023-12-10' ORDER BY sales_amount DESC;

-- Query 669
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 670
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 671
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 672
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 673
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 674
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 675
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-10-09' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 676
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 677
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-07-28' AND '2023-11-21' ORDER BY sales_amount DESC;

-- Query 678
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 679
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-21';

-- Query 680
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 681
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

-- Query 682
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 683
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 684
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 685
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 686
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 687
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 688
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 689
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 690
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 691
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 692
SELECT product_name, price FROM products WHERE price BETWEEN 329 AND 854;

-- Query 693
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

-- Query 694
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 695
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-01' AND '2023-12-31' ORDER BY sales_amount DESC;

-- Query 696
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 697
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 698
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 699
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 700
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 701
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

-- Query 702
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 703
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

-- Query 704
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 705
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-21';

-- Query 706
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

-- Query 707
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 708
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 709
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 710
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-10-09' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 711
SELECT COUNT(*) FROM simple_test WHERE value > 472;

-- Query 712
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 713
SELECT product_name, price FROM products WHERE price BETWEEN 457 AND 932;

-- Query 714
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 715
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

-- Query 716
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

-- Query 717
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 718
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 719
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 720
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 721
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 722
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-10';

-- Query 723
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 724
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 725
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 726
SELECT product_name, price FROM products WHERE price BETWEEN 348 AND 672;

-- Query 727
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 728
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 729
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 730
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 731
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 732
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 733
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 734
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 735
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

-- Query 736
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-06-19' AND '2023-11-11' ORDER BY sales_amount DESC;

-- Query 737
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

-- Query 738
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 739
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 740
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

-- Query 741
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 742
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-21';

-- Query 743
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 744
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 745
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 746
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-01' AND '2023-12-31' ORDER BY sales_amount DESC;

-- Query 747
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 748
SELECT product_name, price FROM products WHERE price BETWEEN 244 AND 818;

-- Query 749
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 750
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 751
SELECT COUNT(*) FROM simple_test WHERE value > 423;

-- Query 752
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 753
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 754
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 755
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 756
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 757
SELECT name, value FROM simple_test WHERE created_date >= '2023-06-05';

-- Query 758
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

-- Query 759
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 760
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 761
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 762
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 763
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 764
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 765
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 766
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 767
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

-- Query 768
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 769
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

-- Query 770
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

-- Query 771
SELECT product_name, price FROM products WHERE price BETWEEN 348 AND 672;

-- Query 772
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 773
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 774
SELECT * FROM orders WHERE order_date = '2023-08-05';

-- Query 775
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 776
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 777
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 778
SELECT product_name, price FROM products WHERE price BETWEEN 348 AND 672;

-- Query 779
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

-- Query 780
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 781
SELECT * FROM orders WHERE order_date = '2023-11-10';

-- Query 782
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 783
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 784
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 785
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 786
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 787
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 788
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

-- Query 789
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 790
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 791
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 792
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-09-13' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 793
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 794
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 795
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 796
SELECT * FROM orders WHERE order_date = '2023-10-27';

-- Query 797
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 798
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 799
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 800
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 801
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3363);

-- Query 802
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 803
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 804
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-11-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 805
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 806
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 807
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 808
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 809
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

-- Query 810
SELECT product_name, price FROM products WHERE price BETWEEN 131 AND 654;

-- Query 811
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 812
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 813
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 814
SELECT * FROM orders WHERE order_date = '2023-10-27';

-- Query 815
SELECT COUNT(*) FROM simple_test WHERE value > 483;

-- Query 816
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 817
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 818
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 819
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 820
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 821
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 822
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 823
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 824
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 825
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 826
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-08-05' AND '2023-12-10' ORDER BY sales_amount DESC;

-- Query 827
SELECT * FROM products WHERE category_id = 5 ORDER BY price;

-- Query 828
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 829
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1784);

-- Query 830
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 831
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 832
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

-- Query 833
SELECT product_name, price FROM products WHERE price BETWEEN 224 AND 732;

-- Query 834
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 835
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 836
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

-- Query 837
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 838
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 839
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 840
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

-- Query 841
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

-- Query 842
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 843
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 844
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-10-26' AND '2023-12-28' ORDER BY sales_amount DESC;

-- Query 845
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 846
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 847
SELECT name, value FROM simple_test WHERE created_date >= '2023-09-21';

-- Query 848
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 849
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-09-13' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 850
SELECT COUNT(*) FROM simple_test WHERE value > 585;

-- Query 851
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 852
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 853
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 854
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 3;

-- Query 855
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 856
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-10-09' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 857
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3813);

-- Query 858
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 859
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 860
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 861
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 862
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 863
SELECT * FROM orders WHERE order_date = '2023-11-10';

-- Query 864
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

-- Query 865
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 866
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 867
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

-- Query 868
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 869
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 4151);

-- Query 870
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 871
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

-- Query 872
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-04-17' AND '2023-11-24' ORDER BY sales_amount DESC;

-- Query 873
SELECT product_name, price FROM products WHERE price BETWEEN 348 AND 672;

-- Query 874
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 875
SELECT product_name, price FROM products WHERE price BETWEEN 244 AND 818;

-- Query 876
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 877
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 878
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 879
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-22' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 880
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 881
SELECT name, value FROM simple_test WHERE created_date >= '2023-12-16';

-- Query 882
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1134);

-- Query 883
SELECT name, value FROM simple_test WHERE created_date >= '2023-10-10';

-- Query 884
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 885
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 886
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 887
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-01-15' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 888
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 889
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 890
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

-- Query 891
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 892
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

-- Query 893
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 894
SELECT COUNT(*) FROM products WHERE stock_quantity < 46;

-- Query 895
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 896
SELECT COUNT(*) FROM simple_test WHERE value > 814;

-- Query 897
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 2083);

-- Query 898
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 899
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 900
SELECT COUNT(*) FROM simple_test WHERE value > 483;

-- Query 901
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 902
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 903
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 904
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-02-28' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 905
SELECT * FROM orders WHERE order_date = '2023-06-28';

-- Query 906
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 907
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-04-17' AND '2023-11-24' ORDER BY sales_amount DESC;

-- Query 908
SELECT * FROM products WHERE category_id = 3 ORDER BY price;

-- Query 909
SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);

-- Query 910
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 911
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3978);

-- Query 912
SELECT COUNT(*) FROM simple_test WHERE value > 393;

-- Query 913
SELECT COUNT(*) FROM simple_test WHERE value > 483;

-- Query 914
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 915
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 916
SELECT name, value FROM simple_test WHERE created_date >= '2023-11-26';

-- Query 917
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 918
SELECT COUNT(*) FROM products WHERE stock_quantity < 39;

-- Query 919
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-16';

-- Query 920
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 921
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 922
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 923
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 924
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 925
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-08-05' AND '2023-12-10' ORDER BY sales_amount DESC;

-- Query 926
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 927
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-04-17' AND '2023-11-24' ORDER BY sales_amount DESC;

-- Query 928
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 929
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 930
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

-- Query 931
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-08' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 932
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

-- Query 933
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 5;

-- Query 934
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 935
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 936
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 6;

-- Query 937
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 938
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 939
SELECT COUNT(*) FROM products WHERE stock_quantity < 26;

-- Query 940
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 941
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 4;

-- Query 942
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 943
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Query 944
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 945
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

-- Query 946
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-08-12' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 947
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 948
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 949
SELECT * FROM orders WHERE order_date = '2023-01-25';

-- Query 950
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 951
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-05-22' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 952
SELECT * FROM orders WHERE order_date = '2023-05-06';

-- Query 953
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 954
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-04-17' AND '2023-11-24' ORDER BY sales_amount DESC;

-- Query 955
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 956
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 957
SELECT * FROM products WHERE category_id = 2 ORDER BY price;

-- Query 958
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-07-28' AND '2023-11-21' ORDER BY sales_amount DESC;

-- Query 959
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 960
SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '2023-03-25' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;

-- Query 961
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 962
SELECT * FROM orders WHERE order_date = '2023-04-02';

-- Query 963
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 964
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 965
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 966
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-06-19' AND '2023-11-11' ORDER BY sales_amount DESC;

-- Query 967
SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;

-- Query 968
SELECT COUNT(*) FROM simple_test WHERE value > 730;

-- Query 969
SELECT COUNT(*) FROM simple_test WHERE value > 730;

-- Query 970
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 971
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 972
SELECT COUNT(*) FROM products WHERE stock_quantity < 25;

-- Query 973
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 974
SELECT * FROM simple_test WHERE category = 'A' ORDER BY id LIMIT 100;

-- Query 975
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 976
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1665);

-- Query 977
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 7;

-- Query 978
SELECT COUNT(*) FROM simple_test WHERE value > 676;

-- Query 979
SELECT COUNT(*) FROM products WHERE stock_quantity < 38;

-- Query 980
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-02-05' AND '2023-11-13' ORDER BY sales_amount DESC;

-- Query 981
SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > 9;

-- Query 982
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 983
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 984
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 985
SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;

-- Query 986
SELECT * FROM sales_summary WHERE date_key BETWEEN '2023-09-18' AND '2023-12-30' ORDER BY sales_amount DESC;

-- Query 987
SELECT COUNT(*) FROM products WHERE stock_quantity < 35;

-- Query 988
SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- Query 989
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 990
SELECT name, value FROM simple_test WHERE created_date >= '2023-01-16';

-- Query 991
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 3813);

-- Query 992
SELECT * FROM simple_test WHERE category = 'B' ORDER BY id LIMIT 100;

-- Query 993
SELECT * FROM products WHERE category_id = 1 ORDER BY price;

-- Query 994
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Query 995
SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1665);

-- Query 996
SELECT COUNT(*) FROM simple_test WHERE value > 812;

-- Query 997
SELECT name, value FROM simple_test WHERE created_date >= '2023-07-07';

-- Query 998
SELECT SUM(total_amount) FROM orders WHERE status = 'processing';

-- Query 999
SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;

-- Query 1000
SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;

