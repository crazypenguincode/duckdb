-- CTE Queries - Complexity: HIGH
-- Total queries: 70

-- Query 1: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 4
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 4: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 5: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 7: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 11: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-05-29'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 1998
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 12: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-17'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 9915 THEN 'High Value'
            WHEN total_spent >= 2872 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 10 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 13: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-08'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 6697 THEN 'High Value'
            WHEN total_spent >= 4845 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 7 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 15: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 4
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 17: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 18: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 4
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 25: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 29: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-10'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 6958 THEN 'High Value'
            WHEN total_spent >= 4042 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 13 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 31: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-01-22'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 2940
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 35: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-16'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 5722
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 36: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 38: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-25'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 8912 THEN 'High Value'
            WHEN total_spent >= 3342 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 11 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 46: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-31'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 10942 THEN 'High Value'
            WHEN total_spent >= 1406 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 15 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 47: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-01-18'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 4394
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 48: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 49: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-17'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 9505 THEN 'High Value'
            WHEN total_spent >= 3557 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 15 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 50: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-17'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 7500 THEN 'High Value'
            WHEN total_spent >= 3813 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 12 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 56: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 5
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 63: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-20'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 13224 THEN 'High Value'
            WHEN total_spent >= 2531 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 8 THEN 'Frequent'
            WHEN order_count >= 5 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 67: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 70: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-05'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 8273
)
SELECT * FROM top_customers WHERE rank <= 10 ORDER BY rank;

-- Query 71: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-12'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 10236 THEN 'High Value'
            WHEN total_spent >= 3735 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 10 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 75: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 76: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-25'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 7610 THEN 'High Value'
            WHEN total_spent >= 3040 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 13 THEN 'Frequent'
            WHEN order_count >= 5 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 78: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-11'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 6555
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 80: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 5
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 81: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-19'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 9609
)
SELECT * FROM top_customers WHERE rank <= 20 ORDER BY rank;

-- Query 83: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 84: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 85: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-03-26'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 8518
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 86: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-30'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 8871 THEN 'High Value'
            WHEN total_spent >= 1254 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 15 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 91: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 5
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 95: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-22'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 5749 THEN 'High Value'
            WHEN total_spent >= 3304 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 8 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 97: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-06'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 8916
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 100: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-23'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 6435
)
SELECT * FROM top_customers WHERE rank <= 20 ORDER BY rank;

-- Query 103: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-02-13'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 5405
)
SELECT * FROM top_customers WHERE rank <= 20 ORDER BY rank;

-- Query 104: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-25'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 14738 THEN 'High Value'
            WHEN total_spent >= 1557 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 9 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 109: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-05-24'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 8570
)
SELECT * FROM top_customers WHERE rank <= 10 ORDER BY rank;

-- Query 113: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-11'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 5681 THEN 'High Value'
            WHEN total_spent >= 4112 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 12 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 116: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 118: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 121: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-13'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 2163
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 123: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-20'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 14975 THEN 'High Value'
            WHEN total_spent >= 1225 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 9 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 128: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-01-20'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 2020
)
SELECT * FROM top_customers WHERE rank <= 20 ORDER BY rank;

-- Query 129: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 4
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 130: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-18'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 6989 THEN 'High Value'
            WHEN total_spent >= 1048 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 5 THEN 'Frequent'
            WHEN order_count >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 133: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-03-23'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 4588
)
SELECT * FROM top_customers WHERE rank <= 10 ORDER BY rank;

-- Query 139: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-31'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 14078 THEN 'High Value'
            WHEN total_spent >= 3957 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 13 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 141: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-11'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 10632 THEN 'High Value'
            WHEN total_spent >= 4310 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 13 THEN 'Frequent'
            WHEN order_count >= 5 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 143: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 5
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 147: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 149: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-03'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 6236
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 152: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-12'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 1077
)
SELECT * FROM top_customers WHERE rank <= 20 ORDER BY rank;

-- Query 155: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 156: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 5
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 157: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-07-19'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 2229
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 163: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 172: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 2
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 177: 递归CTE - 组织层级
WITH RECURSIVE org_hierarchy AS (
    -- 基础情况：顶级分类
    SELECT category_id, category_name, parent_category_id, 0 as level
    FROM categories 
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- 递归情况：子分类
    SELECT c.category_id, c.category_name, c.parent_category_id, oh.level + 1
    FROM categories c
    JOIN org_hierarchy oh ON c.parent_category_id = oh.category_id
    WHERE oh.level < 3
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;

-- Query 178: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-11'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 5767
)
SELECT * FROM top_customers WHERE rank <= 10 ORDER BY rank;

-- Query 180: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-06-17'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 6985
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 181: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-04-03'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 2938
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 190: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-03-29'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 12548 THEN 'High Value'
            WHEN total_spent >= 4672 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 14 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 193: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-01-02'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 8452 THEN 'High Value'
            WHEN total_spent >= 2554 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 14 THEN 'Frequent'
            WHEN order_count >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

-- Query 197: 多层CTE - 销售分析
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '2023-03-23'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
),
customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as active_months,
        AVG(monthly_total) as avg_monthly_spend,
        SUM(monthly_total) as total_spend
    FROM monthly_sales
    GROUP BY customer_id
),
top_customers AS (
    SELECT 
        cs.*,
        c.customer_name,
        ROW_NUMBER() OVER (ORDER BY cs.total_spend DESC) as rank
    FROM customer_stats cs
    JOIN customers c ON cs.customer_id = c.customer_id
    WHERE cs.total_spend > 5382
)
SELECT * FROM top_customers WHERE rank <= 50 ORDER BY rank;

-- Query 200: 嵌套CTE - 客户细分
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.registration_date,
        COUNT(o.order_id) as order_count,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        MIN(o.order_date) as first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date >= '2023-02-07'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 14781 THEN 'High Value'
            WHEN total_spent >= 1947 THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= 5 THEN 'Frequent'
            WHEN order_count >= 4 THEN 'Regular'
            ELSE 'Occasional'
        END as frequency_segment,
        EXTRACT(DAYS FROM (CURRENT_DATE - last_order_date)) as days_since_last_order
    FROM customer_orders
),
segment_analysis AS (
    SELECT 
        value_segment,
        frequency_segment,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_total_spent,
        AVG(order_count) as avg_order_count,
        AVG(days_since_last_order) as avg_days_since_last_order
    FROM customer_segments
    GROUP BY value_segment, frequency_segment
)
SELECT * FROM segment_analysis ORDER BY customer_count DESC;

