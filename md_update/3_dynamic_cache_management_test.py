#!/usr/bin/env python3
"""
第三章 动态缓存管理 - 布隆过滤器与SQL/CTE缓存测试脚本
Chapter 3: Dynamic Cache Management - Bloom Filter and SQL/CTE Cache Testing Script

本脚本用于测试第三章的核心技术：
1. 布隆过滤器前置过滤技术
2. SQL语句动态缓存技术
3. CTE子语句动态缓存技术
4. 查询签名生成与标准化
"""

import duckdb
import time
import json
import hashlib
import re
import numpy as np
from typing import Dict, List, Tuple, Any, Set
from dataclasses import dataclass, asdict
import argparse
import sys
from collections import defaultdict

@dataclass
class BloomFilterMetrics:
    """布隆过滤器性能指标"""
    size_bits: int
    hash_functions: int
    elements_added: int
    false_positive_rate: float
    memory_usage_mb: float
    avg_query_time_ns: float
    filter_efficiency: float

@dataclass
class QueryCacheMetrics:
    """查询缓存性能指标"""
    query_type: str
    original_query: str
    normalized_query: str
    query_hash: str
    execution_time_ms: float
    cache_hit: bool
    result_size_bytes: int
    complexity_score: float

@dataclass
class CTECacheMetrics:
    """CTE缓存性能指标"""
    cte_name: str
    cte_query: str
    dependency_count: int
    cache_strategy: str
    execution_time_ms: float
    cache_reuse_count: int
    memory_savings_mb: float

class BloomFilter:
    """简化的布隆过滤器实现"""
    
    def __init__(self, size: int, hash_count: int):
        self.size = size
        self.hash_count = hash_count
        self.bit_array = [False] * size
        self.elements_added = 0
    
    def _hash(self, item: str, seed: int) -> int:
        """计算哈希值"""
        hash_obj = hashlib.md5((item + str(seed)).encode())
        return int(hash_obj.hexdigest(), 16) % self.size
    
    def add(self, item: str):
        """添加元素到布隆过滤器"""
        for i in range(self.hash_count):
            index = self._hash(item, i)
            self.bit_array[index] = True
        self.elements_added += 1
    
    def might_contain(self, item: str) -> bool:
        """检查元素是否可能存在"""
        for i in range(self.hash_count):
            index = self._hash(item, i)
            if not self.bit_array[index]:
                return False
        return True
    
    def get_false_positive_rate(self) -> float:
        """计算当前假阳性率"""
        if self.elements_added == 0:
            return 0.0
        
        # 理论假阳性率公式: (1 - e^(-k*n/m))^k
        k = self.hash_count
        n = self.elements_added
        m = self.size
        
        return (1 - np.exp(-k * n / m)) ** k

class QueryNormalizer:
    """查询标准化器"""
    
    @staticmethod
    def normalize_query(query: str) -> str:
        """标准化SQL查询"""
        # 转换为小写
        normalized = query.lower().strip()
        
        # 移除多余的空白字符
        normalized = re.sub(r'\s+', ' ', normalized)
        
        # 标准化字符串字面量
        normalized = re.sub(r"'[^']*'", "'?'", normalized)
        
        # 标准化数字字面量
        normalized = re.sub(r'\b\d+\b', '?', normalized)
        
        # 移除注释
        normalized = re.sub(r'--.*$', '', normalized, flags=re.MULTILINE)
        normalized = re.sub(r'/\*.*?\*/', '', normalized, flags=re.DOTALL)
        
        return normalized.strip()
    
    @staticmethod
    def generate_query_hash(query: str) -> str:
        """生成查询哈希"""
        normalized = QueryNormalizer.normalize_query(query)
        return hashlib.sha256(normalized.encode()).hexdigest()[:16]
    
    @staticmethod
    def calculate_complexity_score(query: str) -> float:
        """计算查询复杂度评分"""
        query_lower = query.lower()
        score = 0.0
        
        # 基础复杂度
        score += len(query) / 1000.0
        
        # JOIN复杂度
        join_count = len(re.findall(r'\bjoin\b', query_lower))
        score += join_count * 0.3
        
        # 子查询复杂度
        subquery_count = query_lower.count('(select')
        score += subquery_count * 0.4
        
        # 聚合函数复杂度
        agg_functions = ['sum', 'count', 'avg', 'max', 'min', 'group by']
        for func in agg_functions:
            if func in query_lower:
                score += 0.2
        
        # CTE复杂度
        if 'with' in query_lower:
            score += 0.3
        
        # 窗口函数复杂度
        if 'over(' in query_lower:
            score += 0.4
        
        return min(score, 1.0)

