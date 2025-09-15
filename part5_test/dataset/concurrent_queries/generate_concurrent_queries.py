#!/usr/bin/env python3
"""
生成并发查询集 - 100个查询，高并发访问
用于测试并发性能
"""

import random
import os
import json
import threading
import time
from datetime import datetime, timedelta

def generate_concurrent_query_templates():
    """生成适合并发测试的查询模板"""
    templates = [
        {
            'id': 1,
            'name': '快速聚合查询',
            'template': "SELECT COUNT(*), AVG(price) FROM products WHERE category_id = {category_id};",
            'parameters': ['category_id'],
            'expected_duration': 'fast',  # < 100ms
            'concurrency_level': 'high'
        },
        {
            'id': 2,
            'name': '简单连接查询',
            'template': "SELECT c.customer_name, COUNT(o.order_id) FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.customer_id BETWEEN {start_id} AND {end_id} GROUP BY c.customer_id, c.customer_name;",
            'parameters': ['start_id', 'end_id'],
            'expected_duration': 'fast',
            'concurrency_level': 'high'
        },
        {
            'id': 3,
            'name': '日期范围查询',
            'template': "SELECT DATE(order_date), COUNT(*), SUM(total_amount) FROM orders WHERE order_date BETWEEN '{start_date}' AND '{end_date}' GROUP BY DATE(order_date) ORDER BY DATE(order_date);",
            'parameters': ['start_date', 'end_date'],
            'expected_duration': 'medium',  # 100-500ms
            'concurrency_level': 'medium'
        },
        {
            'id': 4,
            'name': '产品销量查询',
            'template': "SELECT p.product_name, SUM(oi.quantity) as total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id WHERE p.category_id = {category_id} GROUP BY p.product_id, p.product_name ORDER BY total_sold DESC LIMIT {limit};",
            'parameters': ['category_id', 'limit'],
            'expected_duration': 'medium',
            'concurrency_level': 'medium'
        },
        {
            'id': 5,
            'name': '客户统计查询',
            'template': "SELECT status, COUNT(*) as order_count, AVG(total_amount) as avg_amount FROM orders WHERE customer_id = {customer_id} GROUP BY status;",
            'parameters': ['customer_id'],
            'expected_duration': 'fast',
            'concurrency_level': 'high'
        },
        {
            'id': 6,
            'name': '库存检查查询',
            'template': "SELECT product_id, product_name, stock_quantity FROM products WHERE stock_quantity < {threshold} AND category_id = {category_id} ORDER BY stock_quantity;",
            'parameters': ['threshold', 'category_id'],
            'expected_duration': 'fast',
            'concurrency_level': 'high'
        },
        {
            'id': 7,
            'name': '复杂分析查询',
            'template': """
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '{start_date}'
  AND p.price > {min_price}
GROUP BY p.category_id
HAVING SUM(oi.quantity * oi.unit_price) > {min_revenue}
ORDER BY total_revenue DESC;
""",
            'parameters': ['start_date', 'min_price', 'min_revenue'],
            'expected_duration': 'slow',  # > 500ms
            'concurrency_level': 'low'
        },
        {
            'id': 8,
            'name': '窗口函数查询',
            'template': """
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as running_total
FROM orders
WHERE order_date >= '{start_date}'
  AND customer_id BETWEEN {start_customer} AND {end_customer}
ORDER BY customer_id, order_date DESC;
""",
            'parameters': ['start_date', 'start_customer', 'end_customer'],
            'expected_duration': 'medium',
            'concurrency_level': 'medium'
        },
        {
            'id': 9,
            'name': '子查询性能测试',
            'template': """
SELECT 
    p.product_name,
    p.price,
    (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as category_avg_price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.product_id) as times_ordered
FROM products p
WHERE p.price > {min_price}
  AND p.category_id = {category_id}
ORDER BY p.price DESC
LIMIT {limit};
""",
            'parameters': ['min_price', 'category_id', 'limit'],
            'expected_duration': 'slow',
            'concurrency_level': 'low'
        },
        {
            'id': 10,
            'name': '简单计数查询',
            'template': "SELECT COUNT(*) FROM simple_test WHERE category = '{category}' AND value > {value};",
            'parameters': ['category', 'value'],
            'expected_duration': 'fast',
            'concurrency_level': 'high'
        }
    ]
    
    return templates

