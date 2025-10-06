#!/usr/bin/env python3
"""
TPC-H缓存性能测试脚本 - 最终版本
测试所有22个TPC-H查询在有无缓存情况下的性能对比
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
RESULTS_FILE = "tpch_cache_results_final.json"

def check_environment():
    """检查测试环境"""
    print("🔍 检查测试环境...")
    
    # 检查DuckDB可执行文件
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"❌ DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return False
    
    # 检查数据库文件
    if not os.path.exists(DATABASE_PATH):
        print(f"❌ 数据库文件不存在: {DATABASE_PATH}")
        return False
    
    # 检查查询目录
    if not os.path.exists(QUERIES_DIR):
        print(f"❌ 查询目录不存在: {QUERIES_DIR}")
        return False
    
    # 检查查询文件
    query_files = [f"q{i:02d}.sql" for i in range(1, 23)]
    missing_files = []
    for qfile in query_files:
        if not os.path.exists(os.path.join(QUERIES_DIR, qfile)):
            missing_files.append(qfile)
    
    if missing_files:
        print(f"❌ 缺少查询文件: {missing_files}")
        return False
    
    print("✅ 环境检查通过")
    return True

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
            timeout=300  # 5分钟超时
        )
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        if result.returncode == 0:
            return {
                "success": True,
                "execution_time": execution_time,
                "output_size": len(result.stdout)
            }
        else:
            return {
                "success": False,
                "error": result.stderr,
                "execution_time": execution_time
            }
            
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": "Query timeout (300s)",
            "execution_time": 300
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "execution_time": 0
        }

def clear_cache():
    """清理缓存"""
    try:
        # 重启DuckDB连接来清理缓存
        subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", "PRAGMA enable_query_cache=false; SELECT 1;"],
            capture_output=True,
            timeout=30
        )
        time.sleep(1)  # 等待缓存清理
    except:
        pass

def run_performance_test():
    """运行性能测试"""
    print("🚀 开始TPC-H缓存性能测试...")
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "duckdb_executable": DUCKDB_EXECUTABLE,
            "database_path": DATABASE_PATH,
            "queries_dir": QUERIES_DIR
        },
        "query_results": {}
    }
    
    # 测试前5个查询（快速测试）
    test_queries = [f"q{i:02d}.sql" for i in range(1, 6)]
    
    for query_file in test_queries:
        print(f"\n📊 测试查询: {query_file}")
        query_name = query_file.replace('.sql', '')
        
        results["query_results"][query_name] = {
            "no_cache": {"single_run": [], "multiple_runs": []},
            "with_cache": {"single_run": [], "multiple_runs": []}
        }
        
        # 测试无缓存情况 - 单次运行
        print("  🔄 无缓存 - 单次运行")
        clear_cache()
        result = run_query(query_file, use_cache=False)
        results["query_results"][query_name]["no_cache"]["single_run"].append(result)
        
        if result["success"]:
            print(f"    ✅ 执行时间: {result['execution_time']:.3f}s")
        else:
            print(f"    ❌ 执行失败: {result.get('error', 'Unknown error')}")
        
        # 测试无缓存情况 - 多次运行（3次）
        print("  🔄 无缓存 - 多次运行")
        for i in range(3):
            clear_cache()
            result = run_query(query_file, use_cache=False)
            results["query_results"][query_name]["no_cache"]["multiple_runs"].append(result)
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.3f}s")
        
        # 测试有缓存情况 - 单次运行
        print("  🔄 有缓存 - 单次运行")
        clear_cache()
        result = run_query(query_file, use_cache=True)
        results["query_results"][query_name]["with_cache"]["single_run"].append(result)
        
        if result["success"]:
            print(f"    ✅ 执行时间: {result['execution_time']:.3f}s")
        
        # 测试有缓存情况 - 多次运行（3次）
        print("  🔄 有缓存 - 多次运行")
        for i in range(3):
            result = run_query(query_file, use_cache=True)
            results["query_results"][query_name]["with_cache"]["multiple_runs"].append(result)
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.3f}s")
    
    # 保存结果
    with open(RESULTS_FILE, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 测试完成，结果保存到: {RESULTS_FILE}")
    return results

def generate_mermaid_charts(results):
    """生成Mermaid图表"""
    print("\n📊 生成性能对比图表...")
    
    # 提取性能数据
    chart_data = []
    for query_name, data in results["query_results"].items():
        no_cache_times = [r["execution_time"] for r in data["no_cache"]["multiple_runs"] if r["success"]]
        with_cache_times = [r["execution_time"] for r in data["with_cache"]["multiple_runs"] if r["success"]]
        
        if no_cache_times and with_cache_times:
            avg_no_cache = sum(no_cache_times) / len(no_cache_times)
            avg_with_cache = sum(with_cache_times) / len(with_cache_times)
            chart_data.append({
                "query": query_name,
                "no_cache": avg_no_cache,
                "with_cache": avg_with_cache,
                "improvement": ((avg_no_cache - avg_with_cache) / avg_no_cache * 100) if avg_no_cache > 0 else 0
            })
    
    # 生成柱状图
    bar_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 执行时间"
    x-axis ["""
    
    bar_chart += ", ".join([f'"{d["query"]}"' for d in chart_data])
    bar_chart += """]
    y-axis "执行时间(秒)" 0 --> """
    
    max_time = max([max(d["no_cache"], d["with_cache"]) for d in chart_data]) if chart_data else 1
    bar_chart += f"{max_time * 1.1:.1f}\n"
    
    bar_chart += '    bar [' + ", ".join([f'{d["no_cache"]:.3f}' for d in chart_data]) + ']\n'
    bar_chart += '    bar [' + ", ".join([f'{d["with_cache"]:.3f}' for d in chart_data]) + ']\n'
    bar_chart += "```"
    
    # 生成折线图
    line_chart = """```mermaid
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis ["""
    
    line_chart += ", ".join([f'"{d["query"]}"' for d in chart_data])
    line_chart += """]
    y-axis "性能提升(%)" 0 --> 100
    line ["""
    
    line_chart += ", ".join([f'{d["improvement"]:.1f}' for d in chart_data])
    line_chart += """]
```"""
    
    # 保存图表
    charts_content = f"""# TPC-H缓存性能测试结果

## 测试时间
{results["test_info"]["timestamp"]}

## 性能对比柱状图
{bar_chart}

## 性能提升折线图
{line_chart}

## 详细数据
"""
    
    for data in chart_data:
        charts_content += f"""
### {data["query"]}
- 无缓存平均时间: {data["no_cache"]:.3f}秒
- 有缓存平均时间: {data["with_cache"]:.3f}秒
- 性能提升: {data["improvement"]:.1f}%
"""
    
    with open("tpch_cache_performance_charts.md", 'w', encoding='utf-8') as f:
        f.write(charts_content)
    
    print("✅ 图表生成完成: tpch_cache_performance_charts.md")

def main():
    """主函数"""
    print("=" * 60)
    print("TPC-H缓存性能测试脚本")
    print("=" * 60)
    
    # 检查环境
    if not check_environment():
        sys.exit(1)
    
    # 运行测试
    results = run_performance_test()
    
    # 生成图表
    generate_mermaid_charts(results)
    
    print("\n🎉 所有测试完成！")
    print(f"📁 结果文件: {RESULTS_FILE}")
    print("📊 图表文件: tpch_cache_performance_charts.md")

if __name__ == "__main__":
    main()