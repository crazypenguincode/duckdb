-- Template 9: 月度销售增长分析
-- Parameterized Template: WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= ? GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > ?;

-- Variation 1
-- Parameters: {'start_date': '2023-02-16', 'min_total': 3873}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-16' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 3873;

-- Variation 2
-- Parameters: {'start_date': '2023-02-12', 'min_total': 6653}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-12' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6653;

-- Variation 3
-- Parameters: {'start_date': '2023-06-23', 'min_total': 8122}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-23' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 8122;

-- Variation 4
-- Parameters: {'start_date': '2023-06-22', 'min_total': 5183}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-22' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 5183;

-- Variation 5
-- Parameters: {'start_date': '2023-01-09', 'min_total': 6759}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-01-09' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6759;

-- Variation 6
-- Parameters: {'start_date': '2023-01-20', 'min_total': 2816}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-01-20' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2816;

-- Variation 7
-- Parameters: {'start_date': '2023-06-06', 'min_total': 5336}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-06' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 5336;

-- Variation 8
-- Parameters: {'start_date': '2023-04-25', 'min_total': 2194}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-25' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2194;

-- Variation 9
-- Parameters: {'start_date': '2023-02-27', 'min_total': 9039}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-27' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9039;

-- Variation 10
-- Parameters: {'start_date': '2023-07-16', 'min_total': 9759}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-07-16' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9759;

-- Variation 11
-- Parameters: {'start_date': '2023-02-19', 'min_total': 2390}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-19' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2390;

-- Variation 12
-- Parameters: {'start_date': '2023-05-18', 'min_total': 1701}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-05-18' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 1701;

-- Variation 13
-- Parameters: {'start_date': '2023-04-27', 'min_total': 1235}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-27' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 1235;

-- Variation 14
-- Parameters: {'start_date': '2023-01-12', 'min_total': 2979}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-01-12' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2979;

-- Variation 15
-- Parameters: {'start_date': '2023-02-10', 'min_total': 1666}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-10' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 1666;

-- Variation 16
-- Parameters: {'start_date': '2023-06-27', 'min_total': 9570}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-27' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9570;

-- Variation 17
-- Parameters: {'start_date': '2023-07-17', 'min_total': 9686}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-07-17' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9686;

-- Variation 18
-- Parameters: {'start_date': '2023-06-07', 'min_total': 6966}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-07' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6966;

-- Variation 19
-- Parameters: {'start_date': '2023-07-19', 'min_total': 6340}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-07-19' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6340;

-- Variation 20
-- Parameters: {'start_date': '2023-04-10', 'min_total': 8141}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-10' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 8141;

-- Variation 21
-- Parameters: {'start_date': '2023-04-18', 'min_total': 5597}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-18' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 5597;

-- Variation 22
-- Parameters: {'start_date': '2023-03-05', 'min_total': 8581}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-03-05' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 8581;

-- Variation 23
-- Parameters: {'start_date': '2023-05-07', 'min_total': 9701}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-05-07' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9701;

-- Variation 24
-- Parameters: {'start_date': '2023-04-29', 'min_total': 3650}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-29' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 3650;

-- Variation 25
-- Parameters: {'start_date': '2023-01-21', 'min_total': 7977}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-01-21' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 7977;

-- Variation 26
-- Parameters: {'start_date': '2023-01-30', 'min_total': 2097}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-01-30' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2097;

-- Variation 27
-- Parameters: {'start_date': '2023-07-01', 'min_total': 6656}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-07-01' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6656;

-- Variation 28
-- Parameters: {'start_date': '2023-02-07', 'min_total': 2260}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-07' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2260;

-- Variation 29
-- Parameters: {'start_date': '2023-06-15', 'min_total': 4097}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-06-15' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 4097;

-- Variation 30
-- Parameters: {'start_date': '2023-04-01', 'min_total': 8933}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-01' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 8933;

-- Variation 31
-- Parameters: {'start_date': '2023-02-22', 'min_total': 6187}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-22' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 6187;

-- Variation 32
-- Parameters: {'start_date': '2023-02-09', 'min_total': 7628}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-09' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 7628;

-- Variation 33
-- Parameters: {'start_date': '2023-04-02', 'min_total': 2914}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-02' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2914;

-- Variation 34
-- Parameters: {'start_date': '2023-04-03', 'min_total': 7462}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-04-03' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 7462;

-- Variation 35
-- Parameters: {'start_date': '2023-07-06', 'min_total': 8278}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-07-06' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 8278;

-- Variation 36
-- Parameters: {'start_date': '2023-02-14', 'min_total': 2449}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-14' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 2449;

-- Variation 37
-- Parameters: {'start_date': '2023-03-09', 'min_total': 9095}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-03-09' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9095;

-- Variation 38
-- Parameters: {'start_date': '2023-05-04', 'min_total': 9078}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-05-04' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 9078;

-- Variation 39
-- Parameters: {'start_date': '2023-02-11', 'min_total': 3394}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-02-11' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 3394;

-- Variation 40
-- Parameters: {'start_date': '2023-03-19', 'min_total': 3738}
WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '2023-03-19' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > 3738;

