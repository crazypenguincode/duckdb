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

