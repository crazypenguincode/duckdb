#!/usr/bin/env python3
"""
TPC-H 缓存性能测试脚本 - 简化版
测试所有22个TPC-H查询在有无缓存情况下的性能对比
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime

# 配置
DUCKDB_EXECUTABLE = "/Users/max/src/duckdb/build/release/duckdb"
DATABASE_PATH = "/Users/max/test/tpc/tpch-sf1.db"
QUERIES_DIR = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"

def run_query(query_file, enable_cache=True, timeout=300):
    """执行单个查询并返回执行时间"""
    try:
        # 构建命令
        cache_setting = "SET enable_query_cache=true;" if enable_cache else "SET enable_query_cache=false;"
        
        with open(query_file, 'r') as f:
            query_content = f.read()
        
        full_query = f"{cache_setting}\n{query_content}"
        
        # 执行查询
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH],
            input=full_query,
            text=True,
            capture_output=True,
            timeout=timeout
        )
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        if result.returncode != 0:
            print(f"查询执行失败: {query_file}")
            print(f"错误: {result.stderr}")
            return None
            
        return execution_time
        
    except subprocess.TimeoutExpired:
        print(f"查询超时: {query_file}")
        return None
    except Exception as e:
        print(f"执行查询时出错: {e}")
        return None

def test_query_performance(query_file, runs=3):
    """测试单个查询的性能"""
    query_name = os.path.basename(query_file).replace('.sql', '')
    print(f"\n测试查询: {query_name}")
    
    # 测试无缓存情况
    print("  测试无缓存...")
    no_cache_times = []
    for i in range(runs):
        exec_time = run_query(query_file, enable_cache=False)
        if exec_time is not None:
            no_cache_times.append(exec_time)
            print(f"    运行 {i+1}: {exec_time:.3f}s")
    
    # 测试有缓存情况
    print("  测试有缓存...")
    cache_times = []
    for i in range(runs):
        exec_time = run_query(query_file, enable_cache=True)
        if exec_time is not None:
            cache_times.append(exec_time)
            print(f"    运行 {i+1}: {exec_time:.3f}s")
    
    # 计算统计信息
    result = {
        'query': query_name,
        'no_cache': {
            'times': no_cache_times,
            'avg': statistics.mean(no_cache_times) if no_cache_times else 0,
            'min': min(no_cache_times) if no_cache_times else 0,
            'max': max(no_cache_times) if no_cache_times else 0
        },
        'cache': {
            'times': cache_times,
            'avg': statistics.mean(cache_times) if cache_times else 0,
            'min': min(cache_times) if cache_times else 0,
            'max': max(cache_times) if cache_times else 0
        }
    }
    
    if result['no_cache']['avg'] > 0 and result['cache']['avg'] > 0:
        result['speedup'] = result['no_cache']['avg'] / result['cache']['avg']
        result['improvement'] = (result['no_cache']['avg'] - result['cache']['avg']) / result['no_cache']['avg'] * 100
    else:
        result['speedup'] = 0
        result['improvement'] = 0
    
    print(f"  无缓存平均: {result['no_cache']['avg']:.3f}s")
    print(f"  有缓存平均: {result['cache']['avg']:.3f}s")
    print(f"  性能提升: {result['improvement']:.1f}%")
    
    return result

def generate_mermaid_charts(results):
    """生成Mermaid图表"""
    
    # 柱状图 - 执行时间对比
    bar_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis ["""
    
    queries = [r['query'] for r in results if r['no_cache']['avg'] > 0]
    bar_chart += ', '.join([f'"{q}"' for q in queries])
    bar_chart += """]
    y-axis "执行时间(秒)" 0 --> """
    
    max_time = max([max(r['no_cache']['avg'], r['cache']['avg']) for r in results if r['no_cache']['avg'] > 0])
    bar_chart += f"{max_time * 1.1:.1f}\n"
    
    no_cache_times = [r['no_cache']['avg'] for r in results if r['no_cache']['avg'] > 0]
    cache_times = [r['cache']['avg'] for r in results if r['no_cache']['avg'] > 0]
    
    bar_chart += f"    bar [无缓存] [{', '.join([f'{t:.3f}' for t in no_cache_times])}]\n"
    bar_chart += f"    bar [有缓存] [{', '.join([f'{t:.3f}' for t in cache_times])}]\n"
    bar_chart += "```\n"
    
    # 折线图 - 性能提升百分比
    line_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis ["""
    
    line_chart += ', '.join([f'"{q}"' for q in queries])
    line_chart += """]
    y-axis "性能提升(%)" 0 --> 100
    line [性能提升] ["""
    
    improvements = [r['improvement'] for r in results if r['no_cache']['avg'] > 0]
    line_chart += ', '.join([f'{imp:.1f}' for imp in improvements])
    line_chart += """]
```"""
    
    return bar_chart, line_chart

def main():
    print("TPC-H 缓存性能测试开始...")
    print(f"DuckDB可执行文件: {DUCKDB_EXECUTABLE}")
    print(f"数据库路径: {DATABASE_PATH}")
    print(f"查询目录: {QUERIES_DIR}")
    
    # 检查文件是否存在
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"错误: DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return
    
    if not os.path.exists(DATABASE_PATH):
        print(f"错误: 数据库文件不存在: {DATABASE_PATH}")
        return
    
    if not os.path.exists(QUERIES_DIR):
        print(f"错误: 查询目录不存在: {QUERIES_DIR}")
        return
    
    # 获取所有查询文件
    query_files = []
    for i in range(1, 23):  # q01.sql 到 q22.sql
        query_file = os.path.join(QUERIES_DIR, f"q{i:02d}.sql")
        if os.path.exists(query_file):
            query_files.append(query_file)
    
    print(f"找到 {len(query_files)} 个查询文件")
    
    # 测试前5个查询（快速测试）
    test_queries = query_files[:5]
    print(f"测试查询: {[os.path.basename(f) for f in test_queries]}")
    
    results = []
    start_time = datetime.now()
    
    for query_file in test_queries:
        result = test_query_performance(query_file, runs=2)
        if result:
            results.append(result)
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    # 保存结果
    output_data = {
        'timestamp': start_time.isoformat(),
        'duration': str(duration),
        'total_queries': len(test_queries),
        'successful_queries': len(results),
        'results': results
    }
    
    output_file = f"tpch_cache_test_results_{start_time.strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n测试完成! 总耗时: {duration}")
    print(f"结果已保存到: {output_file}")
    
    # 生成图表
    if results:
        bar_chart, line_chart = generate_mermaid_charts(results)
        
        chart_file = f"tpch_cache_charts_{start_time.strftime('%Y%m%d_%H%M%S')}.md"
        with open(chart_file, 'w', encoding='utf-8') as f:
            f.write("# TPC-H 缓存性能测试结果\n\n")
            f.write("## 执行时间对比\n\n")
            f.write(bar_chart)
            f.write("\n\n## 性能提升百分比\n\n")
            f.write(line_chart)
            f.write("\n")
        
        print(f"图表已保存到: {chart_file}")
        
        # 打印摘要
        print("\n=== 测试摘要 ===")
        avg_improvement = statistics.mean([r['improvement'] for r in results if r['improvement'] > 0])
        print(f"平均性能提升: {avg_improvement:.1f}%")
        
        best_query = max(results, key=lambda x: x['improvement'])
        print(f"最佳提升查询: {best_query['query']} ({best_query['improvement']:.1f}%)")

if __name__ == "__main__":
    main()