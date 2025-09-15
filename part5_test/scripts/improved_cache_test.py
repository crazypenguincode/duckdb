#!/usr/bin/env python3
"""
改进版缓存测试脚本
基于final_cache_test.py的正确方法，测试表5.7中四种数据集的缓存效果
使用单个DuckDB会话而不是多个进程，确保缓存在查询间保持
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

class ImprovedCacheTest:
    def __init__(self, duckdb_path):
        self.duckdb_path = duckdb_path
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / 'results'
        self.results_dir.mkdir(exist_ok=True)
        
        # 测试结果存储
        self.test_results = {
            'test_info': {
                'timestamp': datetime.now().isoformat(),
                'duckdb_path': duckdb_path,
                'test_method': 'single_session_correct_method'
            },
            'datasets': {}
        }
    
    def setup_test_database(self, db_path):
        """设置测试数据库"""
        print("=== 设置测试数据库 ===")
        
        # 读取数据库创建脚本
        create_sql_path = self.base_dir / 'dataset' / 'create_test_database_fixed.sql'
        
        if not create_sql_path.exists():
            raise FileNotFoundError(f"未找到数据库创建脚本: {create_sql_path}")
        
        with open(create_sql_path, 'r', encoding='utf-8') as f:
            setup_sql = f.read()
        
        print("创建测试数据...")
        result = subprocess.run([
            self.duckdb_path, str(db_path), "-c", setup_sql
        ], capture_output=True, text=True, timeout=120)
        
        if result.returncode != 0:
            raise RuntimeError(f"数据库创建失败: {result.stderr}")
        
        print("✓ 测试数据库创建成功")
        return True
    
    def load_queries_from_file(self, file_path):
        """从文件加载查询"""
        queries = []
        
        if not file_path.exists():
            print(f"⚠️ 查询文件不存在: {file_path}")
            return queries
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 按分号分割查询，过滤空查询
        raw_queries = content.split(';')
        
        for query in raw_queries:
            query = query.strip()
            if query and not query.startswith('--') and len(query) > 10:
                queries.append(query + ';')
        
        return queries
    
    def load_queries_from_json(self, json_path):
        """从JSON文件加载查询"""
        queries = []
        
        if not json_path.exists():
            print(f"⚠️ JSON文件不存在: {json_path}")
            return queries
        
        try:
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if isinstance(data, list):
                # 直接是查询列表
                queries = [q for q in data if isinstance(q, str) and len(q.strip()) > 10]
            elif isinstance(data, dict):
                # 可能包含查询的字典
                if 'queries' in data:
                    queries = data['queries']
                elif 'sql_queries' in data:
                    queries = data['sql_queries']
                else:
                    # 尝试从值中提取查询
                    for key, value in data.items():
                        if isinstance(value, list):
                            queries.extend([q for q in value if isinstance(q, str) and len(q.strip()) > 10])
                        elif isinstance(value, str) and len(value.strip()) > 10:
                            queries.append(value)
        
        except Exception as e:
            print(f"⚠️ 加载JSON文件失败: {e}")
        
        return queries
    
    def test_repeat_queries_dataset(self, db_path):
        """测试重复查询集 - 1000个查询，高重复率(80%)"""
        print("\n=== 测试重复查询集 ===")
        print("目标: 缓存命中率测试")
        
        dataset_dir = self.base_dir / 'dataset' / 'repeat_queries'
        
        # 加载查询
        queries = []
        
        # 尝试从不同文件加载查询
        query_files = [
            dataset_dir / 'repeat_queries_all.sql',
            dataset_dir / 'repeat_queries_batch_01.sql',
            dataset_dir / 'repeat_queries_batch_02.sql',
            dataset_dir / 'repeat_queries_batch_03.sql'
        ]
        
        for query_file in query_files:
            if query_file.exists():
                file_queries = self.load_queries_from_file(query_file)
                queries.extend(file_queries)
                if len(queries) >= 100:  # 限制查询数量以便测试
                    break
        
        if not queries:
            print("⚠️ 未找到重复查询，生成测试查询")
            queries = self.generate_repeat_test_queries()
        
        # 限制查询数量并创建重复模式
        base_queries = queries[:20]  # 取前20个基础查询
        repeat_queries = []
        
        # 创建80%重复率的查询序列
        for i in range(100):
            if i < 80:  # 80%重复
                repeat_queries.append(random.choice(base_queries))
            else:  # 20%新查询
                if i - 80 < len(queries):
                    repeat_queries.append(queries[i - 80])
                else:
                    repeat_queries.append(random.choice(base_queries))
        
        # 随机打乱顺序
        random.shuffle(repeat_queries)
        
        print(f"准备测试 {len(repeat_queries)} 个查询（基于 {len(base_queries)} 个基础查询）")
        
        # 执行缓存测试
        result = self.execute_cache_test_session(
            db_path, 
            repeat_queries, 
            "重复查询集",
            no_cache_runs=3,
            cache_runs=10  # 更多缓存运行以观察重复效果
        )
        
        # 分析重复查询的缓存效果
        if result:
            result['dataset_type'] = 'repeat_queries'
            result['repeat_rate'] = 0.8
            result['base_query_count'] = len(base_queries)
            result['total_query_count'] = len(repeat_queries)
            
            self.test_results['datasets']['重复查询集'] = result
        
        return result
    
    def test_parameterized_queries_dataset(self, db_path):
        """测试参数化查询集 - 500个模板，参数变化"""
        print("\n=== 测试参数化查询集 ===")
        print("目标: SQL标准化测试")
        
        dataset_dir = self.base_dir / 'dataset' / 'parameterized_queries'
        
        # 加载查询
        queries = []
        
        # 尝试从模板文件加载
        template_files = list(dataset_dir.glob('template_*.sql'))
        
        for template_file in template_files[:5]:  # 限制模板数量
            if template_file.exists():
                file_queries = self.load_queries_from_file(template_file)
                queries.extend(file_queries)
        
        # 也尝试从主文件加载
        main_file = dataset_dir / 'parameterized_queries_all.sql'
        if main_file.exists():
            main_queries = self.load_queries_from_file(main_file)
            queries.extend(main_queries)
        
        if not queries:
            print("⚠️ 未找到参数化查询，生成测试查询")
            queries = self.generate_parameterized_test_queries()
        
        # 限制查询数量
        queries = queries[:100]
        
        print(f"准备测试 {len(queries)} 个参数化查询")
        
        # 执行缓存测试
        result = self.execute_cache_test_session(
            db_path, 
            queries, 
            "参数化查询集",
            no_cache_runs=3,
            cache_runs=5
        )
        
        if result:
            result['dataset_type'] = 'parameterized_queries'
            result['template_based'] = True
            
            self.test_results['datasets']['参数化查询集'] = result
        
        return result
    
    def test_cte_queries_dataset(self, db_path):
        """测试CTE查询集 - 200个查询，复杂CTE结构"""
        print("\n=== 测试CTE查询集 ===")
        print("目标: CTE缓存优化测试")
        
        dataset_dir = self.base_dir / 'dataset' / 'cte_queries'
        
        # 加载查询
        queries = []
        
        # 尝试从不同复杂度文件加载
        cte_files = [
            dataset_dir / 'cte_queries_all.sql',
            dataset_dir / 'cte_queries_high.sql',
            dataset_dir / 'cte_queries_medium.sql'
        ]
        
        for cte_file in cte_files:
            if cte_file.exists():
                file_queries = self.load_queries_from_file(cte_file)
                queries.extend(file_queries)
        
        if not queries:
            print("⚠️ 未找到CTE查询，生成测试查询")
            queries = self.generate_cte_test_queries()
        
        # 限制查询数量
        queries = queries[:50]  # CTE查询通常较复杂，减少数量
        
        print(f"准备测试 {len(queries)} 个CTE查询")
        
        # 执行缓存测试
        result = self.execute_cache_test_session(
            db_path, 
            queries, 
            "CTE查询集",
            no_cache_runs=3,
            cache_runs=5
        )
        
        if result:
            result['dataset_type'] = 'cte_queries'
            result['complex_structure'] = True
            
            self.test_results['datasets']['CTE查询集'] = result
        
        return result
    
    def test_concurrent_queries_dataset(self, db_path):
        """测试并发查询集 - 100个查询，高并发访问"""
        print("\n=== 测试并发查询集 ===")
        print("目标: 并发性能测试")
        
        dataset_dir = self.base_dir / 'dataset' / 'concurrent_queries'
        
        # 加载查询
        queries = []
        
        # 尝试从不同并发类型文件加载
        concurrent_files = [
            dataset_dir / 'concurrent_queries_all.sql',
            dataset_dir / 'concurrent_queries_高并发轻量查询.sql',
            dataset_dir / 'concurrent_queries_中等并发混合查询.sql'
        ]
        
        for concurrent_file in concurrent_files:
            if concurrent_file.exists():
                file_queries = self.load_queries_from_file(concurrent_file)
                queries.extend(file_queries)
        
        if not queries:
            print("⚠️ 未找到并发查询，生成测试查询")
            queries = self.generate_concurrent_test_queries()
        
        # 限制查询数量
        queries = queries[:80]
        
        print(f"准备测试 {len(queries)} 个并发查询")
        
        # 执行缓存测试（模拟并发场景）
        result = self.execute_cache_test_session(
            db_path, 
            queries, 
            "并发查询集",
            no_cache_runs=3,
            cache_runs=8  # 更多运行以模拟并发
        )
        
        if result:
            result['dataset_type'] = 'concurrent_queries'
            result['concurrent_simulation'] = True
            
            self.test_results['datasets']['并发查询集'] = result
        
        return result
    
    def execute_cache_test_session(self, db_path, queries, dataset_name, no_cache_runs=3, cache_runs=5):
        """在单个DuckDB会话中执行缓存测试"""
        print(f"执行 {dataset_name} 缓存测试...")
        
        if not queries:
            print("⚠️ 没有查询可执行")
            return None
        
        # 随机选择一些查询进行测试（避免测试时间过长）
        test_queries = random.sample(queries, min(len(queries), 10))
        
        # 创建测试脚本
        script_content = ".timer on\n.echo off\n\n"
        
        # 禁用缓存阶段
        script_content += f"-- 禁用缓存测试 ({no_cache_runs} 次)\n"
        script_content += "SET enable_query_cache = false;\n"
        
        for i in range(no_cache_runs):
            for j, query in enumerate(test_queries):
                script_content += f"-- 无缓存执行 {i+1}-{j+1}\n"
                script_content += query + "\n"
        
        # 启用缓存阶段
        script_content += f"\n-- 启用缓存测试 ({cache_runs} 次)\n"
        script_content += "SET enable_query_cache = true;\n"
        
        for i in range(cache_runs):
            for j, query in enumerate(test_queries):
                script_content += f"-- 缓存执行 {i+1}-{j+1}\n"
                script_content += query + "\n"
        
        # 创建临时脚本文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            print(f"  执行 {len(test_queries)} 个查询，每个查询无缓存{no_cache_runs}次，缓存{cache_runs}次")
            
            # 执行测试
            start_time = time.time()
            result = subprocess.run([
                self.duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
            ], capture_output=True, text=True, timeout=300)
            
            total_time = time.time() - start_time
            
            if result.returncode == 0:
                # 解析执行时间
                times = self.extract_execution_times(result.stdout)
                
                expected_times = len(test_queries) * (no_cache_runs + cache_runs)
                
                if len(times) >= expected_times * 0.8:  # 允许一些容错
                    # 分析结果
                    no_cache_count = len(test_queries) * no_cache_runs
                    no_cache_times = times[:no_cache_count]
                    cache_times = times[no_cache_count:]
                    
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
                            'all_times': times,
                            'success': True
                        }
                        
                        print(f"  ✓ 测试完成")
                        print(f"    查询数量: {len(test_queries)}")
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
                    print(f"  ✗ 执行时间数据不足: 期望{expected_times}，实际{len(times)}")
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
    
    def extract_execution_times(self, output):
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
    
    def generate_repeat_test_queries(self):
        """生成重复测试查询"""
        return [
            "SELECT COUNT(*) FROM customers",
            "SELECT COUNT(*) FROM products", 
            "SELECT COUNT(*) FROM orders",
            "SELECT AVG(price) FROM products",
            "SELECT MAX(order_date) FROM orders",
            "SELECT category, COUNT(*) FROM products GROUP BY category",
            "SELECT customer_id, COUNT(*) FROM orders GROUP BY customer_id LIMIT 10",
            "SELECT * FROM products WHERE price > 100 LIMIT 5",
            "SELECT * FROM customers WHERE city = 'Beijing' LIMIT 5",
            "SELECT o.*, c.name FROM orders o JOIN customers c ON o.customer_id = c.id LIMIT 10"
        ]
    
    def generate_parameterized_test_queries(self):
        """生成参数化测试查询"""
        queries = []
        
        # 不同参数的相似查询
        for i in range(1, 21):
            queries.append(f"SELECT * FROM products WHERE price > {i * 50} LIMIT 10")
            queries.append(f"SELECT * FROM customers WHERE id = {i}")
            queries.append(f"SELECT COUNT(*) FROM orders WHERE customer_id = {i}")
        
        return queries
    
    def generate_cte_test_queries(self):
        """生成CTE测试查询"""
        return [
            """
            WITH customer_stats AS (
                SELECT customer_id, COUNT(*) as order_count, SUM(total_amount) as total_spent
                FROM orders GROUP BY customer_id
            )
            SELECT c.name, cs.order_count, cs.total_spent
            FROM customers c JOIN customer_stats cs ON c.id = cs.customer_id
            WHERE cs.order_count > 2
            """,
            """
            WITH product_sales AS (
                SELECT product_id, SUM(quantity) as total_sold
                FROM order_items GROUP BY product_id
            ),
            top_products AS (
                SELECT ps.product_id, ps.total_sold, p.name, p.price
                FROM product_sales ps JOIN products p ON ps.product_id = p.id
                ORDER BY ps.total_sold DESC LIMIT 10
            )
            SELECT * FROM top_products
            """,
            """
            WITH monthly_sales AS (
                SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as monthly_total
                FROM orders GROUP BY DATE_TRUNC('month', order_date)
            )
            SELECT month, monthly_total, 
                   LAG(monthly_total) OVER (ORDER BY month) as prev_month,
                   monthly_total - LAG(monthly_total) OVER (ORDER BY month) as growth
            FROM monthly_sales ORDER BY month
            """
        ]
    
    def generate_concurrent_test_queries(self):
        """生成并发测试查询"""
        queries = []
        
        # 模拟不同类型的并发查询
        for i in range(20):
            queries.extend([
                f"SELECT COUNT(*) FROM products WHERE category = 'Category_{i % 5}'",
                f"SELECT AVG(price) FROM products WHERE id BETWEEN {i*10} AND {(i+1)*10}",
                f"SELECT * FROM customers WHERE id = {i + 1}",
                f"SELECT COUNT(*) FROM orders WHERE customer_id BETWEEN {i} AND {i+5}"
            ])
        
        return queries
    
    def generate_comprehensive_report(self):
        """生成综合测试报告"""
        print("\n" + "=" * 80)
        print("=== 表5.7数据集缓存测试综合报告 ===")
        print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"DuckDB路径: {self.duckdb_path}")
        print("=" * 80)
        
        if not self.test_results['datasets']:
            print("❌ 没有可用的测试结果")
            return
        
        # 汇总统计
        total_datasets = len(self.test_results['datasets'])
        successful_tests = len([r for r in self.test_results['datasets'].values() if r.get('success', False)])
        
        print(f"\n📊 测试汇总:")
        print(f"  测试数据集: {total_datasets}")
        print(f"  成功测试: {successful_tests}")
        
        # 详细结果表格
        print(f"\n📋 详细测试结果:")
        print("┌" + "─" * 20 + "┬" + "─" * 10 + "┬" + "─" * 12 + "┬" + "─" * 12 + "┬" + "─" * 15 + "┬" + "─" * 10 + "┐")
        print("│{:^20}│{:^10}│{:^12}│{:^12}│{:^15}│{:^10}│".format(
            "数据集类型", "查询数", "无缓存(ms)", "缓存(ms)", "缓存命中(ms)", "提升(%)"))
        print("├" + "─" * 20 + "┼" + "─" * 10 + "┼" + "─" * 12 + "┼" + "─" * 12 + "┼" + "─" * 15 + "┼" + "─" * 10 + "┤")
        
        improvements = []
        
        for dataset_name, result in self.test_results['datasets'].items():
            if result.get('success', False):
                name = dataset_name[:18] + ".." if len(dataset_name) > 20 else dataset_name
                query_count = result.get('query_count', 0)
                no_cache = result.get('no_cache_avg_ms', 0)
                cache = result.get('cache_avg_ms', 0)
                cache_hit = result.get('cache_hit_avg_ms', 0)
                improvement = result.get('improvement_percent', 0)
                
                improvements.append(improvement)
                
                print("│{:<20}│{:>8}  │{:>10.2f}  │{:>10.2f}  │{:>13.2f}  │{:>8.1f}  │".format(
                    name, query_count, no_cache, cache, cache_hit, improvement))
            else:
                name = dataset_name[:18] + ".." if len(dataset_name) > 20 else dataset_name
                print("│{:<20}│{:>8}  │{:>10}  │{:>10}  │{:>13}  │{:>8}  │".format(
                    name, "N/A", "失败", "失败", "失败", "N/A"))
        
        print("└" + "─" * 20 + "┴" + "─" * 10 + "┴" + "─" * 12 + "┴" + "─" * 12 + "┴" + "─" * 15 + "┴" + "─" * 10 + "┘")
        
        # 性能分析
        if improvements:
            avg_improvement = sum(improvements) / len(improvements)
            max_improvement = max(improvements)
            min_improvement = min(improvements)
            
            print(f"\n📈 性能分析:")
            print(f"  平均性能提升: {avg_improvement:.2f}%")
            print(f"  最大性能提升: {max_improvement:.2f}%")
            print(f"  最小性能提升: {min_improvement:.2f}%")
        
        # 按数据集类型分析
        print(f"\n🎯 按数据集类型分析:")
        
        dataset_analysis = {
            '重复查询集': '测试缓存命中率，重复查询应显示显著缓存效果',
            '参数化查询集': '测试SQL标准化，相似查询结构的缓存效果',
            'CTE查询集': '测试复杂查询缓存，CTE结构的优化效果',
            '并发查询集': '测试并发场景下的缓存性能表现'
        }
        
        for dataset_name, description in dataset_analysis.items():
            if dataset_name in self.test_results['datasets']:
                result = self.test_results['datasets'][dataset_name]
                if result.get('success', False):
                    improvement = result.get('improvement_percent', 0)
                    if improvement > 20:
                        status = "🎉 优秀"
                    elif improvement > 10:
                        status = "✅ 良好"
                    elif improvement > 0:
                        status = "⚠️ 一般"
                    else:
                        status = "❌ 无效果"
                    
                    print(f"  {dataset_name}: {status} ({improvement:.1f}% 提升)")
                    print(f"    {description}")
                else:
                    print(f"  {dataset_name}: ❌ 测试失败")
                    print(f"    {description}")
            else:
                print(f"  {dataset_name}: ⚠️ 未测试")
                print(f"    {description}")
        
        # 结论和建议
        print(f"\n🎯 测试结论:")
        
        if successful_tests == total_datasets and improvements:
            avg_improvement = sum(improvements) / len(improvements)
            if avg_improvement > 15:
                print(f"  ✅ 所有数据集测试成功，缓存功能表现优秀！")
                print(f"  ✅ 平均性能提升 {avg_improvement:.1f}%，符合预期效果")
            elif avg_improvement > 5:
                print(f"  ✅ 所有数据集测试成功，缓存功能基本有效")
                print(f"  ⚠️ 平均性能提升 {avg_improvement:.1f}%，有改进空间")
            else:
                print(f"  ⚠️ 测试完成但缓存效果不明显")
                print(f"  💡 可能需要更复杂的查询或更大的数据集")
        else:
            print(f"  ⚠️ 部分测试失败或缓存效果有限")
            print(f"  💡 建议检查数据集生成和查询复杂度")
        
        print(f"\n💡 使用建议:")
        print(f"  1. 重复查询集最适合展示缓存命中效果")
        print(f"  2. CTE查询集能体现复杂查询的缓存价值")
        print(f"  3. 参数化查询集测试SQL标准化的缓存效果")
        print(f"  4. 并发查询集模拟真实生产环境的缓存需求")
        
        # 保存详细结果
        result_file = self.results_dir / f"table_5_7_cache_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(self.test_results, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 详细结果已保存到: {result_file}")
    
    def run_all_tests(self):
        """运行所有数据集的缓存测试"""
        print("🚀 开始表5.7数据集缓存测试")
        print(f"DuckDB路径: {self.duckdb_path}")
        print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)
        
        # 测试数据库路径
        db_path = Path("table_5_7_cache_test.db")
        
        try:
            # 删除旧的测试数据库
            if db_path.exists():
                db_path.unlink()
            
            # 设置测试数据库
            self.setup_test_database(db_path)
            
            # 运行四种数据集测试
            print("\n开始测试四种数据集...")
            
            # 1. 重复查询集测试
            self.test_repeat_queries_dataset(db_path)
            
            # 2. 参数化查询集测试
            self.test_parameterized_queries_dataset(db_path)
            
            # 3. CTE查询集测试
            self.test_cte_queries_dataset(db_path)
            
            # 4. 并发查询集测试
            self.test_concurrent_queries_dataset(db_path)
            
            # 生成综合报告
            self.generate_comprehensive_report()
            
            # 清理测试数据库
            if db_path.exists():
                db_path.unlink()
                print(f"\n🧹 已清理测试数据库: {db_path}")
            
            print(f"\n✅ 所有测试完成于: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            
        except KeyboardInterrupt:
            print("\n⚠️ 测试被用户中断")
            return False
        except Exception as e:
            print(f"\n❌ 测试过程中发生错误: {e}")
            import traceback
            traceback.print_exc()
            return False
        
        return True

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python improved_cache_test.py <duckdb_path>")
        print("Example: python improved_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    # 创建测试实例并运行
    tester = ImprovedCacheTest(duckdb_path)
    success = tester.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()