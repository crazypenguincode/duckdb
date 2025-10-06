#!/usr/bin/env python3
"""
TPC-H 缓存性能综合测试脚本
测试所有22个TPC-H查询在有无缓存情况下的性能对比
生成详细的性能报告和Mermaid可视化图表
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime
import traceback

class TPCHCacheTest:
    def __init__(self):
        self.duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
        self.db_path = "/Users/max/test/tpc/tpch-sf1.db"
        self.queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
        self.results = []
        self.test_start_time = datetime.now()
        
    def check_environment(self):
        """检查测试环境"""
        print("🔍 检查测试环境...")
        
        checks = [
            (self.duckdb_exe, "DuckDB可执行文件"),
            (self.db_path, "TPC-H数据库文件"),
            (self.queries_dir, "TPC-H查询目录")
        ]
        
        for path, name in checks:
            if os.path.exists(path):
                print(f"  ✅ {name}: {path}")
            else:
                print(f"  ❌ {name}不存在: {path}")
                return False
        
        # 检查查询文件
        query_files = []
        for i in range(1, 23):
            query_file = os.path.join(self.queries_dir, f"q{i:02d}.sql")
            if os.path.exists(query_file):
                query_files.append(query_file)
        
        print(f"  📁 找到 {len(query_files)}/22 个TPC-H查询文件")
        
        if len(query_files) < 22:
            print("  ⚠️  部分查询文件缺失，将测试现有文件")
        
        return True
    
    def run_query(self, query_file, enable_cache=True, timeout=300):
        """执行单个查询并返回执行时间"""
        try:
            cache_setting = "SET enable_query_cache=true;" if enable_cache else "SET enable_query_cache=false;"
            
            with open(query_file, 'r') as f:
                query_content = f.read()
            
            # 添加缓存清理命令（对于无缓存测试）
            if not enable_cache:
                full_query = f"PRAGMA disable_optimizer;\n{cache_setting}\n{query_content}"
            else:
                full_query = f"{cache_setting}\n{query_content}"
            
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_exe, self.db_path],
                input=full_query,
                text=True,
                capture_output=True,
                timeout=timeout
            )
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            if result.returncode != 0:
                print(f"    ❌ 查询执行失败: {result.stderr[:200]}...")
                return None
                
            return execution_time
            
        except subprocess.TimeoutExpired:
            print(f"    ⏰ 查询超时 ({timeout}s)")
            return None
        except Exception as e:
            print(f"    ❌ 执行错误: {str(e)[:100]}...")
            return None
    
    def test_single_query(self, query_file, runs=3):
        """测试单个查询的性能"""
        query_name = os.path.basename(query_file).replace('.sql', '')
        print(f"\n📊 测试查询: {query_name}")
        
        # 测试无缓存情况
        print("  🔄 测试无缓存...")
        no_cache_times = []
        for i in range(runs):
            exec_time = self.run_query(query_file, enable_cache=False)
            if exec_time is not None:
                no_cache_times.append(exec_time)
                print(f"    运行 {i+1}: {exec_time:.3f}s")
            else:
                print(f"    运行 {i+1}: 失败")
        
        # 测试有缓存情况
        print("  ⚡ 测试有缓存...")
        cache_times = []
        for i in range(runs):
            exec_time = self.run_query(query_file, enable_cache=True)
            if exec_time is not None:
                cache_times.append(exec_time)
                print(f"    运行 {i+1}: {exec_time:.3f}s")
            else:
                print(f"    运行 {i+1}: 失败")
        
        # 计算统计信息
        result = {
            'query': query_name,
            'query_file': query_file,
            'no_cache': {
                'times': no_cache_times,
                'avg': statistics.mean(no_cache_times) if no_cache_times else 0,
                'min': min(no_cache_times) if no_cache_times else 0,
                'max': max(no_cache_times) if no_cache_times else 0,
                'std': statistics.stdev(no_cache_times) if len(no_cache_times) > 1 else 0
            },
            'cache': {
                'times': cache_times,
                'avg': statistics.mean(cache_times) if cache_times else 0,
                'min': min(cache_times) if cache_times else 0,
                'max': max(cache_times) if cache_times else 0,
                'std': statistics.stdev(cache_times) if len(cache_times) > 1 else 0
            },
            'success_rate': {
                'no_cache': len(no_cache_times) / runs * 100,
                'cache': len(cache_times) / runs * 100
            }
        }
        
        # 计算性能提升
        if result['no_cache']['avg'] > 0 and result['cache']['avg'] > 0:
            result['speedup'] = result['no_cache']['avg'] / result['cache']['avg']
            result['improvement'] = (result['no_cache']['avg'] - result['cache']['avg']) / result['no_cache']['avg'] * 100
        else:
            result['speedup'] = 0
            result['improvement'] = 0
        
        print(f"  📈 结果:")
        print(f"    无缓存平均: {result['no_cache']['avg']:.3f}s (±{result['no_cache']['std']:.3f})")
        print(f"    有缓存平均: {result['cache']['avg']:.3f}s (±{result['cache']['std']:.3f})")
        print(f"    性能提升: {result['improvement']:.1f}%")
        print(f"    加速比: {result['speedup']:.2f}x")
        
        return result
    
    def run_comprehensive_test(self, test_queries=None, runs_per_query=3):
        """运行综合测试"""
        print("🚀 开始TPC-H缓存性能综合测试")
        print(f"📅 测试时间: {self.test_start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"🔄 每个查询运行次数: {runs_per_query}")
        
        if not self.check_environment():
            print("❌ 环境检查失败，退出测试")
            return False
        
        # 获取要测试的查询文件
        if test_queries is None:
            query_files = []
            for i in range(1, 23):
                query_file = os.path.join(self.queries_dir, f"q{i:02d}.sql")
                if os.path.exists(query_file):
                    query_files.append(query_file)
        else:
            query_files = test_queries
        
        print(f"\n📋 将测试 {len(query_files)} 个查询")
        
        # 执行测试
        for i, query_file in enumerate(query_files, 1):
            print(f"\n{'='*60}")
            print(f"进度: {i}/{len(query_files)}")
            
            try:
                result = self.test_single_query(query_file, runs=runs_per_query)
                if result:
                    self.results.append(result)
            except Exception as e:
                print(f"❌ 测试 {os.path.basename(query_file)} 时出错: {e}")
                traceback.print_exc()
        
        print(f"\n{'='*60}")
        print(f"✅ 测试完成! 成功测试了 {len(self.results)} 个查询")
        
        return True
    
    def generate_summary_report(self):
        """生成测试摘要报告"""
        if not self.results:
            return "没有测试结果可用于生成报告"
        
        # 计算总体统计
        successful_results = [r for r in self.results if r['no_cache']['avg'] > 0 and r['cache']['avg'] > 0]
        
        if not successful_results:
            return "没有成功的测试结果"
        
        avg_improvement = statistics.mean([r['improvement'] for r in successful_results])
        avg_speedup = statistics.mean([r['speedup'] for r in successful_results])
        
        best_query = max(successful_results, key=lambda x: x['improvement'])
        worst_query = min(successful_results, key=lambda x: x['improvement'])
        
        total_no_cache_time = sum([r['no_cache']['avg'] for r in successful_results])
        total_cache_time = sum([r['cache']['avg'] for r in successful_results])
        
        report = f"""
