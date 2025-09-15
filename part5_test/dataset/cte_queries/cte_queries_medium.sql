-- CTE Queries - Complexity: MEDIUM
-- Total queries: 61

-- Query 3: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 30
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 6: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-08'
      AND total_amount > 999
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-08'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 14: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 98
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 16: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-05'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 5
ORDER BY total_revenue DESC;

-- Query 20: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 69
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 23: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-29'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 33
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 27: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-13'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 86
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 28: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 94
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 34: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-11-07'
      AND total_amount > 456
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-11-07'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 50;

-- Query 37: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-18'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 72
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 39: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-19'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 14
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 42: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 39
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 43: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-31'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 5
ORDER BY total_revenue DESC;

-- Query 44: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 43
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 45: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-31'
      AND total_amount > 701
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-31'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 53: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 24
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 55: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 89
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 59: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-16'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 6
ORDER BY total_revenue DESC;

-- Query 60: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-01-20'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 47
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 64: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-02'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 78
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 68: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-25'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 15
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 69: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-12-16'
      AND total_amount > 760
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-12-16'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 50;

-- Query 72: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 26
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 73: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-02'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 3
ORDER BY total_revenue DESC;

-- Query 82: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-05'
      AND total_amount > 306
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-05'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 87: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-02-21'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 83
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 90: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-01'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 7
ORDER BY total_revenue DESC;

-- Query 92: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-05'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 7
ORDER BY total_revenue DESC;

-- Query 99: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 50
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 102: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 11
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 105: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-06'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 94
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 106: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-05-25'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 92
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 115: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-04-05'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 68
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 25;

-- Query 117: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-07-05'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 99
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 120: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-15'
      AND total_amount > 761
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-15'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 20;

-- Query 122: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-24'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 92
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 124: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 23
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 126: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-09-08'
      AND total_amount > 519
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-09-08'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 20;

-- Query 131: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-06-07'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 89
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 137: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-18'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 7
ORDER BY total_revenue DESC;

-- Query 138: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-10'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 10
ORDER BY total_revenue DESC;

-- Query 140: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-02-17'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 67
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 10;

-- Query 142: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 18
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 145: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 82
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 153: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-10'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 7
ORDER BY total_revenue DESC;

-- Query 154: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-29'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 9
ORDER BY total_revenue DESC;

-- Query 158: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-18'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 2
ORDER BY total_revenue DESC;

-- Query 161: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 93
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 162: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-23'
      AND total_amount > 949
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-23'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 167: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 80
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 168: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-20'
      AND total_amount > 577
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-20'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 169: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 38
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 171: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-12-22'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 2
ORDER BY total_revenue DESC;

-- Query 173: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-10-16'
      AND total_amount > 793
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-10-16'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 100;

-- Query 179: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-12'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 43
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 50;

-- Query 184: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 99
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 189: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 19
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 191: 双CTE - 订单分析
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '2023-11-23'
),
order_summary AS (
    SELECT 
        status,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue,
        AVG(total_amount) as avg_order_value
    FROM recent_orders
    GROUP BY status
)
SELECT * FROM order_summary 
WHERE order_count > 4
ORDER BY total_revenue DESC;

-- Query 192: 基础CTE - 产品统计
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > 38
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;

-- Query 198: 排名CTE - 热销产品
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '2023-03-25'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > 70
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT 25;

-- Query 199: 过滤CTE - 活跃客户
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '2023-09-27'
      AND total_amount > 410
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '2023-09-27'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT 20;

