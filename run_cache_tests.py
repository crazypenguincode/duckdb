#!/usr/bin/env python3
"""
DuckDB查询缓存综合测试套件

运行所有缓存相关的性能测试并生成综合报告
"""

import os
import sys
import subprocess
import json
import time
from datetime import datetime
import argparse

class CacheTestSuite:
    """缓存测试套件"""
    
    def __init__(self, db_path: str, output_dir: str = "cache_test_results"):
        self.db_path = db_path
        self.output_dir = output_dir
        self.test_scripts = [
            "test_query_cache_performance.py",
            "test_cache_memory_analysis.py", 
            "test_cache_strategies.py"
        ]
        
        # 确保输出目录存在
        os.makedirs(output_dir, exist_ok=True)
    
    def run_performance_test(self, iterations: int = 5) -> dict:
        """运行性能测试"""
        print("="*80)
        print("运行查询缓存性能测试")
        print("="*80)
        
        output_file = os.path.join(self.output_dir, "performance_results.json")
        
        cmd = [
            sys.executable, "test_query_cache_performance.py",
            "--db-path", self.db_path,
            "--iterations", str(iterations),
            "--output", output_file
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=1800)  # 30分钟超时
            
            if result.returncode == 0:
                print("✓ 性能测试完成")
                # 读取结果
                if os.path.exists(output_file):
                    with open(output_file, 'r') as f:
                        return json.load(f)
                else:
                    print("⚠ 性能测试结果文件未找到")
                    return {}
            else:
                print(f"✗ 性能测试失败: {result.stderr}")
                return {}
                
        except subprocess.TimeoutExpired:
            print("✗ 性能测试超时")
            return {}
        except Exception as e:
            print(f"✗ 性能测试异常: {e}")
            return {}
    
    def run_memory_analysis(self, iterations: int = 3) -> dict:
        """运行内存分析"""
        print("\n" + "="*80)
        print("运行查询缓存内存分析")
        print("="*80)
        
        memory_output_dir = os.path.join(self.output_dir, "memory_analysis")
        
        cmd = [
            sys.executable, "test_cache_memory_analysis.py",
            "--db-path", self.db_path,
            "--iterations", str(iterations),
            "--output-dir", memory_output_dir,
            "--test-scaling"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=1200)  # 20分钟超时
            
            if result.returncode == 0:
                print("✓ 内存分析完成")
                # 读取结果
                results_file = os.path.join(memory_output_dir, "memory_results.json")
                if os.path.exists(results_file):
                    with open(results_file, 'r') as f:
                        return json.load(f)
                else:
                    print("⚠ 内存分析结果文件未找到")
                    return {}
            else:
                print(f"✗ 内存分析失败: {result.stderr}")
                return {}
                
        except subprocess.TimeoutExpired:
            print("✗ 内存分析超时")
            return {}
        except Exception as e:
            print(f"✗ 内存分析异常: {e}")
            return {}
    
    def run_strategy_test(self, workload_duration: int = 2) -> dict:
        """运行策略测试"""
        print("\n" + "="*80)
        print("运行查询缓存策略测试")
        print("="*80)
        
        output_file = os.path.join(self.output_dir, "strategy_results.json")
        
        cmd = [
            sys.executable, "test_cache_strategies.py",
            "--db-path", self.db_path,
            "--workload-duration", str(workload_duration),
            "--output", output_file
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=900)  # 15分钟超时
            
            if result.returncode == 0:
                print("✓ 策略测试完成")
                # 读取结果
                if os.path.exists(output_file):
                    with open(output_file, 'r') as f:
                        return json.load(f)
                else:
                    print("⚠ 策略测试结果文件未找到")
                    return {}
            else:
                print(f"✗ 策略测试失败: {result.stderr}")
                return {}
                
        except subprocess.TimeoutExpired:
            print("✗ 策略测试超时")
            return {}
        except Exception as e:
            print(f"✗ 策略测试异常: {e}")
            return {}
    
    def generate_comprehensive_report(self, performance_results: dict, 
                                    memory_results: dict, strategy_results: dict):
        """生成综合报告"""
        print("\n" + "="*80)
        print("生成综合测试报告")
        print("="*80)
        
        report = {
            "test_info": {
                "timestamp": datetime.now().isoformat(),
                "database_path": self.db_path,
                "database_exists": os.path.exists(self.db_path)
            },
            "performance_test": performance_results,
            "memory_analysis": memory_results,
            "strategy_test": strategy_results,
            "summary": self._generate_summary(performance_results, memory_results, strategy_results)
        }
        
        # 保存完整报告
        report_file = os.path.join(self.output_dir, "comprehensive_report.json")
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        # 生成文本摘要
        self._generate_text_summary(report)
        
        print(f"✓ 综合报告已保存到: {self.output_dir}/")
    
    def _generate_summary(self, performance_results: dict, 
                         memory_results: dict, strategy_results: dict) -> dict:
        """生成测试摘要"""
        summary = {
            "cache_effectiveness": {},
            "memory_impact": {},
            "best_strategies": {},
            "recommendations": []
        }
        
        # 分析性能结果
        if performance_results:
            try:
                simple_enabled = performance_results.get("simple_queries", {}).get("cache_enabled", {})
                simple_disabled = performance_results.get("simple_queries", {}).get("cache_disabled", {})
                
                if simple_enabled and simple_disabled:
                    speedup = simple_enabled.get("speedup_ratio", 1.0)
                    summary["cache_effectiveness"]["simple_queries_speedup"] = speedup
                    
                    if speedup > 1.5:
                        summary["recommendations"].append("简单查询缓存效果显著，建议启用")
                    elif speedup > 1.1:
                        summary["recommendations"].append("简单查询缓存有一定效果")
                    else:
                        summary["recommendations"].append("简单查询缓存效果不明显")
                
                tpch_enabled = performance_results.get("tpch_queries", {}).get("cache_enabled", {})
                tpch_disabled = performance_results.get("tpch_queries", {}).get("cache_disabled", {})
                
                if tpch_enabled and tpch_disabled:
                    speedup = tpch_enabled.get("speedup_ratio", 1.0)
                    summary["cache_effectiveness"]["complex_queries_speedup"] = speedup
                    
                    if speedup > 2.0:
                        summary["recommendations"].append("复杂查询缓存效果非常好，强烈建议启用")
                    elif speedup > 1.3:
                        summary["recommendations"].append("复杂查询缓存效果良好，建议启用")
                    else:
                        summary["recommendations"].append("复杂查询缓存效果有限")
                        
            except Exception as e:
                print(f"分析性能结果时出错: {e}")
        
        # 分析内存结果
        if memory_results:
            try:
                if "enabled" in memory_results and "disabled" in memory_results:
                    enabled_growth = memory_results["enabled"].get("memory_growth_mb", 0)
                    disabled_growth = memory_results["disabled"].get("memory_growth_mb", 0)
                    overhead = enabled_growth - disabled_growth
                    
                    summary["memory_impact"]["cache_overhead_mb"] = overhead
                    
                    if overhead < 10:
                        summary["recommendations"].append("缓存内存开销很小，可以放心使用")
                    elif overhead < 50:
                        summary["recommendations"].append("缓存内存开销适中，需要监控内存使用")
                    else:
                        summary["recommendations"].append("缓存内存开销较大，需要调整缓存大小")
                        
            except Exception as e:
                print(f"分析内存结果时出错: {e}")
        
        # 分析策略结果
        if strategy_results:
            try:
                results = strategy_results.get("results", {})
                analysis = strategy_results.get("analysis", {})
                
                best_hit_rate = analysis.get("best_hit_rate", {})
                if best_hit_rate:
                    summary["best_strategies"]["highest_hit_rate"] = best_hit_rate
                
                fastest_time = analysis.get("fastest_avg_time", {})
                if fastest_time:
                    summary["best_strategies"]["fastest_execution"] = fastest_time
                
                # 推荐策略
                eviction_comparison = analysis.get("eviction_comparison", {})
                if eviction_comparison:
                    avg_hit_rates = eviction_comparison.get("avg_hit_rates", {})
                    if avg_hit_rates:
                        best_eviction = max(avg_hit_rates.items(), key=lambda x: x[1])
                        summary["recommendations"].append(f"推荐使用 {best_eviction[0]} 驱逐策略")
                        
            except Exception as e:
                print(f"分析策略结果时出错: {e}")
        
        return summary
    
    def _generate_text_summary(self, report: dict):
        """生成文本摘要报告"""
        summary_file = os.path.join(self.output_dir, "test_summary.txt")
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            f.write("DuckDB查询缓存综合测试报告\n")
            f.write("=" * 50 + "\n\n")
            
            # 测试信息
            test_info = report.get("test_info", {})
            f.write(f"测试时间: {test_info.get('timestamp', 'N/A')}\n")
            f.write(f"数据库路径: {test_info.get('database_path', 'N/A')}\n")
            f.write(f"数据库存在: {'是' if test_info.get('database_exists') else '否'}\n\n")
            
            # 摘要信息
            summary = report.get("summary", {})
            
            f.write("缓存效果:\n")
            f.write("-" * 20 + "\n")
            cache_effectiveness = summary.get("cache_effectiveness", {})
            simple_speedup = cache_effectiveness.get("simple_queries_speedup", 0)
            complex_speedup = cache_effectiveness.get("complex_queries_speedup", 0)
            f.write(f"简单查询加速比: {simple_speedup:.2f}x\n")
            f.write(f"复杂查询加速比: {complex_speedup:.2f}x\n\n")
            
            f.write("内存影响:\n")
            f.write("-" * 20 + "\n")
            memory_impact = summary.get("memory_impact", {})
            overhead = memory_impact.get("cache_overhead_mb", 0)
            f.write(f"缓存内存开销: {overhead:.2f} MB\n\n")
            
            f.write("最佳策略:\n")
            f.write("-" * 20 + "\n")
            best_strategies = summary.get("best_strategies", {})
            hit_rate_strategy = best_strategies.get("highest_hit_rate", {})
            if hit_rate_strategy:
                f.write(f"最高命中率策略: {hit_rate_strategy.get('strategy', 'N/A')} "
                       f"({hit_rate_strategy.get('hit_rate', 0):.2%})\n")
            
            fastest_strategy = best_strategies.get("fastest_execution", {})
            if fastest_strategy:
                f.write(f"最快执行策略: {fastest_strategy.get('strategy', 'N/A')} "
                       f"({fastest_strategy.get('time_ms', 0):.2f}ms)\n\n")
            
            f.write("建议:\n")
            f.write("-" * 20 + "\n")
            recommendations = summary.get("recommendations", [])
            for i, rec in enumerate(recommendations, 1):
                f.write(f"{i}. {rec}\n")
        
        print(f"✓ 文本摘要已保存到: {summary_file}")
    
    def run_all_tests(self, performance_iterations: int = 5, 
                     memory_iterations: int = 3, workload_duration: int = 2):
        """运行所有测试"""
        print("开始运行DuckDB查询缓存综合测试套件")
        print(f"数据库路径: {self.db_path}")
        print(f"输出目录: {self.output_dir}")
        print(f"数据库存在: {'是' if os.path.exists(self.db_path) else '否'}")
        
        start_time = time.time()
        
        # 运行各项测试
        performance_results = self.run_performance_test(performance_iterations)
        memory_results = self.run_memory_analysis(memory_iterations)
        strategy_results = self.run_strategy_test(workload_duration)
        
        # 生成综合报告
        self.generate_comprehensive_report(performance_results, memory_results, strategy_results)
        
        total_time = time.time() - start_time
        print(f"\n✓ 所有测试完成，总耗时: {total_time:.1f} 秒")
        
        return {
            "performance": performance_results,
            "memory": memory_results,
            "strategy": strategy_results
        }

