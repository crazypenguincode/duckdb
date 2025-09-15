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

