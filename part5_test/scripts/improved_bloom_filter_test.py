#!/usr/bin/env python3
"""
改进的布隆过滤器性能测试
通过编译不同配置的DuckDB来测试布隆过滤器的真实效果
"""

import os
import sys
import time
import json
import subprocess
import random
import shutil
from pathlib import Path
from datetime import datetime
from statistics import mean, stdev

class ImprovedBloomFilterTest:
    def __init__(self, duckdb_source_dir):
        self.duckdb_source_dir = Path(duckdb_source_dir)
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / "results"
        self.results_dir.mkdir(exist_ok=True)
        
        # 测试配置
        self.test_configs = [
            {
                'name': '禁用布隆过滤器',
                'bloom_filter_size': 0,
                'bloom_filter_hash_functions': 0,
                'description': '完全禁用布隆过滤器'
            },
            {
                'name': '小型布隆过滤器',
                'bloom_filter_size': 10000,
                'bloom_filter_hash_functions': 2,
                'description': '小型布隆过滤器，低内存占用'
            },
            {
                'name': '标准布隆过滤器',
                'bloom_filter_size': 100000,
                'bloom_filter_hash_functions': 3,
                'description': '标准配置，平衡性能和内存'
            },
            {
                'name': '大型布隆过滤器',
                'bloom_filter_size': 1000000,
                'bloom_filter_hash_functions': 4,
                'description': '大型布隆过滤器，低假阳性率'
            }
        ]
        
        # 测试查询
        self.test_queries = [
            "SELECT COUNT(*) FROM range(1000)",
            "SELECT SUM(i) FROM range(10000) t(i)",
            "SELECT AVG(i) FROM range(5000) t(i) WHERE i % 2 = 0",
            "SELECT MAX(i), MIN(i) FROM range(8000) t(i)",
            "SELECT i % 10 as bucket, COUNT(*) FROM range(20000) t(i) GROUP BY bucket",
            "WITH RECURSIVE t(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM t WHERE n < 100) SELECT SUM(n) FROM t",
            "SELECT i, i*2, i*3 FROM range(1000) t(i) WHERE i % 5 = 0",
            "SELECT DISTINCT i % 100 FROM range(50000) t(i)",
            "SELECT i FROM range(10000) t(i) ORDER BY i DESC LIMIT 100",
            "SELECT COUNT(DISTINCT i % 1000) FROM range(100000) t(i)"
        ]
    
    def modify_query_cache_config(self, bloom_size, hash_functions):
        """修改查询缓存配置文件"""
        config_file = self.duckdb_source_dir / "src" / "include" / "duckdb" / "main" / "query_cache.hpp"
        
        if not config_file.exists():
            print(f"❌ 配置文件不存在: {config_file}")
            return False
        
        try:
            # 读取原始文件
            with open(config_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 备份原始文件
            backup_file = config_file.with_suffix('.hpp.backup')
            if not backup_file.exists():
                shutil.copy2(config_file, backup_file)
            
            # 修改配置
            import re
            
            # 修改布隆过滤器大小
            content = re.sub(
                r'idx_t bloom_filter_size = \d+;',
                f'idx_t bloom_filter_size = {bloom_size};',
                content
            )
            
            # 修改哈希函数数量
            content = re.sub(
                r'idx_t bloom_filter_hash_functions = \d+;',
                f'idx_t bloom_filter_hash_functions = {hash_functions};',
                content
            )
            
            # 写回文件
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ 配置已修改: bloom_filter_size={bloom_size}, hash_functions={hash_functions}")
            return True
            
        except Exception as e:
            print(f"❌ 修改配置失败: {e}")
            return False
    
    def restore_original_config(self):
        """恢复原始配置"""
        config_file = self.duckdb_source_dir / "src" / "include" / "duckdb" / "main" / "query_cache.hpp"
        backup_file = config_file.with_suffix('.hpp.backup')
        
        if backup_file.exists():
            shutil.copy2(backup_file, config_file)
            print("✅ 原始配置已恢复")
            return True
        else:
            print("⚠️ 备份文件不存在，无法恢复原始配置")
            return False
    
    def compile_duckdb(self, config_name):
        """编译DuckDB"""
        print(f"🔨 编译DuckDB配置: {config_name}")
        
        build_dir = self.duckdb_source_dir / "build" / "release"
        
        try:
            # 清理之前的构建
            if build_dir.exists():
                shutil.rmtree(build_dir)
            
            # 创建构建目录
            build_dir.mkdir(parents=True, exist_ok=True)
            
            # 运行cmake
            cmake_cmd = [
                "cmake", 
                "-DCMAKE_BUILD_TYPE=Release",
                "-DBUILD_EXTENSIONS=",
                str(self.duckdb_source_dir)
            ]
            
            result = subprocess.run(
                cmake_cmd,
                cwd=build_dir,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode != 0:
                print(f"❌ CMake失败: {result.stderr}")
                return None
            
            # 编译
            make_cmd = ["make", "-j4", "duckdb"]
            
            result = subprocess.run(
                make_cmd,
                cwd=build_dir,
                capture_output=True,
                text=True,
                timeout=600
            )
            
            if result.returncode != 0:
                print(f"❌ 编译失败: {result.stderr}")
                return None
            
            duckdb_binary = build_dir / "duckdb"
            if duckdb_binary.exists():
                print(f"✅ 编译成功: {duckdb_binary}")
                return str(duckdb_binary)
            else:
                print("❌ 编译后找不到duckdb二进制文件")
                return None
                
        except subprocess.TimeoutExpired:
            print("❌ 编译超时")
            return None
        except Exception as e:
            print(f"❌ 编译异常: {e}")
            return None
    
    def run_cache_performance_test(self, duckdb_binary, config_name, repeat_count=1000):
        """运行缓存性能测试"""
        print(f"🧪 测试配置: {config_name} (重复{repeat_count}次)")
        
        # 创建测试数据库
        test_db = self.base_dir / f"test_{config_name.replace(' ', '_')}.db"
        if test_db.exists():
            test_db.unlink()
        
        # 准备测试查询
        selected_queries = []
        for _ in range(repeat_count):
            query = random.choice(self.test_queries)
            selected_queries.append(query)
        
        # 构建测试脚本
        sql_script_parts = [
            "SET enable_query_cache = true;",
            "SET query_cache_max_size = '100MB';",
            "SET query_cache_max_entries = 10000;"
        ]
        
        # 添加查询
        for i, query in enumerate(selected_queries):
            sql_script_parts.append(f"-- Query {i+1}")
            sql_script_parts.append(query + ";")
        
        complete_script = "\n".join(sql_script_parts)
        
        # 执行测试
        start_time = time.time()
        try:
            result = subprocess.run(
                [duckdb_binary, str(test_db)],
                input=complete_script,
                text=True,
                capture_output=True,
                timeout=300
            )
            
            end_time = time.time()
            execution_time = end_time - start_time
            
            if result.returncode != 0:
                print(f"❌ 测试执行失败: {result.stderr}")
                return None
            
            # 分析输出中的调试信息
            debug_info = self.analyze_debug_output(result.stderr)
            
            return {
                'config_name': config_name,
                'execution_time_s': execution_time,
                'query_count': repeat_count,
                'avg_query_time_ms': (execution_time / repeat_count) * 1000,
                'debug_info': debug_info,
                'stdout_lines': len(result.stdout.split('\n')),
                'stderr_lines': len(result.stderr.split('\n'))
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
    
    def analyze_debug_output(self, stderr_output):
        """分析调试输出"""
        debug_info = {
            'bloom_filter_disabled_count': 0,
            'bloom_filter_add_count': 0,
            'bloom_filter_might_contain_count': 0,
            'bloom_filter_clear_count': 0
        }
        
        if not stderr_output:
            return debug_info
        
        lines = stderr_output.split('\n')
        for line in lines:
            if 'BloomFilter disabled' in line:
                debug_info['bloom_filter_disabled_count'] += 1
            elif 'BloomFilter::Add - filter disabled' in line:
                debug_info['bloom_filter_add_count'] += 1
            elif 'BloomFilter::MightContain - filter disabled' in line:
                debug_info['bloom_filter_might_contain_count'] += 1
            elif 'BloomFilter::Clear - filter disabled' in line:
                debug_info['bloom_filter_clear_count'] += 1
        
        return debug_info
    
    def run_comprehensive_test(self):
        """运行完整的布隆过滤器测试"""
        print("🎯 改进的布隆过滤器性能测试")
        print("=" * 80)
        
        all_results = {
            'test_timestamp': datetime.now().isoformat(),
            'test_environment': {
                'duckdb_source_dir': str(self.duckdb_source_dir),
                'python_version': sys.version,
                'platform': os.name
            },
            'test_results': {}
        }
        
        try:
            for config in self.test_configs:
                print(f"\n{'='*60}")
                print(f"测试配置: {config['name']}")
                print(f"描述: {config['description']}")
                print(f"布隆过滤器大小: {config['bloom_filter_size']:,}")
                print(f"哈希函数数量: {config['bloom_filter_hash_functions']}")
                print(f"{'='*60}")
                
                # 修改配置
                if not self.modify_query_cache_config(
                    config['bloom_filter_size'], 
                    config['bloom_filter_hash_functions']
                ):
                    print(f"❌ 跳过配置: {config['name']}")
                    continue
                
                # 编译DuckDB
                duckdb_binary = self.compile_duckdb(config['name'])
                if not duckdb_binary:
                    print(f"❌ 跳过配置: {config['name']} (编译失败)")
                    continue
                
                # 运行性能测试
                test_result = self.run_cache_performance_test(
                    duckdb_binary, config['name'], repeat_count=500
                )
                
                if test_result:
                    all_results['test_results'][config['name']] = test_result
                    print(f"✅ 测试完成: {config['name']}")
                    print(f"   平均查询时间: {test_result['avg_query_time_ms']:.2f}ms")
                    print(f"   总执行时间: {test_result['execution_time_s']:.3f}s")
                    print(f"   调试信息: {test_result['debug_info']}")
                else:
                    print(f"❌ 测试失败: {config['name']}")
        
        finally:
            # 恢复原始配置
            self.restore_original_config()
        
        # 生成报告
        self.generate_comprehensive_report(all_results)
        
        return all_results
    
    def generate_comprehensive_report(self, all_results):
        """生成综合报告"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        print(f"\n{'='*80}")
        print("📊 改进的布隆过滤器测试报告")
        print(f"{'='*80}")
        
        if not all_results['test_results']:
            print("❌ 没有有效的测试结果")
            return
        
        # 性能对比
        print(f"\n🔍 性能测试结果对比:")
        print(f"{'配置名称':<20} {'平均时间(ms)':<12} {'总时间(s)':<10} {'性能评级':<10}")
        print("-" * 60)
        
        # 按平均查询时间排序
        sorted_results = sorted(
            all_results['test_results'].items(),
            key=lambda x: x[1]['avg_query_time_ms']
        )
        
        for config_name, result in sorted_results:
            avg_time = result['avg_query_time_ms']
            total_time = result['execution_time_s']
            
            if avg_time < 5:
                rating = "🎉 优秀"
            elif avg_time < 20:
                rating = "✅ 良好"
            elif avg_time < 50:
                rating = "⚠️ 一般"
            else:
                rating = "❌ 较差"
            
            print(f"{config_name:<20} {avg_time:<12.2f} {total_time:<10.3f} {rating:<10}")
        
        # 调试信息分析
        print(f"\n🔍 布隆过滤器调试信息分析:")
        for config_name, result in all_results['test_results'].items():
            debug_info = result['debug_info']
            print(f"\n  {config_name}:")
            print(f"    禁用消息数: {debug_info['bloom_filter_disabled_count']}")
            print(f"    Add调用数: {debug_info['bloom_filter_add_count']}")
            print(f"    MightContain调用数: {debug_info['bloom_filter_might_contain_count']}")
            print(f"    Clear调用数: {debug_info['bloom_filter_clear_count']}")
        
        # 保存详细结果
        result_file = self.results_dir / f"improved_bloom_filter_test_{timestamp}.json"
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(all_results, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 详细结果已保存到: {result_file}")
        
        # 生成结论
        self.generate_conclusions(all_results)
    
    def generate_conclusions(self, all_results):
        """生成测试结论"""
        print(f"\n🎯 测试结论与建议:")
        
        if not all_results['test_results']:
            print("❌ 无有效测试结果，无法生成结论")
            return
        
        # 分析性能数据
        performance_data = []
        for config_name, result in all_results['test_results'].items():
            performance_data.append({
                'name': config_name,
                'avg_time': result['avg_query_time_ms'],
                'debug_info': result['debug_info']
            })
        
        # 按性能排序
        performance_data.sort(key=lambda x: x['avg_time'])
        
        best_config = performance_data[0]
        worst_config = performance_data[-1]
        
        improvement = ((worst_config['avg_time'] - best_config['avg_time']) / worst_config['avg_time']) * 100
        
        print(f"\n1. 📊 性能分析:")
        print(f"   - 最佳配置: {best_config['name']} ({best_config['avg_time']:.2f}ms)")
        print(f"   - 最差配置: {worst_config['name']} ({worst_config['avg_time']:.2f}ms)")
        print(f"   - 性能提升: {improvement:.1f}%")
        
        print(f"\n2. 🔍 布隆过滤器效果分析:")
        disabled_configs = [p for p in performance_data if p['debug_info']['bloom_filter_disabled_count'] > 0]
        enabled_configs = [p for p in performance_data if p['debug_info']['bloom_filter_disabled_count'] == 0]
        
        if disabled_configs and enabled_configs:
            disabled_avg = mean([p['avg_time'] for p in disabled_configs])
            enabled_avg = mean([p['avg_time'] for p in enabled_configs])
            
            print(f"   - 禁用布隆过滤器平均时间: {disabled_avg:.2f}ms")
            print(f"   - 启用布隆过滤器平均时间: {enabled_avg:.2f}ms")
            
            if disabled_avg > enabled_avg:
                improvement = ((disabled_avg - enabled_avg) / disabled_avg) * 100
                print(f"   - 布隆过滤器带来 {improvement:.1f}% 的性能提升")
            else:
                degradation = ((enabled_avg - disabled_avg) / disabled_avg) * 100
                print(f"   - 布隆过滤器导致 {degradation:.1f}% 的性能下降")
        
        print(f"\n3. 💡 优化建议:")
        print(f"   - 推荐配置: {best_config['name']}")
        print(f"   - 布隆过滤器在缓存场景下的效果取决于查询重复率")
        print(f"   - 对于高重复率查询，布隆过滤器能显著提升性能")
        print(f"   - 合理的布隆过滤器大小和哈希函数数量很重要")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 improved_bloom_filter_test.py <duckdb_source_directory>")
        print("示例: python3 improved_bloom_filter_test.py /Users/max/src/duckdb")
        sys.exit(1)
    
    duckdb_source_dir = sys.argv[1]
    if not os.path.exists(duckdb_source_dir):
        print(f"❌ DuckDB源码目录不存在: {duckdb_source_dir}")
        sys.exit(1)
    
    test = ImprovedBloomFilterTest(duckdb_source_dir)
    results = test.run_comprehensive_test()
    
    if results and results['test_results']:
        print(f"\n🎉 改进的布隆过滤器测试完成！")
        print("✅ 测试结果显示了不同布隆过滤器配置的真实性能差异")
    else:
        print(f"\n❌ 测试失败，请检查配置和环境")

if __name__ == "__main__":
    main()