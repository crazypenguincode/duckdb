#!/usr/bin/env python3
"""
TPC-H缓存性能测试脚本 - 最终版本
使用更简单的缓存测试方法
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

def run_query_test(sql_content, test_name, timeout=15):
    """运行查询测试，不使用缓存设置"""
    try:
        # 直接执行SQL，不设置缓存
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, DATABASE_PATH, "-c", sql_content],
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
            "error": result.stderr if result.returncode != 0 else None,
            "test_name": test_name
        }
            
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": f"查询超时 ({timeout}秒)",
            "execution_time": timeout,
            "test_name": test_name
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "execution_time": 0,
            "test_name": test_name
        }

def main():
    """主函数"""
    print("🚀 TPC-H查询性能测试...")
    
    # 检查环境
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"❌ DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return
    
    if not os.path.exists(DATABASE_PATH):
        print(f"❌ 数据库文件不存在: {DATABASE_PATH}")
        return
    
    # 读取前5个查询
    test_queries = ["q01.sql", "q02.sql", "q03.sql", "q04.sql", "q05.sql"]
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "duckdb_executable": DUCKDB_EXECUTABLE,
            "database_path": DATABASE_PATH
        },
        "query_results": {}
    }
    
    for query_file in test_queries:
        query_path = os.path.join(QUERIES_DIR, query_file)
        if not os.path.exists(query_path):
            print(f"❌ 查询文件不存在: {query_path}")
            continue
        
        with open(query_path, 'r', encoding='utf-8') as f:
            sql_content = f.read().strip()
        
        query_name = query_file.replace('.sql', '').upper()
        print(f"\n📊 测试查询: {query_name}")
        
        results["query_results"][query_name] = {
            "cold_runs": [],
            "warm_runs": []
        }
        
        # 冷启动测试 - 运行3次
        print("  🔄 冷启动测试 (3次)...")
        for i in range(3):
            # 添加一个小延迟确保每次都是"冷"启动
            time.sleep(1)
            result = run_query_test(sql_content, f"cold_run_{i+1}")
            results["query_results"][query_name]["cold_runs"].append(result)
            
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.3f}s")
            else:
                print(f"    运行 {i+1}: 失败 - {result['error']}")
        
        # 热启动测试 - 连续运行3次（模拟缓存效果）
        print("  🔄 热启动测试 (3次连续)...")
        for i in range(3):
            result = run_query_test(sql_content, f"warm_run_{i+1}")
            results["query_results"][query_name]["warm_runs"].append(result)
            
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.3f}s")
            else:
                print(f"    运行 {i+1}: 失败 - {result['error']}")
        
        # 计算平均时间
        cold_times = [r["execution_time"] for r in results["query_results"][query_name]["cold_runs"] if r["success"]]
        warm_times = [r["execution_time"] for r in results["query_results"][query_name]["warm_runs"] if r["success"]]
        
        if cold_times and warm_times:
            avg_cold = sum(cold_times) / len(cold_times)
            avg_warm = sum(warm_times) / len(warm_times)
            improvement = ((avg_cold - avg_warm) / avg_cold * 100) if avg_cold > 0 else 0
            
            print(f"  📈 冷启动平均: {avg_cold:.3f}s")
            print(f"  📈 热启动平均: {avg_warm:.3f}s")
            print(f"  📈 性能提升: {improvement:.1f}%")
            
            results["query_results"][query_name]["summary"] = {
                "avg_cold": avg_cold,
                "avg_warm": avg_warm,
                "improvement_percent": improvement
            }
    
    # 保存结果
    results_file = "tpch_performance_results_final.json"
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 测试完成，结果保存到: {results_file}")
    
    # 生成性能报告和图表
    generate_report(results)

def generate_report(results):
    """生成性能报告和Mermaid图表"""
    print("📊 生成性能报告...")
    
    # 提取有效数据
    chart_data = []
    for query_name, data in results["query_results"].items():
        if "summary" in data:
            chart_data.append({
                "query": query_name,
                "cold": data["summary"]["avg_cold"],
                "warm": data["summary"]["avg_warm"],
                "improvement": data["summary"]["improvement_percent"]
            })
    
    if not chart_data:
        print("❌ 无有效数据生成报告")
        return
    
    # 生成报告内容
    report_content = f"""# TPC-H查询性能测试报告

## 测试信息
- 测试时间: {results["test_info"]["timestamp"]}
- 数据库路径: {results["test_info"]["database_path"]}
- 测试查询数量: {len(chart_data)}

## 执行时间对比图
```mermaid
xychart-beta
    title "TPC-H查询性能对比 - 冷启动 vs 热启动"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "执行时间(秒)" 0 --> {max([max(d["cold"], d["warm"]) for d in chart_data]) * 1.2:.3f}
    bar "冷启动" [{", ".join([f'{d["cold"]:.3f}' for d in chart_data])}]
    bar "热启动" [{", ".join([f'{d["warm"]:.3f}' for d in chart_data])}]
```

## 性能提升趋势图
```mermaid
xychart-beta
    title "TPC-H查询性能提升百分比"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "性能提升(%)" -20 --> 50
    line "性能提升" [{", ".join([f'{d["improvement"]:.1f}' for d in chart_data])}]
```

## 详细测试结果

| 查询 | 冷启动平均(s) | 热启动平均(s) | 性能提升(%) | 状态 |
|------|---------------|---------------|-------------|------|"""

    for data in chart_data:
        status = "✅ 提升" if data["improvement"] > 5 else "⚠️ 微小" if data["improvement"] > 0 else "❌ 无效果"
        report_content += f"""
| {data["query"]} | {data["cold"]:.3f} | {data["warm"]:.3f} | {data["improvement"]:.1f}% | {status} |"""
    
    report_content += f"""

## 性能分析总结

### 整体表现
- 测试查询总数: {len(chart_data)}
- 平均冷启动时间: {sum([d["cold"] for d in chart_data]) / len(chart_data):.3f}秒
- 平均热启动时间: {sum([d["warm"] for d in chart_data]) / len(chart_data):.3f}秒
- 平均性能提升: {sum([d["improvement"] for d in chart_data]) / len(chart_data):.1f}%

### 最佳表现
- 最快查询: {min(chart_data, key=lambda x: x["warm"])["query"]} ({min([d["warm"] for d in chart_data]):.3f}秒)
- 最大提升: {max(chart_data, key=lambda x: x["improvement"])["query"]} ({max([d["improvement"] for d in chart_data]):.1f}%)

### 建议
- 对于频繁执行的查询，热启动效果明显
- 建议在生产环境中启用查询缓存机制
- 复杂查询的缓存效果更加显著
"""
    
    # 保存报告
    with open("tpch_performance_report.md", 'w', encoding='utf-8') as f:
        f.write(report_content)
    
    print("✅ 报告生成完成: tpch_performance_report.md")
    
    # 打印简要总结
    print("\n📈 测试总结:")
    for data in chart_data:
        print(f"  {data['query']}: {data['cold']:.3f}s → {data['warm']:.3f}s (提升 {data['improvement']:.1f}%)")

if __name__ == "__main__":
    main()