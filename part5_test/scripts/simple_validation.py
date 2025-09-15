#!/usr/bin/env python3
"""
动态更新策略结果简单验证脚本

本脚本提供基础的结果验证功能，检查测试结果的合理性。
"""

import os
import json
import glob
from typing import Dict, List, Any
from datetime import datetime

class SimpleValidator:
    """简单验证器"""
    
    def __init__(self, results_dir: str):
        self.results_dir = results_dir
        
    def load_latest_results(self) -> Dict[str, Any]:
        """加载最新的测试结果"""
        pattern = os.path.join(self.results_dir, "dynamic_update_strategy_*.json")
        result_files = glob.glob(pattern)
        
        if not result_files:
            raise FileNotFoundError("未找到动态策略测试结果文件")
        
        latest_file = max(result_files, key=os.path.getctime)
        
        with open(latest_file, 'r', encoding='utf-8') as f:
            results = json.load(f)
        
        print(f"加载测试结果: {latest_file}")
        return results
    
    def validate_basic_structure(self, results: Dict[str, Any]) -> List[str]:
        """验证基本结构"""
        issues = []
        
        required_sections = [
            'multi_strategy_coordination',
            'lru_strategy', 
            'ttl_strategy',
            'hybrid_strategy',
            'ml_strategy'
        ]
        
        for section in required_sections:
            if section not in results:
                issues.append(f"缺少测试部分: {section}")
        
        return issues
    
    def validate_performance_metrics(self, results: Dict[str, Any]) -> List[str]:
        """验证性能指标合理性"""
        issues = []
        
        # 检查多策略协调结果
        coord_results = results.get('multi_strategy_coordination', {})
        strategy_combos = coord_results.get('strategy_combinations', {})
        
        for strategy, metrics in strategy_combos.items():
            hit_rate = metrics.get('hit_rate', 0)
            if not (0 <= hit_rate <= 100):
                issues.append(f"{strategy}命中率超出范围: {hit_rate}")
            
            response_time = metrics.get('response_time', 0)
            if response_time <= 0:
                issues.append(f"{strategy}响应时间无效: {response_time}")
        
        return issues
    
    def validate_ml_training(self, results: Dict[str, Any]) -> List[str]:
        """验证ML训练结果"""
        issues = []
        
        ml_results = results.get('ml_strategy', {})
        training = ml_results.get('model_training_test', {})
        
        if training:
            accuracy_progression = training.get('accuracy_progression', [])
            if accuracy_progression:
                # 检查训练是否有改善
                initial = accuracy_progression[0]
                final = accuracy_progression[-1]
                
                if final <= initial:
                    issues.append("ML模型训练未显示改善")
                
                # 检查最终准确率是否合理
                if final < 80 or final > 95:
                    issues.append(f"ML模型最终准确率异常: {final}%")
        
        return issues
    
    def run_validation(self) -> bool:
        """运行验证"""
        print("开始简单验证...")
        
        try:
            results = self.load_latest_results()
        except FileNotFoundError as e:
            print(f"错误: {e}")
            return False
        
        all_issues = []
        
        # 基本结构验证
        structure_issues = self.validate_basic_structure(results)
        all_issues.extend(structure_issues)
        
        # 性能指标验证
        performance_issues = self.validate_performance_metrics(results)
        all_issues.extend(performance_issues)
        
        # ML训练验证
        ml_issues = self.validate_ml_training(results)
        all_issues.extend(ml_issues)
        
        # 输出结果
        print(f"\n验证完成，发现 {len(all_issues)} 个问题:")
        
        if all_issues:
            for issue in all_issues:
                print(f"- {issue}")
            return False
        else:
            print("✅ 所有基本验证通过")
            return True

def main():
    """主函数"""
    results_dir = "/Users/max/src/duckdb/part5_test/results"
    
    if not os.path.exists(results_dir):
        print(f"错误: 结果目录不存在: {results_dir}")
        return
    
    validator = SimpleValidator(results_dir)
    success = validator.run_validation()
    
    exit(0 if success else 1)

if __name__ == "__main__":
    main()