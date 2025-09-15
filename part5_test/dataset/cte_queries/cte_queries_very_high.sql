-- CTE Queries - Complexity: VERY_HIGH
-- Total queries: 69

-- Query 2: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-02-25' AND '2023-10-14'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 489
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 16 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 8: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-21'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 8953 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 9: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-04-16' AND '2023-11-16'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 769
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 16 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 10: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-08'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 1035 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 19: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-12'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 6491 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 21: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-08'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 5050 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 22: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-26'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 9890 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 24: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-04-27' AND '2023-10-11'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 384
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 36 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 26: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-05-25' AND '2023-07-30'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 538
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 33 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 30: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-03-12'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.4404687981360103 THEN 'Anomaly'
            WHEN z_score > 1.1843636703900817 THEN 'High'
            WHEN z_score < -1.9486232828164223 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 32: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-02-10' AND '2023-09-19'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 176
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 20 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 33: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-23'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 3037 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 40: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-02-28'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.3243746667813023 THEN 'Anomaly'
            WHEN z_score > 1.056119228105007 THEN 'High'
            WHEN z_score < -1.6415366576996364 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 41: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-30'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 5712 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 51: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-07-04'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.2242448691075656 THEN 'Anomaly'
            WHEN z_score > 1.1082183819272666 THEN 'High'
            WHEN z_score < -1.154626581398655 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 52: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-25'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 7566 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 54: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-01-02'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 9149 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 57: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-04-29'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.068286258495756 THEN 'Anomaly'
            WHEN z_score > 1.4422080638362849 THEN 'High'
            WHEN z_score < -1.697179564860987 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 58: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-06-15' AND '2023-08-12'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 573
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 47 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 61: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-23'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 1715 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 62: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-06'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 1854 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 65: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-20'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 2402 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 66: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-07-11' AND '2023-07-24'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 453
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 25 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 74: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-16'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 4453 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 77: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-03-15'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.051157687383008 THEN 'Anomaly'
            WHEN z_score > 1.5618168651659436 THEN 'High'
            WHEN z_score < -1.6374762240557155 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 79: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-05'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 6427 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 88: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-01-30' AND '2023-09-10'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 622
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 38 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 89: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-05-19' AND '2023-08-04'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 132
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 28 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 93: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-04-29'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.922226104511222 THEN 'Anomaly'
            WHEN z_score > 1.8471333859196117 THEN 'High'
            WHEN z_score < -1.9075360034731363 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 94: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-28'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 4350 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 96: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-03-07'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.9903235408798565 THEN 'Anomaly'
            WHEN z_score > 1.9572368939126434 THEN 'High'
            WHEN z_score < -1.4760555845959207 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 98: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-03-10' AND '2023-10-29'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 515
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 39 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 101: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-10'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 3526 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 107: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-01-28' AND '2023-07-22'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 327
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 42 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 108: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-03-31'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.3189094742177003 THEN 'Anomaly'
            WHEN z_score > 1.3002640831819403 THEN 'High'
            WHEN z_score < -1.1898140630813019 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 110: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-02'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 7367 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 111: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-02-16' AND '2023-10-23'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 497
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 36 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 112: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-05-05' AND '2023-08-23'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 675
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 42 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 114: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-07-01'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.5322807973704116 THEN 'Anomaly'
            WHEN z_score > 1.5968576858845989 THEN 'High'
            WHEN z_score < -1.8316226353969156 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 119: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-04-08' AND '2023-08-23'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 643
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 46 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 125: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-02-08' AND '2023-09-03'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 922
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 36 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 127: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-03-27'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.9725592359673922 THEN 'Anomaly'
            WHEN z_score > 1.1423734852049683 THEN 'High'
            WHEN z_score < -1.7201747291309637 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 132: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-04-16' AND '2023-12-07'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 189
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 27 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 134: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-06-01' AND '2023-07-27'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 677
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 19 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 135: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-01-06' AND '2023-08-26'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 966
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 43 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 136: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-02-16'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 6213 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 144: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-01-06'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 6535 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 146: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-03-12' AND '2023-10-22'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 506
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 50 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 148: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-05-30'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.481738418816306 THEN 'Anomaly'
            WHEN z_score > 1.3362836538878153 THEN 'High'
            WHEN z_score < -1.7235167500332391 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 150: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-06-18' AND '2023-12-09'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 199
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 40 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 151: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-05-01'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.342669884929 THEN 'Anomaly'
            WHEN z_score > 1.9871915993795066 THEN 'High'
            WHEN z_score < -1.107154876689457 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 159: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-04'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 8997 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 160: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-05-13'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.011644867385914 THEN 'Anomaly'
            WHEN z_score > 1.934371420420165 THEN 'High'
            WHEN z_score < -1.4944324281152668 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 164: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-27'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 3845 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 165: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-04-26' AND '2023-08-23'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 716
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 42 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 166: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-05-30' AND '2023-12-13'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 865
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 44 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 170: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-08'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 2857 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 174: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-02-23'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 6633 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 175: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-29'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 8982 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 176: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-06-27'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.7121991272256984 THEN 'Anomaly'
            WHEN z_score > 1.6408385443398659 THEN 'High'
            WHEN z_score < -1.7233201649776841 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 182: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-01-22'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 4548 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 183: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-07-05' AND '2023-10-15'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 704
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 14 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 185: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-07'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 4365 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

