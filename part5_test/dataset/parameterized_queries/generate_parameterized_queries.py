#!/usr/bin/env python3
"""
生成参数化查询集 - 500个模板，参数变化
用于测试SQL标准化
"""

import random
import os
import json
from datetime import datetime, timedelta

def generate_query_templates():
    """生成参数化查询模板"""
    templates = [
        {
            'id': 1,
            'template': "SELECT * FROM simple_test WHERE category = ? AND value > ? ORDER BY id LIMIT ?;",
            'sql_template': "SELECT * FROM simple_test WHERE category = '{category}' AND value > {value} ORDER BY id LIMIT {limit};",
            'parameters': ['category', 'value', 'limit'],
            'description': '简单条件查询'
        },
        {
            'id': 2,
            'template': "SELECT COUNT(*) FROM products WHERE price BETWEEN ? AND ? AND category_id = ?;",
            'sql_template': "SELECT COUNT(*) FROM products WHERE price BETWEEN {min_price} AND {max_price} AND category_id = {category_id};",
            'parameters': ['min_price', 'max_price', 'category_id'],
            'description': '价格范围查询'
        },
        {
            'id': 3,
            'template': "SELECT customer_name FROM customers WHERE registration_date >= ? AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > ?);",
            'sql_template': "SELECT customer_name FROM customers WHERE registration_date >= '{reg_date}' AND customer_id IN (SELECT customer_id FROM orders WHERE total_amount > {amount});",
            'parameters': ['reg_date', 'amount'],
            'description': '子查询客户筛选'
        },
        {
            'id': 4,
            'template': "SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = ? GROUP BY p.product_name HAVING SUM(oi.quantity) > ? ORDER BY total_sold DESC LIMIT ?;",
            'sql_template': "SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = {category_id} GROUP BY p.product_name HAVING SUM(oi.quantity) > {min_quantity} ORDER BY total_sold DESC LIMIT {limit};",
            'parameters': ['category_id', 'min_quantity', 'limit'],
            'description': '产品销量统计'
        },
        {
            'id': 5,
            'template': "SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN ? AND ? AND status = ? GROUP BY DATE(order_date) ORDER BY order_day;",
            'sql_template': "SELECT DATE(order_date) as order_day, COUNT(*) as order_count, SUM(total_amount) as daily_revenue FROM orders WHERE order_date BETWEEN '{start_date}' AND '{end_date}' AND status = '{status}' GROUP BY DATE(order_date) ORDER BY order_day;",
            'parameters': ['start_date', 'end_date', 'status'],
            'description': '日销售统计'
        },
        {
            'id': 6,
            'template': "SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= ? GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= ? ORDER BY avg_order_value DESC LIMIT ?;",
            'sql_template': "SELECT c.customer_name, COUNT(o.order_id) as order_count, AVG(o.total_amount) as avg_order_value FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.registration_date >= '{reg_date}' GROUP BY c.customer_id, c.customer_name HAVING COUNT(o.order_id) >= {min_orders} ORDER BY avg_order_value DESC LIMIT {limit};",
            'parameters': ['reg_date', 'min_orders', 'limit'],
            'description': '客户价值分析'
        },
        {
            'id': 7,
            'template': "SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > ? AND price > ?;",
            'sql_template': "SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank FROM products WHERE stock_quantity > {stock} AND price > {min_price};",
            'parameters': ['stock', 'min_price'],
            'description': '产品价格排名'
        },
        {
            'id': 8,
            'template': "SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN ? AND ? AND s.product_id = ?;",
            'sql_template': "SELECT s.date_key, s.product_id, s.sales_amount, LAG(s.sales_amount) OVER (PARTITION BY s.product_id ORDER BY s.date_key) as prev_sales FROM sales_summary s WHERE s.date_key BETWEEN '{start_date}' AND '{end_date}' AND s.product_id = {product_id};",
            'parameters': ['start_date', 'end_date', 'product_id'],
            'description': '销售趋势分析'
        },
        {
            'id': 9,
            'template': "WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= ? GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > ?;",
            'sql_template': "WITH monthly_sales AS (SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total FROM orders WHERE order_date >= '{start_date}' GROUP BY DATE_TRUNC('month', order_date)) SELECT month, monthly_total, monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth FROM monthly_sales WHERE monthly_total > {min_total};",
            'parameters': ['start_date', 'min_total'],
            'description': '月度销售增长分析'
        },
        {
            'id': 10,
            'template': "SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN ? AND ? GROUP BY p.category_id HAVING COUNT(*) > ? ORDER BY total_sold DESC;",
            'sql_template': "SELECT p.category_id, AVG(p.price) as avg_price, COUNT(*) as product_count, SUM(COALESCE(oi.quantity, 0)) as total_sold FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE p.price BETWEEN {min_price} AND {max_price} GROUP BY p.category_id HAVING COUNT(*) > {min_count} ORDER BY total_sold DESC;",
            'parameters': ['min_price', 'max_price', 'min_count'],
            'description': '分类销售分析'
        }
    ]
    
    # 扩展更多模板
    additional_templates = [
        {
            'id': 11,
            'template': "SELECT * FROM orders WHERE customer_id = ? AND order_date >= ? ORDER BY order_date DESC LIMIT ?;",
            'sql_template': "SELECT * FROM orders WHERE customer_id = {customer_id} AND order_date >= '{order_date}' ORDER BY order_date DESC LIMIT {limit};",
            'parameters': ['customer_id', 'order_date', 'limit'],
            'description': '客户订单历史'
        },
        {
            'id': 12,
            'template': "SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < ? GROUP BY supplier_id HAVING COUNT(*) > ?;",
            'sql_template': "SELECT supplier_id, COUNT(*) as product_count, AVG(price) as avg_price FROM products WHERE stock_quantity < {stock_threshold} GROUP BY supplier_id HAVING COUNT(*) > {min_products};",
            'parameters': ['stock_threshold', 'min_products'],
            'description': '供应商库存分析'
        },
        {
            'id': 13,
            'template': "SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = ? GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;",
            'sql_template': "SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as order_count FROM orders WHERE order_date = '{target_date}' GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY hour;",
            'parameters': ['target_date'],
            'description': '小时订单分布'
        }
    ]
    
    templates.extend(additional_templates)
    return templates

