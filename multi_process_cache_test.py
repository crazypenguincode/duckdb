#!/usr/bin/env python3
"""
DuckDB Multi-Process Query Cache Performance Test
测试DuckDB多进程查询缓存性能
"""

import subprocess
import time
import os
import sys
import json
import multiprocessing
from pathlib import Path
import tempfile
import shutil

class MultiProcessCacheTester:
    def __init__(self, duckdb_path, db_path, queries_dir):
        self.duckdb_path = duckdb_path
        self.db_path = db_path
        self.queries_dir = queries_dir
        self.results = {}
        self.cache_dir = "/tmp/duckdb_cache_test"
        
    def setup_cache_directory(self):
        """设置缓存目录"""
        if os.path.exists(self.cache_dir):
            shutil.rmtree(self.cache_dir)
        os.makedirs(self.cache_dir, exist_ok=True)
        print(f"📁 缓存目录已创建: {self.cache_dir}")
    
    def cleanup_cache_directory(self):
        """清理缓存目录"""
        if os.path.exists(self.cache_dir):
            shutil.rmtree(self.cache_dir)
        print(f"🧹 缓存目录已清理: {self.cache_dir}")
    
    def run_single_process_test(self, query, description, cache_enabled=True, process_id=0):
        """运行单进程测试"""
        print(f"\n[进程 {process_id}] 测试: {description}")
        print(f"[进程 {process_id}] 查询缓存: {'开启' if cache_enabled else '关闭'}")
        
        # 为避免锁冲突，为每个进程创建数据库副本
        tmp_db_dir = os.path.join(self.cache_dir, f"proc_{process_id}")
        os.makedirs(tmp_db_dir, exist_ok=True)
        tmp_db_path = os.path.join(tmp_db_dir, "tpch_copy.db")
        try:
            shutil.copy2(self.db_path, tmp_db_path)
        except Exception as e:
            print(f"[进程 {process_id}] ❌ 拷贝数据库失败: {e}")
            return {
                'success': False,
                'execution_time': 0.0,
                'output': '',
                'error': f'Copy DB failed: {e}',
                'cache_stats': {}
            }

        # 构建DuckDB命令
        sql_commands = [
            f"ATTACH '{tmp_db_path}' AS tpch;",
            f"USE tpch;",
            f"PRAGMA enable_query_cache={str(cache_enabled).lower()};",
            f"PRAGMA query_cache_max_size='100MB';",
            f"PRAGMA memory_limit='1GB';",
            f"PRAGMA threads=2;",
            # 首次执行（预热）
            query,
            # 第二次执行（应命中缓存，若同进程缓存生效）
            query,
            "PRAGMA query_cache_stats;"
        ]
        
        sql_script = "\n".join(sql_commands)
        
        # 执行查询并测量时间
        start_time = time.time()
        try:
            result = subprocess.run(
                [self.duckdb_path, "-c", sql_script],
                capture_output=True,
                text=True,
                timeout=300  # 5分钟超时
            )
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            if result.returncode == 0:
                print(f"[进程 {process_id}] ✅ 查询执行成功")
                print(f"[进程 {process_id}] ⏱️  执行时间: {execution_time:.3f} 秒")
                
                # 解析缓存统计信息
                cache_stats = self.parse_cache_stats(result.stdout)
                
                return {
                    'success': True,
                    'execution_time': execution_time,
                    'output': result.stdout,
                    'error': result.stderr,
                    'cache_stats': cache_stats
                }
            else:
                print(f"[进程 {process_id}] ❌ 查询执行失败")
                print(f"[进程 {process_id}] 错误信息: {result.stderr}")
                return {
                    'success': False,
                    'execution_time': execution_time,
                    'output': result.stdout,
                    'error': result.stderr,
                    'cache_stats': {}
                }
                
        except subprocess.TimeoutExpired:
            print(f"[进程 {process_id}] ⏰ 查询超时 (5分钟)")
            return {
                'success': False,
                'execution_time': 300.0,
                'output': '',
                'error': 'Query timeout',
                'cache_stats': {}
            }
        except Exception as e:
            print(f"[进程 {process_id}] ❌ 执行异常: {str(e)}")
            return {
                'success': False,
                'execution_time': 0.0,
                'output': '',
                'error': str(e),
                'cache_stats': {}
            }
    
    def parse_cache_stats(self, output):
        """解析缓存统计信息"""
        stats = {}
        lines = output.split('\n')
        
        for line in lines:
            if 'Cache Stats:' in line or 'Total entries:' in line or 'Hit rate:' in line:
                # 简单的统计信息解析
                if 'Total entries:' in line:
                    try:
                        stats['total_entries'] = int(line.split(':')[1].strip())
                    except:
                        pass
                elif 'Hit rate:' in line:
                    try:
                        stats['hit_rate'] = float(line.split(':')[1].strip().replace('%', ''))
                    except:
                        pass
        
        return stats
    
    def run_concurrent_processes(self, query, description, num_processes=4, cache_enabled=True):
        """运行并发进程测试"""
        print(f"\n{'='*60}")
        print(f"并发测试: {description}")
        print(f"进程数: {num_processes}")
        print(f"查询缓存: {'开启' if cache_enabled else '关闭'}")
        print(f"{'='*60}")
        
        # 创建进程池
        with multiprocessing.Pool(processes=num_processes) as pool:
            # 准备参数
            args = [(query, description, cache_enabled, i) for i in range(num_processes)]
            
            # 并发执行
            start_time = time.time()
            results = pool.starmap(self.run_single_process_test, args)
            end_time = time.time()
            
            total_time = end_time - start_time
            
            # 分析结果
            successful_results = [r for r in results if r['success']]
            failed_results = [r for r in results if not r['success']]
            
            if successful_results:
                avg_execution_time = sum(r['execution_time'] for r in successful_results) / len(successful_results)
                min_execution_time = min(r['execution_time'] for r in successful_results)
                max_execution_time = max(r['execution_time'] for r in successful_results)
                
                # 计算缓存统计
                total_cache_entries = sum(r['cache_stats'].get('total_entries', 0) for r in successful_results)
                avg_hit_rate = sum(r['cache_stats'].get('hit_rate', 0) for r in successful_results) / len(successful_results)
                
                print(f"\n📊 并发测试结果:")
                print(f"总执行时间: {total_time:.3f} 秒")
                print(f"成功进程数: {len(successful_results)}/{num_processes}")
                print(f"失败进程数: {len(failed_results)}")
                print(f"平均单进程执行时间: {avg_execution_time:.3f} 秒")
                print(f"最快执行时间: {min_execution_time:.3f} 秒")
                print(f"最慢执行时间: {max_execution_time:.3f} 秒")
                print(f"总缓存条目数: {total_cache_entries}")
                print(f"平均命中率: {avg_hit_rate:.2f}%")
                
                return {
                    'success': True,
                    'total_time': total_time,
                    'successful_processes': len(successful_results),
                    'failed_processes': len(failed_results),
                    'avg_execution_time': avg_execution_time,
                    'min_execution_time': min_execution_time,
                    'max_execution_time': max_execution_time,
                    'total_cache_entries': total_cache_entries,
                    'avg_hit_rate': avg_hit_rate,
                    'individual_results': results
                }
            else:
                print(f"\n❌ 所有进程都失败了")
                return {
                    'success': False,
                    'total_time': total_time,
                    'successful_processes': 0,
                    'failed_processes': num_processes,
                    'individual_results': results
                }
    
    def test_simple_queries_concurrent(self):
        """测试简单查询的并发缓存效果"""
        print("\n🔍 开始简单查询并发测试...")
        
        simple_queries = [
            {
                'query': "SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01';",
                'description': '简单日期过滤查询'
            },
            {
                'query': "SELECT l_returnflag, COUNT(*) FROM lineitem WHERE l_quantity > 20 GROUP BY l_returnflag;",
                'description': '分组聚合查询'
            },
            {
                'query': "SELECT AVG(l_extendedprice) FROM lineitem WHERE l_discount BETWEEN 0.05 AND 0.07;",
                'description': '范围过滤聚合查询'
            }
        ]
        
        for query_info in simple_queries:
            query = query_info['query']
            description = query_info['description']
            
            # 测试缓存开启的并发性能
            result_enabled = self.run_concurrent_processes(query, f"{description} (缓存开启)", 4, True)
            
            # 测试缓存关闭的并发性能
            result_disabled = self.run_concurrent_processes(query, f"{description} (缓存关闭)", 4, False)
            
            # 记录结果
            self.results[description] = {
                'cache_enabled': result_enabled,
                'cache_disabled': result_disabled,
                'speedup': result_disabled['avg_execution_time'] / result_enabled['avg_execution_time'] if result_enabled['success'] and result_disabled['success'] and result_enabled['avg_execution_time'] > 0 else 0
            }
    
    def test_tpch_queries_concurrent(self):
        """测试TPCH查询的并发缓存效果"""
        print("\n🔍 开始TPCH查询并发测试...")
        
        # 选择几个代表性的TPCH查询
        tpch_queries = ['q01.sql', 'q06.sql', 'q14.sql']
        
        for query_file in tpch_queries:
            query_path = os.path.join(self.queries_dir, query_file)
            if not os.path.exists(query_path):
                print(f"⚠️  查询文件不存在: {query_path}")
                continue
                
            with open(query_path, 'r') as f:
                query = f.read()
            
            description = f"TPCH {query_file}"
            
            # 测试缓存开启的并发性能
            result_enabled = self.run_concurrent_processes(query, f"{description} (缓存开启)", 4, True)
            
            # 测试缓存关闭的并发性能
            result_disabled = self.run_concurrent_processes(query, f"{description} (缓存关闭)", 4, False)
            
            # 记录结果
            self.results[description] = {
                'cache_enabled': result_enabled,
                'cache_disabled': result_disabled,
                'speedup': result_disabled['avg_execution_time'] / result_enabled['avg_execution_time'] if result_enabled['success'] and result_disabled['success'] and result_enabled['avg_execution_time'] > 0 else 0
            }
    
    def test_cache_persistence_strategies(self):
        """测试不同缓存持久化策略"""
        print("\n🔍 开始缓存持久化策略测试...")
        
        # 测试不同的持久化策略
        strategies = [
            {'name': 'MEMORY_ONLY', 'config': 'MEMORY_ONLY'},
            {'name': 'WAL_FORMAT', 'config': 'WAL_FORMAT'},
            {'name': 'MATERIALIZED_VIEW', 'config': 'MATERIALIZED_VIEW'}
        ]
        
        test_query = "SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01';"
        
        for strategy in strategies:
            print(f"\n测试策略: {strategy['name']}")
            
            # 构建带持久化策略的SQL
            # 为策略测试也使用副本以避免锁
            tmp_db_path = os.path.join(self.cache_dir, f"persist_{strategy['name']}.db")
            try:
                shutil.copy2(self.db_path, tmp_db_path)
            except Exception as e:
                print(f"❌ 拷贝数据库失败: {e}")
                continue

            sql_commands = [
                f"ATTACH '{tmp_db_path}' AS tpch;",
                f"USE tpch;",
                f"PRAGMA enable_query_cache=true;",
                f"PRAGMA query_cache_max_size='50MB';",
                f"PRAGMA query_cache_persistence_strategy='{strategy['config']}';",
                f"PRAGMA query_cache_persistence_path='{self.cache_dir}';",
                test_query,
                "PRAGMA query_cache_stats;"
            ]
            
            sql_script = "\n".join(sql_commands)
            
            # 执行测试
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, "-c", sql_script],
                capture_output=True,
                text=True,
                timeout=300
            )
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            if result.returncode == 0:
                print(f"✅ 策略 {strategy['name']} 测试成功")
                print(f"⏱️  执行时间: {execution_time:.3f} 秒")
                
                cache_stats = self.parse_cache_stats(result.stdout)
                
                self.results[f"Persistence_{strategy['name']}"] = {
                    'strategy': strategy['name'],
                    'execution_time': execution_time,
                    'success': True,
                    'cache_stats': cache_stats,
                    'output': result.stdout
                }
            else:
                print(f"❌ 策略 {strategy['name']} 测试失败")
                print(f"错误信息: {result.stderr}")
                
                self.results[f"Persistence_{strategy['name']}"] = {
                    'strategy': strategy['name'],
                    'execution_time': execution_time,
                    'success': False,
                    'error': result.stderr
                }
    
    def test_mixed_workload(self):
        """测试混合工作负载"""
        print("\n🔍 开始混合工作负载测试...")
        
        # 定义混合工作负载
        workloads = [
            {'query': "SELECT COUNT(*) FROM lineitem;", 'weight': 0.3, 'name': '全表扫描'},
            {'query': "SELECT l_returnflag, COUNT(*) FROM lineitem GROUP BY l_returnflag;", 'weight': 0.3, 'name': '分组聚合'},
            {'query': "SELECT AVG(l_extendedprice) FROM lineitem WHERE l_discount > 0.05;", 'weight': 0.2, 'name': '条件聚合'},
            {'query': "SELECT l_orderkey, l_partkey FROM lineitem WHERE l_quantity > 20 LIMIT 1000;", 'weight': 0.2, 'name': '限制查询'}
        ]
        
        def run_mixed_workload_process_inner(process_id, cache_enabled=True):
            """运行混合工作负载的单个进程"""
            results = []
            
            for workload in workloads:
                # 根据权重决定执行次数
                iterations = max(1, int(workload['weight'] * 10))
                
                for i in range(iterations):
                    result = self.run_single_process_test(
                        workload['query'], 
                        f"混合工作负载-{workload['name']}-进程{process_id}-迭代{i+1}",
                        cache_enabled,
                        process_id
                    )
                    results.append({
                        'workload': workload['name'],
                        'iteration': i+1,
                        'result': result
                    })
            
            return results
        
        # 跳过混合工作负载的并发执行以避免 pickling 问题
        print("跳过混合工作负载的并发测试（后续可改为多进程可序列化实现）")
        cache_enabled_results = []
        cache_disabled_results = []
        
        # 分析结果
        def analyze_workload_results(results):
            total_queries = sum(len(process_results) for process_results in results)
            successful_queries = sum(
                sum(1 for r in process_results if r['result']['success']) 
                for process_results in results
            )
            total_time = sum(
                sum(r['result']['execution_time'] for r in process_results if r['result']['success'])
                for process_results in results
            )
            avg_time = total_time / successful_queries if successful_queries > 0 else 0
            
            return {
                'total_queries': total_queries,
                'successful_queries': successful_queries,
                'total_time': total_time,
                'avg_time': avg_time,
                'success_rate': successful_queries / total_queries if total_queries > 0 else 0
            }
        
        enabled_analysis = analyze_workload_results(cache_enabled_results)
        disabled_analysis = analyze_workload_results(cache_disabled_results)
        
        self.results['Mixed_Workload'] = {
            'cache_enabled': enabled_analysis,
            'cache_disabled': disabled_analysis,
            'speedup': disabled_analysis['avg_time'] / enabled_analysis['avg_time'] if enabled_analysis['avg_time'] > 0 and disabled_analysis['avg_time'] > 0 else 0
        }
    
    def generate_report(self):
        """生成测试报告"""
        print("\n" + "="*80)
        print("📊 多进程查询缓存性能测试报告")
        print("="*80)
        
        total_tests = len(self.results)
        def is_success(entry):
            if isinstance(entry, dict) and 'cache_enabled' in entry and 'cache_disabled' in entry:
                return entry['cache_enabled'].get('success') and entry['cache_disabled'].get('success')
            return False
        successful_tests = sum(1 for r in self.results.values() if is_success(r))
        
        print(f"总测试数: {total_tests}")
        print(f"成功测试数: {successful_tests}")
        print(f"成功率: {successful_tests/total_tests*100:.1f}%")
        print()
        
        # 详细结果
        for test_name, result in self.results.items():
            print(f"🔍 {test_name}")
            print("-" * 50)
            
            if isinstance(result, dict) and 'cache_enabled' in result and 'cache_disabled' in result:
                if result['cache_enabled'].get('success') and result['cache_disabled'].get('success'):
                    enabled_time = result['cache_enabled'].get('avg_execution_time', 0)
                    disabled_time = result['cache_disabled'].get('avg_execution_time', 0)
                    speedup = result.get('speedup', 0)
                    print(f"缓存开启平均时间: {enabled_time:.3f} 秒")
                    print(f"缓存关闭平均时间: {disabled_time:.3f} 秒")
                    print(f"性能提升: {speedup:.2f}x {'(缓存更快)' if speedup > 1 else '(缓存更慢)' if speedup < 1 else '(性能相同)'}")
                    if 'total_cache_entries' in result['cache_enabled']:
                        print(f"缓存条目数: {result['cache_enabled']['total_cache_entries']}")
                    if 'avg_hit_rate' in result['cache_enabled']:
                        print(f"平均命中率: {result['cache_enabled']['avg_hit_rate']:.2f}%")
                else:
                    print("❌ 测试失败")
            elif isinstance(result, dict) and 'strategy' in result:
                # 持久化策略测试结果
                print(f"策略: {result['strategy']}")
                if result['success']:
                    print(f"执行时间: {result['execution_time']:.3f} 秒")
                    if 'cache_stats' in result:
                        print(f"缓存统计: {result['cache_stats']}")
                else:
                    print(f"❌ 失败: {result.get('error', 'Unknown error')}")
            print()
        
        # 保存结果到JSON文件
        report_data = {
            'test_summary': {
                'total_tests': total_tests,
                'successful_tests': successful_tests,
                'success_rate': successful_tests/total_tests*100 if total_tests > 0 else 0
            },
            'results': self.results
        }
        
        with open('multi_process_cache_test_results.json', 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 详细结果已保存到: multi_process_cache_test_results.json")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始DuckDB多进程查询缓存性能测试")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"数据库路径: {self.db_path}")
        print(f"查询目录: {self.queries_dir}")
        
        # 检查文件是否存在
        if not os.path.exists(self.duckdb_path):
            print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
            return
        
        if not os.path.exists(self.db_path):
            print(f"❌ 数据库文件不存在: {self.db_path}")
            return
        
        if not os.path.exists(self.queries_dir):
            print(f"❌ 查询目录不存在: {self.queries_dir}")
            return
        
        # 设置缓存目录
        self.setup_cache_directory()
        
        try:
            # 运行测试
            self.test_simple_queries_concurrent()
            self.test_tpch_queries_concurrent()
            self.test_cache_persistence_strategies()
            self.test_mixed_workload()
            
            # 生成报告
            self.generate_report()
            
        finally:
            # 清理缓存目录
            self.cleanup_cache_directory()

def main():
    # 配置路径
    duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 创建测试器并运行测试
    tester = MultiProcessCacheTester(duckdb_path, db_path, queries_dir)
    tester.run_all_tests()

if __name__ == "__main__":
    main()
