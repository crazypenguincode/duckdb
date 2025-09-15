#!/usr/bin/env python3
"""
直接数据集缓存测试脚本
使用Python直接调用DuckDB，避免脚本解析问题
基于final_cache_test.py的成功方法
"""

import os
import sys
import time
import json
import subprocess
import tempfile
from pathlib import Path
from datetime import datetime

class DirectDatasetCacheTest:
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
    
    def run_query_with_timing(self, sql, enable_cache=True):
        """运行单个查询并计时"""
        # 创建临时脚本
        script_content = f"""
-- 设置缓存
SET enable_query_cache = {'true' if enable_cache else 'false'};

-- 创建数据库（如果需要）
.read {self.dataset_dir}/create_test_database_fixed.sql

-- 执行查询
.timer on
{sql};
.timer off
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, '-c', f'.read {script_path}'],
                capture_output=True,
                text=True,
                timeout=60
            )
            end_time = time.time()
            
            if result.returncode != 0:
                print(f"查询执行失败: {result.stderr}")
                return None
                
            # 解析时间信息
            output_lines = result.stdout.split('\n')
            for line in output_lines:
                if 'Run Time:' in line:
                    parts = line.split()
                    if len(parts) >= 4:
                        try:
                            real_time = float(parts[3])
                            return real_time
                        except (ValueError, IndexError):
                            continue
            
            # 如果没有找到时间信息，使用总执行时间
            return end_time - start_time
            
        except Exception as e:
            print(f"查询执行异常: {e}")
            return None
        finally:
            try:
                os.unlink(script_path)
            except:
                pass
    
    def test_query_cache_effect(self, sql, query_id):
        """测试单个查询的缓存效果"""
        print(f"  测试查询 {query_id}...")
        
        # 第一次执行（缓存启用）
        time1 = self.run_query_with_timing(sql, enable_cache=True)
        if time1 is None:
            return None
            
        # 第二次执行（应该命中缓存）
        time2 = self.run_query_with_timing(sql, enable_cache=True)
        if time2 is None:
            return None
            
        # 第三次执行（缓存禁用，作为对比）
        time3 = self.run_query_with_timing(sql, enable_cache=False)
        if time3 is None:
            return None
        
        return {
            'query_id': query_id,
            'first_run_cached': time1,
            'second_run_cached': time2,
            'no_cache_run': time3,
            'cache_improvement': ((time1 - time2) / time1 * 100) if time1 > 0 else 0,
            'vs_no_cache_improvement': ((time3 - time2) / time3 * 100) if time3 > 0 else 0
        }
    
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
            result = self.test_query_cache_effect(query['sql'], query['id'])
            if result:
                results.append(result)
                successful_tests += 1
                print(f"    ✅ 查询 {query['id']}: 缓存提升 {result['cache_improvement']:.1f}%, vs无缓存提升 {result['vs_no_cache_improvement']:.1f}%")
            else:
                print(f"    ❌ 查询 {query['id']}: 测试失败")
        
        if results:
            # 计算平均值
            avg_cache_improvement = sum(r['cache_improvement'] for r in results) / len(results)
            avg_vs_no_cache = sum(r['vs_no_cache_improvement'] for r in results) / len(results)
            avg_first_run = sum(r['first_run_cached'] for r in results) / len(results)
            avg_second_run = sum(r['second_run_cached'] for r in results) / len(results)
            avg_no_cache = sum(r['no_cache_run'] for r in results) / len(results)
            
            return {
                'dataset_name': dataset_name,
                'total_queries': len(queries),
                'successful_tests': successful_tests,
                'avg_first_run_ms': avg_first_run * 1000,
                'avg_second_run_ms': avg_second_run * 1000,
                'avg_no_cache_ms': avg_no_cache * 1000,
                'avg_cache_improvement_pct': avg_cache_improvement,
                'avg_vs_no_cache_improvement_pct': avg_vs_no_cache,
                'detailed_results': results
            }
        
        return None
    
    def run_all_tests(self):
        """运行所有数据集测试"""
        print("🚀 开始表5.7数据集缓存测试（直接方法）")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"数据集目录: {self.dataset_dir}")
        
        # 定义要测试的数据集
        datasets = [
            {
                'name': 'repeat_queries',
                'description': '重复查询集',
                'sql_file': 'repeat_queries_all.sql',
                'max_queries': 5,
                'target': '1000个查询，高重复率(80%)'
            },
            {
                'name': 'parameterized_queries', 
                'description': '参数化查询集',
                'sql_file': 'parameterized_queries_all.sql',
                'max_queries': 5,
                'target': '500个模板，参数变化'
            },
            {
                'name': 'cte_queries',
                'description': 'CTE查询集', 
                'sql_file': 'cte_queries_all.sql',
                'max_queries': 3,
                'target': '200个查询，复杂CTE结构'
            },
            {
                'name': 'concurrent_queries',
                'description': '并发查询集',
                'sql_file': 'concurrent_queries_all.sql', 
                'max_queries': 5,
                'target': '100个查询，高并发访问'
            }
        ]
        
        all_results = []
        successful_datasets = 0
        
        for dataset in datasets:
            print(f"\n{'='*60}")
            print(f"数据集: {dataset['description']}")
            print(f"目标: {dataset['target']}")
            print(f"{'='*60}")
            
            result = self.test_dataset(
                dataset['name'], 
                dataset['sql_file'],
                dataset.get('max_queries', 5)
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
        print("📊 表5.7数据集缓存测试总结报告（直接方法）")
        print(f"{'='*80}")
        
        print(f"测试覆盖率: {successful_tests}/{total_tests} ({successful_tests/total_tests*100:.1f}%)")
        
        if not results:
            print("❌ 没有成功的测试结果")
            return
            
        print(f"\n{'数据集类型':<20} {'查询数':<8} {'首次(ms)':<10} {'缓存(ms)':<10} {'无缓存(ms)':<12} {'缓存提升':<10} {'评级':<8}")
        print("-" * 88)
        
        total_improvement = 0
        valid_results = 0
        
        for result in results:
            dataset_name = result['dataset_name']
            query_count = result['successful_tests']
            first_run = result['avg_first_run_ms']
            cached_run = result['avg_second_run_ms']
            no_cache_run = result['avg_no_cache_ms']
            improvement = result['avg_vs_no_cache_improvement_pct']
            
            total_improvement += improvement
            valid_results += 1
            
            # 评级
            if improvement >= 70:
                rating = "🎉 优秀"
            elif improvement >= 40:
                rating = "✅ 良好"  
            elif improvement >= 20:
                rating = "⚠️  一般"
            else:
                rating = "❌ 较差"
            
            print(f"{dataset_name:<20} {query_count:<8} {first_run:<10.2f} {cached_run:<10.2f} {no_cache_run:<12.2f} {improvement:<9.1f}% {rating:<8}")
        
        if valid_results > 0:
            avg_improvement = total_improvement / valid_results
            print("-" * 88)
            print(f"{'平均性能提升':<20} {'':<8} {'':<10} {'':<10} {'':<12} {avg_improvement:<9.1f}% {'📈 总体':<8}")
        
        # 保存详细结果
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_file = self.base_dir / f"results/direct_dataset_test_{timestamp}.json"
        result_file.parent.mkdir(exist_ok=True)
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
                'test_method': 'direct_python_calls',
                'test_summary': {
                    'total_tests': total_tests,
                    'successful_tests': successful_tests,
                    'coverage_pct': successful_tests/total_tests*100,
                    'avg_improvement_pct': avg_improvement if valid_results > 0 else 0
                },
                'detailed_results': results
            }, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 详细结果已保存到: {result_file}")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 direct_dataset_cache_test.py <duckdb_path>")
        print("示例: python3 direct_dataset_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = DirectDatasetCacheTest(duckdb_path)
    results = tester.run_all_tests()
    
    if results:
        print(f"\n🎉 测试完成！共测试了 {len(results)} 个数据集")
    else:
        print(f"\n❌ 测试失败，没有获得有效结果")

if __name__ == "__main__":
    main()