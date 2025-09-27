#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
增强数学公式处理的 Word 文档构建器
专门优化指数、对数、复杂表达式的显示
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

def create_base_template():
    """创建基础模板文档"""
    doc = Document()
    
    # 删除默认段落
    for paragraph in doc.paragraphs:
        p = paragraph._element
        p.getparent().remove(p)
    
    # 设置文档默认字体
    doc.styles['Normal'].font.name = 'Times New Roman'
    doc.styles['Normal'].font.size = Pt(12)
    
    return doc

def force_font_style(run, font_name='Times New Roman', font_size=12, bold=False, italic=False):
    """强制设置字体样式"""
    # 设置基本属性
    run.font.name = font_name
    run.font.size = Pt(font_size)
    run.bold = bold
    run.italic = italic
    
    # 获取或创建 rPr 元素
    rPr = run._element.get_or_add_rPr()
    
    # 清除现有字体设置
    for rFonts in rPr.xpath('.//w:rFonts'):
        rPr.remove(rFonts)
    
    # 强制设置字体
    rFonts = OxmlElement('w:rFonts')
    rFonts.set(qn('w:ascii'), font_name)
    rFonts.set(qn('w:hAnsi'), font_name)
    rFonts.set(qn('w:cs'), font_name)
    rFonts.set(qn('w:eastAsia'), font_name)
    rPr.insert(0, rFonts)
    
    # 强制设置字体大小
    for sz in rPr.xpath('.//w:sz'):
        rPr.remove(sz)
    for szCs in rPr.xpath('.//w:szCs'):
        rPr.remove(szCs)
    
    sz = OxmlElement('w:sz')
    sz.set(qn('w:val'), str(font_size * 2))  # Word 使用半点
    rPr.append(sz)
    
    szCs = OxmlElement('w:szCs')
    szCs.set(qn('w:val'), str(font_size * 2))
    rPr.append(szCs)

def add_text_with_style(paragraph, text, bold=False, italic=False, font_size=12):
    """添加带样式的文本"""
    run = paragraph.add_run(text)
    force_font_style(run, 'Times New Roman', font_size, bold, italic)
    return run

def preprocess_formula(formula_text):
    """预处理公式文本，处理复杂表达式"""
    formula = formula_text.strip()
    
    # 处理常见的数学函数
    function_replacements = {
        r'\\ln\b': 'ln',
        r'\\log\b': 'log',
        r'\\sin\b': 'sin',
        r'\\cos\b': 'cos',
        r'\\tan\b': 'tan',
        r'\\exp\b': 'exp',
        r'\\max\b': 'max',
        r'\\min\b': 'min',
        r'\\lim\b': 'lim',
    }
    
    for pattern, replacement in function_replacements.items():
        formula = re.sub(pattern, replacement, formula)
    
    return formula

