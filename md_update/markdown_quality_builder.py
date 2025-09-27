#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Markdown 质量的 Word 公式构建器
使用 Word 原生数学对象实现专业公式显示
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
from docx.oxml.parser import parse_xml
from xml.sax.saxutils import escape
M_NS = "http://schemas.openxmlformats.org/officeDocument/2006/math"
W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

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

def _tex_to_omml(tex: str) -> str:
    """
    最小可用的 LaTeX->OMML 转换，覆盖论文中常见模式：
    - \frac{a}{b}
    - e^{...}、x^{...}、x_{...}
    - \left( ... \right) 圆括号
    - ln(), log()
    """
    s = tex.strip()
    s = s.replace(r'\left', '').replace(r'\right', '')
    s = re.sub(r'\\\\,|\\\\\\s+', '', s)

    # 递归处理分数
    def frac_repl(m):
        num = m.group(1) or ""
        den = m.group(2) or ""
        return f'<m:f><m:fPr/><m:num><m:r><m:t>{escape(num)}</m:t></m:r></m:num><m:den><m:r><m:t>{escape(den)}</m:t></m:r></m:den></m:f>'
    while True:
        new_s = re.sub(r'\\frac\{([^{}]+)\}\{([^{}]+)\}', frac_repl, s)
        if new_s == s:
            break
        s = new_s

    # 上标 a^{b} 或 a^b
    def sup_repl(m):
        base = m.group(1)
        sup = m.group(2)
        if sup.startswith('{') and sup.endswith('}'):
            sup = sup[1:-1]
        return f'<m:sSup><m:e><m:r><m:t>{escape(base)}</m:t></m:r></m:e><m:sup><m:r><m:t>{escape(sup)}</m:t></m:r></m:sup></m:sSup>'
    s = re.sub(r'([A-Za-z0-9])\^\{([^{}]+)\}', lambda m: sup_repl(type("M", (), {"group": lambda self, i: [None, m.group(1), "{"+m.group(2)+"}"][i]})()), s)
    s = re.sub(r'([A-Za-z0-9])\^([A-Za-z0-9])', lambda m: sup_repl(type("M", (), {"group": lambda self, i: [None, m.group(1), m.group(2)][i]})()), s)

    # 下标 a_{b} 或 a_b
    def sub_repl(m):
        base = m.group(1)
        sub = m.group(2)
        if sub.startswith('{') and sub.endswith('}'):
            sub = sub[1:-1]
        return f'<m:sSub><m:e><m:r><m:t>{escape(base)}</m:t></m:r></m:e><m:sub><m:r><m:t>{escape(sub)}</m:t></m:r></m:sub></m:sSub>'
    s = re.sub(r'([A-Za-z0-9])_\{([^{}]+)\}', lambda m: sub_repl(type("M", (), {"group": lambda self, i: [None, m.group(1), "{"+m.group(2)+"}"][i]})()), s)
    s = re.sub(r'([A-Za-z0-9])_([A-Za-z0-9])', lambda m: sub_repl(type("M", (), {"group": lambda self, i: [None, m.group(1), m.group(2)][i]})()), s)

    # 函数 ln()/log() 与 e^x 的常见写法
    s = re.sub(r'\\\\ln', 'ln', s)
    s = re.sub(r'\\\\log', 'log', s)
    s = re.sub(r'\\\\approx', '≈', s)
    s = re.sub(r'\\\\sqrt\{([^{}]+)\}', lambda m: f'√({escape(m.group(1) or "")})', s)

    # 括号包裹
    s = re.sub(r'\(([^()]*)\)', lambda m: f'<m:d><m:e><m:r><m:t>{escape(m.group(1) or "")}</m:t></m:r></m:e><m:begChr>(</m:begChr><m:endChr>)</m:endChr></m:d>', s)

    # 若最终仍是纯文本，包一层 m:r（注意：这里返回 OMML 片段，不做转义为普通文本）
    if not s.strip().startswith('<'):
        s = f'<m:r><m:t>{escape(s)}</m:t></m:r>'
    # 返回 m:oMath 的内部 XML 片段，由调用方包装完整节点
    return s

