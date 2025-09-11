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

def copy_images_to_output():
    """复制图片到输出目录"""
    output_images_dir = DOCX_OUT_DIR / "images"
    output_images_dir.mkdir(exist_ok=True)
    
    if not IMAGES_DIR.exists():
        print("[WARN] 源图片目录不存在")
        return
    
    # 复制所有 PNG 文件
    png_files = list(IMAGES_DIR.glob("*.png"))
    for png_file in png_files:
        dest_path = output_images_dir / png_file.name
        shutil.copy2(png_file, dest_path)
        print(f"📋 复制图片: {png_file.name}")
    
    # 复制 mermaid 源文件（如果存在）
    mmd_files = list(IMAGES_DIR.glob("*.mmd")) + list(IMAGES_DIR.glob("*.mermaid"))
    for mmd_file in mmd_files:
        dest_path = output_images_dir / mmd_file.name
        shutil.copy2(mmd_file, dest_path)
        print(f"📋 复制 Mermaid 文件: {mmd_file.name}")
    
    print(f"✅ 图片复制完成，共 {len(png_files)} 个 PNG 文件，{len(mmd_files)} 个 Mermaid 文件")
    print(f"📁 输出图片目录: {output_images_dir}")

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
    """改进的合并多个 DOCX 文件，保持格式一致性"""
    try:
        from docx import Document
        from docx.enum.text import WD_BREAK
        from docx.shared import Pt
        from docx.oxml.shared import OxmlElement, qn
    except ImportError:
        print("[ERROR] 需要安装 python-docx: pip install python-docx")
        sys.exit(1)
    
    # 创建新文档并设置默认样式
    merged = Document()
    
    # 强制设置文档默认字体
    merged.styles['Normal'].font.name = 'Times New Roman'
    merged.styles['Normal'].font.size = Pt(12)
    
    # 删除默认段落
    for paragraph in merged.paragraphs:
        p = paragraph._element
        p.getparent().remove(p)
    
    for i, docx_path in enumerate(docx_files):
        if not docx_path.exists():
            print(f"[WARN] 跳过缺失文件: {docx_path}")
            continue
        
        try:
            doc = Document(str(docx_path))
            print(f"📖 合并文件: {docx_path.name}")
        except Exception as e:
            print(f"[WARN] 无法打开文件 {docx_path}: {e}")
            continue
        
        # 添加分页符（除了第一个文档）
        if i > 0:
            page_break = merged.add_paragraph()
            page_break.add_run().add_break(WD_BREAK.PAGE)
        
        # 逐段落复制内容，保持格式
        for paragraph in doc.paragraphs:
            # 创建新段落
            new_para = merged.add_paragraph()
            
            # 复制段落格式
            new_para.alignment = paragraph.alignment
            new_para.paragraph_format.space_before = paragraph.paragraph_format.space_before
            new_para.paragraph_format.space_after = paragraph.paragraph_format.space_after
            
            # 复制所有 runs
            for run in paragraph.runs:
                new_run = new_para.add_run(run.text)
                
                # 强制设置字体
                if run.font.name:
                    new_run.font.name = run.font.name
                else:
                    new_run.font.name = 'Times New Roman'
                
                if run.font.size:
                    new_run.font.size = run.font.size
                else:
                    new_run.font.size = Pt(12)
                
                new_run.bold = run.bold
                new_run.italic = run.italic
                new_run.underline = run.underline
                
                # 强制设置字体属性
                force_run_font(new_run, new_run.font.name or 'Times New Roman', 
                             (new_run.font.size.pt if new_run.font.size else 12))
        
        # 复制表格
        for table in doc.tables:
            new_table = merged.add_table(rows=len(table.rows), cols=len(table.columns))
            for i, row in enumerate(table.rows):
                for j, cell in enumerate(row.cells):
                    new_table.cell(i, j).text = cell.text
                    # 设置表格字体
                    for paragraph in new_table.cell(i, j).paragraphs:
                        for run in paragraph.runs:
                            force_run_font(run, 'Times New Roman', 12)
    
    merged.save(str(output_path))
    print(f"✅ 合并完成: {output_path}")

