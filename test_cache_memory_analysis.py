#!/usr/bin/env python3
"""
DuckDB查询缓存内存使用分析脚本

专门分析查询缓存对内存使用的影响
"""

import duckdb
import time
import json
import os
import sys
import psutil
import gc
import matplotlib.pyplot as plt
import pandas as pd
from typing import List, Dict, Tuple
from dataclasses import dataclass
import threading
import queue

@dataclass
class MemorySnapshot:
    """内存快照"""
    timestamp: float
    rss_mb: float  # 物理内存
    vms_mb: float  # 虚拟内存
    cache_entries: int
    cache_memory_mb: float
    query_name: str = ""
    event: str = ""

class MemoryMonitor:
    """内存监控器"""
    
    def __init__(self, interval: float = 0.1):
        self.interval = interval
        self.snapshots: List[MemorySnapshot] = []
        self.monitoring = False
        self.monitor_thread = None
        self.process = psutil.Process()
        self.snapshot_queue = queue.Queue()
        
    def start_monitoring(self):
        """开始监控"""
        self.monitoring = True
        self.monitor_thread = threading.Thread(target=self._monitor_loop)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
    def stop_monitoring(self):
        """停止监控"""
        self.monitoring = False
        if self.monitor_thread:
            self.monitor_thread.join()
            
    def _monitor_loop(self):
        """监控循环"""
        while self.monitoring:
            try:
                memory_info = self.process.memory_info()
                snapshot = MemorySnapshot(
                    timestamp=time.time(),
                    rss_mb=memory_info.rss / 1024 / 1024,
                    vms_mb=memory_info.vms / 1024 / 1024,
                    cache_entries=0,  # 需要从DuckDB获取
                    cache_memory_mb=0.0  # 需要从DuckDB获取
                )
                self.snapshots.append(snapshot)
                time.sleep(self.interval)
            except Exception as e:
                print(f"内存监控错误: {e}")
                break
                
    def add_event(self, event: str, query_name: str = ""):
        """添加事件标记"""
        if self.snapshots:
            self.snapshots[-1].event = event
            self.snapshots[-1].query_name = query_name
            
    def get_memory_usage_stats(self) -> Dict:
        """获取内存使用统计"""
        if not self.snapshots:
            return {}
            
        rss_values = [s.rss_mb for s in self.snapshots]
        vms_values = [s.vms_mb for s in self.snapshots]
        
        return {
            "peak_rss_mb": max(rss_values),
            "avg_rss_mb": sum(rss_values) / len(rss_values),
            "peak_vms_mb": max(vms_values),
            "avg_vms_mb": sum(vms_values) / len(vms_values),
            "total_snapshots": len(self.snapshots)
        }

