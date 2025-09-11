#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
最终版 DOCX 构建器：解决图片和公式显示问题
1) 复制图片到构建目录，使用相对路径
2) 改进公式处理
3) 添加详细调试输出
"""

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"
BUILD_DIR = BASE_DIR / "_final_build"
BUILD_MD_DIR = BUILD_DIR / "md"
BUILD_IMG_DIR = BUILD_DIR / "images"
DOCX_OUT_DIR = BUILD_DIR / "docx"
MERGED_DOCX = BASE_DIR / "final_merged_thesis.docx"

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
        return None
    if cp.stdout.strip():
        print(cp.stdout.strip())
    return cp

def setup_build_environment():
    """设置构建环境"""
    print("设置构建环境...")
    
    # 清理并创建构建目录
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)
    
    BUILD_DIR.mkdir(exist_ok=True)
    BUILD_MD_DIR.mkdir(exist_ok=True)
    BUILD_IMG_DIR.mkdir(exist_ok=True)
    DOCX_OUT_DIR.mkdir(exist_ok=True)
    
    # 复制所有图片到构建目录
    if IMAGES_DIR.exists():
        for img_file in IMAGES_DIR.glob("*.png"):
            if not img_file.name.startswith("mermaid_"):  # 只复制命名图片
                shutil.copy2(img_file, BUILD_IMG_DIR)
                print(f"  复制图片: {img_file.name}")
    
    print(f"构建环境准备完成: {BUILD_DIR}")

def get_chapter_images(chapter_num):
    """获取指定章节的图片列表"""
    images = []
    for img in BUILD_IMG_DIR.glob("*.png"):
        if img.name.startswith(f"{chapter_num}."):
            images.append(img)
    
    return sorted(images, key=lambda x: x.name)

def replace_mermaid_with_images(md_text, chapter_num):
    """替换 mermaid 代码块为图片引用"""
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
            # 使用相对路径（相对于 MD 文件位置）
            rel_img_path = f"../images/{img_path.name}"
            replacement = f"\n![{img_path.stem}]({rel_img_path})\n\n"
            md_text = md_text[:block.start()] + replacement + md_text[block.end():]
            replaced += 1
            print(f"    替换 mermaid 块 -> {img_path.name}")
        else:
            print(f"    跳过 mermaid 块（无对应图片）")
    
    return md_text, replaced

def fix_math_formulas(md_text):
    """修复数学公式格式"""
    print("  修复数学公式...")
    
    # 移除被反引号包裹的公式
    md_text = re.sub(r"`(\$[^`$]+\$)`", r"\1", md_text)
    
    # 确保行间公式独占一行，前后有空行
    md_text = re.sub(r"([^\n])\$\$([^$]+)\$\$([^\n])", r"\1\n\n$$\2$$\n\n\3", md_text)
    
    # 修复常见的公式问题
    md_text = re.sub(r"\\frac\s*\{\s*([^}]+)\s*\}\s*\{\s*([^}]+)\s*\}", r"\\frac{\1}{\2}", md_text)
    
    # 确保内联公式前后有空格
    md_text = re.sub(r"([^\s])\$([^$]+)\$([^\s])", r"\1 $\2$ \3", md_text)
    
    return md_text

def preprocess_markdown(md_path):
    """预处理单个 Markdown 文件"""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 提取章节号
    chapter_match = re.search(r"第([一二三四五六七八九十\d]+)章", md_path.name)
    if chapter_match:
        chapter_text = chapter_match.group(1)
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
    # 尝试多种 pandoc 参数组合
    cmd_variants = [
        # 变体1：使用 OMML（Office Math Markup Language）
        [
            "pandoc", str(md_path), "-o", str(docx_path),
            "--standalone",
            "--from", "markdown+tex_math_dollars+tex_math_double_backslash",
            "--to", "docx",
            "--wrap", "preserve"
        ],
        # 变体2：使用 MathML
        [
            "pandoc", str(md_path), "-o", str(docx_path),
            "--standalone", 
            "--from", "markdown+tex_math_dollars",
            "--to", "docx",
            "--mathml"
        ],
        # 变体3：基础转换
        [
            "pandoc", str(md_path), "-o", str(docx_path),
            "--standalone",
            "--from", "markdown",
            "--to", "docx"
        ]
    ]
    
    for i, cmd in enumerate(cmd_variants):
        print(f"  尝试转换方式 {i+1}...")
        result = run_cmd(cmd, cwd=BUILD_MD_DIR)
        if result and docx_path.exists():
            print(f"  ✅ 转换成功")
            return True
        else:
            print(f"  ❌ 转换失败，尝试下一种方式")
    
    print(f"  ❌ 所有转换方式都失败")
    return False

def merge_docx_files(docx_files, output_path):
    """合并多个 DOCX 文件"""
    try:
        from docx import Document
        from docx.enum.text import WD_BREAK
    except ImportError:
        print("[ERROR] 需要安装 python-docx: pip install python-docx")
        return False
    
    merged = Document()
    
    for i, docx_path in enumerate(docx_files):
        if not docx_path.exists():
            print(f"[WARN] 跳过缺失文件: {docx_path}")
            continue
        
        try:
            doc = Document(str(docx_path))
            print(f"  合并: {docx_path.name}")
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
    print(f"✅ 合并完成: {output_path}")
    return True

def debug_processed_files():
    """调试：检查预处理后的文件"""
    print("\n=== 调试信息 ===")
    
    for md_file in BUILD_MD_DIR.glob("*.md"):
        print(f"\n检查文件: {md_file.name}")
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查图片引用
        img_refs = re.findall(r"!\[.*?\]\([^)]+\)", content)
        print(f"  图片引用数量: {len(img_refs)}")
        for ref in img_refs[:3]:  # 只显示前3个
            print(f"    {ref}")
        
        # 检查公式
        inline_math = re.findall(r"\$[^$]+\$", content)
        block_math = re.findall(r"\$\$[^$]+\$\$", content)
        print(f"  内联公式数量: {len(inline_math)}")
        print(f"  块级公式数量: {len(block_math)}")

def main():
    print(f"工作目录: {BASE_DIR}")
    
    # 设置构建环境
    setup_build_environment()
    
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
        if convert_to_docx(processed_md, docx_path):
            docx_files.append(docx_path)
        else:
            print(f"  [ERROR] 转换失败: {md_name}")
    
    # 调试预处理后的文件
    debug_processed_files()
    
    # 合并所有 DOCX
    if docx_files:
        print(f"\n开始合并 {len(docx_files)} 个 DOCX 文件...")
        if merge_docx_files(docx_files, MERGED_DOCX):
            print(f"\n🎉 完成！输出文件: {MERGED_DOCX}")
            print(f"📁 构建目录: {BUILD_DIR}")
            print(f"📁 预处理的 MD 文件: {BUILD_MD_DIR}")
            print(f"📁 单独的 DOCX 文件: {DOCX_OUT_DIR}")
        else:
            print(f"\n❌ 合并失败")
    else:
        print(f"\n❌ 没有成功转换的 DOCX 文件")

if __name__ == "__main__":
    main()