-- Query 186: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-07-13'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.5776511530902706 THEN 'Anomaly'
            WHEN z_score > 1.7741944842449917 THEN 'High'
            WHEN z_score < -1.6018702482001301 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 187: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-02-11' AND '2023-10-27'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 943
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 19 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 188: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-02-19'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.975645900945699 THEN 'Anomaly'
            WHEN z_score > 1.0868428125740375 THEN 'High'
            WHEN z_score < -1.724063129874521 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 194: 时间序列CTE - 销售预测
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-04-04'
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        *,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7day,
        AVG(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30day,
        STDDEV(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as stddev_30day
    FROM daily_totals
),
trend_analysis AS (
    SELECT 
        *,
        daily_revenue - ma_7day as deviation_from_ma7,
        daily_revenue - ma_30day as deviation_from_ma30,
        CASE 
            WHEN stddev_30day > 0 THEN (daily_revenue - ma_30day) / stddev_30day
            ELSE 0 
        END as z_score,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue
    FROM moving_averages
),
anomaly_detection AS (
    SELECT 
        *,
        CASE 
            WHEN ABS(z_score) > 2.555340047420701 THEN 'Anomaly'
            WHEN z_score > 1.8563087387448802 THEN 'High'
            WHEN z_score < -1.803936785863014 THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;

-- Query 195: 窗口函数CTE - 产品趋势
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '2023-03-18' AND '2023-09-22'
    GROUP BY ss.date_key, ss.product_id
),
product_trends AS (
    SELECT 
        *,
        LAG(daily_sales, 1) OVER (PARTITION BY product_id ORDER BY date_key) as prev_day_sales,
        LAG(daily_sales, 7) OVER (PARTITION BY product_id ORDER BY date_key) as week_ago_sales,
        AVG(daily_sales) OVER (PARTITION BY product_id ORDER BY date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as week_avg
    FROM daily_product_sales
),
trending_products AS (
    SELECT 
        pt.*,
        p.product_name,
        CASE 
            WHEN prev_day_sales > 0 THEN (daily_sales - prev_day_sales) / prev_day_sales * 100
            ELSE 0 
        END as daily_growth_pct,
        CASE 
            WHEN week_ago_sales > 0 THEN (daily_sales - week_ago_sales) / week_ago_sales * 100
            ELSE 0 
        END as weekly_growth_pct
    FROM product_trends pt
    JOIN products p ON pt.product_id = p.product_id
    WHERE pt.daily_sales > 201
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > 20 
ORDER BY date_key DESC, daily_growth_pct DESC;

-- Query 196: 复杂聚合CTE - 供应商绩效
WITH supplier_products AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(p.product_id) as product_count,
        AVG(p.price) as avg_product_price,
        SUM(p.stock_quantity) as total_stock
    FROM suppliers s
    LEFT JOIN products p ON s.supplier_id = p.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
),
product_sales AS (
    SELECT 
        p.supplier_id,
        SUM(oi.quantity * oi.unit_price) as total_sales_revenue,
        SUM(oi.quantity) as total_units_sold,
        COUNT(DISTINCT oi.order_id) as orders_involved
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-07'
    GROUP BY p.supplier_id
),
supplier_performance AS (
    SELECT 
        sp.supplier_id,
        sp.supplier_name,
        sp.product_count,
        sp.avg_product_price,
        sp.total_stock,
        COALESCE(ps.total_sales_revenue, 0) as sales_revenue,
        COALESCE(ps.total_units_sold, 0) as units_sold,
        COALESCE(ps.orders_involved, 0) as orders_count,
        CASE 
            WHEN ps.total_units_sold > 0 THEN ps.total_sales_revenue / ps.total_units_sold
            ELSE 0 
        END as avg_unit_price,
        CASE 
            WHEN sp.total_stock > 0 THEN ps.total_units_sold::FLOAT / sp.total_stock * 100
            ELSE 0 
        END as inventory_turnover_pct
    FROM supplier_products sp
    LEFT JOIN product_sales ps ON sp.supplier_id = ps.supplier_id
)
SELECT * FROM supplier_performance 
WHERE sales_revenue > 5694 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;

