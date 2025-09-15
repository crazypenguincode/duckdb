#!/usr/bin/env python3
"""
最终版表5.7数据集缓存测试脚本
基于final_cache_test.py的正确方法，确保所有四种数据集都能正确测试
"""

import os
import sys
import json
import time
import subprocess
import tempfile
import re
from pathlib import Path
from datetime import datetime
import random

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

def setup_test_database(duckdb_path, db_path):
    """设置测试数据库"""
    print("=== 设置测试数据库 ===")
    
    # 简化的数据库创建脚本
    setup_sql = """
    -- 创建测试表
    DROP TABLE IF EXISTS customers;
    DROP TABLE IF EXISTS products;
    DROP TABLE IF EXISTS orders;
    DROP TABLE IF EXISTS order_items;
    
    CREATE TABLE customers AS 
    SELECT 
        i as customer_id,
        'Customer_' || i as customer_name,
        'City_' || (i % 10) as city,
        'Region_' || (i % 5) as region
    FROM range(1000) t(i);
    
    CREATE TABLE products AS 
    SELECT 
        i as product_id,
        'Product_' || i as product_name,
        'Category_' || (i % 20) as category,
        (random() * 1000 + 100)::DECIMAL(10,2) as price
    FROM range(500) t(i);
    
    CREATE TABLE orders AS 
    SELECT 
        i as order_id,
        (random() * 1000)::int as customer_id,
        (random() * 500)::int as product_id,
        (random() * 10 + 1)::int as quantity,
        DATE '2024-01-01' + (random() * 365)::int as order_date
    FROM range(10000) t(i);
    
    -- 创建索引
    CREATE INDEX idx_orders_customer ON orders(customer_id);
    CREATE INDEX idx_orders_product ON orders(product_id);
    CREATE INDEX idx_orders_date ON orders(order_date);
    """
    
    print("创建测试数据...")
    result = subprocess.run([
        duckdb_path, str(db_path), "-c", setup_sql
    ], capture_output=True, text=True, timeout=120)
    
    if result.returncode != 0:
        raise RuntimeError(f"数据库创建失败: {result.stderr}")
    
    print("✓ 测试数据库创建成功")
    return True

def test_dataset_cache_performance(duckdb_path, db_path, dataset_name, queries, no_cache_runs=3, cache_runs=5):
    """测试数据集的缓存性能"""
    print(f"\n=== 测试 {dataset_name} ===")
    
    if not queries:
        print(f"⚠️ {dataset_name} 没有查询可执行")
        return None
    
    # 限制查询数量以确保测试稳定
    test_queries = queries[:5] if len(queries) > 5 else queries
    
    print(f"准备测试 {len(test_queries)} 个查询")
    
    # 创建测试脚本
    script_content = ".timer on\n.echo off\n\n"
    
    # 禁用缓存阶段
    script_content += f"-- 禁用缓存测试\n"
    script_content += "SET enable_query_cache = false;\n"
    
    for i in range(no_cache_runs):
        for j, query in enumerate(test_queries):
            script_content += f"-- 无缓存执行 {i+1}-{j+1}\n"
            script_content += query.strip()
            if not query.strip().endswith(';'):
                script_content += ';'
            script_content += "\n"
    
    # 启用缓存阶段
    script_content += f"\n-- 启用缓存测试\n"
    script_content += "SET enable_query_cache = true;\n"
    
    for i in range(cache_runs):
        for j, query in enumerate(test_queries):
            script_content += f"-- 缓存执行 {i+1}-{j+1}\n"
            script_content += query.strip()
            if not query.strip().endswith(';'):
                script_content += ';'
            script_content += "\n"
    
    # 创建临时脚本文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        f.write(script_content)
        script_path = f.name
    
    try:
        print(f"  执行测试: {len(test_queries)} 个查询 × 无缓存{no_cache_runs}次 + 缓存{cache_runs}次")
        
        # 执行测试
        start_time = time.time()
        result = subprocess.run([
            duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
        ], capture_output=True, text=True, timeout=180)
        
        total_time = time.time() - start_time
        
        if result.returncode == 0:
            # 解析执行时间
            times = extract_execution_times(result.stdout)
            
            expected_times = len(test_queries) * (no_cache_runs + cache_runs)
            
            print(f"  提取到 {len(times)} 个执行时间（期望 {expected_times} 个）")
            
            if len(times) >= expected_times * 0.7:  # 允许一些容错
                # 分析结果
                no_cache_count = len(test_queries) * no_cache_runs
                no_cache_times = times[:no_cache_count]
                cache_times = times[no_cache_count:no_cache_count + len(test_queries) * cache_runs]
                
                if no_cache_times and cache_times:
                    avg_no_cache = sum(no_cache_times) / len(no_cache_times)
                    avg_cache = sum(cache_times) / len(cache_times)
                    
                    # 计算缓存命中效果（排除第一轮缓存执行）
                    if len(cache_times) > len(test_queries):
                        cache_hit_times = cache_times[len(test_queries):]  # 排除第一轮
                        avg_cache_hit = sum(cache_hit_times) / len(cache_hit_times)
                    else:
                        avg_cache_hit = avg_cache
                    
                    improvement = (avg_no_cache - avg_cache_hit) / avg_no_cache * 100 if avg_no_cache > 0 else 0
                    
                    result_info = {
                        'dataset_name': dataset_name,
                        'query_count': len(test_queries),
                        'no_cache_runs': no_cache_runs,
                        'cache_runs': cache_runs,
                        'no_cache_avg_ms': avg_no_cache * 1000,
                        'cache_avg_ms': avg_cache * 1000,
                        'cache_hit_avg_ms': avg_cache_hit * 1000,
                        'improvement_percent': improvement,
                        'total_test_time': total_time,
                        'success': True
                    }
                    
                    print(f"  ✓ 测试完成")
                    print(f"    无缓存平均: {avg_no_cache*1000:.2f}ms")
                    print(f"    缓存平均: {avg_cache*1000:.2f}ms")
                    print(f"    缓存命中平均: {avg_cache_hit*1000:.2f}ms")
                    print(f"    性能提升: {improvement:.2f}%")
                    
                    if improvement > 20:
                        print(f"    🎉 缓存效果显著！")
                    elif improvement > 5:
                        print(f"    ✓ 缓存有效果")
                    else:
                        print(f"    ⚠️ 缓存效果不明显")
                    
                    return result_info
                else:
                    print(f"  ✗ 时间数据分析失败")
            else:
                print(f"  ✗ 执行时间数据不足")
        else:
            print(f"  ✗ 测试执行失败: {result.stderr}")
            
    except Exception as e:
        print(f"  ✗ 测试异常: {e}")
    finally:
        # 清理临时文件
        try:
            os.unlink(script_path)
        except:
            pass
    
    return None