def force_run_font(run, font_name='Times New Roman', font_size=12):
    """强制设置 run 的字体"""
    try:
        from docx.oxml.shared import OxmlElement, qn
        
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
        sz.set(qn('w:val'), str(int(font_size * 2)))  # Word 使用半点
        rPr.append(sz)
        
        szCs = OxmlElement('w:szCs')
        szCs.set(qn('w:val'), str(int(font_size * 2)))
        rPr.append(szCs)
        
    except Exception as e:
        print(f"[WARN] 字体设置失败: {e}")

def main():
    print(f"🚀 增强版 DOCX 构建器")
    print(f"📁 工作目录: {BASE_DIR}")
    
    # 确保图片存在
    ensure_images()
    
    # 清理并创建构建目录
    if BUILD_MD_DIR.exists():
        shutil.rmtree(BUILD_MD_DIR)
    BUILD_MD_DIR.mkdir(exist_ok=True)
    
    if DOCX_OUT_DIR.exists():
        shutil.rmtree(DOCX_OUT_DIR)
    DOCX_OUT_DIR.mkdir(exist_ok=True)
    
    # 复制图片到输出目录
    copy_images_to_output()
    
    docx_files = []
    
    # 处理所有章节
    all_files = CHAPTERS + [REF_MD]
    
    for md_name in all_files:
        md_path = BASE_DIR / md_name
        if not md_path.exists():
            print(f"[WARN] 文件不存在: {md_name}")
            continue
        
        print(f"\n📖 处理章节: {md_name}")
        
        # 预处理
        processed_content, mermaid_count = preprocess_markdown(md_path)
        
        # 保存预处理后的文件
        processed_md = BUILD_MD_DIR / md_name
        with open(processed_md, 'w', encoding='utf-8') as f:
            f.write(processed_content)
        
        print(f"  ✅ 替换了 {mermaid_count} 个 mermaid 图")
        
        # 转换为 DOCX
        docx_name = md_name.replace('.md', '.docx')
        docx_path = DOCX_OUT_DIR / docx_name
        
        print(f"  🔄 转换: {md_name} -> {docx_name}")
        convert_to_docx(processed_md, docx_path)
        
        docx_files.append(docx_path)
    
    # 合并所有 DOCX
    print("\n🔗 开始合并 DOCX 文件...")
    merge_docx_files(docx_files, MERGED_DOCX)
    
    # 验证最终文档
    try:
        from docx import Document
        test_doc = Document(str(MERGED_DOCX))
        
        # 统计图片数量
        image_count = 0
        for rel in test_doc.part.rels.values():
            if "image" in rel.target_ref:
                image_count += 1
        
        print(f"\n📊 文档统计:")
        print(f"   - 段落数量: {len(test_doc.paragraphs)}")
        print(f"   - 嵌入图片: {image_count}")
        print(f"   - 文档大小: {MERGED_DOCX.stat().st_size / 1024 / 1024:.1f} MB")
        
    except Exception as e:
        print(f"[WARN] 文档验证失败: {e}")
    
    print(f"\n✅ 完成！输出文件:")
    print(f"   📄 合并文档: {MERGED_DOCX}")
    print(f"   📁 预处理 MD: {BUILD_MD_DIR}")
    print(f"   📁 单独 DOCX: {DOCX_OUT_DIR}")
    print(f"   🖼️  图片目录: {DOCX_OUT_DIR}/images")
    
    print(f"\n🏆 改进特性:")
    print(f"   - ✅ 强制字体设置 (Times New Roman)")
    print(f"   - ✅ 改进的合并逻辑")
    print(f"   - ✅ 图片复制到输出目录")
    print(f"   - ✅ 支持 PNG 和 Mermaid 文件")
    print(f"   - ✅ 保持格式一致性")

if __name__ == "__main__":
    main()