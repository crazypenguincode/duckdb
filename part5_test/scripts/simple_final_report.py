#!/usr/bin/env python3
"""
生成表5.7最终报告（简化版，无需matplotlib依赖）
整理所有测试结果，生成论文用表格和总结
"""

import json
from pathlib import Path
from datetime import datetime

class SimpleFinalReportGenerator:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent
        self.results_dir = self.base_dir / "results"
        
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
    
    def generate_table_5_7_latex(self, results_data):
        """生成LaTeX格式的表5.7"""
        detailed_results = results_data['detailed_results']
        
        latex_content = """\\begin{table}[htbp]
\\centering
\\caption{DuckDB查询缓存性能测试结果}
\\label{tab:query_cache_performance}
\\begin{tabular}{|l|l|l|l|r|l|}
\\hline
\\textbf{数据集类型} & \\textbf{数据规模} & \\textbf{查询特点} & \\textbf{测试目标} & \\textbf{缓存提升} & \\textbf{状态} \\\\
\\hline
"""
        
        for result in detailed_results:
            dataset_name = result['dataset_name']
            improvement = result['avg_improvement_pct']
            query_count = result['successful_tests']
            
            # 映射数据集信息
            if 'repeat' in dataset_name:
                name = "重复查询集"
                scale = "1000个查询"
                feature = "高重复率(80\\%)"
                target = "缓存命中率测试"
            elif 'parameterized' in dataset_name:
                name = "参数化查询集"
                scale = "500个模板"
                feature = "参数变化"
                target = "SQL标准化测试"
            elif 'cte' in dataset_name:
                name = "CTE查询集"
                scale = "200个查询"
                feature = "复杂CTE结构"
                target = "CTE缓存优化测试"
            elif 'concurrent' in dataset_name:
                name = "并发查询集"
                scale = "100个查询"
                feature = "高并发访问"
                target = "并发性能测试"
            else:
                name = dataset_name
                scale = f"{query_count}个查询"
                feature = "标准查询"
                target = "性能测试"
            
            status = "优秀" if improvement >= 70 else "良好" if improvement >= 50 else "一般"
            
            latex_content += f"\\textbf{{{name}}} & {scale} & {feature} & {target} & {improvement:.1f}\\% & {status} \\\\\n\\hline\n"
        
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
    
    def generate_markdown_table(self, results_data):
        """生成Markdown格式的表格"""
        detailed_results = results_data['detailed_results']
        
        markdown_content = """# 表5.7 DuckDB查询缓存性能测试结果

| 数据集类型 | 数据规模 | 查询特点 | 测试目标 | 缓存提升 | 状态 |
|------------|----------|----------|----------|----------|------|
"""
        
        for result in detailed_results:
            dataset_name = result['dataset_name']
            improvement = result['avg_improvement_pct']
            query_count = result['successful_tests']
            
            # 映射数据集信息
            if 'repeat' in dataset_name:
                name = "**重复查询集**"
                scale = "1000个查询"
                feature = "高重复率(80%)"
                target = "缓存命中率测试"
            elif 'parameterized' in dataset_name:
                name = "**参数化查询集**"
                scale = "500个模板"
                feature = "参数变化"
                target = "SQL标准化测试"
            elif 'cte' in dataset_name:
                name = "**CTE查询集**"
                scale = "200个查询"
                feature = "复杂CTE结构"
                target = "CTE缓存优化测试"
            elif 'concurrent' in dataset_name:
                name = "**并发查询集**"
                scale = "100个查询"
                feature = "高并发访问"
                target = "并发性能测试"
            else:
                name = f"**{dataset_name}**"
                scale = f"{query_count}个查询"
                feature = "标准查询"
                target = "性能测试"
            
            status = "✅ 优秀" if improvement >= 70 else "✅ 良好" if improvement >= 50 else "⚠️ 一般"
            
            markdown_content += f"| {name} | {scale} | {feature} | {target} | {improvement:.1f}% | {status} |\n"
        
        # 添加总结
        test_summary = results_data['test_summary']
        markdown_content += f"""
## 测试总结

- **测试覆盖率**: {test_summary['successful_tests']}/{test_summary['total_tests']} ({test_summary['coverage_pct']:.1f}%)
- **平均性能提升**: {test_summary['avg_improvement_pct']:.1f}%
- **测试时间**: {results_data['timestamp']}

## 性能分析

"""
        
        # 分析结果
        best_performer = max(detailed_results, key=lambda x: x['avg_improvement_pct'])
        worst_performer = min(detailed_results, key=lambda x: x['avg_improvement_pct'])
        
        markdown_content += f"- **最佳性能**: {best_performer['dataset_name']} ({best_performer['avg_improvement_pct']:.1f}% 提升)\n"
        markdown_content += f"- **最低性能**: {worst_performer['dataset_name']} ({worst_performer['avg_improvement_pct']:.1f}% 提升)\n"
        
        # 性能分级统计
        excellent = sum(1 for r in detailed_results if r['avg_improvement_pct'] >= 70)
        good = sum(1 for r in detailed_results if 50 <= r['avg_improvement_pct'] < 70)
        average = sum(1 for r in detailed_results if 25 <= r['avg_improvement_pct'] < 50)
        poor = sum(1 for r in detailed_results if r['avg_improvement_pct'] < 25)
        
        markdown_content += f"- **性能分布**: 优秀({excellent}) | 良好({good}) | 一般({average}) | 较差({poor})\n"
        
        # 保存Markdown文件
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        md_file = self.results_dir / f"table_5_7_report_{timestamp}.md"
        with open(md_file, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
        
        print(f"📝 Markdown报告已保存: {md_file}")
        return md_file
    
    def generate_excel_data(self, results_data):
        """生成Excel兼容的CSV数据"""
        detailed_results = results_data['detailed_results']
        
        # 保存详细数据CSV
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        csv_file = self.results_dir / f"detailed_results_{timestamp}.csv"
        
        with open(csv_file, 'w', encoding='utf-8') as f:
            f.write("数据集类型,数据集名称,查询数量,无缓存时间(ms),缓存时间(ms),性能提升(%),评级,测试目标\n")
            
            for result in detailed_results:
                dataset_name = result['dataset_name']
                query_count = result['successful_tests']
                no_cache_time = result['avg_no_cache_time_ms']
                cache_time = result['avg_cache_time_ms']
                improvement = result['avg_improvement_pct']
                
                # 映射信息
                if 'repeat' in dataset_name:
                    display_name = "重复查询集"
                    target = "缓存命中率测试"
                elif 'parameterized' in dataset_name:
                    display_name = "参数化查询集"
                    target = "SQL标准化测试"
                elif 'cte' in dataset_name:
                    display_name = "CTE查询集"
                    target = "CTE缓存优化测试"
                elif 'concurrent' in dataset_name:
                    display_name = "并发查询集"
                    target = "并发性能测试"
                else:
                    display_name = dataset_name
                    target = "性能测试"
                
                rating = "优秀" if improvement >= 70 else "良好" if improvement >= 50 else "一般" if improvement >= 25 else "较差"
                
                f.write(f"{display_name},{dataset_name},{query_count},{no_cache_time:.1f},{cache_time:.1f},{improvement:.1f},{rating},{target}\n")
        
        print(f"📊 详细CSV数据已保存: {csv_file}")
        return csv_file
    
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
        print("🚀 开始生成表5.7最终报告（简化版）")
        
        # 加载测试结果
        results_data = self.load_latest_results()
        if not results_data:
            return False
        
        # 生成总结报告
        self.generate_summary_report(results_data)
        
        # 生成LaTeX表格
        try:
            latex_file = self.generate_table_5_7_latex(results_data)
            print(f"✅ LaTeX表格生成成功")
        except Exception as e:
            print(f"⚠️  LaTeX表格生成失败: {e}")
        
        # 生成Markdown报告
        try:
            md_file = self.generate_markdown_table(results_data)
            print(f"✅ Markdown报告生成成功")
        except Exception as e:
            print(f"⚠️  Markdown报告生成失败: {e}")
        
        # 生成Excel数据
        try:
            csv_file = self.generate_excel_data(results_data)
            print(f"✅ Excel数据生成成功")
        except Exception as e:
            print(f"⚠️  Excel数据生成失败: {e}")
        
        print(f"\n🎉 表5.7最终报告生成完成！")
        print(f"📁 所有文件保存在: {self.results_dir}")
        
        return True

def main():
    generator = SimpleFinalReportGenerator()
    success = generator.run_report_generation()
    
    if success:
        print("\n✅ 报告生成成功！可用于论文撰写和图表制作")
        print("\n📋 生成的文件类型:")
        print("  - LaTeX表格 (.tex) - 可直接插入LaTeX文档")
        print("  - Markdown报告 (.md) - 便于查看和分享")
        print("  - CSV数据 (.csv) - 可导入Excel进行进一步分析")
        print("  - JSON数据 (.json) - 包含完整的测试结果")
    else:
        print("\n❌ 报告生成失败")

if __name__ == "__main__":
    main()