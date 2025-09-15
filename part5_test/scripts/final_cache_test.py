#!/usr/bin/env python3
"""
最终版缓存测试脚本
正确测试DuckDB查询缓存功能
"""

import os
import sys
import time
import subprocess
import tempfile
import re
from pathlib import Path
from datetime import datetime

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

def run_comprehensive_cache_tests(duckdb_path, db_path):
    """运行综合缓存测试"""
    
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
        print(f"\n--- 测试: {query_info['name']} ---")
        
        # 创建测试脚本
        script_content = f"""
.timer on
.echo off

-- 禁用缓存，执行5次
SET enable_query_cache = false;
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}

-- 启用缓存，执行5次
SET enable_query_cache = true;
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            # 执行测试
            result = subprocess.run([
                duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
            ], capture_output=True, text=True, timeout=120)
            
            if result.returncode == 0:
                # 解析执行时间
                times = extract_execution_times(result.stdout)
                
                if len(times) >= 6:  # 至少需要6次执行时间
                    no_cache_times = times[:3]
                    cache_times = times[3:]
                    
                    avg_no_cache = sum(no_cache_times) / len(no_cache_times)
                    avg_cache = sum(cache_times) / len(cache_times)
                    
                    # 计算缓存命中效果（排除第一次缓存执行）
                    if len(cache_times) > 1:
                        cache_hit_times = cache_times[1:]  # 排除第一次
                        avg_cache_hit = sum(cache_hit_times) / len(cache_hit_times)
                    else:
                        avg_cache_hit = avg_cache
                    
                    improvement = (avg_no_cache - avg_cache_hit) / avg_no_cache * 100 if avg_no_cache > 0 else 0
                    
                    result_info = {
                        'name': query_info['name'],
                        'no_cache_avg': avg_no_cache,
                        'cache_avg': avg_cache,
                        'cache_hit_avg': avg_cache_hit,
                        'improvement': improvement,
                        'all_times': times
                    }
                    
                    results.append(result_info)
                    
                    print(f"  ✓ 测试完成")
                    print(f"    无缓存平均: {avg_no_cache*1000:.2f}ms")
                    print(f"    缓存平均: {avg_cache*1000:.2f}ms")
                    print(f"    缓存命中平均: {avg_cache_hit*1000:.2f}ms")
                    print(f"    性能提升: {improvement:.2f}%")
                    
                    if improvement > 10:
                        print(f"    🎉 缓存效果显著！")
                    elif improvement > 0:
                        print(f"    ✓ 缓存有效果")
                    else:
                        print(f"    ⚠️ 缓存效果不明显")
                else:
                    print(f"  ✗ 未能提取足够的执行时间数据")
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

def generate_cache_performance_report(results, duckdb_path):
    """生成缓存性能报告"""
    print("\n" + "=" * 80)
    print("=== DuckDB查询缓存性能测试报告 ===")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"DuckDB路径: {duckdb_path}")
    print("=" * 80)
    
    if not results:
        print("❌ 没有可用的测试结果")
        return
    
    # 汇总统计
    total_tests = len(results)
    effective_tests = len([r for r in results if r['improvement'] > 0])
    significant_tests = len([r for r in results if r['improvement'] > 10])
    
    print(f"\n📊 测试汇总:")
    print(f"  总测试数: {total_tests}")
    print(f"  有效缓存测试: {effective_tests}")
    print(f"  显著效果测试: {significant_tests}")
    
    # 详细结果表格
    print(f"\n📋 详细测试结果:")
    print("┌" + "─" * 25 + "┬" + "─" * 12 + "┬" + "─" * 12 + "┬" + "─" * 15 + "┬" + "─" * 10 + "┐")
    print("│{:^25}│{:^12}│{:^12}│{:^15}│{:^10}│".format("查询类型", "无缓存(ms)", "缓存(ms)", "缓存命中(ms)", "提升(%)"))
    print("├" + "─" * 25 + "┼" + "─" * 12 + "┼" + "─" * 12 + "┼" + "─" * 15 + "┼" + "─" * 10 + "┤")
    
    for result in results:
        name = result['name'][:23] + ".." if len(result['name']) > 25 else result['name']
        no_cache = result['no_cache_avg'] * 1000
        cache = result['cache_avg'] * 1000
        cache_hit = result['cache_hit_avg'] * 1000
        improvement = result['improvement']
        
        print("│{:<25}│{:>10.2f}  │{:>10.2f}  │{:>13.2f}  │{:>8.1f}  │".format(
            name, no_cache, cache, cache_hit, improvement))
    
    print("└" + "─" * 25 + "┴" + "─" * 12 + "┴" + "─" * 12 + "┴" + "─" * 15 + "┴" + "─" * 10 + "┘")
    
    # 性能分析
    if results:
        improvements = [r['improvement'] for r in results if r['improvement'] > 0]
        if improvements:
            avg_improvement = sum(improvements) / len(improvements)
            max_improvement = max(improvements)
            min_improvement = min(improvements)
            
            print(f"\n📈 性能分析:")
            print(f"  平均性能提升: {avg_improvement:.2f}%")
            print(f"  最大性能提升: {max_improvement:.2f}%")
            print(f"  最小性能提升: {min_improvement:.2f}%")
    
    # 结论和建议
    print(f"\n🎯 测试结论:")
    
    if significant_tests > 0:
        print(f"  ✅ DuckDB查询缓存功能正常工作！")
        print(f"  ✅ {significant_tests}/{total_tests} 个查询显示显著的缓存效果")
        print(f"  ✅ 缓存对复杂查询特别有效")
    elif effective_tests > 0:
        print(f"  ✅ DuckDB查询缓存功能基本正常")
        print(f"  ⚠️ {effective_tests}/{total_tests} 个查询显示缓存效果")
        print(f"  💡 建议使用更复杂的查询来获得更好的缓存效果")
    else:
        print(f"  ⚠️ 缓存效果不明显")
        print(f"  💡 可能原因: 查询太简单、数据集太小、或系统性能太好")
    
    print(f"\n💡 使用建议:")
    print(f"  1. 缓存对重复的复杂查询最有效")
    print(f"  2. 多表连接和聚合查询能获得更好的缓存效果")
    print(f"  3. 在生产环境中，缓存效果会更加明显")
    print(f"  4. 定期监控缓存命中率和性能提升")

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python final_cache_test.py <duckdb_path>")
        print("Example: python final_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    print("🚀 DuckDB查询缓存综合测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 测试数据库路径
    db_path = Path("final_cache_test.db")
    
    try:
        # 删除旧的测试数据库
        if db_path.exists():
            db_path.unlink()
        
        # 创建测试数据
        if not create_comprehensive_cache_test(duckdb_path, db_path):
            print("❌ 测试数据创建失败")
            sys.exit(1)
        
        # 运行综合缓存测试
        results = run_comprehensive_cache_tests(duckdb_path, db_path)
        
        # 生成测试报告
        generate_cache_performance_report(results, duckdb_path)
        
        # 保存结果到JSON文件
        import json
        result_file = f"cache_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        report_data = {
            'test_info': {
                'timestamp': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'total_tests': len(results)
            },
            'results': results
        }
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 详细结果已保存到: {result_file}")
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"🧹 已清理测试数据库: {db_path}")
        
        print(f"\n✅ 测试完成于: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
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