#!/usr/bin/env python3
"""
TPC-H 查询缓存性能测试脚本 - 最终版本
测试TPC-H查询的缓存性能对比，生成Mermaid图表
"""

import os
import sys
import time
import subprocess
import json
import statistics
from datetime import datetime

def check_environment():
    """检查测试环境"""
    config = {
        'duckdb_exe': '/Users/max/src/duckdb/build/release/duckdb',
        'database': '/Users/max/test/tpc/tpch-sf1.db',
        'queries_dir': '/Users/max/src/duckdb/extension/tpch/dbgen/queries'
    }
    
    print("🔍 环境检查:")
    for key, path in config.items():
        exists = os.path.exists(path)
        status = "✅" if exists else "❌"
        print(f"  {status} {key}: {path}")
        if not exists:
            return None
    
    # 检查查询文件
    query_count = 0
    for i in range(1, 23):
        query_file = os.path.join(config['queries_dir'], f"q{i:02d}.sql")
        if os.path.exists(query_file):
            query_count += 1
    
    print(f"  ✅ 找到 {query_count}/22 个TPC-H查询文件")
    return config

def run_query(duckdb_exe, database, sql, timeout=60):
    """执行查询并返回执行时间"""
    try:
        start_time = time.time()
        cmd = [duckdb_exe, database, "-c", sql]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        end_time = time.time()
        
        if result.returncode != 0:
            return None
        
        return end_time - start_time
    except:
        return None

def test_query(config, query_name, sql_content):
    """测试单个查询的缓存性能"""
    print(f"  🧪 测试 {query_name}")
    
    # 无缓存测试
    no_cache_sql = f"SET enable_query_cache=false;\n{sql_content}"
    no_cache_time = run_query(config['duckdb_exe'], config['database'], no_cache_sql)
    
    if no_cache_time is None:
        print(f"    ❌ 无缓存测试失败")
        return None
    
    # 缓存预热
    cache_sql = f"SET enable_query_cache=true;\n{sql_content}"
    run_query(config['duckdb_exe'], config['database'], cache_sql)
    
    # 缓存测试
    cache_time = run_query(config['duckdb_exe'], config['database'], cache_sql)
    
    if cache_time is None:
        print(f"    ❌ 缓存测试失败")
        return None
    
    speedup = no_cache_time / cache_time if cache_time > 0 else float('inf')
    improvement = (no_cache_time - cache_time) / no_cache_time * 100
    
    result = {
        'query': query_name,
        'no_cache_time': no_cache_time,
        'cache_time': cache_time,
        'speedup': speedup,
        'improvement': improvement
    }
    
    print(f"    📊 无缓存: {no_cache_time:.3f}s, 缓存: {cache_time:.3f}s")
    print(f"    🚀 提升: {speedup:.2f}x ({improvement:.1f}%)")
    
    return result

def generate_mermaid_charts(results, output_file):
    """生成Mermaid图表"""
    if not results:
        return
    
    # 柱状图
    bar_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比"
    x-axis ["""
    
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f'"{result["query"]}"'
    
    bar_chart += """]
    y-axis "执行时间(秒)" 0 --> """
    
    max_time = max([max(r['no_cache_time'], r['cache_time']) for r in results])
    bar_chart += f"{max_time * 1.1:.1f}\n"
    
    # 无缓存数据
    bar_chart += '    bar [' 
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f"{result['no_cache_time']:.3f}"
    bar_chart += ']\n'
    
    # 缓存数据
    bar_chart += '    bar [' 
    for i, result in enumerate(results):
        if i > 0:
            bar_chart += ", "
        bar_chart += f"{result['cache_time']:.3f}"
    bar_chart += ']\n```\n\n'
    
    # 折线图
    line_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升倍数"
    x-axis ["""
    
    for i, result in enumerate(results):
        if i > 0:
            line_chart += ", "
        line_chart += f'"{result["query"]}"'
    
    line_chart += """]
    y-axis "性能提升倍数" 0 --> """
    
    max_speedup = max([r['speedup'] for r in results])
    line_chart += f"{max_speedup * 1.1:.1f}\n"
    
    line_chart += '    line [' 
    for i, result in enumerate(results):
        if i > 0:
            line_chart += ", "
        line_chart += f"{result['speedup']:.2f}"
    line_chart += ']\n```\n\n'
    
    # 生成完整报告
    content = f"""# TPC-H缓存性能测试报告

## 测试概述

测试时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
测试查询数: {len(results)}

## 执行时间对比柱状图

{bar_chart}

## 性能提升趋势折线图

{line_chart}

## 详细数据表格

| 查询 | 无缓存时间(s) | 缓存时间(s) | 提升倍数 | 提升百分比 |
|------|---------------|-------------|----------|------------|
"""
    
    for result in results:
        content += f"| {result['query']} | {result['no_cache_time']:.3f} | {result['cache_time']:.3f} | {result['speedup']:.2f}x | {result['improvement']:.1f}% |\n"
    
    avg_speedup = statistics.mean([r['speedup'] for r in results])
    avg_improvement = statistics.mean([r['improvement'] for r in results])
    
    content += f"""
## 测试总结

- 平均性能提升: {avg_speedup:.2f}x
- 平均提升百分比: {avg_improvement:.1f}%
- 最大提升倍数: {max([r['speedup'] for r in results]):.2f}x
- 测试通过率: {len(results)}/22
"""
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"📊 报告已生成: {output_file}")

def main():
    """主函数"""
    print("🚀 TPC-H 查询缓存性能测试")
    print("=" * 50)
    
    # 检查环境
    config = check_environment()
    if not config:
        print("❌ 环境检查失败")
        return False
    
    print("\n🧪 开始测试...")
    
    # 测试前5个查询作为示例
    test_queries = ['q01', 'q02', 'q03', 'q04', 'q05']
    results = []
    
    for query_name in test_queries:
        query_file = os.path.join(config['queries_dir'], f"{query_name}.sql")
        
        if not os.path.exists(query_file):
            print(f"  ⚠️  跳过 {query_name} (文件不存在)")
            continue
        
        try:
            with open(query_file, 'r') as f:
                sql_content = f.read().strip()
            
            result = test_query(config, query_name, sql_content)
            if result:
                results.append(result)
        except Exception as e:
            print(f"  ❌ {query_name} 测试异常: {str(e)}")
    
    if not results:
        print("\n❌ 没有成功的测试结果")
        return False
    
    # 生成报告
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"tpch_cache_results_{timestamp}.json"
    report_file = f"tpch_cache_report_{timestamp}.md"
    
    # 保存JSON结果
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    # 生成Mermaid报告
    generate_mermaid_charts(results, report_file)
    
    # 打印总结
    print(f"\n📈 测试完成")
    print("=" * 50)
    print(f"✅ 成功测试: {len(results)}/{len(test_queries)} 个查询")
    
    if results:
        avg_speedup = statistics.mean([r['speedup'] for r in results])
        avg_improvement = statistics.mean([r['improvement'] for r in results])
        print(f"📊 平均性能提升: {avg_speedup:.2f}x ({avg_improvement:.1f}%)")
        print(f"🚀 最大提升倍数: {max([r['speedup'] for r in results]):.2f}x")
    
    print(f"💾 结果文件: {results_file}")
    print(f"📊 报告文件: {report_file}")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)