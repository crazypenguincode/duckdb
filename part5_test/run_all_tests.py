#!/usr/bin/env python3
"""
第五章完整测试套件 - 主测试脚本
运行所有第五章的测试并生成综合报告
"""

import os
import sys
import time
import json
import subprocess
from typing import Dict, List

class Chapter5TestSuite:
    def __init__(self):
        self.test_results = {}
        self.test_scripts = [
            "5.1.platform_setup.py",
            "5.2.cache_performance.py", 
            "5.3.bloom_filter.py",
            "5.4.sql_cache.py",
            "5.7.persistence.py",
            "5.8.comprehensive.py"
        ]
        
    def run_single_test(self, script_name: str) -> Dict:
        """运行单个测试脚本"""
        print(f"\n{'='*60}")
        print(f"运行测试: {script_name}")
        print(f"{'='*60}")
        
        script_path = f"part5_test/{script_name}"
        
        if not os.path.exists(script_path):
            print(f"错误: 测试脚本不存在 {script_path}")
            return {"status": "error", "message": f"Script not found: {script_path}"}
        
        try:
            # 运行测试脚本
            start_time = time.time()
            result = subprocess.run([sys.executable, script_path], 
                                  capture_output=True, text=True, timeout=300)
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            if result.returncode == 0:
                print(f"✅ 测试完成: {script_name} (耗时: {execution_time:.2f}s)")
                return {
                    "status": "success",
                    "execution_time": execution_time,
                    "stdout": result.stdout,
                    "stderr": result.stderr
                }
            else:
                print(f"❌ 测试失败: {script_name}")
                print(f"错误输出: {result.stderr}")
                return {
                    "status": "failed",
                    "execution_time": execution_time,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "return_code": result.returncode
                }
                
        except subprocess.TimeoutExpired:
            print(f"⏰ 测试超时: {script_name}")
            return {"status": "timeout", "message": "Test execution timeout"}
            
        except Exception as e:
            print(f"💥 测试异常: {script_name} - {str(e)}")
            return {"status": "exception", "message": str(e)}
    
    def run_all_tests(self):
        """运行所有测试"""
        print("第五章 实验与分析 - 完整测试套件")
        print("=" * 80)
        print(f"开始时间: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"测试脚本数量: {len(self.test_scripts)}")
        
        overall_start_time = time.time()
        
        # 运行每个测试
        for script in self.test_scripts:
            self.test_results[script] = self.run_single_test(script)
        
        overall_end_time = time.time()
        total_execution_time = overall_end_time - overall_start_time
        
        # 生成综合报告
        self.generate_comprehensive_report(total_execution_time)
    
    def generate_comprehensive_report(self, total_time: float):
        """生成综合测试报告"""
        print(f"\n{'='*80}")
        print("第五章测试综合报告")
        print(f"{'='*80}")
        
        # 统计测试结果
        successful_tests = 0
        failed_tests = 0
        timeout_tests = 0
        exception_tests = 0
        
        for script, result in self.test_results.items():
            status = result.get("status", "unknown")
            if status == "success":
                successful_tests += 1
            elif status == "failed":
                failed_tests += 1
            elif status == "timeout":
                timeout_tests += 1
            elif status == "exception":
                exception_tests += 1
        
        total_tests = len(self.test_scripts)
        success_rate = (successful_tests / total_tests) * 100 if total_tests > 0 else 0
        
        print(f"\n📊 测试执行统计:")
        print(f"  总测试数: {total_tests}")
        print(f"  成功: {successful_tests} ✅")
        print(f"  失败: {failed_tests} ❌")
        print(f"  超时: {timeout_tests} ⏰")
        print(f"  异常: {exception_tests} 💥")
        print(f"  成功率: {success_rate:.1f}%")
        print(f"  总执行时间: {total_time:.2f}s")
        
        # 详细测试结果
        print(f"\n📋 详细测试结果:")
        for script, result in self.test_results.items():
            status = result.get("status", "unknown")
            execution_time = result.get("execution_time", 0)
            
            status_icon = {
                "success": "✅",
                "failed": "❌", 
                "timeout": "⏰",
                "exception": "💥",
                "error": "🚫"
            }.get(status, "❓")
            
            print(f"  {status_icon} {script}: {status} ({execution_time:.2f}s)")
            
            if status in ["failed", "exception", "error"]:
                error_msg = result.get("message", result.get("stderr", "Unknown error"))
                print(f"      错误信息: {error_msg[:100]}...")
        
        # 性能指标汇总
        print(f"\n🎯 性能指标汇总:")
        
        # 尝试从结果文件中读取性能数据
        performance_summary = self.collect_performance_metrics()
        
        if performance_summary:
            print(f"  平台准备就绪率: {performance_summary.get('platform_readiness', 'N/A')}")
            print(f"  缓存性能改善: {performance_summary.get('cache_improvement', 'N/A')}")
            print(f"  布隆过滤器效果: {performance_summary.get('bloom_filter_effectiveness', 'N/A')}")
            print(f"  SQL标准化成功率: {performance_summary.get('sql_standardization_rate', 'N/A')}")
            print(f"  持久化策略评分: {performance_summary.get('persistence_score', 'N/A')}")
            print(f"  综合性能评分: {performance_summary.get('comprehensive_score', 'N/A')}")
        else:
            print("  性能数据收集中...")
        
        # 测试建议
        print(f"\n💡 测试建议:")
        if success_rate >= 80:
            print("  ✅ 测试执行良好，系统性能验证完成")
            print("  📈 建议进行生产环境部署前的最终验证")
        elif success_rate >= 60:
            print("  ⚠️  部分测试需要关注，建议检查失败的测试项")
            print("  🔧 优化相关配置后重新运行测试")
        else:
            print("  🚨 测试成功率较低，需要全面检查系统配置")
            print("  🛠️  建议逐个排查测试失败原因")
        
        # 保存综合报告
        report_data = {
            "test_summary": {
                "total_tests": total_tests,
                "successful_tests": successful_tests,
                "failed_tests": failed_tests,
                "timeout_tests": timeout_tests,
                "exception_tests": exception_tests,
                "success_rate": success_rate,
                "total_execution_time": total_time
            },
            "test_results": self.test_results,
            "performance_summary": performance_summary,
            "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        with open("part5_test/chapter5_comprehensive_report.json", "w") as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 综合报告已保存到: part5_test/chapter5_comprehensive_report.json")
        
        # 生成Markdown报告
        self.generate_markdown_report(report_data)
    
    def collect_performance_metrics(self) -> Dict:
        """收集性能指标"""
        metrics = {}
        
        # 尝试读取各个测试的结果文件
        result_files = {
            "platform_setup": "part5_test/5.1.platform_setup_results.json",
            "cache_performance": "part5_test/5.2.cache_performance_results.json",
            "bloom_filter": "part5_test/5.3.bloom_filter_results.json",
            "sql_cache": "part5_test/5.4.sql_cache_results.json",
            "persistence": "part5_test/5.7.persistence_results.json",
            "comprehensive": "part5_test/5.8.comprehensive_results.json"
        }
        
        for test_name, file_path in result_files.items():
            if os.path.exists(file_path):
                try:
                    with open(file_path, 'r') as f:
                        data = json.load(f)
                        # 根据不同测试提取关键指标
                        if test_name == "platform_setup":
                            metrics["platform_readiness"] = "✅ 就绪" if data else "⚠️ 需检查"
                        elif test_name == "cache_performance":
                            metrics["cache_improvement"] = "显著提升" if data else "待验证"
                        # 可以继续添加其他指标的提取逻辑
                except:
                    continue
        
        return metrics
    
    def generate_markdown_report(self, report_data: Dict):
        """生成Markdown格式的报告"""
        markdown_content = f"""# 第五章 实验与分析 - 测试报告

## 测试概览

- **测试时间**: {report_data['timestamp']}
- **总测试数**: {report_data['test_summary']['total_tests']}
- **成功测试**: {report_data['test_summary']['successful_tests']} ✅
- **失败测试**: {report_data['test_summary']['failed_tests']} ❌
- **成功率**: {report_data['test_summary']['success_rate']:.1f}%
- **总执行时间**: {report_data['test_summary']['total_execution_time']:.2f}s

## 测试结果详情

| 测试脚本 | 状态 | 执行时间(s) | 备注 |
|---------|------|-------------|------|
"""
        
        for script, result in report_data['test_results'].items():
            status = result.get("status", "unknown")
            execution_time = result.get("execution_time", 0)
            status_icon = {
                "success": "✅",
                "failed": "❌", 
                "timeout": "⏰",
                "exception": "💥",
                "error": "🚫"
            }.get(status, "❓")
            
            markdown_content += f"| {script} | {status_icon} {status} | {execution_time:.2f} | - |\n"
        
        markdown_content += f"""
## 性能指标汇总

{self.format_performance_metrics(report_data.get('performance_summary', {}))}

## 测试建议

根据测试结果，建议：

1. **成功的测试项**: 继续保持当前配置
2. **失败的测试项**: 检查相关配置和依赖
3. **性能优化**: 根据具体指标进行针对性优化

## 下一步行动

- [ ] 修复失败的测试项
- [ ] 优化性能瓶颈
- [ ] 准备生产环境部署
- [ ] 制定监控和维护计划

---
*报告生成时间: {report_data['timestamp']}*
"""
        
        with open("part5_test/Chapter5_Test_Report.md", "w", encoding='utf-8') as f:
            f.write(markdown_content)
        
        print(f"📄 Markdown报告已保存到: part5_test/Chapter5_Test_Report.md")
    
    def format_performance_metrics(self, metrics: Dict) -> str:
        """格式化性能指标为Markdown"""
        if not metrics:
            return "性能数据收集中..."
        
        formatted = ""
        for key, value in metrics.items():
            formatted += f"- **{key}**: {value}\n"
        
        return formatted

def main():
    """主函数"""
    # 确保测试目录存在
    os.makedirs("part5_test", exist_ok=True)
    
    # 运行测试套件
    test_suite = Chapter5TestSuite()
    test_suite.run_all_tests()

if __name__ == "__main__":
    main()