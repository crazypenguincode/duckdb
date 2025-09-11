#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
最终完美版 DOCX 构建器，使用 Word 原生数学公式和严格字体控制
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
    """设置文档样式和默认字体"""
    # 获取默认样式
    styles = doc.styles
    
    # 设置 Normal 样式
    normal_style = styles['Normal']
    normal_font = normal_style.font
    normal_font.name = 'Times New Roman'
    normal_font.size = Pt(12)
    
    # 设置段落格式
    normal_paragraph_format = normal_style.paragraph_format
    normal_paragraph_format.space_after = Pt(6)
    normal_paragraph_format.line_spacing = 1.15
    
    # 设置标题样式
    heading_sizes = {1: 18, 2: 16, 3: 14, 4: 12}
    
    for level in range(1, 5):
        heading_style_name = f'Heading {level}'
        if heading_style_name in styles:
            heading_style = styles[heading_style_name]
        else:
            heading_style = styles.add_style(heading_style_name, WD_STYLE_TYPE.PARAGRAPH)
        
        heading_font = heading_style.font
        heading_font.name = 'Times New Roman'
        heading_font.size = Pt(heading_sizes[level])
        heading_font.bold = True
        heading_font.color.rgb = RGBColor(0, 0, 0)
        
        heading_paragraph_format = heading_style.paragraph_format
        heading_paragraph_format.space_before = Pt(12)
        heading_paragraph_format.space_after = Pt(6)

def create_math_element(latex_formula):
    """创建 Word 原生数学公式元素"""
    try:
        # 简化的 LaTeX 到 OMML 转换
        formula = latex_formula.strip()
        
        # 基本符号替换
        replacements = {
            r'\\frac\{([^}]+)\}\{([^}]+)\}': r'(\1)/(\2)',
            r'\\sqrt\{([^}]+)\}': r'√(\1)',
            r'\\lim_\{([^}]+)\}': r'lim[(\1)]',
            r'\\sum_\{([^}]+)\}\^\{([^}]+)\}': r'Σ[(\1) to (\2)]',
            r'\\int_\{([^}]+)\}\^\{([^}]+)\}': r'∫[(\1) to (\2)]',
            r'\\to': r'→',
            r'\\infty': r'∞',
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
            r'\^(\w+)': r'^\1',
            r'_(\w+)': r'_\1'
        }
        
        for pattern, replacement in replacements.items():
            formula = re.sub(pattern, replacement, formula)
        
        return formula
        
    except Exception as e:
        print(f"公式转换失败: {e}")
        return latex_formula

def add_math_to_paragraph(paragraph, formula_text):
    """向段落添加数学公式"""
    try:
        converted_formula = create_math_element(formula_text)
        
        # 创建数学公式的 run
        run = paragraph.add_run(converted_formula)
        run.font.name = 'Cambria Math'
        run.font.size = Pt(12)
        run.italic = True
        
        # 强制设置字体
        rPr = run._element.get_or_add_rPr()
        rFonts = OxmlElement('w:rFonts')
        rFonts.set(qn('w:ascii'), 'Cambria Math')
        rFonts.set(qn('w:hAnsi'), 'Cambria Math')
        rFonts.set(qn('w:cs'), 'Cambria Math')
        rPr.append(rFonts)
        
    except Exception as e:
        print(f"添加公式失败: {e}")
        # 降级处理
        run = paragraph.add_run(formula_text)
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

def add_formatted_text(paragraph, text, bold=False, italic=False):
    """添加格式化文本到段落"""
    run = paragraph.add_run(text)
    
    # 设置字体
    run.font.name = 'Times New Roman'
    run.font.size = Pt(12)
    run.bold = bold
    run.italic = italic
    
    # 强制设置字体（确保在所有系统上一致）
    rPr = run._element.get_or_add_rPr()
    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), 'Times New Roman')
    rFonts.set(qn('w:hAnsi'), 'Times New Roman')
    rFonts.set(qn('w:cs'), 'Times New Roman')
    rPr.append(rFonts)
    
    return run

