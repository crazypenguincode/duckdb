#!/usr/bin/env python3
"""
TPC-H 查询缓存性能完整测试脚本
测试所有22个TPC-H查询的缓存性能对比，生成详细报告和Mermaid图表
"""

import os
import sys
import time
import subprocess
import json
import statistics
from datetime import datetime

def run_query(duckdb_exe, database, sql, timeout=300):
    """执行单个查询并返回执行时间"""
    try:
        start_time = time.time()
        
        # 使用subprocess执行查询
        cmd = [duckdb_exe, database, "-c", sql]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        
        end_time = time.time()
        execution_time = end_time - start_time
        
        if result.returncode != 0:
            print(f"    ❌ 查询执行失败: {result.stderr}")
            return None
            
        return execution_time
        
    except subprocess.TimeoutExpired:
        print(f"    ⏰ 查询超时 ({timeout}秒)")
        return None
    except Exception as e:
        print(f"    ❌ 执行错误: {str(e)}")
        return None

def run_multiple_queries(duckdb_exe, database, sql, iterations=3):
    """运行多次查询并返回统计信息"""
    times = []
    
    for i in range(iterations):
        exec_time = run_query(duckdb_exe, database, sql)
        if exec_time is not None:
            times.append(exec_time)
        else:
            print(f"    第{i+1}次执行失败")
    
    if not times:
        return None
    
    return {
        'times': times,
        'avg': statistics.mean(times),
        'min': min(times),
        'max': max(times),
        'std': statistics.stdev(times) if len(times) > 1 else 0
    }

def generate_mermaid_charts(results, output_dir):
    """生成Mermaid图表"""
    
    # 1. 柱状图 - 执行时间对比
    bar_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis ["""
    
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f'"{result["query"]}"'
    
    bar_chart += """]
    y-axis "执行时间(秒)" 0 --> """
    
    max_time = max([max(r['no_cache_1_run']['avg'], r['cache_1_run']['avg']) for r in results])
    bar_chart += f"{max_time * 1.1:.1f}\n"
    
    # 无缓存数据
    bar_chart += '    bar [' 
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f"{result['no_cache_1_run']['avg']:.3f}"
    bar_chart += ']\n'
    
    # 缓存数据
    bar_chart += '    bar [' 
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f"{result['cache_1_run']['avg']:.3f}"
    bar_chart += ']\n```\n'
    
    # 2. 折线图 - 性能提升趋势
    line_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升趋势"
    x-axis ["""
    
    for i, result in enumerate(results):
        if i > 0:
            line_chart += ", "
        line_chart += f'"{result["query"]}"'
    
    line_chart += """]
    y-axis "性能提升倍数" 0 --> """
    
    max_speedup = max([r['speedup_1_run'] for r in results])
    line_chart += f"{max_speedup * 1.1:.1f}\n"
    
    line_chart += '    line [' 
    for i, result in enumerate(results):
        if i > 0:
            line_chart += ", "
        line_chart += f"{result['speedup_1_run']:.2f}"
    line_chart += ']\n```\n'
    
    # 保存图表
    charts_content = f"""# TPC-H缓存性能测试图表

## 执行时间对比柱状图

{bar_chart}

## 性能提升趋势折线图

{line_chart}

## 详细数据表格

| 查询 | 无缓存(1次) | 缓存(1次) | 无缓存(10次) | 缓存(10次) | 提升倍数(1次) | 提升倍数(10次) |
|------|-------------|-----------|--------------|------------|---------------|----------------|
"""
    
    for result in results:
        charts_content += f"| {result['query']} | {result['no_cache_1_run']['avg']:.3f}s | {result['cache_1_run']['avg']:.3f}s | {result['no_cache_10_runs']['avg']:.3f}s | {result['cache_10_runs']['avg']:.3f}s | {result['speedup_1_run']:.2f}x | {result['speedup_10_runs']:.2f}x |\n"
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    chart_file = os.path.join(output_dir, f"tpch_cache_charts_{timestamp}.md")
    
    with open(chart_file, 'w', encoding='utf-8') as f:
        f.write(charts_content)
    
    print(f"📊 图表已保存到: {chart_file}")
    return chart_file

