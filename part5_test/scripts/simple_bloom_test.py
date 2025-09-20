#!/usr/bin/env python3
"""
简化的布隆过滤器测试脚本
用于验证布隆过滤器禁用功能是否正常工作
"""

import subprocess
import sys
import time
import json
import os
from datetime import datetime

def run_duckdb_query(duckdb_path, query, enable_cache=True, bloom_size=0):
    """运行DuckDB查询并返回执行时间"""
    try:
        # 构建命令
        cmd = [duckdb_path]
        
        # 设置缓存参数
        full_query = f"""
        SET enable_query_cache={str(enable_cache).lower()};
        SET query_cache_max_entries=1000;
        SET query_cache_max_memory='100MB';
        SET query_cache_bloom_filter_size={bloom_size};
        {query}
        """
        
        start_time = time.time()
        result = subprocess.run(
            cmd,
            input=full_query,
            text=True,
            capture_output=True,
            timeout=30
        )
        end_time = time.time()
        
        execution_time = (end_time - start_time) * 1000  # 转换为毫秒
        
        if result.returncode != 0:
            print(f"❌ 查询执行失败: {result.stderr}")
            return None
            
        return execution_time
        
    except subprocess.TimeoutExpired:
        print("❌ 查询超时")
        return None
    except Exception as e:
        print(f"❌ 执行查询时出错: {e}")
        return None

def test_bloom_filter_configurations(duckdb_path):
    """测试不同的布隆过滤器配置"""
    
    print("🎯 简化布隆过滤器测试")
    print("=" * 60)
    
    # 测试查询
    test_queries = [
        ("简单聚合", "SELECT COUNT(*), AVG(i), SUM(i*2) FROM generate_series(1, 10000) AS t(i) WHERE i % 3 = 0"),
        ("复杂查询", """
        WITH recursive_series AS (
            SELECT 1 as n, 1 as fib_current, 1 as fib_next
            UNION ALL
            SELECT n + 1, fib_next, fib_current + fib_next
            FROM recursive_series
            WHERE n < 20
        )
        SELECT n, fib_current FROM recursive_series ORDER BY n
        """),
        ("窗口函数", """
        SELECT 
            i,
            ROW_NUMBER() OVER (ORDER BY i) as row_num,
            LAG(i, 1) OVER (ORDER BY i) as prev_val,
            SUM(i) OVER (ORDER BY i ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_sum
        FROM generate_series(1, 1000) AS t(i)
        WHERE i % 10 = 0
        ORDER BY i
        """)
    ]
    
    # 测试配置
    configurations = [
        ("禁用布隆过滤器", 0, "完全禁用布隆过滤器"),
        ("小型布隆过滤器", 10000, "小型布隆过滤器，低内存占用"),
        ("标准布隆过滤器", 100000, "标准配置，平衡性能和内存"),
        ("大型布隆过滤器", 1000000, "大型布隆过滤器，低假阳性率")
    ]
    
    results = {}
    
    for config_name, bloom_size, description in configurations:
        print(f"\n📊 测试配置: {config_name}")
        print(f"   描述: {description}")
        print(f"   布隆过滤器大小: {bloom_size:,}")
        
        config_results = {}
        
        for query_name, query in test_queries:
            print(f"   🔍 测试查询: {query_name}")
            
            # 执行多次测试取平均值
            times = []
            for i in range(5):
                exec_time = run_duckdb_query(duckdb_path, query, True, bloom_size)
                if exec_time is not None:
                    times.append(exec_time)
                    print(f"      第{i+1}次: {exec_time:.2f}ms")
                else:
                    print(f"      第{i+1}次: 失败")
            
            if times:
                avg_time = sum(times) / len(times)
                config_results[query_name] = {
                    'times': times,
                    'avg_time': avg_time,
                    'min_time': min(times),
                    'max_time': max(times)
                }
                print(f"   ✅ 平均时间: {avg_time:.2f}ms")
            else:
                print(f"   ❌ 所有测试都失败")
                config_results[query_name] = None
        
        results[config_name] = {
            'bloom_size': bloom_size,
            'description': description,
            'query_results': config_results
        }
    
    return results

def analyze_results(results):
    """分析测试结果"""
    print("\n" + "=" * 60)
    print("📊 测试结果分析")
    print("=" * 60)
    
    # 计算每个查询的性能对比
    query_names = set()
    for config_results in results.values():
        if config_results['query_results']:
            query_names.update(config_results['query_results'].keys())
    
    for query_name in query_names:
        print(f"\n🔍 {query_name} 查询性能对比:")
        print("-" * 40)
        
        config_times = {}
        for config_name, config_data in results.items():
            if (config_data['query_results'] and 
                query_name in config_data['query_results'] and 
                config_data['query_results'][query_name]):
                avg_time = config_data['query_results'][query_name]['avg_time']
                config_times[config_name] = avg_time
                print(f"  {config_name:20s}: {avg_time:6.2f}ms")
        
        # 找出最快和最慢的配置
        if config_times:
            fastest_config = min(config_times, key=config_times.get)
            slowest_config = max(config_times, key=config_times.get)
            
            fastest_time = config_times[fastest_config]
            slowest_time = config_times[slowest_config]
            
            if fastest_time > 0:
                improvement = ((slowest_time - fastest_time) / slowest_time) * 100
                print(f"  🏆 最佳配置: {fastest_config} ({fastest_time:.2f}ms)")
                print(f"  📈 性能提升: {improvement:.1f}%")

def save_results(results, output_file):
    """保存测试结果到JSON文件"""
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'test_type': 'simple_bloom_filter_test',
                'results': results
            }, f, indent=2, ensure_ascii=False)
        print(f"\n💾 测试结果已保存到: {output_file}")
    except Exception as e:
        print(f"❌ 保存结果失败: {e}")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 simple_bloom_test.py <duckdb_path>")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    try:
        # 运行测试
        results = test_bloom_filter_configurations(duckdb_path)
        
        # 分析结果
        analyze_results(results)
        
        # 保存结果
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = f"/Users/max/src/duckdb/part5_test/results/simple_bloom_test_{timestamp}.json"
        save_results(results, output_file)
        
        print("\n🎉 简化布隆过滤器测试完成！")
        
    except KeyboardInterrupt:
        print("\n⚠️ 测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()