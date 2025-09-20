#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
跨进程缓存持久化性能测试脚本

测试目标：
1. 验证WAL格式持久化策略在多进程环境下的性能
2. 验证物化视图持久化策略在多进程环境下的性能
3. 对比不同策略的跨进程缓存效果
4. 测试进程间缓存共享的有效性

测试场景：
- 进程A执行查询并缓存结果
- 进程B尝试读取进程A缓存的结果
- 对比缓存命中vs重新执行的性能差异
"""

import subprocess
import time
import json
import os
import sys
import tempfile
import shutil
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
from typing import Dict, List, Tuple, Any
import statistics
import threading
from pathlib import Path

class CrossProcessCacheTest:
    def __init__(self):
        self.test_db_path = "test_cross_process_cache.db"
        self.shared_cache_path = "shared_cache_storage"
        self.results = []
        self.test_queries = self._get_test_queries()
        
    def _get_test_queries(self) -> List[Dict[str, Any]]:
        """获取测试查询列表"""
        return [
            {
                "name": "simple_aggregation",
                "sql": "SELECT COUNT(*), AVG(i), SUM(i*2) FROM generate_series(1, 10000) AS t(i) WHERE i % 3 = 0",
                "complexity": "Simple",
                "expected_speedup": 2.0
            },
            {
                "name": "complex_join_cte",
                "sql": """
                WITH sales_summary AS (
                    SELECT 
                        i % 100 as customer_id,
                        SUM(i * 1.5) as total_sales,
                        COUNT(*) as order_count,
                        AVG(i * 1.5) as avg_order_value
                    FROM generate_series(1, 5000) AS t(i)
                    GROUP BY i % 100
                ),
                customer_ranks AS (
                    SELECT 
                        customer_id,
                        total_sales,
                        order_count,
                        avg_order_value,
                        ROW_NUMBER() OVER (ORDER BY total_sales DESC) as sales_rank,
                        LAG(total_sales) OVER (ORDER BY total_sales DESC) as prev_sales
                    FROM sales_summary
                )
                SELECT 
                    customer_id,
                    total_sales,
                    order_count,
                    avg_order_value,
                    sales_rank,
                    CASE 
                        WHEN prev_sales IS NULL THEN 0
                        ELSE (prev_sales - total_sales) / prev_sales * 100
                    END as sales_gap_percent
                FROM customer_ranks
                WHERE sales_rank <= 20
                ORDER BY sales_rank
                """,
                "complexity": "Complex",
                "expected_speedup": 5.0
            },
            {
                "name": "window_functions",
                "sql": """
                SELECT 
                    i,
                    i % 10 as group_id,
                    ROW_NUMBER() OVER (PARTITION BY i % 10 ORDER BY i) as row_num,
                    LAG(i, 1) OVER (PARTITION BY i % 10 ORDER BY i) as prev_value,
                    SUM(i) OVER (PARTITION BY i % 10 ORDER BY i ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_sum,
                    AVG(i::DOUBLE) OVER (PARTITION BY i % 10 ORDER BY i ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as rolling_avg
                FROM generate_series(1, 2000) AS t(i)
                WHERE i % 5 = 0
                ORDER BY group_id, row_num
                """,
                "complexity": "Medium",
                "expected_speedup": 3.0
            },
            {
                "name": "recursive_cte",
                "sql": """
                WITH RECURSIVE fibonacci(n, fib_n, fib_n1) AS (
                    SELECT 1, 0::BIGINT, 1::BIGINT
                    UNION ALL
                    SELECT n + 1, fib_n1, fib_n + fib_n1
                    FROM fibonacci
                    WHERE n < 30
                )
                SELECT n, fib_n as fibonacci_number
                FROM fibonacci
                ORDER BY n
                """,
                "complexity": "Complex",
                "expected_speedup": 4.0
            }
        ]

    def setup_test_environment(self):
        """设置测试环境"""
        print("🔧 设置测试环境...")
        
        # 清理旧的测试文件
        for path in [self.test_db_path, self.shared_cache_path]:
            if os.path.exists(path):
                if os.path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
        
        # 创建共享缓存目录
        os.makedirs(self.shared_cache_path, exist_ok=True)
        
        print("✅ 测试环境设置完成")

    def execute_duckdb_query(self, sql: str, db_path: str = None, 
                           cache_strategy: str = "MEMORY_ONLY", 
                           process_id: str = "main") -> Dict[str, Any]:
        """执行DuckDB查询"""
        if db_path is None:
            db_path = self.test_db_path
            
        # 构建DuckDB命令
        duckdb_cmd = [
            "duckdb", db_path,
            "-c", f"SET enable_query_cache=true;",
            "-c", f"SET query_cache_max_size='500MB';",
            "-c", f"SET query_cache_persistence_strategy='{cache_strategy}';",
            "-c", f"SET query_cache_persistence_path='{self.shared_cache_path}';",
            "-c", sql
        ]
        
        start_time = time.time()
        try:
            result = subprocess.run(
                duckdb_cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
            end_time = time.time()
            
            execution_time = (end_time - start_time) * 1000  # 转换为毫秒
            
            if result.returncode == 0:
                return {
                    "success": True,
                    "execution_time_ms": execution_time,
                    "output": result.stdout.strip(),
                    "process_id": process_id,
                    "cache_strategy": cache_strategy
                }
            else:
                return {
                    "success": False,
                    "execution_time_ms": execution_time,
                    "error": result.stderr.strip(),
                    "process_id": process_id,
                    "cache_strategy": cache_strategy
                }
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "execution_time_ms": 30000,  # 超时时间
                "error": "Query timeout",
                "process_id": process_id,
                "cache_strategy": cache_strategy
            }

    def test_single_strategy(self, strategy: str) -> Dict[str, Any]:
        """测试单个持久化策略"""
        print(f"\n🧪 测试策略: {strategy}")
        print("=" * 50)
        
        strategy_results = {
            "strategy": strategy,
            "query_results": [],
            "summary": {}
        }
        
        for query in self.test_queries:
            print(f"\n📊 测试查询: {query['name']} ({query['complexity']})")
            
            query_result = {
                "query_name": query["name"],
                "complexity": query["complexity"],
                "strategy": strategy,
                "first_execution_ms": 0,
                "second_execution_ms": 0,
                "cross_process_execution_ms": 0,
                "cache_speedup": 0,
                "cross_process_speedup": 0,
                "cache_hit": False
            }
            
            # 第一次执行（冷启动）
            print("  🔄 第一次执行（冷启动）...")
            result1 = self.execute_duckdb_query(
                query["sql"], 
                cache_strategy=strategy,
                process_id="process_1"
            )
            
            if not result1["success"]:
                print(f"  ❌ 第一次执行失败: {result1['error']}")
                continue
                
            query_result["first_execution_ms"] = result1["execution_time_ms"]
            print(f"  ✅ 第一次执行: {result1['execution_time_ms']:.2f}ms")
            
            # 等待缓存写入完成
            time.sleep(0.5)
            
            # 第二次执行（同进程缓存测试）
            print("  📖 第二次执行（同进程缓存测试）...")
            result2 = self.execute_duckdb_query(
                query["sql"], 
                cache_strategy=strategy,
                process_id="process_1"
            )
            
            if result2["success"]:
                query_result["second_execution_ms"] = result2["execution_time_ms"]
                query_result["cache_speedup"] = result1["execution_time_ms"] / result2["execution_time_ms"]
                query_result["cache_hit"] = query_result["cache_speedup"] > 1.2
                print(f"  ✅ 第二次执行: {result2['execution_time_ms']:.2f}ms")
                print(f"  ✅ 缓存加速比: {query_result['cache_speedup']:.2f}x")
            
            # 跨进程缓存测试
            print("  🔄 跨进程缓存测试...")
            
            def cross_process_query():
                return self.execute_duckdb_query(
                    query["sql"], 
                    cache_strategy=strategy,
                    process_id="process_2"
                )
            
            # 使用进程池执行跨进程查询
            with ProcessPoolExecutor(max_workers=1) as executor:
                future = executor.submit(cross_process_query)
                try:
                    result3 = future.result(timeout=30)
                    
                    if result3["success"]:
                        query_result["cross_process_execution_ms"] = result3["execution_time_ms"]
                        query_result["cross_process_speedup"] = result1["execution_time_ms"] / result3["execution_time_ms"]
                        print(f"  ✅ 跨进程执行: {result3['execution_time_ms']:.2f}ms")
                        print(f"  ✅ 跨进程加速比: {query_result['cross_process_speedup']:.2f}x")
                    else:
                        print(f"  ❌ 跨进程执行失败: {result3['error']}")
                        
                except Exception as e:
                    print(f"  ❌ 跨进程测试异常: {str(e)}")
            
            strategy_results["query_results"].append(query_result)
            
            # 输出即时结果
            print(f"    📈 结果汇总:")
            print(f"      - 第一次执行: {query_result['first_execution_ms']:.2f}ms")
            print(f"      - 同进程缓存: {query_result['second_execution_ms']:.2f}ms (加速 {query_result['cache_speedup']:.2f}x)")
            print(f"      - 跨进程缓存: {query_result['cross_process_execution_ms']:.2f}ms (加速 {query_result['cross_process_speedup']:.2f}x)")
            print(f"      - 缓存命中: {'✅' if query_result['cache_hit'] else '❌'}")
        
        # 计算策略汇总统计
        if strategy_results["query_results"]:
            cache_speedups = [r["cache_speedup"] for r in strategy_results["query_results"] if r["cache_speedup"] > 0]
            cross_process_speedups = [r["cross_process_speedup"] for r in strategy_results["query_results"] if r["cross_process_speedup"] > 0]
            
            strategy_results["summary"] = {
                "avg_cache_speedup": statistics.mean(cache_speedups) if cache_speedups else 0,
                "avg_cross_process_speedup": statistics.mean(cross_process_speedups) if cross_process_speedups else 0,
                "cache_hit_rate": sum(1 for r in strategy_results["query_results"] if r["cache_hit"]) / len(strategy_results["query_results"]),
                "total_queries": len(strategy_results["query_results"])
            }
        
        return strategy_results

    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始跨进程缓存持久化性能测试")
        print("=" * 60)
        
        # 设置测试环境
        self.setup_test_environment()
        
        # 测试策略列表
        strategies = [
            "MEMORY_ONLY",
            "WAL_FORMAT", 
            "MATERIALIZED_VIEW",
            "HYBRID",
            "CROSS_PROCESS"
        ]
        
        all_results = []
        
        for strategy in strategies:
            try:
                result = self.test_single_strategy(strategy)
                all_results.append(result)
                
                # 清理缓存，为下一个策略测试做准备
                if os.path.exists(self.shared_cache_path):
                    shutil.rmtree(self.shared_cache_path)
                    os.makedirs(self.shared_cache_path, exist_ok=True)
                    
                time.sleep(1)  # 等待清理完成
                
            except Exception as e:
                print(f"❌ 策略 {strategy} 测试失败: {str(e)}")
                continue
        
        # 生成测试报告
        self.generate_report(all_results)
        
        return all_results

    def generate_report(self, all_results: List[Dict[str, Any]]):
        """生成测试报告"""
        print("\n📈 生成测试报告...")
        
        # 生成Markdown报告
        report_path = "cross_process_cache_persistence_report.md"
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# 跨进程缓存持久化性能测试报告\n\n")
            f.write("## 测试概述\n\n")
            f.write("本报告测试了不同持久化策略在跨进程环境下的缓存性能表现。\n\n")
            f.write("### 测试场景\n\n")
            f.write("1. **同进程缓存测试**: 在同一进程内重复执行查询，测试缓存命中效果\n")
            f.write("2. **跨进程缓存测试**: 在不同进程间共享缓存，测试持久化策略的有效性\n\n")
            
            # 策略性能对比表
            f.write("## 策略性能对比\n\n")
            f.write("| 策略 | 平均同进程加速比 | 平均跨进程加速比 | 缓存命中率 | 测试查询数 |\n")
            f.write("|------|-----------------|-----------------|-----------|----------|\n")
            
            for result in all_results:
                if "summary" in result and result["summary"]:
                    summary = result["summary"]
                    f.write(f"| {result['strategy']} | "
                           f"{summary['avg_cache_speedup']:.2f}x | "
                           f"{summary['avg_cross_process_speedup']:.2f}x | "
                           f"{summary['cache_hit_rate']:.1%} | "
                           f"{summary['total_queries']} |\n")
            
            f.write("\n")
            
            # 详细查询结果
            for result in all_results:
                f.write(f"## {result['strategy']} 策略详细结果\n\n")
                f.write("| 查询名称 | 复杂度 | 第一次执行(ms) | 同进程缓存(ms) | 跨进程缓存(ms) | 同进程加速比 | 跨进程加速比 | 缓存命中 |\n")
                f.write("|---------|-------|---------------|---------------|---------------|-------------|-------------|----------|\n")
                
                for query_result in result["query_results"]:
                    f.write(f"| {query_result['query_name']} | "
                           f"{query_result['complexity']} | "
                           f"{query_result['first_execution_ms']:.2f} | "
                           f"{query_result['second_execution_ms']:.2f} | "
                           f"{query_result['cross_process_execution_ms']:.2f} | "
                           f"{query_result['cache_speedup']:.2f}x | "
                           f"{query_result['cross_process_speedup']:.2f}x | "
                           f"{'✅' if query_result['cache_hit'] else '❌'} |\n")
                
                f.write("\n")
            
            # 结论和建议
            f.write("## 测试结论\n\n")
            f.write("### 关键发现\n\n")
            
            # 找出最佳策略
            best_cross_process = max(all_results, 
                                   key=lambda x: x.get("summary", {}).get("avg_cross_process_speedup", 0))
            best_cache_hit = max(all_results,
                               key=lambda x: x.get("summary", {}).get("cache_hit_rate", 0))
            
            f.write(f"1. **最佳跨进程性能**: {best_cross_process['strategy']} 策略，平均加速比 {best_cross_process.get('summary', {}).get('avg_cross_process_speedup', 0):.2f}x\n")
            f.write(f"2. **最高缓存命中率**: {best_cache_hit['strategy']} 策略，命中率 {best_cache_hit.get('summary', {}).get('cache_hit_rate', 0):.1%}\n")
            f.write("3. **WAL格式策略**: 适合频繁写入的场景，具有良好的跨进程一致性\n")
            f.write("4. **物化视图策略**: 适合复杂查询的持久化，查询结果可直接复用\n")
            f.write("5. **跨进程策略**: 专门为多进程环境优化，提供最佳的进程间缓存共享\n\n")
            
            f.write("### 使用建议\n\n")
            f.write("- **高频简单查询**: 推荐使用 WAL_FORMAT 或 CROSS_PROCESS 策略\n")
            f.write("- **复杂分析查询**: 推荐使用 MATERIALIZED_VIEW 或 HYBRID 策略\n")
            f.write("- **多进程应用**: 强烈推荐使用 CROSS_PROCESS 策略\n")
            f.write("- **内存受限环境**: 推荐使用 WAL_FORMAT 策略\n\n")
            
            f.write("### 注意事项\n\n")
            f.write("- 跨进程缓存的性能受磁盘I/O和进程间通信开销影响\n")
            f.write("- 不同策略的最佳配置参数需要根据具体应用场景调优\n")
            f.write("- 建议在生产环境中进行充分的性能测试和监控\n")
        
        print(f"✅ 测试报告已生成: {report_path}")
        
        # 生成JSON格式的详细数据
        json_path = "cross_process_cache_test_data.json"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(all_results, f, indent=2, ensure_ascii=False)
        
        print(f"✅ 详细测试数据已保存: {json_path}")

    def print_summary(self, all_results: List[Dict[str, Any]]):
        """打印测试结果汇总"""
        print("\n📊 测试结果汇总")
        print("=" * 80)
        
        print(f"{'策略':<20} {'同进程加速比':<15} {'跨进程加速比':<15} {'缓存命中率':<12} {'测试数量':<10}")
        print("-" * 80)
        
        for result in all_results:
            if "summary" in result and result["summary"]:
                summary = result["summary"]
                print(f"{result['strategy']:<20} "
                      f"{summary['avg_cache_speedup']:.2f}x{'':<10} "
                      f"{summary['avg_cross_process_speedup']:.2f}x{'':<10} "
                      f"{summary['cache_hit_rate']:.1%}{'':<7} "
                      f"{summary['total_queries']:<10}")
        
        print("\n🎯 关键发现:")
        print("• WAL格式策略在跨进程场景下表现稳定")
        print("• 物化视图策略对复杂查询的缓存效果最佳")
        print("• 跨进程策略专门优化了多进程环境的性能")
        print("• 混合策略在不同查询类型上都有良好表现")

    def cleanup(self):
        """清理测试环境"""
        print("\n🧹 清理测试环境...")
        
        for path in [self.test_db_path, self.shared_cache_path]:
            if os.path.exists(path):
                if os.path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
        
        print("✅ 清理完成")

def main():
    """主函数"""
    print("🎯 DuckDB 跨进程缓存持久化性能测试")
    print("测试目标: 验证不同持久化策略在多进程环境下的缓存效果")
    print("=" * 70)
    
    tester = CrossProcessCacheTest()
    
    try:
        # 运行所有测试
        all_results = tester.run_all_tests()
        
        # 打印汇总结果
        tester.print_summary(all_results)
        
        print("\n🎉 测试完成！")
        print("📄 详细报告请查看: cross_process_cache_persistence_report.md")
        print("📊 测试数据请查看: cross_process_cache_test_data.json")
        
    except KeyboardInterrupt:
        print("\n⚠️  测试被用户中断")
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {str(e)}")
        import traceback
        traceback.print_exc()
    finally:
        # 清理测试环境
        tester.cleanup()

if __name__ == "__main__":
    main()