def generate_parameter_values():
    """生成查询参数"""
    categories = ['A', 'B', 'C']
    start_date = datetime(2023, 1, 1)
    
    return {
        'category_id': random.randint(1, 5),
        'start_id': random.randint(1, 400),
        'end_id': random.randint(401, 500),
        'start_date': (start_date + timedelta(days=random.randint(0, 200))).strftime('%Y-%m-%d'),
        'end_date': (start_date + timedelta(days=random.randint(200, 364))).strftime('%Y-%m-%d'),
        'limit': random.choice([10, 20, 50]),
        'customer_id': random.randint(1, 500),
        'threshold': random.randint(10, 50),
        'min_price': random.randint(10, 500),
        'min_revenue': random.randint(1000, 10000),
        'start_customer': random.randint(1, 400),
        'end_customer': random.randint(401, 500),
        'category': random.choice(categories),
        'value': random.randint(100, 900)
    }

def generate_concurrent_scenarios():
    """生成并发测试场景"""
    scenarios = [
        {
            'name': '高并发轻量查询',
            'description': '大量简单快速查询同时执行',
            'concurrent_users': 50,
            'queries_per_user': 20,
            'query_types': ['fast'],
            'think_time_range': (0.1, 0.5),  # 用户思考时间（秒）
            'ramp_up_time': 10  # 启动时间（秒）
        },
        {
            'name': '中等并发混合查询',
            'description': '中等数量的混合复杂度查询',
            'concurrent_users': 20,
            'queries_per_user': 15,
            'query_types': ['fast', 'medium'],
            'think_time_range': (0.5, 2.0),
            'ramp_up_time': 15
        },
        {
            'name': '低并发重型查询',
            'description': '少量复杂查询并发执行',
            'concurrent_users': 5,
            'queries_per_user': 10,
            'query_types': ['medium', 'slow'],
            'think_time_range': (1.0, 3.0),
            'ramp_up_time': 5
        },
        {
            'name': '混合负载测试',
            'description': '各种类型查询混合并发',
            'concurrent_users': 30,
            'queries_per_user': 12,
            'query_types': ['fast', 'medium', 'slow'],
            'think_time_range': (0.2, 1.5),
            'ramp_up_time': 20
        },
        {
            'name': '缓存命中测试',
            'description': '重复查询测试缓存效果',
            'concurrent_users': 25,
            'queries_per_user': 25,
            'query_types': ['fast', 'medium'],
            'think_time_range': (0.1, 0.3),
            'ramp_up_time': 8,
            'repeat_queries': True,
            'repeat_rate': 0.7
        }
    ]
    
    return scenarios

