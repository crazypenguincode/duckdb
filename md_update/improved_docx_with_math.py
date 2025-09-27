#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
改进版 DOCX 构建器，支持原生数学公式和统一字体
"""

import os
import re
import json
from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_PARAGRAPH_ALIGNMENT
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.shared import OxmlElement, qn
from docx.oxml.ns import nsdecls
from docx.oxml import parse_xml

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"

def setup_document_styles(doc):
    """设置文档样式"""
    # 设置默认字体
    style = doc.styles['Normal']
    font = style.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    
    # 创建标题样式
    for level in range(1, 5):
        heading_style = doc.styles[f'Heading {level}']
        heading_font = heading_style.font
        heading_font.name = 'Times New Roman'
        heading_font.bold = True
        
        if level == 1:
            heading_font.size = Pt(18)
        elif level == 2:
            heading_font.size = Pt(16)
        elif level == 3:
            heading_font.size = Pt(14)
        else:
            heading_font.size = Pt(12)

def add_math_equation(paragraph, latex_formula):
    """添加数学公式到段落"""
    try:
        # 简化的公式处理：将常见的 LaTeX 符号转换
        formula = latex_formula.strip()
        
        # 基本符号替换
        replacements = {
            r'\\frac\{([^}]+)\}\{([^}]+)\}': r'(\1)/(\2)',
            r'\\lim_\{([^}]+)\}': r'lim[(\1)]',
            r'\\to': r'→',
            r'\\infty': r'∞',
            r'\\sum': r'Σ',
            r'\\int': r'∫',
            r'\\alpha': r'α',
            r'\\beta': r'β',
            r'\\gamma': r'γ',
            r'\\delta': r'δ',
            r'\\epsilon': r'ε',
            r'\\theta': r'θ',
            r'\\lambda': r'λ',
            r'\\mu': r'μ',
            r'\\pi': r'π',
            r'\\sigma': r'σ',
            r'\\phi': r'φ',
            r'\\omega': r'ω',
            r'\\leq': r'≤',
            r'\\geq': r'≥',
            r'\\neq': r'≠',
            r'\\approx': r'≈',
            r'\\cdot': r'·',
            r'\\times': r'×',
            r'\\div': r'÷',
            r'\\pm': r'±',
            r'\\sqrt\{([^}]+)\}': r'√(\1)',
            r'\^(\w+)': r'^\1',
            r'_(\w+)': r'_\1'
        }
        
        for pattern, replacement in replacements.items():
            formula = re.sub(pattern, replacement, formula)
        
        # 添加公式文本
        run = paragraph.add_run(formula)
        run.font.name = 'Cambria Math'
        run.font.size = Pt(12)
        run.italic = True
        
    except Exception as e:
        print(f"公式处理失败: {e}, 原始公式: {latex_formula}")
        # 降级处理：直接显示原始公式
        run = paragraph.add_run(latex_formula)
        run.font.name = 'Cambria Math'
        run.font.size = Pt(12)
        run.italic = True

def load_image_index():
    """加载图片索引"""
    index_file = BASE_DIR / "图片提取报告.json"
    if index_file.exists():
        with open(index_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def get_image_for_figure(fig_num, image_index):
    """根据图号获取对应的图片文件"""
    pattern = f"{fig_num}_*.png"
    matches = list(IMAGES_DIR.glob(pattern))
    if matches:
        return matches[0]
    return None

def add_formatted_paragraph(doc, text, style='Normal'):
    """添加格式化段落"""
    p = doc.add_paragraph(style=style)
    
    # 处理粗体文本
    if '**' in text:
        parts = re.split(r'(\*\*[^*]+\*\*)', text)
        for part in parts:
            if part.startswith('**') and part.endswith('**'):
                run = p.add_run(part[2:-2])
                run.bold = True
                run.font.name = 'Times New Roman'
                run.font.size = Pt(12)
            else:
                if part.strip():
                    run = p.add_run(part)
                    run.font.name = 'Times New Roman'
                    run.font.size = Pt(12)
    else:
        run = p.add_run(text)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(12)
    
    return p

def process_chapter(content, doc, chapter_num, image_index):
    """处理单个章节"""
    lines = content.split('\n')
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # 处理标题
        if line.startswith('#'):
            level = len(line) - len(line.lstrip('#'))
            title_text = line.lstrip('#').strip()
            
            if level <= 4:
                heading = doc.add_heading(title_text, level=level)
                # 确保标题字体一致
                for run in heading.runs:
                    run.font.name = 'Times New Roman'
                    run.font.bold = True
                    if level == 1:
                        run.font.size = Pt(18)
                    elif level == 2:
                        run.font.size = Pt(16)
                    elif level == 3:
                        run.font.size = Pt(14)
                    else:
                        run.font.size = Pt(12)
            else:
                p = add_formatted_paragraph(doc, title_text)
                for run in p.runs:
                    run.bold = True
        
        # 处理图片标题
        elif line.startswith('**图') and line.endswith('**'):
            match = re.search(r'\*\*图(\d+\.\d+)\s*(.*?)\*\*', line)
            if match:
                fig_num = match.group(1)
                fig_title = match.group(2).strip()
                
                print(f"处理图片: 图{fig_num} {fig_title}")
                
                image_path = get_image_for_figure(fig_num, image_index)
                
                if image_path and image_path.exists():
                    try:
                        # 添加图片
                        doc.add_picture(str(image_path), width=Inches(5.5))
                        
                        # 添加图片标题
                        caption_p = doc.add_paragraph()
                        caption_p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        caption_run = caption_p.add_run(f"图{fig_num} {fig_title}")
                        caption_run.bold = True
                        caption_run.font.name = 'Times New Roman'
                        caption_run.font.size = Pt(12)
                        
                        print(f"✅ 成功插入图片: {image_path.name}")
                        
                    except Exception as e:
                        print(f"❌ 插入图片失败: {e}")
                        p = add_formatted_paragraph(doc, f"[图片占位符: 图{fig_num} {fig_title}]")
                        p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                else:
                    print(f"❌ 未找到图片文件: 图{fig_num}")
                    p = add_formatted_paragraph(doc, f"[图片缺失: 图{fig_num} {fig_title}]")
                    p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
        
        # 跳过 mermaid 代码块
        elif line.startswith('```mermaid'):
            j = i + 1
            while j < len(lines) and not lines[j].strip().startswith('```'):
                j += 1
            i = j
        
        # 跳过其他代码块
        elif line.startswith('```'):
            j = i + 1
            code_lines = []
            while j < len(lines) and not lines[j].strip().startswith('```'):
                code_lines.append(lines[j])
                j += 1
            
            # 添加代码块
            if code_lines:
                code_text = '\n'.join(code_lines)
                p = doc.add_paragraph()
                run = p.add_run(code_text)
                run.font.name = 'Consolas'
                run.font.size = Pt(10)
            
            i = j
        
        # 处理普通段落
        elif line:
            # 处理内联公式 $...$
            if '$' in line and not line.startswith('$$'):
                p = doc.add_paragraph()
                formula_pattern = r'\$([^$]+)\$'
                parts = re.split(formula_pattern, line)
                
                for idx, part in enumerate(parts):
                    if idx % 2 == 1:  # 奇数索引是公式内容
                        add_math_equation(p, part)
                    else:  # 偶数索引是普通文本
                        if part.strip():
                            if '**' in part:
                                bold_parts = re.split(r'(\*\*[^*]+\*\*)', part)
                                for bold_part in bold_parts:
                                    if bold_part.startswith('**') and bold_part.endswith('**'):
                                        run = p.add_run(bold_part[2:-2])
                                        run.bold = True
                                        run.font.name = 'Times New Roman'
                                        run.font.size = Pt(12)
                                    else:
                                        run = p.add_run(bold_part)
                                        run.font.name = 'Times New Roman'
                                        run.font.size = Pt(12)
                            else:
                                run = p.add_run(part)
                                run.font.name = 'Times New Roman'
                                run.font.size = Pt(12)
            
            # 处理块级公式 $$...$$
            elif line.startswith('$$') and line.endswith('$$'):
                formula = line[2:-2].strip()
                p = doc.add_paragraph()
                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                add_math_equation(p, formula)
            
            # 处理多行块级公式
            elif line.startswith('$$'):
                # 收集多行公式
                formula_lines = [line[2:]]  # 去掉开头的 $$
                j = i + 1
                while j < len(lines):
                    if lines[j].strip().endswith('$$'):
                        formula_lines.append(lines[j].strip()[:-2])  # 去掉结尾的 $$
                        break
                    else:
                        formula_lines.append(lines[j])
                    j += 1
                
                formula = '\n'.join(formula_lines).strip()
                p = doc.add_paragraph()
                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                add_math_equation(p, formula)
                i = j
            
            # 普通段落
            else:
                add_formatted_paragraph(doc, line)
        
        i += 1

def main():
    """主函数"""
    print("🔧 改进版 DOCX 构建器（支持数学公式和统一字体）")
    
    # 加载图片索引
    image_index = load_image_index()
    print(f"📊 加载图片索引: {len(image_index.get('chapters', {}))} 个章节")
    
    # 创建新文档
    doc = Document()
    
    # 设置文档样式
    setup_document_styles(doc)
    
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
        
        print(f"\n📖 处理章节: {filename}")
        
        # 读取文件内容
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 处理内容
        process_chapter(content, doc, chapter_num, image_index)
        
        # 在章节之间添加分页符（除了最后一章）
        if chapter_num < 7:
            doc.add_page_break()
    
    # 保存文档
    output_path = BASE_DIR / "improved_thesis_with_math.docx"
    doc.save(str(output_path))
    
    print(f"\n✅ 文档已保存: {output_path}")
    
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
        
        if image_count > 0:
            print("🎉 成功插入图片！")
        
        print("📝 改进内容:")
        print("   - ✅ 统一字体: Times New Roman 12pt")
        print("   - ✅ 改进公式处理: LaTeX → Unicode 符号")
        print("   - ✅ 统一标题字体大小")
        print("   - ✅ 代码块使用 Consolas 字体")
        
    except Exception as e:
        print(f"❌ 验证失败: {e}")

if __name__ == "__main__":
    main()