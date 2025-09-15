#!/usr/bin/env python3
"""
正确的数据集缓存测试脚本
使用part5_test/dataset目录下已生成的数据集
采用单个DuckDB会话避免缓存失效问题
"""

import os
import sys
import time
import json
import subprocess
import tempfile
from pathlib import Path
from datetime import datetime

class DatasetCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.dataset_dir = self.base_dir / "dataset"
        self.results = {}
        
    def load_sql_queries(self, sql_file_path):
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
            # 找到SQL语句（跳过注释行和查询ID行）
            sql_lines = []
            skip_first_line = True  # 跳过第一行（查询ID）
            
            for line in lines:
                line = line.strip()
                if skip_first_line and (not line or line.isdigit() or '(' in line):
                    skip_first_line = False
                    continue
                    
                if not line.startswith('--') and line:
                    sql_lines.append(line)
            
            if sql_lines:
                sql = '\n'.join(sql_lines).strip()
                if sql.endswith(';'):
                    sql = sql[:-1]  # 移除末尾分号
                    
                # 验证SQL不为空且不是纯数字
                if sql and not sql.isdigit():
                    queries.append({
                        'id': i,
                        'sql': sql
                    })
                
        return queries
    
    def create_test_script(self, queries, test_name, enable_cache=True):
        """创建测试脚本，使用单个DuckDB会话"""
        script_content = f"""
-- 设置缓存
SET enable_query_cache = {'true' if enable_cache else 'false'};

-- 创建数据库
.read {self.dataset_dir}/create_test_database_fixed.sql

-- 开始计时测试
"""
        
        for query in queries:
            script_content += f"""
-- Query {query['id']} - 第一次执行
.timer on
{query['sql']};
.timer off

-- Query {query['id']} - 第二次执行（应该命中缓存）
.timer on
{query['sql']};
.timer off

"""
        
        return script_content
    
    def run_single_session_test(self, queries, test_name, enable_cache=True):
        """使用单个DuckDB会话运行测试"""
        print(f"\n{'='*60}")
        print(f"测试: {test_name}")
        print(f"缓存状态: {'启用' if enable_cache else '禁用'}")
        print(f"查询数量: {len(queries)}")
        print(f"{'='*60}")
        
        # 创建临时脚本文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            script_content = self.create_test_script(queries, test_name, enable_cache)
            f.write(script_content)
            script_path = f.name
        
        try:
            # 运行DuckDB脚本
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, '-c', f'.read {script_path}'],
                capture_output=True,
                text=True,
                timeout=300  # 5分钟超时
            )
            end_time = time.time()
            
            if result.returncode != 0:
                print(f"❌ 测试失败: {result.stderr}")
                return None
                
            # 解析输出中的时间信息
            output_lines = result.stdout.split('\n')
            times = []
            for line in output_lines:
                if 'Run Time:' in line:
                    # 提取时间，格式如 "Run Time: real 0.001 user 0.000 sys 0.000"
                    parts = line.split()
                    if len(parts) >= 4:
                        try:
                            real_time = float(parts[3])
                            times.append(real_time)
                        except (ValueError, IndexError):
                            continue
            
            # 计算性能指标
            if len(times) >= 2:
                # 假设每个查询执行两次，第一次是冷启动，第二次应该命中缓存
                first_runs = times[::2]  # 奇数索引：第一次执行
                second_runs = times[1::2]  # 偶数索引：第二次执行
                
                avg_first = sum(first_runs) / len(first_runs) if first_runs else 0
                avg_second = sum(second_runs) / len(second_runs) if second_runs else 0
                
                improvement = ((avg_first - avg_second) / avg_first * 100) if avg_first > 0 else 0
                
                result_data = {
                    'test_name': test_name,
                    'cache_enabled': enable_cache,
                    'query_count': len(queries),
                    'total_time': end_time - start_time,
                    'avg_first_run_ms': avg_first * 1000,
                    'avg_second_run_ms': avg_second * 1000,
                    'performance_improvement_pct': improvement,
                    'all_times': times
                }
                
                print(f"✅ 测试完成:")
                print(f"   查询数量: {len(queries)}")
                print(f"   平均首次执行: {avg_first*1000:.2f}ms")
                print(f"   平均二次执行: {avg_second*1000:.2f}ms")
                print(f"   性能提升: {improvement:.1f}%")
                
                return result_data
            else:
                print(f"⚠️  无法解析时间信息，获得的时间数据: {len(times)} 个")
                return None
                
        except subprocess.TimeoutExpired:
            print(f"❌ 测试超时")
            return None
        except Exception as e:
            print(f"❌ 测试异常: {e}")
            return None
        finally:
            # 清理临时文件
            try:
                os.unlink(script_path)
            except:
                pass
    
    def test_dataset(self, dataset_name, sql_file_name, max_queries=None):
        """测试单个数据集"""
        sql_file_path = self.dataset_dir / dataset_name / sql_file_name
        
        if not sql_file_path.exists():
            print(f"❌ SQL文件不存在: {sql_file_path}")
            return None
            
        # 加载查询
        queries = self.load_sql_queries(sql_file_path)
        if not queries:
            print(f"❌ 无法从文件加载查询: {sql_file_path}")
            return None
            
        # 限制查询数量以加快测试
        if max_queries and len(queries) > max_queries:
            queries = queries[:max_queries]
            print(f"📝 限制查询数量为: {max_queries}")
        
        # 测试启用缓存的情况
        cache_result = self.run_single_session_test(queries, f"{dataset_name} (缓存启用)", True)
        
        # 测试禁用缓存的情况
        no_cache_result = self.run_single_session_test(queries, f"{dataset_name} (缓存禁用)", False)
        
        return {
            'dataset_name': dataset_name,
            'with_cache': cache_result,
            'without_cache': no_cache_result
        }
    
    def run_all_tests(self):
        """运行所有数据集测试"""
        print("🚀 开始表5.7数据集缓存测试")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"数据集目录: {self.dataset_dir}")
        
        # 定义要测试的数据集
        datasets = [
            {
                'name': 'repeat_queries',
                'description': '重复查询集',
                'sql_file': 'repeat_queries_all.sql',
                'max_queries': 10,  # 限制查询数量
                'target': '1000个查询，高重复率(80%)'
            },
            {
                'name': 'parameterized_queries', 
                'description': '参数化查询集',
                'sql_file': 'parameterized_queries_all.sql',
                'max_queries': 10,
                'target': '500个模板，参数变化'
            },
            {
                'name': 'cte_queries',
                'description': 'CTE查询集', 
                'sql_file': 'cte_queries_all.sql',
                'max_queries': 5,  # CTE查询较复杂，减少数量
                'target': '200个查询，复杂CTE结构'
            },
            {
                'name': 'concurrent_queries',
                'description': '并发查询集',
                'sql_file': 'concurrent_queries_all.sql', 
                'max_queries': 8,
                'target': '100个查询，高并发访问'
            }
        ]
        
        all_results = []
        successful_tests = 0
        
        for dataset in datasets:
            print(f"\n🔍 测试数据集: {dataset['description']}")
            print(f"   目标: {dataset['target']}")
            
            result = self.test_dataset(
                dataset['name'], 
                dataset['sql_file'],
                dataset.get('max_queries')
            )
            
            if result:
                all_results.append(result)
                successful_tests += 1
            else:
                print(f"❌ 数据集 {dataset['name']} 测试失败")
        
        # 生成总结报告
        self.generate_summary_report(all_results, successful_tests, len(datasets))
        
        return all_results
    
    def generate_summary_report(self, results, successful_tests, total_tests):
        """生成总结报告"""
        print(f"\n{'='*80}")
        print("📊 表5.7数据集缓存测试总结报告")
        print(f"{'='*80}")
        
        print(f"测试覆盖率: {successful_tests}/{total_tests} ({successful_tests/total_tests*100:.1f}%)")
        
        if not results:
            print("❌ 没有成功的测试结果")
            return
            
        print(f"\n{'数据集类型':<20} {'查询数':<8} {'无缓存(ms)':<12} {'缓存(ms)':<12} {'提升':<10} {'评级':<8}")
        print("-" * 80)
        
        total_improvement = 0
        valid_results = 0
        
        for result in results:
            dataset_name = result['dataset_name']
            with_cache = result.get('with_cache')
            without_cache = result.get('without_cache')
            
            if with_cache and without_cache:
                cache_time = with_cache['avg_second_run_ms']
                no_cache_time = without_cache['avg_first_run_ms']
                query_count = with_cache['query_count']
                
                if no_cache_time > 0:
                    improvement = (no_cache_time - cache_time) / no_cache_time * 100
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
                    
                    print(f"{dataset_name:<20} {query_count:<8} {no_cache_time:<12.2f} {cache_time:<12.2f} {improvement:<9.1f}% {rating:<8}")
                else:
                    print(f"{dataset_name:<20} {query_count:<8} {'N/A':<12} {'N/A':<12} {'N/A':<10} {'❌ 错误':<8}")
            else:
                print(f"{dataset_name:<20} {'N/A':<8} {'N/A':<12} {'N/A':<12} {'N/A':<10} {'❌ 失败':<8}")
        
        if valid_results > 0:
            avg_improvement = total_improvement / valid_results
            print("-" * 80)
            print(f"{'平均性能提升':<20} {'':<8} {'':<12} {'':<12} {avg_improvement:<9.1f}% {'📈 总体':<8}")
        
        # 保存详细结果
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_file = self.base_dir / f"results/correct_dataset_test_{timestamp}.json"
        result_file.parent.mkdir(exist_ok=True)
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
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
        print("用法: python3 correct_dataset_cache_test.py <duckdb_path>")
        print("示例: python3 correct_dataset_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = DatasetCacheTest(duckdb_path)
    results = tester.run_all_tests()
    
    if results:
        print(f"\n🎉 测试完成！共测试了 {len(results)} 个数据集")
    else:
        print(f"\n❌ 测试失败，没有获得有效结果")

if __name__ == "__main__":
    main()