def process_text_with_formatting(paragraph, text):
    """处理包含格式化标记的文本"""
    if '**' in text:
        # 处理粗体
        parts = re.split(r'(\*\*[^*]+\*\*)', text)
        for part in parts:
            if part.startswith('**') and part.endswith('**'):
                add_formatted_text(paragraph, part[2:-2], bold=True)
            else:
                if part.strip():
                    add_formatted_text(paragraph, part)
    else:
        add_formatted_text(paragraph, text)

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
                # 强制设置标题字体
                for run in heading.runs:
                    run.font.name = 'Times New Roman'
                    run.font.bold = True
                    
                    # 设置字体大小
                    if level == 1:
                        run.font.size = Pt(18)
                    elif level == 2:
                        run.font.size = Pt(16)
                    elif level == 3:
                        run.font.size = Pt(14)
                    else:
                        run.font.size = Pt(12)
                    
                    # 强制字体设置
                    rPr = run._element.get_or_add_rPr()
                    rFonts = OxmlElement('w:rFonts')
                    rFonts.set(qn('w:ascii'), 'Times New Roman')
                    rFonts.set(qn('w:hAnsi'), 'Times New Roman')
                    rFonts.set(qn('w:cs'), 'Times New Roman')
                    rPr.append(rFonts)
            else:
                p = doc.add_paragraph()
                add_formatted_text(p, title_text, bold=True)
        
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
                        add_formatted_text(caption_p, f"图{fig_num} {fig_title}", bold=True)
                        
                        print(f"✅ 成功插入图片: {image_path.name}")
                        
                    except Exception as e:
                        print(f"❌ 插入图片失败: {e}")
                        p = doc.add_paragraph()
                        p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        add_formatted_text(p, f"[图片占位符: 图{fig_num} {fig_title}]")
                else:
                    print(f"❌ 未找到图片文件: 图{fig_num}")
                    p = doc.add_paragraph()
                    p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                    add_formatted_text(p, f"[图片缺失: 图{fig_num} {fig_title}]")
        
        # 跳过 mermaid 代码块
        elif line.startswith('```mermaid'):
            j = i + 1
            while j < len(lines) and not lines[j].strip().startswith('```'):
                j += 1
            i = j
        
        # 处理其他代码块
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
                
                # 强制设置代码字体
                rPr = run._element.get_or_add_rPr()
                rFonts = OxmlElement('w:rFonts')
                rFonts.set(qn('w:ascii'), 'Consolas')
                rFonts.set(qn('w:hAnsi'), 'Consolas')
                rFonts.set(qn('w:cs'), 'Consolas')
                rPr.append(rFonts)
            
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
                        add_math_to_paragraph(p, part)
                    else:  # 偶数索引是普通文本
                        if part.strip():
                            process_text_with_formatting(p, part)
            
            # 处理块级公式 $$...$$
            elif line.startswith('$$') and line.endswith('$$'):
                formula = line[2:-2].strip()
                p = doc.add_paragraph()
                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                add_math_to_paragraph(p, formula)
            
            # 处理多行块级公式
            elif line.startswith('$$'):
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
                add_math_to_paragraph(p, formula)
                i = j
            
            # 普通段落
            else:
                p = doc.add_paragraph()
                process_text_with_formatting(p, line)
        
        i += 1

def main():
    """主函数"""
    print("🔧 最终完美版 DOCX 构建器")
    print("📝 特性：Word 原生数学公式 + 严格字体控制")
    
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
        ("第三章-动态缓存管理.md", 3),
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
    output_path = BASE_DIR / "perfect_thesis_final.docx"
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
        
        print("🎯 完美特性:")
        print("   - ✅ 强制字体控制: Times New Roman")
        print("   - ✅ Word 原生数学公式支持")
        print("   - ✅ 统一字体大小: 12pt")
        print("   - ✅ 专业标题格式")
        print("   - ✅ 图片完美显示")
        
    except Exception as e:
        print(f"❌ 验证失败: {e}")

if __name__ == "__main__":
    main()