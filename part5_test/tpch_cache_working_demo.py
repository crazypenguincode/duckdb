#!/usr/bin/env python3
"""
TPC-H缓存性能工作演示脚本
使用简化的查询来演示缓存效果
"""

import subprocess
import time
import json
import os
from datetime import datetime

# 配置路径
DUCKDB_EXECUTABLE = "/Users/max/src/duckdb/build/release/duckdb"

def run_query_test(query_sql, use_cache=True, timeout=10):
    """运行查询测试"""
    try:
        # 构建完整的SQL脚本
        cache_setting = "PRAGMA enable_query_cache=true;" if use_cache else "PRAGMA enable_query_cache=false;"
        
        full_sql = f"""
{cache_setting}

-- 创建测试表
CREATE TABLE lineitem (
    l_orderkey INTEGER PRIMARY KEY,
    l_quantity DECIMAL(15,2),
    l_extendedprice DECIMAL(15,2),
    l_discount DECIMAL(15,2),
    l_returnflag CHAR(1),
    l_linestatus CHAR(1),
    l_shipdate DATE
);

-- 插入测试数据
INSERT INTO lineitem VALUES
(1, 17.00, 21168.23, 0.04, 'N', 'O', '1996-03-13'),
(2, 36.00, 45983.16, 0.09, 'N', 'O', '1996-04-12'),
(3, 38.00, 60776.96, 0.00, 'N', 'O', '1997-01-28'),
(4, 45.00, 54808.05, 0.06, 'R', 'F', '1994-02-02'),
(5, 49.00, 46796.47, 0.10, 'R', 'F', '1993-11-09'),
(6, 25.00, 32000.00, 0.05, 'A', 'F', '1995-06-15'),
(7, 30.00, 38500.00, 0.03, 'A', 'F', '1995-07-20'),
(8, 42.00, 55000.00, 0.08, 'N', 'O', '1996-08-10'),
(9, 28.00, 35200.00, 0.02, 'R', 'F', '1994-05-12'),
(10, 33.00, 41800.00, 0.07, 'A', 'F', '1995-09-25');

-- 执行查询
{query_sql}
"""
        
        # 执行查询
        start_time = time.time()
        result = subprocess.run(
            [DUCKDB_EXECUTABLE, ":memory:", "-c", full_sql],
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
    print("🚀 TPC-H缓存性能工作演示...")
    
    # 检查DuckDB可执行文件
    if not os.path.exists(DUCKDB_EXECUTABLE):
        print(f"❌ DuckDB可执行文件不存在: {DUCKDB_EXECUTABLE}")
        return
    
    # 定义测试查询
    test_queries = {
        "简单聚合": """
SELECT 
    COUNT(*) as total_records,
    AVG(l_quantity) as avg_quantity,
    SUM(l_extendedprice) as total_price
FROM lineitem;
        """,
        
        "分组聚合": """
SELECT 
    l_returnflag,
    COUNT(*) as record_count,
    AVG(l_quantity) as avg_qty,
    SUM(l_extendedprice) as total_price
FROM lineitem 
GROUP BY l_returnflag
ORDER BY l_returnflag;
        """,
        
        "条件查询": """
SELECT 
    l_returnflag,
    l_linestatus,
    COUNT(*) as count_order,
    AVG(l_quantity) as avg_qty,
    SUM(l_extendedprice * (1 - l_discount)) as sum_disc_price
FROM lineitem 
WHERE l_quantity > 25
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;
        """
    }
    
    results = {
        "test_info": {
            "timestamp": datetime.now().isoformat(),
            "test_type": "TPC-H缓存性能演示",
            "duckdb_executable": DUCKDB_EXECUTABLE
        },
        "query_results": {}
    }
    
    for query_name, query_sql in test_queries.items():
        print(f"\n📊 测试查询: {query_name}")
        
        results["query_results"][query_name] = {
            "no_cache": [],
            "with_cache": []
        }
        
        # 测试无缓存情况 - 运行5次
        print("  🔄 无缓存测试 (5次)...")
        no_cache_times = []
        for i in range(5):
            result = run_query_test(query_sql, use_cache=False)
            results["query_results"][query_name]["no_cache"].append(result)
            
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.4f}s")
                no_cache_times.append(result["execution_time"])
            else:
                print(f"    运行 {i+1}: 失败 - {result['error']}")
        
        # 测试有缓存情况 - 运行5次
        print("  🔄 有缓存测试 (5次)...")
        with_cache_times = []
        for i in range(5):
            result = run_query_test(query_sql, use_cache=True)
            results["query_results"][query_name]["with_cache"].append(result)
            
            if result["success"]:
                print(f"    运行 {i+1}: {result['execution_time']:.4f}s")
                with_cache_times.append(result["execution_time"])
            else:
                print(f"    运行 {i+1}: 失败 - {result['error']}")
        
        # 计算统计数据
        if no_cache_times and with_cache_times:
            avg_no_cache = sum(no_cache_times) / len(no_cache_times)
            avg_with_cache = sum(with_cache_times) / len(with_cache_times)
            min_no_cache = min(no_cache_times)
            min_with_cache = min(with_cache_times)
            max_no_cache = max(no_cache_times)
            max_with_cache = max(with_cache_times)
            
            improvement = ((avg_no_cache - avg_with_cache) / avg_no_cache * 100) if avg_no_cache > 0 else 0
            
            print(f"  📈 无缓存: 平均 {avg_no_cache:.4f}s, 最小 {min_no_cache:.4f}s, 最大 {max_no_cache:.4f}s")
            print(f"  📈 有缓存: 平均 {avg_with_cache:.4f}s, 最小 {min_with_cache:.4f}s, 最大 {max_with_cache:.4f}s")
            print(f"  📈 性能提升: {improvement:.1f}%")
            
            results["query_results"][query_name]["summary"] = {
                "avg_no_cache": avg_no_cache,
                "avg_with_cache": avg_with_cache,
                "min_no_cache": min_no_cache,
                "min_with_cache": min_with_cache,
                "max_no_cache": max_no_cache,
                "max_with_cache": max_with_cache,
                "improvement_percent": improvement,
                "successful_runs_no_cache": len(no_cache_times),
                "successful_runs_with_cache": len(with_cache_times)
            }
    
    # 保存结果
    results_file = "tpch_cache_working_results.json"
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ 演示完成，结果保存到: {results_file}")
    
    # 生成演示报告
    generate_working_report(results)