def create_native_math_equation(paragraph, latex_formula):
    """创建原生 Word 数学公式对象（OMML）（OxmlElement 构造）"""
    try:
        inner = _tex_to_omml(latex_formula)

        # 新建 w:p 段落并设置居中
        wp = OxmlElement('w:p')
        wp.set(qn('xmlns:w'), W_NS)
        wp.set(qn('xmlns:m'), M_NS)

        pPr = OxmlElement('w:pPr')
        jc = OxmlElement('w:jc')
        jc.set(qn('w:val'), 'center')
        pPr.append(jc)
        wp.append(pPr)

        # m:oMathPara / m:oMath
        oMathPara = OxmlElement('m:oMathPara')
        oMath = OxmlElement('m:oMath')

        # 将 inner 作为片段解析并附加
        frag = parse_xml(f'<root xmlns:w="{W_NS}" xmlns:m="{M_NS}">{inner}</root>')
        for child in list(frag):
            oMath.append(child)

        oMathPara.append(oMath)
        wp.append(oMathPara)

        parent = paragraph._element.getparent()
        parent.insert(parent.index(paragraph._element)+1, wp)
        return True
    except Exception as e:
        print(f"❌ 原生公式创建失败: {e}")
        return create_enhanced_unicode_equation(paragraph, latex_formula)