# TPC-H 缓存性能测试报告

## 测试概览
- 测试时间: {self.test_start_time.strftime('%Y-%m-%d %H:%M:%S')}
- 测试查询数: {len(self.results)}
- 成功查询数: {len(successful_results)}
- 测试环境: DuckDB with TPC-H SF=1

## 总体性能
- 平均性能提升: {avg_improvement:.1f}%
- 平均加速比: {avg_speedup:.2f}x
- 总执行时间（无缓存）: {total_no_cache_time:.2f}s
- 总执行时间（有缓存）: {total_cache_time:.2f}s
- 总体时间节省: {total_no_cache_time - total_cache_time:.2f}s

## 最佳/最差性能
- 最佳提升: {best_query['query']} ({best_query['improvement']:.1f}%)
- 最差提升: {worst_query['query']} ({worst_query['improvement']:.1f}%)

## 详细结果
"""
        
        for result in successful_results:
            report += f"""
### {result['query']}
- 无缓存: {result['no_cache']['avg']:.3f}s (±{result['no_cache']['std']:.3f})
- 有缓存: {result['cache']['avg']:.3f}s (±{result['cache']['std']:.3f})
- 性能提升: {result['improvement']:.1f}%
- 加速比: {result['speedup']:.2f}x
"""
        
        return report
    
    def generate_mermaid_charts(self):
        """生成Mermaid图表"""
        successful_results = [r for r in self.results if r['no_cache']['avg'] > 0 and r['cache']['avg'] > 0]
        
        if not successful_results:
            return "没有成功的测试结果可用于生成图表"
        
        # 按查询名称排序
        successful_results.sort(key=lambda x: x['query'])
        
        queries = [r['query'] for r in successful_results]
        no_cache_times = [r['no_cache']['avg'] for r in successful_results]
        cache_times = [r['cache']['avg'] for r in successful_results]
        improvements = [r['improvement'] for r in successful_results]
        
        # 执行时间对比柱状图
        max_time = max(max(no_cache_times), max(cache_times))
        
        bar_chart = f"""```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "执行时间(秒)" 0 --> {max_time * 1.1:.1f}
    bar [无缓存] [{', '.join([f'{t:.3f}' for t in no_cache_times])}]
    bar [有缓存] [{', '.join([f'{t:.3f}' for t in cache_times])}]
```"""
        
        # 性能提升折线图
        line_chart = f"""```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "性能提升(%)" 0 --> {max(improvements) * 1.1:.0f}
    line [性能提升] [{', '.join([f'{imp:.1f}' for imp in improvements])}]
```"""
        
        # 加速比柱状图
        speedups = [r['speedup'] for r in successful_results]
        speedup_chart = f"""```mermaid
xychart-beta
    title "TPC-H查询缓存加速比"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "加速比" 1 --> {max(speedups) * 1.1:.1f}
    bar [加速比] [{', '.join([f'{s:.2f}' for s in speedups])}]
```"""
        
        return f"""
