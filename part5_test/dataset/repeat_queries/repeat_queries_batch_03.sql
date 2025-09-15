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

