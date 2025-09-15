#!/usr/bin/env python3
"""
生成CTE查询集 - 200个查询，复杂CTE结构
用于测试CTE缓存优化
"""

import random
import os
import json
from datetime import datetime, timedelta

def generate_cte_templates():
    """生成CTE查询模板"""
    templates = [
        {
            'id': 1,
            'name': '递归CTE - 组织层级',
            'template': """
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
    WHERE oh.level < {max_level}
)
SELECT * FROM org_hierarchy ORDER BY level, category_name;
""",
            'parameters': ['max_level'],
            'complexity': 'high'
        },
        
        {
            'id': 2,
            'name': '多层CTE - 销售分析',
            'template': """
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        customer_id,
        SUM(total_amount) as monthly_total
    FROM orders 
    WHERE order_date >= '{start_date}'
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
    WHERE cs.total_spend > {min_spend}
)
SELECT * FROM top_customers WHERE rank <= {top_n} ORDER BY rank;
""",
            'parameters': ['start_date', 'min_spend', 'top_n'],
            'complexity': 'high'
        },
        
        {
            'id': 3,
            'name': '窗口函数CTE - 产品趋势',
            'template': """
WITH daily_product_sales AS (
    SELECT 
        ss.date_key,
        ss.product_id,
        SUM(ss.sales_amount) as daily_sales,
        SUM(ss.quantity_sold) as daily_quantity
    FROM sales_summary ss
    WHERE ss.date_key BETWEEN '{start_date}' AND '{end_date}'
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
    WHERE pt.daily_sales > {min_sales}
)
SELECT * FROM trending_products 
WHERE ABS(daily_growth_pct) > {growth_threshold} 
ORDER BY date_key DESC, daily_growth_pct DESC;
""",
            'parameters': ['start_date', 'end_date', 'min_sales', 'growth_threshold'],
            'complexity': 'very_high'
        },
        
        {
            'id': 4,
            'name': '嵌套CTE - 客户细分',
            'template': """
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
    WHERE c.registration_date >= '{reg_start_date}'
    GROUP BY c.customer_id, c.customer_name, c.registration_date
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= {high_value_threshold} THEN 'High Value'
            WHEN total_spent >= {medium_value_threshold} THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_segment,
        CASE 
            WHEN order_count >= {frequent_threshold} THEN 'Frequent'
            WHEN order_count >= {regular_threshold} THEN 'Regular'
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
""",
            'parameters': ['reg_start_date', 'high_value_threshold', 'medium_value_threshold', 'frequent_threshold', 'regular_threshold'],
            'complexity': 'high'
        },
        
        {
            'id': 5,
            'name': '复杂聚合CTE - 供应商绩效',
            'template': """
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
    WHERE o.order_date >= '{analysis_start_date}'
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
WHERE sales_revenue > {min_revenue} 
ORDER BY sales_revenue DESC, inventory_turnover_pct DESC;
""",
            'parameters': ['analysis_start_date', 'min_revenue'],
            'complexity': 'very_high'
        },
        
        {
            'id': 6,
            'name': '时间序列CTE - 销售预测',
            'template': """
WITH daily_totals AS (
    SELECT 
        order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as daily_revenue,
        AVG(total_amount) as avg_order_value
    FROM orders
    WHERE order_date >= '{start_date}'
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
            WHEN ABS(z_score) > {anomaly_threshold} THEN 'Anomaly'
            WHEN z_score > {high_threshold} THEN 'High'
            WHEN z_score < {low_threshold} THEN 'Low'
            ELSE 'Normal'
        END as trend_category
    FROM trend_analysis
    WHERE prev_day_revenue IS NOT NULL
)
SELECT * FROM anomaly_detection 
WHERE trend_category != 'Normal' 
ORDER BY order_date DESC;
""",
            'parameters': ['start_date', 'anomaly_threshold', 'high_threshold', 'low_threshold'],
            'complexity': 'very_high'
        }
    ]
    
    return templates

