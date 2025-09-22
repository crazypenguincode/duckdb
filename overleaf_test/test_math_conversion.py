#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数学公式转换测试脚本
"""

import re

def test_math_formula_conversion():
    """测试数学公式转换"""
    
    # 测试文本，包含数学公式
    test_content = """
布隆过滤器的数学特性决定了其性能表现。设已插入n个元素，某个位仍为0的概率为$(1 - \\frac{1}{m})^{kn}$，当m很大时可近似为$e^{-kn/m}$。因此假阳性率为$(1 - e^{-kn/m})^k$。通过数学推导可得最优哈希函数数量$k_{opt} = \\frac{m}{n} \\ln 2$，最优位数组大小$m = -\\frac{n \\ln p}{(\\ln 2)^2}$，其中p为目标假阳性率。

缓存价值评估通过多因素模型$V(item) = \\alpha \\cdot freq(item) + \\beta \\cdot recency(item) + \\gamma \\cdot size(item) + \\delta \\cdot cost(item)$综合考虑访问频率、最近访问时间、数据大小和重新计算成本等因素。
"""
    
    print("原始内容:")
    print(test_content)
    print("\n" + "="*60 + "\n")
    
    # 保护数学公式
    math_placeholders = {}
    math_counter = 0
    
    def protect_math(match):
        nonlocal math_counter
        math_content = match.group(0)  # 保留完整的$...$格式
        placeholder = f"MATHPLACEHOLDER{math_counter}MATHPLACEHOLDER"
        math_placeholders[placeholder] = math_content
        print(f"保护公式 {math_counter}: {math_content} -> {placeholder}")
        math_counter += 1
        return placeholder
    
    # 保护数学公式
    protected_content = re.sub(r'\$[^$\n]+?\$', protect_math, test_content)
    
    print(f"\n保护后的内容:")
    print(protected_content)
    print(f"\n占位符映射:")
    for placeholder, formula in math_placeholders.items():
        print(f"  {placeholder} -> {formula}")
    
    # 模拟其他转换过程（转义特殊字符）
    processed_content = protected_content
    processed_content = re.sub(r'(?<!\\)&', r'\\&', processed_content)
    processed_content = re.sub(r'(?<!\\)%', r'\\%', processed_content)
    # 不转义$符号，因为数学公式需要保留
    processed_content = re.sub(r'(?<!\\)#', r'\\#', processed_content)
    # 转义下划线，现在不需要担心占位符了
    processed_content = re.sub(r'(?<!\\)_', r'\\_', processed_content)
    
    print(f"\n转义特殊字符后:")
    print(processed_content)
    
    # 恢复数学公式
    final_content = processed_content
    for placeholder, math_content in math_placeholders.items():
        final_content = final_content.replace(placeholder, math_content)
        print(f"恢复公式: {placeholder} -> {math_content}")
    
    print(f"\n最终结果:")
    print(final_content)
    
    # 检查是否还有未恢复的占位符
    remaining_placeholders = re.findall(r'__MATH_PLACEHOLDER_\d+__', final_content)
    if remaining_placeholders:
        print(f"\n警告: 发现未恢复的占位符: {remaining_placeholders}")
    else:
        print(f"\n✓ 所有数学公式都已正确恢复")

if __name__ == "__main__":
    test_math_formula_conversion()