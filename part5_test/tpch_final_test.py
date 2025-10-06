#!/usr/bin/env python3
"""
TPC-H 缓存性能测试 - 最终版本
专门为TPC-H查询设计的缓存性能对比测试
"""

import os
import sys
import time
import subprocess
import json
from datetime import datetime

def run_tpch_cache_test():
    """运行TPC-H缓存性能测试"""
    print("🚀 TPC-H 缓存性能测试")
    print("=" * 60)
    
    # 环境配置
    duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 检查环境
    if not os.path.exists(duckdb_exe):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_exe}")
        return
    
    if not os.path.exists(db_path):
        print(f"❌ 数据库文件不存在: {db_path}")
        return
        
    if not os.path.exists(queries_dir):
        print(f"❌ 查询目录不存在: {queries_dir}")
        return
    
    print("✅ 环境检查通过")
    
    # 获取所有TPC-H查询文件
    query_files = []
    for i in range(1, 23):  # TPC-H 有22个查询
        query_file = os.path.join(queries_dir, f"q{i:02d}.sql")
        if os.path.exists(query_file):
            query_files.append((query_file, f"q{i:02d}"))
    
    print(f"📋 找到 {len(query_files)} 个TPC-H查询")
    
    results = []
    
    for query_file, query_name in query_files[:5]:  # 先测试前5个
        print(f"\n🔍 测试 {query_name}...")
        
        try:
            # 读取查询内容
            with open(query_file, 'r') as f:
                query_content = f.read().strip()
            
            # 测试无缓存 (单次执行)
            no_cache_query = f"SET enable_query_cache=false;\n{query_content}"
            
            start_time = time.time()
            result = subprocess.run(
                [duckdb_exe, db_path],
                input=no_cache_query,
                text=True,
                capture_output=True,
                timeout=30
            )
            no_cache_time = time.time() - start_time
            
            if result.returncode != 0:
                print(f"  ❌ 无缓存查询失败: {result.stderr[:100]}")
                continue
                
            # 测试有缓存 (先执行一次预热，再测试)
            cache_query = f"SET enable_query_cache=true;\n{query_content}"
            
            # 预热缓存
            subprocess.run(
                [duckdb_exe, db_path],
                input=cache_query,
                text=True,
                capture_output=True,
                timeout=30
            )
            
            # 测试缓存性能
            start_time = time.time()
            result = subprocess.run(
                [duckdb_exe, db_path],
                input=cache_query,
                text=True,
                capture_output=True,
                timeout=30
            )
            cache_time = time.time() - start_time
            
            if result.returncode != 0:
                print(f"  ❌ 缓存查询失败: {result.stderr[:100]}")
                continue
            
            # 计算性能提升
            improvement = (no_cache_time - cache_time) / no_cache_time * 100
            speedup = no_cache_time / cache_time if cache_time > 0 else 0
            
            result_data = {
                'query': query_name,
                'no_cache_time': round(no_cache_time, 3),
                'cache_time': round(cache_time, 3),
                'improvement_percent': round(improvement, 1),
                'speedup': round(speedup, 2)
            }
            
            results.append(result_data)
            
            print(f"  ⏱️  无缓存: {no_cache_time:.3f}s")
            print(f"  ⚡ 有缓存: {cache_time:.3f}s")
            print(f"  📈 提升: {improvement:.1f}% ({speedup:.2f}x)")
            
        except subprocess.TimeoutExpired:
            print(f"  ⏰ {query_name} 查询超时")
        except Exception as e:
            print(f"  ❌ {query_name} 执行错误: {str(e)}")
    
    # 生成报告
    if results:
        print(f"\n{'='*60}")
        print("📊 TPC-H 缓存性能测试报告")
        print(f"{'='*60}")
        
        total_queries = len(results)
        avg_improvement = sum(r['improvement_percent'] for r in results) / total_queries
        avg_speedup = sum(r['speedup'] for r in results) / total_queries
        
        print(f"成功测试查询数量: {total_queries}")
        print(f"平均性能提升: {avg_improvement:.1f}%")
        print(f"平均加速比: {avg_speedup:.2f}x")
        
        print(f"\n详细结果:")
        for result in results:
            print(f"  {result['query']}: {result['no_cache_time']}s → {result['cache_time']}s "
                  f"({result['improvement_percent']}%, {result['speedup']}x)")
        
        # 保存结果到JSON
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        result_file = f"tpch_cache_test_results_{timestamp}.json"
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': timestamp,
                'summary': {
                    'total_queries': total_queries,
                    'avg_improvement_percent': avg_improvement,
                    'avg_speedup': avg_speedup
                },
                'results': results
            }, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 详细结果已保存到: {result_file}")
        
        # 生成简单的Mermaid图表
        mermaid_chart = generate_mermaid_chart(results)
        chart_file = f"tpch_cache_chart_{timestamp}.md"
        
        with open(chart_file, 'w', encoding='utf-8') as f:
            f.write(f"# TPC-H 缓存性能测试结果\n\n")
            f.write(f"测试时间: {timestamp}\n\n")
            f.write(mermaid_chart)
        
        print(f"📊 Mermaid图表已保存到: {chart_file}")
        
    else:
        print("❌ 没有成功的测试结果")

def generate_mermaid_chart(results):
    """生成Mermaid柱状图"""
    chart = """## 性能对比柱状图

```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比"
    x-axis ["""
    
    # 添加查询名称
    query_names = [r['query'] for r in results]
    chart += ", ".join(f'"{name}"' for name in query_names)
    chart += "]\n    y-axis \"执行时间(秒)\" 0 --> "
    
    # 计算最大时间用于Y轴范围
    max_time = max(max(r['no_cache_time'], r['cache_time']) for r in results)
    chart += f"{max_time * 1.1:.1f}\n"
    
    # 添加数据系列
    no_cache_times = [r['no_cache_time'] for r in results]
    cache_times = [r['cache_time'] for r in results]
    
    chart += "    bar [" + ", ".join(f"{t}" for t in no_cache_times) + "]\n"
    chart += "    bar [" + ", ".join(f"{t}" for t in cache_times) + "]\n"
    chart += "```\n\n"
    
    # 添加性能提升折线图
    chart += """## 性能提升折线图

```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis ["""
    
    chart += ", ".join(f'"{name}"' for name in query_names)
    chart += "]\n    y-axis \"性能提升(%)\" 0 --> 100\n"
    
    improvements = [r['improvement_percent'] for r in results]
    chart += "    line [" + ", ".join(f"{imp}" for imp in improvements) + "]\n"
    chart += "```\n"
    
    return chart

if __name__ == "__main__":
    run_tpch_cache_test()