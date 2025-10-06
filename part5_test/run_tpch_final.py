#!/usr/bin/env python3
"""
TPC-H 缓存性能测试 - 最终版本
简化版本，专注于核心测试功能
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime

def run_query_test(duckdb_exe, db_path, query_file, enable_cache=True):
    """运行单个查询测试"""
    try:
        cache_setting = "SET enable_query_cache=true;" if enable_cache else "SET enable_query_cache=false; PRAGMA disable_optimizer;"
        
        with open(query_file, 'r') as f:
            query_content = f.read()
        
        full_query = f"{cache_setting}\n{query_content}"
        
        start_time = time.time()
        result = subprocess.run(
            [duckdb_exe, db_path],
            input=full_query,
            text=True,
            capture_output=True,
            timeout=120
        )
        end_time = time.time()
        
        if result.returncode != 0:
            print(f"    ❌ 查询失败: {result.stderr[:100]}...")
            return None
            
        return end_time - start_time
        
    except subprocess.TimeoutExpired:
        print(f"    ⏰ 查询超时")
        return None
    except Exception as e:
        print(f"    ❌ 执行错误: {str(e)[:50]}...")
        return None

def main():
    print("🚀 TPC-H 缓存性能测试 - 最终版本")
    print("=" * 50)
    
    # 配置路径
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
    
    # 获取查询文件（测试前5个查询）
    test_queries = []
    for i in range(1, 6):  # 测试前5个查询
        query_file = os.path.join(queries_dir, f"q{i:02d}.sql")
        if os.path.exists(query_file):
            test_queries.append(query_file)
    
    print(f"📋 将测试 {len(test_queries)} 个查询")
    
    results = []
    
    # 执行测试
    for i, query_file in enumerate(test_queries, 1):
        query_name = os.path.basename(query_file).replace('.sql', '')
        print(f"\n📊 测试查询 {i}/{len(test_queries)}: {query_name}")
        
        # 测试无缓存（1次）
        print("  🔄 无缓存测试...")
        no_cache_time = run_query_test(duckdb_exe, db_path, query_file, enable_cache=False)
        
        # 测试有缓存（1次）
        print("  ⚡ 有缓存测试...")
        cache_time = run_query_test(duckdb_exe, db_path, query_file, enable_cache=True)
        
        if no_cache_time and cache_time:
            improvement = (no_cache_time - cache_time) / no_cache_time * 100
            speedup = no_cache_time / cache_time
            
            result = {
                'query': query_name,
                'no_cache_time': no_cache_time,
                'cache_time': cache_time,
                'improvement': improvement,
                'speedup': speedup
            }
            results.append(result)
            
            print(f"  📈 无缓存: {no_cache_time:.3f}s")
            print(f"  📈 有缓存: {cache_time:.3f}s")
            print(f"  📈 性能提升: {improvement:.1f}%")
            print(f"  📈 加速比: {speedup:.2f}x")
        else:
            print(f"  ❌ 测试失败")
    
    # 生成报告
    if results:
        print(f"\n{'='*50}")
        print("📊 测试总结:")
        
        avg_improvement = statistics.mean([r['improvement'] for r in results])
        avg_speedup = statistics.mean([r['speedup'] for r in results])
        
        print(f"  成功测试查询: {len(results)}")
        print(f"  平均性能提升: {avg_improvement:.1f}%")
        print(f"  平均加速比: {avg_speedup:.2f}x")
        
        # 生成Mermaid图表
        queries = [r['query'] for r in results]
        no_cache_times = [r['no_cache_time'] for r in results]
        cache_times = [r['cache_time'] for r in results]
        improvements = [r['improvement'] for r in results]
        
        mermaid_chart = f"""
# TPC-H 缓存性能测试结果

## 执行时间对比
```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "执行时间(秒)" 0 --> {max(max(no_cache_times), max(cache_times)) * 1.1:.1f}
    bar [无缓存] [{', '.join([f'{t:.3f}' for t in no_cache_times])}]
    bar [有缓存] [{', '.join([f'{t:.3f}' for t in cache_times])}]
```

## 性能提升百分比
```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "性能提升(%)" 0 --> {max(improvements) * 1.1:.0f}
    line [性能提升] [{', '.join([f'{imp:.1f}' for imp in improvements])}]
```

## 测试详细结果
"""
        
        for result in results:
            mermaid_chart += f"""
### {result['query']}
- 无缓存执行时间: {result['no_cache_time']:.3f}s
- 有缓存执行时间: {result['cache_time']:.3f}s
- 性能提升: {result['improvement']:.1f}%
- 加速比: {result['speedup']:.2f}x
"""
        
        # 保存结果
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # 保存JSON
        json_file = f"tpch_final_test_results_{timestamp}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'total_queries': len(results),
                'avg_improvement': avg_improvement,
                'avg_speedup': avg_speedup,
                'results': results
            }, f, indent=2, ensure_ascii=False)
        
        # 保存报告
        report_file = f"tpch_final_test_report_{timestamp}.md"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(mermaid_chart)
        
        print(f"\n📄 结果已保存:")
        print(f"  📊 JSON数据: {json_file}")
        print(f"  📋 报告文件: {report_file}")
        
    else:
        print("❌ 没有成功的测试结果")

if __name__ == "__main__":
    main()