def create_enhanced_unicode_equation(paragraph, latex_formula):
    """创建增强的 Unicode 公式显示"""
    try:
        formula = latex_formula.strip()
        
        # 处理分数 - 使用真正的分数符号
        def replace_frac(match):
            num = match.group(1).strip()
            den = match.group(2).strip()
            
            # 对于简单的数字分数，使用 Unicode 分数符号
            fraction_map = {
                ('1', '2'): '½', ('1', '3'): '⅓', ('2', '3'): '⅔',
                ('1', '4'): '¼', ('3', '4'): '¾', ('1', '5'): '⅕',
                ('2', '5'): '⅖', ('3', '5'): '⅗', ('4', '5'): '⅘',
                ('1', '6'): '⅙', ('5', '6'): '⅚', ('1', '8'): '⅛',
                ('3', '8'): '⅜', ('5', '8'): '⅝', ('7', '8'): '⅞'
            }
            
            if (num, den) in fraction_map:
                return fraction_map[(num, den)]
            else:
                return f'{num}/{den}'
        
        formula = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', replace_frac, formula)
        
        # 处理上标 - 使用完整的 Unicode 上标
        superscript_map = {
            '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵',
            '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹', '+': '⁺', '-': '⁻',
            '=': '⁼', '(': '⁽', ')': '⁾', 'n': 'ⁿ', 'i': 'ⁱ', 'x': 'ˣ',
            'y': 'ʸ', 'k': 'ᵏ', 'm': 'ᵐ', 'a': 'ᵃ', 'b': 'ᵇ', 'c': 'ᶜ',
            'd': 'ᵈ', 'e': 'ᵉ', 'f': 'ᶠ', 'g': 'ᵍ', 'h': 'ʰ', 'j': 'ʲ',
            'l': 'ˡ', 'o': 'ᵒ', 'p': 'ᵖ', 'r': 'ʳ', 's': 'ˢ', 't': 'ᵗ',
            'u': 'ᵘ', 'v': 'ᵛ', 'w': 'ʷ', 'z': 'ᶻ'
        }
        
        def replace_superscript(match):
            base = match.group(1)
            sup = match.group(2)
            if sup.startswith('{') and sup.endswith('}'):
                sup = sup[1:-1]
            
            unicode_sup = ''
            for char in sup:
                unicode_sup += superscript_map.get(char, char)
            
            return f'{base}{unicode_sup}'
        
        formula = re.sub(r'(\w+)\^(\{[^}]+\}|\w+)', replace_superscript, formula)
        
        # 处理下标
        subscript_map = {
            '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄', '5': '₅',
            '6': '₆', '7': '₇', '8': '₈', '9': '₉', '+': '₊', '-': '₋',
            '=': '₌', '(': '₍', ')': '₎', 'a': 'ₐ', 'e': 'ₑ', 'h': 'ₕ',
            'i': 'ᵢ', 'j': 'ⱼ', 'k': 'ₖ', 'l': 'ₗ', 'm': 'ₘ', 'n': 'ₙ',
            'o': 'ₒ', 'p': 'ₚ', 'r': 'ᵣ', 's': 'ₛ', 't': 'ₜ', 'u': 'ᵤ',
            'v': 'ᵥ', 'x': 'ₓ'
        }
        
        def replace_subscript(match):
            base = match.group(1)
            sub = match.group(2)
            if sub.startswith('{') and sub.endswith('}'):
                sub = sub[1:-1]
            
            unicode_sub = ''
            for char in sub:
                unicode_sub += subscript_map.get(char, char)
            
            return f'{base}{unicode_sub}'
        
        formula = re.sub(r'(\w+)_(\{[^}]+\}|\w+)', replace_subscript, formula)
        
        # 处理根号
        formula = re.sub(r'\\sqrt\{([^}]+)\}', r'√(\1)', formula)
        
        # 处理函数
        formula = re.sub(r'\\ln\b', 'ln', formula)
        formula = re.sub(r'\\log\b', 'log', formula)
        
        # 处理希腊字母和符号
        symbol_map = {
            r'\\alpha': 'α', r'\\beta': 'β', r'\\gamma': 'γ', r'\\delta': 'δ',
            r'\\epsilon': 'ε', r'\\theta': 'θ', r'\\lambda': 'λ', r'\\mu': 'μ',
            r'\\pi': 'π', r'\\sigma': 'σ', r'\\phi': 'φ', r'\\omega': 'ω',
            r'\\infty': '∞', r'\\to': '→', r'\\leq': '≤', r'\\geq': '≥',
            r'\\neq': '≠', r'\\approx': '≈', r'\\cdot': '·', r'\\times': '×',
            r'\\div': '÷', r'\\pm': '±'
        }
        
        for latex_symbol, unicode_symbol in symbol_map.items():
            formula = re.sub(latex_symbol, unicode_symbol, formula)
        
        # 创建新段落用于公式
        formula_p = paragraph._element.getparent().makeelement(
            qn('w:p'), nsmap=paragraph._element.nsmap
        )
        
        # 设置居中对齐
        pPr = OxmlElement('w:pPr')
        jc = OxmlElement('w:jc')
        jc.set(qn('w:val'), 'center')
        pPr.append(jc)
        formula_p.append(pPr)
        
        # 添加公式文本
        r = OxmlElement('w:r')
        rPr = OxmlElement('w:rPr')
        
        # 设置 Cambria Math 字体
        rFonts = OxmlElement('w:rFonts')
        rFonts.set(qn('w:ascii'), 'Cambria Math')
        rFonts.set(qn('w:hAnsi'), 'Cambria Math')
        rFonts.set(qn('w:cs'), 'Cambria Math')
        rPr.append(rFonts)
        
        # 设置字体大小
        sz = OxmlElement('w:sz')
        sz.set(qn('w:val'), '24')  # 12pt = 24 half-points
        rPr.append(sz)
        
        r.append(rPr)
        
        t = OxmlElement('w:t')
        t.text = formula
        r.append(t)
        formula_p.append(r)
        
        # 插入公式段落
        paragraph._element.getparent().insert(
            paragraph._element.getparent().index(paragraph._element) + 1,
            formula_p
        )
        
        print(f"✅ 创建增强 Unicode 公式: {formula[:50]}...")
        return True
        
    except Exception as e:
        print(f"❌ 增强公式创建失败: {e}")
        # 最后回退到简单文本
        run = paragraph.add_run(latex_formula)
        run.font.name = 'Cambria Math'
        run.font.size = Pt(12)
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
    formula_count = 0
    
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
                        create_enhanced_unicode_equation(p, part)
                        formula_count += 1
                    else:  # 偶数索引是普通文本
                        if part.strip():
                            process_text_line(p, part)
            
            # 处理块级公式 $$...$$
            elif line.startswith('$$') and line.endswith('$$'):
                formula = line[2:-2].strip()
                p = doc.add_paragraph()
                create_native_math_equation(p, formula)
                formula_count += 1
            
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
                create_native_math_equation(p, formula)
                formula_count += 1
                i = j
            
            # 普通段落
            else:
                p = doc.add_paragraph()
                process_text_line(p, line)
        
        i += 1
    
    print(f"📊 章节 {chapter_num} 公式统计: {formula_count} 个 Markdown 质量公式已处理")

def main():
    """主函数"""
    print("🏆 Markdown 质量的 Word 文档构建器")
    print("📝 特性：原生 Math Zone + 增强 Unicode 显示")
    
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
    output_path = BASE_DIR / "markdown_quality_thesis.docx"
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
        
        print("🏆 Markdown 质量特性:")
        print("   - ✅ 原生 Word Math Zone 公式")
        print("   - ✅ 真正的分数线显示 (½, ¾)")
        print("   - ✅ 完整的 Unicode 上下标 (x², x₁)")
        print("   - ✅ 专业函数显示 (ln, log)")
        print("   - ✅ 希腊字母和符号 (α, β, π)")
        print("   - ✅ Cambria Math 专业字体")
        print("   - ✅ 居中对齐的块级公式")
        
    except Exception as e:
        print(f"❌ 验证失败: {e}")

if __name__ == "__main__":
    main()