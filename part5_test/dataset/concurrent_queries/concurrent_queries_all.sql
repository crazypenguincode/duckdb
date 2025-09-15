-- 并发查询集 - 高并发访问测试
-- 用于测试DuckDB查询缓存在并发场景下的性能表现

-- Query 1
-- Template: 简单聚合查询（适合并发）
-- Parameters: 基础统计查询
-- Complexity: 低
SELECT 
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    MAX(total_amount) as max_order_value,
    MIN(total_amount) as min_order_value
FROM orders
WHERE order_date >= '2023-01-01'

-- Query 2
-- Template: 分组聚合查询（适合并发）
-- Parameters: 按状态分组
-- Complexity: 低
SELECT 
    status,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY status
ORDER BY total_revenue DESC

-- Query 3
-- Template: 时间范围查询（适合并发）
-- Parameters: 月度统计
-- Complexity: 中等
SELECT 
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as monthly_orders,
    SUM(total_amount) as monthly_revenue,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month

-- Query 4
-- Template: 关联查询（适合并发）
-- Parameters: 客户订单统计
-- Complexity: 中等
SELECT 
    c.customer_name,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2023-01-01'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
ORDER BY total_spent DESC
LIMIT 20

-- Query 5
-- Template: 产品销售查询（适合并发）
-- Parameters: 产品性能分析
-- Complexity: 中等
SELECT 
    p.product_name,
    p.category_id,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    COUNT(DISTINCT oi.order_id) as order_frequency,
    AVG(oi.unit_price) as avg_selling_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2023-01-01'
GROUP BY p.product_id, p.product_name, p.category_id
HAVING SUM(oi.quantity) > 10
ORDER BY total_revenue DESC
LIMIT 30

-- Query 6
-- Template: 简单过滤查询（适合并发）
-- Parameters: 高价值订单
-- Complexity: 低
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    status
FROM orders
WHERE total_amount > 1000
    AND order_date >= '2023-01-01'
ORDER BY total_amount DESC
LIMIT 50

-- Query 7
-- Template: 计数查询（适合并发）
-- Parameters: 分类统计
-- Complexity: 低
SELECT 
    c.category_name,
    COUNT(p.product_id) as product_count,
    AVG(p.price) as avg_price,
    MAX(p.price) as max_price,
    MIN(p.price) as min_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC

-- Query 8
-- Template: 日期范围查询（适合并发）
-- Parameters: 最近订单
-- Complexity: 低
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.order_date DESC
LIMIT 100