class CTEAnalyzer:
    """CTE分析器"""
    
    @staticmethod
    def extract_ctes(query: str) -> Dict[str, str]:
        """提取查询中的CTE"""
        ctes = {}
        
        # 简化的CTE提取（实际实现需要更复杂的解析）
        if not query.lower().strip().startswith('with'):
            return ctes
        
        # 使用正则表达式提取CTE
        cte_pattern = r'(\w+)\s+as\s*\((.*?)\)'
        matches = re.findall(cte_pattern, query, re.IGNORECASE | re.DOTALL)
        
        for name, definition in matches:
            ctes[name.strip()] = definition.strip()
        
        return ctes
    
    @staticmethod
    def analyze_cte_dependencies(ctes: Dict[str, str]) -> Dict[str, List[str]]:
        """分析CTE依赖关系"""
        dependencies = {}
        
        for cte_name, cte_query in ctes.items():
            deps = []
            for other_cte in ctes.keys():
                if other_cte != cte_name and other_cte.lower() in cte_query.lower():
                    deps.append(other_cte)
            dependencies[cte_name] = deps
        
        return dependencies

class Chapter3DynamicCacheTester:
    """第三章动态缓存测试器"""
    
    def __init__(self, db_path: str = ":memory:"):
        self.db_path = db_path
        self.bloom_filter = BloomFilter(size=100000, hash_count=7)
        self.query_cache: Dict[str, Any] = {}
        self.cte_cache: Dict[str, Any] = {}
        self.test_results = {
            "bloom_filter_tests": [],
            "sql_cache_tests": [],
            "cte_cache_tests": []
        }
    
    def test_bloom_filter_performance(self) -> Dict[str, Any]:
        """测试布隆过滤器性能"""
        print("\n=== 布隆过滤器性能测试 ===")
        
        # 测试不同配置的布隆过滤器
        configurations = [
            {"size": 10000, "hash_count": 3},
            {"size": 50000, "hash_count": 5},
            {"size": 100000, "hash_count": 7},
            {"size": 200000, "hash_count": 10},
        ]
        
        results = []
        
        for config in configurations:
            print(f"测试配置: {config['size']} bits, {config['hash_count']} hash functions")
            
            bf = BloomFilter(config["size"], config["hash_count"])
            
            # 添加测试元素
            test_elements = [f"query_{i}" for i in range(1000)]
            
            # 测试添加性能
            start_time = time.perf_counter_ns()
            for element in test_elements:
                bf.add(element)
            add_time_ns = time.perf_counter_ns() - start_time
            
            # 测试查询性能
            start_time = time.perf_counter_ns()
            for element in test_elements:
                bf.might_contain(element)
            query_time_ns = time.perf_counter_ns() - start_time
            
            # 测试假阳性率
            false_positives = 0
            test_non_elements = [f"non_query_{i}" for i in range(1000)]
            for element in test_non_elements:
                if bf.might_contain(element):
                    false_positives += 1
            
            actual_fpr = false_positives / len(test_non_elements)
            theoretical_fpr = bf.get_false_positive_rate()
            
            metrics = BloomFilterMetrics(
                size_bits=config["size"],
                hash_functions=config["hash_count"],
                elements_added=len(test_elements),
                false_positive_rate=actual_fpr,
                memory_usage_mb=config["size"] / (8 * 1024 * 1024),
                avg_query_time_ns=query_time_ns / len(test_elements),
                filter_efficiency=(1 - actual_fpr) * 100
            )
            
            results.append(asdict(metrics))
            
            print(f"  假阳性率: {actual_fpr:.4f} (理论值: {theoretical_fpr:.4f})")
            print(f"  平均查询时间: {metrics.avg_query_time_ns:.1f}ns")
            print(f"  内存使用: {metrics.memory_usage_mb:.2f}MB")
        
        return {"configurations": results}
    
    def test_sql_cache_performance(self) -> Dict[str, Any]:
        """测试SQL缓存性能"""
        print("\n=== SQL缓存性能测试 ===")
        
        conn = duckdb.connect(self.db_path)
        self._create_test_data(conn)
        
        # 测试查询集合
        test_queries = {
            "simple_select": "SELECT * FROM test_table LIMIT 10",
            "aggregation": "SELECT category, COUNT(*), AVG(value) FROM test_table GROUP BY category",
            "join_query": """
                SELECT t1.id, t1.value, t2.category 
                FROM test_table t1 
                JOIN test_table t2 ON t1.id = t2.id 
                WHERE t1.value > 50
            """,
            "complex_where": """
                SELECT * FROM test_table 
                WHERE value BETWEEN 10 AND 90 
                AND category IN ('A', 'B', 'C')
                ORDER BY value DESC
            """,
            "window_function": """
                SELECT id, value, category,
                       ROW_NUMBER() OVER (PARTITION BY category ORDER BY value) as rn
                FROM test_table
            """
        }
        
        results = []
        
        for query_name, query_sql in test_queries.items():
            print(f"测试查询: {query_name}")
            
            # 查询标准化和哈希生成
            normalized_query = QueryNormalizer.normalize_query(query_sql)
            query_hash = QueryNormalizer.generate_query_hash(query_sql)
            complexity_score = QueryNormalizer.calculate_complexity_score(query_sql)
            
            # 布隆过滤器检查
            bloom_check_start = time.perf_counter_ns()
            might_be_cached = self.bloom_filter.might_contain(query_hash)
            bloom_check_time = time.perf_counter_ns() - bloom_check_start
            
            # 第一次执行（缓存未命中）
            start_time = time.perf_counter()
            result = conn.execute(query_sql).fetchall()
            first_execution_time = (time.perf_counter() - start_time) * 1000
            
            # 模拟缓存存储
            self.bloom_filter.add(query_hash)
            self.query_cache[query_hash] = {
                "result": result,
                "timestamp": time.time(),
                "access_count": 1
            }
            
            # 第二次执行（模拟缓存命中）
            start_time = time.perf_counter()
            if query_hash in self.query_cache:
                cached_result = self.query_cache[query_hash]["result"]
                self.query_cache[query_hash]["access_count"] += 1
            second_execution_time = (time.perf_counter() - start_time) * 1000
            
            # 计算结果大小
            result_size = len(str(result).encode('utf-8'))
            
            metrics = QueryCacheMetrics(
                query_type=query_name,
                original_query=query_sql.strip(),
                normalized_query=normalized_query,
                query_hash=query_hash,
                execution_time_ms=first_execution_time,
                cache_hit=False,  # 第一次执行
                result_size_bytes=result_size,
                complexity_score=complexity_score
            )
            
            results.append({
                "metrics": asdict(metrics),
                "first_execution_ms": first_execution_time,
                "second_execution_ms": second_execution_time,
                "cache_speedup": first_execution_time / max(second_execution_time, 0.001),
                "bloom_filter_check_ns": bloom_check_time,
                "result_rows": len(result)
            })
            
            print(f"  复杂度评分: {complexity_score:.3f}")
            print(f"  第一次执行: {first_execution_time:.2f}ms")
            print(f"  第二次执行: {second_execution_time:.2f}ms")
            print(f"  加速比: {first_execution_time / max(second_execution_time, 0.001):.1f}x")
        
        conn.close()
        return {"query_tests": results}
    
    def test_cte_cache_performance(self) -> Dict[str, Any]:
        """测试CTE缓存性能"""
        print("\n=== CTE缓存性能测试 ===")
        
        conn = duckdb.connect(self.db_path)
        self._create_test_data(conn)
        
        # CTE测试查询
        cte_test_queries = {
            "simple_cte": """
                WITH category_summary AS (
                    SELECT category, COUNT(*) as count, AVG(value) as avg_value
                    FROM test_table
                    GROUP BY category
                )
                SELECT * FROM category_summary WHERE count > 100
            """,
            "multiple_cte": """
                WITH high_value AS (
                    SELECT * FROM test_table WHERE value > 75
                ),
                category_stats AS (
                    SELECT category, COUNT(*) as count FROM high_value GROUP BY category
                )
                SELECT h.*, c.count as category_count
                FROM high_value h
                JOIN category_stats c ON h.category = c.category
            """,
            "nested_cte": """
                WITH base_data AS (
                    SELECT category, value, 
                           ROW_NUMBER() OVER (PARTITION BY category ORDER BY value DESC) as rn
                    FROM test_table
                ),
                top_per_category AS (
                    SELECT * FROM base_data WHERE rn <= 3
                )
                SELECT category, COUNT(*) as top_count, AVG(value) as avg_top_value
                FROM top_per_category
                GROUP BY category
            """,
            "recursive_cte": """
                WITH RECURSIVE number_series AS (
                    SELECT 1 as n
                    UNION ALL
                    SELECT n + 1 FROM number_series WHERE n < 100
                )
                SELECT COUNT(*) as total_numbers FROM number_series
            """
        }
        
        results = []
        
        for cte_name, cte_query in cte_test_queries.items():
            print(f"测试CTE: {cte_name}")
            
            # 提取和分析CTE
            ctes = CTEAnalyzer.extract_ctes(cte_query)
            dependencies = CTEAnalyzer.analyze_cte_dependencies(ctes)
            
            # 执行查询并测量性能
            execution_times = []
            for i in range(3):  # 多次执行测试
                start_time = time.perf_counter()
                try:
                    result = conn.execute(cte_query).fetchall()
                    execution_time = (time.perf_counter() - start_time) * 1000
                    execution_times.append(execution_time)
                except Exception as e:
                    print(f"  CTE查询执行失败: {e}")
                    execution_times.append(0)
            
            avg_execution_time = np.mean(execution_times) if execution_times else 0
            
            # 模拟CTE缓存策略
            cache_strategy = "independent" if len(dependencies) == 0 else "dependent"
            if "recursive" in cte_name:
                cache_strategy = "iterative"
            
            # 计算缓存效果
            cache_reuse_count = len(ctes) if len(ctes) > 1 else 0
            memory_savings = cache_reuse_count * 0.5  # 模拟内存节省
            
            metrics = CTECacheMetrics(
                cte_name=cte_name,
                cte_query=cte_query.strip(),
                dependency_count=len(dependencies),
                cache_strategy=cache_strategy,
                execution_time_ms=avg_execution_time,
                cache_reuse_count=cache_reuse_count,
                memory_savings_mb=memory_savings
            )
            
            results.append({
                "metrics": asdict(metrics),
                "cte_definitions": ctes,
                "dependencies": dependencies,
                "execution_times": execution_times,
                "cache_potential": len(ctes) > 1
            })
            
            print(f"  CTE数量: {len(ctes)}")
            print(f"  依赖关系: {len(dependencies)}")
            print(f"  缓存策略: {cache_strategy}")
            print(f"  平均执行时间: {avg_execution_time:.2f}ms")
        
        conn.close()
        return {"cte_tests": results}
    
    def _create_test_data(self, conn: duckdb.DuckDBPyConnection):
        """创建测试数据"""
        conn.execute("DROP TABLE IF EXISTS test_table")
        conn.execute("""
            CREATE TABLE test_table AS
            SELECT 
                i as id,
                (i % 100) as value,
                CASE (i % 5) 
                    WHEN 0 THEN 'A'
                    WHEN 1 THEN 'B'
                    WHEN 2 THEN 'C'
                    WHEN 3 THEN 'D'
                    ELSE 'E'
                END as category,
                DATE '2024-01-01' + INTERVAL (i % 365) DAY as date_col
            FROM range(10000) t(i)
        """)
    
    def run_comprehensive_test(self) -> Dict[str, Any]:
        """运行第三章综合测试"""
        print("开始运行第三章动态缓存管理综合测试...")
        
        results = {
            "test_timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "bloom_filter_performance": self.test_bloom_filter_performance(),
            "sql_cache_performance": self.test_sql_cache_performance(),
            "cte_cache_performance": self.test_cte_cache_performance()
        }
        
        return results
    
    def save_results(self, results: Dict[str, Any], filename: str = "chapter3_cache_test_results.json"):
        """保存测试结果"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False, default=str)
        print(f"\n测试结果已保存到: {filename}")
    
    def generate_report(self, results: Dict[str, Any]):
        """生成测试报告"""
        print("\n" + "="*80)
        print("第三章 动态缓存管理 - 测试报告")
        print("="*80)
        
        # 布隆过滤器测试结果
        print("\n布隆过滤器性能测试结果:")
        bf_results = results["bloom_filter_performance"]["configurations"]
        for config in bf_results:
            print(f"  配置 {config['size_bits']}bits/{config['hash_functions']}hash:")
            print(f"    假阳性率: {config['false_positive_rate']:.4f}")
            print(f"    查询时间: {config['avg_query_time_ns']:.1f}ns")
            print(f"    内存使用: {config['memory_usage_mb']:.2f}MB")
            print(f"    过滤效率: {config['filter_efficiency']:.1f}%")
        
        # SQL缓存测试结果
        print("\nSQL缓存性能测试结果:")
        sql_results = results["sql_cache_performance"]["query_tests"]
        for test in sql_results:
            metrics = test["metrics"]
            print(f"  {metrics['query_type']}:")
            print(f"    复杂度评分: {metrics['complexity_score']:.3f}")
            print(f"    缓存加速比: {test['cache_speedup']:.1f}x")
            print(f"    结果大小: {metrics['result_size_bytes']} bytes")
        
        # CTE缓存测试结果
        print("\nCTE缓存性能测试结果:")
        cte_results = results["cte_cache_performance"]["cte_tests"]
        for test in cte_results:
            metrics = test["metrics"]
            print(f"  {metrics['cte_name']}:")
            print(f"    依赖数量: {metrics['dependency_count']}")
            print(f"    缓存策略: {metrics['cache_strategy']}")
            print(f"    执行时间: {metrics['execution_time_ms']:.2f}ms")
            print(f"    内存节省: {metrics['memory_savings_mb']:.1f}MB")

def main():
    parser = argparse.ArgumentParser(description="第三章动态缓存管理测试")
    parser.add_argument("--db-path", default=":memory:", help="数据库路径")
    parser.add_argument("--output", default="chapter3_cache_test_results.json", help="输出文件名")
    
    args = parser.parse_args()
    
    # 创建测试器
    tester = Chapter3DynamicCacheTester(args.db_path)
    
    try:
        # 运行综合测试
        results = tester.run_comprehensive_test()
        
        # 生成报告
        tester.generate_report(results)
        
        # 保存结果
        tester.save_results(results, args.output)
        
        print("\n第三章测试完成!")
        return 0
        
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())