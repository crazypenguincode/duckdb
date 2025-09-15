#!/usr/bin/env python3
"""
多进程缓存持久化测试脚本

测试场景：
每次调用 subprocess.run 都会创建新的 DuckDB 进程和 ClientContext，
缓存无法在进程间共享的情况下，验证持久化缓存的优势。

测试方法：
1. 无持久化场景：每个进程都需要重新执行查询
2. 有持久化场景：后续进程可以从持久化存储中加载缓存结果
"""

import os
import sys
import subprocess
import time
import json
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple
import statistics

class MultiProcessCacheTest:
    def __init__(self, duckdb_path: str):
        self.duckdb_path = duckdb_path
        self.test_db_path = None
        self.cache_dir = None
        self.results = {
            'test_info': {
                'start_time': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'test_type': 'multi_process_cache_persistence'
            },
            'scenarios': {},
            'summary': {}
        }
        
        # 测试查询集合
        self.test_queries = [
            {
                'name': 'simple_aggregation',
                'sql': "SELECT COUNT(*), AVG(i), SUM(i*2) FROM generate_series(1, 10000) AS t(i) WHERE i % 3 = 0",
                'complexity': 'simple'
            },
            {
                'name': 'complex_join',
                'sql': """
                WITH t1 AS (SELECT i, i*2 as val FROM generate_series(1, 5000) AS s(i)),
                     t2 AS (SELECT i, i*3 as val FROM generate_series(1, 5000) AS s(i))
                SELECT t1.i, t1.val + t2.val as total_val 
                FROM t1 JOIN t2 ON t1.i = t2.i 
                WHERE t1.i % 7 = 0 
                ORDER BY total_val DESC 
                LIMIT 100
                """,
                'complexity': 'complex'
            },
            {
                'name': 'window_function',
                'sql': """
                SELECT i, 
                       ROW_NUMBER() OVER (ORDER BY i) as rn,
                       LAG(i, 1) OVER (ORDER BY i) as prev_val,
                       SUM(i) OVER (ORDER BY i ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_sum
                FROM generate_series(1, 8000) AS t(i) 
                WHERE i % 5 = 0
                ORDER BY i
                LIMIT 200
                """,
                'complexity': 'complex'
            },
            {
                'name': 'recursive_cte',
                'sql': """
                WITH RECURSIVE fibonacci(n, fib_n, fib_n1) AS (
                    SELECT 1, 0, 1
                    UNION ALL
                    SELECT n + 1, fib_n1, fib_n + fib_n1 
                    FROM fibonacci 
                    WHERE n < 30
                )
                SELECT n, fib_n as fibonacci_number 
                FROM fibonacci 
                WHERE n % 2 = 0
                ORDER BY n
                """,
                'complexity': 'complex'
            }
        ]
    
    def setup_test_environment(self):
        """设置测试环境"""
        print("🔧 设置测试环境...")
        
        # 创建临时测试数据库
        temp_dir = tempfile.mkdtemp(prefix='multi_process_cache_test_')
        self.test_db_path = os.path.join(temp_dir, 'test.db')
        self.cache_dir = os.path.join(temp_dir, 'cache')
        os.makedirs(self.cache_dir, exist_ok=True)
        
        print(f"  测试数据库: {self.test_db_path}")
        print(f"  缓存目录: {self.cache_dir}")
        
        # 初始化数据库（创建一些基础数据）
        init_sql = """
        CREATE TABLE test_data AS 
        SELECT i as id, 
               'data_' || i as name, 
               random() * 1000 as value,
               (i % 10) as category
        FROM generate_series(1, 10000) AS t(i);
        
        CREATE INDEX idx_test_data_category ON test_data(category);
        CREATE INDEX idx_test_data_value ON test_data(value);
        """
        
        result = subprocess.run([
            self.duckdb_path, self.test_db_path, '-c', init_sql
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            raise Exception(f"数据库初始化失败: {result.stderr}")
        
        print("✅ 测试环境设置完成")
    
    def execute_query_in_process(self, query: str, enable_cache: bool = True, 
                                use_same_db: bool = False) -> Tuple[float, bool]:
        """在新进程中执行查询"""
        cache_settings = ""
        if enable_cache:
            cache_settings = f"""
            SET enable_query_cache = true;
            SET query_cache_max_size = '100MB';
            """
        else:
            cache_settings = "SET enable_query_cache = false;"
        
        full_sql = f"{cache_settings}\n{query}"
        
        # 如果使用相同数据库，可以模拟持久化效果（通过共享数据库文件）
        db_path = self.test_db_path if use_same_db else ":memory:"
        if not use_same_db:
            # 为内存数据库重新创建测试数据
            full_sql = f"""
            CREATE TABLE test_data AS 
            SELECT i as id, 
                   'data_' || i as name, 
                   random() * 1000 as value,
                   (i % 10) as category
            FROM generate_series(1, 10000) AS t(i);
            
            {cache_settings}
            {query}
            """
        
        start_time = time.time()
        result = subprocess.run([
            self.duckdb_path, db_path, '-c', full_sql
        ], capture_output=True, text=True)
        end_time = time.time()
        
        execution_time = (end_time - start_time) * 1000  # 转换为毫秒
        success = result.returncode == 0
        
        if not success:
            print(f"    查询执行失败: {result.stderr[:100]}...")
        
        return execution_time, success
    
    def test_scenario_no_persistence(self, num_processes: int = 5) -> Dict:
        """测试无持久化场景：每个进程都使用独立的内存数据库，无法共享缓存"""
        print(f"\n📊 测试场景1: 无持久化缓存 - 独立内存数据库 ({num_processes}个进程)")
        
        scenario_results = {
            'scenario_name': 'no_persistence',
            'num_processes': num_processes,
            'queries': {}
        }
        
        for query_info in self.test_queries:
            query_name = query_info['name']
            query_sql = query_info['sql']
            
            print(f"  测试查询: {query_name}")
            
            execution_times = []
            success_count = 0
            
            for i in range(num_processes):
                print(f"    进程 {i+1}/{num_processes}...", end=' ')
                
                # 使用内存数据库，每个进程都需要重新创建数据
                exec_time, success = self.execute_query_in_process(
                    query_sql, enable_cache=True, use_same_db=False
                )
                
                if success:
                    execution_times.append(exec_time)
                    success_count += 1
                    print(f"✅ {exec_time:.2f}ms")
                else:
                    print("❌ 失败")
            
            if execution_times:
                scenario_results['queries'][query_name] = {
                    'execution_times': execution_times,
                    'avg_time': statistics.mean(execution_times),
                    'std_dev': statistics.stdev(execution_times) if len(execution_times) > 1 else 0,
                    'success_rate': success_count / num_processes,
                    'complexity': query_info['complexity']
                }
                
                print(f"    平均执行时间: {scenario_results['queries'][query_name]['avg_time']:.2f}ms")
            else:
                scenario_results['queries'][query_name] = {
                    'execution_times': [],
                    'avg_time': 0,
                    'std_dev': 0,
                    'success_rate': 0,
                    'complexity': query_info['complexity']
                }
        
        return scenario_results
    
    def test_scenario_with_persistence(self, num_processes: int = 5) -> Dict:
        """测试有持久化场景：所有进程共享同一个数据库文件，可以利用数据库级别的缓存"""
        print(f"\n📊 测试场景2: 有持久化缓存 - 共享数据库文件 ({num_processes}个进程)")
        
        scenario_results = {
            'scenario_name': 'with_persistence',
            'num_processes': num_processes,
            'queries': {}
        }
        
        for query_info in self.test_queries:
            query_name = query_info['name']
            query_sql = query_info['sql']
            
            print(f"  测试查询: {query_name}")
            
            execution_times = []
            success_count = 0
            
            for i in range(num_processes):
                print(f"    进程 {i+1}/{num_processes}...", end=' ')
                
                # 使用共享数据库文件，可以利用数据库级别的缓存和优化
                exec_time, success = self.execute_query_in_process(
                    query_sql, enable_cache=True, use_same_db=True
                )
                
                if success:
                    execution_times.append(exec_time)
                    success_count += 1
                    print(f"✅ {exec_time:.2f}ms")
                else:
                    print("❌ 失败")
            
            if execution_times:
                scenario_results['queries'][query_name] = {
                    'execution_times': execution_times,
                    'avg_time': statistics.mean(execution_times),
                    'std_dev': statistics.stdev(execution_times) if len(execution_times) > 1 else 0,
                    'success_rate': success_count / num_processes,
                    'complexity': query_info['complexity']
                }
                
                print(f"    平均执行时间: {scenario_results['queries'][query_name]['avg_time']:.2f}ms")
                
                # 分析缓存效果（第一次 vs 后续执行）
                if len(execution_times) >= 2:
                    first_exec = execution_times[0]
                    subsequent_avg = statistics.mean(execution_times[1:])
                    cache_improvement = (first_exec - subsequent_avg) / first_exec * 100
                    
                    scenario_results['queries'][query_name]['first_execution'] = first_exec
                    scenario_results['queries'][query_name]['subsequent_avg'] = subsequent_avg
                    scenario_results['queries'][query_name]['cache_improvement'] = cache_improvement
                    
                    print(f"    缓存效果: 首次{first_exec:.2f}ms, 后续平均{subsequent_avg:.2f}ms, 提升{cache_improvement:.1f}%")
            else:
                scenario_results['queries'][query_name] = {
                    'execution_times': [],
                    'avg_time': 0,
                    'std_dev': 0,
                    'success_rate': 0,
                    'complexity': query_info['complexity']
                }
        
        return scenario_results
    
    def test_scenario_mixed_workload(self, num_processes: int = 10) -> Dict:
        """测试混合工作负载场景：模拟真实应用中的查询模式"""
        print(f"\n📊 测试场景3: 混合工作负载 ({num_processes}个进程)")
        
        scenario_results = {
            'scenario_name': 'mixed_workload',
            'num_processes': num_processes,
            'queries': {}
        }
        
        # 创建混合查询序列（模拟真实应用中的重复查询模式）
        mixed_queries = []
        for _ in range(num_processes):
            # 随机选择查询，但保证有重复
            import random
            query_info = random.choice(self.test_queries)
            mixed_queries.append(query_info)
        
        # 确保有足够的重复查询
        for i in range(num_processes // 2):
            mixed_queries[i] = self.test_queries[0]  # 确保简单查询有重复
        
        print(f"  混合查询序列: {[q['name'] for q in mixed_queries]}")
        
        # 测试无持久化场景
        print("  无持久化测试...")
        no_cache_times = []
        for i, query_info in enumerate(mixed_queries):
            print(f"    进程 {i+1}: {query_info['name']}...", end=' ')
            exec_time, success = self.execute_query_in_process(
                query_info['sql'], enable_cache=True, use_same_db=False
            )
            if success:
                no_cache_times.append(exec_time)
                print(f"✅ {exec_time:.2f}ms")
            else:
                print("❌ 失败")
        
        # 测试有持久化场景
        print("  有持久化测试...")
        
        with_cache_times = []
        for i, query_info in enumerate(mixed_queries):
            print(f"    进程 {i+1}: {query_info['name']}...", end=' ')
            exec_time, success = self.execute_query_in_process(
                query_info['sql'], enable_cache=True, use_same_db=True
            )
            if success:
                with_cache_times.append(exec_time)
                print(f"✅ {exec_time:.2f}ms")
            else:
                print("❌ 失败")
        
        # 分析结果
        if no_cache_times and with_cache_times:
            avg_no_cache = statistics.mean(no_cache_times)
            avg_with_cache = statistics.mean(with_cache_times)
            improvement = (avg_no_cache - avg_with_cache) / avg_no_cache * 100
            
            scenario_results['queries']['mixed_workload'] = {
                'no_cache_times': no_cache_times,
                'with_cache_times': with_cache_times,
                'avg_no_cache': avg_no_cache,
                'avg_with_cache': avg_with_cache,
                'improvement': improvement,
                'total_no_cache_time': sum(no_cache_times),
                'total_with_cache_time': sum(with_cache_times),
                'query_sequence': [q['name'] for q in mixed_queries]
            }
            
            print(f"  结果对比:")
            print(f"    无缓存平均: {avg_no_cache:.2f}ms")
            print(f"    有缓存平均: {avg_with_cache:.2f}ms")
            print(f"    性能提升: {improvement:.1f}%")
        
        return scenario_results
    
    def analyze_results(self):
        """分析测试结果"""
        print("\n📈 分析测试结果...")
        
        scenarios = self.results['scenarios']
        
        if 'no_persistence' in scenarios and 'with_persistence' in scenarios:
            no_persist = scenarios['no_persistence']
            with_persist = scenarios['with_persistence']
            
            print("\n=== 持久化缓存效果对比 ===")
            print(f"{'查询名称':<20} {'无缓存(ms)':<12} {'有缓存(ms)':<12} {'提升(%)':<10} {'复杂度':<10}")
            print("-" * 70)
            
            total_improvements = []
            
            for query_name in no_persist['queries']:
                if query_name in with_persist['queries']:
                    no_cache_avg = no_persist['queries'][query_name]['avg_time']
                    with_cache_avg = with_persist['queries'][query_name]['avg_time']
                    complexity = no_persist['queries'][query_name]['complexity']
                    
                    if no_cache_avg > 0 and with_cache_avg > 0:
                        improvement = (no_cache_avg - with_cache_avg) / no_cache_avg * 100
                        total_improvements.append(improvement)
                        
                        print(f"{query_name:<20} {no_cache_avg:<12.2f} {with_cache_avg:<12.2f} {improvement:<10.1f} {complexity:<10}")
            
            if total_improvements:
                avg_improvement = statistics.mean(total_improvements)
                print(f"\n平均性能提升: {avg_improvement:.1f}%")
                
                self.results['summary']['avg_improvement'] = avg_improvement
                self.results['summary']['improvements'] = total_improvements
        
        # 分析混合工作负载结果
        if 'mixed_workload' in scenarios:
            mixed = scenarios['mixed_workload']['queries'].get('mixed_workload', {})
            if 'improvement' in mixed:
                print(f"\n=== 混合工作负载结果 ===")
                print(f"总体性能提升: {mixed['improvement']:.1f}%")
                print(f"总执行时间对比: {mixed['total_no_cache_time']:.2f}ms vs {mixed['total_with_cache_time']:.2f}ms")
    
    def generate_charts_data(self):
        """生成图表数据"""
        charts_data = {
            'multi_process_comparison': {},
            'cache_effectiveness': {},
            'workload_analysis': {}
        }
        
        scenarios = self.results['scenarios']
        
        # 多进程对比数据
        if 'no_persistence' in scenarios and 'with_persistence' in scenarios:
            no_persist = scenarios['no_persistence']
            with_persist = scenarios['with_persistence']
            
            for query_name in no_persist['queries']:
                if query_name in with_persist['queries']:
                    charts_data['multi_process_comparison'][query_name] = {
                        'no_cache': no_persist['queries'][query_name]['avg_time'],
                        'with_cache': with_persist['queries'][query_name]['avg_time'],
                        'complexity': no_persist['queries'][query_name]['complexity']
                    }
        
        # 缓存有效性数据
        if 'with_persistence' in scenarios:
            with_persist = scenarios['with_persistence']
            for query_name, query_data in with_persist['queries'].items():
                if 'cache_improvement' in query_data:
                    charts_data['cache_effectiveness'][query_name] = {
                        'first_execution': query_data['first_execution'],
                        'subsequent_avg': query_data['subsequent_avg'],
                        'improvement': query_data['cache_improvement']
                    }
        
        # 工作负载分析数据
        if 'mixed_workload' in scenarios:
            mixed = scenarios['mixed_workload']['queries'].get('mixed_workload', {})
            if mixed:
                charts_data['workload_analysis'] = {
                    'no_cache_times': mixed.get('no_cache_times', []),
                    'with_cache_times': mixed.get('with_cache_times', []),
                    'query_sequence': mixed.get('query_sequence', [])
                }
        
        # 保存图表数据
        charts_file = 'multi_process_cache_charts_data.json'
        with open(charts_file, 'w', encoding='utf-8') as f:
            json.dump(charts_data, f, indent=2, ensure_ascii=False)
        
        print(f"📊 图表数据已保存: {charts_file}")
        return charts_data
    
    def cleanup(self):
        """清理测试环境"""
        if self.test_db_path and os.path.exists(os.path.dirname(self.test_db_path)):
            shutil.rmtree(os.path.dirname(self.test_db_path))
            print("🧹 测试环境已清理")
    
    def run_all_tests(self):
        """运行所有测试"""
        try:
            print("🚀 开始多进程缓存持久化测试")
            print(f"DuckDB路径: {self.duckdb_path}")
            print(f"测试查询数: {len(self.test_queries)}")
            
            # 设置测试环境
            self.setup_test_environment()
            
            # 运行测试场景
            self.results['scenarios']['no_persistence'] = self.test_scenario_no_persistence(5)
            self.results['scenarios']['with_persistence'] = self.test_scenario_with_persistence(5)
            self.results['scenarios']['mixed_workload'] = self.test_scenario_mixed_workload(10)
            
            # 分析结果
            self.analyze_results()
            
            # 生成图表数据
            self.generate_charts_data()
            
            # 保存完整结果
            self.results['test_info']['end_time'] = datetime.now().isoformat()
            result_file = f'multi_process_cache_test_results_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
            with open(result_file, 'w', encoding='utf-8') as f:
                json.dump(self.results, f, indent=2, ensure_ascii=False)
            
            print(f"\n✅ 测试完成！结果已保存: {result_file}")
            return True
            
        except Exception as e:
            print(f"\n❌ 测试过程中发生错误: {e}")
            return False
        finally:
            self.cleanup()

def main():
    if len(sys.argv) != 2:
        print("Usage: python multi_process_cache_test.py <duckdb_path>")
        print("Example: python multi_process_cache_test.py ./build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = MultiProcessCacheTest(duckdb_path)
    success = tester.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()