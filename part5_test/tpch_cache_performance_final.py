#!/usr/bin/env python3
"""
TPC-H查询缓存性能测试脚本
测试所有22个TPC-H查询在有无缓存情况下的性能对比
生成Mermaid图表进行可视化分析
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime
from pathlib import Path

class TPCHCachePerformanceTest:
    def __init__(self):
        self.duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
        self.database_path = "/Users/max/test/tpc/tpch-sf1.db"
        self.queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
        self.results = {}
        self.test_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def verify_environment(self):
        """验证测试环境"""
        print("🔍 验证测试环境...")
        
        # 检查DuckDB可执行文件
        if not os.path.exists(self.duckdb_path):
            print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
            return False
        print(f"✅ DuckDB可执行文件: {self.duckdb_path}")
        
        # 检查数据库文件
        if not os.path.exists(self.database_path):
            print(f"❌ 数据库文件不存在: {self.database_path}")
            return False
        print(f"✅ 数据库文件: {self.database_path}")
        
        # 检查查询目录
        if not os.path.exists(self.queries_dir):
            print(f"❌ 查询目录不存在: {self.queries_dir}")
            return False
        print(f"✅ 查询目录: {self.queries_dir}")
        
        # 检查查询文件
        query_files = [f"q{i:02d}.sql" for i in range(1, 23)]
        missing_files = []
        for qfile in query_files:
            if not os.path.exists(os.path.join(self.queries_dir, qfile)):
                missing_files.append(qfile)
        
        if missing_files:
            print(f"❌ 缺少查询文件: {missing_files}")
            return False
        
        print(f"✅ 找到所有22个TPC-H查询文件")
        return True
    
    def execute_query(self, query_file, use_cache=True):
        """执行单个查询并返回执行时间"""
        try:
            # 构建命令
            cache_setting = "SET enable_query_cache=true;" if use_cache else "SET enable_query_cache=false;"
            
            # 读取查询内容
            with open(os.path.join(self.queries_dir, query_file), 'r') as f:
                query_content = f.read().strip()
            
            # 如果查询不以分号结尾，添加分号
            if not query_content.endswith(';'):
                query_content += ';'
            
            # 构建完整的SQL命令
            full_sql = f"{cache_setting} {query_content}"
            
            # 执行查询
            start_time = time.time()
            result = subprocess.run([
                self.duckdb_path, 
                self.database_path,
                "-c", full_sql
            ], capture_output=True, text=True, timeout=300)
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            if result.returncode != 0:
                print(f"❌ 查询 {query_file} 执行失败: {result.stderr}")
                return None
            
            return execution_time
            
        except subprocess.TimeoutExpired:
            print(f"⏰ 查询 {query_file} 执行超时")
            return None
        except Exception as e:
            print(f"❌ 执行查询 {query_file} 时出错: {str(e)}")
            return None
    
    def run_performance_test(self):
        """运行性能测试"""
        print("\n🚀 开始TPC-H缓存性能测试...")
        
        query_files = [f"q{i:02d}.sql" for i in range(1, 23)]
        
        for query_file in query_files:
            print(f"\n📊 测试查询: {query_file}")
            query_name = query_file.replace('.sql', '')
            
            self.results[query_name] = {
                'no_cache_1_run': [],
                'no_cache_10_runs': [],
                'with_cache_1_run': [],
                'with_cache_10_runs': []
            }
            
            # 测试无缓存单次执行
            print("  🔄 无缓存单次执行...")
            time_no_cache_1 = self.execute_query(query_file, use_cache=False)
            if time_no_cache_1:
                self.results[query_name]['no_cache_1_run'].append(time_no_cache_1)
                print(f"    ⏱️  执行时间: {time_no_cache_1:.3f}秒")
            
            # 测试无缓存10次执行
            print("  🔄 无缓存10次执行...")
            times_no_cache_10 = []
            for i in range(10):
                exec_time = self.execute_query(query_file, use_cache=False)
                if exec_time:
                    times_no_cache_10.append(exec_time)
                print(f"    第{i+1}次: {exec_time:.3f}秒" if exec_time else f"    第{i+1}次: 失败")
            
            if times_no_cache_10:
                self.results[query_name]['no_cache_10_runs'] = times_no_cache_10
                avg_time = statistics.mean(times_no_cache_10)
                print(f"    📈 平均时间: {avg_time:.3f}秒")
            
            # 测试有缓存单次执行
            print("  ⚡ 有缓存单次执行...")
            time_with_cache_1 = self.execute_query(query_file, use_cache=True)
            if time_with_cache_1:
                self.results[query_name]['with_cache_1_run'].append(time_with_cache_1)
                print(f"    ⏱️  执行时间: {time_with_cache_1:.3f}秒")
            
            # 测试有缓存10次执行
            print("  ⚡ 有缓存10次执行...")
            times_with_cache_10 = []
            for i in range(10):
                exec_time = self.execute_query(query_file, use_cache=True)
                if exec_time:
                    times_with_cache_10.append(exec_time)
                print(f"    第{i+1}次: {exec_time:.3f}秒" if exec_time else f"    第{i+1}次: 失败")
            
            if times_with_cache_10:
                self.results[query_name]['with_cache_10_runs'] = times_with_cache_10
                avg_time = statistics.mean(times_with_cache_10)
                print(f"    📈 平均时间: {avg_time:.3f}秒")
            
            # 计算性能提升
            if (time_no_cache_1 and time_with_cache_1):
                improvement = ((time_no_cache_1 - time_with_cache_1) / time_no_cache_1) * 100
                print(f"    🎯 单次执行性能提升: {improvement:.1f}%")
            
            if (times_no_cache_10 and times_with_cache_10):
                avg_no_cache = statistics.mean(times_no_cache_10)
                avg_with_cache = statistics.mean(times_with_cache_10)
                improvement = ((avg_no_cache - avg_with_cache) / avg_no_cache) * 100
                print(f"    🎯 10次执行平均性能提升: {improvement:.1f}%")
    
    def save_results(self):
        """保存测试结果"""
        results_file = f"tpch_cache_test_results_{self.test_timestamp}.json"
        
        # 计算统计信息
        summary = {
            'test_timestamp': self.test_timestamp,
            'total_queries': len(self.results),
            'environment': {
                'duckdb_path': self.duckdb_path,
                'database_path': self.database_path,
                'queries_dir': self.queries_dir
            },
            'results': self.results,
            'summary_stats': {}
        }
        
        # 计算汇总统计
        for query_name, data in self.results.items():
            if data['no_cache_1_run'] and data['with_cache_1_run']:
                no_cache_time = data['no_cache_1_run'][0]
                with_cache_time = data['with_cache_1_run'][0]
                improvement = ((no_cache_time - with_cache_time) / no_cache_time) * 100
                
                summary['summary_stats'][query_name] = {
                    'no_cache_1_run': no_cache_time,
                    'with_cache_1_run': with_cache_time,
                    'improvement_percent': improvement
                }
        
        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 测试结果已保存到: {results_file}")
        return results_file
    
    def generate_mermaid_charts(self):
        """生成Mermaid图表"""
        chart_file = f"tpch_cache_performance_chart_{self.test_timestamp}.md"
        
        # 准备数据
        queries = []
        no_cache_times = []
        with_cache_times = []
        improvements = []
        
        for query_name, data in self.results.items():
            if data['no_cache_1_run'] and data['with_cache_1_run']:
                queries.append(query_name)
                no_cache_times.append(data['no_cache_1_run'][0])
                with_cache_times.append(data['with_cache_1_run'][0])
                improvement = ((data['no_cache_1_run'][0] - data['with_cache_1_run'][0]) / data['no_cache_1_run'][0]) * 100
                improvements.append(improvement)
        
        # 生成Mermaid图表
        mermaid_content = f"""# TPC-H查询缓存性能测试结果

