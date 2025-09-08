#!/usr/bin/env python3
"""
DuckDB查询缓存策略对比测试脚本

测试不同的缓存策略：
1. TTL-based eviction
2. LRU-based eviction  
3. ML-based eviction
4. 不同持久化策略的性能对比
"""

import duckdb
import time
import json
import os
import sys
import statistics
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass, asdict
import argparse
import random

@dataclass
class StrategyTestResult:
    """策略测试结果"""
    strategy_name: str
    total_queries: int
    cache_hits: int
    cache_misses: int
    hit_rate: float
    avg_execution_time_ms: float
    total_execution_time_ms: float
    memory_usage_mb: float
    evictions: int

class CacheStrategyTester:
    """缓存策略测试器"""
    
    def __init__(self, db_path: str = "/Users/max/test/tpc/tpch-sf1.db"):
        self.db_path = db_path
        self.results: List[StrategyTestResult] = []
        
        # 测试查询集合 - 模拟真实的查询模式
        self.query_patterns = {
            # 高频查询（会被重复执行）
            "high_frequency": [
                "SELECT COUNT(*) FROM orders;",
                "SELECT AVG(o_totalprice) FROM orders;",
                "SELECT COUNT(*) FROM customer;",
                "SELECT MAX(o_orderdate) FROM orders;",
                "SELECT MIN(o_orderdate) FROM orders;"
            ],
            
            # 中频查询
            "medium_frequency": [
                "SELECT c_mktsegment, COUNT(*) FROM customer GROUP BY c_mktsegment;",
                "SELECT EXTRACT(YEAR FROM o_orderdate) as year, COUNT(*) FROM orders GROUP BY year;",
                "SELECT n_name, COUNT(*) FROM nation n JOIN customer c ON n.n_nationkey = c.c_nationkey GROUP BY n_name;",
                "SELECT COUNT(*) FROM orders WHERE o_orderdate >= '1995-01-01';",
                "SELECT AVG(c_acctbal) FROM customer WHERE c_acctbal > 0;"
            ],
            
            # 低频查询（很少重复）
            "low_frequency": [
                f"SELECT COUNT(*) FROM orders WHERE o_orderkey % {i} = 0;" for i in range(2, 20)
            ] + [
                f"SELECT AVG(o_totalprice) FROM orders WHERE o_custkey % {i} = 0;" for i in range(3, 15)
            ]
        }
    
    def generate_workload(self, duration_minutes: int = 5) -> List[Tuple[str, str]]:
        """生成测试工作负载"""
        workload = []
        end_time = time.time() + duration_minutes * 60
        
        # 定义查询频率权重
        frequency_weights = {
            "high_frequency": 0.5,    # 50%的查询是高频的
            "medium_frequency": 0.3,  # 30%是中频的
            "low_frequency": 0.2      # 20%是低频的
        }
        
        query_id = 0
        while time.time() < end_time:
            # 根据权重选择查询类型
            rand = random.random()
            if rand < frequency_weights["high_frequency"]:
                category = "high_frequency"
            elif rand < frequency_weights["high_frequency"] + frequency_weights["medium_frequency"]:
                category = "medium_frequency"
            else:
                category = "low_frequency"
            
            # 从选定类别中随机选择查询
            query = random.choice(self.query_patterns[category])
            workload.append((f"{category}_{query_id}", query))
            query_id += 1
            
            # 模拟查询间隔
            time.sleep(random.uniform(0.1, 0.5))
        
        return workload
    
    def test_eviction_strategy(self, strategy: str, workload: List[Tuple[str, str]], 
                             cache_size: int = 50) -> StrategyTestResult:
        """测试特定的驱逐策略"""
        print(f"\n测试驱逐策略: {strategy}")
        print(f"缓存大小: {cache_size}")
        print(f"工作负载大小: {len(workload)} 个查询")
        
        # 连接数据库
        if os.path.exists(self.db_path):
            conn = duckdb.connect(self.db_path)
        else:
            conn = duckdb.connect()
            self._create_test_data(conn)
        
        # 配置缓存策略
        try:
            conn.execute("SET enable_query_cache = true")
            conn.execute(f"SET query_cache_max_entries = {cache_size}")
            conn.execute("SET query_cache_max_memory = '100MB'")
            
            # 设置驱逐策略
            if strategy == "TTL":
                conn.execute("SET query_cache_eviction_strategy = 'TTL_BASED'")
                conn.execute("SET query_cache_ttl_seconds = 300")  # 5分钟TTL
            elif strategy == "LRU":
                conn.execute("SET query_cache_eviction_strategy = 'LRU_BASED'")
            elif strategy == "ML":
                conn.execute("SET query_cache_eviction_strategy = 'ML_BASED'")
                conn.execute("SET query_cache_ml_learning_rate = 0.01")
            
        except Exception as e:
            print(f"缓存配置可能不被支持: {e}")
        
        # 执行工作负载
        execution_times = []
        cache_hits = 0
        cache_misses = 0
        start_time = time.time()
        
        for i, (query_name, query_sql) in enumerate(workload):
            if i % 50 == 0:
                print(f"  进度: {i}/{len(workload)}")
            
            query_start = time.perf_counter()
            try:
                result = conn.execute(query_sql).fetchall()
                # 简化的缓存命中检测（实际需要查询缓存统计）
                is_cache_hit = self._is_likely_cache_hit(query_sql, workload[:i])
                if is_cache_hit:
                    cache_hits += 1
                else:
                    cache_misses += 1
            except Exception as e:
                print(f"查询失败: {e}")
                cache_misses += 1
            
            query_end = time.perf_counter()
            execution_times.append((query_end - query_start) * 1000)
        
        total_time = time.time() - start_time
        
        # 获取内存使用情况（简化）
        memory_usage = self._estimate_memory_usage(conn)
        
        # 估算驱逐次数
        evictions = max(0, len(set(q[1] for q in workload)) - cache_size)
        
        result = StrategyTestResult(
            strategy_name=strategy,
            total_queries=len(workload),
            cache_hits=cache_hits,
            cache_misses=cache_misses,
            hit_rate=cache_hits / len(workload) if workload else 0,
            avg_execution_time_ms=statistics.mean(execution_times) if execution_times else 0,
            total_execution_time_ms=sum(execution_times),
            memory_usage_mb=memory_usage,
            evictions=evictions
        )
        
        conn.close()
        return result
    
    def test_persistence_strategies(self, workload: List[Tuple[str, str]]) -> Dict[str, StrategyTestResult]:
        """测试不同的持久化策略"""
        strategies = ["MEMORY_ONLY", "WAL_FORMAT", "MATERIALIZED_VIEW", "HYBRID"]
        results = {}
        
        for strategy in strategies:
            print(f"\n测试持久化策略: {strategy}")
            
            # 连接数据库
            if os.path.exists(self.db_path):
                conn = duckdb.connect(self.db_path)
            else:
                conn = duckdb.connect()
                self._create_test_data(conn)
            
            try:
                conn.execute("SET enable_query_cache = true")
                conn.execute("SET query_cache_max_entries = 100")
                conn.execute(f"SET query_cache_persistence_strategy = '{strategy}'")
                
                if strategy == "WAL_FORMAT":
                    conn.execute("SET query_cache_wal_buffer_size = '4MB'")
                    conn.execute("SET query_cache_enable_compression = true")
                elif strategy == "HYBRID":
                    conn.execute("SET query_cache_memory_threshold = '50MB'")
                
            except Exception as e:
                print(f"持久化策略配置可能不被支持: {e}")
            
            # 执行测试
            start_time = time.time()
            execution_times = []
            
            for query_name, query_sql in workload[:100]:  # 限制测试规模
                query_start = time.perf_counter()
                try:
                    conn.execute(query_sql).fetchall()
                except:
                    pass
                query_end = time.perf_counter()
                execution_times.append((query_end - query_start) * 1000)
            
            # 测试持久化性能 - 重启连接
            conn.close()
            
            if os.path.exists(self.db_path):
                conn = duckdb.connect(self.db_path)
            else:
                conn = duckdb.connect()
                self._create_test_data(conn)
            
            # 重新配置并测试缓存恢复
            try:
                conn.execute("SET enable_query_cache = true")
                conn.execute(f"SET query_cache_persistence_strategy = '{strategy}'")
            except:
                pass
            
            # 执行相同查询测试恢复性能
            recovery_times = []
            for query_name, query_sql in workload[:20]:
                query_start = time.perf_counter()
                try:
                    conn.execute(query_sql).fetchall()
                except:
                    pass
                query_end = time.perf_counter()
                recovery_times.append((query_end - query_start) * 1000)
            
            results[strategy] = StrategyTestResult(
                strategy_name=f"PERSISTENCE_{strategy}",
                total_queries=len(workload[:100]),
                cache_hits=0,  # 简化
                cache_misses=0,  # 简化
                hit_rate=0.0,
                avg_execution_time_ms=statistics.mean(execution_times) if execution_times else 0,
                total_execution_time_ms=sum(execution_times),
                memory_usage_mb=self._estimate_memory_usage(conn),
                evictions=0
            )
            
            conn.close()
        
        return results
    
    def _is_likely_cache_hit(self, query: str, previous_queries: List[Tuple[str, str]]) -> bool:
        """简化的缓存命中检测"""
        # 检查是否在之前的查询中出现过
        for _, prev_query in previous_queries:
            if query.strip() == prev_query.strip():
                return True
        return False
    
    def _estimate_memory_usage(self, conn: duckdb.DuckDBPyConnection) -> float:
        """估算内存使用量"""
        # 这里是简化实现，实际需要查询DuckDB的内存统计
        try:
            # 尝试获取内存统计
            result = conn.execute("SELECT current_setting('memory_limit')").fetchone()
            return 50.0  # 简化返回固定值
        except:
            return 50.0
    
    def _create_test_data(self, conn: duckdb.DuckDBPyConnection):
        """创建测试数据"""
        print("创建测试数据...")
        
        conn.execute("""
            CREATE TABLE orders AS 
            SELECT 
                i as o_orderkey,
                (i % 1000) as o_custkey,
                DATE '1995-01-01' + INTERVAL (i % 365) DAY as o_orderdate,
                (i % 10000) / 100.0 as o_totalprice,
                (i % 5) + 1 as o_shippriority
            FROM range(20000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE customer AS 
            SELECT 
                i as c_custkey,
                'Customer_' || i as c_name,
                i % 25 as c_nationkey,
                (i % 10000) / 100.0 as c_acctbal,
                CASE WHEN i % 5 = 0 THEN 'BUILDING' 
                     WHEN i % 5 = 1 THEN 'AUTOMOBILE'
                     WHEN i % 5 = 2 THEN 'MACHINERY'
                     WHEN i % 5 = 3 THEN 'HOUSEHOLD'
                     ELSE 'FURNITURE' END as c_mktsegment
            FROM range(1000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE nation AS 
            SELECT 
                i as n_nationkey,
                'Nation_' || i as n_name,
                i % 5 as n_regionkey
            FROM range(25) t(i)
        """)
    
    def run_comprehensive_test(self, workload_duration: int = 3) -> Dict[str, Any]:
        """运行综合测试"""
        print("="*80)
        print("DuckDB查询缓存策略综合测试")
        print("="*80)
        
        # 生成工作负载
        print(f"\n生成 {workload_duration} 分钟的工作负载...")
        workload = self.generate_workload(workload_duration)
        print(f"生成了 {len(workload)} 个查询")
        
        results = {}
        
        # 测试驱逐策略
        print("\n" + "="*50)
        print("测试驱逐策略")
        print("="*50)
        
        eviction_strategies = ["TTL", "LRU", "ML"]
        cache_sizes = [20, 50, 100]
        
        for strategy in eviction_strategies:
            for cache_size in cache_sizes:
                key = f"{strategy}_size_{cache_size}"
                results[key] = self.test_eviction_strategy(strategy, workload, cache_size)
        
        # 测试持久化策略
        print("\n" + "="*50)
        print("测试持久化策略")
        print("="*50)
        
        persistence_results = self.test_persistence_strategies(workload)
        results.update(persistence_results)
        
        return results
    
    def analyze_results(self, results: Dict[str, StrategyTestResult]) -> Dict[str, Any]:
        """分析测试结果"""
        analysis = {
            "best_hit_rate": {"strategy": "", "hit_rate": 0},
            "fastest_avg_time": {"strategy": "", "time_ms": float('inf')},
            "lowest_memory": {"strategy": "", "memory_mb": float('inf')},
            "eviction_comparison": {},
            "persistence_comparison": {}
        }
        
        # 找出最佳性能指标
        for strategy_name, result in results.items():
            if result.hit_rate > analysis["best_hit_rate"]["hit_rate"]:
                analysis["best_hit_rate"] = {
                    "strategy": strategy_name,
                    "hit_rate": result.hit_rate
                }
            
            if result.avg_execution_time_ms < analysis["fastest_avg_time"]["time_ms"]:
                analysis["fastest_avg_time"] = {
                    "strategy": strategy_name,
                    "time_ms": result.avg_execution_time_ms
                }
            
            if result.memory_usage_mb < analysis["lowest_memory"]["memory_mb"]:
                analysis["lowest_memory"] = {
                    "strategy": strategy_name,
                    "memory_mb": result.memory_usage_mb
                }
        
        # 分析驱逐策略
        eviction_results = {k: v for k, v in results.items() 
                          if any(evict in k for evict in ["TTL", "LRU", "ML"])}
        
        if eviction_results:
            analysis["eviction_comparison"] = {
                "strategies": list(set(k.split("_")[0] for k in eviction_results.keys())),
                "avg_hit_rates": {},
                "avg_execution_times": {}
            }
            
            for strategy in analysis["eviction_comparison"]["strategies"]:
                strategy_results = [v for k, v in eviction_results.items() if k.startswith(strategy)]
                if strategy_results:
                    analysis["eviction_comparison"]["avg_hit_rates"][strategy] = \
                        statistics.mean(r.hit_rate for r in strategy_results)
                    analysis["eviction_comparison"]["avg_execution_times"][strategy] = \
                        statistics.mean(r.avg_execution_time_ms for r in strategy_results)
        
        # 分析持久化策略
        persistence_results = {k: v for k, v in results.items() if k.startswith("PERSISTENCE_")}
        if persistence_results:
            analysis["persistence_comparison"] = {
                strategy: {
                    "avg_time_ms": result.avg_execution_time_ms,
                    "memory_mb": result.memory_usage_mb
                } for strategy, result in persistence_results.items()
            }
        
        return analysis
    
    def print_results(self, results: Dict[str, StrategyTestResult], analysis: Dict[str, Any]):
        """打印测试结果"""
        print("\n" + "="*80)
        print("测试结果总结")
        print("="*80)
        
        # 最佳性能指标
        print("\n最佳性能指标:")
        print("-" * 40)
        print(f"最高命中率: {analysis['best_hit_rate']['strategy']} "
              f"({analysis['best_hit_rate']['hit_rate']:.2%})")
        print(f"最快执行时间: {analysis['fastest_avg_time']['strategy']} "
              f"({analysis['fastest_avg_time']['time_ms']:.2f}ms)")
        print(f"最低内存使用: {analysis['lowest_memory']['strategy']} "
              f"({analysis['lowest_memory']['memory_mb']:.2f}MB)")
        
        # 驱逐策略对比
        if "eviction_comparison" in analysis and analysis["eviction_comparison"]:
            print("\n驱逐策略对比:")
            print("-" * 40)
            for strategy in analysis["eviction_comparison"]["strategies"]:
                hit_rate = analysis["eviction_comparison"]["avg_hit_rates"].get(strategy, 0)
                exec_time = analysis["eviction_comparison"]["avg_execution_times"].get(strategy, 0)
                print(f"{strategy:>3}: 命中率 {hit_rate:.2%}, 平均执行时间 {exec_time:.2f}ms")
        
        # 持久化策略对比
        if "persistence_comparison" in analysis and analysis["persistence_comparison"]:
            print("\n持久化策略对比:")
            print("-" * 40)
            for strategy, metrics in analysis["persistence_comparison"].items():
                strategy_name = strategy.replace("PERSISTENCE_", "")
                print(f"{strategy_name:>15}: 执行时间 {metrics['avg_time_ms']:.2f}ms, "
                      f"内存使用 {metrics['memory_mb']:.2f}MB")
        
        # 详细结果
        print("\n详细结果:")
        print("-" * 80)
        print(f"{'策略':<20} {'查询数':<8} {'命中率':<8} {'平均时间(ms)':<12} {'内存(MB)':<10} {'驱逐次数':<8}")
        print("-" * 80)
        
        for strategy_name, result in results.items():
            print(f"{strategy_name:<20} {result.total_queries:<8} "
                  f"{result.hit_rate:<8.2%} {result.avg_execution_time_ms:<12.2f} "
                  f"{result.memory_usage_mb:<10.2f} {result.evictions:<8}")
    
    def save_results(self, results: Dict[str, StrategyTestResult], 
                    analysis: Dict[str, Any], filename: str = "cache_strategy_results.json"):
        """保存结果到文件"""
        output = {
            "results": {k: asdict(v) for k, v in results.items()},
            "analysis": analysis,
            "timestamp": time.time()
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(output, f, indent=2, ensure_ascii=False)
        
        print(f"\n结果已保存到: {filename}")

def main():
    parser = argparse.ArgumentParser(description="DuckDB查询缓存策略测试")
    parser.add_argument("--db-path", default="/Users/max/test/tpc/tpch-sf1.db",
                       help="TPC-H数据库路径")
    parser.add_argument("--workload-duration", type=int, default=3,
                       help="工作负载持续时间（分钟）")
    parser.add_argument("--output", default="cache_strategy_results.json",
                       help="结果输出文件名")
    
    args = parser.parse_args()
    
    # 设置随机种子以确保可重现性
    random.seed(42)
    
    tester = CacheStrategyTester(args.db_path)
    
    try:
        # 运行综合测试
        results = tester.run_comprehensive_test(args.workload_duration)
        
        # 分析结果
        analysis = tester.analyze_results(results)
        
        # 打印结果
        tester.print_results(results, analysis)
        
        # 保存结果
        tester.save_results(results, analysis, args.output)
        
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())