def create_enhanced_math_element(formula_text):
    """创建增强的 Word 数学公式元素"""
    formula = preprocess_formula(formula_text)
    
    # 基本符号替换
    symbol_replacements = {
        r'\\alpha': 'α',
        r'\\beta': 'β', 
        r'\\gamma': 'γ',
        r'\\delta': 'δ',
        r'\\epsilon': 'ε',
        r'\\theta': 'θ',
        r'\\lambda': 'λ',
        r'\\mu': 'μ',
        r'\\pi': 'π',
        r'\\sigma': 'σ',
        r'\\phi': 'φ',
        r'\\omega': 'ω',
        r'\\infty': '∞',
        r'\\sum': 'Σ',
        r'\\int': '∫',
        r'\\to': '→',
        r'\\leq': '≤',
        r'\\geq': '≥',
        r'\\neq': '≠',
        r'\\approx': '≈',
        r'\\cdot': '·',
        r'\\times': '×',
        r'\\div': '÷',
        r'\\pm': '±'
    }
    
    for pattern, replacement in symbol_replacements.items():
        formula = re.sub(pattern, replacement, formula)
    
    # 构建 OMML 数学公式
    math_parts = []
    
    # 处理分数 \frac{a}{b}
    def process_fraction(match):
        numerator = match.group(1)
        denominator = match.group(2)
        return f'<m:f><m:num><m:r><m:t>{numerator}</m:t></m:r></m:num><m:den><m:r><m:t>{denominator}</m:t></m:r></m:den></m:f>'
    
    formula = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', process_fraction, formula)
    
    # 处理平方根 \sqrt{...}
    def process_sqrt(match):
        content = match.group(1)
        return f'<m:rad><m:radPr><m:degHide m:val="1"/></m:radPr><m:deg></m:deg><m:e><m:r><m:t>{content}</m:t></m:r></m:e></m:rad>'
    
    formula = re.sub(r'\\sqrt\{([^}]+)\}', process_sqrt, formula)
    
    # 处理上标 ^{...} 或 ^x (包括指数)
    def process_superscript(match):
        base_text = match.group(1) if match.group(1) else ''
        sup_text = match.group(2)
        if sup_text.startswith('{') and sup_text.endswith('}'):
            sup_text = sup_text[1:-1]
        
        if base_text:
            return f'<m:sSup><m:e><m:r><m:t>{base_text}</m:t></m:r></m:e><m:sup><m:r><m:t>{sup_text}</m:t></m:r></m:sup></m:sSup>'
        else:
            return f'<m:sSup><m:e><m:r><m:t></m:t></m:r></m:e><m:sup><m:r><m:t>{sup_text}</m:t></m:r></m:sup></m:sSup>'
    
    # 匹配 word^{exp} 或 word^x 格式
    formula = re.sub(r'(\w+)\^(\{[^}]+\}|\w+)', process_superscript, formula)
    # 匹配单独的 ^{exp} 或 ^x
    formula = re.sub(r'(?<!\w)\^(\{[^}]+\}|\w+)', lambda m: process_superscript(type('obj', (object,), {'group': lambda x: '' if x == 1 else m.group(1)})()), formula)
    
    # 处理下标 _{...} 或 _x
    def process_subscript(match):
        base_text = match.group(1) if match.group(1) else ''
        sub_text = match.group(2)
        if sub_text.startswith('{') and sub_text.endswith('}'):
            sub_text = sub_text[1:-1]
        
        if base_text:
            return f'<m:sSub><m:e><m:r><m:t>{base_text}</m:t></m:r></m:e><m:sub><m:r><m:t>{sub_text}</m:t></m:r></m:sub></m:sSub>'
        else:
            return f'<m:sSub><m:e><m:r><m:t></m:t></m:r></m:e><m:sub><m:r><m:t>{sub_text}</m:t></m:r></m:sub></m:sSub>'
    
    # 匹配 word_{sub} 或 word_x 格式
    formula = re.sub(r'(\w+)_(\{[^}]+\}|\w+)', process_subscript, formula)
    # 匹配单独的 _{sub} 或 _x
    formula = re.sub(r'(?<!\w)_(\{[^}]+\}|\w+)', lambda m: process_subscript(type('obj', (object,), {'group': lambda x: '' if x == 1 else m.group(1)})()), formula)
    
    # 处理函数调用，如 ln(x), log(x), sin(x) 等
    def process_function(match):
        func_name = match.group(1)
        arg = match.group(2)
        return f'<m:func><m:funcPr></m:funcPr><m:fName><m:r><m:t>{func_name}</m:t></m:r></m:fName><m:e><m:r><m:t>{arg}</m:t></m:r></m:e></m:func>'
    
    # 匹配函数调用模式
    formula = re.sub(r'\b(ln|log|sin|cos|tan|exp|max|min)\s*\(([^)]+)\)', process_function, formula)
    
    # 创建完整的 OMML 数学公式
    omml_template = f'''
    <m:oMath {nsdecls('m')}>
        <m:r>
            <m:rPr>
                <m:sty m:val="p"/>
            </m:rPr>
            <m:t>{formula}</m:t>
        </m:r>
    </m:oMath>
    '''
    
    try:
        return parse_xml(omml_template)
    except Exception as e:
        print(f"⚠️  OMML 解析失败: {e}")
        return None