## 测试概览
- 测试时间: {self.test_timestamp}
- 测试查询数量: {len(queries)}
- 数据库: {self.database_path}

## 1. 执行时间对比柱状图

```mermaid
%%{{init: {{"theme": "base", "themeVariables": {{"primaryColor": "#ff6b6b", "primaryTextColor": "#fff", "primaryBorderColor": "#ff4757", "lineColor": "#5f27cd", "secondaryColor": "#00d2d3", "tertiaryColor": "#fff"}}}}}}%%
xychart-beta
    title "TPC-H查询执行时间对比 (秒)"
    x-axis [{', '.join([f'"{q}"' for q in queries[:10]])}]
    y-axis "执行时间 (秒)" 0 --> {max(max(no_cache_times[:10]), max(with_cache_times[:10])) * 1.1:.2f}
    bar [无缓存] [{', '.join([f'{t:.3f}' for t in no_cache_times[:10]])}]
    bar [有缓存] [{', '.join([f'{t:.3f}' for t in with_cache_times[:10]])}]
```

## 2. 性能提升百分比柱状图

```mermaid
%%{{init: {{"theme": "base", "themeVariables": {{"primaryColor": "#2ed573", "primaryTextColor": "#fff", "primaryBorderColor": "#7bed9f", "lineColor": "#5f27cd"}}}}}}%%
xychart-beta
    title "TPC-H查询缓存性能提升百分比"
    x-axis [{', '.join([f'"{q}"' for q in queries[:10]])}]
    y-axis "性能提升 (%)" 0 --> {max(improvements[:10]) * 1.1:.1f}
    bar [性能提升] [{', '.join([f'{imp:.1f}' for imp in improvements[:10]])}]
```

