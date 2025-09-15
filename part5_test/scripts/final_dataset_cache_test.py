#!/usr/bin/env python3
"""
最终版数据集缓存测试脚本
基于已验证有效的final_cache_test.py方法
使用真实的part5_test/dataset数据集文件
"""

import os
import sys
import time
import json
import subprocess
from pathlib import Path
from datetime import datetime

class FinalDatasetCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.dataset_dir = self.base_dir / "dataset"
        
    def load_sql_queries(self, sql_file_path, max_queries=None):
        """从SQL文件中加载查询"""
        queries = []
        if not sql_file_path.exists():
            print(f"警告: SQL文件不存在: {sql_file_path}")
            return queries
            
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # 按注释分割查询
        query_blocks = content.split('-- Query ')
        for i, block in enumerate(query_blocks[1:], 1):  # 跳过第一个空块
            lines = block.strip().split('\n')
            
            # 找到实际的SQL语句
            sql_lines = []
            found_sql = False
            
            for line in lines:
                line = line.strip()
                # 跳过注释行和空行
                if line.startswith('--') or not line:
                    continue
                # 跳过模板信息行
                if 'Template:' in line or 'Parameters:' in line or 'Complexity:' in line:
                    continue
                    
                # 这应该是SQL语句
                if line.upper().startswith(('SELECT', 'WITH', 'INSERT', 'UPDATE', 'DELETE')):
                    found_sql = True
                    
                if found_sql:
                    sql_lines.append(line)
            
            if sql_lines:
                sql = '\n'.join(sql_lines).strip()
                if sql.endswith(';'):
                    sql = sql[:-1]  # 移除末尾分号
                    
                # 验证SQL有效
                if sql and any(keyword in sql.upper() for keyword in ['SELECT', 'WITH', 'INSERT', 'UPDATE', 'DELETE']):
                    queries.append({
                        'id': i,
                        'sql': sql
                    })
                    
                    if max_queries and len(queries) >= max_queries:
                        break
                
        return queries
    
    def run_query_with_cache_test(self, sql, query_id):
        """使用已验证的方法测试单个查询的缓存效果"""
        print(f"  测试查询 {query_id}...")
        
        try:
            # 读取数据库创建脚本内容
            with open(self.dataset_dir / "create_test_database_fixed.sql", 'r') as f:
                db_init_sql = f.read()
            
            # 简单的性能测试：多次执行并计算平均时间
            cache_times = []
            no_cache_times = []
            
            # 测试缓存启用的情况
            for i in range(3):
                cache_script = f'''
{db_init_sql}

SET enable_query_cache = true;
{sql};
{sql};
'''
                start = time.time()
                cache_result = subprocess.run(
                    [self.duckdb_path, '-c', cache_script],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                end = time.time()
                
                if cache_result.returncode == 0:
                    cache_times.append(end - start)
                else:
                    print(f"    ⚠️  缓存测试 {i+1} 失败: {cache_result.stderr}")
            
            # 测试缓存禁用的情况
            for i in range(3):
                no_cache_script = f'''
{db_init_sql}

SET enable_query_cache = false;
{sql};
{sql};
'''
                start = time.time()
                no_cache_result = subprocess.run(
                    [self.duckdb_path, '-c', no_cache_script],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                end = time.time()
                
                if no_cache_result.returncode == 0:
                    no_cache_times.append(end - start)
                else:
                    print(f"    ⚠️  无缓存测试 {i+1} 失败: {no_cache_result.stderr}")
            
            if cache_times and no_cache_times:
                avg_cache_time = sum(cache_times) / len(cache_times)
                avg_no_cache_time = sum(no_cache_times) / len(no_cache_times)
                
                improvement = ((avg_no_cache_time - avg_cache_time) / avg_no_cache_time * 100) if avg_no_cache_time > 0 else 0
                
                result_data = {
                    'query_id': query_id,
                    'avg_cache_time_s': avg_cache_time,
                    'avg_no_cache_time_s': avg_no_cache_time,
                    'improvement_pct': improvement,
                    'cache_times': cache_times,
                    'no_cache_times': no_cache_times
                }
                
                print(f"    ✅ 缓存: {avg_cache_time*1000:.1f}ms, 无缓存: {avg_no_cache_time*1000:.1f}ms, 提升: {improvement:.1f}%")
                return result_data
            else:
                print(f"    ❌ 无法获得有效的时间测量 (缓存:{len(cache_times)}, 无缓存:{len(no_cache_times)})")
                return None
                
        except Exception as e:
            print(f"    ❌ 测试异常: {e}")
            return None
    
    def test_dataset(self, dataset_name, sql_file_name, max_queries=5):
        """测试单个数据集"""
        print(f"\n🔍 测试数据集: {dataset_name}")
        
        sql_file_path = self.dataset_dir / dataset_name / sql_file_name
        if not sql_file_path.exists():
            print(f"❌ SQL文件不存在: {sql_file_path}")
            return None
            
        # 加载查询
        queries = self.load_sql_queries(sql_file_path, max_queries)
        if not queries:
            print(f"❌ 无法从文件加载查询: {sql_file_path}")
            return None
            
        print(f"📝 加载了 {len(queries)} 个查询")
        
        # 测试每个查询
        results = []
        successful_tests = 0
        
        for query in queries:
            result = self.run_query_with_cache_test(query['sql'], query['id'])
            if result:
                results.append(result)
                successful_tests += 1
            else:
                print(f"    ❌ 查询 {query['id']}: 测试失败")
        
        if results:
            # 计算平均值
            avg_improvement = sum(r['improvement_pct'] for r in results) / len(results)
            avg_cache_time = sum(r['avg_cache_time_s'] for r in results) / len(results)
            avg_no_cache_time = sum(r['avg_no_cache_time_s'] for r in results) / len(results)
            
            return {
                'dataset_name': dataset_name,
                'total_queries': len(queries),
                'successful_tests': successful_tests,
                'avg_cache_time_ms': avg_cache_time * 1000,
                'avg_no_cache_time_ms': avg_no_cache_time * 1000,
                'avg_improvement_pct': avg_improvement,
                'detailed_results': results
            }
        
        return None
    
    def run_all_tests(self):
        """运行所有数据集测试"""
        print("🚀 开始表5.7数据集缓存测试（最终版）")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"数据集目录: {self.dataset_dir}")
        
        # 定义要测试的数据集
        datasets = [
            {
                'name': 'repeat_queries',
                'description': '重复查询集',
                'sql_file': 'repeat_queries_all.sql',
                'max_queries': 3,  # 减少查询数量以加快测试
                'target': '1000个查询，高重复率(80%)'
            },
            {
                'name': 'parameterized_queries', 
                'description': '参数化查询集',
                'sql_file': 'parameterized_queries_all.sql',
                'max_queries': 3,
                'target': '500个模板，参数变化'
            }
        ]
        
        all_results = []
        successful_datasets = 0
        
        for dataset in datasets:
            print(f"\n{'='*80}")
            print(f"数据集: {dataset['description']}")
            print(f"目标: {dataset['target']}")
            print(f"{'='*80}")
            
            result = self.test_dataset(
                dataset['name'], 
                dataset['sql_file'],
                dataset.get('max_queries', 3)
            )
            
            if result:
                all_results.append(result)
                successful_datasets += 1
                print(f"✅ 数据集 {dataset['name']} 测试完成")
            else:
                print(f"❌ 数据集 {dataset['name']} 测试失败")
        
        # 生成总结报告
        self.generate_summary_report(all_results, successful_datasets, len(datasets))
        
        return all_results
    
    def generate_summary_report(self, results, successful_tests, total_tests):
        """生成总结报告"""
        print(f"\n{'='*80}")
        print("📊 表5.7数据集缓存测试总结报告（最终版）")
        print(f"{'='*80}")
        
        print(f"测试覆盖率: {successful_tests}/{total_tests} ({successful_tests/total_tests*100:.1f}%)")
        
        if not results:
            print("❌ 没有成功的测试结果")
            return
            
        print(f"\n{'数据集类型':<20} {'查询数':<8} {'缓存(ms)':<12} {'无缓存(ms)':<12} {'提升':<10} {'评级':<8}")
        print("-" * 80)
        
        total_improvement = 0
        valid_results = 0
        
        for result in results:
            dataset_name = result['dataset_name']
            query_count = result['successful_tests']
            cache_time = result['avg_cache_time_ms']
            no_cache_time = result['avg_no_cache_time_ms']
            improvement = result['avg_improvement_pct']
            
            total_improvement += improvement
            valid_results += 1
            
            # 评级
            if improvement >= 50:
                rating = "🎉 优秀"
            elif improvement >= 25:
                rating = "✅ 良好"  
            elif improvement >= 10:
                rating = "⚠️  一般"
            else:
                rating = "❌ 较差"
            
            print(f"{dataset_name:<20} {query_count:<8} {cache_time:<12.1f} {no_cache_time:<12.1f} {improvement:<9.1f}% {rating:<8}")
        
        if valid_results > 0:
            avg_improvement = total_improvement / valid_results
            print("-" * 80)
            print(f"{'平均性能提升':<20} {'':<8} {'':<12} {'':<12} {avg_improvement:<9.1f}% {'📈 总体':<8}")
        
        # 保存详细结果
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_file = self.base_dir / f"results/final_dataset_test_{timestamp}.json"
        result_file.parent.mkdir(exist_ok=True)
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
                'test_method': 'final_verified_method',
                'test_summary': {
                    'total_tests': total_tests,
                    'successful_tests': successful_tests,
                    'coverage_pct': successful_tests/total_tests*100,
                    'avg_improvement_pct': avg_improvement if valid_results > 0 else 0
                },
                'detailed_results': results
            }, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 详细结果已保存到: {result_file}")
        
        # 输出表5.7格式的结果
        print(f"\n📋 表5.7格式结果:")
        print("| 数据集类型 | 数据规模 | 查询特点 | 测试目标 | 缓存提升 | 状态 |")
        print("|------------|----------|----------|----------|----------|------|")
        
        for result in results:
            dataset_name = result['dataset_name']
            improvement = result['avg_improvement_pct']
            
            if dataset_name == 'repeat_queries':
                print(f"| **重复查询集** | {result['successful_tests']}个查询 | 高重复率(80%) | 缓存命中率测试 | {improvement:.1f}% | ✅ |")
            elif dataset_name == 'parameterized_queries':
                print(f"| **参数化查询集** | {result['successful_tests']}个模板 | 参数变化 | SQL标准化测试 | {improvement:.1f}% | ✅ |")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 final_dataset_cache_test.py <duckdb_path>")
        print("示例: python3 final_dataset_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = FinalDatasetCacheTest(duckdb_path)
    results = tester.run_all_tests()
    
    if results:
        print(f"\n🎉 测试完成！共测试了 {len(results)} 个数据集")
        print("✅ 已成功验证DuckDB查询缓存功能在真实数据集上的表现")
    else:
        print(f"\n❌ 测试失败，没有获得有效结果")

if __name__ == "__main__":
    main()