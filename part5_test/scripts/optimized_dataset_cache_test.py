#!/usr/bin/env python3
"""
优化的数据集缓存测试脚本
使用持久数据库连接，避免重复创建数据库
真正测试缓存在同一会话中的效果
"""

import os
import sys
import time
import json
import subprocess
import tempfile
from pathlib import Path
from datetime import datetime

class OptimizedDatasetCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.dataset_dir = self.base_dir / "dataset"
        self.db_initialized = False
        
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
    
    def create_session_script(self, queries, enable_cache=True):
        """创建单个会话脚本，包含所有查询的多次执行"""
        script_content = f"""
-- 设置缓存
SET enable_query_cache = {'true' if enable_cache else 'false'};

-- 创建数据库（只创建一次）
.read {self.dataset_dir}/create_test_database_fixed.sql

-- 执行所有查询的多轮测试
"""
        
        # 为每个查询添加多次执行
        for query in queries:
            script_content += f"""
-- ========== 查询 {query['id']} ==========
-- 第一次执行（冷启动）
.timer on
{query['sql']};
.timer off

-- 第二次执行（应该命中缓存）
.timer on
{query['sql']};
.timer off

-- 第三次执行（再次验证缓存）
.timer on
{query['sql']};
.timer off

"""
        
        return script_content
    
    def run_session_test(self, queries, test_name, enable_cache=True):
        """运行单个会话测试"""
        print(f"\n{'='*60}")
        print(f"测试: {test_name}")
        print(f"缓存状态: {'启用' if enable_cache else '禁用'}")
        print(f"查询数量: {len(queries)}")
        print(f"{'='*60}")
        
        # 创建会话脚本
        script_content = self.create_session_script(queries, enable_cache)
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, '-c', f'.read {script_path}'],
                capture_output=True,
                text=True,
                timeout=300
            )
            end_time = time.time()
            
            if result.returncode != 0:
                print(f"❌ 测试失败: {result.stderr}")
                return None
                
            # 解析时间信息
            output_lines = result.stdout.split('\n')
            times = []
            for line in output_lines:
                if 'Run Time:' in line:
                    parts = line.split()
                    if len(parts) >= 4:
                        try:
                            real_time = float(parts[3])
                            times.append(real_time)
                        except (ValueError, IndexError):
                            continue
            
            print(f"📊 获得 {len(times)} 个时间测量值")
            
            if len(times) >= len(queries) * 3:  # 每个查询执行3次
                # 按查询分组时间
                query_results = []
                for i in range(len(queries)):
                    start_idx = i * 3
                    if start_idx + 2 < len(times):
                        first_run = times[start_idx]
                        second_run = times[start_idx + 1]
                        third_run = times[start_idx + 2]
                        
                        # 计算缓存效果（第一次vs后续执行）
                        avg_cached = (second_run + third_run) / 2
                        improvement = ((first_run - avg_cached) / first_run * 100) if first_run > 0 else 0
                        
                        query_results.append({
                            'query_id': queries[i]['id'],
                            'first_run': first_run,
                            'second_run': second_run,
                            'third_run': third_run,
                            'avg_cached': avg_cached,
                            'improvement_pct': improvement
                        })
                        
                        print(f"  查询 {queries[i]['id']}: {first_run*1000:.2f}ms → {avg_cached*1000:.2f}ms (提升 {improvement:.1f}%)")
                
                if query_results:
                    # 计算总体统计
                    avg_first = sum(r['first_run'] for r in query_results) / len(query_results)
                    avg_cached = sum(r['avg_cached'] for r in query_results) / len(query_results)
                    overall_improvement = ((avg_first - avg_cached) / avg_first * 100) if avg_first > 0 else 0
                    
                    result_data = {
                        'test_name': test_name,
                        'cache_enabled': enable_cache,
                        'query_count': len(queries),
                        'total_time': end_time - start_time,
                        'avg_first_run_ms': avg_first * 1000,
                        'avg_cached_run_ms': avg_cached * 1000,
                        'overall_improvement_pct': overall_improvement,
                        'query_results': query_results,
                        'all_times': times
                    }
                    
                    print(f"✅ 测试完成:")
                    print(f"   平均首次执行: {avg_first*1000:.2f}ms")
                    print(f"   平均缓存执行: {avg_cached*1000:.2f}ms")
                    print(f"   总体性能提升: {overall_improvement:.1f}%")
                    
                    return result_data
            
            print(f"⚠️  时间数据不足，获得 {len(times)} 个，期望 {len(queries) * 3} 个")
            return None
                
        except subprocess.TimeoutExpired:
            print(f"❌ 测试超时")
            return None
        except Exception as e:
            print(f"❌ 测试异常: {e}")
            return None
        finally:
            try:
                os.unlink(script_path)
            except:
                pass
    
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
        
        # 测试启用缓存的情况
        cache_result = self.run_session_test(queries, f"{dataset_name} (缓存启用)", True)
        
        # 测试禁用缓存的情况
        no_cache_result = self.run_session_test(queries, f"{dataset_name} (缓存禁用)", False)
        
        return {
            'dataset_name': dataset_name,
            'with_cache': cache_result,
            'without_cache': no_cache_result
        }
    
    def run_all_tests(self):
        """运行所有数据集测试"""
        print("🚀 开始表5.7数据集缓存测试（优化方法）")
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
        print("📊 表5.7数据集缓存测试总结报告（优化方法）")
        print(f"{'='*80}")
        
        print(f"测试覆盖率: {successful_tests}/{total_tests} ({successful_tests/total_tests*100:.1f}%)")
        
        if not results:
            print("❌ 没有成功的测试结果")
            return
            
        print(f"\n{'数据集类型':<20} {'查询数':<8} {'缓存首次(ms)':<14} {'缓存后续(ms)':<14} {'无缓存(ms)':<12} {'缓存提升':<10} {'评级':<8}")
        print("-" * 96)
        
        total_improvement = 0
        valid_results = 0
        
        for result in results:
            dataset_name = result['dataset_name']
            with_cache = result.get('with_cache')
            without_cache = result.get('without_cache')
            
            if with_cache:
                query_count = with_cache['query_count']
                cache_first = with_cache['avg_first_run_ms']
                cache_cached = with_cache['avg_cached_run_ms']
                cache_improvement = with_cache['overall_improvement_pct']
                
                no_cache_time = without_cache['avg_first_run_ms'] if without_cache else cache_first
                
                # 计算相对于无缓存的提升
                vs_no_cache_improvement = ((no_cache_time - cache_cached) / no_cache_time * 100) if no_cache_time > 0 else 0
                
                total_improvement += vs_no_cache_improvement
                valid_results += 1
                
                # 评级
                if vs_no_cache_improvement >= 70:
                    rating = "🎉 优秀"
                elif vs_no_cache_improvement >= 40:
                    rating = "✅ 良好"  
                elif vs_no_cache_improvement >= 20:
                    rating = "⚠️  一般"
                else:
                    rating = "❌ 较差"
                
                print(f"{dataset_name:<20} {query_count:<8} {cache_first:<14.2f} {cache_cached:<14.2f} {no_cache_time:<12.2f} {vs_no_cache_improvement:<9.1f}% {rating:<8}")
            else:
                print(f"{dataset_name:<20} {'N/A':<8} {'N/A':<14} {'N/A':<14} {'N/A':<12} {'N/A':<10} {'❌ 失败':<8}")
        
        if valid_results > 0:
            avg_improvement = total_improvement / valid_results
            print("-" * 96)
            print(f"{'平均性能提升':<20} {'':<8} {'':<14} {'':<14} {'':<12} {avg_improvement:<9.1f}% {'📈 总体':<8}")
        
        # 保存详细结果
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        result_file = self.base_dir / f"results/optimized_dataset_test_{timestamp}.json"
        result_file.parent.mkdir(exist_ok=True)
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
                'test_method': 'optimized_single_session',
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
        print("用法: python3 optimized_dataset_cache_test.py <duckdb_path>")
        print("示例: python3 optimized_dataset_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = OptimizedDatasetCacheTest(duckdb_path)
    results = tester.run_all_tests()
    
    if results:
        print(f"\n🎉 测试完成！共测试了 {len(results)} 个数据集")
    else:
        print(f"\n❌ 测试失败，没有获得有效结果")

if __name__ == "__main__":
    main()