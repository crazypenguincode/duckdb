-- Template 3: 子查询客户筛选
-- Parameterized Template: SELECT customer_name FROM customers WHERE registration_date >= ? AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > ?);

-- Variation 1
-- Parameters: {'reg_date': '2023-04-22', 'amount': 2734}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-22' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2734);

-- Variation 2
-- Parameters: {'reg_date': '2023-02-07', 'amount': 1311}
SELECT customer_name FROM customers WHERE registration_date >= '2023-02-07' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1311);

-- Variation 3
-- Parameters: {'reg_date': '2023-03-02', 'amount': 4823}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-02' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4823);

-- Variation 4
-- Parameters: {'reg_date': '2023-03-03', 'amount': 2886}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-03' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2886);

-- Variation 5
-- Parameters: {'reg_date': '2023-03-06', 'amount': 856}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-06' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 856);

-- Variation 6
-- Parameters: {'reg_date': '2023-07-03', 'amount': 1993}
SELECT customer_name FROM customers WHERE registration_date >= '2023-07-03' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1993);

-- Variation 7
-- Parameters: {'reg_date': '2023-06-17', 'amount': 2843}
SELECT customer_name FROM customers WHERE registration_date >= '2023-06-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2843);

-- Variation 8
-- Parameters: {'reg_date': '2023-05-20', 'amount': 3977}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-20' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3977);

-- Variation 9
-- Parameters: {'reg_date': '2023-01-20', 'amount': 2749}
SELECT customer_name FROM customers WHERE registration_date >= '2023-01-20' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2749);

-- Variation 10
-- Parameters: {'reg_date': '2023-04-05', 'amount': 765}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-05' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 765);

-- Variation 11
-- Parameters: {'reg_date': '2023-03-09', 'amount': 3670}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-09' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3670);

-- Variation 12
-- Parameters: {'reg_date': '2023-03-18', 'amount': 3346}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-18' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3346);

-- Variation 13
-- Parameters: {'reg_date': '2023-01-17', 'amount': 1563}
SELECT customer_name FROM customers WHERE registration_date >= '2023-01-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1563);

-- Variation 14
-- Parameters: {'reg_date': '2023-04-21', 'amount': 1990}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-21' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1990);

-- Variation 15
-- Parameters: {'reg_date': '2023-05-09', 'amount': 1525}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-09' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1525);

-- Variation 16
-- Parameters: {'reg_date': '2023-05-08', 'amount': 3912}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-08' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3912);

-- Variation 17
-- Parameters: {'reg_date': '2023-03-22', 'amount': 2171}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-22' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2171);

-- Variation 18
-- Parameters: {'reg_date': '2023-06-07', 'amount': 914}
SELECT customer_name FROM customers WHERE registration_date >= '2023-06-07' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 914);

-- Variation 19
-- Parameters: {'reg_date': '2023-02-25', 'amount': 4640}
SELECT customer_name FROM customers WHERE registration_date >= '2023-02-25' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4640);

-- Variation 20
-- Parameters: {'reg_date': '2023-05-26', 'amount': 3497}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-26' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3497);

-- Variation 21
-- Parameters: {'reg_date': '2023-07-13', 'amount': 3277}
SELECT customer_name FROM customers WHERE registration_date >= '2023-07-13' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3277);

-- Variation 22
-- Parameters: {'reg_date': '2023-02-11', 'amount': 1645}
SELECT customer_name FROM customers WHERE registration_date >= '2023-02-11' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1645);

-- Variation 23
-- Parameters: {'reg_date': '2023-06-17', 'amount': 718}
SELECT customer_name FROM customers WHERE registration_date >= '2023-06-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 718);

-- Variation 24
-- Parameters: {'reg_date': '2023-04-18', 'amount': 2062}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-18' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2062);

-- Variation 25
-- Parameters: {'reg_date': '2023-05-17', 'amount': 3070}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3070);

-- Variation 26
-- Parameters: {'reg_date': '2023-05-24', 'amount': 4505}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-24' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4505);

-- Variation 27
-- Parameters: {'reg_date': '2023-05-24', 'amount': 4424}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-24' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4424);

-- Variation 28
-- Parameters: {'reg_date': '2023-01-02', 'amount': 4369}
SELECT customer_name FROM customers WHERE registration_date >= '2023-01-02' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4369);

-- Variation 29
-- Parameters: {'reg_date': '2023-04-17', 'amount': 805}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 805);

-- Variation 30
-- Parameters: {'reg_date': '2023-05-10', 'amount': 4546}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-10' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4546);

-- Variation 31
-- Parameters: {'reg_date': '2023-04-13', 'amount': 4003}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-13' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4003);

-- Variation 32
-- Parameters: {'reg_date': '2023-06-20', 'amount': 3445}
SELECT customer_name FROM customers WHERE registration_date >= '2023-06-20' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3445);

-- Variation 33
-- Parameters: {'reg_date': '2023-04-17', 'amount': 1754}
SELECT customer_name FROM customers WHERE registration_date >= '2023-04-17' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1754);

-- Variation 34
-- Parameters: {'reg_date': '2023-05-27', 'amount': 4986}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-27' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4986);

-- Variation 35
-- Parameters: {'reg_date': '2023-06-22', 'amount': 4242}
SELECT customer_name FROM customers WHERE registration_date >= '2023-06-22' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4242);

-- Variation 36
-- Parameters: {'reg_date': '2023-07-16', 'amount': 2851}
SELECT customer_name FROM customers WHERE registration_date >= '2023-07-16' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 2851);

-- Variation 37
-- Parameters: {'reg_date': '2023-07-13', 'amount': 1543}
SELECT customer_name FROM customers WHERE registration_date >= '2023-07-13' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 1543);

-- Variation 38
-- Parameters: {'reg_date': '2023-03-03', 'amount': 3934}
SELECT customer_name FROM customers WHERE registration_date >= '2023-03-03' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 3934);

-- Variation 39
-- Parameters: {'reg_date': '2023-05-28', 'amount': 4627}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-28' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 4627);

-- Variation 40
-- Parameters: {'reg_date': '2023-05-15', 'amount': 884}
SELECT customer_name FROM customers WHERE registration_date >= '2023-05-15' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > 884);

