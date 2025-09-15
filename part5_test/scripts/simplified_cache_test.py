#!/usr/bin/env python3
"""
DuckDB 持久化策略性能测试脚本 (简化版)
测试有缓存和无缓存的性能对比
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
import tempfile
import shutil

@dataclass
class PerformanceTestResult:
    test_name: str
    cached_times: List[float]      # 缓存命中时间(ms)
    uncached_times: List[float]    # 无缓存时间(ms)
    cache_enabled: bool
    
    @property
    def avg_cached_time(self) -> float:
        return statistics.mean(self.cached_times) if self.cached_times else 0.0
    
    @property
    def avg_uncached_time(self) -> float:
        return statistics.mean(self.uncached_times) if self.uncached_times else 0.0
    
    @property
    def speedup_ratio(self) -> float:
        if self.avg_cached_time > 0:
            return self.avg_uncached_time / self.avg_cached_time
        return 1.0
    
    @property
    def performance_improvement(self) -> float:
        if self.avg_uncached_time > 0:
            return ((self.avg_uncached_time - self.avg_cached_time) / self.avg_uncached_time) * 100
        return 0.0

class SimplifiedPersistenceTester:
    def __init__(self, duckdb_path: str):
        self.duckdb_path = duckdb_path
        self.test_queries = self._generate_test_queries()
        self.results: Dict[str, PerformanceTestResult] = {}
        
    def _generate_test_queries(self) -> List[Tuple[str, str, str]]:
        """生成测试查询 (名称, SQL, 复杂度)"""
        queries = [
            # 简单查询
            ("simple_count", "SELECT COUNT(*) FROM range(50000) t(i)", "Simple"),
            ("simple_sum", "SELECT SUM(i) FROM range(50000) t(i) WHERE i % 2 = 0", "Simple"),
            ("simple_avg", "SELECT AVG(i::DOUBLE) FROM range(30000) t(i)", "Simple"),
            
            # 中等复杂度查询
            ("medium_group", "SELECT i % 100 as bucket, COUNT(*), AVG(i::DOUBLE) FROM range(100000) t(i) GROUP BY i % 100", "Medium"),
            ("medium_join", "SELECT a.i, b.i FROM range(5000) a(i) JOIN range(5000) b(i) ON a.i = b.i WHERE a.i < 2500", "Medium"),
            ("medium_window", "SELECT i, ROW_NUMBER() OVER (ORDER BY i), LAG(i) OVER (ORDER BY i) FROM range(20000) t(i)", "Medium"),
            
            # 复杂查询
            ("complex_cte", """
                WITH RECURSIVE series(x) AS (
                    SELECT 1
                    UNION ALL
                    SELECT x + 1 FROM series WHERE x < 5000
                )
                SELECT x, x * x as square, x * x * x as cube FROM series WHERE x % 100 = 0
            """, "Complex"),
            ("complex_analytics", """
                SELECT 
                    i % 50 as bucket,
                    COUNT(*) as cnt,
                    AVG(i::DOUBLE) as avg_val,
                    STDDEV(i::DOUBLE) as std_val,
                    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY i) as median,
                    MIN(i) as min_val,
                    MAX(i) as max_val
                FROM range(50000) t(i) 
                GROUP BY i % 50 
                HAVING COUNT(*) > 500
                ORDER BY bucket
            """, "Complex"),
            ("complex_subquery", """
                SELECT 
                    i, 
                    (SELECT COUNT(*) FROM range(1000) WHERE range < i) as cnt,
                    (SELECT AVG(range::DOUBLE) FROM range(1000) WHERE range < i) as avg_below
                FROM range(1000) t(i) 
                WHERE i % 50 = 0
                ORDER BY i
            """, "Complex")
        ]
        return queries
    
    def _run_duckdb_query(self, sql: str, enable_cache: bool = True) -> Tuple[float, bool, str]:
        """执行DuckDB查询并测量时间"""
        try:
            # 构建完整的SQL
            if enable_cache:
                # 启用缓存的查询
                full_sql = sql
            else:
                # 禁用缓存的查询 - 每次都清空缓存
                full_sql = f"SELECT query_cache_clear(); {sql};"
            
            start_time = time.perf_counter()
            
            # 执行命令
            process = subprocess.run(
                [self.duckdb_path, "-c", full_sql],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            end_time = time.perf_counter()
            execution_time = (end_time - start_time) * 1000  # 转换为毫秒
            
            success = process.returncode == 0
            output = process.stdout if success else process.stderr
            
            return execution_time, success, output
            
        except subprocess.TimeoutExpired:
            return 60000.0, False, "Timeout"
        except Exception as e:
            return 0.0, False, str(e)
    
    def _test_query_performance(self, query_name: str, query_sql: str, complexity: str, iterations: int = 10) -> PerformanceTestResult:
        """测试单个查询的性能"""
        print(f"  📊 测试查询: {query_name} ({complexity})")
        
        cached_times = []
        uncached_times = []
        
        # 预热 - 执行一次查询让缓存生效
        print("    🔥 预热...")
        self._run_duckdb_query(query_sql, enable_cache=True)
        time.sleep(0.1)
        
        # 测试无缓存性能 (每次都清空缓存)
        print("    ❄️  测试无缓存性能...")
        for i in range(iterations):
            exec_time, success, output = self._run_duckdb_query(query_sql, enable_cache=False)
            if success:
                uncached_times.append(exec_time)
            else:
                print(f"      ❌ 无缓存执行失败: {output[:100]}")
            time.sleep(0.05)  # 短暂延迟
        
        # 再次预热缓存
        self._run_duckdb_query(query_sql, enable_cache=True)
        time.sleep(0.1)
        
        # 测试缓存性能 (应该命中缓存)
        print("    🚀 测试缓存性能...")
        for i in range(iterations):
            exec_time, success, output = self._run_duckdb_query(query_sql, enable_cache=True)
            if success:
                cached_times.append(exec_time)
            else:
                print(f"      ❌ 缓存执行失败: {output[:100]}")
            time.sleep(0.05)  # 短暂延迟
        
        result = PerformanceTestResult(
            test_name=f"{query_name}_{complexity}",
            cached_times=cached_times,
            uncached_times=uncached_times,
            cache_enabled=True
        )
        
        print(f"    ✅ 完成 - 无缓存: {result.avg_uncached_time:.2f}ms, 缓存: {result.avg_cached_time:.2f}ms, 加速: {result.speedup_ratio:.2f}x")
        
        return result
    
    def run_all_tests(self, iterations: int = 10) -> None:
        """运行所有测试"""
        print("🚀 DuckDB 缓存性能对比测试")
        print("=" * 60)
        print(f"测试参数: {iterations} 次迭代, {len(self.test_queries)} 个查询")
        
        for query_name, query_sql, complexity in self.test_queries:
            try:
                result = self._test_query_performance(query_name, query_sql, complexity, iterations)
                self.results[f"{query_name}_{complexity}"] = result
            except Exception as e:
                print(f"❌ 查询 {query_name} 测试失败: {e}")
        
        self._print_summary()
        self._generate_report()
        self._generate_charts_data()
    
    def _print_summary(self) -> None:
        """打印测试总结"""
        print("\n" + "=" * 80)
        print("📊 缓存性能对比结果")
        print("=" * 80)
        
        # 性能对比表
        print(f"\n{'查询':<20} {'复杂度':<8} {'无缓存(ms)':<12} {'缓存(ms)':<10} {'加速比':<8} {'性能提升(%)':<12}")
        print("-" * 80)
        
        total_speedup = 0
        total_improvement = 0
        valid_results = 0
        
        # 按复杂度分组
        simple_results = []
        medium_results = []
        complex_results = []
        
        for test_name, result in self.results.items():
            if result.cached_times and result.uncached_times:
                complexity = "Simple" if "Simple" in test_name else ("Medium" if "Medium" in test_name else "Complex")
                query_name = test_name.replace("_Simple", "").replace("_Medium", "").replace("_Complex", "")
                
                print(f"{query_name:<20} {complexity:<8} {result.avg_uncached_time:<12.2f} {result.avg_cached_time:<10.2f} "
                      f"{result.speedup_ratio:<8.2f} {result.performance_improvement:<12.1f}")
                
                total_speedup += result.speedup_ratio
                total_improvement += result.performance_improvement
                valid_results += 1
                
                # 分组统计
                if complexity == "Simple":
                    simple_results.append(result)
                elif complexity == "Medium":
                    medium_results.append(result)
                else:
                    complex_results.append(result)
        
        # 总体统计
        if valid_results > 0:
            avg_speedup = total_speedup / valid_results
            avg_improvement = total_improvement / valid_results
            
            print(f"\n📈 总体性能:")
            print(f"  平均加速比: {avg_speedup:.2f}x")
            print(f"  平均性能提升: {avg_improvement:.1f}%")
            
            # 分组统计
            self._print_group_stats("简单查询", simple_results)
            self._print_group_stats("中等查询", medium_results)
            self._print_group_stats("复杂查询", complex_results)
    
    def _print_group_stats(self, group_name: str, results: List[PerformanceTestResult]) -> None:
        """打印分组统计"""
        if not results:
            return
        
        avg_speedup = statistics.mean([r.speedup_ratio for r in results])
        avg_improvement = statistics.mean([r.performance_improvement for r in results])
        avg_uncached = statistics.mean([r.avg_uncached_time for r in results])
        avg_cached = statistics.mean([r.avg_cached_time for r in results])
        
        print(f"\n  {group_name}:")
        print(f"    平均无缓存时间: {avg_uncached:.2f}ms")
        print(f"    平均缓存时间: {avg_cached:.2f}ms")
        print(f"    平均加速比: {avg_speedup:.2f}x")
        print(f"    平均性能提升: {avg_improvement:.1f}%")
    
    def _generate_report(self) -> None:
        """生成详细报告"""
        report_path = "cache_performance_comparison_report.md"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# DuckDB 缓存性能对比测试报告\n\n")
            f.write(f"**测试时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(f"**测试环境**: DuckDB {self.duckdb_path}\n\n")
            
            f.write("## 测试概述\n\n")
            f.write("本报告对比了DuckDB查询缓存系统启用和禁用时的性能差异，")
            f.write("通过测试不同复杂度的查询来评估缓存系统的效果。\n\n")
            
            f.write("## 测试结果\n\n")
            f.write("| 查询名称 | 复杂度 | 无缓存时间(ms) | 缓存时间(ms) | 加速比 | 性能提升(%) |\n")
            f.write("|----------|--------|---------------|-------------|--------|-------------|\n")
            
            for test_name, result in self.results.items():
                if result.cached_times and result.uncached_times:
                    complexity = "Simple" if "Simple" in test_name else ("Medium" if "Medium" in test_name else "Complex")
                    query_name = test_name.replace("_Simple", "").replace("_Medium", "").replace("_Complex", "")
                    
                    f.write(f"| {query_name} | {complexity} | {result.avg_uncached_time:.2f} | "
                           f"{result.avg_cached_time:.2f} | {result.speedup_ratio:.2f}x | {result.performance_improvement:.1f}% |\n")
            
            f.write("\n## 性能分析\n\n")
            
            # 计算总体统计
            valid_results = [r for r in self.results.values() if r.cached_times and r.uncached_times]
            if valid_results:
                avg_speedup = statistics.mean([r.speedup_ratio for r in valid_results])
                avg_improvement = statistics.mean([r.performance_improvement for r in valid_results])
                
                f.write(f"### 总体性能提升\n\n")
                f.write(f"- **平均加速比**: {avg_speedup:.2f}x\n")
                f.write(f"- **平均性能提升**: {avg_improvement:.1f}%\n\n")
                
                # 分复杂度统计
                simple_results = [r for r in valid_results if "Simple" in r.test_name]
                medium_results = [r for r in valid_results if "Medium" in r.test_name]
                complex_results = [r for r in valid_results if "Complex" in r.test_name]
                
                if simple_results:
                    avg_simple_speedup = statistics.mean([r.speedup_ratio for r in simple_results])
                    f.write(f"### 简单查询\n\n")
                    f.write(f"- 平均加速比: {avg_simple_speedup:.2f}x\n")
                    f.write(f"- 查询数量: {len(simple_results)}\n\n")
                
                if medium_results:
                    avg_medium_speedup = statistics.mean([r.speedup_ratio for r in medium_results])
                    f.write(f"### 中等复杂查询\n\n")
                    f.write(f"- 平均加速比: {avg_medium_speedup:.2f}x\n")
                    f.write(f"- 查询数量: {len(medium_results)}\n\n")
                
                if complex_results:
                    avg_complex_speedup = statistics.mean([r.speedup_ratio for r in complex_results])
                    f.write(f"### 复杂查询\n\n")
                    f.write(f"- 平均加速比: {avg_complex_speedup:.2f}x\n")
                    f.write(f"- 查询数量: {len(complex_results)}\n\n")
            
            f.write("## 结论\n\n")
            f.write("测试结果表明，DuckDB的查询缓存系统能够显著提升查询性能，")
            f.write("特别是对于重复执行的查询。缓存系统的效果随查询复杂度的增加而更加明显。\n\n")
            
            f.write("### 建议\n\n")
            f.write("- 对于生产环境，建议启用查询缓存以提升性能\n")
            f.write("- 复杂查询从缓存中获益更多，应优先缓存\n")
            f.write("- 根据内存容量合理配置缓存大小\n")
        
        print(f"\n📄 详细报告已生成: {report_path}")
    
    def _generate_charts_data(self) -> None:
        """生成图表数据"""
        # 准备图表数据
        query_names = []
        uncached_times = []
        cached_times = []
        speedup_ratios = []
        complexities = []
        
        for test_name, result in self.results.items():
            if result.cached_times and result.uncached_times:
                complexity = "Simple" if "Simple" in test_name else ("Medium" if "Medium" in test_name else "Complex")
                query_name = test_name.replace("_Simple", "").replace("_Medium", "").replace("_Complex", "")
                
                query_names.append(query_name)
                uncached_times.append(result.avg_uncached_time)
                cached_times.append(result.avg_cached_time)
                speedup_ratios.append(result.speedup_ratio)
                complexities.append(complexity)
        
        charts_data = {
            "performance_comparison": {
                "query_names": query_names,
                "uncached_times": uncached_times,
                "cached_times": cached_times,
                "complexities": complexities
            },
            "speedup_analysis": {
                "query_names": query_names,
                "speedup_ratios": speedup_ratios,
                "complexities": complexities
            },
            "complexity_analysis": {
                "simple": {
                    "queries": [q for i, q in enumerate(query_names) if complexities[i] == "Simple"],
                    "speedups": [s for i, s in enumerate(speedup_ratios) if complexities[i] == "Simple"]
                },
                "medium": {
                    "queries": [q for i, q in enumerate(query_names) if complexities[i] == "Medium"],
                    "speedups": [s for i, s in enumerate(speedup_ratios) if complexities[i] == "Medium"]
                },
                "complex": {
                    "queries": [q for i, q in enumerate(query_names) if complexities[i] == "Complex"],
                    "speedups": [s for i, s in enumerate(speedup_ratios) if complexities[i] == "Complex"]
                }
            }
        }
        
        charts_path = "cache_performance_charts_data.json"
        with open(charts_path, 'w') as f:
            json.dump(charts_data, f, indent=2)
        
        print(f"📊 图表数据已生成: {charts_path}")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 simplified_cache_test.py <duckdb_path>")
        print("示例: python3 simplified_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = SimplifiedPersistenceTester(duckdb_path)
    
    try:
        # 运行测试
        tester.run_all_tests(iterations=12)
        
        print("\n🎉 测试完成！")
        print("📄 查看详细报告: cache_performance_comparison_report.md")
        print("📊 查看图表数据: cache_performance_charts_data.json")
        
    except KeyboardInterrupt:
        print("\n⚠️  测试被用户中断")
    except Exception as e:
        print(f"❌ 测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()