class CacheMemoryTester:
    """缓存内存测试器"""
    
    def __init__(self, db_path: str = "/Users/max/test/tpc/tpch-sf1.db"):
        self.db_path = db_path
        self.monitor = MemoryMonitor()
        
        # 不同大小的查询
        self.queries = {
            "small": {
                "simple_count": "SELECT COUNT(*) FROM orders;",
                "simple_avg": "SELECT AVG(o_totalprice) FROM orders;",
            },
            "medium": {
                "join_query": """
                    SELECT c.c_name, COUNT(o.o_orderkey) as order_count
                    FROM customer c
                    JOIN orders o ON c.c_custkey = o.o_custkey
                    GROUP BY c.c_name
                    ORDER BY order_count DESC
                    LIMIT 100;
                """,
                "aggregation": """
                    SELECT 
                        EXTRACT(YEAR FROM o_orderdate) as year,
                        EXTRACT(MONTH FROM o_orderdate) as month,
                        COUNT(*) as order_count,
                        SUM(o_totalprice) as total_revenue
                    FROM orders
                    GROUP BY year, month
                    ORDER BY year, month;
                """
            },
            "large": {
                "complex_join": """
                    SELECT 
                        n.n_name,
                        c.c_mktsegment,
                        COUNT(o.o_orderkey) as order_count,
                        SUM(l.l_extendedprice * (1 - l.l_discount)) as revenue
                    FROM nation n
                    JOIN customer c ON n.n_nationkey = c.c_nationkey
                    JOIN orders o ON c.c_custkey = o.o_custkey
                    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
                    WHERE o.o_orderdate >= DATE '1995-01-01'
                        AND o.o_orderdate < DATE '1996-01-01'
                    GROUP BY n.n_name, c.c_mktsegment
                    ORDER BY revenue DESC;
                """,
                "window_function": """
                    SELECT 
                        o_orderkey,
                        o_custkey,
                        o_totalprice,
                        ROW_NUMBER() OVER (PARTITION BY o_custkey ORDER BY o_totalprice DESC) as rank,
                        SUM(o_totalprice) OVER (PARTITION BY o_custkey) as customer_total
                    FROM orders
                    WHERE o_orderdate >= DATE '1995-01-01'
                        AND o_orderdate < DATE '1996-01-01'
                    ORDER BY o_custkey, rank;
                """
            }
        }
    
    def test_cache_memory_impact(self, iterations: int = 10) -> Dict:
        """测试缓存对内存的影响"""
        results = {}
        
        for cache_enabled in [False, True]:
            cache_status = "enabled" if cache_enabled else "disabled"
            print(f"\n测试缓存{cache_status}时的内存使用...")
            
            # 连接数据库
            if os.path.exists(self.db_path):
                conn = duckdb.connect(self.db_path)
            else:
                conn = duckdb.connect()
                self._create_test_data(conn)
            
            # 配置缓存
            try:
                if cache_enabled:
                    conn.execute("SET enable_query_cache = true")
                    conn.execute("SET query_cache_max_entries = 1000")
                    conn.execute("SET query_cache_max_memory = '500MB'")
                else:
                    conn.execute("SET enable_query_cache = false")
            except:
                print("注意: 缓存配置可能不被支持")
            
            # 开始内存监控
            self.monitor = MemoryMonitor()
            self.monitor.start_monitoring()
            
            # 记录基线内存
            time.sleep(1)
            self.monitor.add_event("baseline", "")
            baseline_memory = self.monitor.snapshots[-1].rss_mb
            
            # 执行查询
            for size_category, queries in self.queries.items():
                for query_name, query_sql in queries.items():
                    print(f"  执行 {size_category}/{query_name}...")
                    
                    for i in range(iterations):
                        self.monitor.add_event("query_start", f"{size_category}/{query_name}")
                        
                        start_time = time.time()
                        try:
                            result = conn.execute(query_sql).fetchall()
                            rows = len(result)
                        except Exception as e:
                            print(f"    查询失败: {e}")
                            rows = 0
                        end_time = time.time()
                        
                        self.monitor.add_event("query_end", f"{size_category}/{query_name}")
                        
                        # 强制垃圾回收
                        gc.collect()
                        time.sleep(0.5)
            
            # 停止监控
            self.monitor.stop_monitoring()
            
            # 分析结果
            memory_stats = self.monitor.get_memory_usage_stats()
            memory_growth = memory_stats["peak_rss_mb"] - baseline_memory
            
            results[cache_status] = {
                "baseline_memory_mb": baseline_memory,
                "peak_memory_mb": memory_stats["peak_rss_mb"],
                "memory_growth_mb": memory_growth,
                "avg_memory_mb": memory_stats["avg_rss_mb"],
                "snapshots": self.monitor.snapshots.copy()
            }
            
            conn.close()
            
            # 清理内存
            gc.collect()
            time.sleep(2)
        
        return results
    
    def test_cache_size_scaling(self, max_entries_list: List[int] = [10, 50, 100, 500, 1000]) -> Dict:
        """测试不同缓存大小对内存的影响"""
        results = {}
        
        for max_entries in max_entries_list:
            print(f"\n测试缓存大小: {max_entries} 条目...")
            
            # 连接数据库
            if os.path.exists(self.db_path):
                conn = duckdb.connect(self.db_path)
            else:
                conn = duckdb.connect()
                self._create_test_data(conn)
            
            # 配置缓存
            try:
                conn.execute("SET enable_query_cache = true")
                conn.execute(f"SET query_cache_max_entries = {max_entries}")
                conn.execute("SET query_cache_max_memory = '1GB'")
            except:
                print("注意: 缓存配置可能不被支持")
            
            # 开始内存监控
            self.monitor = MemoryMonitor()
            self.monitor.start_monitoring()
            
            time.sleep(1)
            baseline_memory = self.monitor.snapshots[-1].rss_mb
            
            # 执行足够多的不同查询来填满缓存
            query_count = 0
            for i in range(max_entries + 10):  # 超过缓存大小
                # 生成不同的查询
                query = f"SELECT COUNT(*) FROM orders WHERE o_orderkey % {i+1} = 0;"
                
                try:
                    conn.execute(query).fetchall()
                    query_count += 1
                except:
                    pass
                
                if i % 10 == 0:
                    self.monitor.add_event("cache_fill", f"query_{i}")
            
            # 停止监控
            self.monitor.stop_monitoring()
            
            memory_stats = self.monitor.get_memory_usage_stats()
            
            results[max_entries] = {
                "baseline_memory_mb": baseline_memory,
                "peak_memory_mb": memory_stats["peak_rss_mb"],
                "memory_growth_mb": memory_stats["peak_rss_mb"] - baseline_memory,
                "queries_executed": query_count,
                "snapshots": self.monitor.snapshots.copy()
            }
            
            conn.close()
            gc.collect()
            time.sleep(2)
        
        return results
    
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
            FROM range(50000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE lineitem AS 
            SELECT 
                (i % 50000) as l_orderkey,
                i % 100 as l_suppkey,
                (i % 1000) + 1 as l_quantity,
                (i % 10000) / 100.0 as l_extendedprice,
                0.05 + (i % 10) / 100.0 as l_discount,
                0.05 + (i % 5) / 100.0 as l_tax
            FROM range(200000) t(i)
        """)
        
        conn.execute("""
            CREATE TABLE customer AS 
            SELECT 
                i as c_custkey,
                'Customer_' || i as c_name,
                i % 25 as c_nationkey,
                (i % 10000) / 100.0 as c_acctbal,
                CASE WHEN i % 5 = 0 THEN 'BUILDING' ELSE 'AUTOMOBILE' END as c_mktsegment
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
    
    def generate_memory_report(self, results: Dict, output_dir: str = "memory_analysis"):
        """生成内存分析报告"""
        os.makedirs(output_dir, exist_ok=True)
        
        # 保存原始数据
        with open(f"{output_dir}/memory_results.json", 'w') as f:
            # 转换snapshots为可序列化格式
            serializable_results = {}
            for key, value in results.items():
                if isinstance(value, dict) and 'snapshots' in value:
                    serializable_value = value.copy()
                    serializable_value['snapshots'] = [
                        {
                            'timestamp': s.timestamp,
                            'rss_mb': s.rss_mb,
                            'vms_mb': s.vms_mb,
                            'cache_entries': s.cache_entries,
                            'cache_memory_mb': s.cache_memory_mb,
                            'query_name': s.query_name,
                            'event': s.event
                        } for s in value['snapshots']
                    ]
                    serializable_results[key] = serializable_value
                else:
                    serializable_results[key] = value
            
            json.dump(serializable_results, f, indent=2)
        
        # 生成图表（如果有matplotlib）
        try:
            self._plot_memory_usage(results, output_dir)
        except ImportError:
            print("matplotlib未安装，跳过图表生成")
        
        # 生成文本报告
        self._generate_text_report(results, f"{output_dir}/memory_report.txt")
        
        print(f"内存分析报告已保存到: {output_dir}/")
    
    def _plot_memory_usage(self, results: Dict, output_dir: str):
        """绘制内存使用图表"""
        if 'enabled' in results and 'disabled' in results:
            # 对比图
            fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
            
            for i, (status, data) in enumerate([('disabled', results['disabled']), ('enabled', results['enabled'])]):
                ax = ax1 if i == 0 else ax2
                
                snapshots = data['snapshots']
                timestamps = [(s.timestamp - snapshots[0].timestamp) for s in snapshots]
                rss_values = [s.rss_mb for s in snapshots]
                
                ax.plot(timestamps, rss_values, label=f'Cache {status}')
                ax.set_xlabel('Time (seconds)')
                ax.set_ylabel('Memory Usage (MB)')
                ax.set_title(f'Memory Usage - Cache {status.title()}')
                ax.grid(True)
                
                # 标记事件
                for s in snapshots:
                    if s.event:
                        t = s.timestamp - snapshots[0].timestamp
                        ax.axvline(x=t, color='red', alpha=0.3, linestyle='--')
            
            plt.tight_layout()
            plt.savefig(f"{output_dir}/memory_comparison.png", dpi=300, bbox_inches='tight')
            plt.close()
        
        # 如果有缓存大小测试结果
        if any(isinstance(k, int) for k in results.keys()):
            cache_sizes = [k for k in results.keys() if isinstance(k, int)]
            cache_sizes.sort()
            
            memory_growth = [results[size]['memory_growth_mb'] for size in cache_sizes]
            
            plt.figure(figsize=(10, 6))
            plt.plot(cache_sizes, memory_growth, 'bo-')
            plt.xlabel('Cache Size (entries)')
            plt.ylabel('Memory Growth (MB)')
            plt.title('Memory Growth vs Cache Size')
            plt.grid(True)
            plt.savefig(f"{output_dir}/cache_size_scaling.png", dpi=300, bbox_inches='tight')
            plt.close()
    
    def _generate_text_report(self, results: Dict, filename: str):
        """生成文本报告"""
        with open(filename, 'w') as f:
            f.write("DuckDB查询缓存内存使用分析报告\n")
            f.write("=" * 50 + "\n\n")
            
            if 'enabled' in results and 'disabled' in results:
                f.write("缓存启用/禁用对比:\n")
                f.write("-" * 30 + "\n")
                
                disabled = results['disabled']
                enabled = results['enabled']
                
                f.write(f"缓存禁用:\n")
                f.write(f"  基线内存: {disabled['baseline_memory_mb']:.2f} MB\n")
                f.write(f"  峰值内存: {disabled['peak_memory_mb']:.2f} MB\n")
                f.write(f"  内存增长: {disabled['memory_growth_mb']:.2f} MB\n\n")
                
                f.write(f"缓存启用:\n")
                f.write(f"  基线内存: {enabled['baseline_memory_mb']:.2f} MB\n")
                f.write(f"  峰值内存: {enabled['peak_memory_mb']:.2f} MB\n")
                f.write(f"  内存增长: {enabled['memory_growth_mb']:.2f} MB\n\n")
                
                overhead = enabled['memory_growth_mb'] - disabled['memory_growth_mb']
                f.write(f"缓存内存开销: {overhead:.2f} MB\n\n")
            
            # 缓存大小扩展测试
            cache_sizes = [k for k in results.keys() if isinstance(k, int)]
            if cache_sizes:
                cache_sizes.sort()
                f.write("缓存大小扩展测试:\n")
                f.write("-" * 30 + "\n")
                
                for size in cache_sizes:
                    data = results[size]
                    f.write(f"缓存大小 {size}:\n")
                    f.write(f"  内存增长: {data['memory_growth_mb']:.2f} MB\n")
                    f.write(f"  执行查询数: {data['queries_executed']}\n\n")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="DuckDB查询缓存内存分析")
    parser.add_argument("--db-path", default="/Users/max/test/tpc/tpch-sf1.db",
                       help="TPC-H数据库路径")
    parser.add_argument("--iterations", type=int, default=5,
                       help="查询迭代次数")
    parser.add_argument("--output-dir", default="memory_analysis",
                       help="输出目录")
    parser.add_argument("--test-scaling", action="store_true",
                       help="测试缓存大小扩展")
    
    args = parser.parse_args()
    
    tester = CacheMemoryTester(args.db_path)
    
    try:
        print("开始内存使用分析...")
        
        # 基本内存影响测试
        results = tester.test_cache_memory_impact(args.iterations)
        
        # 缓存大小扩展测试
        if args.test_scaling:
            print("\n开始缓存大小扩展测试...")
            scaling_results = tester.test_cache_size_scaling()
            results.update(scaling_results)
        
        # 生成报告
        tester.generate_memory_report(results, args.output_dir)
        
        print(f"\n内存分析完成，报告保存在: {args.output_dir}/")
        
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())