def generate_simple_cte_templates():
    """生成简单CTE查询模板"""
    simple_templates = [
        {
            'id': 7,
            'name': '基础CTE - 产品统计',
            'template': """
WITH product_stats AS (
    SELECT 
        category_id,
        COUNT(*) as product_count,
        AVG(price) as avg_price,
        MAX(price) as max_price,
        MIN(price) as min_price
    FROM products
    WHERE price > {min_price}
    GROUP BY category_id
)
SELECT 
    ps.*,
    c.category_name
FROM product_stats ps
JOIN categories c ON ps.category_id = c.category_id
ORDER BY ps.avg_price DESC;
""",
            'parameters': ['min_price'],
            'complexity': 'medium'
        },
        
        {
            'id': 8,
            'name': '双CTE - 订单分析',
            'template': """
WITH recent_orders AS (
    SELECT *
    FROM orders
    WHERE order_date >= '{recent_date}'
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
WHERE order_count > {min_count}
ORDER BY total_revenue DESC;
""",
            'parameters': ['recent_date', 'min_count'],
            'complexity': 'medium'
        },
        
        {
            'id': 9,
            'name': '过滤CTE - 活跃客户',
            'template': """
WITH active_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= '{activity_date}'
      AND total_amount > {min_amount}
)
SELECT 
    c.customer_name,
    c.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as recent_spending
FROM active_customers ac
JOIN customers c ON ac.customer_id = c.customer_id
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_date >= '{activity_date}'
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY recent_spending DESC
LIMIT {limit_count};
""",
            'parameters': ['activity_date', 'min_amount', 'limit_count'],
            'complexity': 'medium'
        },
        
        {
            'id': 10,
            'name': '排名CTE - 热销产品',
            'template': """
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity) as total_sold,
        SUM(oi.quantity * oi.unit_price) as total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= '{sales_start_date}'
    GROUP BY p.product_id, p.product_name
    HAVING SUM(oi.quantity) > {min_quantity}
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_sold DESC) as sales_rank,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM product_sales
ORDER BY total_sold DESC
LIMIT {top_products};
""",
            'parameters': ['sales_start_date', 'min_quantity', 'top_products'],
            'complexity': 'medium'
        }
    ]
    
    return simple_templates

def generate_parameter_values():
    """生成CTE查询参数"""
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2023, 12, 31)
    
    return {
        'max_level': random.randint(2, 5),
        'start_date': (start_date + timedelta(days=random.randint(0, 200))).strftime('%Y-%m-%d'),
        'end_date': (start_date + timedelta(days=random.randint(200, 364))).strftime('%Y-%m-%d'),
        'min_spend': random.randint(1000, 10000),
        'top_n': random.choice([10, 20, 50]),
        'min_sales': random.randint(100, 1000),
        'growth_threshold': random.randint(10, 50),
        'reg_start_date': (start_date + timedelta(days=random.randint(0, 100))).strftime('%Y-%m-%d'),
        'high_value_threshold': random.randint(5000, 15000),
        'medium_value_threshold': random.randint(1000, 5000),
        'frequent_threshold': random.randint(5, 15),
        'regular_threshold': random.randint(2, 5),
        'analysis_start_date': (start_date + timedelta(days=random.randint(0, 180))).strftime('%Y-%m-%d'),
        'min_revenue': random.randint(1000, 10000),
        'anomaly_threshold': random.uniform(2.0, 3.0),
        'high_threshold': random.uniform(1.0, 2.0),
        'low_threshold': random.uniform(-2.0, -1.0),
        'min_price': random.randint(10, 100),
        'recent_date': (start_date + timedelta(days=random.randint(300, 364))).strftime('%Y-%m-%d'),
        'min_count': random.randint(1, 10),
        'activity_date': (start_date + timedelta(days=random.randint(250, 364))).strftime('%Y-%m-%d'),
        'min_amount': random.randint(100, 1000),
        'limit_count': random.choice([20, 50, 100]),
        'sales_start_date': (start_date + timedelta(days=random.randint(0, 200))).strftime('%Y-%m-%d'),
        'min_quantity': random.randint(10, 100),
        'top_products': random.choice([10, 25, 50])
    }

