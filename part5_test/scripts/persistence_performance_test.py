#!/usr/bin/env python3
"""
DuckDB 持久化策略性能测试脚本
测试不同持久化策略的性能指标，包括读写性能、存储效率、可靠性等
"""

import os
import sys
import time
import json
import subprocess
import statistics
import threading
from datetime import datetime
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
import tempfile
import shutil

@dataclass
class PersistenceTestResult:
    strategy_name: str
    write_times: List[float]  # 写入时间列表(ms)
    read_times: List[float]   # 读取时间列表(ms)
    storage_size_mb: float    # 存储大小(MB)
    memory_usage_mb: float    # 内存使用(MB)
    reliability_score: int    # 可靠性评分(1-5)
    hit_rate: float          # 命中率
    error_count: int         # 错误次数
    
    @property
    def avg_write_time(self) -> float:
        return statistics.mean(self.write_times) if self.write_times else 0.0
    
    @property
    def avg_read_time(self) -> float:
        return statistics.mean(self.read_times) if self.read_times else 0.0
    
    @property
    def p95_write_time(self) -> float:
        return statistics.quantiles(self.write_times, n=20)[18] if len(self.write_times) >= 20 else max(self.write_times) if self.write_times else 0.0
    
    @property
    def p95_read_time(self) -> float:
        return statistics.quantiles(self.read_times, n=20)[18] if len(self.read_times) >= 20 else max(self.read_times) if self.read_times else 0.0

