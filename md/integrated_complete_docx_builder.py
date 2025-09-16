#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
融合版完整 DOCX 构建器
结合 enhanced_docx_builder.py 和 final_complete_docx_builder.py 的所有功能：
1) 生成每章单独的 DOCX 文件
2) 生成最终完整的合并文档
3) 确保图片和公式都正确显示
4) 支持图片复制到输出目录
"""

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
import logging

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"
BUILD_MD_DIR = BASE_DIR / "_integrated_build_md"
DOCX_OUT_DIR = BASE_DIR / "_integrated_docx_out"
FINAL_DOCX = BASE_DIR / "完整论文-分析型数据库的动态缓存技术研究.docx"

CHAPTERS = [
    "第0章-摘要.md",
    "第一章-绪论.md",
    "第二章-相关背景与理论基础.md", 
    "第三章-动态缓存管理.md",
    "第四章-动态缓存更新技术与持久化技术.md",
    "第五章-实验与分析.md",
    "第六章-总结与展望.md",
]
REF_MD = "统一参考文献列表.md"

def run_cmd(cmd, cwd=None):
    """运行命令"""
    logger.info(f"执行命令: {' '.join(str(x) for x in cmd)}")
    cp = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                       text=True, cwd=cwd or BASE_DIR)
    if cp.returncode != 0:
        logger.error(f"命令执行失败: {cp.stderr.strip()}")
        sys.exit(cp.returncode)
    if cp.stdout.strip():
        logger.info(cp.stdout.strip())
    return cp

def ensure_images():
    """确保图片已生成"""
    if not IMAGES_DIR.exists() or len(list(IMAGES_DIR.glob("*.png"))) == 0:
        script = BASE_DIR / "extract_all_images.py"
        if script.exists():
            logger.info("生成图片...")
            run_cmd([sys.executable, str(script)])
        else:
            logger.warning("未找到图片生成脚本")

def copy_images_to_output():
    """复制图片到输出目录"""
    output_images_dir = DOCX_OUT_DIR / "images"
    output_images_dir.mkdir(exist_ok=True)
    
    if not IMAGES_DIR.exists():
        logger.warning("源图片目录不存在")
        return
    
    # 复制所有 PNG 文件
    png_files = list(IMAGES_DIR.glob("*.png"))
    for png_file in png_files:
        dest_path = output_images_dir / png_file.name
        shutil.copy2(png_file, dest_path)
        logger.info(f"📋 复制图片: {png_file.name}")
    
    # 复制 mermaid 源文件（如果存在）
    mmd_files = list(IMAGES_DIR.glob("*.mmd")) + list(IMAGES_DIR.glob("*.mermaid"))
    for mmd_file in mmd_files:
        dest_path = output_images_dir / mmd_file.name
        shutil.copy2(mmd_file, dest_path)
        logger.info(f"📋 复制 Mermaid 文件: {mmd_file.name}")
    
    logger.info(f"✅ 图片复制完成，共 {len(png_files)} 个 PNG 文件，{len(mmd_files)} 个 Mermaid 文件")
    logger.info(f"📁 输出图片目录: {output_images_dir}")

def get_chapter_images(chapter_num):
    """获取指定章节的图片列表"""
    if not IMAGES_DIR.exists():
        return []
    
    images = []
    for img in IMAGES_DIR.glob("*.png"):
        # 匹配新格式：5-图5.18 机器学习模型特征重要性分布.png
        if img.name.startswith(f"{chapter_num}-图") and not img.name.startswith("mermaid_"):
            # 验证是否确实属于该章节
            pattern = rf"{chapter_num}-图(\d+\.\d+)"
            match = re.match(pattern, img.name)
            if match:
                images.append(img)
    
    # 使用图号排序
    def extract_figure_number(filename):
        # 从文件名中提取完整图号，如 "5-图5.18 机器学习模型特征重要性分布.png" -> (5, 18)
        match = re.match(rf"{chapter_num}-图(\d+)\.(\d+)", filename.name)
        if match:
            return (int(match.group(1)), int(match.group(2)))
        return (0, 0)
    
    return sorted(images, key=extract_figure_number)

def replace_mermaid_with_images(md_text, chapter_num):
    """替换 mermaid 代码块为图片引用"""
    # 查找所有 mermaid 代码块和图片标题
    mermaid_pattern = r"```mermaid[^\n]*\n([\s\S]*?)```"
    title_pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
    
    mermaid_blocks = list(re.finditer(mermaid_pattern, md_text))
    title_matches = list(re.finditer(title_pattern, md_text))
    
    if not mermaid_blocks:
        return md_text, 0
    
    logger.info(f"  找到 {len(mermaid_blocks)} 个 mermaid 块")
    
    # 为每个mermaid块找到对应的图片文件
    replaced = 0
    for i, block in enumerate(reversed(mermaid_blocks)):
        mermaid_pos = block.start()
        
        # 找到最近的标题
        best_title = None
        best_distance = float('inf')
        
        for title_match in title_matches:
            title_pos = title_match.start()
            distance = abs(mermaid_pos - title_pos)
            
            # 优先选择在mermaid块前面且距离最近的标题
            if title_pos < mermaid_pos and distance < best_distance:
                best_title = title_match
                best_distance = distance
            # 如果没有前面的标题，选择后面最近的
            elif best_title is None and title_pos > mermaid_pos and distance < best_distance:
                best_title = title_match
                best_distance = distance
        
        if best_title:
            fig_num = best_title.group(1)  # 如 "5.18"
            title = best_title.group(2).strip()  # 如 "机器学习模型特征重要性分布"
            
            # 构建图片文件名
            img_filename = f"{chapter_num}-图{fig_num} {title}.png"
            img_path = IMAGES_DIR / img_filename
            
            if img_path.exists():
                # 使用绝对路径确保 pandoc 能找到
                abs_img_path = str(img_path.absolute())
                replacement = f"![图片]({abs_img_path})\n"
                md_text = md_text[:block.start()] + replacement + md_text[block.end():]
                replaced += 1
                logger.info(f"    替换 mermaid 块 -> {img_filename}")
            else:
                logger.info(f"    跳过 mermaid 块（图片文件不存在: {img_filename}）")
        else:
            logger.info(f"    跳过 mermaid 块（找不到对应标题）")
    
    return md_text, replaced

def fix_math_formulas(md_text):
    """修复数学公式格式"""
    # 移除被反引号包裹的公式
    md_text = re.sub(r"`(\$[^`$]+\$)`", r"\1", md_text)
    
    # 确保行间公式独占一行
    md_text = re.sub(r"([^$])\$\$([^$]+)\$\$([^$])", r"\1\n\n$$\2$$\n\n\3", md_text)
    
    # 修复常见的公式问题
    # 将 \\frac{a}{b} 确保正确格式
    md_text = re.sub(r"\\frac\s*\{\s*([^}]+)\s*\}\s*\{\s*([^}]+)\s*\}", r"\\frac{\1}{\2}", md_text)
    
    return md_text

def preprocess_markdown(md_path):
    """预处理单个 Markdown 文件"""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 提取章节号
    chapter_match = re.search(r"第([一二三四五六七八九十\d]+)章", md_path.name)
    if chapter_match:
        chapter_text = chapter_match.group(1)
        # 转换中文数字为阿拉伯数字
        chinese_to_num = {'一': '1', '二': '2', '三': '3', '四': '4', '五': '5', '六': '6'}
        chapter_num = chinese_to_num.get(chapter_text, chapter_text)
    else:
        chapter_num = "0"
    
    logger.info(f"预处理章节 {chapter_num}: {md_path.name}")
    
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
        "--mathml",  # 使用 MathML 获得更好的公式显示
    ]
    
    run_cmd(cmd)

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
        logger.warning(f"字体设置失败: {e}")

def merge_docx_files(docx_files, output_path):
    """改进的合并多个 DOCX 文件，保持格式一致性"""
    try:
        from docx import Document
        from docx.enum.text import WD_BREAK
        from docx.shared import Pt
        from docx.oxml.shared import OxmlElement, qn
    except ImportError:
        logger.error("需要安装 python-docx: pip install python-docx")
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
    
    # 添加标题页
    title_para = merged.add_paragraph()
    title_run = title_para.add_run("分析型数据库的动态缓存技术研究")
    title_run.font.name = 'Times New Roman'
    title_run.font.size = Pt(18)
    title_run.bold = True
    title_para.alignment = 1  # 居中
    
    merged.add_paragraph()
    
    subtitle_para = merged.add_paragraph()
    subtitle_run = subtitle_para.add_run("学位论文")
    subtitle_run.font.name = 'Times New Roman'
    subtitle_run.font.size = Pt(14)
    subtitle_para.alignment = 1  # 居中
    
    merged.add_paragraph()
    merged.add_paragraph("专业：计算机科学与技术").alignment = 1
    merged.add_paragraph("研究方向：数据库系统").alignment = 1
    merged.add_paragraph("完成时间：2025年").alignment = 1
    
    # 添加分页符
    page_break = merged.add_paragraph()
    page_break.add_run().add_break(WD_BREAK.PAGE)
    
    for i, docx_path in enumerate(docx_files):
        if not docx_path.exists():
            logger.warning(f"跳过缺失文件: {docx_path}")
            continue
        
        try:
            doc = Document(str(docx_path))
            logger.info(f"📖 合并文件: {docx_path.name}")
        except Exception as e:
            logger.warning(f"无法打开文件 {docx_path}: {e}")
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
    logger.info(f"✅ 合并完成: {output_path}")

def create_combined_markdown():
    """创建合并的Markdown文件（用于单一转换方法）"""
    logger.info("创建合并的Markdown文件...")
    
    combined_content = []
    
    # 添加标题页
    title_page = """
