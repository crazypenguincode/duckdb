#!/usr/bin/env python3
"""
使用编译的DuckDB版本进行查询缓存性能测试
"""

import subprocess
import time
import json
import os
import tempfile
from typing import Dict, List, Tuple

class DuckDBCacheTest:
    def __init__(self, duckdb_path: str = "./build/release/duckdb", 
                 db_path: str = "/Users/max/test/tpc/tpch-sf1.db"):
        self.duckdb_path = duckdb_path
        self.db_path = db_path
        
    def execute_sql_session(self, sql_commands: List[str]) -> str:
        """在单个DuckDB会话中执行多个SQL命令"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            for cmd in sql_commands:
                f.write(cmd + '\n')
            temp_sql_file = f.name
        
        try:
            result = subprocess.run(
                [self.duckdb_path, self.db_path],
                input=open(temp_sql_file).read(),
                text=True,
                capture_output=True,
                timeout=30
            )
            return result.stdout
        finally:
            os.unlink(temp_sql_file)
    
    def parse_cache_stats(self, output: str) -> Dict:
        """解析缓存统计信息"""
        lines = output.strip().split('\n')
        for i, line in enumerate(lines):
            if 'total_entries' in line and i + 2 < len(lines):
                # 找到数据行
                data_line = lines[i + 2]
                if '│' in data_line:
                    parts = [p.strip() for p in data_line.split('│') if p.strip()]
                    if len(parts) >= 7:
                        return {
                            'total_entries': int(parts[0]),
                            'total_hits': int(parts[1]),
                            'total_misses': int(parts[2]),
                            'hit_rate': float(parts[3]),
                            'memory_usage_bytes': int(parts[4]),
                            'false_positive_rate': float(parts[5]),
                            'enabled': parts[6] == 'true'
                        }
        return {}
    
    def extract_timing(self, output: str) -> float:
        """从输出中提取执行时间"""
        lines = output.split('\n')
        for line in lines:
            if 'Run Time (s):' in line and 'user' in line:
                # 提取用户时间
                parts = line.split()
                for i, part in enumerate(parts):
                    if part == 'user' and i > 0:
                        return float(parts[i-1])
        return 0.0
    
    def test_simple_queries(self) -> Dict:
        """测试简单查询的缓存性能"""
        print("测试简单查询缓存性能...")
        
        queries = [
            "SELECT COUNT(*) FROM orders;",
            "SELECT AVG(o_totalprice) FROM orders;",
            "SELECT MAX(o_orderdate) FROM orders;",
            "SELECT MIN(o_custkey) FROM orders;",
            "SELECT COUNT(DISTINCT o_orderstatus) FROM orders;"
        ]
        
        results = {}
        
        for query_name, query in enumerate(queries):
            print(f"  测试查询 {query_name + 1}: {query.strip()}")
            
            # 构建测试SQL
            sql_commands = [
                "SELECT * FROM pragma_query_cache_stats();",  # 初始状态
                ".timer on",
                query,  # 第一次执行
                ".timer off",
                "SELECT * FROM pragma_query_cache_stats();",  # 第一次后状态
                ".timer on", 
                query,  # 第二次执行
                ".timer off",
                "SELECT * FROM pragma_query_cache_stats();",  # 第二次后状态
                ".timer on",
                query,  # 第三次执行
                ".timer off",
                "SELECT * FROM pragma_query_cache_stats();"   # 最终状态
            ]
            
            output = self.execute_sql_session(sql_commands)
            
            # 解析结果
            sections = output.split("SELECT * FROM pragma_query_cache_stats();")
            if len(sections) >= 4:
                initial_stats = self.parse_cache_stats(sections[1])
                after_first = self.parse_cache_stats(sections[2])
                after_second = self.parse_cache_stats(sections[3])
                final_stats = self.parse_cache_stats(sections[4])
                
                # 提取执行时间
                timing_sections = output.split(".timer")
                times = []
                for section in timing_sections:
                    time_val = self.extract_timing(section)
                    if time_val > 0:
                        times.append(time_val)
                
                results[f"query_{query_name + 1}"] = {
                    'query': query.strip(),
                    'initial_stats': initial_stats,
                    'after_first': after_first,
                    'after_second': after_second,
                    'final_stats': final_stats,
                    'execution_times': times,
                    'cache_hits': final_stats.get('total_hits', 0) - initial_stats.get('total_hits', 0),
                    'speedup': times[0] / times[1] if len(times) >= 2 and times[1] > 0 else 1.0
                }
                
                print(f"    执行时间: {times}")
                print(f"    缓存命中: {results[f'query_{query_name + 1}']['cache_hits']}")
                print(f"    加速比: {results[f'query_{query_name + 1}']['speedup']:.2f}x")
        
        return results
    
    def test_complex_queries(self) -> Dict:
        """测试复杂查询的缓存性能"""
        print("\n测试复杂查询缓存性能...")
        
        tpch_queries = {
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
            "Q6": """
                SELECT
                    SUM(l_extendedprice * l_discount) AS revenue
                FROM lineitem
                WHERE l_shipdate >= DATE '1994-01-01'
                    AND l_shipdate < DATE '1995-01-01'
                    AND l_discount BETWEEN 0.05 AND 0.07
                    AND l_quantity < 24;
            """
        }
        
        results = {}
        
        for query_name, query in tpch_queries.items():
            print(f"  测试 TPC-H {query_name}")
            
            sql_commands = [
                "SELECT * FROM pragma_query_cache_stats();",
                ".timer on",
                query,
                ".timer off", 
                "SELECT * FROM pragma_query_cache_stats();",
                ".timer on",
                query,
                ".timer off",
                "SELECT * FROM pragma_query_cache_stats();"
            ]
            
            output = self.execute_sql_session(sql_commands)
            
            # 解析结果
            sections = output.split("SELECT * FROM pragma_query_cache_stats();")
            if len(sections) >= 3:
                initial_stats = self.parse_cache_stats(sections[1])
                after_first = self.parse_cache_stats(sections[2])
                final_stats = self.parse_cache_stats(sections[3])
                
                timing_sections = output.split(".timer")
                times = []
                for section in timing_sections:
                    time_val = self.extract_timing(section)
                    if time_val > 0:
                        times.append(time_val)
                
                results[query_name] = {
                    'query': query.strip(),
                    'initial_stats': initial_stats,
                    'after_first': after_first,
                    'final_stats': final_stats,
                    'execution_times': times,
                    'cache_hits': final_stats.get('total_hits', 0) - initial_stats.get('total_hits', 0),
                    'speedup': times[0] / times[1] if len(times) >= 2 and times[1] > 0 else 1.0
                }
                
                print(f"    执行时间: {times}")
                print(f"    缓存命中: {results[query_name]['cache_hits']}")
                print(f"    加速比: {results[query_name]['speedup']:.2f}x")
        
        return results
    
    def run_comprehensive_test(self) -> Dict:
        """运行综合测试"""
        print("=== DuckDB查询缓存综合性能测试 ===")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"数据库路径: {self.db_path}")
        
        # 检查初始状态
        initial_output = self.execute_sql_session(["SELECT * FROM pragma_query_cache_stats();"])
        print(f"\n初始缓存状态:")
        print(initial_output)
        
        results = {
            'simple_queries': self.test_simple_queries(),
            'complex_queries': self.test_complex_queries()
        }
        
        # 计算总体统计
        all_speedups = []
        total_hits = 0
        
        for category in results.values():
            for test in category.values():
                if 'speedup' in test:
                    all_speedups.append(test['speedup'])
                if 'cache_hits' in test:
                    total_hits += test['cache_hits']
        
        avg_speedup = sum(all_speedups) / len(all_speedups) if all_speedups else 1.0
        
        print(f"\n=== 测试总结 ===")
        print(f"总缓存命中次数: {total_hits}")
        print(f"平均加速比: {avg_speedup:.2f}x")
        print(f"测试的查询数量: {len(all_speedups)}")
        
        # 保存结果
        with open('cache_performance_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        
        return results

def main():
    tester = DuckDBCacheTest()
    results = tester.run_comprehensive_test()

if __name__ == "__main__":
    main()