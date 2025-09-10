#!/usr/bin/env python3
"""
DuckDB Bloom Filter Performance Test
测试DuckDB布隆过滤器的开启和关闭性能对比
"""

import subprocess
import time
import os
import sys
import json
from pathlib import Path

class BloomFilterTester:
    def __init__(self, duckdb_path, db_path, queries_dir):
        self.duckdb_path = duckdb_path
        self.db_path = db_path
        self.queries_dir = queries_dir
        self.results = {}
        
    def run_query_with_timing(self, query, description):
        """运行查询并记录执行时间"""
        print(f"\n{'='*60}")
        print(f"测试: {description}")
        
        print(f"{'='*60}")
        
        # 构建DuckDB命令
        sql_commands = [
            f"ATTACH '{self.db_path}' AS tpch;",
            f"USE tpch;",
            f"PRAGMA memory_limit='1GB';",
            f"PRAGMA threads=4;",
            query
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
                print(f"✅ 查询执行成功")
                print(f"⏱️  执行时间: {execution_time:.3f} 秒")
                return {
                    'success': True,
                    'execution_time': execution_time,
                    'output': result.stdout,
                    'error': result.stderr
                }
            else:
                print(f"❌ 查询执行失败")
                print(f"错误信息: {result.stderr}")
                return {
                    'success': False,
                    'execution_time': execution_time,
                    'output': result.stdout,
                    'error': result.stderr
                }
                
        except subprocess.TimeoutExpired:
            print(f"⏰ 查询超时 (5分钟)")
            return {
                'success': False,
                'execution_time': 300.0,
                'output': '',
                'error': 'Query timeout'
            }
        except Exception as e:
            print(f"❌ 执行异常: {str(e)}")
            return {
                'success': False,
                'execution_time': 0.0,
                'output': '',
                'error': str(e)
            }
    
    def test_simple_queries(self):
        """测试简单查询的布隆过滤器效果"""
        print("\n🔍 开始简单查询测试...")
        
        simple_queries = [
            # 使用表进行基线测试（不涉及布隆过滤器开关）
            {
                'query': "SELECT COUNT(*) FROM lineitem WHERE l_shipdate >= '1994-01-01';",
                'description': '表上简单日期过滤查询(基线)'
            },
            {
                'query': "SELECT l_returnflag, COUNT(*) FROM lineitem WHERE l_quantity > 20 GROUP BY l_returnflag;",
                'description': '表上分组聚合查询(基线)'
            },
            {
                'query': "SELECT AVG(l_extendedprice) FROM lineitem WHERE l_discount BETWEEN 0.05 AND 0.07;",
                'description': '表上范围过滤聚合查询(基线)'
            }
        ]
        
        for query_info in simple_queries:
            query = query_info['query']
            description = query_info['description']
            
            # 基线仅记录一次
            result_baseline = self.run_query_with_timing(query, f"{description}")
            self.results[description] = {
                'baseline': result_baseline
            }
    
    def test_tpch_queries(self):
        """测试TPCH查询的布隆过滤器效果"""
        print("\n🔍 开始TPCH查询测试...")
        
        # 选择几个代表性的TPCH查询
        tpch_queries = ['q01.sql', 'q06.sql', 'q14.sql', 'q19.sql']
        
        for query_file in tpch_queries:
            query_path = os.path.join(self.queries_dir, query_file)
            if not os.path.exists(query_path):
                print(f"⚠️  查询文件不存在: {query_path}")
                continue
                
            with open(query_path, 'r') as f:
                query = f.read()
            
            description = f"TPCH {query_file}"
            
            # 运行一次TPCH查询作为基线
            result_baseline = self.run_query_with_timing(query, f"{description}")
            self.results[description] = {
                'baseline': result_baseline
            }
    
    def test_parquet_specific_queries(self):
        """测试Parquet文件特定的布隆过滤器效果"""
        print("\n🔍 开始Parquet特定查询测试(带/不带布隆过滤器)...")
        
        # 创建Parquet文件进行测试
        create_parquet_sql = f"""
        ATTACH '{self.db_path}' AS tpch;
        USE tpch;
        CREATE OR REPLACE TABLE lineitem_parquet AS SELECT * FROM lineitem;
        -- 写入带布隆过滤器的parquet
        COPY lineitem_parquet TO '/tmp/lineitem_bf.parquet' (FORMAT PARQUET, WRITE_BLOOM_FILTER true, BLOOM_FILTER_FALSE_POSITIVE_RATIO 0.001);
        -- 写入不带布隆过滤器的parquet
        COPY lineitem_parquet TO '/tmp/lineitem_nobf.parquet' (FORMAT PARQUET, WRITE_BLOOM_FILTER false);
        """
        
        # 先创建Parquet文件
        print("📁 创建Parquet测试文件...")
        subprocess.run([self.duckdb_path, "-c", create_parquet_sql], cwd="/tmp")
        
        parquet_queries = [
            {
                'base': "SELECT COUNT(*) FROM '{FILE}' WHERE l_shipdate >= '1994-01-01';",
                'description': 'Parquet文件日期过滤查询'
            },
            {
                'base': "SELECT l_returnflag, COUNT(*) FROM '{FILE}' WHERE l_quantity > 20 GROUP BY l_returnflag;",
                'description': 'Parquet文件分组聚合查询'
            }
        ]
        
        for query_info in parquet_queries:
            description = query_info['description']
            query_bf = query_info['base'].format(FILE='/tmp/lineitem_bf.parquet')
            query_nobf = query_info['base'].format(FILE='/tmp/lineitem_nobf.parquet')
            
            # 带布隆过滤器文件
            result_bf = self.run_query_with_timing(query_bf, f"{description} (文件含Bloom)")
            # 不带布隆过滤器文件
            result_nobf = self.run_query_with_timing(query_nobf, f"{description} (文件无Bloom)")
            
            self.results[description] = {
                'file_with_bloom': result_bf,
                'file_without_bloom': result_nobf,
                'speedup': (result_nobf['execution_time'] / result_bf['execution_time']) if result_bf.get('success') and result_nobf.get('success') and result_bf['execution_time'] > 0 else 0
            }
    
    def generate_report(self):
        """生成测试报告"""
        print("\n" + "="*80)
        print("📊 布隆过滤器性能测试报告")
        print("="*80)
        
        total_tests = len(self.results)
        def is_success(entry):
            if 'baseline' in entry:
                return entry['baseline']['success']
            return entry.get('file_with_bloom', {}).get('success') and entry.get('file_without_bloom', {}).get('success')
        successful_tests = sum(1 for r in self.results.values() if is_success(r))
        
        print(f"总测试数: {total_tests}")
        print(f"成功测试数: {successful_tests}")
        print(f"成功率: {successful_tests/total_tests*100:.1f}%")
        print()
        
        # 详细结果
        for test_name, result in self.results.items():
            print(f"🔍 {test_name}")
            print("-" * 50)
            
            if 'baseline' in result:
                if result['baseline']['success']:
                    print(f"基线执行时间: {result['baseline']['execution_time']:.3f} 秒")
                else:
                    print("❌ 基线测试失败")
                    print(f"  错误: {result['baseline']['error']}")
            else:
                if result['file_with_bloom']['success'] and result['file_without_bloom']['success']:
                    t_bf = result['file_with_bloom']['execution_time']
                    t_nobf = result['file_without_bloom']['execution_time']
                    speedup = result['speedup']
                    print(f"含Bloom文件: {t_bf:.3f} 秒")
                    print(f"无Bloom文件: {t_nobf:.3f} 秒")
                    print(f"性能提升(无Bloom/含Bloom): {speedup:.2f}x {'(Bloom更快)' if speedup > 1 else '(Bloom更慢)' if speedup < 1 else '(相同)'}")
                else:
                    print("❌ 测试失败")
                    if not result['file_with_bloom'].get('success', False):
                        print(f"  含Bloom失败: {result['file_with_bloom'].get('error')}")
                    if not result['file_without_bloom'].get('success', False):
                        print(f"  无Bloom失败: {result['file_without_bloom'].get('error')}")
            print()
        
        # 统计摘要
        successful_speedups = [r['speedup'] for r in self.results.values() if ('file_with_bloom' in r and r['file_with_bloom']['success'] and r['file_without_bloom']['success'] and r['speedup'] > 0)]
        
        if successful_speedups:
            avg_speedup = sum(successful_speedups) / len(successful_speedups)
            max_speedup = max(successful_speedups)
            min_speedup = min(successful_speedups)
            
            print("📈 性能统计摘要")
            print("-" * 30)
            print(f"平均性能提升: {avg_speedup:.2f}x")
            print(f"最大性能提升: {max_speedup:.2f}x")
            print(f"最小性能提升: {min_speedup:.2f}x")
            
            faster_count = sum(1 for s in successful_speedups if s > 1)
            slower_count = sum(1 for s in successful_speedups if s < 1)
            same_count = sum(1 for s in successful_speedups if s == 1)
            
            print(f"布隆过滤器更快: {faster_count} 个测试")
            print(f"布隆过滤器更慢: {slower_count} 个测试")
            print(f"性能相同: {same_count} 个测试")
        
        # 保存结果到JSON文件
        report_data = {
            'test_summary': {
                'total_tests': total_tests,
                'successful_tests': successful_tests,
                'success_rate': successful_tests/total_tests*100 if total_tests > 0 else 0
            },
            'results': self.results,
            'statistics': {
                'average_speedup': avg_speedup if successful_speedups else 0,
                'max_speedup': max_speedup if successful_speedups else 0,
                'min_speedup': min_speedup if successful_speedups else 0,
                'faster_tests': faster_count if successful_speedups else 0,
                'slower_tests': slower_count if successful_speedups else 0,
                'same_performance': same_count if successful_speedups else 0
            } if successful_speedups else {}
        }
        
        with open('bloom_filter_test_results.json', 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 详细结果已保存到: bloom_filter_test_results.json")
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始DuckDB布隆过滤器性能测试")
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
        
        # 运行测试
        self.test_simple_queries()
        self.test_tpch_queries()
        self.test_parquet_specific_queries()
        
        # 生成报告
        self.generate_report()

def main():
    # 配置路径
    duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 创建测试器并运行测试
    tester = BloomFilterTester(duckdb_path, db_path, queries_dir)
    tester.run_all_tests()

if __name__ == "__main__":
    main()