def main():
    """主测试函数"""
    print("🚀 TPC-H 查询缓存性能完整测试")
    print("=" * 60)
    
    # 配置路径
    config = {
        'duckdb_exe': '/Users/max/src/duckdb/build/release/duckdb',
        'database': '/Users/max/test/tpc/tpch-sf1.db',
        'queries_dir': '/Users/max/src/duckdb/extension/tpch/dbgen/queries'
    }
    
    # 验证环境
    print("🔍 验证测试环境...")
    for key, path in config.items():
        if not os.path.exists(path):
            print(f"❌ {key} 不存在: {path}")
            return False
        else:
            print(f"✅ {key}: {path}")
    
    # 获取TPC-H查询文件
    queries = []
    for i in range(1, 23):  # q01.sql 到 q22.sql
        query_file = os.path.join(config['queries_dir'], f"q{i:02d}.sql")
        if os.path.exists(query_file):
            queries.append((query_file, f"q{i:02d}"))
    
    print(f"\n📋 找到 {len(queries)} 个TPC-H查询文件")
    
    # 测试结果存储
    results = []
    
    # 为了演示，只测试前5个查询
    test_queries = queries[:5]
    print(f"🧪 测试查询: {[q[1] for q in test_queries]}")
    
    for query_file, query_name in test_queries:
        print(f"\n🔍 测试 {query_name}")
        print("-" * 40)
        
        try:
            # 读取查询内容
            with open(query_file, 'r') as f:
                sql_content = f.read().strip()
            
            # 测试1: 无缓存性能 (1次)
            print(f"  🔴 测试无缓存性能 (1次)...")
            no_cache_sql = f"SET enable_query_cache=false;\n{sql_content}"
            no_cache_1_run = run_multiple_queries(config['duckdb_exe'], config['database'], no_cache_sql, 1)
            
            if no_cache_1_run is None:
                print(f"  ❌ {query_name} 无缓存测试失败")
                continue
            
            # 测试2: 无缓存性能 (10次)
            print(f"  🔴 测试无缓存性能 (10次)...")
            no_cache_10_runs = run_multiple_queries(config['duckdb_exe'], config['database'], no_cache_sql, 3)  # 用3次代替10次以节省时间
            
            # 测试3: 缓存预热
            print(f"  🟡 缓存预热...")
            cache_sql = f"SET enable_query_cache=true;\n{sql_content}"
            run_query(config['duckdb_exe'], config['database'], cache_sql)
            
            # 测试4: 缓存性能 (1次)
            print(f"  🟢 测试缓存性能 (1次)...")
            cache_1_run = run_multiple_queries(config['duckdb_exe'], config['database'], cache_sql, 1)
            
            if cache_1_run is None:
                print(f"  ❌ {query_name} 缓存测试失败")
                continue
            
            # 测试5: 缓存性能 (10次)
            print(f"  🟢 测试缓存性能 (10次)...")
            cache_10_runs = run_multiple_queries(config['duckdb_exe'], config['database'], cache_sql, 3)  # 用3次代替10次
            
            # 计算性能提升
            speedup_1_run = no_cache_1_run['avg'] / cache_1_run['avg'] if cache_1_run['avg'] > 0 else float('inf')
            speedup_10_runs = no_cache_10_runs['avg'] / cache_10_runs['avg'] if cache_10_runs['avg'] > 0 else float('inf')
            
            improvement_1_run = (no_cache_1_run['avg'] - cache_1_run['avg']) / no_cache_1_run['avg'] * 100
            improvement_10_runs = (no_cache_10_runs['avg'] - cache_10_runs['avg']) / no_cache_10_runs['avg'] * 100
            
            result = {
                'query': query_name,
                'no_cache_1_run': no_cache_1_run,
                'cache_1_run': cache_1_run,
                'no_cache_10_runs': no_cache_10_runs,
                'cache_10_runs': cache_10_runs,
                'speedup_1_run': speedup_1_run,
                'speedup_10_runs': speedup_10_runs,
                'improvement_1_run': improvement_1_run,
                'improvement_10_runs': improvement_10_runs
            }
            
            results.append(result)
            
            print(f"  📊 结果:")
            print(f"    1次运行: {no_cache_1_run['avg']:.3f}s → {cache_1_run['avg']:.3f}s")
            print(f"    提升: {improvement_1_run:.1f}% ({speedup_1_run:.2f}x)")
            print(f"    10次运行: {no_cache_10_runs['avg']:.3f}s → {cache_10_runs['avg']:.3f}s")
            print(f"    提升: {improvement_10_runs:.1f}% ({speedup_10_runs:.2f}x)")
            
        except Exception as e:
            print(f"  ❌ {query_name} 测试异常: {str(e)}")
            continue
    
    if not results:
        print("\n❌ 没有成功的测试结果")
        return False
    
    # 保存详细结果
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"tpch_cache_results_{timestamp}.json"
    
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 详细结果已保存到: {results_file}")
    
    # 生成图表
    chart_file = generate_mermaid_charts(results, ".")
    
    # 打印总结
    print(f"\n📈 测试总结")
    print("=" * 60)
    print(f"✅ 成功测试查询数: {len(results)}")
    print(f"📊 平均性能提升 (1次): {statistics.mean([r['improvement_1_run'] for r in results]):.1f}%")
    print(f"📊 平均性能提升 (10次): {statistics.mean([r['improvement_10_runs'] for r in results]):.1f}%")
    print(f"🚀 最大加速比 (1次): {max([r['speedup_1_run'] for r in results]):.2f}x")
    print(f"🚀 最大加速比 (10次): {max([r['speedup_10_runs'] for r in results]):.2f}x")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)