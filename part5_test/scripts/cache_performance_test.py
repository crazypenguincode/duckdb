#!/usr/bin/env python3
"""
缓存性能对比测试脚本
对比开启缓存与不开启缓存的性能差异
"""

import os
import sys
import json
import time
import sqlite3
import statistics
import subprocess
from datetime import datetime
from pathlib import Path

class CachePerformanceTest:
    def __init__(self, duckdb_path, test_db_path):
        self.duckdb_path = duckdb_path
        self.test_db_path = test_db_path
        self.results = {
            'test_info': {
                'timestamp': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'test_db_path': test_db_path
            },
            'datasets': {}
        }
    
    def setup_test_database(self):
        """设置测试数据库"""
        print("设置测试数据库...")
        
        # 创建数据库和表结构
        create_sql_path = Path(__file__).parent.parent / 'dataset' / 'create_test_database.sql'
        
        if not create_sql_path.exists():
            raise FileNotFoundError(f"未找到数据库创建脚本: {create_sql_path}")
        
        # 使用DuckDB执行创建脚本
        cmd = [self.duckdb_path, self.test_db_path, f".read {create_sql_path}"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            raise RuntimeError(f"数据库创建失败: {result.stderr}")
        
        print("测试数据库创建完成")
    
    def execute_query_batch(self, queries, cache_enabled=True, batch_name=""):
        """执行查询批次"""
        print(f"执行查询批次: {batch_name} (缓存{'开启' if cache_enabled else '关闭'})")
        
        results = []
        
        # 构建DuckDB命令
        cache_setting = "SET enable_query_cache = true;" if cache_enabled else "SET enable_query_cache = false;"
        
        for i, query in enumerate(queries, 1):
            if i % 50 == 0:
                print(f"  进度: {i}/{len(queries)}")
            
            # 准备SQL命令
            full_sql = f"{cache_setting}\n{query}"
            
            start_time = time.time()
            try:
                # 执行查询
                cmd = [self.duckdb_path, self.test_db_path, "-c", full_sql]
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                
                end_time = time.time()
                execution_time = (end_time - start_time) * 1000  # 转换为毫秒
                
                if result.returncode == 0:
                    # 计算结果行数
                    result_lines = len([line for line in result.stdout.strip().split('\n') if line.strip()])
                    
                    query_result = {
                        'query_id': i,
                        'execution_time_ms': execution_time,
                        'result_count': result_lines,
                        'success': True,
                        'cache_enabled': cache_enabled
                    }
                else:
                    query_result = {
                        'query_id': i,
                        'execution_time_ms': execution_time,
                        'result_count': 0,
                        'success': False,
                        'error': result.stderr.strip(),
                        'cache_enabled': cache_enabled
                    }
                
            except subprocess.TimeoutExpired:
                query_result = {
                    'query_id': i,
                    'execution_time_ms': 30000,  # 超时时间
                    'result_count': 0,
                    'success': False,
                    'error': 'Query timeout',
                    'cache_enabled': cache_enabled
                }
            except Exception as e:
                query_result = {
                    'query_id': i,
                    'execution_time_ms': 0,
                    'result_count': 0,
                    'success': False,
                    'error': str(e),
                    'cache_enabled': cache_enabled
                }
            
            results.append(query_result)
        
        return results
    
    def analyze_results(self, cached_results, uncached_results, dataset_name):
        """分析测试结果"""
        print(f"分析结果: {dataset_name}")
        
        # 过滤成功的查询
        cached_success = [r for r in cached_results if r['success']]
        uncached_success = [r for r in uncached_results if r['success']]
        
        if not cached_success or not uncached_success:
            return {
                'dataset': dataset_name,
                'error': 'Insufficient successful queries for analysis'
            }
        
        # 计算统计信息
        cached_times = [r['execution_time_ms'] for r in cached_success]
        uncached_times = [r['execution_time_ms'] for r in uncached_success]
        
        analysis = {
            'dataset': dataset_name,
            'cached_performance': {
                'total_queries': len(cached_results),
                'successful_queries': len(cached_success),
                'success_rate': len(cached_success) / len(cached_results) * 100,
                'avg_execution_time_ms': statistics.mean(cached_times),
                'median_execution_time_ms': statistics.median(cached_times),
                'min_execution_time_ms': min(cached_times),
                'max_execution_time_ms': max(cached_times),
                'std_execution_time_ms': statistics.stdev(cached_times) if len(cached_times) > 1 else 0,
                'total_execution_time_ms': sum(cached_times)
            },
            'uncached_performance': {
                'total_queries': len(uncached_results),
                'successful_queries': len(uncached_success),
                'success_rate': len(uncached_success) / len(uncached_results) * 100,
                'avg_execution_time_ms': statistics.mean(uncached_times),
                'median_execution_time_ms': statistics.median(uncached_times),
                'min_execution_time_ms': min(uncached_times),
                'max_execution_time_ms': max(uncached_times),
                'std_execution_time_ms': statistics.stdev(uncached_times) if len(uncached_times) > 1 else 0,
                'total_execution_time_ms': sum(uncached_times)
            }
        }
        
        # 计算性能提升
        avg_improvement = (analysis['uncached_performance']['avg_execution_time_ms'] - 
                          analysis['cached_performance']['avg_execution_time_ms']) / \
                         analysis['uncached_performance']['avg_execution_time_ms'] * 100
        
        total_improvement = (analysis['uncached_performance']['total_execution_time_ms'] - 
                           analysis['cached_performance']['total_execution_time_ms']) / \
                          analysis['uncached_performance']['total_execution_time_ms'] * 100
        
        analysis['performance_improvement'] = {
            'avg_time_improvement_pct': avg_improvement,
            'total_time_improvement_pct': total_improvement,
            'speedup_factor': analysis['uncached_performance']['avg_execution_time_ms'] / 
                            analysis['cached_performance']['avg_execution_time_ms']
        }
        
        return analysis
    
    def load_queries_from_file(self, file_path):
        """从文件加载查询"""
        queries = []
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 分割查询（以分号和空行为分隔符）
        query_blocks = content.split('\n\n')
        
        for block in query_blocks:
            # 移除注释行
            lines = [line for line in block.split('\n') if not line.strip().startswith('--')]
            query = '\n'.join(lines).strip()
            
            if query and not query.startswith('--'):
                # 确保查询以分号结尾
                if not query.endswith(';'):
                    query += ';'
                queries.append(query)
        
        return queries
    
    def test_dataset(self, dataset_name, query_file_path):
        """测试单个数据集"""
        print(f"\n=== 测试数据集: {dataset_name} ===")
        
        # 加载查询
        queries = self.load_queries_from_file(query_file_path)
        print(f"加载了 {len(queries)} 个查询")
        
        if not queries:
            print(f"警告: 数据集 {dataset_name} 没有有效查询")
            return
        
        # 测试无缓存性能
        print("测试无缓存性能...")
        uncached_results = self.execute_query_batch(queries, cache_enabled=False, batch_name=f"{dataset_name}_uncached")
        
        # 等待一段时间
        time.sleep(2)
        
        # 测试有缓存性能
        print("测试有缓存性能...")
        cached_results = self.execute_query_batch(queries, cache_enabled=True, batch_name=f"{dataset_name}_cached")
        
        # 分析结果
        analysis = self.analyze_results(cached_results, uncached_results, dataset_name)
        
        # 保存结果
        self.results['datasets'][dataset_name] = {
            'analysis': analysis,
            'cached_results': cached_results,
            'uncached_results': uncached_results
        }
        
        # 打印摘要
        if 'error' not in analysis:
            print(f"结果摘要:")
            print(f"  平均执行时间提升: {analysis['performance_improvement']['avg_time_improvement_pct']:.2f}%")
            print(f"  总执行时间提升: {analysis['performance_improvement']['total_time_improvement_pct']:.2f}%")
            print(f"  加速倍数: {analysis['performance_improvement']['speedup_factor']:.2f}x")
        else:
            print(f"测试失败: {analysis['error']}")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("开始缓存性能对比测试")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"测试数据库: {self.test_db_path}")
        
        # 设置测试数据库
        self.setup_test_database()
        
        # 定义测试数据集
        dataset_dir = Path(__file__).parent.parent / 'dataset'
        
        test_datasets = [
            {
                'name': '重复查询集',
                'file': dataset_dir / 'repeat_queries' / 'repeat_queries_all.sql',
                'description': '1000个查询，高重复率(80%)'
            },
            {
                'name': '参数化查询集',
                'file': dataset_dir / 'parameterized_queries' / 'parameterized_queries_all.sql',
                'description': '500个模板，参数变化'
            },
            {
                'name': 'CTE查询集',
                'file': dataset_dir / 'cte_queries' / 'cte_queries_all.sql',
                'description': '200个查询，复杂CTE结构'
            },
            {
                'name': '并发查询集',
                'file': dataset_dir / 'concurrent_queries' / 'concurrent_queries_all.sql',
                'description': '100个查询，高并发访问'
            }
        ]
        
        # 测试每个数据集
        for dataset in test_datasets:
            if dataset['file'].exists():
                self.test_dataset(dataset['name'], dataset['file'])
            else:
                print(f"警告: 数据集文件不存在: {dataset['file']}")
        
        # 生成综合报告
        self.generate_summary_report()
    
    def generate_summary_report(self):
        """生成综合报告"""
        print("\n=== 综合测试报告 ===")
        
        summary = {
            'test_summary': {
                'total_datasets': len(self.results['datasets']),
                'test_timestamp': self.results['test_info']['timestamp']
            },
            'performance_summary': {}
        }
        
        for dataset_name, dataset_results in self.results['datasets'].items():
            analysis = dataset_results['analysis']
            
            if 'error' not in analysis:
                summary['performance_summary'][dataset_name] = {
                    'avg_improvement_pct': analysis['performance_improvement']['avg_time_improvement_pct'],
                    'total_improvement_pct': analysis['performance_improvement']['total_time_improvement_pct'],
                    'speedup_factor': analysis['performance_improvement']['speedup_factor'],
                    'cached_avg_time_ms': analysis['cached_performance']['avg_execution_time_ms'],
                    'uncached_avg_time_ms': analysis['uncached_performance']['avg_execution_time_ms'],
                    'success_rate_cached': analysis['cached_performance']['success_rate'],
                    'success_rate_uncached': analysis['uncached_performance']['success_rate']
                }
                
                print(f"\n{dataset_name}:")
                print(f"  平均执行时间提升: {analysis['performance_improvement']['avg_time_improvement_pct']:.2f}%")
                print(f"  加速倍数: {analysis['performance_improvement']['speedup_factor']:.2f}x")
                print(f"  缓存成功率: {analysis['cached_performance']['success_rate']:.2f}%")
                print(f"  无缓存成功率: {analysis['uncached_performance']['success_rate']:.2f}%")
        
        # 计算总体性能提升
        if summary['performance_summary']:
            improvements = [data['avg_improvement_pct'] for data in summary['performance_summary'].values()]
            speedups = [data['speedup_factor'] for data in summary['performance_summary'].values()]
            
            summary['overall_performance'] = {
                'avg_improvement_pct': statistics.mean(improvements),
                'avg_speedup_factor': statistics.mean(speedups),
                'best_improvement_pct': max(improvements),
                'worst_improvement_pct': min(improvements)
            }
            
            print(f"\n总体性能:")
            print(f"  平均性能提升: {summary['overall_performance']['avg_improvement_pct']:.2f}%")
            print(f"  平均加速倍数: {summary['overall_performance']['avg_speedup_factor']:.2f}x")
            print(f"  最佳提升: {summary['overall_performance']['best_improvement_pct']:.2f}%")
            print(f"  最差提升: {summary['overall_performance']['worst_improvement_pct']:.2f}%")
        
        # 保存完整结果
        self.results['summary'] = summary
        
        output_file = f"cache_performance_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"\n完整测试结果已保存到: {output_file}")

def main():
    """主函数"""
    if len(sys.argv) != 3:
        print("Usage: python cache_performance_test.py <duckdb_path> <test_db_path>")
        print("Example: python cache_performance_test.py ./duckdb test_cache.db")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    test_db_path = sys.argv[2]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    # 创建测试实例
    tester = CachePerformanceTest(duckdb_path, test_db_path)
    
    try:
        # 运行所有测试
        tester.run_all_tests()
        print("\n所有测试完成！")
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()