#!/usr/bin/env python3
"""
生成重复查询集 - 1000个查询，高重复率(80%)
用于测试缓存命中率
"""

import random
import os
from datetime import datetime, timedelta

def generate_base_queries():
    """生成基础查询模板"""
    base_queries = [
        # 简单查询
        "SELECT * FROM simple_test WHERE category = '{category}' ORDER BY id LIMIT 100;",
        "SELECT COUNT(*) FROM simple_test WHERE value > {value};",
        "SELECT name, value FROM simple_test WHERE created_date >= '{date}';",
        
        # 产品查询
        "SELECT * FROM products WHERE category_id = {category_id} ORDER BY price;",
        "SELECT product_name, price FROM products WHERE price BETWEEN {min_price} AND {max_price};",
        "SELECT COUNT(*) FROM products WHERE stock_quantity < {stock};",
        
        # 订单查询
        "SELECT * FROM orders WHERE order_date = '{date}';",
        "SELECT customer_id, COUNT(*) as order_count FROM orders GROUP BY customer_id HAVING COUNT(*) > {count};",
        "SELECT SUM(total_amount) FROM orders WHERE status = '{status}';",
        
        # 连接查询
        "SELECT p.product_name, SUM(oi.quantity) FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.product_name;",
        "SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_name;",
        
        # 复杂聚合查询
        "SELECT category_id, AVG(price), COUNT(*) FROM products GROUP BY category_id ORDER BY AVG(price) DESC;",
        "SELECT DATE(order_date), SUM(total_amount) FROM orders GROUP BY DATE(order_date) ORDER BY DATE(order_date);",
        
        # 子查询
        "SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);",
        "SELECT * FROM customers WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders WHERE total_amount > {amount});",
        
        # 窗口函数查询
        "SELECT product_id, price, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as rank FROM products;",
        "SELECT customer_id, order_date, total_amount, SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total FROM orders;",
        
        # 复杂连接查询
        """SELECT 
            c.customer_name, 
            p.product_name, 
            SUM(oi.quantity * oi.unit_price) as total_spent
        FROM customers c 
        JOIN orders o ON c.customer_id = o.customer_id 
        JOIN order_items oi ON o.order_id = oi.order_id 
        JOIN products p ON oi.product_id = p.product_id 
        GROUP BY c.customer_name, p.product_name 
        ORDER BY total_spent DESC 
        LIMIT 50;""",
        
        # 时间范围查询
        "SELECT * FROM sales_summary WHERE date_key BETWEEN '{start_date}' AND '{end_date}' ORDER BY sales_amount DESC;",
        "SELECT product_id, SUM(sales_amount) FROM sales_summary WHERE date_key >= '{date}' GROUP BY product_id ORDER BY SUM(sales_amount) DESC LIMIT 20;"
    ]
    return base_queries

def generate_parameters():
    """生成查询参数"""
    categories = ['A', 'B', 'C']
    statuses = ['pending', 'processing', 'shipped', 'delivered']
    
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2023, 12, 31)
    
    params = {
        'category': random.choice(categories),
        'category_id': random.randint(1, 5),
        'value': random.randint(100, 900),
        'date': (start_date + timedelta(days=random.randint(0, 364))).strftime('%Y-%m-%d'),
        'start_date': (start_date + timedelta(days=random.randint(0, 300))).strftime('%Y-%m-%d'),
        'end_date': (start_date + timedelta(days=random.randint(300, 364))).strftime('%Y-%m-%d'),
        'min_price': random.randint(10, 500),
        'max_price': random.randint(500, 1000),
        'stock': random.randint(10, 50),
        'count': random.randint(2, 10),
        'status': random.choice(statuses),
        'amount': random.randint(1000, 5000)
    }
    return params

def generate_repeat_queries(num_queries=1000, repeat_rate=0.8):
    """生成重复查询集"""
    base_queries = generate_base_queries()
    queries = []
    
    # 计算重复查询数量
    num_unique = int(num_queries * (1 - repeat_rate))
    num_repeats = num_queries - num_unique
    
    # 生成唯一查询
    unique_queries = []
    for i in range(num_unique):
        query_template = random.choice(base_queries)
        params = generate_parameters()
        try:
            query = query_template.format(**params)
            unique_queries.append(query)
        except KeyError:
            # 如果参数不匹配，使用原查询
            unique_queries.append(query_template)
    
    # 添加唯一查询到结果集
    queries.extend(unique_queries)
    
    # 生成重复查询（从唯一查询中随机选择）
    for i in range(num_repeats):
        queries.append(random.choice(unique_queries))
    
    # 打乱查询顺序
    random.shuffle(queries)
    
    return queries

def save_queries_to_files(queries, output_dir):
    """保存查询到文件"""
    os.makedirs(output_dir, exist_ok=True)
    
    # 保存所有查询到一个文件
    with open(os.path.join(output_dir, 'repeat_queries_all.sql'), 'w', encoding='utf-8') as f:
        for i, query in enumerate(queries, 1):
            f.write(f"-- Query {i}\n")
            f.write(query)
            f.write("\n\n")
    
    # 分批保存查询（每100个查询一个文件）
    batch_size = 100
    for batch_num in range(0, len(queries), batch_size):
        batch_queries = queries[batch_num:batch_num + batch_size]
        filename = f'repeat_queries_batch_{batch_num // batch_size + 1:02d}.sql'
        
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as f:
            for i, query in enumerate(batch_queries, batch_num + 1):
                f.write(f"-- Query {i}\n")
                f.write(query)
                f.write("\n\n")
    
    # 生成查询统计信息
    unique_queries = list(set(queries))
    stats = {
        'total_queries': len(queries),
        'unique_queries': len(unique_queries),
        'repeat_rate': 1 - len(unique_queries) / len(queries),
        'most_frequent_queries': []
    }
    
    # 统计最频繁的查询
    query_counts = {}
    for query in queries:
        query_counts[query] = query_counts.get(query, 0) + 1
    
    sorted_queries = sorted(query_counts.items(), key=lambda x: x[1], reverse=True)
    stats['most_frequent_queries'] = [(query[:100] + '...', count) for query, count in sorted_queries[:10]]
    
    # 保存统计信息
    import json
    with open(os.path.join(output_dir, 'repeat_queries_stats.json'), 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=2, ensure_ascii=False)
    
    return stats

def main():
    """主函数"""
    print("生成重复查询集...")
    
    # 设置随机种子以确保可重现性
    random.seed(42)
    
    # 生成查询
    queries = generate_repeat_queries(num_queries=1000, repeat_rate=0.8)
    
    # 保存查询
    output_dir = os.path.dirname(os.path.abspath(__file__))
    stats = save_queries_to_files(queries, output_dir)
    
    print(f"生成完成！")
    print(f"总查询数: {stats['total_queries']}")
    print(f"唯一查询数: {stats['unique_queries']}")
    print(f"重复率: {stats['repeat_rate']:.2%}")
    print(f"文件保存在: {output_dir}")

if __name__ == "__main__":
    main()