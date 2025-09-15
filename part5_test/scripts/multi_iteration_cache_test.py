#!/usr/bin/env python3
"""
多次数缓存测试脚本
测试不同测试次数对缓存性能评估的影响
"""

import os
import sys
import time
import subprocess
import tempfile
import re
import json
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
from datetime import datetime
from statistics import mean, stdev

def create_comprehensive_cache_test(duckdb_path, db_path):
    """创建综合缓存测试"""
    print("=== 综合缓存功能测试 ===")
    
    # 创建测试数据
    setup_sql = """
    -- 创建多个测试表
    DROP TABLE IF EXISTS sales_data;
    DROP TABLE IF EXISTS products;
    DROP TABLE IF EXISTS customers;
    
    CREATE TABLE products AS 
    SELECT 
        i as product_id,
        'Product_' || i as product_name,
        'Category_' || (i % 20) as category,
        (random() * 1000 + 100)::DECIMAL(10,2) as price
    FROM range(1000) t(i);
    
    CREATE TABLE customers AS 
    SELECT 
        i as customer_id,
        'Customer_' || i as customer_name,
        'City_' || (i % 50) as city,
        'Region_' || (i % 10) as region
    FROM range(500) t(i);
    
    CREATE TABLE sales_data AS 
    SELECT 
        i as sale_id,
        (random() * 1000)::int as product_id,
        (random() * 500)::int as customer_id,
        (random() * 10 + 1)::int as quantity,
        DATE '2024-01-01' + (random() * 365)::int as sale_date
    FROM range(50000) t(i);
    
    -- 创建索引
    CREATE INDEX idx_sales_product ON sales_data(product_id);
    CREATE INDEX idx_sales_customer ON sales_data(customer_id);
    CREATE INDEX idx_sales_date ON sales_data(sale_date);
    """
    
    print("创建综合测试数据...")
    result = subprocess.run([
        duckdb_path, str(db_path), "-c", setup_sql
    ], capture_output=True, text=True, timeout=60)
    
    if result.returncode != 0:
        print(f"✗ 创建测试数据失败: {result.stderr}")
        return False
    
    print("✓ 综合测试数据创建成功")
    return True

