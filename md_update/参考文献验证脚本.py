#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
参考文献验证脚本
验证所有章节中的参考文献引用是否正确使用
"""

import os
import re
from collections import defaultdict

def extract_references_from_file(file_path):
    """从文件中提取参考文献引用"""
    references = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # 查找 [数字] 格式的引用
            matches = re.findall(r'\[(\d+)\]', content)
            references.update(int(match) for match in matches)
    except Exception as e:
        print(f"读取文件 {file_path} 时出错: {e}")
    return references

def extract_reference_list():
    """从统一参考文献列表中提取所有参考文献"""
    ref_file = "/Users/max/src/duckdb/md_update/统一参考文献列表.md"
    references = {}
    try:
        with open(ref_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # 查找 [数字] 格式的参考文献定义
            pattern = r'\[(\d+)\]\s+(.+?)(?=\n\[|\n\n|$)'
            matches = re.findall(pattern, content, re.DOTALL)
            for match in matches:
                ref_num = int(match[0])
                ref_text = match[1].strip()
                references[ref_num] = ref_text
    except Exception as e:
        print(f"读取参考文献列表时出错: {e}")
    return references

def main():
    """主函数"""
    # 章节文件列表
    chapter_files = [
        "/Users/max/src/duckdb/md_update/第一章-绪论.md",
        "/Users/max/src/duckdb/md_update/第二章-相关背景与理论基础.md",
        "/Users/max/src/duckdb/md_update/第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
        "/Users/max/src/duckdb/md_update/第四章-动态缓存更新技术与持久化技术.md",
        "/Users/max/src/duckdb/md_update/第五章-实验与分析.md",
        "/Users/max/src/duckdb/md_update/第六章-总结与展望.md"
    ]
    
    # 提取所有参考文献定义
    all_references = extract_reference_list()
    print(f"参考文献列表中共有 {len(all_references)} 个参考文献")
    
    # 统计每个章节的引用情况
    chapter_usage = {}
    all_used_refs = set()
    
    for i, file_path in enumerate(chapter_files, 1):
        if os.path.exists(file_path):
            refs = extract_references_from_file(file_path)
            chapter_usage[f"第{i}章"] = refs
            all_used_refs.update(refs)
            print(f"第{i}章使用了 {len(refs)} 个参考文献: {sorted(refs)}")
        else:
            print(f"文件不存在: {file_path}")
    
    # 检查未使用的参考文献
    unused_refs = set(all_references.keys()) - all_used_refs
    print(f"\n未使用的参考文献 ({len(unused_refs)} 个): {sorted(unused_refs)}")
    
    # 检查引用了但不存在的参考文献
    missing_refs = all_used_refs - set(all_references.keys())
    print(f"引用了但不存在的参考文献 ({len(missing_refs)} 个): {sorted(missing_refs)}")
    
    # 生成验证报告
    report_path = "/Users/max/src/duckdb/md_update/参考文献验证报告.md"
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("# 参考文献验证报告\n\n")
        f.write(f"## 验证概要\n\n")
        f.write(f"- 参考文献总数: {len(all_references)}\n")
        f.write(f"- 已使用参考文献: {len(all_used_refs)}\n")
        f.write(f"- 未使用参考文献: {len(unused_refs)}\n")
        f.write(f"- 缺失参考文献: {len(missing_refs)}\n\n")
        
        f.write("## 各章节引用统计\n\n")
        for chapter, refs in chapter_usage.items():
            f.write(f"### {chapter}\n")
            f.write(f"- 引用数量: {len(refs)}\n")
            f.write(f"- 引用编号: {sorted(refs)}\n\n")
        
        if unused_refs:
            f.write("## 未使用的参考文献\n\n")
            for ref_num in sorted(unused_refs):
                f.write(f"[{ref_num}] {all_references[ref_num][:100]}...\n\n")
        
        if missing_refs:
            f.write("## 缺失的参考文献\n\n")
            for ref_num in sorted(missing_refs):
                f.write(f"[{ref_num}] - 需要添加到参考文献列表\n\n")
        
        f.write("## 验证结果\n\n")
        if not unused_refs and not missing_refs:
            f.write("✅ 所有参考文献引用正确，无问题发现。\n")
        else:
            f.write("⚠️ 发现以下问题需要处理:\n")
            if unused_refs:
                f.write(f"- {len(unused_refs)} 个未使用的参考文献\n")
            if missing_refs:
                f.write(f"- {len(missing_refs)} 个缺失的参考文献\n")
    
    print(f"\n验证报告已生成: {report_path}")

if __name__ == "__main__":
    main()