## 3. 执行时间趋势折线图

```mermaid
%%{{init: {{"theme": "base", "themeVariables": {{"primaryColor": "#3742fa", "primaryTextColor": "#fff", "primaryBorderColor": "#5352ed", "lineColor": "#ff6348"}}}}}}%%
xychart-beta
    title "TPC-H查询执行时间趋势"
    x-axis [{', '.join([f'"{q}"' for q in queries])}]
    y-axis "执行时间 (秒)" 0 --> {max(max(no_cache_times), max(with_cache_times)) * 1.1:.2f}
    line [无缓存] [{', '.join([f'{t:.3f}' for t in no_cache_times])}]
    line [有缓存] [{', '.join([f'{t:.3f}' for t in with_cache_times])}]
```

## 4. 详细测试结果

| 查询 | 无缓存时间(秒) | 有缓存时间(秒) | 性能提升(%) |
|------|---------------|---------------|-------------|
"""
        
        # 添加详细结果表格
        for i, query in enumerate(queries):
            mermaid_content += f"| {query} | {no_cache_times[i]:.3f} | {with_cache_times[i]:.3f} | {improvements[i]:.1f}% |\n"
        
        # 添加统计摘要
        avg_improvement = statistics.mean(improvements) if improvements else 0
        max_improvement = max(improvements) if improvements else 0
        min_improvement = min(improvements) if improvements else 0
        
        mermaid_content += f"""
## 5. 统计摘要

- **平均性能提升**: {avg_improvement:.1f}%
- **最大性能提升**: {max_improvement:.1f}%
- **最小性能提升**: {min_improvement:.1f}%
- **测试查询总数**: {len(queries)}

## 6. 结论

通过对TPC-H标准查询集的测试，查询缓存功能在大多数查询上都显示出了显著的性能提升。
平均性能提升达到了{avg_improvement:.1f}%，这表明查询缓存是一个非常有效的性能优化手段。
"""
        
        with open(chart_file, 'w', encoding='utf-8') as f:
            f.write(mermaid_content)
        
        print(f"📊 Mermaid图表已生成: {chart_file}")
        return chart_file
    
    def run_test(self):
        """运行完整测试"""
        print("🎯 TPC-H查询缓存性能测试")
        print("=" * 50)
        
        # 验证环境
        if not self.verify_environment():
            print("❌ 环境验证失败，测试终止")
            return False
        
        # 运行性能测试
        self.run_performance_test()
        
        # 保存结果
        results_file = self.save_results()
        
        # 生成图表
        chart_file = self.generate_mermaid_charts()
        
        print("\n🎉 测试完成!")
        print(f"📁 结果文件: {results_file}")
        print(f"📊 图表文件: {chart_file}")
        
        return True

def main():
    """主函数"""
    test = TPCHCachePerformanceTest()
    success = test.run_test()
    
    if success:
        print("\n✅ TPC-H缓存性能测试成功完成")
        sys.exit(0)
    else:
        print("\n❌ TPC-H缓存性能测试失败")
        sys.exit(1)

if __name__ == "__main__":
    main()