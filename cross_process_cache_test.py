#!/usr/bin/env python3
"""
跨进程缓存策略测试脚本
专门测试CROSS_PROCESS策略在多进程环境下的缓存效果
"""

import os
import sys
import subprocess
import time
import json
from pathlib import Path
from datetime import datetime

class CrossProcessCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.test_db_path = "cross_process_cache_test.db"
        self.cache_storage_path = "cross_process_cache_storage"
        
        # 确保缓存存储目录存在
        Path(self.cache_storage_path).mkdir(exist_ok=True)
        
        self.test_queries = [
            {
                'name': 'simple_aggregation',
                'sql': "SELECT COUNT(*), AVG(i), SUM(i*2) FROM generate_series(1, 50000) AS t(i) WHERE i % 3 = 0",
                'complexity': 'simple'
            },
            {
                'name': 'complex_window_functions',
                'sql': """
                WITH data AS (
                    SELECT i, i % 10 as group_id, i * 1.5 as value
                    FROM generate_series(1, 20000) AS t(i)
                )
                SELECT 
                    group_id,
                    COUNT(*) as count,
                    AVG(value) as avg_value,
                    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank,
                    LAG(COUNT(*), 1) OVER (ORDER BY group_id) as prev_count,
                    SUM(COUNT(*)) OVER (ORDER BY group_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
                FROM data 
                GROUP BY group_id 
                ORDER BY group_id
                """,
                'complexity': 'complex'
            },
            {
                'name': 'recursive_cte',
                'sql': """
                WITH RECURSIVE fibonacci(n, fib_n, fib_n1) AS (
                    SELECT 1, 0, 1
                    UNION ALL
                    SELECT n+1, fib_n1, fib_n + fib_n1 
                    FROM fibonacci 
                    WHERE n < 30
                )
                SELECT n, fib_n as fibonacci_number FROM fibonacci
                """,
                'complexity': 'complex'
            },
            {
                'name': 'multi_table_join',
                'sql': """
                WITH orders AS (
                    SELECT i as order_id, (i % 1000) as customer_id, i * 10.5 as amount
                    FROM generate_series(1, 10000) AS t(i)
                ),
                customers AS (
                    SELECT i as customer_id, 'Customer_' || i as name
                    FROM generate_series(1, 1000) AS t(i)
                )
                SELECT 
                    c.name,
                    COUNT(o.order_id) as order_count,
                    SUM(o.amount) as total_amount,
                    AVG(o.amount) as avg_amount
                FROM customers c
                LEFT JOIN orders o ON c.customer_id = o.customer_id
                GROUP BY c.customer_id, c.name
                HAVING COUNT(o.order_id) > 5
                ORDER BY total_amount DESC
                LIMIT 100
                """,
                'complexity': 'complex'
            }
        ]
    
    def setup_database(self):
        """设置测试数据库"""
        print("Setting up test database...")
        
        # 删除旧的数据库文件
        if os.path.exists(self.test_db_path):
            os.remove(self.test_db_path)
        
        # 创建数据库并设置跨进程缓存
        setup_sql = f"""
        -- 启用查询缓存
        SET enable_query_cache = true;
        SET query_cache_max_size = '100MB';
        
        -- 创建一些测试数据（如果需要）
        CREATE TABLE IF NOT EXISTS test_data AS 
        SELECT i, i % 100 as category, random() as value 
        FROM generate_series(1, 10000) AS t(i);
        """
        
        cmd = [self.duckdb_path, self.test_db_path, "-c", setup_sql]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"Database setup failed: {result.stderr}")
            return False
        
        print("✓ Database setup completed")
        return True
    
    def execute_query_in_process(self, query_sql, process_id, use_cache=True):
        """在独立进程中执行查询"""
        cache_setting = "SET enable_query_cache = true;" if use_cache else "SET enable_query_cache = false;"
        
        # 跨进程缓存配置
        cache_config = f"""
        {cache_setting}
        SET query_cache_max_size = '100MB';
        """
        
        full_sql = f"{cache_config}\n{query_sql}"
        
        start_time = time.time()
        cmd = [self.duckdb_path, self.test_db_path, "-c", full_sql]
        result = subprocess.run(cmd, capture_output=True, text=True)
        end_time = time.time()
        
        execution_time = (end_time - start_time) * 1000  # 转换为毫秒
        
        if result.returncode == 0:
            return {
                'success': True,
                'execution_time_ms': execution_time,
                'process_id': process_id,
                'output_lines': len(result.stdout.strip().split('\n')) if result.stdout.strip() else 0
            }
        else:
            return {
                'success': False,
                'error': result.stderr,
                'execution_time_ms': execution_time,
                'process_id': process_id
            }
    
    def test_cross_process_cache_effectiveness(self):
        """测试跨进程缓存的有效性"""
        print("\n=== 跨进程缓存效果测试 ===")
        
        results = {
            'test_info': {
                'start_time': datetime.now().isoformat(),
                'duckdb_path': self.duckdb_path,
                'test_db_path': self.test_db_path,
                'cache_storage_path': self.cache_storage_path
            },
            'query_results': {}
        }
        
        for query_info in self.test_queries:
            query_name = query_info['name']
            query_sql = query_info['sql']
            complexity = query_info['complexity']
            
            print(f"\n--- 测试查询: {query_name} ({complexity}) ---")
            
            # 第一次执行：冷启动，建立缓存
            print("  第1次执行 (建立缓存)...")
            first_result = self.execute_query_in_process(query_sql, "process_1", use_cache=True)
            
            if not first_result['success']:
                print(f"  ❌ 第1次执行失败: {first_result['error']}")
                continue
            
            print(f"  ✓ 第1次执行完成: {first_result['execution_time_ms']:.2f}ms")
            
            # 等待缓存持久化
            time.sleep(0.5)
            
            # 第二次执行：新进程，应该从跨进程缓存加载
            print("  第2次执行 (新进程，跨进程缓存)...")
            second_result = self.execute_query_in_process(query_sql, "process_2", use_cache=True)
            
            if not second_result['success']:
                print(f"  ❌ 第2次执行失败: {second_result['error']}")
                continue
            
            print(f"  ✓ 第2次执行完成: {second_result['execution_time_ms']:.2f}ms")
            
            # 第三次执行：新进程，禁用缓存作为对比
            print("  第3次执行 (新进程，无缓存对比)...")
            third_result = self.execute_query_in_process(query_sql, "process_3", use_cache=False)
            
            if not third_result['success']:
                print(f"  ❌ 第3次执行失败: {third_result['error']}")
                continue
            
            print(f"  ✓ 第3次执行完成: {third_result['execution_time_ms']:.2f}ms")
            
            # 计算性能提升
            cache_speedup = third_result['execution_time_ms'] / second_result['execution_time_ms']
            improvement_pct = (third_result['execution_time_ms'] - second_result['execution_time_ms']) / third_result['execution_time_ms'] * 100
            
            print(f"  📊 跨进程缓存加速比: {cache_speedup:.2f}x")
            print(f"  📊 性能提升: {improvement_pct:.2f}%")
            
            # 保存结果
            results['query_results'][query_name] = {
                'complexity': complexity,
                'first_execution_ms': first_result['execution_time_ms'],
                'cached_execution_ms': second_result['execution_time_ms'],
                'uncached_execution_ms': third_result['execution_time_ms'],
                'cache_speedup': cache_speedup,
                'improvement_pct': improvement_pct,
                'output_lines': first_result['output_lines']
            }
        
        return results
    
    def test_multiple_processes_concurrent(self):
        """测试多个进程并发访问跨进程缓存"""
        print("\n=== 多进程并发缓存测试 ===")
        
        # 选择一个复杂查询进行并发测试
        test_query = self.test_queries[1]  # complex_window_functions
        query_sql = test_query['sql']
        
        print(f"使用查询: {test_query['name']}")
        
        # 先执行一次建立缓存
        print("建立初始缓存...")
        initial_result = self.execute_query_in_process(query_sql, "initial", use_cache=True)
        if not initial_result['success']:
            print(f"初始缓存建立失败: {initial_result['error']}")
            return None
        
        print(f"初始执行时间: {initial_result['execution_time_ms']:.2f}ms")
        
        # 等待缓存持久化
        time.sleep(1.0)
        
        # 并发执行多个进程
        print("启动5个并发进程...")
        concurrent_results = []
        
        import concurrent.futures
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = []
            for i in range(5):
                future = executor.submit(self.execute_query_in_process, query_sql, f"concurrent_{i}", True)
                futures.append(future)
            
            for i, future in enumerate(concurrent.futures.as_completed(futures)):
                result = future.result()
                concurrent_results.append(result)
                if result['success']:
                    print(f"  进程 {i+1}: {result['execution_time_ms']:.2f}ms")
                else:
                    print(f"  进程 {i+1}: 失败 - {result['error']}")
        
        # 计算并发性能统计
        successful_results = [r for r in concurrent_results if r['success']]
        if successful_results:
            avg_time = sum(r['execution_time_ms'] for r in successful_results) / len(successful_results)
            min_time = min(r['execution_time_ms'] for r in successful_results)
            max_time = max(r['execution_time_ms'] for r in successful_results)
            
            print(f"\n并发执行统计:")
            print(f"  成功进程数: {len(successful_results)}/5")
            print(f"  平均执行时间: {avg_time:.2f}ms")
            print(f"  最快执行时间: {min_time:.2f}ms")
            print(f"  最慢执行时间: {max_time:.2f}ms")
            print(f"  相对初始执行的加速比: {initial_result['execution_time_ms']/avg_time:.2f}x")
            
            return {
                'initial_time_ms': initial_result['execution_time_ms'],
                'concurrent_avg_ms': avg_time,
                'concurrent_min_ms': min_time,
                'concurrent_max_ms': max_time,
                'successful_processes': len(successful_results),
                'speedup_ratio': initial_result['execution_time_ms']/avg_time
            }
        
        return None
    
    def generate_report(self, effectiveness_results, concurrent_results):
        """生成测试报告"""
        print("\n=== 跨进程缓存测试报告 ===")
        
        # 保存详细结果到JSON文件
        report_data = {
            'test_info': effectiveness_results['test_info'],
            'effectiveness_test': effectiveness_results['query_results'],
            'concurrent_test': concurrent_results,
            'summary': {}
        }
        
        # 计算总体统计
        query_results = effectiveness_results['query_results']
        if query_results:
            improvements = [r['improvement_pct'] for r in query_results.values()]
            speedups = [r['cache_speedup'] for r in query_results.values()]
            
            avg_improvement = sum(improvements) / len(improvements)
            avg_speedup = sum(speedups) / len(speedups)
            max_improvement = max(improvements)
            min_improvement = min(improvements)
            
            report_data['summary'] = {
                'total_queries_tested': len(query_results),
                'avg_improvement_pct': avg_improvement,
                'avg_speedup_ratio': avg_speedup,
                'max_improvement_pct': max_improvement,
                'min_improvement_pct': min_improvement,
                'concurrent_test_success': concurrent_results is not None
            }
            
            print(f"测试查询数量: {len(query_results)}")
            print(f"平均性能提升: {avg_improvement:.2f}%")
            print(f"平均加速比: {avg_speedup:.2f}x")
            print(f"最大性能提升: {max_improvement:.2f}%")
            print(f"最小性能提升: {min_improvement:.2f}%")
            
            # 按复杂度分析
            simple_queries = [r for r in query_results.values() if r['complexity'] == 'simple']
            complex_queries = [r for r in query_results.values() if r['complexity'] == 'complex']
            
            if simple_queries:
                simple_avg = sum(r['improvement_pct'] for r in simple_queries) / len(simple_queries)
                print(f"简单查询平均提升: {simple_avg:.2f}%")
            
            if complex_queries:
                complex_avg = sum(r['improvement_pct'] for r in complex_queries) / len(complex_queries)
                print(f"复杂查询平均提升: {complex_avg:.2f}%")
        
        if concurrent_results:
            print(f"\n并发测试结果:")
            print(f"并发加速比: {concurrent_results['speedup_ratio']:.2f}x")
            print(f"成功进程数: {concurrent_results['successful_processes']}/5")
        
        # 保存报告文件
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"cross_process_cache_test_results_{timestamp}.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n详细报告已保存到: {report_file}")
        
        return report_data
    
    def cleanup(self):
        """清理测试文件"""
        try:
            if os.path.exists(self.test_db_path):
                os.remove(self.test_db_path)
            
            # 清理缓存存储目录
            import shutil
            if os.path.exists(self.cache_storage_path):
                shutil.rmtree(self.cache_storage_path)
                
            print("✓ 测试文件清理完成")
        except Exception as e:
            print(f"清理文件时出错: {e}")
    
    def run_full_test(self):
        """运行完整的跨进程缓存测试"""
        print("🚀 开始跨进程缓存策略测试")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        try:
            # 设置数据库
            if not self.setup_database():
                print("❌ 数据库设置失败")
                return False
            
            # 测试缓存效果
            effectiveness_results = self.test_cross_process_cache_effectiveness()
            
            # 测试并发性能
            concurrent_results = self.test_multiple_processes_concurrent()
            
            # 生成报告
            report_data = self.generate_report(effectiveness_results, concurrent_results)
            
            # 判断测试是否成功
            if report_data['summary']:
                avg_improvement = report_data['summary']['avg_improvement_pct']
                if avg_improvement > 10:  # 如果平均提升超过10%认为成功
                    print(f"\n🎉 跨进程缓存测试成功！平均性能提升: {avg_improvement:.2f}%")
                    return True
                else:
                    print(f"\n⚠️ 跨进程缓存效果不明显，平均提升仅: {avg_improvement:.2f}%")
                    return False
            else:
                print("\n❌ 测试失败，无法获取有效结果")
                return False
                
        except Exception as e:
            print(f"❌ 测试过程中发生错误: {e}")
            return False
        finally:
            # 清理测试文件
            self.cleanup()

def main():
    if len(sys.argv) != 2:
        print("Usage: python cross_process_cache_test.py <duckdb_path>")
        print("Example: python cross_process_cache_test.py ./build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    # 运行测试
    tester = CrossProcessCacheTest(duckdb_path)
    success = tester.run_full_test()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()