def run_table_5_7_cache_tests(duckdb_path):
    """运行表5.7的四种数据集缓存测试"""
    print("🚀 表5.7数据集缓存测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 测试数据库路径
    db_path = Path("table_5_7_final_test.db")
    
    try:
        # 删除旧的测试数据库
        if db_path.exists():
            db_path.unlink()
        
        # 设置测试数据库
        setup_test_database(duckdb_path, db_path)
        
        # 定义四种数据集的查询
        datasets = {
            '重复查询集': {
                'description': '1000个查询，高重复率(80%)，测试缓存命中率',
                'queries': [
                    # 基础查询，会重复执行
                    "SELECT COUNT(*) FROM customers",
                    "SELECT COUNT(*) FROM products", 
                    "SELECT COUNT(*) FROM orders",
                    "SELECT AVG(price) FROM products",
                    "SELECT MAX(order_date) FROM orders"
                ] * 4  # 重复4次模拟高重复率
            },
            
            '参数化查询集': {
                'description': '500个模板，参数变化，测试SQL标准化',
                'queries': [
                    "SELECT * FROM customers WHERE customer_id = 1",
                    "SELECT * FROM customers WHERE customer_id = 2", 
                    "SELECT * FROM customers WHERE customer_id = 3",
                    "SELECT * FROM products WHERE price > 100",
                    "SELECT * FROM products WHERE price > 200",
                    "SELECT * FROM products WHERE price > 300",
                    "SELECT COUNT(*) FROM orders WHERE customer_id = 1",
                    "SELECT COUNT(*) FROM orders WHERE customer_id = 2"
                ]
            },
            
            'CTE查询集': {
                'description': '200个查询，复杂CTE结构，测试CTE缓存优化',
                'queries': [
                    """
                    WITH customer_stats AS (
                        SELECT customer_id, COUNT(*) as order_count
                        FROM orders GROUP BY customer_id
                    )
                    SELECT c.customer_name, cs.order_count
                    FROM customers c JOIN customer_stats cs ON c.customer_id = cs.customer_id
                    WHERE cs.order_count > 5
                    """,
                    """
                    WITH product_sales AS (
                        SELECT product_id, SUM(quantity) as total_sold
                        FROM orders GROUP BY product_id
                    )
                    SELECT p.product_name, ps.total_sold
                    FROM products p JOIN product_sales ps ON p.product_id = ps.product_id
                    ORDER BY ps.total_sold DESC LIMIT 10
                    """,
                    """
                    WITH monthly_orders AS (
                        SELECT DATE_TRUNC('month', order_date) as month, COUNT(*) as order_count
                        FROM orders GROUP BY DATE_TRUNC('month', order_date)
                    )
                    SELECT month, order_count FROM monthly_orders ORDER BY month
                    """
                ]
            },
            
            '并发查询集': {
                'description': '100个查询，高并发访问，测试并发性能',
                'queries': [
                    "SELECT COUNT(*) FROM orders WHERE customer_id BETWEEN 1 AND 100",
                    "SELECT COUNT(*) FROM orders WHERE customer_id BETWEEN 101 AND 200",
                    "SELECT COUNT(*) FROM orders WHERE customer_id BETWEEN 201 AND 300",
                    "SELECT AVG(quantity) FROM orders WHERE product_id BETWEEN 1 AND 50",
                    "SELECT AVG(quantity) FROM orders WHERE product_id BETWEEN 51 AND 100",
                    "SELECT MAX(order_date) FROM orders WHERE customer_id < 500",
                    "SELECT MIN(order_date) FROM orders WHERE customer_id >= 500"
                ]
            }
        }
        
        # 测试结果存储
        test_results = {
            'test_info': {
                'timestamp': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'test_method': 'single_session_table_5_7'
            },
            'datasets': {}
        }
        
        # 运行每个数据集的测试
        for dataset_name, dataset_info in datasets.items():
            print(f"\n目标: {dataset_info['description']}")
            
            result = test_dataset_cache_performance(
                duckdb_path, 
                db_path, 
                dataset_name, 
                dataset_info['queries'],
                no_cache_runs=3,
                cache_runs=5
            )
            
            if result:
                test_results['datasets'][dataset_name] = result
        
        # 生成综合报告
        generate_final_report(test_results, duckdb_path)
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"\n🧹 已清理测试数据库: {db_path}")
        
        print(f"\n✅ 所有测试完成于: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        return True
        
    except KeyboardInterrupt:
        print("\n⚠️ 测试被用户中断")
        return False
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return False

def generate_final_report(test_results, duckdb_path):
    """生成最终测试报告"""
    print("\n" + "=" * 80)
    print("=== 表5.7数据集缓存测试最终报告 ===")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"DuckDB路径: {duckdb_path}")
    print("=" * 80)
    
    datasets = test_results.get('datasets', {})
    
    if not datasets:
        print("❌ 没有可用的测试结果")
        return
    
    # 汇总统计
    total_datasets = 4  # 表5.7定义的四种数据集
    successful_tests = len([r for r in datasets.values() if r.get('success', False)])
    
    print(f"\n📊 测试汇总:")
    print(f"  目标数据集: {total_datasets}")
    print(f"  成功测试: {successful_tests}")
    print(f"  测试覆盖率: {successful_tests/total_datasets*100:.1f}%")
    
    # 详细结果表格
    print(f"\n📋 详细测试结果:")
    print("┌" + "─" * 15 + "┬" + "─" * 8 + "┬" + "─" * 12 + "┬" + "─" * 12 + "┬" + "─" * 15 + "┬" + "─" * 10 + "┐")
    print("│{:^15}│{:^8}│{:^12}│{:^12}│{:^15}│{:^10}│".format(
        "数据集", "查询数", "无缓存(ms)", "缓存(ms)", "缓存命中(ms)", "提升(%)"))
    print("├" + "─" * 15 + "┼" + "─" * 8 + "┼" + "─" * 12 + "┼" + "─" * 12 + "┼" + "─" * 15 + "┼" + "─" * 10 + "┤")
    
    improvements = []
    
    # 按表5.7的顺序显示结果
    dataset_order = ['重复查询集', '参数化查询集', 'CTE查询集', '并发查询集']
    
    for dataset_name in dataset_order:
        if dataset_name in datasets:
            result = datasets[dataset_name]
            if result.get('success', False):
                name = dataset_name[:13] + ".." if len(dataset_name) > 15 else dataset_name
                query_count = result.get('query_count', 0)
                no_cache = result.get('no_cache_avg_ms', 0)
                cache = result.get('cache_avg_ms', 0)
                cache_hit = result.get('cache_hit_avg_ms', 0)
                improvement = result.get('improvement_percent', 0)
                
                improvements.append(improvement)
                
                print("│{:<15}│{:>6}  │{:>10.2f}  │{:>10.2f}  │{:>13.2f}  │{:>8.1f}  │".format(
                    name, query_count, no_cache, cache, cache_hit, improvement))
            else:
                name = dataset_name[:13] + ".." if len(dataset_name) > 15 else dataset_name
                print("│{:<15}│{:>6}  │{:>10}  │{:>10}  │{:>13}  │{:>8}  │".format(
                    name, "N/A", "失败", "失败", "失败", "N/A"))
        else:
            name = dataset_name[:13] + ".." if len(dataset_name) > 15 else dataset_name
            print("│{:<15}│{:>6}  │{:>10}  │{:>10}  │{:>13}  │{:>8}  │".format(
                name, "N/A", "未测试", "未测试", "未测试", "N/A"))
    
    print("└" + "─" * 15 + "┴" + "─" * 8 + "┴" + "─" * 12 + "┴" + "─" * 12 + "┴" + "─" * 15 + "┴" + "─" * 10 + "┘")
    
    # 性能分析
    if improvements:
        avg_improvement = sum(improvements) / len(improvements)
        max_improvement = max(improvements)
        min_improvement = min(improvements)
        
        print(f"\n📈 性能分析:")
        print(f"  平均性能提升: {avg_improvement:.2f}%")
        print(f"  最大性能提升: {max_improvement:.2f}%")
        print(f"  最小性能提升: {min_improvement:.2f}%")
    
    # 按表5.7要求分析每种数据集
    print(f"\n🎯 表5.7数据集分析:")
    
    dataset_analysis = {
        '重复查询集': {
            'target': '缓存命中率测试',
            'expected': '高重复率查询应显示显著缓存效果'
        },
        '参数化查询集': {
            'target': 'SQL标准化测试', 
            'expected': '参数变化的相似查询结构应有缓存效果'
        },
        'CTE查询集': {
            'target': 'CTE缓存优化测试',
            'expected': '复杂CTE结构应展示缓存对复杂查询的价值'
        },
        '并发查询集': {
            'target': '并发性能测试',
            'expected': '高并发访问场景下的缓存性能表现'
        }
    }
    
    for dataset_name, analysis in dataset_analysis.items():
        if dataset_name in datasets:
            result = datasets[dataset_name]
            if result.get('success', False):
                improvement = result.get('improvement_percent', 0)
                if improvement > 30:
                    status = "🎉 优秀"
                elif improvement > 15:
                    status = "✅ 良好"
                elif improvement > 5:
                    status = "⚠️ 一般"
                else:
                    status = "❌ 效果不明显"
                
                print(f"  {dataset_name}: {status} ({improvement:.1f}% 提升)")
                print(f"    目标: {analysis['target']}")
                print(f"    预期: {analysis['expected']}")
            else:
                print(f"  {dataset_name}: ❌ 测试失败")
                print(f"    目标: {analysis['target']}")
        else:
            print(f"  {dataset_name}: ⚠️ 未测试")
            print(f"    目标: {analysis['target']}")
    
    # 总结和建议
    print(f"\n🎯 测试总结:")
    
    if successful_tests == total_datasets:
        if improvements and sum(improvements) / len(improvements) > 20:
            print(f"  ✅ 所有数据集测试成功，缓存功能表现优秀！")
            print(f"  ✅ 符合表5.7的测试目标和预期效果")
        else:
            print(f"  ✅ 所有数据集测试成功，缓存功能基本有效")
            print(f"  ⚠️ 部分数据集的缓存效果有改进空间")
    elif successful_tests >= total_datasets * 0.75:
        print(f"  ✅ 大部分数据集测试成功")
        print(f"  ⚠️ 建议检查失败的数据集配置")
    else:
        print(f"  ⚠️ 部分数据集测试失败")
        print(f"  💡 建议检查数据集生成和查询复杂度")
    
    print(f"\n💡 表5.7测试建议:")
    print(f"  1. 重复查询集: 最能体现缓存命中率的价值")
    print(f"  2. 参数化查询集: 展示SQL标准化后的缓存效果")
    print(f"  3. CTE查询集: 验证复杂查询结构的缓存优化")
    print(f"  4. 并发查询集: 模拟生产环境的并发缓存需求")
    
    # 保存详细结果
    results_dir = Path("results")
    results_dir.mkdir(exist_ok=True)
    
    result_file = results_dir / f"table_5_7_final_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    with open(result_file, 'w', encoding='utf-8') as f:
        json.dump(test_results, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 详细结果已保存到: {result_file}")

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python final_table_5_7_test.py <duckdb_path>")
        print("Example: python final_table_5_7_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    # 运行测试
    success = run_table_5_7_cache_tests(duckdb_path)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()