def generate_cte_queries(num_queries=200):
    """生成CTE查询集"""
    complex_templates = generate_cte_templates()
    simple_templates = generate_simple_cte_templates()
    all_templates = complex_templates + simple_templates
    
    queries = []
    template_usage = {}
    
    for i in range(num_queries):
        # 70%复杂CTE，30%简单CTE
        if random.random() < 0.7:
            template = random.choice(complex_templates)
        else:
            template = random.choice(simple_templates)
        
        template_id = template['id']
        template_usage[template_id] = template_usage.get(template_id, 0) + 1
        
        params = generate_parameter_values()
        
        try:
            sql_query = template['template'].format(**params)
            
            query_info = {
                'query_id': i + 1,
                'template_id': template_id,
                'template_name': template['name'],
                'complexity': template['complexity'],
                'parameters': {param: params.get(param) for param in template['parameters']},
                'sql_query': sql_query.strip()
            }
            
            queries.append(query_info)
            
        except KeyError as e:
            print(f"参数错误 - 模板 {template_id}: {e}")
            continue
    
    return queries, template_usage, all_templates

def save_cte_queries(queries, template_usage, templates, output_dir):
    """保存CTE查询"""
    os.makedirs(output_dir, exist_ok=True)
    
    # 保存所有查询
    with open(os.path.join(output_dir, 'cte_queries_all.sql'), 'w', encoding='utf-8') as f:
        for query_info in queries:
            f.write(f"-- CTE Query {query_info['query_id']}\n")
            f.write(f"-- Template: {query_info['template_name']} (ID: {query_info['template_id']})\n")
            f.write(f"-- Complexity: {query_info['complexity']}\n")
            f.write(f"-- Parameters: {query_info['parameters']}\n")
            f.write(query_info['sql_query'])
            f.write("\n\n")
    
    # 按复杂度分组保存
    complexity_groups = {}
    for query_info in queries:
        complexity = query_info['complexity']
        if complexity not in complexity_groups:
            complexity_groups[complexity] = []
        complexity_groups[complexity].append(query_info)
    
    for complexity, group_queries in complexity_groups.items():
        filename = f'cte_queries_{complexity}.sql'
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as f:
            f.write(f"-- CTE Queries - Complexity: {complexity.upper()}\n")
            f.write(f"-- Total queries: {len(group_queries)}\n\n")
            
            for query_info in group_queries:
                f.write(f"-- Query {query_info['query_id']}: {query_info['template_name']}\n")
                f.write(query_info['sql_query'])
                f.write("\n\n")
    
    # 保存JSON格式
    with open(os.path.join(output_dir, 'cte_queries.json'), 'w', encoding='utf-8') as f:
        json.dump(queries, f, indent=2, ensure_ascii=False)
    
    # 保存统计信息
    complexity_stats = {}
    for query_info in queries:
        complexity = query_info['complexity']
        complexity_stats[complexity] = complexity_stats.get(complexity, 0) + 1
    
    stats = {
        'total_queries': len(queries),
        'total_templates': len(templates),
        'complexity_distribution': complexity_stats,
        'template_usage': template_usage,
        'template_details': {t['id']: {'name': t['name'], 'complexity': t['complexity']} for t in templates}
    }
    
    with open(os.path.join(output_dir, 'cte_stats.json'), 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=2, ensure_ascii=False)
    
    return stats

def main():
    """主函数"""
    print("生成CTE查询集...")
    
    # 设置随机种子
    random.seed(42)
    
    # 生成CTE查询
    queries, template_usage, templates = generate_cte_queries(num_queries=200)
    
    # 保存查询
    output_dir = os.path.dirname(os.path.abspath(__file__))
    stats = save_cte_queries(queries, template_usage, templates, output_dir)
    
    print(f"生成完成！")
    print(f"总查询数: {stats['total_queries']}")
    print(f"模板数: {stats['total_templates']}")
    print(f"复杂度分布: {stats['complexity_distribution']}")
    print(f"文件保存在: {output_dir}")

if __name__ == "__main__":
    main()