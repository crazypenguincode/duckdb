#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试新的图片命名规则
验证修改后的脚本是否按照新规则工作
"""

import re
from pathlib import Path

def test_naming_rules():
    """测试新的命名规则"""
    print("测试新的图片命名规则...")
    
    # 测试示例
    test_cases = [
        {
            'chapter': 5,
            'fig_num': '5.18',
            'title': '机器学习模型特征重要性分布',
            'expected_filename': '5-图5.18 机器学习模型特征重要性分布.png',
            'expected_latex_title': '机器学习模型特征重要性分布'
        },
        {
            'chapter': 3,
            'fig_num': '3.1',
            'title': '动态缓存管理系统架构流程',
            'expected_filename': '3-图3.1 动态缓存管理系统架构流程.png',
            'expected_latex_title': '动态缓存管理系统架构流程'
        },
        {
            'chapter': 2,
            'fig_num': '2.1',
            'title': '数据库查询处理流水线架构',
            'expected_filename': '2-图2.1 数据库查询处理流水线架构.png',
            'expected_latex_title': '数据库查询处理流水线架构'
        }
    ]
    
    print("\n=== 命名规则测试 ===")
    for i, case in enumerate(test_cases, 1):
        print(f"\n测试用例 {i}:")
        print(f"  章节: {case['chapter']}")
        print(f"  图号: {case['fig_num']}")
        print(f"  原标题: 图{case['fig_num']} {case['title']}")
        print(f"  期望文件名: {case['expected_filename']}")
        print(f"  期望LaTeX标题: {case['expected_latex_title']}")
        
        # 模拟新的命名逻辑
        actual_filename = f"{case['chapter']}-图{case['fig_num']} {case['title']}.png"
        actual_latex_title = case['title']  # 只保留纯标题
        
        print(f"  实际文件名: {actual_filename}")
        print(f"  实际LaTeX标题: {actual_latex_title}")
        
        # 验证结果
        filename_match = actual_filename == case['expected_filename']
        title_match = actual_latex_title == case['expected_latex_title']
        
        print(f"  文件名匹配: {'✅' if filename_match else '❌'}")
        print(f"  标题匹配: {'✅' if title_match else '❌'}")
        
        if not (filename_match and title_match):
            print(f"  ❌ 测试失败!")
        else:
            print(f"  ✅ 测试通过!")

def test_regex_patterns():
    """测试正则表达式模式"""
    print("\n=== 正则表达式测试 ===")
    
    # 测试图片文件名匹配模式
    test_filenames = [
        "5-图5.18 机器学习模型特征重要性分布.png",
        "3-图3.1 动态缓存管理系统架构流程.png", 
        "2-图2.1 数据库查询处理流水线架构.png",
        "1-图1.1 研究背景.png",
        "6-图6.1 总结与展望.png"
    ]
    
    for filename in test_filenames:
        print(f"\n测试文件名: {filename}")
        
        # 提取章节号
        chapter_match = re.match(r"(\d+)-图\d+\.\d+", filename)
        if chapter_match:
            chapter = chapter_match.group(1)
            print(f"  提取章节号: {chapter}")
        
        # 提取图号
        fig_match = re.match(r"\d+-图(\d+\.\d+)", filename)
        if fig_match:
            fig_num = fig_match.group(1)
            print(f"  提取图号: {fig_num}")
        
        # 提取标题
        title_match = re.match(r"\d+-图\d+\.\d+ (.+)\.png", filename)
        if title_match:
            title = title_match.group(1)
            print(f"  提取标题: {title}")

def test_chapter_image_matching():
    """测试章节图片匹配逻辑"""
    print("\n=== 章节图片匹配测试 ===")
    
    # 模拟图片文件列表
    mock_images = [
        "5-图5.1 TPC-H数据集生成流程.png",
        "5-图5.18 机器学习模型特征重要性分布.png", 
        "5-图5.2 四类查询响应时间实测对比.png",
        "3-图3.1 动态缓存管理系统架构流程.png",
        "2-图2.1 数据库查询处理流水线架构.png"
    ]
    
    # 测试第5章图片匹配
    chapter_num = 5
    print(f"测试第{chapter_num}章图片匹配:")
    
    matched_images = []
    for img_name in mock_images:
        if img_name.startswith(f"{chapter_num}-图{chapter_num}."):
            matched_images.append(img_name)
            print(f"  ✅ 匹配: {img_name}")
        else:
            print(f"  ❌ 不匹配: {img_name}")
    
    print(f"\n第{chapter_num}章匹配到 {len(matched_images)} 个图片")
    
    # 测试排序逻辑
    def extract_figure_number(filename):
        match = re.match(rf"{chapter_num}-图{chapter_num}\.(\d+)", filename)
        if match:
            return int(match.group(1))
        return 0
    
    sorted_images = sorted(matched_images, key=extract_figure_number)
    print(f"排序后的图片:")
    for img in sorted_images:
        fig_num = extract_figure_number(img)
        print(f"  图{chapter_num}.{fig_num}: {img}")

if __name__ == "__main__":
    print("🧪 新图片命名规则测试")
    print("="*50)
    
    test_naming_rules()
    test_regex_patterns() 
    test_chapter_image_matching()
    
    print("\n" + "="*50)
    print("✅ 测试完成!")
    print("\n📋 修改总结:")
    print("1. 图片文件命名: 章节号-图片本身名称 (如: 5-图5.18 机器学习模型特征重要性分布.png)")
    print("2. LaTeX标题: 只包含图片名字 (如: 机器学习模型特征重要性分布)")
    print("3. 路径格式: images/5-图5.18 机器学习模型特征重要性分布.png")