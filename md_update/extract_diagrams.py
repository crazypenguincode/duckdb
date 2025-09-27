#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简化的文档处理脚本
"""

import os
import re
from pathlib import Path

def extract_mermaid_diagrams():
    """提取所有Mermaid图表"""
    base_dir = Path("/Users/max/src/duckdb/md_update")
    images_dir = base_dir / "images"
    images_dir.mkdir(exist_ok=True)
    
    chapter_files = [
        ("第一章-绪论.md", "1"),
        ("第二章-相关背景与理论基础.md", "2"), 
        ("第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md", "3"),
        ("第四章-动态缓存更新技术与持久化技术.md", "4"),
        ("第五章-实验与分析.md", "5"),
        ("第六章-总结与展望.md", "6")
    ]
    
    all_diagrams = []
    
    for filename, chapter_num in chapter_files:
        file_path = base_dir / filename
        if not file_path.exists():
            continue
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取Mermaid图表
        mermaid_pattern = r'```mermaid\n(.*?)\n```'
        diagrams = re.findall(mermaid_pattern, content, re.DOTALL)
        
        for i, diagram in enumerate(diagrams):
            # 提取图表标题
            title_match = re.search(r'title\s+"([^"]+)"', diagram)
            if title_match:
                title = title_match.group(1)
            else:
                # 从图表类型推断标题
                if 'graph' in diagram:
                    title = "流程图"
                elif 'pie' in diagram:
                    title = "饼图"
                elif 'xychart' in diagram:
                    title = "图表"
                elif 'sequenceDiagram' in diagram:
                    title = "序列图"
                else:
                    title = f"图表{i+1}"
            
            # 生成文件名
            safe_title = title.replace(' ', '_').replace('/', '_').replace(':', '_')
            filename_base = f"{chapter_num}.{i+1}_{safe_title}"
            mmd_filename = f"{filename_base}.mmd"
            png_filename = f"{filename_base}.png"
            
            # 保存mermaid源文件
            mmd_path = images_dir / mmd_filename
            with open(mmd_path, 'w', encoding='utf-8') as f:
                f.write(diagram)
            
            all_diagrams.append({
                'chapter': chapter_num,
                'index': i + 1,
                'title': title,
                'mmd_file': mmd_filename,
                'png_file': png_filename,
                'content': diagram
            })
            
            print(f"提取图表: 第{chapter_num}章 图{chapter_num}.{i+1} - {title}")
    
    return all_diagrams

def generate_image_index(diagrams):
    """生成图片索引文件"""
    base_dir = Path("/Users/max/src/duckdb/md_update")
    
    index_content = "# 图片索引\n\n"
    index_content += "本文档包含的所有图表及其文件信息：\n\n"
    
    # 按章节分组
    chapters = {}
    for img in diagrams:
        chapter = img['chapter']
        if chapter not in chapters:
            chapters[chapter] = []
        chapters[chapter].append(img)
    
    for chapter in sorted(chapters.keys(), key=lambda x: int(x)):
        index_content += f"## 第{chapter}章\n\n"
        index_content += "| 图号 | 标题 | Mermaid文件 | PNG文件 |\n"
        index_content += "|------|------|-------------|----------|\n"
        
        for img in chapters[chapter]:
            index_content += f"| 图{chapter}.{img['index']} | {img['title']} | [{img['mmd_file']}](images/{img['mmd_file']}) | [{img['png_file']}](images/{img['png_file']}) |\n"
        
        index_content += "\n"
    
    # 保存索引文件
    index_path = base_dir / "图片索引.md"
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(index_content)
    
    return index_path

if __name__ == "__main__":
    print("开始提取Mermaid图表...")
    diagrams = extract_mermaid_diagrams()
    print(f"总共提取了 {len(diagrams)} 个图表")
    
    print("生成图片索引...")
    index_path = generate_image_index(diagrams)
    print(f"图片索引已生成: {index_path}")
    
    print("完成!")