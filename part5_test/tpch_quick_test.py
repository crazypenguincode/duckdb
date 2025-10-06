#!/usr/bin/env python3
"""
TPC-H缓存性能快速测试脚本
只测试Q01查询，快速验证缓存功能
"""

import subprocess
import time
import json
import os
from datetime import datetime

# 配置路径
DUCKDB_EXECUTABLE = "/Users/max/src/duckdb/build/release/duckdb"
DATABASE_PATH = "/Users/max/test/tpc/tpch-sf1.db"
QUERIES_DIR = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"

def run_single_query(sql_content, use_cache=True, timeout=30):
    """执行单个查询"""
    try:
        # 构建完整的SQL命令
        cache_setting = "PRAGMA enable_query_cache=true;" if use_cache else "PRAGMA enable_query_cache=false;"
        full_sql = f"{cache_setting}\n{sql_content}"
        
        # 执行查询
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", full_sql],
            capture_output=True,
            text=True,
            timeout=timeout
        )
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        return {
            "success": result.returncode == 0,
            "execution_time": execution_time,
            "output_lines": len(result.stdout.split('\n')) if result.stdout else 0,
            "error": result.stderr if result.returncode != 0 else None
        }
            
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": f"查询超时 ({timeout}秒)",
            "execution_time": timeout
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "execution_time": 0
        }

def main():
    """主函数"""
    print("🚀 TPC-H缓存性能快速测试...")
    
    # 检查环境
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"❌ DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return
    
    if not os.path.exists(DATABASE_PATH):
        print(f"❌ 数据库文件不存在: {DATABASE_PATH}")
        return
    
    # 读取Q01查询
    q01_path = os.path.join(QUERIES_DIR, "q01.sql")
    if not os.path.exists(q01_path):
        print(f"❌ 查询文件不存在: {q01_path}")
        return
    
    with open(q01_path, 'r', encoding='utf-8') as f:
        q01_sql = f.read().strip()
    
    print(f"📊 测试查询: Q01")
    print(f"SQL内容预览: {q01_sql[:100]}...")
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "query": "q01.sql"
        },
        "results": {}
    }
    
    # 测试无缓存 - 2次运行
    print("\n🔄 无缓存测试...")
    no_cache_results = []
    for i in range(2):
        print(f"  运行 {i+1}/2...")
        result = run_single_query(q01_sql, use_cache=False, timeout=30)
        no_cache_results.append(result)
        
        if result["success"]:
            print(f"    ✅ 执行时间: {result['execution_time']:.3f}s, 输出行数: {result['output_lines']}")
        else:
            print(f"    ❌ 失败: {result['error']}")
    
    # 测试有缓存 - 2次运行
    print("\n🔄 有缓存测试...")
    with_cache_results = []
    for i in range(2):
        print(f"  运行 {i+1}/2...")
        result = run_single_query(q01_sql, use_cache=True, timeout=30)
        with_cache_results.append(result)
        
        if result["success"]:
            print(f"    ✅ 执行时间: {result['execution_time']:.3f}s, 输出行数: {result['output_lines']}")
        else:
            print(f"    ❌ 失败: {result['error']}")
    
    results["results"]["q01"] = {
        "no_cache": no_cache_results,
        "with_cache": with_cache_results
    }
    
    # 计算平均时间
    no_cache_times = [r["execution_time"] for r in no_cache_results if r["success"]]
    with_cache_times = [r["execution_time"] for r in with_cache_results if r["success"]]
    
    print("\n📈 测试结果汇总:")
    if no_cache_times:
        avg_no_cache = sum(no_cache_times) / len(no_cache_times)
        print(f"  无缓存平均时间: {avg_no_cache:.3f}s")
    else:
        print("  无缓存测试全部失败")
        avg_no_cache = 0
    
    if with_cache_times:
        avg_with_cache = sum(with_cache_times) / len(with_cache_times)
        print(f"  有缓存平均时间: {avg_with_cache:.3f}s")
    else:
        print("  有缓存测试全部失败")
        avg_with_cache = 0
    
    if avg_no_cache > 0 and avg_with_cache > 0:
        improvement = ((avg_no_cache - avg_with_cache) / avg_no_cache * 100)
        print(f"  性能提升: {improvement:.1f}%")
        
        if improvement > 0:
            print("  ✅ 缓存有效果！")
        else:
            print("  ⚠️ 缓存效果不明显")
    
    # 保存结果
    results_file = "tpch_quick_test_results.json"
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 测试完成，结果保存到: {results_file}")
    
    # 生成简单的Mermaid图表
    if avg_no_cache > 0 and avg_with_cache > 0:
        chart_content = f"""# TPC-H Q01缓存性能测试结果

## 测试时间
{results["test_info"]["timestamp"]}

## 性能对比
```mermaid
xychart-beta
    title "Q01查询缓存性能对比"
    x-axis ["Q01"]
    y-axis "执行时间(秒)" 0 --> {max(avg_no_cache, avg_with_cache) * 1.2:.3f}
    bar "无缓存" [{avg_no_cache:.3f}]
    bar "有缓存" [{avg_with_cache:.3f}]
```

## 测试结果
- 无缓存平均时间: {avg_no_cache:.3f}秒
- 有缓存平均时间: {avg_with_cache:.3f}秒
- 性能提升: {improvement:.1f}%
"""
        
        with open("tpch_quick_chart.md", 'w', encoding='utf-8') as f:
            f.write(chart_content)
        
        print("📊 图表文件: tpch_quick_chart.md")

if __name__ == "__main__":
    main()