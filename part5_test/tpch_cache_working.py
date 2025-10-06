#!/usr/bin/env python3
"""
TPC-H缓存性能测试脚本 - 工作版本
直接读取SQL文件内容并执行
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
RESULTS_FILE = "tpch_cache_results_working.json"

def run_query(query_file, use_cache=True):
    """执行单个查询"""
    try:
        query_path = os.path.join(QUERIES_DIR, query_file)
        
        # 读取SQL文件内容
        with open(query_path, 'r', encoding='utf-8') as f:
            sql_content = f.read().strip()
        
        # 构建完整的SQL命令
        cache_setting = "PRAGMA enable_query_cache=true;" if use_cache else "PRAGMA enable_query_cache=false;"
        full_sql = f"{cache_setting}\n{sql_content}"
        
        # 执行查询
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", full_sql],
            capture_output=True,
            text=True,
            timeout=120  # 2分钟超时
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
            "error": "查询超时 (120秒)",
            "execution_time": 120
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "execution_time": 0
        }

def clear_cache():
    """清除查询缓存"""
    try:
        # 执行一个简单查询来重置连接
        subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", "PRAGMA enable_query_cache=false; SELECT 1;"],
            capture_output=True,
            timeout=10
        )
        time.sleep(0.5)  # 短暂等待
    except:
        pass

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
    
    if not os.path.exists(QUERIES_DIR):
        print(f"❌ 查询目录不存在: {QUERIES_DIR}")
        return
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "duckdb_executable": DUCKDB_EXECUTABLE,
            "database_path": DATABASE_PATH,
            "queries_dir": QUERIES_DIR
        },
        "results": {}
    }
    
    # 测试前5个查询
    test_queries = ["q01.sql", "q02.sql", "q03.sql", "q04.sql", "q05.sql"]
    
    for query_file in test_queries:
        query_path = os.path.join(QUERIES_DIR, query_file)
        if not os.path.exists(query_path):
            print(f"❌ 查询文件不存在: {query_path}")
            continue
            
        print(f"\n📊 测试查询: {query_file}")
        query_name = query_file.replace('.sql', '')
        
        results["results"][query_name] = {
            "no_cache_runs": [],
            "with_cache_runs": []
        }
        
        # 测试无缓存情况 - 运行3次
        print("  🔄 无缓存测试 (3次运行)...")
        for run_num in range(3):
            clear_cache()
            result = run_query(query_file, use_cache=False)
            results["results"][query_name]["no_cache_runs"].append(result)
            
            if result["success"]:
                print(f"    运行 {run_num + 1}: {result['execution_time']:.3f}s")
            else:
                print(f"    运行 {run_num + 1}: 失败 - {result['error']}")
        
        # 测试有缓存情况 - 运行3次
        print("  🔄 有缓存测试 (3次运行)...")
        clear_cache()  # 先清除缓存
        for run_num in range(3):
            result = run_query(query_file, use_cache=True)
            results["results"][query_name]["with_cache_runs"].append(result)
            
            if result["success"]:
                print(f"    运行 {run_num + 1}: {result['execution_time']:.3f}s")
            else:
                print(f"    运行 {run_num + 1}: 失败 - {result['error']}")
        
        # 计算平均时间和性能提升
        no_cache_times = [r["execution_time"] for r in results["results"][query_name]["no_cache_runs"] if r["success"]]
        with_cache_times = [r["execution_time"] for r in results["results"][query_name]["with_cache_runs"] if r["success"]]
        
        if no_cache_times and with_cache_times:
            avg_no_cache = sum(no_cache_times) / len(no_cache_times)
            avg_with_cache = sum(with_cache_times) / len(with_cache_times)
            improvement = ((avg_no_cache - avg_with_cache) / avg_no_cache * 100) if avg_no_cache > 0 else 0
            
            print(f"  📈 平均无缓存时间: {avg_no_cache:.3f}s")
            print(f"  📈 平均有缓存时间: {avg_with_cache:.3f}s")
            print(f"  📈 性能提升: {improvement:.1f}%")
            
            # 保存汇总数据
            results["results"][query_name]["summary"] = {
                "avg_no_cache": avg_no_cache,
                "avg_with_cache": avg_with_cache,
                "improvement_percent": improvement
            }
    
    # 保存结果
    with open(RESULTS_FILE, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 测试完成，结果保存到: {RESULTS_FILE}")
    
    # 生成Mermaid图表
    generate_charts(results)

def generate_charts(results):
    """生成性能对比图表"""
    print("📊 生成性能对比图表...")
    
    # 提取有效的测试结果
    chart_data = []
    for query_name, data in results["results"].items():
        if "summary" in data:
            chart_data.append({
                "query": query_name.upper(),
                "no_cache": data["summary"]["avg_no_cache"],
                "with_cache": data["summary"]["avg_with_cache"],
                "improvement": data["summary"]["improvement_percent"]
            })
    
    if not chart_data:
        print("❌ 没有有效的测试数据生成图表")
        return
    
    # 生成柱状图
    chart_content = f"""# TPC-H缓存性能测试结果

## 测试时间
{results["test_info"]["timestamp"]}

## 执行时间对比柱状图
```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "执行时间(秒)" 0 --> {max([max(d["no_cache"], d["with_cache"]) for d in chart_data]) * 1.2:.1f}
    bar "无缓存" [{", ".join([f'{d["no_cache"]:.3f}' for d in chart_data])}]
    bar "有缓存" [{", ".join([f'{d["with_cache"]:.3f}' for d in chart_data])}]
```

## 性能提升折线图
```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "性能提升(%)" 0 --> 100
    line "性能提升" [{", ".join([f'{d["improvement"]:.1f}' for d in chart_data])}]
```

## 详细测试结果
"""
    
    for data in chart_data:
        chart_content += f"""
### {data["query"]}
- 无缓存平均时间: {data["no_cache"]:.3f}秒
- 有缓存平均时间: {data["with_cache"]:.3f}秒  
- 性能提升: {data["improvement"]:.1f}%
"""
    
    with open("tpch_cache_performance_charts.md", 'w', encoding='utf-8') as f:
        f.write(chart_content)
    
    print("✅ 图表文件生成: tpch_cache_performance_charts.md")

if __name__ == "__main__":
    main()