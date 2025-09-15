#!/usr/bin/env python3
"""
生成表5.7最终报告和可视化图表
整理所有测试结果，生成论文用图表和表格
"""

import json
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime
import seaborn as sns

class FinalReportGenerator:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / "results"
        
        # 设置中文字体
        plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'DejaVu Sans']
        plt.rcParams['axes.unicode_minus'] = False
        
    def load_latest_results(self):
        """加载最新的测试结果"""
        json_files = list(self.results_dir.glob("complete_table_5_7_test_*.json"))
        if not json_files:
            print("❌ 未找到测试结果文件")
            return None
            
        # 获取最新的结果文件
        latest_file = max(json_files, key=lambda x: x.stat().st_mtime)
        print(f"📄 加载结果文件: {latest_file}")
        
        with open(latest_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def generate_performance_chart(self, results_data):
        """生成性能对比图表"""
        detailed_results = results_data['detailed_results']
        
        # 准备数据
        datasets = []
        no_cache_times = []
        cache_times = []
        improvements = []
        
        for result in detailed_results:
            datasets.append(result.get('description', result['dataset_name']))
            no_cache_times.append(result['avg_no_cache_time_ms'])
            cache_times.append(result['avg_cache_time_ms'])
            improvements.append(result['avg_improvement_pct'])
        
        # 创建图表
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        # 子图1: 执行时间对比
        x = np.arange(len(datasets))
        width = 0.35
        
        bars1 = ax1.bar(x - width/2, no_cache_times, width, label='无缓存', color='#ff7f7f', alpha=0.8)
        bars2 = ax1.bar(x + width/2, cache_times, width, label='有缓存', color='#7fbf7f', alpha=0.8)
        
        ax1.set_xlabel('数据集类型')
        ax1.set_ylabel('执行时间 (ms)')
        ax1.set_title('DuckDB查询缓存性能对比 - 执行时间')
        ax1.set_xticks(x)
        ax1.set_xticklabels(datasets, rotation=45, ha='right')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # 添加数值标签
        for bar in bars1:
            height = bar.get_height()
            ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'{height:.1f}', ha='center', va='bottom', fontsize=9)
        
        for bar in bars2:
            height = bar.get_height()
            ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'{height:.1f}', ha='center', va='bottom', fontsize=9)
        
        # 子图2: 性能提升百分比
        colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4']
        bars3 = ax2.bar(datasets, improvements, color=colors, alpha=0.8)
        
        ax2.set_xlabel('数据集类型')
        ax2.set_ylabel('性能提升 (%)')
        ax2.set_title('DuckDB查询缓存性能提升')
        ax2.set_xticklabels(datasets, rotation=45, ha='right')
        ax2.grid(True, alpha=0.3)
        
        # 添加数值标签
        for bar in bars3:
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'{height:.1f}%', ha='center', va='bottom', fontsize=10, fontweight='bold')
        
        # 添加平均线
        avg_improvement = sum(improvements) / len(improvements)
        ax2.axhline(y=avg_improvement, color='red', linestyle='--', alpha=0.7, 
                   label=f'平均提升: {avg_improvement:.1f}%')
        ax2.legend()
        
        plt.tight_layout()
        
        # 保存图表
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        chart_file = self.results_dir / f"performance_chart_{timestamp}.png"
        plt.savefig(chart_file, dpi=300, bbox_inches='tight')
        print(f"📊 性能图表已保存: {chart_file}")
        
        return chart_file
    
    def generate_table_5_7_latex(self, results_data):
        """生成LaTeX格式的表5.7"""
        detailed_results = results_data['detailed_results']
        
        latex_content = """
\\begin{table}[htbp]
\\centering
\\caption{DuckDB查询缓存性能测试结果}
\\label{tab:query_cache_performance}
\\begin{tabular}{|l|l|l|l|r|l|}
\\hline
\\textbf{数据集类型} & \\textbf{数据规模} & \\textbf{查询特点} & \\textbf{测试目标} & \\textbf{缓存提升} & \\textbf{状态} \\\\
\\hline
"""
        
        for result in detailed_results:
            dataset_name = result.get('description', result['dataset_name'])
            target = result.get('target', f"{result['successful_tests']}个查询")
            test_goal = result.get('test_goal', '性能测试')
            improvement = result['avg_improvement_pct']
            status = "优秀" if improvement >= 70 else "良好" if improvement >= 50 else "一般"
            
            # 映射中文名称
            if 'repeat' in result['dataset_name']:
                dataset_name = "重复查询集"
                target = "1000个查询"
                test_goal = "缓存命中率测试"
            elif 'parameterized' in result['dataset_name']:
                dataset_name = "参数化查询集"
                target = "500个模板"
                test_goal = "SQL标准化测试"
            elif 'cte' in result['dataset_name']:
                dataset_name = "CTE查询集"
                target = "200个查询"
                test_goal = "CTE缓存优化测试"
            elif 'concurrent' in result['dataset_name']:
                dataset_name = "并发查询集"
                target = "100个查询"
                test_goal = "并发性能测试"
            
            latex_content += f"\\textbf{{{dataset_name}}} & {target} & 高重复率(80\\%) & {test_goal} & {improvement:.1f}\\% & {status} \\\\\n\\hline\n"
        
        latex_content += """\\end{tabular}
\\end{table}
"""
        
        # 保存LaTeX文件
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        latex_file = self.results_dir / f"table_5_7_{timestamp}.tex"
        with open(latex_file, 'w', encoding='utf-8') as f:
            f.write(latex_content)
        
        print(f"📝 LaTeX表格已保存: {latex_file}")
        return latex_file
    
    def generate_summary_report(self, results_data):
        """生成总结报告"""
        print("\n" + "="*80)
        print("📊 表5.7 DuckDB查询缓存性能测试 - 最终报告")
        print("="*80)
        
        test_summary = results_data['test_summary']
        detailed_results = results_data['detailed_results']
        
        print(f"🕒 测试时间: {results_data['timestamp']}")
        print(f"📈 测试覆盖率: {test_summary['successful_tests']}/{test_summary['total_tests']} ({test_summary['coverage_pct']:.1f}%)")
        print(f"🎯 平均性能提升: {test_summary['avg_improvement_pct']:.1f}%")
        
        print(f"\n{'='*80}")
        print("📋 详细测试结果:")
        print(f"{'='*80}")
        
        print(f"{'数据集类型':<20} {'查询数':<8} {'无缓存(ms)':<12} {'缓存(ms)':<10} {'提升':<10} {'评级':<8}")
        print("-" * 78)
        
        for result in detailed_results:
            dataset_name = result['dataset_name']
            query_count = result['successful_tests']
            no_cache_time = result['avg_no_cache_time_ms']
            cache_time = result['avg_cache_time_ms']
            improvement = result['avg_improvement_pct']
            
            # 评级
            if improvement >= 70:
                rating = "🎉 优秀"
            elif improvement >= 50:
                rating = "✅ 良好"  
            elif improvement >= 25:
                rating = "⚠️  一般"
            else:
                rating = "❌ 较差"
            
            print(f"{dataset_name:<20} {query_count:<8} {no_cache_time:<12.1f} {cache_time:<10.1f} {improvement:<9.1f}% {rating:<8}")
        
        print("-" * 78)
        print(f"{'平均性能提升':<20} {'':<8} {'':<12} {'':<10} {test_summary['avg_improvement_pct']:<9.1f}% {'📈 总体':<8}")
        
        print(f"\n{'='*80}")
        print("🎯 关键发现:")
        print(f"{'='*80}")
        
        # 分析结果
        best_performer = max(detailed_results, key=lambda x: x['avg_improvement_pct'])
        worst_performer = min(detailed_results, key=lambda x: x['avg_improvement_pct'])
        
        print(f"✅ 最佳性能: {best_performer['dataset_name']} ({best_performer['avg_improvement_pct']:.1f}% 提升)")
        print(f"⚠️  最低性能: {worst_performer['dataset_name']} ({worst_performer['avg_improvement_pct']:.1f}% 提升)")
        
        # 性能分级统计
        excellent = sum(1 for r in detailed_results if r['avg_improvement_pct'] >= 70)
        good = sum(1 for r in detailed_results if 50 <= r['avg_improvement_pct'] < 70)
        average = sum(1 for r in detailed_results if 25 <= r['avg_improvement_pct'] < 50)
        poor = sum(1 for r in detailed_results if r['avg_improvement_pct'] < 25)
        
        print(f"📊 性能分布: 优秀({excellent}) | 良好({good}) | 一般({average}) | 较差({poor})")
        
        if test_summary['avg_improvement_pct'] >= 60:
            print("🎉 总体评价: DuckDB查询缓存表现优秀，显著提升查询性能")
        elif test_summary['avg_improvement_pct'] >= 40:
            print("✅ 总体评价: DuckDB查询缓存表现良好，有效提升查询性能")
        else:
            print("⚠️  总体评价: DuckDB查询缓存表现一般，需要进一步优化")
        
        return True
    
    def run_report_generation(self):
        """运行报告生成"""
        print("🚀 开始生成表5.7最终报告")
        
        # 加载测试结果
        results_data = self.load_latest_results()
        if not results_data:
            return False
        
        # 生成总结报告
        self.generate_summary_report(results_data)
        
        # 生成图表
        try:
            chart_file = self.generate_performance_chart(results_data)
            print(f"✅ 性能图表生成成功")
        except Exception as e:
            print(f"⚠️  图表生成失败: {e}")
        
        # 生成LaTeX表格
        try:
            latex_file = self.generate_table_5_7_latex(results_data)
            print(f"✅ LaTeX表格生成成功")
        except Exception as e:
            print(f"⚠️  LaTeX表格生成失败: {e}")
        
        print(f"\n🎉 表5.7最终报告生成完成！")
        print(f"📁 所有文件保存在: {self.results_dir}")
        
        return True

def main():
    generator = FinalReportGenerator()
    success = generator.run_report_generation()
    
    if success:
        print("\n✅ 报告生成成功！可用于论文撰写和图表制作")
    else:
        print("\n❌ 报告生成失败")

if __name__ == "__main__":
    main()