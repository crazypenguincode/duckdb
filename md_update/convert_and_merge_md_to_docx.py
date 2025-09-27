#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
功能：
1) 使用 pandoc 将 md_update 目录下的 1~6 章与统一参考文献 从 Markdown 转为对应 DOCX（保留图片与公式）。
2) 按顺序将 DOCX 合并为一个 merged_thesis.docx，参考文献放最后。

先决条件：
- 已安装 pandoc（https://pandoc.org）
- 已安装 python-docx:  python3 -m pip install --user python-docx

用法：
  cd /Users/max/src/duckdb/md_update
  python3 convert_and_merge_md_to_docx.py
"""

import os
import shutil
import subprocess
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(BASE_DIR, "docx_out")
IMAGES_DIR = os.path.join(BASE_DIR, "images")

CHAPTER_MD = [
    "第一章-绪论.md",
    "第二章-相关背景与理论基础.md",
    "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
    "第四章-动态缓存更新技术与持久化技术.md",
    "第五章-实验与分析.md",
    "第六章-总结与展望.md",
]
REF_MD = "统一参考文献列表.md"

CHAPTER_DOCX = [
    "第一章-绪论.docx",
    "第二章-相关背景与理论基础.docx",
    "第三章-动态缓存管理.docx",
    "第四章-动态缓存更新技术与持久化技术.docx",
    "第五章-实验与分析.docx",
    "第六章-总结与展望.docx",
]
REF_DOCX = "统一参考文献列表.docx"
MERGED_DOCX = "merged_thesis.docx"

def check_pandoc():
    try:
        res = subprocess.run(["pandoc", "-v"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False, text=True)
        return res.returncode == 0
    except FileNotFoundError:
        return False

def run(cmd):
    print("+", " ".join(cmd))
    cp = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if cp.returncode != 0:
        print("[ERROR] 命令失败:", " ".join(cmd))
        print(cp.stderr)
        sys.exit(cp.returncode)
    if cp.stdout.strip():
        print(cp.stdout)

def ensure_out_dir():
    if os.path.exists(OUT_DIR):
        # 清空输出目录
        shutil.rmtree(OUT_DIR)
    os.makedirs(OUT_DIR, exist_ok=True)

def convert_md_to_docx(md_path: str, docx_path: str):
    """
    使用 pandoc 将单个 MD 转 DOCX：
    - 从 Markdown（含公式与 mermaid/图片链接）转为 docx
    - 启用数学公式（--mathjax/默认 pandoc 会处理 LaTeX 数学至 OOXML 公式）
    - 资源路径包含 images 目录，确保图片能被找到
    """
    # pandoc 在生成 docx 时，LaTeX 数学公式会转换为 Office Math（OMML），无需额外参数。
    # 为了稳妥加入资源路径与可能的中文支持
    cmd = [
        "pandoc",
        md_path,
        "-o", docx_path,
        "--resource-path", BASE_DIR,            # 允许相对路径解析
        "--standalone",
        "--from", "markdown+tex_math_dollars+tex_math_single_backslash",
        "--to", "docx",
    ]
    # 若 images 目录存在，添加到资源路径（pandoc 会自动解析 ![]()）
    if os.path.isdir(IMAGES_DIR):
        cmd.extend(["--resource-path", IMAGES_DIR])

    run(cmd)

def merge_docx(files, output):
    from docx import Document
    from docx.enum.text import WD_BREAK

    merged = Document()
    first = True
    for f in files:
        path = os.path.join(OUT_DIR, f)
        if not os.path.exists(path):
            print(f"[WARN] 跳过缺失文件: {path}")
            continue
        try:
            doc = Document(path)
        except Exception as e:
            print(f"[WARN] 无法打开，跳过: {path} -> {e}")
            continue

        if not first:
            p = merged.add_paragraph()
            p.add_run().add_break(WD_BREAK.PAGE)
        first = False

        # 复制段落（保留基础样式/粗斜体/下划线/字号/颜色）
        for para in doc.paragraphs:
            new_para = merged.add_paragraph()
            try:
                if para.style and para.style.name:
                    new_para.style = para.style
            except Exception:
                pass
            for run in para.runs:
                r = new_para.add_run(run.text)
                r.bold = run.bold
                r.italic = run.italic
                r.underline = run.underline
                r.font.name = getattr(run.font, "name", None)
                r.font.size = getattr(run.font, "size", None)
                color = getattr(run.font, "color", None)
                if color and hasattr(color, "rgb"):
                    r.font.color.rgb = color.rgb

        # 复制表格（仅复制文本）
        for table in doc.tables:
            new_table = merged.add_table(rows=len(table.rows), cols=len(table.columns))
            try:
                new_table.style = table.style
            except Exception:
                pass
            for r_idx, row in enumerate(table.rows):
                for c_idx, cell in enumerate(row.cells):
                    new_table.cell(r_idx, c_idx).text = cell.text

    merged.save(os.path.join(BASE_DIR, output))
    print("合并完成 ->", os.path.join(BASE_DIR, output))

def main():
    os.chdir(BASE_DIR)
    if not check_pandoc():
        print("[ERROR] 未检测到 pandoc。请先安装 pandoc 后重试。Mac 可使用 brew install pandoc")
        sys.exit(1)

    ensure_out_dir()

    # 逐章转换
    for md, docx in zip(CHAPTER_MD, CHAPTER_DOCX):
        md_path = os.path.join(BASE_DIR, md)
        out_docx = os.path.join(OUT_DIR, docx)
        if not os.path.exists(md_path):
            print(f"[WARN] 未找到 Markdown：{md}")
            continue
        print(f"转换 -> {md} -> {docx}")
        convert_md_to_docx(md_path, out_docx)

    # 参考文献
    ref_md_path = os.path.join(BASE_DIR, REF_MD)
    ref_docx_path = os.path.join(OUT_DIR, REF_DOCX)
    if os.path.exists(ref_md_path):
        print(f"转换参考文献 -> {REF_MD} -> {REF_DOCX}")
        convert_md_to_docx(ref_md_path, ref_docx_path)
    else:
        print(f"[WARN] 未找到参考文献 Markdown：{REF_MD}")

    # 合并
    merge_list = CHAPTER_DOCX + [REF_DOCX]
    print("开始合并文档（按章节顺序 + 参考文献）...")
    merge_docx(merge_list, MERGED_DOCX)
    print("全部完成。输出：", os.path.join(BASE_DIR, MERGED_DOCX))

if __name__ == "__main__":
    main()