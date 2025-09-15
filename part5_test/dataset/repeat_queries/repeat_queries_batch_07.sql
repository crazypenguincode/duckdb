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