def generate_concurrent_queries(templates, scenarios):
    """生成并发查询集"""
    all_queries = []
    scenario_queries = {}
    
    for scenario in scenarios:
        scenario_name = scenario['name']
        scenario_queries[scenario_name] = []
        
        # 过滤符合条件的模板
        suitable_templates = [
            t for t in templates 
            if t['expected_duration'] in scenario['query_types']
        ]
        
        total_queries = scenario['concurrent_users'] * scenario['queries_per_user']
        
        # 生成查询
        queries = []
        for i in range(total_queries):
            template = random.choice(suitable_templates)
            params = generate_parameter_values()
            
            try:
                sql_query = template['template'].format(**params)
                
                query_info = {
                    'scenario': scenario_name,
                    'query_id': i + 1,
                    'template_id': template['id'],
                    'template_name': template['name'],
                    'expected_duration': template['expected_duration'],
                    'concurrency_level': template['concurrency_level'],
                    'user_id': (i % scenario['concurrent_users']) + 1,
                    'execution_order': i + 1,
                    'think_time': random.uniform(*scenario['think_time_range']),
                    'parameters': {param: params.get(param) for param in template['parameters']},
                    'sql_query': sql_query.strip()
                }
                
                queries.append(query_info)
                
            except KeyError as e:
                print(f"参数错误 - 模板 {template['id']}: {e}")
                continue
        
        # 处理重复查询
        if scenario.get('repeat_queries', False):
            repeat_rate = scenario.get('repeat_rate', 0.5)
            num_unique = int(len(queries) * (1 - repeat_rate))
            unique_queries = queries[:num_unique]
            
            # 用重复查询替换部分查询
            for i in range(num_unique, len(queries)):
                original_query = random.choice(unique_queries)
                repeated_query = original_query.copy()
                repeated_query['query_id'] = i + 1
                repeated_query['execution_order'] = i + 1
                repeated_query['user_id'] = (i % scenario['concurrent_users']) + 1
                repeated_query['is_repeat'] = True
                repeated_query['original_query_id'] = original_query['query_id']
                queries[i] = repeated_query
        
        scenario_queries[scenario_name] = queries
        all_queries.extend(queries)
    
    return all_queries, scenario_queries

def save_concurrent_queries(all_queries, scenario_queries, scenarios, templates, output_dir):
    """保存并发查询"""
    os.makedirs(output_dir, exist_ok=True)
    
    # 保存所有查询
    with open(os.path.join(output_dir, 'concurrent_queries_all.sql'), 'w', encoding='utf-8') as f:
        for query_info in all_queries:
            f.write(f"-- Concurrent Query {query_info['query_id']}\n")
            f.write(f"-- Scenario: {query_info['scenario']}\n")
            f.write(f"-- Template: {query_info['template_name']} (ID: {query_info['template_id']})\n")
            f.write(f"-- User: {query_info['user_id']}, Duration: {query_info['expected_duration']}\n")
            f.write(f"-- Think Time: {query_info['think_time']:.2f}s\n")
            if query_info.get('is_repeat'):
                f.write(f"-- Repeat of Query {query_info['original_query_id']}\n")
            f.write(query_info['sql_query'])
            f.write("\n\n")
    
    # 按场景保存查询
    for scenario_name, queries in scenario_queries.items():
        safe_name = scenario_name.replace(' ', '_').lower()
        filename = f'concurrent_queries_{safe_name}.sql'
        
        with open(os.path.join(output_dir, filename), 'w', encoding='utf-8') as f:
            f.write(f"-- Concurrent Queries - Scenario: {scenario_name}\n")
            f.write(f"-- Total queries: {len(queries)}\n\n")
            
            for query_info in queries:
                f.write(f"-- Query {query_info['query_id']} (User {query_info['user_id']})\n")
                f.write(f"-- Think Time: {query_info['think_time']:.2f}s\n")
                f.write(query_info['sql_query'])
                f.write("\n\n")
    
    # 生成并发测试脚本
    generate_concurrent_test_scripts(scenario_queries, scenarios, output_dir)
    
    # 保存JSON格式
    with open(os.path.join(output_dir, 'concurrent_queries.json'), 'w', encoding='utf-8') as f:
        json.dump(all_queries, f, indent=2, ensure_ascii=False)
    
    # 保存统计信息
    stats = {
        'total_queries': len(all_queries),
        'total_scenarios': len(scenarios),
        'scenario_stats': {},
        'duration_distribution': {},
        'template_usage': {}
    }
    
    for scenario_name, queries in scenario_queries.items():
        scenario_info = next(s for s in scenarios if s['name'] == scenario_name)
        stats['scenario_stats'][scenario_name] = {
            'query_count': len(queries),
            'concurrent_users': scenario_info['concurrent_users'],
            'queries_per_user': scenario_info['queries_per_user'],
            'ramp_up_time': scenario_info['ramp_up_time']
        }
    
    for query_info in all_queries:
        duration = query_info['expected_duration']
        template_id = query_info['template_id']
        
        stats['duration_distribution'][duration] = stats['duration_distribution'].get(duration, 0) + 1
        stats['template_usage'][template_id] = stats['template_usage'].get(template_id, 0) + 1
    
    with open(os.path.join(output_dir, 'concurrent_stats.json'), 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=2, ensure_ascii=False)
    
    return stats

