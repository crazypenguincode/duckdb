#!/usr/bin/env python3
"""
TPC-H缓存性能测试脚本 - 简化版本
测试前5个TPC-H查询在有无缓存情况下的性能对比
"""

import subprocess
import time
import json
import os
import sys
from datetime import datetime

# 配置路径
DUCKDB_EXECUTABLE = "/Users/max/src/duckdb/build/release/duckdb"
DATABASE_PATH = "/Users/max/test/tpc/tpch-sf1.db"
QUERIES_DIR = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
RESULTS_FILE = "tpch_cache_results_simple.json"

def run_query(query_file, use_cache=True):
    """执行单个查询"""
    try:
        # 构建SQL命令
        cache_setting = "PRAGMA enable_query_cache=true;" if use_cache else "PRAGMA enable_query_cache=false;"
        sql_command = f"{cache_setting} .read {os.path.join(QUERIES_DIR, query_file)}"
        
        # 执行查询
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", sql_command],
            capture_output=True,
            text=True,
            timeout=60
        )
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        return {
            "success": result.returncode == 0,
            "execution_time": execution_time,
            "error": result.stderr if result.returncode != 0 else None
        }
            
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "execution_time": 0
        }

def main():
    """主函数"""
    print("🚀 TPC-H缓存性能测试开始...")
    
    # 检查环境
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"❌ DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return
    
    if not os.path.exists(DATABASE_PATH):
        print(f"❌ 数据库文件不存在: {DATABASE_PATH}")
        return
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "test_queries": ["q01.sql", "q02.sql", "q03.sql"]
        },
        "results": {}
    }
    
    # 测试前3个查询
    test_queries = ["q01.sql", "q02.sql", "q03.sql"]
    
    for query_file in test_queries:
        query_path = os.path.join(QUERIES_DIR, query_file)
        if not os.path.exists(query_path):
            print(f"❌ 查询文件不存在: {query_path}")
            continue
            
        print(f"\n📊 测试查询: {query_file}")
        query_name = query_file.replace('.sql', '')
        
        # 测试无缓存
        print("  🔄 无缓存测试...")
        no_cache_result = run_query(query_file, use_cache=False)
        
        # 测试有缓存
        print("  🔄 有缓存测试...")
        with_cache_result = run_query(query_file, use_cache=True)
        
        results["results"][query_name] = {
            "no_cache": no_cache_result,
            "with_cache": with_cache_result
        }
        
        if no_cache_result["success"] and with_cache_result["success"]:
            improvement = ((no_cache_result["execution_time"] - with_cache_result["execution_time"]) 
                          / no_cache_result["execution_time"] * 100)
            print(f"  ✅ 无缓存: {no_cache_result['execution_time']:.3f}s")
            print(f"  ✅ 有缓存: {with_cache_result['execution_time']:.3f}s")
            print(f"  📈 性能提升: {improvement:.1f}%")
        else:
            if not no_cache_result["success"]:
                print(f"  ❌ 无缓存测试失败: {no_cache_result['error']}")
            if not with_cache_result["success"]:
                print(f"  ❌ 有缓存测试失败: {with_cache_result['error']}")
    
    # 保存结果
    with open(RESULTS_FILE, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 测试完成，结果保存到: {RESULTS_FILE}")
    
    # 生成简单的Mermaid图表
    chart_content = """# TPC-H缓存性能测试结果

```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比"
    x-axis ["Q01", "Q02", "Q03"]
    y-axis "执行时间(秒)" 0 --> 10
    bar "无缓存" ["""
    
    no_cache_times = []
    with_cache_times = []
    
    for query_name in ["q01", "q02", "q03"]:
        if query_name in results["results"]:
            no_cache = results["results"][query_name]["no_cache"]
            with_cache = results["results"][query_name]["with_cache"]
            
            no_cache_time = no_cache["execution_time"] if no_cache["success"] else 0
            with_cache_time = with_cache["execution_time"] if with_cache["success"] else 0
            
            no_cache_times.append(f"{no_cache_time:.3f}")
            with_cache_times.append(f"{with_cache_time:.3f}")
    
    chart_content += ", ".join(no_cache_times)
    chart_content += """]
    bar "有缓存" ["""
    chart_content += ", ".join(with_cache_times)
    chart_content += """]
```

## 测试详情
"""
    
    for query_name, data in results["results"].items():
        no_cache = data["no_cache"]
        with_cache = data["with_cache"]
        
        if no_cache["success"] and with_cache["success"]:
            improvement = ((no_cache["execution_time"] - with_cache["execution_time"]) 
                          / no_cache["execution_time"] * 100)
            chart_content += f"""
### {query_name.upper()}
- 无缓存: {no_cache["execution_time"]:.3f}秒
- 有缓存: {with_cache["execution_time"]:.3f}秒
- 性能提升: {improvement:.1f}%
"""
    
    with open("tpch_cache_chart.md", 'w', encoding='utf-8') as f:
        f.write(chart_content)
    
    print("📊 图表文件: tpch_cache_chart.md")

if __name__ == "__main__":
    main()