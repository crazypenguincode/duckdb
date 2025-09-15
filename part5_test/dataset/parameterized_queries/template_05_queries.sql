-- Template 5: 日销售统计
-- Parameterized Template: SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN ? AND ? AND status = ? GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 1
-- Parameters: {'start_date': '2023-02-10', 'end_date': '2023-09-23', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-10' AND '2023-09-23' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 2
-- Parameters: {'start_date': '2023-03-24', 'end_date': '2023-09-21', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-24' AND '2023-09-21' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 3
-- Parameters: {'start_date': '2023-03-21', 'end_date': '2023-10-11', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-21' AND '2023-10-11' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 4
-- Parameters: {'start_date': '2023-01-02', 'end_date': '2023-11-01', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-02' AND '2023-11-01' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 5
-- Parameters: {'start_date': '2023-07-02', 'end_date': '2023-09-29', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-07-02' AND '2023-09-29' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 6
-- Parameters: {'start_date': '2023-03-16', 'end_date': '2023-09-24', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-16' AND '2023-09-24' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 7
-- Parameters: {'start_date': '2023-01-31', 'end_date': '2023-12-04', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-31' AND '2023-12-04' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 8
-- Parameters: {'start_date': '2023-05-12', 'end_date': '2023-08-01', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-12' AND '2023-08-01' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 9
-- Parameters: {'start_date': '2023-02-20', 'end_date': '2023-10-30', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-20' AND '2023-10-30' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 10
-- Parameters: {'start_date': '2023-05-27', 'end_date': '2023-11-07', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-27' AND '2023-11-07' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 11
-- Parameters: {'start_date': '2023-05-21', 'end_date': '2023-11-19', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-21' AND '2023-11-19' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 12
-- Parameters: {'start_date': '2023-05-09', 'end_date': '2023-10-10', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-09' AND '2023-10-10' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 13
-- Parameters: {'start_date': '2023-05-17', 'end_date': '2023-08-03', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-17' AND '2023-08-03' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 14
-- Parameters: {'start_date': '2023-01-10', 'end_date': '2023-08-12', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-10' AND '2023-08-12' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 15
-- Parameters: {'start_date': '2023-01-29', 'end_date': '2023-12-01', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-29' AND '2023-12-01' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 16
-- Parameters: {'start_date': '2023-03-20', 'end_date': '2023-10-03', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-20' AND '2023-10-03' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 17
-- Parameters: {'start_date': '2023-03-30', 'end_date': '2023-10-09', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-30' AND '2023-10-09' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 18
-- Parameters: {'start_date': '2023-04-16', 'end_date': '2023-11-23', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-04-16' AND '2023-11-23' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 19
-- Parameters: {'start_date': '2023-02-11', 'end_date': '2023-08-08', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-11' AND '2023-08-08' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 20
-- Parameters: {'start_date': '2023-06-28', 'end_date': '2023-12-08', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-06-28' AND '2023-12-08' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 21
-- Parameters: {'start_date': '2023-06-10', 'end_date': '2023-12-20', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-06-10' AND '2023-12-20' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 22
-- Parameters: {'start_date': '2023-04-05', 'end_date': '2023-10-25', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-04-05' AND '2023-10-25' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 23
-- Parameters: {'start_date': '2023-05-31', 'end_date': '2023-09-16', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-31' AND '2023-09-16' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 24
-- Parameters: {'start_date': '2023-02-12', 'end_date': '2023-09-12', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-12' AND '2023-09-12' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 25
-- Parameters: {'start_date': '2023-04-28', 'end_date': '2023-07-23', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-04-28' AND '2023-07-23' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 26
-- Parameters: {'start_date': '2023-03-09', 'end_date': '2023-10-26', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-09' AND '2023-10-26' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 27
-- Parameters: {'start_date': '2023-05-02', 'end_date': '2023-09-26', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-02' AND '2023-09-26' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 28
-- Parameters: {'start_date': '2023-07-09', 'end_date': '2023-11-21', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-07-09' AND '2023-11-21' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 29
-- Parameters: {'start_date': '2023-04-27', 'end_date': '2023-08-01', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-04-27' AND '2023-08-01' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 30
-- Parameters: {'start_date': '2023-05-22', 'end_date': '2023-10-17', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-22' AND '2023-10-17' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 31
-- Parameters: {'start_date': '2023-02-03', 'end_date': '2023-09-02', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-03' AND '2023-09-02' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 32
-- Parameters: {'start_date': '2023-01-27', 'end_date': '2023-07-21', 'status': 'delivered'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-27' AND '2023-07-21' AND status = 'delivered' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 33
-- Parameters: {'start_date': '2023-02-08', 'end_date': '2023-11-29', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-08' AND '2023-11-29' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 34
-- Parameters: {'start_date': '2023-07-05', 'end_date': '2023-09-14', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-07-05' AND '2023-09-14' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 35
-- Parameters: {'start_date': '2023-03-27', 'end_date': '2023-08-11', 'status': 'processing'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-27' AND '2023-08-11' AND status = 'processing' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 36
-- Parameters: {'start_date': '2023-04-08', 'end_date': '2023-12-02', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-04-08' AND '2023-12-02' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 37
-- Parameters: {'start_date': '2023-01-15', 'end_date': '2023-07-21', 'status': 'shipped'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-01-15' AND '2023-07-21' AND status = 'shipped' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 38
-- Parameters: {'start_date': '2023-02-21', 'end_date': '2023-10-23', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-02-21' AND '2023-10-23' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 39
-- Parameters: {'start_date': '2023-03-16', 'end_date': '2023-11-13', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-03-16' AND '2023-11-13' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

-- Variation 40
-- Parameters: {'start_date': '2023-05-10', 'end_date': '2023-09-01', 'status': 'pending'}
SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '2023-05-10' AND '2023-09-01' AND status = 'pending' GROUP BY DATE(order_date) ORDER BY order_day;