# TPC-H 缓存性能测试可视化

## 执行时间对比
{bar_chart}

## 性能提升百分比
{line_chart}

## 加速比对比
{speedup_chart}
"""
    
    def save_results(self):
        """保存测试结果"""
        timestamp = self.test_start_time.strftime('%Y%m%d_%H%M%S')
        
        # 保存JSON结果
        json_file = f"tpch_cache_test_results_{timestamp}.json"
        test_data = {
            'timestamp': self.test_start_time.isoformat(),
            'duration': str(datetime.now() - self.test_start_time),
            'total_queries': len(self.results),
            'successful_queries': len([r for r in self.results if r['no_cache']['avg'] > 0]),
            'environment': {
                'duckdb_exe': self.duckdb_exe,
                'database': self.db_path,
                'queries_dir': self.queries_dir
            },
            'results': self.results
        }
        
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(test_data, f, indent=2, ensure_ascii=False)
        
        # 保存报告
        report_file = f"tpch_cache_test_report_{timestamp}.md"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(self.generate_summary_report())
            f.write("\n\n")
            f.write(self.generate_mermaid_charts())
        
        print(f"\n📄 结果已保存:")
        print(f"  📊 JSON数据: {json_file}")
        print(f"  📋 测试报告: {report_file}")
        
        return json_file, report_file

def main():
    """主函数"""
    print("TPC-H 缓存性能综合测试")
    print("=" * 50)
    
    # 创建测试实例
    test = TPCHCacheTest()
    
    # 可以选择测试部分查询（用于快速测试）
    # test_queries = [os.path.join(test.queries_dir, f"q{i:02d}.sql") for i in range(1, 6)]
    test_queries = None  # 测试所有查询
    
    # 运行测试
    if test.run_comprehensive_test(test_queries=test_queries, runs_per_query=2):
        # 保存结果
        test.save_results()
        
        # 打印摘要
        print("\n" + "=" * 50)
        print("📊 测试摘要:")
        successful_results = [r for r in test.results if r['no_cache']['avg'] > 0 and r['cache']['avg'] > 0]
        if successful_results:
            avg_improvement = statistics.mean([r['improvement'] for r in successful_results])
            print(f"  平均性能提升: {avg_improvement:.1f}%")
            print(f"  成功测试查询: {len(successful_results)}/{len(test.results)}")
            
            best_query = max(successful_results, key=lambda x: x['improvement'])
            print(f"  最佳提升: {best_query['query']} ({best_query['improvement']:.1f}%)")
        else:
            print("  没有成功的测试结果")
    else:
        print("❌ 测试失败")

if __name__ == "__main__":
    main()