def generate_parameter_values():
    """生成参数值"""
    categories = ['A', 'B', 'C']
    statuses = ['pending', 'processing', 'shipped', 'delivered']
    
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2023, 12, 31)
    
    return {
        'category': random.choice(categories),
        'category_id': random.randint(1, 5),
        'value': random.randint(100, 900),
        'limit': random.choice([10, 20, 50, 100]),
        'min_price': random.randint(10, 300),
        'max_price': random.randint(300, 1000),
        'stock': random.randint(5, 50),
        'stock_threshold': random.randint(10, 30),
        'min_products': random.randint(1, 5),
        'min_quantity': random.randint(10, 100),
        'min_orders': random.randint(1, 5),
        'min_count': random.randint(2, 10),
        'min_total': random.randint(1000, 10000),
        'amount': random.randint(500, 5000),
        'customer_id': random.randint(1, 500),
        'product_id': random.randint(1, 1000),
        'status': random.choice(statuses),
        'reg_date': (start_date + timedelta(days=random.randint(0, 200))).strftime('%Y-%m-%d'),
        'start_date': (start_date + timedelta(days=random.randint(0, 200))).strftime('%Y-%m-%d'),
        'end_date': (start_date + timedelta(days=random.randint(200, 364))).strftime('%Y-%m-%d'),
        'order_date': (start_date + timedelta(days=random.randint(0, 364))).strftime('%Y-%m-%d'),
        'target_date': (start_date + timedelta(days=random.randint(0, 364))).strftime('%Y-%m-%d')
    }

