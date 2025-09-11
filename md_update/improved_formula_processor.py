#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
公式处理模块
结合原生公式对象和 Unicode 显示
"""

import re
from docx.oxml import parse_xml
from .improved_font_manager import force_font_style

def create_math_equation(paragraph, latex_formula):
    """创建数学公式 - 改进版本，结合两种方法"""
    try:
        # 方法1：尝试使用 Word 原生公式对象
        math_xml = f"""
        <m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
            <m:r>
                <m:t>{latex_formula}</m:t>
            </m:r>
        </m:oMath>
        """
        
        # 创建数学元素
        math_element = parse_xml(math_xml)
        paragraph._element.append(math_element)
        
        print(f"✅ 使用原生公式对象: {latex_formula[:50]}...")
        return True
        
    except Exception as e:
        print(f"⚠️  原生公式失败，使用 Unicode 替代: {e}")
        
        # 方法2：使用 Unicode 符号替代
        formula = process_unicode_formula(latex_formula)
        
        # 使用 Cambria Math 字体显示
        run = paragraph.add_run(formula)
        force_font_style(run, 'Cambria Math', 12, False, False)
        
        return False

def process_unicode_formula(latex_formula):
    """处理 Unicode 公式转换"""
    formula = latex_formula.strip()
    
    # 符号映射
    superscript_map = {
        '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
        '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹',
        '+': '⁺', '-': '⁻', '=': '⁼', '(': '⁽', ')': '⁾',
        'n': 'ⁿ', 'i': 'ⁱ', 'x': 'ˣ', 'y': 'ʸ', 'k': 'ᵏ', 'm': 'ᵐ'
    }
    subscript_map = {
        '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
        '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
        '+': '₊', '-': '₋', '=': '₌', '(': '₍', ')': '₎',
        'a': 'ₐ', 'e': 'ₑ', 'h': 'ₕ', 'i': 'ᵢ', 'j': 'ⱼ',
        'k': 'ₖ', 'l': 'ₗ', 'm': 'ₘ', 'n': 'ₙ', 'o': 'ₒ',
        'p': 'ₚ', 'r': 'ᵣ', 's': 'ₛ', 't': 'ₜ', 'u': 'ᵤ',
        'v': 'ᵥ', 'x': 'ₓ'
    }
    symbol_map = {
        r'\\alpha': 'α', r'\\beta': 'β', r'\\gamma': 'γ', r'\\delta': 'δ',
        r'\\epsilon': 'ε', r'\\theta': 'θ', r'\\lambda': 'λ', r'\\mu': 'μ',
        r'\\pi': 'π', r'\\sigma': 'σ', r'\\phi': 'φ', r'\\omega': 'ω',
        r'\\infty': '∞', r'\\to': '→', r'\\leq': '≤', r'\\geq': '≥',
        r'\\neq': '≠', r'\\approx': '≈', r'\\cdot': '·', r'\\times': '×',
        r'\\div': '÷', r'\\pm': '±'
    }
    
    def can_be_unicode(text, conversion_map):
        return all(char in conversion_map for char in text)

    def to_unicode(text, conversion_map):
        return "".join(conversion_map.get(char, char) for char in text)

    def replace_superscript(match):
        base, sup = match.groups()
        if sup.startswith('{') and sup.endswith('}'):
            sup = sup[1:-1]
        
        if can_be_unicode(sup, superscript_map):
            return f'{base}{to_unicode(sup, superscript_map)}'
        else:
            return f'{base}^{sup}'

    def replace_subscript(match):
        base, sub = match.groups()
        if sub.startswith('{') and sub.endswith('}'):
            sub = sub[1:-1]
        
        if sub in ['opt', 'min', 'max'] or not can_be_unicode(sub, subscript_map):
            return f'{base}_{sub}'
        else:
            return f'{base}{to_unicode(sub, subscript_map)}'
    
    # 处理公式
    previous_formula = ""
    while formula != previous_formula:
        previous_formula = formula
        
        # 移除 \left 和 \right
        formula = formula.replace('\\left', '').replace('\\right', '')
        
        # 处理函数
        formula = re.sub(r'\\ln\b', 'ln', formula)
        formula = re.sub(r'\\log\b', 'log', formula)
        
        # 处理分数
        formula = re.sub(r'\\frac\{d\}\{d([a-zA-Z])\}', r'd/d\1', formula)
        formula = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1)/(\2)', formula)
        
        # 处理上下标
        formula = re.sub(r'(\w+|\([^)]+\))\^(\{[^}]+\}|[^{}\s^]+)', replace_superscript, formula)
        formula = re.sub(r'(\w+|\([^)]+\))_(\{[^}]+\}|[^{}\s_]+)', replace_subscript, formula)
        
        # 处理根号
        formula = re.sub(r'\\sqrt\{([^}]+)\}', r'√(\1)', formula)
        
        # 处理符号
        for latex_symbol, unicode_symbol in symbol_map.items():
            formula = re.sub(latex_symbol, unicode_symbol, formula)
    
    return formula