def add_enhanced_math_formula(paragraph, formula_text):
    """添加增强的数学公式到段落"""
    try:
        # 尝试创建 OMML 数学公式
        math_element = create_enhanced_math_element(formula_text)
        
        if math_element is not None:
            # 插入 OMML 数学公式
            paragraph._element.append(math_element)
            return True
        else:
            raise Exception("OMML creation failed")
            
    except Exception as e:
        print(f"⚠️  OMML 公式创建失败，使用增强文本替代: {e}")
        
        # 增强的文本公式处理
        formula = preprocess_formula(formula_text)
        
        # 高级符号和表达式替换
        enhanced_replacements = {
            # 分数
            r'\\frac\{([^}]+)\}\{([^}]+)\}': r'(\1)/(\2)',
            # 根号
            r'\\sqrt\{([^}]+)\}': r'√(\1)',
            # 极限
            r'\\lim_\{([^}]+)\}': r'lim[(\1)]',
            # 求和
            r'\\sum_\{([^}]+)\}\^\{([^}]+)\}': r'Σ[(\1) to (\2)]',
            r'\\sum_\{([^}]+)\}': r'Σ[(\1)]',
            r'\\sum': r'Σ',
            # 积分
            r'\\int_\{([^}]+)\}\^\{([^}]+)\}': r'∫[(\1) to (\2)]',
            r'\\int_\{([^}]+)\}': r'∫[(\1)]',
            r'\\int': r'∫',
            # 指数和对数函数
            r'\b(ln|log|sin|cos|tan|exp|max|min)\s*\(([^)]+)\)': r'\1(\2)',
            # 上标和下标
            r'(\w+)\^(\{[^}]+\}|\w+)': lambda m: f"{m.group(1)}^{m.group(2).strip('{}')}" if m.group(2) else m.group(0),
            r'(\w+)_(\{[^}]+\}|\w+)': lambda m: f"{m.group(1)}_{m.group(2).strip('{}')}" if m.group(2) else m.group(0),
            # 单独的上标下标
            r'(?<!\w)\^(\{[^}]+\}|\w+)': lambda m: f"^{m.group(1).strip('{}')}",
            r'(?<!\w)_(\{[^}]+\}|\w+)': lambda m: f"_{m.group(1).strip('{}')}",
            # 基本符号
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
            r'\\pm': r'±'
        }
        
        for pattern, replacement in enhanced_replacements.items():
            if callable(replacement):
                formula = re.sub(pattern, replacement, formula)
            else:
                formula = re.sub(pattern, replacement, formula)
        
        # 使用 Cambria Math 字体
        run = paragraph.add_run(formula)
        run.font.name = 'Cambria Math'
        run.font.size = Pt(12)
        run.italic = True
        
        return False

