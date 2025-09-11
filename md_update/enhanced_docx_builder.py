#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
增强版 DOCX 构建器：
1) 确保 mermaid 图片正确嵌入
2) 修复公式显示问题
3) 添加调试输出
"""

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"
BUILD_MD_DIR = BASE_DIR / "_enhanced_build_md"
DOCX_OUT_DIR = BASE_DIR / "_enhanced_docx_out"
MERGED_DOCX = BASE_DIR / "enhanced_merged_thesis.docx"

CHAPTERS = [
    "第一章-绪论.md",
    "第二章-相关背景与理论基础.md", 
    "第三章-动态缓存管理.md",
    "第四章-动态缓存更新技术与持久化技术.md",
    "第五章-实验与分析.md",
    "第六章-总结与展望.md",
]
REF_MD = "统一参考文献列表.md"

def run_cmd(cmd, cwd=None):
    print(f"+ {' '.join(str(x) for x in cmd)}")
    cp = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                       text=True, cwd=cwd or BASE_DIR)
    if cp.returncode != 0:
        print(f"[ERROR] {cp.stderr.strip()}")
        sys.exit(cp.returncode)
    if cp.stdout.strip():
        print(cp.stdout.strip())
    return cp

def ensure_images():
    """确保图片已生成"""
    if not IMAGES_DIR.exists() or len(list(IMAGES_DIR.glob("*.png"))) == 0:
        script = BASE_DIR / "extract_all_images.py"
        if script.exists():
            print("生成图片...")
            run_cmd(["python3", str(script)])
        else:
            print("[WARN] 未找到图片生成脚本")

def get_chapter_images(chapter_num):
    """获取指定章节的图片列表"""
    if not IMAGES_DIR.exists():
        return []
    
    images = []
    for img in IMAGES_DIR.glob("*.png"):
        # 匹配格式：1.1_xxx.png, 1.2_xxx.png 等
        if img.name.startswith(f"{chapter_num}.") and not img.name.startswith("mermaid_"):
            images.append(img)
    
    return sorted(images, key=lambda x: x.name)

def replace_mermaid_with_images(md_text, chapter_num):
    """替换 mermaid 代码块为图片引用"""
    # 获取该章节的图片
    chapter_images = get_chapter_images(chapter_num)
    
    # 查找所有 mermaid 代码块
    mermaid_pattern = r"```mermaid[^\n]*\n([\s\S]*?)```"
    blocks = list(re.finditer(mermaid_pattern, md_text))
    
    if not blocks:
        return md_text, 0
    
    print(f"  找到 {len(blocks)} 个 mermaid 块，可用图片 {len(chapter_images)} 个")
    
    # 从后往前替换，避免位置偏移
    replaced = 0
    for i, block in enumerate(reversed(blocks)):
        img_idx = len(blocks) - 1 - i
        if img_idx < len(chapter_images):
            img_path = chapter_images[img_idx]
            # 使用绝对路径确保 pandoc 能找到
            abs_img_path = str(img_path.absolute())
            replacement = f"![图片]({abs_img_path})\n"
            md_text = md_text[:block.start()] + replacement + md_text[block.end():]
            replaced += 1
            print(f"    替换 mermaid 块 -> {img_path.name}")
        else:
            print(f"    跳过 mermaid 块（无对应图片）")
    
    return md_text, replaced

def fix_math_formulas(md_text):
    """修复数学公式格式"""
    # 移除被反引号包裹的公式
    md_text = re.sub(r"`(\$[^`$]+\$)`", r"\1", md_text)
    
    # 确保行间公式独占一行
    md_text = re.sub(r"([^$])\$\$([^$]+)\$\$([^$])", r"\1\n\n$$\2$$\n\n\3", md_text)
    
    # 修复常见的公式问题
    # 将 \frac{a}{b} 确保正确格式
    md_text = re.sub(r"\\frac\s*\{\s*([^}]+)\s*\}\s*\{\s*([^}]+)\s*\}", r"\\frac{\1}{\2}", md_text)
    
    return md_text

def preprocess_markdown(md_path):
    """预处理单个 Markdown 文件"""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 提取章节号 - 修复正则表达式
    chapter_match = re.search(r"第([一二三四五六七八九十\d]+)章", md_path.name)
    if chapter_match:
        chapter_text = chapter_match.group(1)
        # 转换中文数字为阿拉伯数字
        chinese_to_num = {'一': '1', '二': '2', '三': '3', '四': '4', '五': '5', '六': '6'}
        chapter_num = chinese_to_num.get(chapter_text, chapter_text)
    else:
        chapter_num = "0"
    
    print(f"预处理章节 {chapter_num}: {md_path.name}")
    
    # 替换 mermaid
    content, mermaid_count = replace_mermaid_with_images(content, chapter_num)
    
    # 修复公式
    content = fix_math_formulas(content)
    
    return content, mermaid_count

def convert_to_docx(md_path, docx_path):
    """使用 pandoc 转换为 DOCX"""
    cmd = [
        "pandoc",
        str(md_path),
        "-o", str(docx_path),
        "--standalone",
        "--from", "markdown+tex_math_dollars",
        "--to", "docx",
        "--mathml",  # 使用 MathML 而不是 OMML
    ]
    
    run_cmd(cmd)

def merge_docx_files(docx_files, output_path):
    """合并多个 DOCX 文件"""
    try:
        from docx import Document
        from docx.enum.text import WD_BREAK
    except ImportError:
        print("[ERROR] 需要安装 python-docx: pip install python-docx")
        sys.exit(1)
    
    merged = Document()
    
    for i, docx_path in enumerate(docx_files):
        if not docx_path.exists():
            print(f"[WARN] 跳过缺失文件: {docx_path}")
            continue
        
        try:
            doc = Document(str(docx_path))
        except Exception as e:
            print(f"[WARN] 无法打开文件 {docx_path}: {e}")
            continue
        
        # 添加分页符（除了第一个文档）
        if i > 0:
            merged.add_paragraph().add_run().add_break(WD_BREAK.PAGE)
        
        # 复制内容
        for element in doc.element.body:
            merged.element.body.append(element)
    
    merged.save(str(output_path))
    print(f"合并完成: {output_path}")

def main():
    print(f"工作目录: {BASE_DIR}")
    
    # 确保图片存在
    ensure_images()
    
    # 清理并创建构建目录
    if BUILD_MD_DIR.exists():
        shutil.rmtree(BUILD_MD_DIR)
    BUILD_MD_DIR.mkdir(exist_ok=True)
    
    if DOCX_OUT_DIR.exists():
        shutil.rmtree(DOCX_OUT_DIR)
    DOCX_OUT_DIR.mkdir(exist_ok=True)
    
    docx_files = []
    
    # 处理所有章节
    all_files = CHAPTERS + [REF_MD]
    
    for md_name in all_files:
        md_path = BASE_DIR / md_name
        if not md_path.exists():
            print(f"[WARN] 文件不存在: {md_name}")
            continue
        
        # 预处理
        processed_content, mermaid_count = preprocess_markdown(md_path)
        
        # 保存预处理后的文件
        processed_md = BUILD_MD_DIR / md_name
        with open(processed_md, 'w', encoding='utf-8') as f:
            f.write(processed_content)
        
        print(f"  替换了 {mermaid_count} 个 mermaid 图")
        
        # 转换为 DOCX
        docx_name = md_name.replace('.md', '.docx')
        docx_path = DOCX_OUT_DIR / docx_name
        
        print(f"  转换: {md_name} -> {docx_name}")
        convert_to_docx(processed_md, docx_path)
        
        docx_files.append(docx_path)
    
    # 合并所有 DOCX
    print("\n开始合并 DOCX 文件...")
    merge_docx_files(docx_files, MERGED_DOCX)
    
    print(f"\n✅ 完成！输出文件: {MERGED_DOCX}")
    print(f"📁 预处理的 MD 文件: {BUILD_MD_DIR}")
    print(f"📁 单独的 DOCX 文件: {DOCX_OUT_DIR}")

if __name__ == "__main__":
    main()