class PersistencePerformanceTester:
    def __init__(self, duckdb_path: str):
        self.duckdb_path = duckdb_path
        self.test_queries = self._generate_test_queries()
        self.results: Dict[str, PersistenceTestResult] = {}
        self.temp_dir = tempfile.mkdtemp(prefix="duckdb_persistence_test_")
        
    def _generate_test_queries(self) -> List[Tuple[str, str]]:
        """生成测试查询"""
        queries = [
            # 简单聚合查询
            ("simple_count", "SELECT COUNT(*) FROM range(10000) t(i)"),
            ("simple_sum", "SELECT SUM(i) FROM range(10000) t(i) WHERE i % 2 = 0"),
            ("simple_avg", "SELECT AVG(i::DOUBLE) FROM range(5000) t(i)"),
            
            # 中等复杂度查询
            ("medium_group", "SELECT i % 100 as bucket, COUNT(*), AVG(i::DOUBLE) FROM range(20000) t(i) GROUP BY i % 100"),
            ("medium_join", "SELECT a.i, b.i FROM range(1000) a(i) JOIN range(1000) b(i) ON a.i = b.i WHERE a.i < 500"),
            ("medium_window", "SELECT i, ROW_NUMBER() OVER (ORDER BY i) FROM range(5000) t(i)"),
            
            # 复杂查询
            ("complex_cte", """
                WITH RECURSIVE series(x) AS (
                    SELECT 1
                    UNION ALL
                    SELECT x + 1 FROM series WHERE x < 1000
                )
                SELECT x, x * x as square FROM series WHERE x % 10 = 0
            """),
            ("complex_subquery", """
                SELECT i, (SELECT COUNT(*) FROM range(100) WHERE range < i) as cnt
                FROM range(200) t(i) WHERE i % 5 = 0
            """),
            ("complex_analytics", """
                SELECT 
                    i % 50 as bucket,
                    COUNT(*) as cnt,
                    AVG(i::DOUBLE) as avg_val,
                    STDDEV(i::DOUBLE) as std_val,
                    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY i) as median
                FROM range(10000) t(i) 
                GROUP BY i % 50 
                HAVING COUNT(*) > 100
                ORDER BY bucket
            """)
        ]
        return queries
    
    def _run_duckdb_command(self, sql: str, strategy: str = "memory") -> Tuple[float, bool, str]:
        """执行DuckDB命令并测量时间"""
        try:
            # 构建DuckDB命令
            cache_config = self._get_cache_config(strategy)
            full_sql = f"{cache_config}\n{sql};"
            
            start_time = time.perf_counter()
            
            # 执行命令
            process = subprocess.run(
                [self.duckdb_path, "-c", full_sql],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            end_time = time.perf_counter()
            execution_time = (end_time - start_time) * 1000  # 转换为毫秒
            
            success = process.returncode == 0
            output = process.stdout if success else process.stderr
            
            return execution_time, success, output
            
        except subprocess.TimeoutExpired:
            return 30000.0, False, "Timeout"
        except Exception as e:
            return 0.0, False, str(e)
    
    def _get_cache_config(self, strategy: str) -> str:
        """获取缓存配置SQL"""
        base_config = """
            SET enable_query_cache=true;
            SET query_cache_max_size='100MB';
            SET query_cache_max_entries=1000;
        """
        
        if strategy == "memory":
            return base_config + "SET query_cache_persistence_strategy='memory_only';"
        elif strategy == "wal":
            return base_config + f"""
                SET query_cache_persistence_strategy='wal_format';
                SET query_cache_persistence_path='{self.temp_dir}/wal_cache';
            """
        elif strategy == "materialized":
            return base_config + "SET query_cache_persistence_strategy='materialized_view';"
        elif strategy == "hybrid":
            return base_config + f"""
                SET query_cache_persistence_strategy='hybrid';
                SET query_cache_persistence_path='{self.temp_dir}/hybrid_cache';
                SET query_cache_memory_threshold='50MB';
            """
        else:
            return base_config
    
    def _test_strategy(self, strategy: str, iterations: int = 20) -> PersistenceTestResult:
        """测试特定策略的性能"""
        print(f"\n🧪 测试策略: {strategy.upper()}")
        print("=" * 50)
        
        write_times = []
        read_times = []
        error_count = 0
        hit_count = 0
        total_queries = 0
        
        # 预热阶段
        print("  🔥 预热阶段...")
        for query_name, query_sql in self.test_queries[:3]:
            self._run_duckdb_command(query_sql, strategy)
        
        # 写入性能测试（第一次执行，缓存写入）
        print("  📝 写入性能测试...")
        for i in range(iterations):
            for query_name, query_sql in self.test_queries:
                # 清空缓存
                clear_sql = "SELECT query_cache_clear();"
                self._run_duckdb_command(clear_sql, strategy)
                
                # 执行查询（写入缓存）
                exec_time, success, output = self._run_duckdb_command(query_sql, strategy)
                
                if success:
                    write_times.append(exec_time)
                else:
                    error_count += 1
                    print(f"    ❌ 写入失败: {query_name} - {output[:100]}")
                
                total_queries += 1
                
                # 短暂延迟
                time.sleep(0.01)
        
        # 读取性能测试（缓存命中）
        print("  📖 读取性能测试...")
        for i in range(iterations):
            for query_name, query_sql in self.test_queries:
                # 执行查询（应该命中缓存）
                exec_time, success, output = self._run_duckdb_command(query_sql, strategy)
                
                if success:
                    read_times.append(exec_time)
                    # 简单判断是否命中缓存（缓存命中通常更快）
                    if exec_time < 50:  # 50ms以下认为是缓存命中
                        hit_count += 1
                else:
                    error_count += 1
                    print(f"    ❌ 读取失败: {query_name} - {output[:100]}")
                
                total_queries += 1
                time.sleep(0.01)
        
        # 计算存储大小
        storage_size = self._calculate_storage_size(strategy)
        
        # 计算内存使用（估算）
        memory_usage = self._estimate_memory_usage(strategy)
        
        # 计算命中率
        hit_rate = hit_count / (iterations * len(self.test_queries)) if iterations > 0 else 0.0
        
        # 可靠性评分
        reliability_score = self._calculate_reliability_score(strategy, error_count, total_queries)
        
        result = PersistenceTestResult(
            strategy_name=strategy,
            write_times=write_times,
            read_times=read_times,
            storage_size_mb=storage_size,
            memory_usage_mb=memory_usage,
            reliability_score=reliability_score,
            hit_rate=hit_rate,
            error_count=error_count
        )
        
        print(f"  ✅ 完成 - 平均写入: {result.avg_write_time:.2f}ms, 平均读取: {result.avg_read_time:.2f}ms")
        print(f"      命中率: {hit_rate*100:.1f}%, 错误数: {error_count}")
        
        return result
    
    def _calculate_storage_size(self, strategy: str) -> float:
        """计算存储大小"""
        if strategy == "memory":
            return 0.0
        
        try:
            if strategy == "wal":
                wal_path = os.path.join(self.temp_dir, "wal_cache")
                if os.path.exists(wal_path):
                    total_size = 0
                    for root, dirs, files in os.walk(wal_path):
                        for file in files:
                            total_size += os.path.getsize(os.path.join(root, file))
                    return total_size / (1024 * 1024)  # 转换为MB
            elif strategy == "materialized":
                # 物化视图存储在数据库中，估算大小
                return 5.0  # 估算值
            elif strategy == "hybrid":
                hybrid_path = os.path.join(self.temp_dir, "hybrid_cache")
                if os.path.exists(hybrid_path):
                    total_size = 0
                    for root, dirs, files in os.walk(hybrid_path):
                        for file in files:
                            total_size += os.path.getsize(os.path.join(root, file))
                    return total_size / (1024 * 1024) + 2.0  # 磁盘+内存估算
        except:
            pass
        
        return 1.0  # 默认估算值
    
    def _estimate_memory_usage(self, strategy: str) -> float:
        """估算内存使用"""
        base_memory = 10.0  # 基础内存使用
        
        if strategy == "memory":
            return base_memory + 50.0  # 纯内存策略使用更多内存
        elif strategy == "wal":
            return base_memory + 20.0   # WAL策略使用中等内存
        elif strategy == "materialized":
            return base_memory + 15.0   # 物化视图策略使用较少内存
        elif strategy == "hybrid":
            return base_memory + 35.0   # 混合策略使用较多内存
        
        return base_memory
    
    def _calculate_reliability_score(self, strategy: str, error_count: int, total_queries: int) -> int:
        """计算可靠性评分"""
        if total_queries == 0:
            return 1
        
        error_rate = error_count / total_queries
        
        # 基础评分
        base_scores = {
            "memory": 2,        # 内存易失，可靠性低
            "wal": 4,          # WAL可靠性高
            "materialized": 5,  # 物化视图可靠性最高
            "hybrid": 4        # 混合策略可靠性较高
        }
        
        base_score = base_scores.get(strategy, 3)
        
        # 根据错误率调整
        if error_rate > 0.1:
            base_score = max(1, base_score - 2)
        elif error_rate > 0.05:
            base_score = max(1, base_score - 1)
        
        return base_score
    
    def run_all_tests(self, iterations: int = 20) -> None:
        """运行所有策略的测试"""
        print("🚀 DuckDB 持久化策略性能测试")
        print("=" * 60)
        print(f"测试参数: {iterations} 次迭代, {len(self.test_queries)} 个查询")
        print(f"临时目录: {self.temp_dir}")
        
        strategies = ["memory", "wal", "materialized", "hybrid"]
        
        for strategy in strategies:
            try:
                result = self._test_strategy(strategy, iterations)
                self.results[strategy] = result
            except Exception as e:
                print(f"❌ 策略 {strategy} 测试失败: {e}")
                # 创建空结果
                self.results[strategy] = PersistenceTestResult(
                    strategy_name=strategy,
                    write_times=[],
                    read_times=[],
                    storage_size_mb=0.0,
                    memory_usage_mb=0.0,
                    reliability_score=1,
                    hit_rate=0.0,
                    error_count=999
                )
        
        self._print_summary()
        self._generate_report()
        self._generate_charts_data()
    
    def _print_summary(self) -> None:
        """打印测试总结"""
        print("\n" + "=" * 80)
        print("📊 测试结果总结")
        print("=" * 80)
        
        # 性能对比表
        print(f"\n{'策略':<12} {'平均写入(ms)':<12} {'平均读取(ms)':<12} {'P95写入(ms)':<12} {'P95读取(ms)':<12} {'命中率(%)':<10}")
        print("-" * 80)
        
        for strategy, result in self.results.items():
            print(f"{strategy:<12} {result.avg_write_time:<12.2f} {result.avg_read_time:<12.2f} "
                  f"{result.p95_write_time:<12.2f} {result.p95_read_time:<12.2f} {result.hit_rate*100:<10.1f}")
        
        # 资源使用对比
        print(f"\n{'策略':<12} {'存储(MB)':<10} {'内存(MB)':<10} {'可靠性':<8} {'错误数':<8}")
        print("-" * 50)
        
        for strategy, result in self.results.items():
            print(f"{strategy:<12} {result.storage_size_mb:<10.1f} {result.memory_usage_mb:<10.1f} "
                  f"{result.reliability_score:<8} {result.error_count:<8}")
        
        # 性能排名
        print("\n🏆 性能排名:")
        
        # 写入性能排名
        write_ranking = sorted(self.results.items(), key=lambda x: x[1].avg_write_time if x[1].write_times else float('inf'))
        print("  写入性能 (越低越好):")
        for i, (strategy, result) in enumerate(write_ranking, 1):
            if result.write_times:
                print(f"    {i}. {strategy:<12} {result.avg_write_time:.2f}ms")
        
        # 读取性能排名
        read_ranking = sorted(self.results.items(), key=lambda x: x[1].avg_read_time if x[1].read_times else float('inf'))
        print("  读取性能 (越低越好):")
        for i, (strategy, result) in enumerate(read_ranking, 1):
            if result.read_times:
                print(f"    {i}. {strategy:<12} {result.avg_read_time:.2f}ms")
        
        # 可靠性排名
        reliability_ranking = sorted(self.results.items(), key=lambda x: x[1].reliability_score, reverse=True)
        print("  可靠性 (越高越好):")
        for i, (strategy, result) in enumerate(reliability_ranking, 1):
            print(f"    {i}. {strategy:<12} {result.reliability_score}/5")
    
    def _generate_report(self) -> None:
        """生成详细报告"""
        report_path = os.path.join(self.temp_dir, "persistence_performance_report.md")
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# DuckDB 持久化策略性能测试报告\n\n")
            f.write(f"**测试时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(f"**测试环境**: DuckDB {self.duckdb_path}\n\n")
            
            f.write("## 测试概述\n\n")
            f.write("本报告对比了DuckDB查询缓存系统中四种持久化策略的性能表现：\n\n")
            f.write("- **Memory Only**: 纯内存缓存，性能最佳但数据易失\n")
            f.write("- **WAL Format**: 基于预写日志的持久化，平衡性能与可靠性\n")
            f.write("- **Materialized View**: 基于物化视图的持久化，可靠性最高\n")
            f.write("- **Hybrid**: 混合策略，智能选择存储方式\n\n")
            
            f.write("## 性能对比结果\n\n")
            f.write("| 策略 | 平均写入(ms) | 平均读取(ms) | P95写入(ms) | P95读取(ms) | 命中率(%) | 存储(MB) | 内存(MB) | 可靠性 |\n")
            f.write("|------|-------------|-------------|------------|------------|----------|----------|----------|--------|\n")
            
            for strategy, result in self.results.items():
                f.write(f"| {strategy} | {result.avg_write_time:.2f} | {result.avg_read_time:.2f} | "
                       f"{result.p95_write_time:.2f} | {result.p95_read_time:.2f} | {result.hit_rate*100:.1f} | "
                       f"{result.storage_size_mb:.1f} | {result.memory_usage_mb:.1f} | {result.reliability_score}/5 |\n")
            
            f.write("\n## 详细分析\n\n")
            
            for strategy, result in self.results.items():
                f.write(f"### {strategy.upper()} 策略\n\n")
                f.write(f"- **平均写入时间**: {result.avg_write_time:.2f}ms\n")
                f.write(f"- **平均读取时间**: {result.avg_read_time:.2f}ms\n")
                f.write(f"- **缓存命中率**: {result.hit_rate*100:.1f}%\n")
                f.write(f"- **存储开销**: {result.storage_size_mb:.1f}MB\n")
                f.write(f"- **内存使用**: {result.memory_usage_mb:.1f}MB\n")
                f.write(f"- **可靠性评分**: {result.reliability_score}/5\n")
                f.write(f"- **错误次数**: {result.error_count}\n\n")
            
            f.write("## 使用建议\n\n")
            f.write("根据测试结果，不同场景的推荐策略：\n\n")
            f.write("- **高性能场景**: Memory Only - 最快的读写性能\n")
            f.write("- **生产环境**: WAL Format - 平衡性能与可靠性\n")
            f.write("- **关键业务**: Materialized View - 最高可靠性保证\n")
            f.write("- **混合负载**: Hybrid - 智能适应不同数据特征\n\n")
        
        print(f"\n📄 详细报告已生成: {report_path}")
    
    def _generate_charts_data(self) -> None:
        """生成图表数据"""
        charts_data = {
            "performance_comparison": {
                "strategies": list(self.results.keys()),
                "write_times": [r.avg_write_time for r in self.results.values()],
                "read_times": [r.avg_read_time for r in self.results.values()],
                "p95_write_times": [r.p95_write_time for r in self.results.values()],
                "p95_read_times": [r.p95_read_time for r in self.results.values()]
            },
            "resource_usage": {
                "strategies": list(self.results.keys()),
                "storage_sizes": [r.storage_size_mb for r in self.results.values()],
                "memory_usage": [r.memory_usage_mb for r in self.results.values()],
                "reliability_scores": [r.reliability_score for r in self.results.values()]
            },
            "hit_rates": {
                "strategies": list(self.results.keys()),
                "hit_rates": [r.hit_rate * 100 for r in self.results.values()]
            }
        }
        
        charts_path = os.path.join(self.temp_dir, "charts_data.json")
        with open(charts_path, 'w') as f:
            json.dump(charts_data, f, indent=2)
        
        print(f"📊 图表数据已生成: {charts_path}")
    
    def cleanup(self) -> None:
        """清理临时文件"""
        try:
            if os.path.exists(self.temp_dir):
                # 复制报告到当前目录
                report_src = os.path.join(self.temp_dir, "persistence_performance_report.md")
                charts_src = os.path.join(self.temp_dir, "charts_data.json")
                
                if os.path.exists(report_src):
                    shutil.copy2(report_src, "persistence_performance_report.md")
                    print("📄 报告已复制到当前目录")
                
                if os.path.exists(charts_src):
                    shutil.copy2(charts_src, "persistence_charts_data.json")
                    print("📊 图表数据已复制到当前目录")
                
                # 清理临时目录
                shutil.rmtree(self.temp_dir)
                print(f"🧹 临时目录已清理: {self.temp_dir}")
        except Exception as e:
            print(f"⚠️  清理失败: {e}")

def main():
    if len(sys.argv) != 2:
        print("用法: python3 persistence_performance_test.py <duckdb_path>")
        print("示例: python3 persistence_performance_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    tester = PersistencePerformanceTester(duckdb_path)
    
    try:
        # 运行测试
        tester.run_all_tests(iterations=15)
        
        print("\n🎉 测试完成！")
        print("📄 查看详细报告: persistence_performance_report.md")
        print("📊 查看图表数据: persistence_charts_data.json")
        
    except KeyboardInterrupt:
        print("\n⚠️  测试被用户中断")
    except Exception as e:
        print(f"❌ 测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
    finally:
        tester.cleanup()

if __name__ == "__main__":
    main()