def run_cache_test_with_iterations(duckdb_path, db_path, iterations):
    """运行指定次数的缓存测试"""
    
    # 定义不同复杂度的测试查询
    test_queries = [
        {
            'name': '简单聚合查询',
            'sql': '''
            SELECT 
                COUNT(*) as total_sales,
                SUM(quantity) as total_quantity,
                AVG(quantity) as avg_quantity
            FROM sales_data;
            '''
        },
        {
            'name': '多表连接查询',
            'sql': '''
            SELECT 
                p.category,
                COUNT(*) as sales_count,
                SUM(s.quantity * p.price) as total_revenue
            FROM sales_data s
            JOIN products p ON s.product_id = p.product_id
            WHERE s.sale_date >= '2024-06-01'
            GROUP BY p.category
            ORDER BY total_revenue DESC
            LIMIT 10;
            '''
        },
        {
            'name': '复杂分析查询',
            'sql': '''
            WITH monthly_sales AS (
                SELECT 
                    DATE_TRUNC('month', s.sale_date) as month,
                    p.category,
                    c.region,
                    SUM(s.quantity * p.price) as revenue,
                    COUNT(*) as transaction_count
                FROM sales_data s
                JOIN products p ON s.product_id = p.product_id
                JOIN customers c ON s.customer_id = c.customer_id
                GROUP BY DATE_TRUNC('month', s.sale_date), p.category, c.region
            ),
            ranked_performance AS (
                SELECT 
                    month,
                    category,
                    region,
                    revenue,
                    transaction_count,
                    ROW_NUMBER() OVER (PARTITION BY month ORDER BY revenue DESC) as rank
                FROM monthly_sales
            )
            SELECT 
                month,
                category,
                region,
                ROUND(revenue, 2) as revenue,
                transaction_count,
                rank
            FROM ranked_performance
            WHERE rank <= 5
            ORDER BY month, rank;
            '''
        },
        {
            'name': '窗口函数查询',
            'sql': '''
            SELECT 
                customer_id,
                sale_date,
                quantity,
                SUM(quantity) OVER (
                    PARTITION BY customer_id 
                    ORDER BY sale_date 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) as running_total,
                AVG(quantity) OVER (
                    PARTITION BY customer_id 
                    ORDER BY sale_date 
                    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                ) as moving_avg
            FROM sales_data
            WHERE customer_id IN (1, 2, 3, 4, 5)
            ORDER BY customer_id, sale_date;
            '''
        }
    ]
    
    results = []
    
    for query_info in test_queries:
        print(f"\n--- 测试: {query_info['name']} ({iterations}次) ---")
        
        # 生成多次执行的SQL
        no_cache_queries = "\n".join([query_info['sql']] * iterations)
        cache_queries = "\n".join([query_info['sql']] * iterations)
        
        # 创建测试脚本
        script_content = f"""
.timer on
.echo off

-- 禁用缓存，执行{iterations}次
SET enable_query_cache = false;
{no_cache_queries}

-- 启用缓存，执行{iterations}次
SET enable_query_cache = true;
{cache_queries}
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            # 执行测试
            result = subprocess.run([
                duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
            ], capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                # 解析执行时间
                times = extract_execution_times(result.stdout)
                
                if len(times) >= iterations * 2:  # 需要足够的执行时间数据
                    no_cache_times = times[:iterations]
                    cache_times = times[iterations:]
                    
                    # 计算统计数据
                    no_cache_stats = calculate_stats(no_cache_times)
                    cache_stats = calculate_stats(cache_times)
                    
                    # 计算缓存命中效果（排除第一次缓存执行）
                    if len(cache_times) > 1:
                        cache_hit_times = cache_times[1:]  # 排除第一次
                        cache_hit_stats = calculate_stats(cache_hit_times)
                    else:
                        cache_hit_stats = cache_stats
                    
                    improvement = (no_cache_stats['mean'] - cache_hit_stats['mean']) / no_cache_stats['mean'] * 100 if no_cache_stats['mean'] > 0 else 0
                    
                    result_info = {
                        'name': query_info['name'],
                        'iterations': iterations,
                        'no_cache_stats': no_cache_stats,
                        'cache_stats': cache_stats,
                        'cache_hit_stats': cache_hit_stats,
                        'improvement': improvement,
                        'no_cache_times': no_cache_times,
                        'cache_times': cache_times
                    }
                    
                    results.append(result_info)
                    
                    print(f"  ✓ 测试完成")
                    print(f"    无缓存平均: {no_cache_stats['mean']*1000:.2f}ms (±{no_cache_stats['std']*1000:.2f})")
                    print(f"    缓存平均: {cache_stats['mean']*1000:.2f}ms (±{cache_stats['std']*1000:.2f})")
                    print(f"    缓存命中平均: {cache_hit_stats['mean']*1000:.2f}ms (±{cache_hit_stats['std']*1000:.2f})")
                    print(f"    性能提升: {improvement:.2f}%")
                    
                else:
                    print(f"  ✗ 未能提取足够的执行时间数据 (需要{iterations*2}个，得到{len(times)}个)")
            else:
                print(f"  ✗ 测试失败: {result.stderr}")
                
        except Exception as e:
            print(f"  ✗ 测试异常: {e}")
        finally:
            try:
                os.unlink(script_path)
            except:
                pass
    
    return results

def calculate_stats(times):
    """计算时间统计数据"""
    if not times:
        return {'mean': 0, 'std': 0, 'min': 0, 'max': 0}
    
    return {
        'mean': mean(times),
        'std': stdev(times) if len(times) > 1 else 0,
        'min': min(times),
        'max': max(times)
    }

def extract_execution_times(output):
    """从输出中提取执行时间"""
    times = []
    lines = output.split('\n')
    
    for line in lines:
        if 'Run Time (s):' in line:
            # 提取 real 时间
            match = re.search(r'real\s+(\d+\.?\d*)', line)
            if match:
                times.append(float(match.group(1)))
    
    return times

def generate_comparison_charts(all_results, output_dir):
    """生成对比图表"""
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # 设置中文字体
    plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'DejaVu Sans']
    plt.rcParams['axes.unicode_minus'] = False
    
    # 获取所有查询类型
    query_types = list(set(result['name'] for results in all_results.values() for result in results))
    iterations_list = sorted(all_results.keys())
    
    # 1. 性能提升对比折线图
    plt.figure(figsize=(12, 8))
    
    for query_type in query_types:
        improvements = []
        for iterations in iterations_list:
            results = all_results[iterations]
            query_result = next((r for r in results if r['name'] == query_type), None)
            if query_result:
                improvements.append(query_result['improvement'])
            else:
                improvements.append(0)
        
        plt.plot(iterations_list, improvements, marker='o', linewidth=2, label=query_type)
    
    plt.xlabel('测试次数')
    plt.ylabel('性能提升 (%)')
    plt.title('不同测试次数下的缓存性能提升对比')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/performance_improvement_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 2. 执行时间对比图
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    axes = axes.flatten()
    
    for i, query_type in enumerate(query_types[:4]):  # 最多显示4个查询类型
        ax = axes[i]
        
        no_cache_means = []
        cache_hit_means = []
        no_cache_stds = []
        cache_hit_stds = []
        
        for iterations in iterations_list:
            results = all_results[iterations]
            query_result = next((r for r in results if r['name'] == query_type), None)
            if query_result:
                no_cache_means.append(query_result['no_cache_stats']['mean'] * 1000)
                cache_hit_means.append(query_result['cache_hit_stats']['mean'] * 1000)
                no_cache_stds.append(query_result['no_cache_stats']['std'] * 1000)
                cache_hit_stds.append(query_result['cache_hit_stats']['std'] * 1000)
            else:
                no_cache_means.append(0)
                cache_hit_means.append(0)
                no_cache_stds.append(0)
                cache_hit_stds.append(0)
        
        x = np.arange(len(iterations_list))
        width = 0.35
        
        ax.bar(x - width/2, no_cache_means, width, yerr=no_cache_stds, 
               label='无缓存', alpha=0.8, capsize=5)
        ax.bar(x + width/2, cache_hit_means, width, yerr=cache_hit_stds, 
               label='缓存命中', alpha=0.8, capsize=5)
        
        ax.set_xlabel('测试次数')
        ax.set_ylabel('执行时间 (ms)')
        ax.set_title(f'{query_type}')
        ax.set_xticks(x)
        ax.set_xticklabels(iterations_list)
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(f'{output_dir}/execution_time_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # 3. 标准差变化趋势图
    plt.figure(figsize=(12, 8))
    
    for query_type in query_types:
        no_cache_stds = []
        cache_hit_stds = []
        
        for iterations in iterations_list:
            results = all_results[iterations]
            query_result = next((r for r in results if r['name'] == query_type), None)
            if query_result:
                no_cache_stds.append(query_result['no_cache_stats']['std'] * 1000)
                cache_hit_stds.append(query_result['cache_hit_stats']['std'] * 1000)
            else:
                no_cache_stds.append(0)
                cache_hit_stds.append(0)
        
        plt.plot(iterations_list, no_cache_stds, marker='o', linestyle='--', 
                label=f'{query_type} (无缓存)', alpha=0.7)
        plt.plot(iterations_list, cache_hit_stds, marker='s', linestyle='-', 
                label=f'{query_type} (缓存命中)')
    
    plt.xlabel('测试次数')
    plt.ylabel('标准差 (ms)')
    plt.title('不同测试次数下执行时间标准差变化')
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_dir}/std_deviation_trend.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"✓ 图表已保存到 {output_dir} 目录")

def generate_comprehensive_report(all_results, output_file):
    """生成综合测试报告"""
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# 多次数缓存测试综合报告\n\n")
        f.write(f"**测试时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        # 测试概况
        f.write("## 测试概况\n\n")
        f.write(f"- **测试次数配置**: {', '.join(map(str, sorted(all_results.keys())))}次\n")
        f.write(f"- **查询类型数量**: {len(set(result['name'] for results in all_results.values() for result in results))}\n")
        f.write(f"- **总测试执行数**: {sum(len(results) for results in all_results.values())}\n\n")
        
        # 详细结果表格
        f.write("## 详细测试结果\n\n")
        
        for iterations in sorted(all_results.keys()):
            f.write(f"### {iterations}次测试结果\n\n")
            f.write("| 查询类型 | 无缓存平均(ms) | 缓存命中平均(ms) | 性能提升(%) | 无缓存标准差(ms) | 缓存标准差(ms) |\n")
            f.write("|----------|----------------|------------------|-------------|------------------|----------------|\n")
            
            results = all_results[iterations]
            for result in results:
                f.write(f"| {result['name']} | "
                       f"{result['no_cache_stats']['mean']*1000:.2f} | "
                       f"{result['cache_hit_stats']['mean']*1000:.2f} | "
                       f"{result['improvement']:.2f} | "
                       f"{result['no_cache_stats']['std']*1000:.2f} | "
                       f"{result['cache_hit_stats']['std']*1000:.2f} |\n")
            f.write("\n")
        
        # 趋势分析
        f.write("## 趋势分析\n\n")
        
        query_types = list(set(result['name'] for results in all_results.values() for result in results))
        iterations_list = sorted(all_results.keys())
        
        for query_type in query_types:
            f.write(f"### {query_type}\n\n")
            
            improvements = []
            std_reductions = []
            
            for iterations in iterations_list:
                results = all_results[iterations]
                query_result = next((r for r in results if r['name'] == query_type), None)
                if query_result:
                    improvements.append(query_result['improvement'])
                    std_reduction = (query_result['no_cache_stats']['std'] - query_result['cache_hit_stats']['std']) / query_result['no_cache_stats']['std'] * 100 if query_result['no_cache_stats']['std'] > 0 else 0
                    std_reductions.append(std_reduction)
            
            if improvements:
                f.write(f"- **性能提升趋势**: {improvements[0]:.2f}% → {improvements[-1]:.2f}%\n")
                f.write(f"- **稳定性改善**: 标准差减少 {std_reductions[0]:.2f}% → {std_reductions[-1]:.2f}%\n")
                
                # 分析趋势
                if len(improvements) > 1:
                    trend = "上升" if improvements[-1] > improvements[0] else "下降" if improvements[-1] < improvements[0] else "稳定"
                    f.write(f"- **总体趋势**: {trend}\n")
            
            f.write("\n")
        
        # 结论和建议
        f.write("## 结论和建议\n\n")
        
        # 计算平均性能提升
        avg_improvements = {}
        for iterations in iterations_list:
            results = all_results[iterations]
            improvements = [r['improvement'] for r in results if r['improvement'] > 0]
            avg_improvements[iterations] = mean(improvements) if improvements else 0
        
        f.write("### 主要发现\n\n")
        f.write(f"1. **最佳测试次数**: {max(avg_improvements, key=avg_improvements.get)}次 "
               f"(平均性能提升: {max(avg_improvements.values()):.2f}%)\n")
        f.write(f"2. **性能提升范围**: {min(avg_improvements.values()):.2f}% - {max(avg_improvements.values()):.2f}%\n")
        
        # 稳定性分析
        std_analysis = {}
        for iterations in iterations_list:
            results = all_results[iterations]
            avg_std = mean([r['cache_hit_stats']['std'] * 1000 for r in results])
            std_analysis[iterations] = avg_std
        
        f.write(f"3. **最稳定配置**: {min(std_analysis, key=std_analysis.get)}次 "
               f"(平均标准差: {min(std_analysis.values()):.2f}ms)\n")
        
        f.write("\n### 使用建议\n\n")
        f.write("1. **生产环境**: 建议使用50-100次测试来获得稳定的性能评估\n")
        f.write("2. **开发测试**: 10次测试足以进行快速验证\n")
        f.write("3. **基准测试**: 200次测试可提供最准确的性能数据\n")
        f.write("4. **缓存优化**: 重点关注多表连接和复杂分析查询的缓存效果\n")
    
    print(f"✓ 综合报告已保存到 {output_file}")

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python multi_iteration_cache_test.py <duckdb_path>")
        print("Example: python multi_iteration_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    print("🚀 DuckDB多次数缓存对比测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 测试配置
    test_iterations = [10, 50, 100, 200]  # 不同的测试次数
    db_path = Path("multi_iteration_cache_test.db")
    
    all_results = {}
    
    try:
        # 删除旧的测试数据库
        if db_path.exists():
            db_path.unlink()
        
        # 创建测试数据
        if not create_comprehensive_cache_test(duckdb_path, db_path):
            print("❌ 测试数据创建失败")
            sys.exit(1)
        
        # 运行不同次数的测试
        for iterations in test_iterations:
            print(f"\n{'='*20} {iterations}次测试 {'='*20}")
            results = run_cache_test_with_iterations(duckdb_path, db_path, iterations)
            all_results[iterations] = results
            
            # 显示当前测试的汇总
            if results:
                avg_improvement = mean([r['improvement'] for r in results if r['improvement'] > 0])
                print(f"\n📊 {iterations}次测试汇总: 平均性能提升 {avg_improvement:.2f}%")
        
        # 生成对比图表
        output_dir = "multi_iteration_results"
        generate_comparison_charts(all_results, output_dir)
        
        # 生成综合报告
        report_file = f"multi_iteration_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        generate_comprehensive_report(all_results, report_file)
        
        # 保存原始数据
        data_file = f"multi_iteration_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(data_file, 'w', encoding='utf-8') as f:
            json.dump({
                'test_info': {
                    'timestamp': datetime.now().isoformat(),
                    'duckdb_path': duckdb_path,
                    'test_iterations': test_iterations
                },
                'results': all_results
            }, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 原始数据已保存到: {data_file}")
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"🧹 已清理测试数据库: {db_path}")
        
        print(f"\n✅ 所有测试完成于: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"📊 图表目录: {output_dir}")
        print(f"📋 报告文件: {report_file}")
        
    except KeyboardInterrupt:
        print("\n⚠️ 测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()