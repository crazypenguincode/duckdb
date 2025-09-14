#!/usr/bin/env python3
"""
第五章 5.3节 - 布隆过滤器对查询的影响评估
测试假阳性率控制效果和过滤效率分析
"""

import os
import sys
import time
import json
import math
import random
import hashlib
import statistics
from typing import Dict, List, Tuple, Set

class BloomFilterTest:
    def __init__(self):
        self.results = {}
        
    def create_bloom_filter(self, size: int, hash_functions: int) -> Dict:
        """创建布隆过滤器"""
        return {
            'size': size,
            'hash_functions': hash_functions,
            'bit_array': [0] * size,
            'items_added': 0
        }
    
    def hash_item(self, item: str, hash_func_index: int, size: int) -> int:
        """计算哈希值"""
        hash_input = f"{item}_{hash_func_index}".encode('utf-8')
        hash_value = int(hashlib.md5(hash_input).hexdigest(), 16)
        return hash_value % size
    
    def add_to_bloom_filter(self, bloom_filter: Dict, item: str):
        """向布隆过滤器添加元素"""
        for i in range(bloom_filter['hash_functions']):
            index = self.hash_item(item, i, bloom_filter['size'])
            bloom_filter['bit_array'][index] = 1
        bloom_filter['items_added'] += 1
    
    def check_bloom_filter(self, bloom_filter: Dict, item: str) -> bool:
        """检查元素是否可能在布隆过滤器中"""
        for i in range(bloom_filter['hash_functions']):
            index = self.hash_item(item, i, bloom_filter['size'])
            if bloom_filter['bit_array'][index] == 0:
                return False
        return True
    
    def calculate_optimal_parameters(self, expected_items: int, false_positive_rate: float) -> Tuple[int, int]:
        """计算最优参数"""
        # 计算最优位数组大小
        m = int(-expected_items * math.log(false_positive_rate) / (math.log(2) ** 2))
        # 计算最优哈希函数数量
        k = int(m * math.log(2) / expected_items)
        return m, max(1, k)
    
    def test_false_positive_rate_control(self) -> Dict:
        """5.3.1 假阳性率控制效果测试"""
        print("\n=== 5.3.1 假阳性率控制效果测试 ===")
        
        results = {
            'parameter_optimization': {},
            'false_positive_rates': {},
            'memory_usage': {},
            'query_latency': {}
        }
        
        # 测试不同假阳性率设置
        target_fp_rates = [0.001, 0.005, 0.01, 0.02, 0.05, 0.1]  # 0.1% 到 10%
        expected_items = 10000
        
        print("测试不同假阳性率参数...")
        
        for target_fp_rate in target_fp_rates:
            print(f"  目标假阳性率: {target_fp_rate*100:.1f}%")
            
            # 计算最优参数
            optimal_size, optimal_hash_funcs = self.calculate_optimal_parameters(expected_items, target_fp_rate)
            
            # 创建布隆过滤器
            bloom_filter = self.create_bloom_filter(optimal_size, optimal_hash_funcs)
            
            # 添加已知元素
            known_items = set()
            for i in range(expected_items):
                item = f"query_hash_{i}"
                known_items.add(item)
                self.add_to_bloom_filter(bloom_filter, item)
            
            # 测试假阳性率
            test_items = 10000
            false_positives = 0
            
            start_time = time.time()
            for i in range(test_items):
                test_item = f"unknown_query_{i}"
                if test_item not in known_items and self.check_bloom_filter(bloom_filter, test_item):
                    false_positives += 1
            end_time = time.time()
            
            actual_fp_rate = false_positives / test_items
            memory_usage_mb = optimal_size / (8 * 1024 * 1024)  # 转换为MB
            query_latency_us = (end_time - start_time) * 1000000 / test_items  # 微秒
            
            results['parameter_optimization'][target_fp_rate] = {
                'optimal_size': optimal_size,
                'optimal_hash_functions': optimal_hash_funcs,
                'actual_fp_rate': actual_fp_rate,
                'memory_usage_mb': memory_usage_mb,
                'query_latency_us': query_latency_us
            }
            
            print(f"    最优大小: {optimal_size:,} 位 ({memory_usage_mb:.2f} MB)")
            print(f"    最优哈希函数数: {optimal_hash_funcs}")
            print(f"    实际假阳性率: {actual_fp_rate*100:.2f}%")
            print(f"    查询延迟: {query_latency_us:.1f} μs")
        
        return results
    
    def run_comprehensive_test(self):
        """运行综合测试"""
        print("第五章 5.3节 - 布隆过滤器对查询的影响评估")
        print("=" * 60)
        
        # 运行测试
        self.results['false_positive_control'] = self.test_false_positive_rate_control()
        
        # 生成测试报告
        self.generate_report()
    
    def generate_report(self):
        """生成测试报告"""
        print("\n" + "=" * 60)
        print("布隆过滤器影响评估报告")
        print("=" * 60)
        
        # 保存结果
        with open("part5_test/5.3.bloom_filter_results.json", "w") as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 测试结果已保存到: part5_test/5.3.bloom_filter_results.json")

def main():
    """主函数"""
    test = BloomFilterTest()
    test.run_comprehensive_test()

if __name__ == "__main__":
    main()