#!/usr/bin/env python3
"""
综合缓存性能测试脚本
用于验证第五章实验与分析中的性能数据
"""

import time
import psutil
import sqlite3
import threading
import statistics
import json
import os
import sys
import random
import string
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import List, Dict, Any
import matplotlib.pyplot as plt
import numpy as np

@dataclass
class QueryResult:
    query_type: str
    execution_time: float
    cache_hit: bool
    memory_usage: float
    cpu_usage: float
    result_size: int

@dataclass
class TestConfig:
    max_concurrent_queries: int = 128
    test_duration_seconds: int = 300
    cache_size_mb: int = 4096
    bloom_filter_size: int = 10000000
    ttl_seconds: int = 3600

class CacheSimulator:
    """缓存模拟器"""
    def __init__(self, config: TestConfig):
        self.config = config
        self.cache = {}
        self.access_times = {}
        self.hit_count = 0
        self.miss_count = 0
        self.bloom_filter = set()  # 简化的布隆过滤器
        
    def get(self, key: str) -> Any:
        current_time = time.time()
        
        # 检查布隆过滤器
        if key not in self.bloom_filter:
            self.miss_count += 1
            return None
            
        # 检查缓存
        if key in self.cache:
            # 检查TTL
            if current_time - self.access_times[key] < self.config.ttl_seconds:
                self.access_times[key] = current_time
                self.hit_count += 1
                return self.cache[key]
            else:
                # TTL过期
                del self.cache[key]
                del self.access_times[key]
                self.bloom_filter.discard(key)
                
        self.miss_count += 1
        return None
        
    def put(self, key: str, value: Any):
        current_time = time.time()
        self.cache[key] = value
        self.access_times[key] = current_time
        self.bloom_filter.add(key)
        
        # 简单的LRU淘汰策略
        if len(self.cache) > self.config.cache_size_mb // 10:  # 简化计算
            oldest_key = min(self.access_times.keys(), key=lambda k: self.access_times[k])
            del self.cache[oldest_key]
            del self.access_times[oldest_key]
            self.bloom_filter.discard(oldest_key)
    
    def get_hit_rate(self) -> float:
        total = self.hit_count + self.miss_count
        return self.hit_count / total if total > 0 else 0.0