def load_image_index():
    """加载图片索引"""
    index_file = BASE_DIR / "图片提取报告.json"
    if index_file.exists():
        with open(index_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def get_image_for_figure(fig_num):
    """根据图号获取对应的图片文件"""
    pattern = f"{fig_num}_*.png"
    matches = list(IMAGES_DIR.glob(pattern))
    if matches:
        return matches[0]
    return None

def add_heading_with_style(doc, text, level=1):
    """添加带样式的标题"""
    heading = doc.add_heading('', level=level)
    
    # 清空默认内容
    heading.clear()
    
    # 设置字体大小
    font_sizes = {1: 18, 2: 16, 3: 14, 4: 12}
    font_size = font_sizes.get(level, 12)
    
    # 添加文本
    add_text_with_style(heading, text, bold=True, font_size=font_size)
    
    return heading

def process_text_line(paragraph, text):
    """处理包含格式化的文本行"""
    if '**' in text:
        # 处理粗体
        parts = re.split(r'(\*\*[^*]+\*\*)', text)
        for part in parts:
            if part.startswith('**') and part.endswith('**'):
                add_text_with_style(paragraph, part[2:-2], bold=True)
            else:
                if part.strip():
                    add_text_with_style(paragraph, part)
    else:
        add_text_with_style(paragraph, text)

def process_chapter(content, doc, chapter_num):
    """处理单个章节"""
    lines = content.split('\n')
    i = 0
    omml_success_count = 0
    omml_fail_count = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # 处理标题
        if line.startswith('#'):
            level = len(line) - len(line.lstrip('#'))
            title_text = line.lstrip('#').strip()
            
            if level <= 4:
                add_heading_with_style(doc, title_text, level)
            else:
                p = doc.add_paragraph()
                add_text_with_style(p, title_text, bold=True)
        
        # 处理图片标题
        elif line.startswith('**图') and line.endswith('**'):
            match = re.search(r'\*\*图(\d+\.\d+)\s*(.*?)\*\*', line)
            if match:
                fig_num = match.group(1)
                fig_title = match.group(2).strip()
                
                print(f"处理图片: 图{fig_num} {fig_title}")
                
                image_path = get_image_for_figure(fig_num)
                
                if image_path and image_path.exists():
                    try:
                        # 添加图片
                        doc.add_picture(str(image_path), width=Inches(5.5))
                        
                        # 添加图片标题
                        caption_p = doc.add_paragraph()
                        caption_p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        add_text_with_style(caption_p, f"图{fig_num} {fig_title}", bold=True)
                        
                        print(f"✅ 成功插入图片: {image_path.name}")
                        
                    except Exception as e:
                        print(f"❌ 插入图片失败: {e}")
                        p = doc.add_paragraph()
                        p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                        add_text_with_style(p, f"[图片占位符: 图{fig_num} {fig_title}]")
                else:
                    print(f"❌ 未找到图片文件: 图{fig_num}")
                    p = doc.add_paragraph()
                    p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                    add_text_with_style(p, f"[图片缺失: 图{fig_num} {fig_title}]")
        
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
                force_font_style(run, 'Consolas', 10)
            
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
                        success = add_enhanced_math_formula(p, part)
                        if success:
                            omml_success_count += 1
                        else:
                            omml_fail_count += 1
                    else:  # 偶数索引是普通文本
                        if part.strip():
                            process_text_line(p, part)
            
            # 处理块级公式 $$...$$
            elif line.startswith('$$') and line.endswith('$$'):
                formula = line[2:-2].strip()
                p = doc.add_paragraph()
                p.alignment = WD_PARAGRAPH_ALIGNMENT.CENTER
                success = add_enhanced_math_formula(p, formula)
                if success:
                    omml_success_count += 1
                else:
                    omml_fail_count += 1
            
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
                success = add_enhanced_math_formula(p, formula)
                if success:
                    omml_success_count += 1
                else:
                    omml_fail_count += 1
                i = j
            
            # 普通段落
            else:
                p = doc.add_paragraph()
                process_text_line(p, line)
        
        i += 1
    
    print(f"📊 章节 {chapter_num} 增强公式统计:")
    print(f"   - OMML 成功: {omml_success_count}")
    print(f"   - 增强文本: {omml_fail_count}")

def main():
    """主函数"""
    print("🚀 增强数学公式处理的 Word 文档构建器")
    print("📝 特性：指数、对数、复杂表达式优化")
    
    # 创建基础模板
    doc = create_base_template()
    
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
    
    total_omml_success = 0
    total_omml_fail = 0
    
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
        process_chapter(content, doc, chapter_num)
        
        # 在章节之间添加分页符（除了最后一章）
        if chapter_num < 7:
            doc.add_page_break()
    
    # 保存文档
    output_path = BASE_DIR / "enhanced_math_thesis.docx"
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
        
        print("🎯 增强数学公式特性:")
        print("   - ✅ 指数表达式优化 (^{...}, ^x)")
        print("   - ✅ 对数函数优化 (ln, log)")
        print("   - ✅ 三角函数优化 (sin, cos, tan)")
        print("   - ✅ 复杂分数和根号")
        print("   - ✅ 函数调用格式")
        print("   - ✅ 增强文本回退")
        
    except Exception as e:
        print(f"❌ 验证失败: {e}")

if __name__ == "__main__":
    main()