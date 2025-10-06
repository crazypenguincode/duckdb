#!/usr/bin/env python3
"""
TPC-H 缓存性能快速测试脚本
测试前5个TPC-H查询在有无缓存情况下的性能对比
用于快速验证和调试
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime
from pathlib import Path
from typing import Dict, List

class TPCHQuickCacheTest:
    def __init__(self):
        self.duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
        self.tpch_db_path = "/Users/max/test/tpc/tpch-sf1.db"
        self.queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
        self.results_dir = Path("part5_test/tpch_cache_results")
        self.results_dir.mkdir(exist_ok=True)
        
        # 快速测试配置 - 只测试前5个查询
        self.test_iterations = [1, 3]  # 测试1次和3次重复
        self.max_queries = 5  # 只测试前5个查询
        self.queries = self.load_tpch_queries()
        
        # 结果存储
        self.results = {
            'test_info': {
                'timestamp': datetime.now().isoformat(),
                'duckdb_path': self.duckdb_path,
                'database': self.tpch_db_path,
                'total_queries': len(self.queries),
                'test_iterations': self.test_iterations,
                'test_type': 'quick_test'
            },
            'performance_data': {}
        }
    
    def load_tpch_queries(self) -> List[Dict]:
        """加载前N个TPC-H查询进行快速测试"""
        queries = []
        
        if not os.path.exists(self.queries_dir):
            print(f"❌ TPC-H查询目录不存在: {self.queries_dir}")
            return queries
        
        for i in range(1, min(self.max_queries + 1, 23)):  # 限制查询数量
            query_file = f"q{i:02d}.sql"
            query_path = os.path.join(self.queries_dir, query_file)
            
            if os.path.exists(query_path):
                try:
                    with open(query_path, 'r', encoding='utf-8') as f:
                        sql_content = f.read().strip()
                        
                    # 移除末尾分号
                    if sql_content.endswith(';'):
                        sql_content = sql_content[:-1]
                    
                    queries.append({
                        'id': f"Q{i:02d}",
                        'name': f"TPC-H Query {i}",
                        'file': query_file,
                        'sql': sql_content,
                        'complexity': self.estimate_query_complexity(sql_content)
                    })
                    
                except Exception as e:
                    print(f"⚠️ 读取查询文件失败 {query_path}: {e}")
                    continue
            else:
                print(f"⚠️ 查询文件不存在: {query_path}")
        
        print(f"✅ 成功加载 {len(queries)} 个TPC-H查询 (快速测试)")
        return queries
    
    def estimate_query_complexity(self, sql: str) -> str:
        """估算查询复杂度"""
        sql_lower = sql.lower()
        complexity_score = 0
        
        # 基于关键词计算复杂度
        complexity_score += sql_lower.count('join') * 2
        complexity_score += sql_lower.count('group by')
        complexity_score += sql_lower.count('order by')
        complexity_score += sql_lower.count('having')
        complexity_score += sql_lower.count('union') * 2
        complexity_score += sql_lower.count('with') * 2
        complexity_score += sql_lower.count('window') * 3
        complexity_score += sql_lower.count('over(') * 3
        complexity_score += sql_lower.count('exists') * 2
        complexity_score += sql_lower.count('in (select') * 2
        
        if complexity_score <= 2:
            return 'simple'
        elif complexity_score <= 6:
            return 'medium'
        elif complexity_score <= 12:
            return 'complex'
        else:
            return 'very_complex'
    
    def execute_query_with_timing(self, query: Dict, enable_cache: bool, iterations: int = 1) -> Dict:
        """执行查询并记录时间"""
        cache_setting = "true" if enable_cache else "false"
        
        print(f"  📊 执行 {query['id']} ({iterations}次, 缓存: {enable_cache})")
        
        # 构建SQL脚本
        sql_commands = [
            f"ATTACH '{self.tpch_db_path}' AS tpch;",
            "USE tpch;",
            f"SET enable_query_cache = {cache_setting};",
        ]
        
        # 添加重复查询
        for i in range(iterations):
            sql_commands.append(f"-- Iteration {i+1}")
            sql_commands.append(query['sql'] + ";")
        
        complete_sql = "\n".join(sql_commands)
        
        # 执行查询并测量时间
        start_time = time.time()
        
        try:
            process = subprocess.run(
                [self.duckdb_path],
                input=complete_sql,
                text=True,
                capture_output=True,
                timeout=120  # 2分钟超时（快速测试）
            )
            
            end_time = time.time()
            execution_time = end_time - start_time
            
            if process.returncode != 0:
                print(f"    ❌ 查询执行失败: {process.stderr[:200]}")
                return {
                    'success': False,
                    'error': process.stderr,
                    'execution_time': None
                }
            
            print(f"    ✅ 执行成功，耗时: {execution_time:.3f}秒")
            
            return {
                'success': True,
                'execution_time': execution_time,
                'iterations': iterations,
                'avg_time_per_iteration': execution_time / iterations,
                'cache_enabled': enable_cache
            }
            
        except subprocess.TimeoutExpired:
            print(f"    ⏰ 查询执行超时 (>120秒)")
            return {
                'success': False,
                'error': 'Timeout after 120 seconds',
                'execution_time': None
            }
        except Exception as e:
            print(f"    ❌ 执行异常: {e}")
            return {
                'success': False,
                'error': str(e),
                'execution_time': None
            }
    
    def run_quick_test(self):
        """运行快速测试"""
        print("🚀 开始TPC-H缓存性能快速测试...")
        print(f"📊 测试配置:")
        print(f"   - 数据库: {self.tpch_db_path}")
        print(f"   - 查询数量: {len(self.queries)} (前{self.max_queries}个查询)")
        print(f"   - 测试迭代: {self.test_iterations}")
        print(f"   - DuckDB路径: {self.duckdb_path}")
        
        # 基本验证
        if not os.path.exists(self.tpch_db_path):
            print(f"❌ TPC-H数据库文件不存在: {self.tpch_db_path}")
            return
        
        if not os.path.exists(self.duckdb_path):
            print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
            return
        
        total_tests = len(self.queries) * len(self.test_iterations) * 2
        current_test = 0
        
        for query in self.queries:
            print(f"\n🔍 测试查询: {query['id']} - {query['name']}")
            print(f"   复杂度: {query['complexity']}")
            
            query_results = {
                'query_info': {
                    'id': query['id'],
                    'name': query['name'],
                    'file': query['file'],
                    'complexity': query['complexity']
                },
                'test_results': {}
            }
            
            for iterations in self.test_iterations:
                print(f"\n  📈 测试 {iterations} 次迭代:")
                
                iteration_results = {}
                
                # 测试无缓存情况
                current_test += 1
                print(f"    进度: {current_test}/{total_tests}")
                no_cache_result = self.execute_query_with_timing(query, False, iterations)
                iteration_results['without_cache'] = no_cache_result
                
                # 测试有缓存情况
                current_test += 1
                print(f"    进度: {current_test}/{total_tests}")
                with_cache_result = self.execute_query_with_timing(query, True, iterations)
                iteration_results['with_cache'] = with_cache_result
                
                # 计算性能提升
                if (no_cache_result['success'] and with_cache_result['success'] and 
                    no_cache_result['execution_time'] and with_cache_result['execution_time']):
                    
                    speedup = no_cache_result['execution_time'] / with_cache_result['execution_time']
                    time_saved = no_cache_result['execution_time'] - with_cache_result['execution_time']
                    
                    iteration_results['performance_metrics'] = {
                        'speedup_ratio': speedup,
                        'time_saved_seconds': time_saved,
                        'cache_efficiency': (time_saved / no_cache_result['execution_time']) * 100
                    }
                    
                    print(f"    📊 性能提升: {speedup:.2f}x, 节省时间: {time_saved:.3f}秒")
                
                query_results['test_results'][f'{iterations}_iterations'] = iteration_results
            
            self.results['performance_data'][query['id']] = query_results
        
        # 生成汇总统计
        self.generate_summary_statistics()
        
        # 保存结果
        self.save_results()
        
        # 生成简化报告
        self.generate_quick_report()
        
        print("\n✅ TPC-H缓存性能快速测试完成!")
        print(f"📁 结果保存在: {self.results_dir}")
    
    def generate_summary_statistics(self):
        """生成汇总统计"""
        print("\n📊 生成汇总统计...")
        
        summary = {
            'overall_statistics': {},
            'by_complexity': {},
            'by_iterations': {}
        }
        
        for iterations in self.test_iterations:
            speedups = []
            time_savings = []
            successful_tests = 0
            failed_tests = 0
            
            for query_id, query_data in self.results['performance_data'].items():
                iteration_key = f'{iterations}_iterations'
                if iteration_key in query_data['test_results']:
                    test_result = query_data['test_results'][iteration_key]
                    
                    if 'performance_metrics' in test_result:
                        speedups.append(test_result['performance_metrics']['speedup_ratio'])
                        time_savings.append(test_result['performance_metrics']['time_saved_seconds'])
                        successful_tests += 1
                    else:
                        failed_tests += 1
            
            if speedups:
                iteration_summary = {
                    'successful_tests': successful_tests,
                    'failed_tests': failed_tests,
                    'avg_speedup': statistics.mean(speedups),
                    'median_speedup': statistics.median(speedups),
                    'max_speedup': max(speedups),
                    'min_speedup': min(speedups),
                    'avg_time_saved': statistics.mean(time_savings),
                    'total_time_saved': sum(time_savings)
                }
                
                summary['by_iterations'][f'{iterations}_iterations'] = iteration_summary
        
        self.results['summary_statistics'] = summary
    
    def save_results(self):
        """保存测试结果"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 保存完整结果
        results_file = self.results_dir / f"tpch_quick_test_{timestamp}.json"
        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"📄 快速测试结果保存至: {results_file}")
    
    def generate_quick_report(self):
        """生成快速测试报告"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = self.results_dir / f"tpch_quick_report_{timestamp}.md"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# TPC-H 缓存性能快速测试报告\n\n")
            f.write(f"**测试时间**: {self.results['test_info']['timestamp']}\n\n")
            f.write(f"**测试配置** (快速测试):\n")
            f.write(f"- 数据库: {self.results['test_info']['database']}\n")
            f.write(f"- 查询数量: {self.results['test_info']['total_queries']} (前{self.max_queries}个查询)\n")
            f.write(f"- 测试迭代: {self.results['test_info']['test_iterations']}\n\n")
            
            # 汇总统计
            if 'summary_statistics' in self.results:
                f.write("## 快速测试汇总\n\n")
                
                for iterations_key, stats in self.results['summary_statistics']['by_iterations'].items():
                    iterations = iterations_key.replace('_iterations', '')
                    f.write(f"### {iterations} 次迭代结果\n\n")
                    f.write(f"- 成功测试: {stats['successful_tests']}\n")
                    f.write(f"- 失败测试: {stats['failed_tests']}\n")
                    f.write(f"- 平均加速比: {stats['avg_speedup']:.3f}x\n")
                    f.write(f"- 中位数加速比: {stats['median_speedup']:.3f}x\n")
                    f.write(f"- 最大加速比: {stats['max_speedup']:.3f}x\n")
                    f.write(f"- 平均节省时间: {stats['avg_time_saved']:.3f}秒\n\n")
            
            # 详细结果表格
            f.write("## 详细测试结果\n\n")
            f.write("| 查询ID | 复杂度 | 迭代次数 | 无缓存时间(s) | 有缓存时间(s) | 加速比 | 节省时间(s) |\n")
            f.write("|--------|--------|----------|---------------|---------------|--------|-------------|\n")
            
            for query_id, query_data in self.results['performance_data'].items():
                query_info = query_data['query_info']
                
                for iterations in self.test_iterations:
                    iteration_key = f'{iterations}_iterations'
                    if iteration_key in query_data['test_results']:
                        test_result = query_data['test_results'][iteration_key]
                        
                        without_cache_time = test_result.get('without_cache', {}).get('execution_time')
                        with_cache_time = test_result.get('with_cache', {}).get('execution_time')
                        
                        if without_cache_time and with_cache_time and 'performance_metrics' in test_result:
                            metrics = test_result['performance_metrics']
                            f.write(f"| {query_id} | {query_info['complexity']} | {iterations} | "
                                   f"{without_cache_time:.3f} | {with_cache_time:.3f} | "
                                   f"{metrics['speedup_ratio']:.3f}x | {metrics['time_saved_seconds']:.3f} |\n")
                        else:
                            f.write(f"| {query_id} | {query_info['complexity']} | {iterations} | "
                                   f"N/A | N/A | N/A | N/A |\n")
            
            f.write("\n---\n")
            f.write("*这是一个快速测试，只包含前5个TPC-H查询。如需完整测试，请运行完整版测试脚本。*\n")
        
        print(f"📋 快速测试报告保存至: {report_file}")

def main():
    """主函数"""
    print("🎯 TPC-H 缓存性能快速测试工具")
    print("=" * 50)
    
    # 创建测试实例
    test = TPCHQuickCacheTest()
    
    # 运行快速测试
    try:
        test.run_quick_test()
        print("\n🎉 快速测试完成!")
        print(f"📁 结果文件位置: {test.results_dir}")
        print("\n💡 提示:")
        print("   - 这是快速测试版本，只测试前5个查询")
        print("   - 如需完整测试，请运行 tpch_cache_performance_test.py")
        
    except KeyboardInterrupt:
        print("\n⚠️ 用户中断测试")
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()