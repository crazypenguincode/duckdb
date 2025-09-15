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

