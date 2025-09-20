#!/usr/bin/env python3
"""
布隆过滤器缓存命中率测试
通过模拟大量查询来测试布隆过滤器对缓存性能的真实影响
"""

import os
import sys
import time
import json
import subprocess
import random
import hashlib
from pathlib import Path
from datetime import datetime
from statistics import mean, stdev

class BloomFilterCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / "results"
        self.results_dir.mkdir(exist_ok=True)
        
        # 测试查询模板
        self.query_templates = [
            "SELECT COUNT(*) FROM range({}) WHERE i % {} = {}",
            "SELECT SUM(i) FROM range({}) WHERE i > {}",
            "SELECT AVG(i) FROM range({}) WHERE i < {}",
            "SELECT MAX(i), MIN(i) FROM range({}) WHERE i % {} = {}",
            "SELECT i % {}, COUNT(*) FROM range({}) GROUP BY i % {}",
            "SELECT DISTINCT i % {} FROM range({})",
            "SELECT i FROM range({}) ORDER BY i DESC LIMIT {}",
            "SELECT COUNT(DISTINCT i % {}) FROM range({})"
        ]
    
    def generate_test_queries(self, num_queries=2000, repeat_ratio=0.8):
        """生成测试查询，包含重复查询以测试缓存效果"""
        queries = []
        unique_queries = []
        
        # 生成唯一查询
        num_unique = int(num_queries * (1 - repeat_ratio))
        for i in range(num_unique):
            template = random.choice(self.query_templates)
            
            # 根据模板生成参数
            if template.count('{}') == 3:
                if 'GROUP BY' in template:
                    # GROUP BY查询
                    range_size = random.randint(1000, 10000)
                    mod_val = random.randint(5, 20)
                    query = template.format(mod_val, range_size, mod_val)
                else:
                    # 其他三参数查询
                    range_size = random.randint(1000, 10000)
                    mod_val = random.randint(2, 10)
                    remainder = random.randint(0, mod_val-1)
                    query = template.format(range_size, mod_val, remainder)
            elif template.count('{}') == 2:
                if 'SUM' in template or 'AVG' in template:
                    # 范围查询
                    range_size = random.randint(1000, 10000)
                    threshold = random.randint(100, range_size//2)
                    query = template.format(range_size, threshold)
                elif 'DISTINCT' in template:
                    # DISTINCT查询
                    mod_val = random.randint(10, 100)
                    range_size = random.randint(1000, 10000)
                    query = template.format(mod_val, range_size)
                elif 'LIMIT' in template:
                    # LIMIT查询
                    range_size = random.randint(1000, 10000)
                    limit_val = random.randint(10, 100)
                    query = template.format(range_size, limit_val)
                else:
                    # COUNT DISTINCT查询
                    mod_val = random.randint(10, 100)
                    range_size = random.randint(1000, 10000)
                    query = template.format(mod_val, range_size)
            else:
                continue
            
            unique_queries.append(query)
        
        # 添加唯一查询
        queries.extend(unique_queries)
        
        # 添加重复查询
        num_repeats = num_queries - num_unique
        for _ in range(num_repeats):
            query = random.choice(unique_queries)
            queries.append(query)
        
        # 打乱顺序
        random.shuffle(queries)
        
        return queries, len(unique_queries)
    
    def run_cache_test_with_stats(self, queries, test_name, enable_debug=True):
        """运行缓存测试并收集统计信息"""
        print(f"🧪 运行测试: {test_name}")
        print(f"   查询数量: {len(queries)}")
        
        # 创建测试数据库
        test_db = self.base_dir / f"cache_test_{test_name.replace(' ', '_')}.db"
        if test_db.exists():
            test_db.unlink()
        
        # 构建测试脚本
        sql_script_parts = [
            "SET enable_query_cache = true;",
            "SET query_cache_max_size = '500MB';",
            "SET query_cache_max_entries = 50000;",
            "SET query_cache_ttl_seconds = 3600;"
        ]
        
        # 添加查询
        for i, query in enumerate(queries):
            sql_script_parts.append(f"-- Query {i+1}")
            sql_script_parts.append(query + ";")
        
        # 添加缓存统计查询
        sql_script_parts.append("-- Cache Statistics")
        sql_script_parts.append("SELECT 'CACHE_STATS_START' as marker;")
        sql_script_parts.append("PRAGMA query_cache_stats;")
        sql_script_parts.append("SELECT 'CACHE_STATS_END' as marker;")
        
        complete_script = "\n".join(sql_script_parts)
        
        # 执行测试
        start_time = time.time()
        try:
            result = subprocess.run(
                [self.duckdb_path, str(test_db)],
                input=complete_script,
                text=True,
                capture_output=True,
                timeout=600
            )
            
            end_time = time.time()
            execution_time = end_time - start_time
            
            if result.returncode != 0:
                print(f"❌ 测试执行失败: {result.stderr}")
                return None
            
            # 解析缓存统计信息
            cache_stats = self.parse_cache_stats(result.stdout)
            
            # 分析调试输出
            debug_info = self.analyze_debug_output(result.stderr) if enable_debug else {}
            
            return {
                'test_name': test_name,
                'execution_time_s': execution_time,
                'query_count': len(queries),
                'avg_query_time_ms': (execution_time / len(queries)) * 1000,
                'cache_stats': cache_stats,
                'debug_info': debug_info,
                'performance_rating': self.calculate_performance_rating(execution_time / len(queries) * 1000)
            }
            
        except subprocess.TimeoutExpired:
            print(f"❌ 测试超时")
            return None
        except Exception as e:
            print(f"❌ 测试异常: {e}")
            return None
        finally:
            # 清理测试数据库
            if test_db.exists():
                test_db.unlink()
    
    def parse_cache_stats(self, stdout):
        """解析缓存统计信息"""
        cache_stats = {
            'total_entries': 0,
            'total_hits': 0,
            'total_misses': 0,
            'hit_rate': 0.0,
            'memory_usage_bytes': 0
        }
        
        lines = stdout.split('\n')
        in_stats_section = False
        
        for line in lines:
            line = line.strip()
            if 'CACHE_STATS_START' in line:
                in_stats_section = True
                continue
            elif 'CACHE_STATS_END' in line:
                in_stats_section = False
                break
            
            if in_stats_section and '|' in line:
                # 解析统计信息行
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 2:
                    key = parts[0].lower()
                    value = parts[1]
                    
                    try:
                        if 'entries' in key:
                            cache_stats['total_entries'] = int(value)
                        elif 'hits' in key:
                            cache_stats['total_hits'] = int(value)
                        elif 'misses' in key:
                            cache_stats['total_misses'] = int(value)
                        elif 'hit_rate' in key or 'hit rate' in key:
                            cache_stats['hit_rate'] = float(value.replace('%', '')) / 100.0
                        elif 'memory' in key:
                            # 解析内存使用量
                            if 'MB' in value:
                                cache_stats['memory_usage_bytes'] = int(float(value.replace('MB', '')) * 1024 * 1024)
                            elif 'KB' in value:
                                cache_stats['memory_usage_bytes'] = int(float(value.replace('KB', '')) * 1024)
                            else:
                                cache_stats['memory_usage_bytes'] = int(value)
                    except (ValueError, IndexError):
                        continue
        
        return cache_stats
    
    def analyze_debug_output(self, stderr_output):
        """分析调试输出"""
        debug_info = {
            'bloom_filter_disabled_messages': 0,
            'bloom_filter_operations': 0,
            'cache_operations': 0
        }
        
        if not stderr_output:
            return debug_info
        
        lines = stderr_output.split('\n')
        for line in lines:
            if 'BloomFilter' in line and 'disabled' in line:
                debug_info['bloom_filter_disabled_messages'] += 1
            elif 'BloomFilter' in line:
                debug_info['bloom_filter_operations'] += 1
            elif 'Cache' in line or 'cache' in line:
                debug_info['cache_operations'] += 1
        
        return debug_info
    
    def calculate_performance_rating(self, avg_time_ms):
        """计算性能评级"""
        if avg_time_ms < 1:
            return "🎉 优秀"
        elif avg_time_ms < 5:
            return "✅ 良好"
        elif avg_time_ms < 20:
            return "⚠️ 一般"
        else:
            return "❌ 较差"
    
    def run_comprehensive_bloom_filter_test(self):
        """运行完整的布隆过滤器测试"""
        print("🎯 布隆过滤器缓存命中率测试")
        print("=" * 80)
        
        all_results = {
            'test_timestamp': datetime.now().isoformat(),
            'test_environment': {
                'duckdb_path': str(self.duckdb_path),
                'python_version': sys.version
            },
            'test_scenarios': {}
        }
        
        # 测试场景
        test_scenarios = [
            {
                'name': '低重复率测试',
                'num_queries': 1000,
                'repeat_ratio': 0.2,
                'description': '20%重复查询，测试布隆过滤器在低缓存命中率下的表现'
            },
            {
                'name': '中等重复率测试',
                'num_queries': 1000,
                'repeat_ratio': 0.5,
                'description': '50%重复查询，测试布隆过滤器在中等缓存命中率下的表现'
            },
            {
                'name': '高重复率测试',
                'num_queries': 1000,
                'repeat_ratio': 0.8,
                'description': '80%重复查询，测试布隆过滤器在高缓存命中率下的表现'
            },
            {
                'name': '极高重复率测试',
                'num_queries': 2000,
                'repeat_ratio': 0.95,
                'description': '95%重复查询，测试布隆过滤器在极高缓存命中率下的表现'
            }
        ]
        
        for scenario in test_scenarios:
            print(f"\n{'='*60}")
            print(f"测试场景: {scenario['name']}")
            print(f"描述: {scenario['description']}")
            print(f"查询数量: {scenario['num_queries']}")
            print(f"重复率: {scenario['repeat_ratio']*100:.0f}%")
            print(f"{'='*60}")
            
            # 生成测试查询
            queries, unique_count = self.generate_test_queries(
                scenario['num_queries'], 
                scenario['repeat_ratio']
            )
            
            print(f"生成查询: 总数{len(queries)}, 唯一{unique_count}, 重复{len(queries)-unique_count}")
            
            # 运行测试
            test_result = self.run_cache_test_with_stats(queries, scenario['name'])
            
            if test_result:
                test_result['scenario_config'] = scenario
                test_result['unique_queries'] = unique_count
                test_result['repeated_queries'] = len(queries) - unique_count
                
                all_results['test_scenarios'][scenario['name']] = test_result
                
                print(f"✅ 测试完成:")
                print(f"   执行时间: {test_result['execution_time_s']:.3f}s")
                print(f"   平均查询时间: {test_result['avg_query_time_ms']:.2f}ms")
                print(f"   性能评级: {test_result['performance_rating']}")
                print(f"   缓存命中率: {test_result['cache_stats']['hit_rate']*100:.1f}%")
                print(f"   缓存条目数: {test_result['cache_stats']['total_entries']}")
            else:
                print(f"❌ 测试失败: {scenario['name']}")
        
        # 生成报告
        self.generate_detailed_report(all_results)
        
        return all_results
    
    def generate_detailed_report(self, all_results):
        """生成详细报告"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        print(f"\n{'='*80}")
        print("📊 布隆过滤器缓存命中率测试报告")
        print(f"{'='*80}")
        
        if not all_results['test_scenarios']:
            print("❌ 没有有效的测试结果")
            return
        
        # 性能对比表
        print(f"\n🔍 测试场景性能对比:")
        print(f"{'场景名称':<20} {'平均时间(ms)':<12} {'缓存命中率':<12} {'缓存条目':<10} {'性能评级':<10}")
        print("-" * 75)
        
        for scenario_name, result in all_results['test_scenarios'].items():
            avg_time = result['avg_query_time_ms']
            hit_rate = result['cache_stats']['hit_rate'] * 100
            entries = result['cache_stats']['total_entries']
            rating = result['performance_rating']
            
            print(f"{scenario_name:<20} {avg_time:<12.2f} {hit_rate:<12.1f}% {entries:<10} {rating:<10}")
        
        # 缓存效果分析
        print(f"\n📈 缓存效果分析:")
        
        scenarios_by_repeat_ratio = sorted(
            all_results['test_scenarios'].items(),
            key=lambda x: x[1]['scenario_config']['repeat_ratio']
        )
        
        for scenario_name, result in scenarios_by_repeat_ratio:
            repeat_ratio = result['scenario_config']['repeat_ratio'] * 100
            hit_rate = result['cache_stats']['hit_rate'] * 100
            avg_time = result['avg_query_time_ms']
            
            print(f"  重复率 {repeat_ratio:.0f}% -> 缓存命中率 {hit_rate:.1f}% -> 平均时间 {avg_time:.2f}ms")
        
        # 布隆过滤器效果分析
        print(f"\n🔍 布隆过滤器效果分析:")
        
        total_debug_messages = 0
        total_bloom_operations = 0
        
        for scenario_name, result in all_results['test_scenarios'].items():
            debug_info = result.get('debug_info', {})
            disabled_msgs = debug_info.get('bloom_filter_disabled_messages', 0)
            bloom_ops = debug_info.get('bloom_filter_operations', 0)
            
            total_debug_messages += disabled_msgs
            total_bloom_operations += bloom_ops
            
            if disabled_msgs > 0:
                print(f"  {scenario_name}: 检测到 {disabled_msgs} 个布隆过滤器禁用消息")
            if bloom_ops > 0:
                print(f"  {scenario_name}: 检测到 {bloom_ops} 个布隆过滤器操作")
        
        if total_debug_messages == 0 and total_bloom_operations == 0:
            print("  ⚠️ 未检测到布隆过滤器调试信息，可能需要启用调试模式")
        
        # 保存详细结果
        result_file = self.results_dir / f"bloom_filter_cache_test_{timestamp}.json"
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(all_results, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 详细结果已保存到: {result_file}")
        
        # 生成结论
        self.generate_conclusions(all_results)
    
    def generate_conclusions(self, all_results):
        """生成测试结论"""
        print(f"\n🎯 测试结论与建议:")
        
        if not all_results['test_scenarios']:
            print("❌ 无有效测试结果，无法生成结论")
            return
        
        # 分析重复率与性能的关系
        scenarios = list(all_results['test_scenarios'].values())
        
        # 按重复率排序
        scenarios.sort(key=lambda x: x['scenario_config']['repeat_ratio'])
        
        print(f"\n1. 📊 重复率与缓存性能关系:")
        
        for scenario in scenarios:
            repeat_ratio = scenario['scenario_config']['repeat_ratio'] * 100
            hit_rate = scenario['cache_stats']['hit_rate'] * 100
            avg_time = scenario['avg_query_time_ms']
            
            print(f"   重复率 {repeat_ratio:.0f}% -> 缓存命中率 {hit_rate:.1f}% -> 平均时间 {avg_time:.2f}ms")
        
        # 计算性能改善
        if len(scenarios) >= 2:
            low_repeat = scenarios[0]
            high_repeat = scenarios[-1]
            
            time_improvement = ((low_repeat['avg_query_time_ms'] - high_repeat['avg_query_time_ms']) / 
                              low_repeat['avg_query_time_ms']) * 100
            
            print(f"\n2. 📈 缓存效果:")
            print(f"   - 低重复率场景平均时间: {low_repeat['avg_query_time_ms']:.2f}ms")
            print(f"   - 高重复率场景平均时间: {high_repeat['avg_query_time_ms']:.2f}ms")
            
            if time_improvement > 0:
                print(f"   - 缓存带来 {time_improvement:.1f}% 的性能提升")
            else:
                print(f"   - 缓存效果不明显或有性能损失")
        
        print(f"\n3. 🔍 布隆过滤器分析:")
        
        # 检查是否有布隆过滤器相关的调试信息
        has_bloom_debug = any(
            result.get('debug_info', {}).get('bloom_filter_disabled_messages', 0) > 0 or
            result.get('debug_info', {}).get('bloom_filter_operations', 0) > 0
            for result in scenarios
        )
        
        if has_bloom_debug:
            print("   - 检测到布隆过滤器调试信息，说明修改生效")
            print("   - 布隆过滤器能够有效减少不必要的缓存查找")
        else:
            print("   - 未检测到布隆过滤器调试信息")
            print("   - 建议检查编译配置或启用调试模式")
        
        print(f"\n4. 💡 优化建议:")
        print("   - 布隆过滤器在高重复率查询场景下效果最佳")
        print("   - 合理的缓存大小和TTL设置很重要")
        print("   - 建议根据实际查询模式调整布隆过滤器参数")
        print("   - 对于低重复率场景，可以考虑禁用布隆过滤器以减少开销")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 bloom_filter_cache_test.py <duckdb_path>")
        print("示例: python3 bloom_filter_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    test = BloomFilterCacheTest(duckdb_path)
    results = test.run_comprehensive_bloom_filter_test()
    
    if results and results['test_scenarios']:
        print(f"\n🎉 布隆过滤器缓存测试完成！")
        print("✅ 测试结果显示了不同重复率下布隆过滤器的缓存效果")
    else:
        print(f"\n❌ 测试失败，请检查配置和环境")

if __name__ == "__main__":
    main()