def generate_concurrent_test_scripts(scenario_queries, scenarios, output_dir):
    """生成并发测试脚本"""
    
    # 生成Python并发测试脚本
    script_content = '''#!/usr/bin/env python3
"""
并发查询测试脚本
"""

import threading
import time
import json
import sqlite3
import statistics
from datetime import datetime
import os

class ConcurrentQueryTester:
    def __init__(self, db_path, scenario_name, queries):
        self.db_path = db_path
        self.scenario_name = scenario_name
        self.queries = queries
        self.results = []
        self.lock = threading.Lock()
    
    def execute_user_queries(self, user_id, user_queries):
        """执行单个用户的查询"""
        user_results = []
        
        try:
            conn = sqlite3.connect(self.db_path)
            conn.execute("PRAGMA cache_size = 10000")  # 设置缓存
            
            for query_info in user_queries:
                # 思考时间
                time.sleep(query_info['think_time'])
                
                start_time = time.time()
                try:
                    cursor = conn.execute(query_info['sql_query'])
                    results = cursor.fetchall()
                    end_time = time.time()
                    
                    execution_time = (end_time - start_time) * 1000  # 转换为毫秒
                    
                    result = {
                        'user_id': user_id,
                        'query_id': query_info['query_id'],
                        'template_id': query_info['template_id'],
                        'execution_time_ms': execution_time,
                        'result_count': len(results),
                        'success': True,
                        'timestamp': datetime.now().isoformat(),
                        'is_repeat': query_info.get('is_repeat', False)
                    }
                    
                except Exception as e:
                    result = {
                        'user_id': user_id,
                        'query_id': query_info['query_id'],
                        'template_id': query_info['template_id'],
                        'execution_time_ms': 0,
                        'result_count': 0,
                        'success': False,
                        'error': str(e),
                        'timestamp': datetime.now().isoformat(),
                        'is_repeat': query_info.get('is_repeat', False)
                    }
                
                user_results.append(result)
            
            conn.close()
            
        except Exception as e:
            print(f"User {user_id} connection error: {e}")
        
        # 线程安全地添加结果
        with self.lock:
            self.results.extend(user_results)
    
    def run_concurrent_test(self):
        """运行并发测试"""
        print(f"开始并发测试: {self.scenario_name}")
        
        # 按用户分组查询
        user_queries = {}
        for query_info in self.queries:
            user_id = query_info['user_id']
            if user_id not in user_queries:
                user_queries[user_id] = []
            user_queries[user_id].append(query_info)
        
        # 创建线程
        threads = []
        start_time = time.time()
        
        for user_id, queries in user_queries.items():
            thread = threading.Thread(
                target=self.execute_user_queries,
                args=(user_id, queries)
            )
            threads.append(thread)
        
        # 启动线程
        for thread in threads:
            thread.start()
        
        # 等待所有线程完成
        for thread in threads:
            thread.join()
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # 分析结果
        return self.analyze_results(total_time)
    
    def analyze_results(self, total_time):
        """分析测试结果"""
        successful_results = [r for r in self.results if r['success']]
        failed_results = [r for r in self.results if not r['success']]
        
        if not successful_results:
            return {
                'scenario': self.scenario_name,
                'total_time': total_time,
                'total_queries': len(self.results),
                'successful_queries': 0,
                'failed_queries': len(failed_results),
                'success_rate': 0.0
            }
        
        execution_times = [r['execution_time_ms'] for r in successful_results]
        
        analysis = {
            'scenario': self.scenario_name,
            'total_time': total_time,
            'total_queries': len(self.results),
            'successful_queries': len(successful_results),
            'failed_queries': len(failed_results),
            'success_rate': len(successful_results) / len(self.results) * 100,
            'avg_execution_time_ms': statistics.mean(execution_times),
            'median_execution_time_ms': statistics.median(execution_times),
            'min_execution_time_ms': min(execution_times),
            'max_execution_time_ms': max(execution_times),
            'std_execution_time_ms': statistics.stdev(execution_times) if len(execution_times) > 1 else 0,
            'queries_per_second': len(successful_results) / total_time,
            'concurrent_users': len(set(r['user_id'] for r in self.results))
        }
        
        return analysis

def main():
    """主函数"""
    import sys
    
    if len(sys.argv) != 3:
        print("Usage: python concurrent_test.py <db_path> <scenario_name>")
        sys.exit(1)
    
    db_path = sys.argv[1]
    scenario_name = sys.argv[2]
    
    # 加载查询数据
    with open('concurrent_queries.json', 'r', encoding='utf-8') as f:
        all_queries = json.load(f)
    
    # 过滤指定场景的查询
    scenario_queries = [q for q in all_queries if q['scenario'] == scenario_name]
    
    if not scenario_queries:
        print(f"未找到场景: {scenario_name}")
        sys.exit(1)
    
    # 运行测试
    tester = ConcurrentQueryTester(db_path, scenario_name, scenario_queries)
    results = tester.run_concurrent_test()
    
    # 保存结果
    output_file = f"concurrent_test_results_{scenario_name.replace(' ', '_').lower()}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    # 打印结果
    print(f"\\n测试完成: {scenario_name}")
    print(f"总查询数: {results['total_queries']}")
    print(f"成功查询数: {results['successful_queries']}")
    print(f"成功率: {results['success_rate']:.2f}%")
    print(f"平均执行时间: {results['avg_execution_time_ms']:.2f}ms")
    print(f"QPS: {results['queries_per_second']:.2f}")
    print(f"并发用户数: {results['concurrent_users']}")
    print(f"结果已保存到: {output_file}")

if __name__ == "__main__":
    main()
'''
    
    with open(os.path.join(output_dir, 'concurrent_test.py'), 'w', encoding='utf-8') as f:
        f.write(script_content)
    
    # 生成批处理脚本
    batch_script = '''#!/bin/bash
# 并发测试批处理脚本

DB_PATH="$1"
if [ -z "$DB_PATH" ]; then
    echo "Usage: $0 <database_path>"
    exit 1
fi

echo "开始并发测试..."
echo "数据库路径: $DB_PATH"
echo "测试时间: $(date)"
echo

# 测试所有场景
scenarios=("高并发轻量查询" "中等并发混合查询" "低并发重型查询" "混合负载测试" "缓存命中测试")

for scenario in "${scenarios[@]}"; do
    echo "正在测试场景: $scenario"
    python3 concurrent_test.py "$DB_PATH" "$scenario"
    echo "等待5秒后开始下一个测试..."
    sleep 5
    echo
done

echo "所有并发测试完成！"
'''
    
    with open(os.path.join(output_dir, 'run_concurrent_tests.sh'), 'w', encoding='utf-8') as f:
        f.write(batch_script)
    
    # 设置执行权限
    os.chmod(os.path.join(output_dir, 'run_concurrent_tests.sh'), 0o755)

def main():
    """主函数"""
    print("生成并发查询集...")
    
    # 设置随机种子
    random.seed(42)
    
    # 生成模板和场景
    templates = generate_concurrent_query_templates()
    scenarios = generate_concurrent_scenarios()
    
    # 生成并发查询
    all_queries, scenario_queries = generate_concurrent_queries(templates, scenarios)
    
    # 保存查询
    output_dir = os.path.dirname(os.path.abspath(__file__))
    stats = save_concurrent_queries(all_queries, scenario_queries, scenarios, templates, output_dir)
    
    print(f"生成完成！")
    print(f"总查询数: {stats['total_queries']}")
    print(f"测试场景数: {stats['total_scenarios']}")
    print(f"持续时间分布: {stats['duration_distribution']}")
    print(f"文件保存在: {output_dir}")

if __name__ == "__main__":
    main()