def generate_parameterized_queries(templates, num_variations_per_template=40):
    """生成参数化查询"""
    all_queries = []
    template_stats = {}
    
    for template in templates:
        template_queries = []
        
        # 为每个模板生成多个参数变化
        for i in range(num_variations_per_template):
            params = generate_parameter_values()
            
            try:
                # 生成实际SQL查询
                sql_query = template['sql_template'].format(**params)
                
                query_info = {
                    'template_id': template['id'],
                    'template_description': template['description'],
                    'parameters': {param: params.get(param) for param in template['parameters']},
                    'sql_query': sql_query,
                    'parameterized_template': template['template']
                }
                
                template_queries.append(query_info)
                all_queries.append(query_info)
                
            except KeyError as e:
                print(f"参数错误 - 模板 {template['id']}: {e}")
                continue
        
        template_stats[template['id']] = {
            'description': template['description'],
            'generated_queries': len(template_queries),
            'parameters': template['parameters']
        }
    
    return all_queries, template_stats

def save_parameterized_queries(queries, stats, output_dir):
    """保存参数化查询"""
    os.makedirs(output_dir, exist_ok=True)
    
    # 保存所有查询
    with open(os.path.join(output_dir, 'parameterized_queries_all.sql'), 'w', encoding='utf-8') as f:
        for i, query_info in enumerate(queries, 1):
            f.write(f"-- Query {i} (Template {query_info['template_id']}): {query_info['template_description']}\n")
            f.write(f"-- Parameters: {query_info['parameters']}\n")
            f.write(f"-- Template: {query_info['parameterized_template']}\n")
            f.write(query_info['sql_query'])
            f.write("\n\n")
    
    # 按模板分组保存
    template_groups = {}
    for query_info in queries:
        template_id = query_info['template_id']
        if template_id not in template_groups:
            template_groups[template_id] = []
        template_groups[template_id].append(query_info)
    
    for template_id, template_queries in template_groups.items():
        filename = f'template_{template_id:02d}_queries.sql'
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as f:
            f.write(f"-- Template {template_id}: {template_queries[0]['template_description']}\n")
            f.write(f"-- Parameterized Template: {template_queries[0]['parameterized_template']}\n\n")
            
            for i, query_info in enumerate(template_queries, 1):
                f.write(f"-- Variation {i}\n")
                f.write(f"-- Parameters: {query_info['parameters']}\n")
                f.write(query_info['sql_query'])
                f.write("\n\n")
    
    # 保存JSON格式的查询信息
    with open(os.path.join(output_dir, 'parameterized_queries.json'), 'w', encoding='utf-8') as f:
        json.dump(queries, f, indent=2, ensure_ascii=False)
    
    # 保存统计信息
    summary_stats = {
        'total_queries': len(queries),
        'total_templates': len(stats),
        'avg_queries_per_template': len(queries) / len(stats) if stats else 0,
        'template_stats': stats
    }
    
    with open(os.path.join(output_dir, 'parameterized_stats.json'), 'w', encoding='utf-8') as f:
        json.dump(summary_stats, f, indent=2, ensure_ascii=False)
    
    return summary_stats

def main():
    """主函数"""
    print("生成参数化查询集...")
    
    # 设置随机种子
    random.seed(42)
    
    # 生成查询模板
    templates = generate_query_templates()
    
    # 生成参数化查询
    queries, template_stats = generate_parameterized_queries(templates, num_variations_per_template=40)
    
    # 保存查询
    output_dir = os.path.dirname(os.path.abspath(__file__))
    summary_stats = save_parameterized_queries(queries, template_stats, output_dir)
    
    print(f"生成完成！")
    print(f"总查询数: {summary_stats['total_queries']}")
    print(f"模板数: {summary_stats['total_templates']}")
    print(f"平均每模板查询数: {summary_stats['avg_queries_per_template']:.1f}")
    print(f"文件保存在: {output_dir}")

if __name__ == "__main__":
    main()