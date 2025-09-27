#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
最终完整版 DOCX 构建器
采用最可靠的方法：先用Pandoc生成单独文档，然后用简单方法合并
确保公式和图片都能正确显示
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
BUILD_MD_DIR = BASE_DIR / "_final_build_md"
DOCX_OUT_DIR = BASE_DIR / "_final_docx_out"
FINAL_DOCX = BASE_DIR / "最终完整论文-分析型数据库的动态缓存技术研究.docx"

CHAPTERS = [
    "第一章-绪论.md",
    "第二章-相关背景与理论基础.md", 
    "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
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
    
    logger.info(f"  找到 {len(blocks)} 个 mermaid 块，可用图片 {len(chapter_images)} 个")
    
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
            logger.info(f"    替换 mermaid 块 -> {img_path.name}")
        else:
            logger.info(f"    跳过 mermaid 块（无对应图片）")
    
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

def create_combined_markdown():
    """创建合并的Markdown文件"""
    logger.info("创建合并的Markdown文件...")
    
    combined_content = []
    
    # 添加标题页
    title_page = """
# 分析型数据库的动态缓存技术研究

**学位论文**

**专业：** 计算机科学与技术  
**研究方向：** 数据库系统  
**完成时间：** 2024年

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
    logger.info("🚀 最终完整版 DOCX 构建器")
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
    
    # 创建合并的Markdown文件
    combined_md = create_combined_markdown()
    
    # 转换为最终DOCX
    logger.info("\n🔄 转换为最终DOCX文件...")
    convert_to_docx(combined_md, FINAL_DOCX)
    
    # 验证最终文档
    try:
        from docx import Document
        test_doc = Document(str(FINAL_DOCX))
        
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
        
        logger.info(f"\n📊 文档统计:")
        logger.info(f"   - 段落数量: {len(test_doc.paragraphs)}")
        logger.info(f"   - 图片关系数: {image_count}")
        logger.info(f"   - 绘图元素数: {drawing_count}")
        logger.info(f"   - 内嵌图形数: {inline_shapes}")
        logger.info(f"   - 文档大小: {FINAL_DOCX.stat().st_size / 1024 / 1024:.2f} MB")
        
        # 检查是否包含公式
        math_count = 0
        for paragraph in test_doc.paragraphs:
            if paragraph._element.xpath('.//m:oMath') or paragraph._element.xpath('.//mml:math'):
                math_count += 1
        
        logger.info(f"   - 数学公式段落: {math_count}")
        
    except Exception as e:
        logger.warning(f"文档验证失败: {e}")
        import traceback
        logger.warning(traceback.format_exc())
    
    logger.info(f"\n✅ 完成！输出文件:")
    logger.info(f"   📄 最终文档: {FINAL_DOCX}")
    logger.info(f"   📁 合并 MD: {BUILD_MD_DIR}")
    
    logger.info(f"\n🏆 特性:")
    logger.info(f"   - ✅ 单一Markdown转换（避免合并问题）")
    logger.info(f"   - ✅ Pandoc MathML 公式处理")
    logger.info(f"   - ✅ 图片自动嵌入")
    logger.info(f"   - ✅ 专业标题页")
    logger.info(f"   - ✅ 分页符处理")

if __name__ == "__main__":
    main()