#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
预处理并构建 DOCX：
1) 运行 extract_all_images.py（如需要）以确保 mermaid 图已生成到 images/
2) 将各章 Markdown 中的 mermaid 代码块替换为对应 PNG 图片引用
3) 规范 LaTeX 公式标记（$...$ 或 $$...$$），移除误用反引号包裹
4) 使用 pandoc 将预处理后的 Markdown 转换为 DOCX
5) 合并为 merged_thesis.docx

先决条件：
- 已安装 pandoc
- 已安装 python-docx（用于合并）
"""

import os
import re
import json
import shutil
import subprocess
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
IMAGES_DIR = os.path.join(BASE_DIR, "images")
REPORT_JSON = os.path.join(BASE_DIR, "图片提取报告.json")
INDEX_MD = os.path.join(BASE_DIR, "图片索引.md")
BUILD_MD_DIR = os.path.join(BASE_DIR, "_build_md")
DOCX_OUT_DIR = os.path.join(BASE_DIR, "docx_out")
MERGED_DOCX = os.path.join(BASE_DIR, "merged_thesis.docx")

CHAPTERS = [
    "第一章-绪论.md",
    "第二章-相关背景与理论基础.md",
    "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
    "第四章-动态缓存更新技术与持久化技术.md",
    "第五章-实验与分析.md",
    "第六章-总结与展望.md",
]
REF_MD = "统一参考文献列表.md"

def run_cmd(cmd):
    print("+", " ".join(cmd))
    cp = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if cp.returncode != 0:
        print("[ERROR]", cp.stderr.strip())
        sys.exit(cp.returncode)
    if cp.stdout.strip():
        print(cp.stdout.strip())
    return cp

def ensure_images():
    # 若无 images 或为空，则尝试运行提取脚本
    needs = (not os.path.isdir(IMAGES_DIR)) or (len(os.listdir(IMAGES_DIR)) == 0)
    if needs:
        script = os.path.join(BASE_DIR, "extract_all_images.py")
        if os.path.exists(script):
            print("Run extract_all_images.py to generate images...")
            run_cmd(["python3", script])
        else:
            print("[WARN] 未找到 extract_all_images.py，继续但 mermaid 可能无法插图。")

def load_image_map():
    """
    尝试从 图片索引.md 或 图片提取报告.json 构建 mermaid → PNG 的映射。
    简化：我们不解析 mermaid 内容，只要将 mermaid 块替换为按顺序命名的图片。
    extract_all_images.py 一般是按顺序 生成 文件名，如 3.1_...png，且文中紧邻 **图X.Y**。
    我们这里采用保守策略：把每个 mermaid 块替换为最近的“图X.Y”命名图片；若无法匹配，则跳过替换。
    """
    mapping = {}  # key: (chapter_file, mermaid_index) -> image_rel_path
    # 粗略从 images 列表推断（文件名通常以 X.Y_ 开头）
    images = [f for f in os.listdir(IMAGES_DIR) if f.lower().endswith(".png")]
    images.sort()
    return mapping, images

def replace_mermaid_with_images(md_text, images_sorted):
    """
    将文中的 mermaid 代码块替换为 ![](images/xxx.png)
    基于一个简化策略：按出现顺序映射到按文件名排序的图片列表（在同章内）。
    若图片不够，则保留原 mermaid（提醒）。
    """
    blocks = list(re.finditer(r"```mermaid[^\n]*\n([\s\S]*?)```", md_text))
    if not blocks:
        return md_text, 0

    new_text = []
    last = 0
    replaced = 0

    # 过滤出与本章相关的图片（启发式），优先匹配以本章号开头的图片
    chapter_num = None
    m = re.search(r"^#\s*第(\d+)章", md_text, re.M)
    if m:
        chapter_num = m.group(1)
    chapter_images = []
    if chapter_num:
        for f in images_sorted:
            if f.startswith(f"{chapter_num}."):
                chapter_images.append(f)
    # 回退：若无匹配章号图片，使用全部列表
    pool = chapter_images if chapter_images else images_sorted
    img_idx = 0

    for b in blocks:
        new_text.append(md_text[last:b.start()])
        if img_idx < len(pool):
            img = pool[img_idx]
            img_idx += 1
            new_text.append(f"![](images/{img})\n")
            replaced += 1
        else:
            # 图片不足，保留原代码块
            new_text.append(md_text[b.start():b.end()])
        last = b.end()
    new_text.append(md_text[last:])
    return "".join(new_text), replaced

def normalize_math(md_text):
    """
    公式规范化：
    - 移除被反引号包裹的数学片段 `...$x$...` -> ...$x$...
    - 确保 $$ ... $$ 行间公式独占一行
    - 避免被额外缩进导致代码块化
    """
    # 去掉行内公式周围误加的反引号
    md_text = re.sub(r"`(\$[^`]+\$)`", r"\1", md_text)
    # 将 $$ 内的内容两侧包行
    md_text = re.sub(r"\$\$(.+?)\$\$", r"\n$$\1$$\n", md_text, flags=re.S)
    # 移除行首多余的4空格以避免被视为代码块（仅作用于纯 $$ 行）
    lines = md_text.splitlines()
    for i, line in enumerate(lines):
        if re.match(r"\s*\$\$.*\$\$\s*$", line):
            lines[i] = line.strip()
    return "\n".join(lines)

def preprocess_one(md_path, images_sorted):
    with open(md_path, "r", encoding="utf-8") as f:
        text = f.read()
    text2, count = replace_mermaid_with_images(text, images_sorted)
    text3 = normalize_math(text2)
    return text3, count

def convert_with_pandoc(src_md, dst_docx):
    cmd = [
        "pandoc",
        src_md,
        "-o", dst_docx,
        "--resource-path", BASE_DIR,
        "--resource-path", IMAGES_DIR,
        "--standalone",
        "--from", "markdown+tex_math_dollars+tex_math_single_backslash",
        "--to", "docx",
    ]
    run_cmd(cmd)

def merge_docx(docx_list, output_path):
    from docx import Document
    from docx.enum.text import WD_BREAK

    merged = Document()
    first = True
    for path in docx_list:
        if not os.path.exists(path):
            print(f"[WARN] 缺失：{path}")
            continue
        try:
            doc = Document(path)
        except Exception as e:
            print(f"[WARN] 无法打开，跳过：{path} -> {e}")
            continue
        if not first:
            p = merged.add_paragraph()
            p.add_run().add_break(WD_BREAK.PAGE)
        first = False
        # 直接合并段落与表格（简单策略）
        for para in doc.paragraphs:
            new_para = merged.add_paragraph()
            for run in para.runs:
                r = new_para.add_run(run.text)
                r.bold = run.bold
                r.italic = run.italic
                r.underline = run.underline
                r.font.name = getattr(run.font, "name", None)
                r.font.size = getattr(run.font, "size", None)
        for table in doc.tables:
            new_table = merged.add_table(rows=len(table.rows), cols=len(table.columns))
            for r_idx, row in enumerate(table.rows):
                for c_idx, cell in enumerate(row.cells):
                    new_table.cell(r_idx, c_idx).text = cell.text
    merged.save(output_path)
    print("合并完成 ->", output_path)

def main():
    os.chdir(BASE_DIR)
    ensure_images()
    # 读取 images 列表
    _, images_sorted = load_image_map()

    # 准备构建目录
    if os.path.isdir(BUILD_MD_DIR):
        shutil.rmtree(BUILD_MD_DIR)
    os.makedirs(BUILD_MD_DIR, exist_ok=True)
    if os.path.isdir(DOCX_OUT_DIR):
        shutil.rmtree(DOCX_OUT_DIR)
    os.makedirs(DOCX_OUT_DIR, exist_ok=True)

    built_docx = []
    # 逐章预处理并转换
    for md_name in CHAPTERS + [REF_MD]:
        src = os.path.join(BASE_DIR, md_name)
        if not os.path.exists(src):
            print(f"[WARN] 未找到：{md_name}")
            continue
        print(f"预处理：{md_name}")
        processed, replaced = preprocess_one(src, images_sorted)
        if replaced:
            print(f"  替换 mermaid -> 图片：{replaced} 处")
        # 写入临时 md
        tmp_md = os.path.join(BUILD_MD_DIR, md_name)
        with open(tmp_md, "w", encoding="utf-8") as f:
            f.write(processed)
        # 转换为 docx
        out_docx = os.path.join(DOCX_OUT_DIR, md_name.replace(".md", ".docx"))
        print(f"  转换：{md_name} -> {os.path.basename(out_docx)}")
        convert_with_pandoc(tmp_md, out_docx)
        built_docx.append(out_docx)

    # 合并（参考文献在最后，已按顺序追加）
    print("开始合并 DOCX ...")
    merge_docx(built_docx, MERGED_DOCX)
    print("全部完成：", MERGED_DOCX)

if __name__ == "__main__":
    main()