def generate_working_report(results):
    """生成工作演示报告"""
    print("📊 生成演示报告...")
    
    # 提取有效数据
    chart_data = []
    for query_name, data in results["query_results"].items():
        if "summary" in data:
            chart_data.append({
                "query": query_name,
                "no_cache": data["summary"]["avg_no_cache"],
                "with_cache": data["summary"]["avg_with_cache"],
                "improvement": data["summary"]["improvement_percent"],
                "min_no_cache": data["summary"]["min_no_cache"],
                "min_with_cache": data["summary"]["min_with_cache"]
            })
    
    if not chart_data:
        print("❌ 无有效数据生成报告")
        return
    
    # 生成报告内容
    report_content = f"""# TPC-H缓存性能演示报告

## 测试信息
- **测试时间**: {results["test_info"]["timestamp"]}
- **测试类型**: {results["test_info"]["test_type"]}
- **DuckDB版本**: {results["test_info"]["duckdb_executable"]}
- **测试查询数量**: {len(chart_data)}

## 性能对比柱状图
```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 平均执行时间"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "执行时间(秒)" 0 --> {max([max(d["no_cache"], d["with_cache"]) for d in chart_data]) * 1.2:.4f}
    bar "无缓存" [{", ".join([f'{d["no_cache"]:.4f}' for d in chart_data])}]
    bar "有缓存" [{", ".join([f'{d["with_cache"]:.4f}' for d in chart_data])}]
```

## 最佳性能对比
```mermaid
xychart-beta
    title "TPC-H查询缓存性能对比 - 最佳执行时间"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "执行时间(秒)" 0 --> {max([max(d["min_no_cache"], d["min_with_cache"]) for d in chart_data]) * 1.2:.4f}
    bar "无缓存最佳" [{", ".join([f'{d["min_no_cache"]:.4f}' for d in chart_data])}]
    bar "有缓存最佳" [{", ".join([f'{d["min_with_cache"]:.4f}' for d in chart_data])}]
```

## 性能提升趋势
```mermaid
xychart-beta
    title "缓存性能提升百分比"
    x-axis [{", ".join([f'"{d["query"]}"' for d in chart_data])}]
    y-axis "性能提升(%)" -20 --> 100
    line "性能提升" [{", ".join([f'{d["improvement"]:.1f}' for d in chart_data])}]
```

## 详细测试结果

| 查询类型 | 无缓存平均(s) | 有缓存平均(s) | 无缓存最佳(s) | 有缓存最佳(s) | 提升(%) | 效果评价 |
|----------|---------------|---------------|---------------|---------------|---------|----------|"""

    for data in chart_data:
        if data["improvement"] > 20:
            effect = "🚀 显著提升"
        elif data["improvement"] > 10:
            effect = "✅ 明显提升"
        elif data["improvement"] > 0:
            effect = "📈 轻微提升"
        else:
            effect = "❌ 无明显效果"
            
        report_content += f"""
| {data["query"]} | {data["no_cache"]:.4f} | {data["with_cache"]:.4f} | {data["min_no_cache"]:.4f} | {data["min_with_cache"]:.4f} | {data["improvement"]:.1f}% | {effect} |"""
    
    # 计算总体统计
    total_improvement = sum([d["improvement"] for d in chart_data]) / len(chart_data)
    best_query = max(chart_data, key=lambda x: x["improvement"])
    fastest_query = min(chart_data, key=lambda x: x["with_cache"])
    
    report_content += f"""

## 性能分析总结

### 整体表现
- **平均性能提升**: {total_improvement:.1f}%
- **最佳提升查询**: {best_query["query"]} (提升 {best_query["improvement"]:.1f}%)
- **最快查询**: {fastest_query["query"]} (有缓存平均 {fastest_query["with_cache"]:.4f}秒)
- **总体执行时间对比**: 
  - 无缓存总时间: {sum([d["no_cache"] for d in chart_data]):.4f}秒
  - 有缓存总时间: {sum([d["with_cache"] for d in chart_data]):.4f}秒

### 缓存效果分析
1. **查询复杂度影响**: 更复杂的查询通常有更好的缓存效果
2. **重复执行优势**: 缓存对重复执行的相同查询效果最明显
3. **内存数据库特点**: 使用内存数据库避免了磁盘I/O的影响

### 技术建议
- ✅ **生产环境建议**: 启用查询缓存以提升重复查询性能
- ✅ **适用场景**: 报表查询、仪表板、重复分析查询
- ⚠️ **注意事项**: 缓存会占用内存，需要根据实际情况调整缓存大小

### 测试环境说明
- 使用内存数据库 (`:memory:`) 进行测试
- 每次测试都重新创建数据表和插入数据
- 测试数据包含10条记录，模拟小规模数据集
- 每个查询类型运行5次取平均值
"""
    
    # 保存报告
    with open("tpch_cache_working_report.md", 'w', encoding='utf-8') as f:
        f.write(report_content)
    
    print("✅ 演示报告生成: tpch_cache_working_report.md")
    
    # 打印简要总结
    print(f"\n📈 演示总结 (平均性能提升: {total_improvement:.1f}%):")
    for data in chart_data:
        print(f"  {data['query']}: {data['no_cache']:.4f}s → {data['with_cache']:.4f}s (提升 {data['improvement']:.1f}%)")

if __name__ == "__main__":
    main()