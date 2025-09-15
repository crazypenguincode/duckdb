-- CTE查询集 - 复杂CTE结构测试
-- 用于测试DuckDB查询缓存对CTE（公共表表达式）的优化效果

-- Query 1
-- Template: 简单CTE查询
-- Parameters: 基础递归CTE
-- Complexity: 中等
WITH sales_summary AS (
    SELECT 
        customer_id,
        SUM(total_amount) as total_sales,
        COUNT(*) as order_count,
        AVG(total_amount) as avg_order_value
    FROM orders 
    WHERE order_date >= '2023-01-01'
    GROUP BY customer_id
)
SELECT 
    c.customer_name,
    s.total_sales,
    s.order_count,
    s.avg_order_value
FROM customers c
JOIN sales_summary s ON c.customer_id = s.customer_id
WHERE s.total_sales > 1000
ORDER BY s.total_sales DESC
LIMIT 20

-- Query 2
-- Template: 多层CTE查询
-- Parameters: 嵌套CTE结构
-- Complexity: 高
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_trends AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT month) as active_months,
        AVG(monthly_total) as avg_monthly_sales,
        MAX(monthly_total) as peak_monthly_sales,
        MIN(monthly_total) as min_monthly_sales
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        customer_id,
        active_months,
        avg_monthly_sales,
        RANK() OVER (ORDER BY avg_monthly_sales DESC) as sales_rank
    FROM customer_trends
    WHERE active_months >= 3
)
SELECT 
    c.customer_name,
    tc.active_months,
    tc.avg_monthly_sales,
    tc.sales_rank,
    CASE 
        WHEN tc.sales_rank <= 10 THEN 'VIP'
        WHEN tc.sales_rank <= 50 THEN 'Premium'
        ELSE 'Standard'
    END as customer_tier
FROM customers c
JOIN top_customers tc ON c.customer_id = tc.customer_id
ORDER BY tc.sales_rank
LIMIT 100

-- Query 3
-- Template: 递归CTE查询
-- Parameters: 分类层次结构
-- Complexity: 高
WITH RECURSIVE category_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT 
        category_id,
        category_name,
        parent_category_id,
        0 as level,
        category_name as path
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT 
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ch.level + 1,
        ch.path || ' > ' || c.category_name
    FROM categories c
    JOIN category_hierarchy ch ON c.parent_category_id = ch.category_id
),
category_sales AS (
    SELECT 
        p.category_id,
        COUNT(DISTINCT oi.order_id) as order_count,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category_id
)
SELECT 
    ch.path,
    ch.level,
    COALESCE(cs.order_count, 0) as order_count,
    COALESCE(cs.total_revenue, 0) as total_revenue
FROM category_hierarchy ch
LEFT JOIN category_sales cs ON ch.category_id = cs.category_id
ORDER BY ch.level, ch.path

-- Query 4
-- Template: 复杂分析CTE
-- Parameters: 时间序列分析
-- Complexity: 高
WITH daily_sales AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '2023-01-01'
    GROUP BY order_date
),
sales_with_trends AS (
    SELECT 
        order_date,
        order_count,
        daily_revenue,
        avg_order_value,
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue,
        LAG(daily_revenue, 7) OVER (ORDER BY order_date) as prev_week_revenue,
        AVG(daily_revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as rolling_7day_avg
    FROM daily_sales
),
growth_analysis AS (
    SELECT 
        order_date,
        daily_revenue,
        rolling_7day_avg,
        CASE 
            WHEN prev_day_revenue > 0 THEN 
                (daily_revenue - prev_day_revenue) / prev_day_revenue * 100
            ELSE 0 
        END as day_over_day_growth,
        CASE 
            WHEN prev_week_revenue > 0 THEN 
                (daily_revenue - prev_week_revenue) / prev_week_revenue * 100
            ELSE 0 
        END as week_over_week_growth
    FROM sales_with_trends
    WHERE prev_day_revenue IS NOT NULL
)
SELECT 
    order_date,
    daily_revenue,
    rolling_7day_avg,
    day_over_day_growth,
    week_over_week_growth,
    CASE 
        WHEN day_over_day_growth > 20 THEN 'High Growth'
        WHEN day_over_day_growth > 5 THEN 'Moderate Growth'
        WHEN day_over_day_growth > -5 THEN 'Stable'
        WHEN day_over_day_growth > -20 THEN 'Moderate Decline'
        ELSE 'High Decline'
    END as growth_category
FROM growth_analysis
ORDER BY order_date DESC
LIMIT 30

-- Query 5
-- Template: 多表关联CTE
-- Parameters: 复杂业务逻辑
-- Complexity: 高
WITH product_performance AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        COUNT(DISTINCT oi.order_id) as order_frequency,
        SUM(oi.quantity) as total_quantity_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue,
        AVG(oi.unit_price) as avg_selling_price
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
category_benchmarks AS (
    SELECT 
        category_id,
        AVG(total_revenue) as avg_category_revenue,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue) as median_category_revenue,
        MAX(total_revenue) as max_category_revenue
    FROM product_performance
    GROUP BY category_id
),
product_rankings AS (
    SELECT 
        pp.*,
        cb.avg_category_revenue,
        cb.median_category_revenue,
        RANK() OVER (PARTITION BY pp.category_id ORDER BY pp.total_revenue DESC) as category_rank,
        RANK() OVER (ORDER BY pp.total_revenue DESC) as overall_rank,
        CASE 
            WHEN pp.total_revenue > cb.avg_category_revenue * 1.5 THEN 'Star'
            WHEN pp.total_revenue > cb.avg_category_revenue THEN 'Above Average'
            WHEN pp.total_revenue > cb.median_category_revenue THEN 'Average'
            ELSE 'Below Average'
        END as performance_tier
    FROM product_performance pp
    JOIN category_benchmarks cb ON pp.category_id = cb.category_id
)
SELECT 
    c.category_name,
    pr.product_name,
    pr.order_frequency,
    pr.total_quantity_sold,
    pr.total_revenue,
    pr.avg_selling_price,
    pr.category_rank,
    pr.overall_rank,
    pr.performance_tier
FROM product_rankings pr
JOIN categories c ON pr.category_id = c.category_id
WHERE pr.total_revenue > 0
ORDER BY pr.overall_rank
LIMIT 50