# 分析型数据库的动态缓存技术研究

**学位论文**

**专业：** 计算机科学与技术  
**研究方向：** 数据库系统  
**完成时间：** 2025年

\\newpage

"""
    combined_content.append(title_page)
    
    # 处理所有章节
    all_files = CHAPTERS + [REF_MD]
    
    for md_name in all_files:
        md_path = BASE_DIR / md_name
        if not md_path.exists():
            logger.warning(f"文件不存在: {md_name}")
            continue
        
        logger.info(f"📖 处理章节: {md_name}")
        
        # 预处理
        processed_content, mermaid_count = preprocess_markdown(md_path)
        
        logger.info(f"  ✅ 替换了 {mermaid_count} 个 mermaid 图")
        
        # 添加到合并内容
        combined_content.append(f"\n\\newpage\n\n{processed_content}\n")
    
    # 保存合并的Markdown文件
    combined_md = BUILD_MD_DIR / "完整论文.md"
    with open(combined_md, 'w', encoding='utf-8') as f:
        f.write('\n'.join(combined_content))
    
    logger.info(f"✅ 合并Markdown文件已保存: {combined_md}")
    return combined_md

def main():
    """主函数"""
    logger.info("🚀 融合版完整 DOCX 构建器")
    logger.info(f"📁 工作目录: {BASE_DIR}")
    
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
    
    logger.info("\n" + "="*60)
    logger.info("第一阶段：生成每章单独的 DOCX 文件")
    logger.info("="*60)
    
    docx_files = []
    
    # 处理所有章节，生成单独的DOCX文件
    all_files = CHAPTERS + [REF_MD]
    
    for md_name in all_files:
        md_path = BASE_DIR / md_name
        if not md_path.exists():
            logger.warning(f"文件不存在: {md_name}")
            continue
        
        logger.info(f"\n📖 处理章节: {md_name}")
        
        # 预处理
        processed_content, mermaid_count = preprocess_markdown(md_path)
        
        # 保存预处理后的文件
        processed_md = BUILD_MD_DIR / md_name
        with open(processed_md, 'w', encoding='utf-8') as f:
            f.write(processed_content)
        
        logger.info(f"  ✅ 替换了 {mermaid_count} 个 mermaid 图")
        
        # 转换为 DOCX
        docx_name = md_name.replace('.md', '.docx')
        docx_path = DOCX_OUT_DIR / docx_name
        
        logger.info(f"  🔄 转换: {md_name} -> {docx_name}")
        convert_to_docx(processed_md, docx_path)
        
        docx_files.append(docx_path)
    
    logger.info("\n" + "="*60)
    logger.info("第二阶段：生成最终完整文档")
    logger.info("="*60)
    
    # 方法1：使用合并方式
    logger.info("\n🔗 方法1：合并单独的DOCX文件...")
    merged_docx = BASE_DIR / "合并版-分析型数据库的动态缓存技术研究.docx"
    merge_docx_files(docx_files, merged_docx)
    
    # 方法2：使用单一Markdown转换方式
    logger.info("\n🔄 方法2：单一Markdown转换...")
    combined_md = create_combined_markdown()
    convert_to_docx(combined_md, FINAL_DOCX)
    
    # 验证最终文档
    logger.info("\n📊 文档验证...")
    
    for doc_name, doc_path in [("合并版", merged_docx), ("单一转换版", FINAL_DOCX)]:
        try:
            from docx import Document
            test_doc = Document(str(doc_path))
            
            # 统计图片数量 - 使用更准确的方法
            image_count = 0
            drawing_count = 0
            
            # 方法1：通过关系统计
            for rel in test_doc.part.rels.values():
                if "image" in rel.target_ref:
                    image_count += 1
            
            # 方法2：通过文档元素统计
            for paragraph in test_doc.paragraphs:
                for run in paragraph.runs:
                    if run._element.xpath('.//a:blip'):
                        drawing_count += 1
            
            # 方法3：检查内嵌对象
            inline_shapes = 0
            for paragraph in test_doc.paragraphs:
                if paragraph._element.xpath('.//w:drawing'):
                    inline_shapes += len(paragraph._element.xpath('.//w:drawing'))
            
            logger.info(f"\n📊 {doc_name} 统计:")
            logger.info(f"   - 段落数量: {len(test_doc.paragraphs)}")
            logger.info(f"   - 图片关系数: {image_count}")
            logger.info(f"   - 绘图元素数: {drawing_count}")
            logger.info(f"   - 内嵌图形数: {inline_shapes}")
            logger.info(f"   - 文档大小: {doc_path.stat().st_size / 1024 / 1024:.2f} MB")
            
            # 检查是否包含公式
            math_count = 0
            for paragraph in test_doc.paragraphs:
                if paragraph._element.xpath('.//m:oMath') or paragraph._element.xpath('.//mml:math'):
                    math_count += 1
            
            logger.info(f"   - 数学公式段落: {math_count}")
            
        except Exception as e:
            logger.warning(f"{doc_name} 验证失败: {e}")
    
    logger.info(f"\n✅ 完成！输出文件:")
    logger.info(f"   📄 单独章节DOCX: {DOCX_OUT_DIR}")
    logger.info(f"   📄 合并版文档: {merged_docx}")
    logger.info(f"   📄 单一转换版: {FINAL_DOCX}")
    logger.info(f"   📁 预处理 MD: {BUILD_MD_DIR}")
    logger.info(f"   🖼️  图片目录: {DOCX_OUT_DIR}/images")
    
    logger.info(f"\n🏆 融合特性:")
    logger.info(f"   - ✅ 生成每章单独DOCX文件")
    logger.info(f"   - ✅ 两种完整文档生成方式")
    logger.info(f"   - ✅ Pandoc MathML 公式处理")
    logger.info(f"   - ✅ 图片自动嵌入和复制")
    logger.info(f"   - ✅ 强制字体设置 (Times New Roman)")
    logger.info(f"   - ✅ 专业标题页")
    logger.info(f"   - ✅ 分页符处理")

if __name__ == "__main__":
    main()