def main():
    parser = argparse.ArgumentParser(description="DuckDB查询缓存综合测试套件")
    parser.add_argument("--db-path", default="/Users/max/test/tpc/tpch-sf1.db",
                       help="TPC-H数据库路径")
    parser.add_argument("--output-dir", default="cache_test_results",
                       help="测试结果输出目录")
    parser.add_argument("--performance-iterations", type=int, default=5,
                       help="性能测试迭代次数")
    parser.add_argument("--memory-iterations", type=int, default=3,
                       help="内存测试迭代次数")
    parser.add_argument("--workload-duration", type=int, default=2,
                       help="策略测试工作负载持续时间（分钟）")
    parser.add_argument("--quick", action="store_true",
                       help="快速测试模式（减少迭代次数）")
    
    args = parser.parse_args()
    
    # 快速测试模式
    if args.quick:
        args.performance_iterations = 2
        args.memory_iterations = 1
        args.workload_duration = 1
        print("启用快速测试模式")
    
    # 检查测试脚本是否存在
    required_scripts = [
        "test_query_cache_performance.py",
        "test_cache_memory_analysis.py", 
        "test_cache_strategies.py"
    ]
    
    missing_scripts = [script for script in required_scripts if not os.path.exists(script)]
    if missing_scripts:
        print(f"错误: 缺少测试脚本: {', '.join(missing_scripts)}")
        return 1
    
    # 创建测试套件并运行
    test_suite = CacheTestSuite(args.db_path, args.output_dir)
    
    try:
        results = test_suite.run_all_tests(
            args.performance_iterations,
            args.memory_iterations, 
            args.workload_duration
        )
        
        print("\n" + "="*80)
        print("测试套件执行完成！")
        print("="*80)
        print(f"详细结果请查看: {args.output_dir}/")
        print(f"综合报告: {args.output_dir}/comprehensive_report.json")
        print(f"文本摘要: {args.output_dir}/test_summary.txt")
        
        return 0
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        return 1
    except Exception as e:
        print(f"\n测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())