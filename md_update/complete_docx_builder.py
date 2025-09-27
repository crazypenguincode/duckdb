#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
直接使用 python-docx 构建包含图片和公式的 DOCX 文档
"""

import os
import re
from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_PARAGRAPH_ALIGNMENT
from docx.oxml.shared import OxmlElement, qn

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"

def add_math_formula(paragraph, formula_text):
    """添加数学公式到段落（简化版本，将公式作为斜体文本）"""
    run = paragraph.add_run(formula_text)
    run.italic = True
    run.font.name = 'Cambria Math'

def process_markdown_content(content, doc, chapter_num):
    """处理 Markdown 内容并添加到文档"""
    lines = content.split('\n')
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # 处理标题
        if line.startswith('#'):
            level = len(line) - len(line.lstrip('#'))
            title_text = line.lstrip('#').strip()
            
            if level == 1:
                # 一级标题
                p = doc.add_heading(title_text, level=1)
                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
            elif level == 2:
                # 二级标题
                doc.add_heading(title_text, level=2)
            elif level == 3:
                # 三级标题
                doc.add_heading(title_text, level=3)
            else:
                # 四级及以下标题
                doc.add_heading(title_text, level=4)
        
        # 处理 Mermaid 代码块
        elif line.startswith('```mermaid'):
            # 跳过 mermaid 代码块，寻找对应的图片
            j = i + 1
            while j < len(lines) and not lines[j].strip().startswith('```'):
                j += 1
            
            # 查找下一行是否有图片标题
            if j + 1 < len(lines):
                next_line = lines[j + 1].strip()
                if next_line.startswith('**图'):
                    # 提取图片标题
                    title_match = re.search(r'\*\*图(\d+\.\d+)\s*(.*?)\*\*', next_line)
                    if title_match:
                        fig_num = title_match.group(1)
                        fig_title = title_match.group(2)
                        
                        # 查找对应的图片文件
                        image_pattern = f"{fig_num}_*.png"
                        matching_images = list(IMAGES_DIR.glob(f"{fig_num}_*.png"))
                        
                        if matching_images:
                            image_path = matching_images[0]
                            print(f"插入图片: {image_path}")
                            
                            # 添加图片
                            try:
                                doc.add_picture(str(image_path), width=Inches(6))
                                
                                # 添加图片标题
                                caption_p = doc.add_paragraph()
                                caption_p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                                caption_run = caption_p.add_run(f"图{fig_num} {fig_title}")
                                caption_run.bold = True
                                
                            except Exception as e:
                                print(f"插入图片失败: {e}")
                                # 添加占位符
                                p = doc.add_paragraph(f"[图片: 图{fig_num} {fig_title}]")
                                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        else:
                            print(f"未找到图片: {image_pattern}")
                            # 添加占位符
                            p = doc.add_paragraph(f"[图片: 图{fig_num} {fig_title}]")
                            p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        
                        i = j + 1  # 跳过图片标题行
            
            i = j  # 跳过整个 mermaid 代码块
        
        # 处理代码块
        elif line.startswith('```'):
            # 跳过代码块
            j = i + 1
            code_lines = []
            while j < len(lines) and not lines[j].strip().startswith('```'):
                code_lines.append(lines[j])
                j += 1
            
            # 添加代码块（简化处理）
            if code_lines:
                code_text = '\n'.join(code_lines)
                p = doc.add_paragraph()
                run = p.add_run(code_text)
                run.font.name = 'Consolas'
                run.font.size = Pt(9)
            
            i = j
        
        # 处理普通段落
        elif line:
            # 处理内联公式
            if '$' in line:
                p = doc.add_paragraph()
                parts = re.split(r'(\$[^$]+\$)', line)
                
                for part in parts:
                    if part.startswith('$') and part.endswith('$'):
                        # 这是公式
                        formula = part[1:-1]  # 去掉 $ 符号
                        add_math_formula(p, formula)
                    else:
                        # 普通文本
                        if part.strip():
                            # 处理粗体
                            if '**' in part:
                                bold_parts = re.split(r'(\*\*[^*]+\*\*)', part)
                                for bold_part in bold_parts:
                                    if bold_part.startswith('**') and bold_part.endswith('**'):
                                        run = p.add_run(bold_part[2:-2])
                                        run.bold = True
                                    else:
                                        p.add_run(bold_part)
                            else:
                                p.add_run(part)
            else:
                # 普通段落
                if '**' in line:
                    p = doc.add_paragraph()
                    bold_parts = re.split(r'(\*\*[^*]+\*\*)', line)
                    for bold_part in bold_parts:
                        if bold_part.startswith('**') and bold_part.endswith('**'):
                            run = p.add_run(bold_part[2:-2])
                            run.bold = True
                        else:
                            p.add_run(bold_part)
                else:
                    doc.add_paragraph(line)
        
        i += 1

def main():
    """主函数"""
    print("🔧 直接构建 DOCX 文档")
    
    # 创建新文档
    doc = Document()
    
    # 章节文件列表
    chapters = [
        ("第一章-绪论.md", 1),
        ("第二章-相关背景与理论基础.md", 2),
        ("第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md", 3),
        ("第四章-动态缓存更新技术与持久化技术.md", 4),
        ("第五章-实验与分析.md", 5),
        ("第六章-总结与展望.md", 6),
        ("统一参考文献列表.md", 7)
    ]
    
    for filename, chapter_num in chapters:
        filepath = BASE_DIR / filename
        
        if not filepath.exists():
            print(f"⚠️  文件不存在: {filename}")
            continue
        
        print(f"📖 处理: {filename}")
        
        # 读取文件内容
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 处理内容
        process_markdown_content(content, doc, chapter_num)
        
        # 在章节之间添加分页符（除了最后一章）
        if chapter_num < 7:
            doc.add_page_break()
    
    # 保存文档
    output_path = BASE_DIR / "direct_built_thesis.docx"
    doc.save(str(output_path))
    
    print(f"✅ 文档已保存: {output_path}")
    
    # 验证文档
    try:
        test_doc = Document(str(output_path))
        
        # 统计图片数量
        image_count = 0
        for rel in test_doc.part.rels.values():
            if "image" in rel.target_ref:
                image_count += 1
        
        print(f"📊 文档统计:")
        print(f"   - 段落数量: {len(test_doc.paragraphs)}")
        print(f"   - 嵌入图片: {image_count}")
        
    except Exception as e:
        print(f"❌ 验证失败: {e}")

if __name__ == "__main__":
    main()