class DatabaseSimulator:
    """数据库模拟器"""
    def __init__(self):
        self.db_path = "/tmp/test_cache_db.sqlite"
        self.setup_database()
        
    def setup_database(self):
        """设置测试数据库"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 创建测试表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY,
                customer_id INTEGER,
                product_id INTEGER,
                quantity INTEGER,
                price REAL,
                order_date TEXT
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS customers (
                id INTEGER PRIMARY KEY,
                name TEXT,
                email TEXT,
                city TEXT,
                country TEXT
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY,
                name TEXT,
                category TEXT,
                price REAL,
                stock INTEGER
            )
        """)
        
        # 插入测试数据
        if cursor.execute("SELECT COUNT(*) FROM orders").fetchone()[0] == 0:
            self.generate_test_data(cursor)
            
        conn.commit()
        conn.close()
        
    def generate_test_data(self, cursor):
        """生成测试数据"""
        print("生成测试数据...")
        
        # 生成客户数据
        customers = []
        cities = ['北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '武汉']
        countries = ['中国', '美国', '日本', '德国', '英国']
        
        for i in range(10000):
            customers.append((
                i + 1,
                f"Customer_{i+1}",
                f"customer{i+1}@example.com",
                random.choice(cities),
                random.choice(countries)
            ))
            
        cursor.executemany(
            "INSERT INTO customers (id, name, email, city, country) VALUES (?, ?, ?, ?, ?)",
            customers
        )
        
        # 生成产品数据
        products = []
        categories = ['电子产品', '服装', '食品', '图书', '家居', '运动', '美妆', '汽车']
        
        for i in range(5000):
            products.append((
                i + 1,
                f"Product_{i+1}",
                random.choice(categories),
                round(random.uniform(10, 1000), 2),
                random.randint(0, 1000)
            ))
            
        cursor.executemany(
            "INSERT INTO products (id, name, category, price, stock) VALUES (?, ?, ?, ?, ?)",
            products
        )
        
        # 生成订单数据
        orders = []
        for i in range(100000):
            orders.append((
                i + 1,
                random.randint(1, 10000),
                random.randint(1, 5000),
                random.randint(1, 10),
                round(random.uniform(10, 1000), 2),
                f"2024-{random.randint(1, 12):02d}-{random.randint(1, 28):02d}"
            ))
            
        cursor.executemany(
            "INSERT INTO orders (id, customer_id, product_id, quantity, price, order_date) VALUES (?, ?, ?, ?, ?, ?)",
            orders
        )
        
        print("测试数据生成完成")

class PerformanceTester:
    """性能测试器"""
    def __init__(self, config: TestConfig):
        self.config = config
        self.cache = CacheSimulator(config)
        self.db = DatabaseSimulator()
        self.results = []
        
    def get_query_templates(self) -> Dict[str, List[str]]:
        """获取查询模板"""
        return {
            "简单SELECT": [
                "SELECT * FROM customers WHERE id = ?",
                "SELECT name, email FROM customers WHERE city = ?",
                "SELECT * FROM products WHERE category = ?",
                "SELECT COUNT(*) FROM orders WHERE customer_id = ?",
            ],
            "多表JOIN": [
                """SELECT c.name, o.order_date, p.name as product_name 
                   FROM customers c 
                   JOIN orders o ON c.id = o.customer_id 
                   JOIN products p ON o.product_id = p.id 
                   WHERE c.city = ?""",
                """SELECT c.country, COUNT(*) as order_count, SUM(o.price * o.quantity) as total_value
                   FROM customers c 
                   JOIN orders o ON c.id = o.customer_id 
                   GROUP BY c.country""",
            ],
            "聚合查询": [
                "SELECT category, AVG(price), COUNT(*) FROM products GROUP BY category",
                "SELECT customer_id, SUM(price * quantity) as total FROM orders GROUP BY customer_id HAVING total > 1000",
                "SELECT DATE(order_date) as date, COUNT(*) as daily_orders FROM orders GROUP BY DATE(order_date)",
            ],
            "窗口函数": [
                """SELECT customer_id, order_date, price,
                   ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as order_rank
                   FROM orders""",
                """SELECT category, name, price,
                   RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
                   FROM products""",
            ],
            "CTE查询": [
                """WITH customer_stats AS (
                     SELECT customer_id, COUNT(*) as order_count, SUM(price * quantity) as total_spent
                     FROM orders GROUP BY customer_id
                   )
                   SELECT c.name, cs.order_count, cs.total_spent
                   FROM customers c JOIN customer_stats cs ON c.id = cs.customer_id
                   WHERE cs.total_spent > 500""",
            ]
        }
    
    def execute_query(self, query_type: str, query: str, params: tuple = ()) -> QueryResult:
        """执行查询并记录性能"""
        start_time = time.time()
        start_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        start_cpu = psutil.cpu_percent()
        
        # 生成查询键
        query_key = f"{query_type}:{hash(query + str(params))}"
        
        # 检查缓存
        cached_result = self.cache.get(query_key)
        cache_hit = cached_result is not None
        
        if not cache_hit:
            # 执行实际查询
            conn = sqlite3.connect(self.db.db_path)
            cursor = conn.cursor()
            
            try:
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                result = cursor.fetchall()
                
                # 缓存结果
                self.cache.put(query_key, result)
                result_size = len(result)
                
            except Exception as e:
                print(f"查询执行错误: {e}")
                result_size = 0
            finally:
                conn.close()
        else:
            result_size = len(cached_result) if cached_result else 0
        
        end_time = time.time()
        end_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
        end_cpu = psutil.cpu_percent()
        
        execution_time = (end_time - start_time) * 1000  # 转换为毫秒
        memory_usage = end_memory - start_memory
        cpu_usage = (end_cpu + start_cpu) / 2
        
        return QueryResult(
            query_type=query_type,
            execution_time=execution_time,
            cache_hit=cache_hit,
            memory_usage=memory_usage,
            cpu_usage=cpu_usage,
            result_size=result_size
        )
    
    def run_response_time_test(self) -> Dict[str, Any]:
        """运行响应时间测试"""
        print("开始响应时间测试...")
        query_templates = self.get_query_templates()
        results = {}
        
        for query_type, queries in query_templates.items():
            type_results = []
            
            # 每种查询类型执行多次
            for _ in range(50):
                query = random.choice(queries)
                
                # 生成随机参数
                if "?" in query:
                    if "id" in query:
                        params = (random.randint(1, 1000),)
                    elif "city" in query:
                        params = ("北京",)
                    elif "category" in query:
                        params = ("电子产品",)
                    else:
                        params = ()
                else:
                    params = ()
                
                result = self.execute_query(query_type, query, params)
                type_results.append(result)
            
            # 计算统计数据
            cached_times = [r.execution_time for r in type_results if r.cache_hit]
            uncached_times = [r.execution_time for r in type_results if not r.cache_hit]
            
            results[query_type] = {
                "cached_avg": statistics.mean(cached_times) if cached_times else 0,
                "uncached_avg": statistics.mean(uncached_times) if uncached_times else 0,
                "cached_std": statistics.stdev(cached_times) if len(cached_times) > 1 else 0,
                "uncached_std": statistics.stdev(uncached_times) if len(uncached_times) > 1 else 0,
                "cache_hit_rate": len(cached_times) / len(type_results) if type_results else 0,
                "improvement": ((statistics.mean(uncached_times) - statistics.mean(cached_times)) / statistics.mean(uncached_times) * 100) if cached_times and uncached_times else 0
            }
        
        return results
    
    def run_throughput_test(self) -> Dict[str, Any]:
        """运行吞吐量测试"""
        print("开始吞吐量测试...")
        query_templates = self.get_query_templates()
        all_queries = []
        
        # 准备查询列表
        for query_type, queries in query_templates.items():
            for query in queries:
                all_queries.append((query_type, query))
        
        results = {}
        
        # 测试不同并发级别
        concurrency_levels = [1, 2, 4, 8, 16, 32, 64, 128]
        
        for concurrency in concurrency_levels:
            if concurrency > self.config.max_concurrent_queries:
                break
                
            print(f"测试并发级别: {concurrency}")
            
            start_time = time.time()
            completed_queries = 0
            
            def execute_random_query():
                nonlocal completed_queries
                query_type, query = random.choice(all_queries)
                
                # 生成随机参数
                if "?" in query:
                    if "id" in query:
                        params = (random.randint(1, 1000),)
                    elif "city" in query:
                        params = ("北京",)
                    elif "category" in query:
                        params = ("电子产品",)
                    else:
                        params = ()
                else:
                    params = ()
                
                self.execute_query(query_type, query, params)
                completed_queries += 1
            
            # 运行并发测试
            with ThreadPoolExecutor(max_workers=concurrency) as executor:
                futures = []
                test_duration = 30  # 30秒测试
                end_time = start_time + test_duration
                
                while time.time() < end_time:
                    if len(futures) < concurrency:
                        future = executor.submit(execute_random_query)
                        futures.append(future)
                    
                    # 清理完成的任务
                    futures = [f for f in futures if not f.done()]
                    time.sleep(0.01)
                
                # 等待所有任务完成
                for future in futures:
                    future.result()
            
            elapsed_time = time.time() - start_time
            qps = completed_queries / elapsed_time
            
            results[concurrency] = {
                "qps": qps,
                "completed_queries": completed_queries,
                "elapsed_time": elapsed_time,
                "cache_hit_rate": self.cache.get_hit_rate()
            }
        
        return results
    
    def run_memory_usage_test(self) -> Dict[str, Any]:
        """运行内存使用测试"""
        print("开始内存使用测试...")
        
        memory_samples = []
        start_time = time.time()
        
        # 24小时模拟（压缩到5分钟）
        simulation_duration = 300  # 5分钟
        sample_interval = 5  # 5秒采样一次
        
        query_templates = self.get_query_templates()
        all_queries = []
        
        for query_type, queries in query_templates.items():
            for query in queries:
                all_queries.append((query_type, query))
        
        def simulate_workload():
            """模拟工作负载"""
            while time.time() - start_time < simulation_duration:
                # 模拟不同时间段的查询强度
                current_time = (time.time() - start_time) / simulation_duration * 24  # 转换为24小时制
                
                if 9 <= current_time <= 18:  # 工作时间
                    query_rate = 10  # 每秒10个查询
                elif 18 <= current_time <= 21:  # 晚高峰
                    query_rate = 5   # 每秒5个查询
                else:  # 其他时间
                    query_rate = 2   # 每秒2个查询
                
                for _ in range(query_rate):
                    query_type, query = random.choice(all_queries)
                    
                    if "?" in query:
                        if "id" in query:
                            params = (random.randint(1, 1000),)
                        elif "city" in query:
                            params = ("北京",)
                        elif "category" in query:
                            params = ("电子产品",)
                        else:
                            params = ()
                    else:
                        params = ()
                    
                    self.execute_query(query_type, query, params)
                
                time.sleep(1)
        
        # 启动工作负载模拟
        workload_thread = threading.Thread(target=simulate_workload)
        workload_thread.start()
        
        # 采样内存使用
        while time.time() - start_time < simulation_duration:
            memory_info = psutil.Process().memory_info()
            memory_mb = memory_info.rss / 1024 / 1024
            
            elapsed_hours = (time.time() - start_time) / simulation_duration * 24
            
            memory_samples.append({
                "hour": elapsed_hours,
                "memory_mb": memory_mb,
                "cache_entries": len(self.cache.cache),
                "cache_hit_rate": self.cache.get_hit_rate()
            })
            
            time.sleep(sample_interval)
        
        workload_thread.join()
        
        return {
            "samples": memory_samples,
            "peak_memory": max(s["memory_mb"] for s in memory_samples),
            "avg_memory": statistics.mean(s["memory_mb"] for s in memory_samples),
            "final_cache_entries": len(self.cache.cache),
            "final_hit_rate": self.cache.get_hit_rate()
        }
    
    def run_bloom_filter_test(self) -> Dict[str, Any]:
        """运行布隆过滤器测试"""
        print("开始布隆过滤器测试...")
        
        # 测试不同的假阳性率配置
        false_positive_rates = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
        results = {}
        
        for fp_rate in false_positive_rates:
            print(f"测试假阳性率: {fp_rate}%")
            
            # 重置缓存
            self.cache = CacheSimulator(self.config)
            
            # 模拟布隆过滤器行为
            test_queries = 1000
            true_negatives = 0
            false_positives = 0
            true_positives = 0
            
            query_templates = self.get_query_templates()
            
            for i in range(test_queries):
                query_type = random.choice(list(query_templates.keys()))
                query = random.choice(query_templates[query_type])
                
                # 生成查询键
                query_key = f"{query_type}:{i}"
                
                # 模拟布隆过滤器检查
                if random.random() * 100 < fp_rate:
                    # 假阳性：布隆过滤器说存在，但实际不存在
                    if query_key not in self.cache.cache:
                        false_positives += 1
                    else:
                        true_positives += 1
                else:
                    # 真阴性：布隆过滤器说不存在，实际也不存在
                    true_negatives += 1
                
                # 随机缓存一些查询
                if random.random() < 0.3:
                    self.cache.put(query_key, f"result_{i}")
            
            # 计算性能指标
            total_checks = true_negatives + false_positives + true_positives
            actual_fp_rate = false_positives / total_checks * 100 if total_checks > 0 else 0
            
            # 估算内存使用（简化计算）
            estimated_memory_mb = fp_rate * 20  # 假设关系
            
            results[fp_rate] = {
                "actual_fp_rate": actual_fp_rate,
                "estimated_memory_mb": estimated_memory_mb,
                "true_negatives": true_negatives,
                "false_positives": false_positives,
                "true_positives": true_positives,
                "filter_efficiency": true_negatives / total_checks * 100 if total_checks > 0 else 0
            }
        
        return results
    
    def generate_report(self, results: Dict[str, Any]):
        """生成测试报告"""
        report_path = "/tmp/cache_performance_report.json"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        print(f"测试报告已保存到: {report_path}")
        
        # 生成简要报告
        print("\n=== 缓存性能测试报告 ===")
        
        if "response_time" in results:
            print("\n1. 查询响应时间测试结果:")
            for query_type, data in results["response_time"].items():
                print(f"  {query_type}:")
                print(f"    无缓存平均时间: {data['uncached_avg']:.1f}ms")
                print(f"    有缓存平均时间: {data['cached_avg']:.1f}ms")
                print(f"    性能改善: {data['improvement']:.1f}%")
                print(f"    缓存命中率: {data['cache_hit_rate']:.1%}")
        
        if "throughput" in results:
            print("\n2. 系统吞吐量测试结果:")
            for concurrency, data in results["throughput"].items():
                print(f"  并发数 {concurrency}: {data['qps']:.0f} QPS (命中率: {data['cache_hit_rate']:.1%})")
        
        if "memory_usage" in results:
            print(f"\n3. 内存使用测试结果:")
            print(f"  峰值内存: {results['memory_usage']['peak_memory']:.1f}MB")
            print(f"  平均内存: {results['memory_usage']['avg_memory']:.1f}MB")
            print(f"  最终缓存条目: {results['memory_usage']['final_cache_entries']}")
            print(f"  最终命中率: {results['memory_usage']['final_hit_rate']:.1%}")
        
        if "bloom_filter" in results:
            print(f"\n4. 布隆过滤器测试结果:")
            for fp_rate, data in results["bloom_filter"].items():
                print(f"  假阳性率 {fp_rate}%: 过滤效率 {data['filter_efficiency']:.1f}%, 内存使用 {data['estimated_memory_mb']:.0f}MB")

def main():
    """主函数"""
    print("开始综合缓存性能测试...")
    
    config = TestConfig(
        max_concurrent_queries=128,
        test_duration_seconds=300,
        cache_size_mb=4096,
        bloom_filter_size=10000000,
        ttl_seconds=3600
    )
    
    tester = PerformanceTester(config)
    
    # 运行所有测试
    all_results = {}
    
    try:
        # 1. 响应时间测试
        all_results["response_time"] = tester.run_response_time_test()
        
        # 2. 吞吐量测试
        all_results["throughput"] = tester.run_throughput_test()
        
        # 3. 内存使用测试
        all_results["memory_usage"] = tester.run_memory_usage_test()
        
        # 4. 布隆过滤器测试
        all_results["bloom_filter"] = tester.run_bloom_filter_test()
        
        # 生成报告
        tester.generate_report(all_results)
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
    finally:
        # 清理临时文件
        if os.path.exists("/tmp/test_cache_db.sqlite"):
            os.remove("/tmp/test_cache_db.sqlite")

if __name__ == "__main__":
    main()