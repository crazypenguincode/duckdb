#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
TPC-H 缓存策略测试结果分析脚本
"""

import json
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime

def load_test_results(filename):
    """加载测试结果"""
    with open(filename, 'r') as f:
        return json.load(f)

def analyze_results(data):
    """分析测试结果"""
    print("🔍 TPC-H 缓存策略测试结果分析")
    print("=" * 60)
    
    test_info = data['test_info']
    results = data['results']
    
    print(f"📊 测试信息:")
    print(f"  • 测试时间: {datetime.fromtimestamp(int(test_info['timestamp']))}")
    print(f"  • 数据库: {test_info['database']}")
    print(f"  • 工作负载大小: {test_info['workload_size']} 个查询")
    print(f"  • 测试策略数: {test_info['strategies_tested']} 种")
    
    print(f"\n📈 性能对比:")
    print(f"{'策略':<12} {'命中率':<8} {'响应时间':<10} {'缓存大小':<8} {'内存使用':<10}")
    print("-" * 60)
    
    for result in results:
        hit_rate = result['hit_rate'] * 100
        response_time = result['avg_response_time']
        cache_size = result['current_cache_size']
        memory_mb = result['memory_usage_mb']
        
        print(f"{result['strategy']:<12} {hit_rate:>6.1f}% {response_time:>8.1f}ms {cache_size:>6d} {memory_mb:>8.1f}MB")
    
    # 性能提升分析
    print(f"\n🚀 性能提升分析:")
    
    no_cache = next((r for r in results if r['strategy'] == 'No Cache'), None)
    lru_cache = next((r for r in results if r['strategy'] == 'LRU Cache'), None)
    ml_cache = next((r for r in results if r['strategy'] == 'ML Cache'), None)
    ttl_cache = next((r for r in results if r['strategy'] == 'TTL Cache'), None)
    
    if no_cache and ml_cache:
        improvement = (no_cache['avg_response_time'] - ml_cache['avg_response_time']) / no_cache['avg_response_time'] * 100
        print(f"  • ML缓存 vs 无缓存: 响应时间改善 {improvement:.1f}%")
    
    if lru_cache and ml_cache:
        hit_improvement = (ml_cache['hit_rate'] - lru_cache['hit_rate']) * 100
        time_improvement = (lru_cache['avg_response_time'] - ml_cache['avg_response_time']) / lru_cache['avg_response_time'] * 100
        print(f"  • ML缓存 vs LRU缓存: 命中率差异 {hit_improvement:+.1f}个百分点, 响应时间差异 {time_improvement:+.1f}%")
    
    if ttl_cache and ml_cache:
        hit_improvement = (ml_cache['hit_rate'] - ttl_cache['hit_rate']) * 100
        time_improvement = (ttl_cache['avg_response_time'] - ml_cache['avg_response_time']) / ttl_cache['avg_response_time'] * 100
        print(f"  • ML缓存 vs TTL缓存: 命中率提升 {hit_improvement:+.1f}个百分点, 响应时间改善 {time_improvement:+.1f}%")
    
    return results

def generate_recommendations(results):
    """生成算法改进建议"""
    print(f"\n💡 算法改进建议:")
    
    lru_cache = next((r for r in results if r['strategy'] == 'LRU Cache'), None)
    ml_cache = next((r for r in results if r['strategy'] == 'ML Cache'), None)
    ttl_cache = next((r for r in results if r['strategy'] == 'TTL Cache'), None)
    
    if lru_cache and ml_cache:
        if lru_cache['hit_rate'] > ml_cache['hit_rate']:
            print(f"  ⚠️  LRU缓存命中率({lru_cache['hit_rate']*100:.1f}%)高于ML缓存({ml_cache['hit_rate']*100:.1f}%)")
            print(f"     建议改进ML算法:")
            print(f"     1. 增加访问频率权重 (当前可能过低)")
            print(f"     2. 优化时间局部性预测")
            print(f"     3. 调整缓存容量 (LRU:{lru_cache['current_cache_size']}, ML:{ml_cache['current_cache_size']})")
        else:
            print(f"  ✅ ML缓存命中率({ml_cache['hit_rate']*100:.1f}%)优于LRU缓存({lru_cache['hit_rate']*100:.1f}%)")
    
    if ttl_cache and ml_cache:
        if ttl_cache['hit_rate'] > ml_cache['hit_rate']:
            print(f"  ⚠️  TTL缓存命中率({ttl_cache['hit_rate']*100:.1f}%)高于ML缓存({ml_cache['hit_rate']*100:.1f}%)")
            print(f"     建议改进:")
            print(f"     1. 增加时间敏感性权重")
            print(f"     2. 实现动态TTL预测")
        else:
            print(f"  ✅ ML缓存命中率({ml_cache['hit_rate']*100:.1f}%)优于TTL缓存({ttl_cache['hit_rate']*100:.1f}%)")
    
    # 基于TPC-H特点的建议
    print(f"\n🎯 基于TPC-H工作负载的优化建议:")
    print(f"  1. TPC-H查询特点:")
    print(f"     • 简单聚合查询(q01,q06)应该高频缓存")
    print(f"     • 复杂连接查询(q02,q19)计算成本高，值得缓存")
    print(f"     • 中等查询需要智能判断")
    
    print(f"  2. ML算法优化方向:")
    print(f"     • 增加查询复杂度权重 (执行时间 > 1s 的查询)")
    print(f"     • 实现查询模式识别 (SELECT COUNT vs JOIN)")
    print(f"     • 动态调整特征权重")
    
    print(f"  3. 缓存策略优化:")
    print(f"     • 为不同查询类型设置不同缓存策略")
    print(f"     • 实现分层缓存 (热点数据 + 长期数据)")
    print(f"     • 考虑查询结果大小的影响")

def create_visualization(results):
    """创建可视化图表"""
    try:
        strategies = [r['strategy'] for r in results]
        hit_rates = [r['hit_rate'] * 100 for r in results]
        response_times = [r['avg_response_time'] for r in results]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
        
        # 命中率对比
        bars1 = ax1.bar(strategies, hit_rates, color=['red', 'blue', 'green', 'orange'])
        ax1.set_title('缓存命中率对比')
        ax1.set_ylabel('命中率 (%)')
        ax1.set_ylim(0, max(hit_rates) * 1.2)
        
        # 在柱状图上添加数值标签
        for bar, rate in zip(bars1, hit_rates):
            height = bar.get_height()
            ax1.text(bar.get_x() + bar.get_width()/2., height + 1,
                    f'{rate:.1f}%', ha='center', va='bottom')
        
        # 响应时间对比
        bars2 = ax2.bar(strategies, response_times, color=['red', 'blue', 'green', 'orange'])
        ax2.set_title('平均响应时间对比')
        ax2.set_ylabel('响应时间 (ms)')
        ax2.set_ylim(0, max(response_times) * 1.2)
        
        # 在柱状图上添加数值标签
        for bar, time in zip(bars2, response_times):
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                    f'{time:.1f}ms', ha='center', va='bottom')
        
        plt.tight_layout()
        plt.savefig('cache_test/results/tpch_benchmark_chart.png', dpi=300, bbox_inches='tight')
        print(f"\n📊 可视化图表已保存: cache_test/results/tpch_benchmark_chart.png")
        
    except ImportError:
        print(f"\n📊 matplotlib未安装，跳过可视化图表生成")
        print(f"   安装命令: pip install matplotlib")

def main():
    """主函数"""
    try:
        # 加载测试结果
        data = load_test_results('cache_test/results/tpch_benchmark_report.json')
        
        # 分析结果
        results = analyze_results(data)
        
        # 生成改进建议
        generate_recommendations(results)
        
        # 创建可视化图表
        create_visualization(results)
        
        print(f"\n🎉 分析完成！")
        
    except FileNotFoundError:
        print("❌ 找不到测试结果文件: cache_test/results/tpch_benchmark_report.json")
        print("   请先运行 TPC-H 缓存基准测试")
    except Exception as e:
        print(f"❌ 分析失败: {e}")

if __name__ == "__main__":
    main()