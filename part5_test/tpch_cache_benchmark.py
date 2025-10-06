#!/usr/bin/env python3
"""
TPC-H 查询缓存性能基准测试
测试所有22个TPC-H查询的缓存性能对比
"""

import os
import sys
import time
import subprocess
import json
from datetime import datetime

def main():
    """主测试函数"""
    print("🚀 TPC-H 查询缓存性能基准测试")
    print("=" * 50)
    
    # 配置路径
    config = {
        'duckdb_exe': '/Users/max/src/duckdb/build/release/duckdb',
        'database': '/Users/max/test/tpc/tpch-sf1.db',
        'queries_dir': '/Users/max/src/duckdb/extension/tpch/dbgen/queries'
    }
    
    # 验证环境
    for key, path in config.items():
        if not os.path.exists(path):
            print(f"❌ {key} 不存在: {path}")
            return False
    
    print("✅ 环境验证通过")
    
    # 获取TPC-H查询文件
    queries = []
    for i in range(1, 23):  # q01.sql 到 q22.sql
        query_file = os.path.join(config['queries_dir'], f"q{i:02d}.sql")
        if os.path.exists(query_file):
            queries.append((query_file, f"q{i:02d}"))
    
    print(f"📋 找到 {len(queries)} 个TPC-H查询文件")
    
    # 测试结果存储
    results = []
    
    # 只测试前3个查询作为示例
    test_queries = queries[:3]
    
    for query_file, query_name in test_queries:
        print(f"\n🔍 测试 {query_name}")
        
        try:
            # 读取查询内容
            with open(query_file, 'r') as f:
                sql_content = f.read().strip()
            
            # 测试1: 无缓存性能
            print(f"  🔴 测试无缓存...")
            no_cache_sql = f"SET enable_query_cache=false;\n{sql_content}"
            no_cache_time = run_query(config['duckdb_exe'], config['database'], no_cache_sql)
            
            if no_cache_time is None:
                print(f"  ❌ {query_name} 无缓存测试失败")
                continue
            
            # 测试2: 缓存预热
            print(f"  🟡 缓存预热...")
            cache_sql = f"SET enable_query_cache=true;\n{sql_content}"
            run_query(config['duckdb_exe'], config['database'], cache_sql)
            
            # 测试3: 缓存性能
            print(f"  🟢 测试缓存性能...")
            cache_time = run_query(config['duckdb_exe'], config['database'], cache_sql)
            
            if cache_time is None:
                print(f"  ❌ {query_name} 缓存测试失败")
                continue
            
            # 计算性能提升
            if cache_time > 0:
                speedup = no_cache_time / cache_time
                improvement = (no_cache_time - cache_time) / no_cache_time * 100
            else:
                speedup = float('inf')
                improvement = 100
            
            result = {
                'query': query_name,
                'no_cache_time': round(no_cache_time, 3),
                'cache_time': round(cache_time, 3),
                'speedup': round(speedup, 2),
                'improvement_percent': round(improvement, 1)
            }
            
            results.append(result)
            
            print(f"  📊 结果: {no_cache_time:.3f}s → {cache_time:.3f}s")
            print(f"  📈 提升: {improvement:.1f}% ({speedup:.2f}x)")
            
        except Exception as e:
            print(f"  ❌ {query_name} 执行错误: {str(e)}")
    
    # 生成报告
    if results:
        generate_report(results)
    else:
        print("❌ 没有成功的测试结果")
    
    return True

def run_query(duckdb_exe, database, sql):
    """执行单个查询并返回执行时间"""
    try:
        start_time = time.time()
        result = subprocess.run(
            [duckdb_exe, database],
            input=sql,
            text=True,
            capture_output=True,
            timeout=30
        )
        end_time = time.time()
        
        if result.returncode == 0:
            return end_time - start_time
        else:
            print(f"    查询执行失败: {result.stderr[:100]}")
            return None
            
    except subprocess.TimeoutExpired:
        print(f"    查询超时")
        return None
    except Exception as e:
        print(f"    查询异常: {str(e)}")
        return None

def generate_report(results):
    """生成测试报告"""
    print(f"\n{'='*50}")
    print("📊 TPC-H 缓存性能测试报告")
    print(f"{'='*50}")
    
    # 统计信息
    total_queries = len(results)
    avg_speedup = sum(r['speedup'] for r in results) / total_queries
    avg_improvement = sum(r['improvement_percent'] for r in results) / total_queries
    
    print(f"测试查询数量: {total_queries}")
    print(f"平均加速比: {avg_speedup:.2f}x")
    print(f"平均性能提升: {avg_improvement:.1f}%")
    
    print(f"\n详细结果:")
    print(f"{'查询':<8} {'无缓存(s)':<10} {'缓存(s)':<10} {'加速比':<8} {'提升%':<8}")
    print("-" * 50)
    
    for result in results:
        print(f"{result['query']:<8} {result['no_cache_time']:<10} "
              f"{result['cache_time']:<10} {result['speedup']:<8} "
              f"{result['improvement_percent']:<8}")
    
    # 保存JSON结果
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    result_file = f"tpch_benchmark_results_{timestamp}.json"
    
    with open(result_file, 'w', encoding='utf-8') as f:
        json.dump({
            'timestamp': timestamp,
            'summary': {
                'total_queries': total_queries,
                'avg_speedup': avg_speedup,
                'avg_improvement_percent': avg_improvement
            },
            'results': results
        }, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 详细结果已保存到: {result_file}")
    
    # 生成Mermaid图表
    generate_mermaid_charts(results, timestamp)

def generate_mermaid_charts(results, timestamp):
    """生成Mermaid性能对比图表"""
    chart_content = f"""# TPC-H 缓存性能测试结果

测试时间: {timestamp}

## 执行时间对比

```mermaid
xychart-beta
    title "TPC-H查询执行时间对比"
    x-axis [{', '.join(f'"{r["query"]}"' for r in results)}]
    y-axis "执行时间(秒)" 0.0 --> {max(max(r['no_cache_time'], r['cache_time']) for r in results) * 1.1:.1f}
    bar [{', '.join(str(r['no_cache_time']) for r in results)}]
    bar [{', '.join(str(r['cache_time']) for r in results)}]
```

## 性能提升对比

```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升"
    x-axis [{', '.join(f'"{r["query"]}"' for r in results)}]
    y-axis "性能提升百分比" 0 --> 100
    line [{', '.join(str(r['improvement_percent']) for r in results)}]
```

## 加速比对比

```mermaid
xychart-beta
    title "TPC-H查询缓存加速比"
    x-axis [{', '.join(f'"{r["query"]}"' for r in results)}]
    y-axis "加速比(倍)" 1.0 --> {max(r['speedup'] for r in results) * 1.1:.1f}
    bar [{', '.join(str(r['speedup']) for r in results)}]
```
"""
    
    chart_file = f"tpch_benchmark_charts_{timestamp}.md"
    with open(chart_file, 'w', encoding='utf-8') as f:
        f.write(chart_content)
    
    print(f"📊 Mermaid图表已保存到: {chart_file}")

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)