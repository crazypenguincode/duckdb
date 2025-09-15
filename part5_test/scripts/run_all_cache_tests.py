#!/usr/bin/env python3
"""
运行所有缓存测试的主脚本
包括数据集生成、性能测试和结果分析
"""

import os
import sys
import subprocess
import json
import time
from pathlib import Path
from datetime import datetime

class CacheTestRunner:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / 'results'
        self.results_dir.mkdir(exist_ok=True)
        
        self.test_results = {
            'test_info': {
                'start_time': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'base_dir': str(self.base_dir)
            },
            'dataset_generation': {},
            'performance_tests': {},
            'summary': {}
        }
    
    def generate_datasets(self):
        """生成所有测试数据集"""
        print("=== 第一步: 生成测试数据集 ===")
        
        datasets = [
            {
                'name': '重复查询集',
                'script': self.base_dir / 'dataset' / 'repeat_queries' / 'generate_repeat_queries.py',
                'description': '1000个查询，高重复率(80%)'
            },
            {
                'name': '参数化查询集',
                'script': self.base_dir / 'dataset' / 'parameterized_queries' / 'generate_parameterized_queries.py',
                'description': '500个模板，参数变化'
            },
            {
                'name': 'CTE查询集',
                'script': self.base_dir / 'dataset' / 'cte_queries' / 'generate_cte_queries.py',
                'description': '200个查询，复杂CTE结构'
            },
            {
                'name': '并发查询集',
                'script': self.base_dir / 'dataset' / 'concurrent_queries' / 'generate_concurrent_queries.py',
                'description': '100个查询，高并发访问'
            }
        ]
        
        for dataset in datasets:
            print(f"\n生成 {dataset['name']}...")
            print(f"描述: {dataset['description']}")
            
            start_time = time.time()
            try:
                # 运行生成脚本
                result = subprocess.run([
                    sys.executable, str(dataset['script'])
                ], capture_output=True, text=True, cwd=dataset['script'].parent)
                
                end_time = time.time()
                generation_time = end_time - start_time
                
                if result.returncode == 0:
                    print(f"✓ 生成成功 (耗时: {generation_time:.2f}秒)")
                    
                    self.test_results['dataset_generation'][dataset['name']] = {
                        'success': True,
                        'generation_time': generation_time,
                        'output': result.stdout,
                        'script_path': str(dataset['script'])
                    }
                else:
                    print(f"✗ 生成失败: {result.stderr}")
                    
                    self.test_results['dataset_generation'][dataset['name']] = {
                        'success': False,
                        'error': result.stderr,
                        'script_path': str(dataset['script'])
                    }
                    
            except Exception as e:
                print(f"✗ 生成异常: {e}")
                
                self.test_results['dataset_generation'][dataset['name']] = {
                    'success': False,
                    'error': str(e),
                    'script_path': str(dataset['script'])
                }
        
        # 统计生成结果
        successful_datasets = sum(1 for result in self.test_results['dataset_generation'].values() if result['success'])
        total_datasets = len(datasets)
        
        print(f"\n数据集生成完成: {successful_datasets}/{total_datasets} 成功")
        
        return successful_datasets == total_datasets
    
    def run_performance_tests(self):
        """运行性能测试"""
        print("\n=== 第二步: 运行性能测试 ===")
        
        # 创建测试数据库
        test_db_path = self.results_dir / 'cache_test.db'
        
        print(f"测试数据库路径: {test_db_path}")
        
        # 运行缓存性能测试
        performance_script = self.base_dir / 'scripts' / 'cache_performance_test.py'
        
        print("开始缓存性能对比测试...")
        start_time = time.time()
        
        try:
            result = subprocess.run([
                sys.executable, str(performance_script),
                self.duckdb_path, str(test_db_path)
            ], capture_output=True, text=True, cwd=self.base_dir / 'scripts')
            
            end_time = time.time()
            test_time = end_time - start_time
            
            if result.returncode == 0:
                print(f"✓ 性能测试完成 (耗时: {test_time:.2f}秒)")
                
                self.test_results['performance_tests']['cache_comparison'] = {
                    'success': True,
                    'test_time': test_time,
                    'output': result.stdout,
                    'db_path': str(test_db_path)
                }
                
                # 查找生成的结果文件
                result_files = list(self.base_dir.glob('cache_performance_test_results_*.json'))
                if result_files:
                    latest_result = max(result_files, key=lambda x: x.stat().st_mtime)
                    self.test_results['performance_tests']['cache_comparison']['result_file'] = str(latest_result)
                
                return True
                
            else:
                print(f"✗ 性能测试失败: {result.stderr}")
                
                self.test_results['performance_tests']['cache_comparison'] = {
                    'success': False,
                    'error': result.stderr,
                    'db_path': str(test_db_path)
                }
                
                return False
                
        except Exception as e:
            print(f"✗ 性能测试异常: {e}")
            
            self.test_results['performance_tests']['cache_comparison'] = {
                'success': False,
                'error': str(e),
                'db_path': str(test_db_path)
            }
            
            return False
    
    def run_tpc_tests(self):
        """运行TPC-H和TPC-DS测试"""
        print("\n=== 第三步: 运行TPC基准测试 ===")
        
        tpc_databases = [
            {
                'name': 'TPC-H SF=1',
                'path': '/Users/max/test/tpc/tpch-sf1.db',
                'queries_dir': Path(__file__).parent.parent.parent / 'extension' / 'tpch' / 'dbgen' / 'queries'
            },
            {
                'name': 'TPC-DS SF=1',
                'path': '/Users/max/test/tpc/tpcds_sf1.db',
                'queries_dir': Path(__file__).parent.parent.parent / 'extension' / 'tpcds' / 'dsdgen' / 'queries'
            }
        ]
        
        for tpc_db in tpc_databases:
            print(f"\n测试 {tpc_db['name']}...")
            
            if not Path(tpc_db['path']).exists():
                print(f"⚠ 数据库文件不存在: {tpc_db['path']}")
                self.test_results['performance_tests'][tpc_db['name']] = {
                    'success': False,
                    'error': f"Database file not found: {tpc_db['path']}"
                }
                continue
            
            if not tpc_db['queries_dir'].exists():
                print(f"⚠ 查询目录不存在: {tpc_db['queries_dir']}")
                self.test_results['performance_tests'][tpc_db['name']] = {
                    'success': False,
                    'error': f"Queries directory not found: {tpc_db['queries_dir']}"
                }
                continue
            
            # 运行TPC测试
            success = self.run_tpc_benchmark(tpc_db['name'], tpc_db['path'], tpc_db['queries_dir'])
            
            if success:
                print(f"✓ {tpc_db['name']} 测试完成")
            else:
                print(f"✗ {tpc_db['name']} 测试失败")
    
    def run_tpc_benchmark(self, benchmark_name, db_path, queries_dir):
        """运行单个TPC基准测试"""
        try:
            # 获取所有查询文件
            query_files = sorted(queries_dir.glob('*.sql'))
            
            if not query_files:
                print(f"未找到查询文件在: {queries_dir}")
                return False
            
            print(f"找到 {len(query_files)} 个查询文件")
            
            # 测试前5个查询（避免测试时间过长）
            test_queries = query_files[:5]
            
            cached_times = []
            uncached_times = []
            
            for query_file in test_queries:
                print(f"  测试查询: {query_file.name}")
                
                # 读取查询
                with open(query_file, 'r', encoding='utf-8') as f:
                    query = f.read().strip()
                
                # 测试无缓存
                uncached_time = self.execute_single_query(db_path, query, cache_enabled=False)
                if uncached_time is not None:
                    uncached_times.append(uncached_time)
                
                # 测试有缓存
                cached_time = self.execute_single_query(db_path, query, cache_enabled=True)
                if cached_time is not None:
                    cached_times.append(cached_time)
            
            # 保存结果
            if cached_times and uncached_times:
                avg_cached = sum(cached_times) / len(cached_times)
                avg_uncached = sum(uncached_times) / len(uncached_times)
                improvement = (avg_uncached - avg_cached) / avg_uncached * 100
                
                self.test_results['performance_tests'][benchmark_name] = {
                    'success': True,
                    'queries_tested': len(test_queries),
                    'avg_cached_time_ms': avg_cached,
                    'avg_uncached_time_ms': avg_uncached,
                    'improvement_pct': improvement,
                    'cached_times': cached_times,
                    'uncached_times': uncached_times
                }
                
                print(f"    平均缓存时间: {avg_cached:.2f}ms")
                print(f"    平均无缓存时间: {avg_uncached:.2f}ms")
                print(f"    性能提升: {improvement:.2f}%")
                
                return True
            else:
                self.test_results['performance_tests'][benchmark_name] = {
                    'success': False,
                    'error': 'No successful query executions'
                }
                return False
                
        except Exception as e:
            self.test_results['performance_tests'][benchmark_name] = {
                'success': False,
                'error': str(e)
            }
            return False
    
    def execute_single_query(self, db_path, query, cache_enabled=True, timeout=30):
        """执行单个查询并返回执行时间（毫秒）"""
        try:
            cache_setting = "SET enable_query_cache = true;" if cache_enabled else "SET enable_query_cache = false;"
            full_sql = f"{cache_setting}\n{query}"
            
            start_time = time.time()
            
            cmd = [self.duckdb_path, db_path, "-c", full_sql]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
            
            end_time = time.time()
            execution_time = (end_time - start_time) * 1000  # 转换为毫秒
            
            if result.returncode == 0:
                return execution_time
            else:
                print(f"    查询执行失败: {result.stderr[:100]}...")
                return None
                
        except subprocess.TimeoutExpired:
            print(f"    查询超时 (>{timeout}秒)")
            return None
        except Exception as e:
            print(f"    查询异常: {e}")
            return None
    
    def generate_final_report(self):
        """生成最终报告"""
        print("\n=== 第四步: 生成测试报告 ===")
        
        # 计算总体统计
        self.test_results['test_info']['end_time'] = datetime.now().isoformat()
        
        # 数据集生成统计
        dataset_stats = self.test_results['dataset_generation']
        successful_datasets = sum(1 for result in dataset_stats.values() if result['success'])
        total_datasets = len(dataset_stats)
        
        # 性能测试统计
        performance_stats = self.test_results['performance_tests']
        successful_tests = sum(1 for result in performance_stats.values() if result['success'])
        total_tests = len(performance_stats)
        
        # 计算平均性能提升
        improvements = []
        for test_name, test_result in performance_stats.items():
            if test_result['success'] and 'improvement_pct' in test_result:
                improvements.append(test_result['improvement_pct'])
        
        avg_improvement = sum(improvements) / len(improvements) if improvements else 0
        
        # 生成摘要
        summary = {
            'dataset_generation': {
                'successful': successful_datasets,
                'total': total_datasets,
                'success_rate': successful_datasets / total_datasets * 100 if total_datasets > 0 else 0
            },
            'performance_tests': {
                'successful': successful_tests,
                'total': total_tests,
                'success_rate': successful_tests / total_tests * 100 if total_tests > 0 else 0,
                'avg_improvement_pct': avg_improvement,
                'improvements': improvements
            },
            'overall_success': successful_datasets == total_datasets and successful_tests > 0
        }
        
        self.test_results['summary'] = summary
        
        # 保存完整结果
        result_file = self.results_dir / f'cache_test_results_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(self.test_results, f, indent=2, ensure_ascii=False)
        
        # 生成Markdown报告
        self.generate_markdown_report(result_file)
        
        # 打印摘要
        print(f"\n=== 测试完成摘要 ===")
        print(f"数据集生成: {successful_datasets}/{total_datasets} 成功 ({summary['dataset_generation']['success_rate']:.1f}%)")
        print(f"性能测试: {successful_tests}/{total_tests} 成功 ({summary['performance_tests']['success_rate']:.1f}%)")
        if improvements:
            print(f"平均性能提升: {avg_improvement:.2f}%")
            print(f"性能提升范围: {min(improvements):.2f}% - {max(improvements):.2f}%")
        print(f"完整结果保存在: {result_file}")
        
        return summary['overall_success']
    
    def generate_markdown_report(self, result_file):
        """生成Markdown格式的报告"""
        report_file = result_file.with_suffix('.md')
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# 第五章表5.7缓存测试报告\n\n")
            f.write(f"**测试时间**: {self.test_results['test_info']['start_time']} - {self.test_results['test_info']['end_time']}\n\n")
            f.write(f"**DuckDB路径**: `{self.test_results['test_info']['duckdb_path']}`\n\n")
            
            # 数据集生成结果
            f.write("## 数据集生成结果\n\n")
            f.write("| 数据集类型 | 数据规模 | 查询特点 | 生成状态 | 耗时 |\n")
            f.write("|------------|----------|----------|----------|------|\n")
            
            dataset_info = {
                '重复查询集': ('1000个查询', '高重复率(80%)'),
                '参数化查询集': ('500个模板', '参数变化'),
                'CTE查询集': ('200个查询', '复杂CTE结构'),
                '并发查询集': ('100个查询', '高并发访问')
            }
            
            for dataset_name, (scale, feature) in dataset_info.items():
                result = self.test_results['dataset_generation'].get(dataset_name, {})
                status = "✓ 成功" if result.get('success') else "✗ 失败"
                time_cost = f"{result.get('generation_time', 0):.2f}s" if result.get('success') else "N/A"
                f.write(f"| {dataset_name} | {scale} | {feature} | {status} | {time_cost} |\n")
            
            # 性能测试结果
            f.write("\n## 缓存性能测试结果\n\n")
            f.write("| 测试类型 | 测试状态 | 平均性能提升 | 缓存平均时间 | 无缓存平均时间 |\n")
            f.write("|----------|----------|--------------|--------------|----------------|\n")
            
            for test_name, test_result in self.test_results['performance_tests'].items():
                if test_result['success']:
                    improvement = test_result.get('improvement_pct', 0)
                    cached_time = test_result.get('avg_cached_time_ms', 0)
                    uncached_time = test_result.get('avg_uncached_time_ms', 0)
                    
                    f.write(f"| {test_name} | ✓ 成功 | {improvement:.2f}% | {cached_time:.2f}ms | {uncached_time:.2f}ms |\n")
                else:
                    f.write(f"| {test_name} | ✗ 失败 | N/A | N/A | N/A |\n")
            
            # 总结
            summary = self.test_results['summary']
            f.write("\n## 测试总结\n\n")
            f.write(f"- **数据集生成成功率**: {summary['dataset_generation']['success_rate']:.1f}%\n")
            f.write(f"- **性能测试成功率**: {summary['performance_tests']['success_rate']:.1f}%\n")
            
            if summary['performance_tests']['improvements']:
                improvements = summary['performance_tests']['improvements']
                f.write(f"- **平均性能提升**: {summary['performance_tests']['avg_improvement_pct']:.2f}%\n")
                f.write(f"- **性能提升范围**: {min(improvements):.2f}% - {max(improvements):.2f}%\n")
            
            f.write(f"\n**详细结果文件**: `{result_file.name}`\n")
        
        print(f"Markdown报告已生成: {report_file}")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("开始运行第五章表5.7的完整缓存测试")
        print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"DuckDB路径: {self.duckdb_path}")
        
        try:
            # 第一步：生成数据集
            if not self.generate_datasets():
                print("数据集生成失败，继续进行性能测试...")
            
            # 第二步：运行性能测试
            if not self.run_performance_tests():
                print("性能测试失败，继续进行TPC测试...")
            
            # 第三步：运行TPC测试
            self.run_tpc_tests()
            
            # 第四步：生成报告
            success = self.generate_final_report()
            
            if success:
                print("\n🎉 所有测试成功完成！")
                return True
            else:
                print("\n⚠️ 部分测试失败，请查看详细报告")
                return False
                
        except KeyboardInterrupt:
            print("\n测试被用户中断")
            return False
        except Exception as e:
            print(f"\n测试过程中发生错误: {e}")
            return False

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python run_all_cache_tests.py <duckdb_path>")
        print("Example: python run_all_cache_tests.py ./duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    # 创建测试运行器
    runner = CacheTestRunner(duckdb_path)
    
    # 运行所有测试
    success = runner.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()