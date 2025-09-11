#!/usr/bin/env python3
"""
DuckDB查询缓存性能测试脚本

测试场景：
1. 简单查询的缓存性能
2. TPC-H复杂查询的缓存性能
3. 单次执行 vs 多次执行的性能对比
4. 不同缓存策略的性能对比
5. 内存使用情况分析
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
import psutil
import gc

@dataclass
class QueryResult:
    """查询结果数据结构"""
    query_name: str
    query_sql: str
    execution_time_ms: float
    rows_returned: int
    cache_hit: bool
    memory_usage_mb: float
    cpu_usage_percent: float
    iteration: int

@dataclass
class CacheStats:
    """缓存统计信息"""
    total_entries: int
    total_hits: int
    total_misses: int
    hit_rate: float
    memory_usage_bytes: int
    false_positive_rate: float

@dataclass
class TestSummary:
    """测试总结"""
    test_name: str
    cache_enabled: bool
    total_queries: int
    avg_execution_time_ms: float
    min_execution_time_ms: float
    max_execution_time_ms: float
    std_execution_time_ms: float
    total_memory_usage_mb: float
    cache_stats: CacheStats
    speedup_ratio: float = 0.0

class QueryCachePerformanceTester:
    def __init__(self, db_path: str = "/Users/max/test/tpc/tpch-sf1.db"):
        self.db_path = db_path
        self.results: List[QueryResult] = []
        self.process = psutil.Process()
        
        # TPC-H查询模板
        self.tpch_queries = {
            "Q1": """
                SELECT
                    l_returnflag,
                    l_linestatus,
                    SUM(l_quantity) AS sum_qty,
                    SUM(l_extendedprice) AS sum_base_price,
                    SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
                    SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
                    AVG(l_quantity) AS avg_qty,
                    AVG(l_extendedprice) AS avg_price,
                    AVG(l_discount) AS avg_disc,
                    COUNT(*) AS count_order
                FROM lineitem
                WHERE l_shipdate <= DATE '1998-12-01' - INTERVAL '90' DAY
                GROUP BY l_returnflag, l_linestatus
                ORDER BY l_returnflag, l_linestatus;
            """,
            
            "Q3": """
                SELECT
                    l_orderkey,
                    SUM(l_extendedprice * (1 - l_discount)) AS revenue,
                    o_orderdate,
                    o_shippriority
                FROM customer, orders, lineitem
                WHERE c_mktsegment = 'BUILDING'
                    AND c_custkey = o_custkey
                    AND l_orderkey = o_orderkey
                    AND o_orderdate < DATE '1995-03-15'
                    AND l_shipdate > DATE '1995-03-15'
                GROUP BY l_orderkey, o_orderdate, o_shippriority
                ORDER BY revenue DESC, o_orderdate
                LIMIT 10;
            """,
            
            "Q5": """
                SELECT
                    n_name,
                    SUM(l_extendedprice * (1 - l_discount)) AS revenue
                FROM customer, orders, lineitem, supplier, nation, region
                WHERE c_custkey = o_custkey
                    AND l_orderkey = o_orderkey
                    AND l_suppkey = s_suppkey
                    AND c_nationkey = s_nationkey
                    AND s_nationkey = n_nationkey
                    AND n_regionkey = r_regionkey
                    AND r_name = 'ASIA'
                    AND o_orderdate >= DATE '1994-01-01'
                    AND o_orderdate < DATE '1995-01-01'
                GROUP BY n_name
                ORDER BY revenue DESC;
            """,
            
            "Q6": """
                SELECT
                    SUM(l_extendedprice * l_discount) AS revenue
                FROM lineitem
                WHERE l_shipdate >= DATE '1994-01-01'
                    AND l_shipdate < DATE '1995-01-01'
                    AND l_discount BETWEEN 0.05 AND 0.07
                    AND l_quantity < 24;
            """,
            
            "Q10": """
                SELECT
                    c_custkey,
                    c_name,
                    SUM(l_extendedprice * (1 - l_discount)) AS revenue,
                    c_acctbal,
                    n_name,
                    c_address,
                    c_phone,
                    c_comment
                FROM customer, orders, lineitem, nation
                WHERE c_custkey = o_custkey
                    AND l_orderkey = o_orderkey
                    AND o_orderdate >= DATE '1993-10-01'
                    AND o_orderdate < DATE '1994-01-01'
                    AND l_returnflag = 'R'
                    AND c_nationkey = n_nationkey
                GROUP BY c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment
                ORDER BY revenue DESC
                LIMIT 20;
            """
        }
        
        # 简单查询模板
        self.simple_queries = {
            "COUNT_ORDERS": "SELECT COUNT(*) FROM orders;",
            "AVG_PRICE": "SELECT AVG(l_extendedprice) FROM lineitem;",
            "TOP_CUSTOMERS": """
                SELECT c_name, c_acctbal 
                FROM customer 
                ORDER BY c_acctbal DESC 
                LIMIT 10;
            """,
            "NATION_STATS": """
                SELECT n_name, COUNT(*) as customer_count
                FROM nation n
                JOIN customer c ON n.n_nationkey = c.c_nationkey
                GROUP BY n_name
                ORDER BY customer_count DESC;
            """,
            "DATE_RANGE": """
                SELECT COUNT(*) 
                FROM orders 
                WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31';
            """
        }

    def get_memory_usage(self) -> float:
        """获取当前内存使用量（MB）"""
        return self.process.memory_info().rss / 1024 / 1024

    def get_cpu_usage(self) -> float:
        """获取当前CPU使用率"""
        return self.process.cpu_percent()

    def execute_query_with_timing(self, conn: duckdb.DuckDBPyConnection, 
                                query_name: str, query_sql: str, 
                                iteration: int = 0) -> QueryResult:
        """执行查询并记录性能指标"""
        # 清理内存
        gc.collect()
        
        # 获取执行前的缓存统计
        cache_stats_before = self.get_cache_stats(conn)
        
        # 记录开始状态
        start_memory = self.get_memory_usage()
        start_time = time.perf_counter()
        
        # 执行查询
        try:
            result = conn.execute(query_sql).fetchall()
            rows_returned = len(result)
        except Exception as e:
            print(f"查询执行失败: {query_name}, 错误: {e}")
            rows_returned = 0
        
        # 记录结束状态
        end_time = time.perf_counter()
        end_memory = self.get_memory_usage()
        cpu_usage = self.get_cpu_usage()
        
        # 获取执行后的缓存统计
        cache_stats_after = self.get_cache_stats(conn)
        
        execution_time_ms = (end_time - start_time) * 1000
        memory_usage_mb = max(0, end_memory - start_memory)
        
        # 检查是否命中缓存
        cache_hit = cache_stats_after.total_hits > cache_stats_before.total_hits
        
        return QueryResult(
            query_name=query_name,
            query_sql=query_sql.strip(),
            execution_time_ms=execution_time_ms,
            rows_returned=rows_returned,
            cache_hit=cache_hit,
            memory_usage_mb=memory_usage_mb,
            cpu_usage_percent=cpu_usage,
            iteration=iteration
        )

    def get_cache_stats(self, conn: duckdb.DuckDBPyConnection) -> CacheStats:
        """获取缓存统计信息"""
        try:
            # 获取缓存统计信息
            result = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
            if result and len(result) > 0:
                row = result[0]
                # pragma_query_cache_stats返回: total_entries, total_hits, total_misses, hit_rate, memory_usage_bytes, false_positive_rate, enabled
                return CacheStats(
                    total_entries=int(row[0]),
                    total_hits=int(row[1]),
                    total_misses=int(row[2]),
                    hit_rate=float(row[3]),
                    memory_usage_bytes=int(row[4]),
                    false_positive_rate=float(row[5])
                )
        except Exception as e:
            print(f"获取缓存统计失败: {e}")
        
        return CacheStats(
            total_entries=0,
            total_hits=0,
            total_misses=0,
            hit_rate=0.0,
            memory_usage_bytes=0,
            false_positive_rate=0.0
        )

    def run_test_suite(self, test_name: str, queries: Dict[str, str], 
                      iterations: int = 3, cache_enabled: bool = True) -> TestSummary:
        """运行测试套件"""
        print(f"\n{'='*60}")
        print(f"运行测试: {test_name}")
        print(f"缓存状态: {'启用' if cache_enabled else '禁用'}")
        print(f"迭代次数: {iterations}")
        print(f"{'='*60}")
        
        # 连接数据库
        if os.path.exists(self.db_path):
            conn = duckdb.connect(self.db_path)
        else:
            print(f"警告: 数据库文件不存在 {self.db_path}，使用内存数据库")
            conn = duckdb.connect()
            # 创建测试数据
            self._create_test_data(conn)
        
        # 配置缓存
        if cache_enabled:
            try:
                # 启用查询缓存（如果支持）
                conn.execute("SET enable_query_cache = true")
                conn.execute("SET query_cache_max_size = '100MB'")
                print("✓ 查询缓存已启用")
            except Exception as e:
                print(f"注意: 查询缓存配置失败: {e}")
        else:
            try:
                conn.execute("SET enable_query_cache = false")
                print("✓ 查询缓存已禁用")
            except Exception as e:
                print(f"注意: 查询缓存禁用失败: {e}")
        
        test_results = []
        
        # 执行查询
        for query_name, query_sql in queries.items():
            print(f"\n执行查询: {query_name}")
            
            for i in range(iterations):
                print(f"  迭代 {i+1}/{iterations}...", end=" ")
                
                result = self.execute_query_with_timing(
                    conn, query_name, query_sql, i
                )
                test_results.append(result)
                self.results.append(result)
                
                print(f"{result.execution_time_ms:.2f}ms ({result.rows_returned} 行)")
        
        # 计算统计信息
        execution_times = [r.execution_time_ms for r in test_results]
        total_memory = sum(r.memory_usage_mb for r in test_results)
        
        cache_stats = self.get_cache_stats(conn)
        
        summary = TestSummary(
            test_name=test_name,
            cache_enabled=cache_enabled,
            total_queries=len(test_results),
            avg_execution_time_ms=statistics.mean(execution_times),
            min_execution_time_ms=min(execution_times),
            max_execution_time_ms=max(execution_times),
            std_execution_time_ms=statistics.stdev(execution_times) if len(execution_times) > 1 else 0,
            total_memory_usage_mb=total_memory,
            cache_stats=cache_stats
        )
        
        conn.close()
        return summary

    def _create_test_data(self, conn: duckdb.DuckDBPyConnection):
        """创建测试数据（当TPC-H数据库不存在时）"""
        print("创建测试数据...")
        
        # 创建简化的测试表
        conn.execute("""
            CREATE TABLE orders AS 
            SELECT 
                i as o_orderkey,
                (i % 1000) as o_custkey,
                DATE '1995-01-01' + INTERVAL (i % 365) DAY as o_orderdate,
                (i % 5) + 1 as o_shippriority
            FROM range(10000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE lineitem AS 
            SELECT 
                (i % 10000) as l_orderkey,
                i % 100 as l_suppkey,
                (i % 1000) + 1 as l_quantity,
                (i % 10000) / 100.0 as l_extendedprice,
                0.05 + (i % 10) / 100.0 as l_discount,
                0.05 + (i % 5) / 100.0 as l_tax,
                CASE WHEN i % 2 = 0 THEN 'R' ELSE 'A' END as l_returnflag,
                CASE WHEN i % 3 = 0 THEN 'O' ELSE 'F' END as l_linestatus,
                DATE '1995-01-01' + INTERVAL (i % 365) DAY as l_shipdate
            FROM range(50000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE customer AS 
            SELECT 
                i as c_custkey,
                'Customer_' || i as c_name,
                'Address_' || i as c_address,
                i % 25 as c_nationkey,
                '555-' || LPAD(i::VARCHAR, 7, '0') as c_phone,
                (i % 10000) / 100.0 as c_acctbal,
                CASE WHEN i % 5 = 0 THEN 'BUILDING' ELSE 'AUTOMOBILE' END as c_mktsegment,
                'Comment_' || i as c_comment
            FROM range(1000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE nation AS 
            SELECT 
                i as n_nationkey,
                'Nation_' || i as n_name,
                i % 5 as n_regionkey,
                'Comment_' || i as n_comment
            FROM range(25) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE region AS 
            SELECT 
                i as r_regionkey,
                CASE i WHEN 0 THEN 'ASIA' WHEN 1 THEN 'AMERICA' 
                       WHEN 2 THEN 'EUROPE' WHEN 3 THEN 'AFRICA' 
                       ELSE 'MIDDLE EAST' END as r_name,
                'Comment_' || i as r_comment
            FROM range(5) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE supplier AS 
            SELECT 
                i as s_suppkey,
                'Supplier_' || i as s_name,
                'Address_' || i as s_address,
                i % 25 as s_nationkey,
                '555-' || LPAD(i::VARCHAR, 7, '0') as s_phone,
                (i % 1000) / 10.0 as s_acctbal,
                'Comment_' || i as s_comment
            FROM range(100) t(i)
        """)
        
        print("测试数据创建完成")

    def compare_cache_performance(self, iterations: int = 5) -> Dict[str, Any]:
        """对比缓存启用和禁用的性能"""
        print("\n" + "="*80)
        print("查询缓存性能对比测试")
        print("="*80)
        
        # 测试简单查询
        simple_cache_enabled = self.run_test_suite(
            "简单查询 (缓存启用)", self.simple_queries, iterations, True
        )
        
        simple_cache_disabled = self.run_test_suite(
            "简单查询 (缓存禁用)", self.simple_queries, iterations, False
        )
        
        # 测试TPC-H查询
        tpch_cache_enabled = self.run_test_suite(
            "TPC-H查询 (缓存启用)", self.tpch_queries, iterations, True
        )
        
        tpch_cache_disabled = self.run_test_suite(
            "TPC-H查询 (缓存禁用)", self.tpch_queries, iterations, False
        )
        
        # 计算加速比
        simple_cache_enabled.speedup_ratio = (
            simple_cache_disabled.avg_execution_time_ms / 
            simple_cache_enabled.avg_execution_time_ms
        )
        
        tpch_cache_enabled.speedup_ratio = (
            tpch_cache_disabled.avg_execution_time_ms / 
            tpch_cache_enabled.avg_execution_time_ms
        )
        
        return {
            "simple_queries": {
                "cache_enabled": simple_cache_enabled,
                "cache_disabled": simple_cache_disabled
            },
            "tpch_queries": {
                "cache_enabled": tpch_cache_enabled,
                "cache_disabled": tpch_cache_disabled
            }
        }

    def print_summary(self, comparison_results: Dict[str, Any]):
        """打印测试总结"""
        print("\n" + "="*80)
        print("测试结果总结")
        print("="*80)
        
        for test_type, results in comparison_results.items():
            print(f"\n{test_type.upper().replace('_', ' ')}:")
            print("-" * 50)
            
            cache_enabled = results["cache_enabled"]
            cache_disabled = results["cache_disabled"]
            
            print(f"缓存启用:")
            print(f"  平均执行时间: {cache_enabled.avg_execution_time_ms:.2f}ms")
            print(f"  最小执行时间: {cache_enabled.min_execution_time_ms:.2f}ms")
            print(f"  最大执行时间: {cache_enabled.max_execution_time_ms:.2f}ms")
            print(f"  标准差: {cache_enabled.std_execution_time_ms:.2f}ms")
            print(f"  总内存使用: {cache_enabled.total_memory_usage_mb:.2f}MB")
            
            print(f"\n缓存禁用:")
            print(f"  平均执行时间: {cache_disabled.avg_execution_time_ms:.2f}ms")
            print(f"  最小执行时间: {cache_disabled.min_execution_time_ms:.2f}ms")
            print(f"  最大执行时间: {cache_disabled.max_execution_time_ms:.2f}ms")
            print(f"  标准差: {cache_disabled.std_execution_time_ms:.2f}ms")
            print(f"  总内存使用: {cache_disabled.total_memory_usage_mb:.2f}MB")
            
            print(f"\n性能提升:")
            print(f"  加速比: {cache_enabled.speedup_ratio:.2f}x")
            improvement = ((cache_disabled.avg_execution_time_ms - cache_enabled.avg_execution_time_ms) / 
                          cache_disabled.avg_execution_time_ms * 100)
            print(f"  性能提升: {improvement:.1f}%")

    def save_results(self, comparison_results: Dict[str, Any], filename: str = "cache_performance_results.json"):
        """保存测试结果到JSON文件"""
        # 转换为可序列化的格式
        serializable_results = {}
        
        for test_type, results in comparison_results.items():
            serializable_results[test_type] = {
                "cache_enabled": asdict(results["cache_enabled"]),
                "cache_disabled": asdict(results["cache_disabled"])
            }
        
        # 添加详细的查询结果
        serializable_results["detailed_results"] = [asdict(r) for r in self.results]
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(serializable_results, f, indent=2, ensure_ascii=False)
        
        print(f"\n测试结果已保存到: {filename}")

def main():
    parser = argparse.ArgumentParser(description="DuckDB查询缓存性能测试")
    parser.add_argument("--db-path", default="/Users/max/test/tpc/tpch-sf1.db",
                       help="TPC-H数据库路径")
    parser.add_argument("--iterations", type=int, default=5,
                       help="每个查询的迭代次数")
    parser.add_argument("--output", default="cache_performance_results.json",
                       help="结果输出文件名")
    
    args = parser.parse_args()
    
    # 创建测试器
    tester = QueryCachePerformanceTester(args.db_path)
    
    try:
        # 运行性能对比测试
        results = tester.compare_cache_performance(args.iterations)
        
        # 打印结果
        tester.print_summary(results)
        
        # 保存结果
        tester.save_results(results, args.output)
        
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())