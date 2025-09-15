-- Template 8: 销售趋势分析
-- Parameterized Template: SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN ? AND ? AND s.product_id = ?;

-- Variation 1
-- Parameters: {'start_date': '2023-03-29', 'end_date': '2023-08-17', 'product_id': 853}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-03-29' AND '2023-08-17' AND s.product_id = 853;

-- Variation 2
-- Parameters: {'start_date': '2023-02-13', 'end_date': '2023-08-04', 'product_id': 597}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-13' AND '2023-08-04' AND s.product_id = 597;

-- Variation 3
-- Parameters: {'start_date': '2023-04-08', 'end_date': '2023-11-27', 'product_id': 889}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-08' AND '2023-11-27' AND s.product_id = 889;

-- Variation 4
-- Parameters: {'start_date': '2023-02-10', 'end_date': '2023-07-24', 'product_id': 502}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-10' AND '2023-07-24' AND s.product_id = 502;

-- Variation 5
-- Parameters: {'start_date': '2023-02-05', 'end_date': '2023-08-11', 'product_id': 350}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-05' AND '2023-08-11' AND s.product_id = 350;

-- Variation 6
-- Parameters: {'start_date': '2023-05-19', 'end_date': '2023-09-09', 'product_id': 212}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-19' AND '2023-09-09' AND s.product_id = 212;

-- Variation 7
-- Parameters: {'start_date': '2023-01-08', 'end_date': '2023-10-09', 'product_id': 860}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-08' AND '2023-10-09' AND s.product_id = 860;

-- Variation 8
-- Parameters: {'start_date': '2023-01-21', 'end_date': '2023-11-19', 'product_id': 704}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-21' AND '2023-11-19' AND s.product_id = 704;

-- Variation 9
-- Parameters: {'start_date': '2023-04-16', 'end_date': '2023-09-14', 'product_id': 993}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-16' AND '2023-09-14' AND s.product_id = 993;

-- Variation 10
-- Parameters: {'start_date': '2023-01-28', 'end_date': '2023-11-12', 'product_id': 962}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-28' AND '2023-11-12' AND s.product_id = 962;

-- Variation 11
-- Parameters: {'start_date': '2023-02-12', 'end_date': '2023-11-05', 'product_id': 848}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-12' AND '2023-11-05' AND s.product_id = 848;

-- Variation 12
-- Parameters: {'start_date': '2023-04-27', 'end_date': '2023-12-18', 'product_id': 462}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-27' AND '2023-12-18' AND s.product_id = 462;

-- Variation 13
-- Parameters: {'start_date': '2023-05-21', 'end_date': '2023-10-25', 'product_id': 811}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-21' AND '2023-10-25' AND s.product_id = 811;

-- Variation 14
-- Parameters: {'start_date': '2023-01-01', 'end_date': '2023-12-26', 'product_id': 921}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-01' AND '2023-12-26' AND s.product_id = 921;

-- Variation 15
-- Parameters: {'start_date': '2023-06-10', 'end_date': '2023-12-09', 'product_id': 904}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-10' AND '2023-12-09' AND s.product_id = 904;

-- Variation 16
-- Parameters: {'start_date': '2023-03-14', 'end_date': '2023-12-23', 'product_id': 183}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-03-14' AND '2023-12-23' AND s.product_id = 183;

-- Variation 17
-- Parameters: {'start_date': '2023-05-01', 'end_date': '2023-08-23', 'product_id': 438}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-01' AND '2023-08-23' AND s.product_id = 438;

-- Variation 18
-- Parameters: {'start_date': '2023-06-05', 'end_date': '2023-10-09', 'product_id': 706}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-05' AND '2023-10-09' AND s.product_id = 706;

-- Variation 19
-- Parameters: {'start_date': '2023-06-10', 'end_date': '2023-08-19', 'product_id': 122}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-10' AND '2023-08-19' AND s.product_id = 122;

-- Variation 20
-- Parameters: {'start_date': '2023-01-02', 'end_date': '2023-08-18', 'product_id': 308}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-02' AND '2023-08-18' AND s.product_id = 308;

-- Variation 21
-- Parameters: {'start_date': '2023-07-20', 'end_date': '2023-11-02', 'product_id': 472}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-07-20' AND '2023-11-02' AND s.product_id = 472;

-- Variation 22
-- Parameters: {'start_date': '2023-04-07', 'end_date': '2023-12-27', 'product_id': 861}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-07' AND '2023-12-27' AND s.product_id = 861;

-- Variation 23
-- Parameters: {'start_date': '2023-05-15', 'end_date': '2023-10-05', 'product_id': 463}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-15' AND '2023-10-05' AND s.product_id = 463;

-- Variation 24
-- Parameters: {'start_date': '2023-03-25', 'end_date': '2023-08-25', 'product_id': 895}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-03-25' AND '2023-08-25' AND s.product_id = 895;

-- Variation 25
-- Parameters: {'start_date': '2023-05-14', 'end_date': '2023-10-07', 'product_id': 911}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-14' AND '2023-10-07' AND s.product_id = 911;

-- Variation 26
-- Parameters: {'start_date': '2023-05-24', 'end_date': '2023-11-28', 'product_id': 118}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-24' AND '2023-11-28' AND s.product_id = 118;

-- Variation 27
-- Parameters: {'start_date': '2023-01-08', 'end_date': '2023-11-17', 'product_id': 455}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-08' AND '2023-11-17' AND s.product_id = 455;

-- Variation 28
-- Parameters: {'start_date': '2023-07-15', 'end_date': '2023-11-16', 'product_id': 203}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-07-15' AND '2023-11-16' AND s.product_id = 203;

-- Variation 29
-- Parameters: {'start_date': '2023-04-27', 'end_date': '2023-11-21', 'product_id': 188}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-27' AND '2023-11-21' AND s.product_id = 188;

-- Variation 30
-- Parameters: {'start_date': '2023-05-23', 'end_date': '2023-08-07', 'product_id': 732}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-23' AND '2023-08-07' AND s.product_id = 732;

-- Variation 31
-- Parameters: {'start_date': '2023-04-22', 'end_date': '2023-12-12', 'product_id': 711}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-22' AND '2023-12-12' AND s.product_id = 711;

-- Variation 32
-- Parameters: {'start_date': '2023-06-03', 'end_date': '2023-08-16', 'product_id': 979}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-03' AND '2023-08-16' AND s.product_id = 979;

-- Variation 33
-- Parameters: {'start_date': '2023-02-22', 'end_date': '2023-10-09', 'product_id': 631}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-22' AND '2023-10-09' AND s.product_id = 631;

-- Variation 34
-- Parameters: {'start_date': '2023-06-30', 'end_date': '2023-12-10', 'product_id': 563}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-30' AND '2023-12-10' AND s.product_id = 563;

-- Variation 35
-- Parameters: {'start_date': '2023-04-09', 'end_date': '2023-10-20', 'product_id': 143}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-04-09' AND '2023-10-20' AND s.product_id = 143;

-- Variation 36
-- Parameters: {'start_date': '2023-06-28', 'end_date': '2023-12-21', 'product_id': 826}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-06-28' AND '2023-12-21' AND s.product_id = 826;

-- Variation 37
-- Parameters: {'start_date': '2023-05-20', 'end_date': '2023-12-14', 'product_id': 514}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-20' AND '2023-12-14' AND s.product_id = 514;

-- Variation 38
-- Parameters: {'start_date': '2023-05-01', 'end_date': '2023-12-28', 'product_id': 912}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-05-01' AND '2023-12-28' AND s.product_id = 912;

-- Variation 39
-- Parameters: {'start_date': '2023-02-12', 'end_date': '2023-07-29', 'product_id': 984}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-02-12' AND '2023-07-29' AND s.product_id = 984;

-- Variation 40
-- Parameters: {'start_date': '2023-01-20', 'end_date': '2023-09-29', 'product_id': 85}
SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '2023-01-20' AND '2023-09-29' AND s.product_id = 85;

