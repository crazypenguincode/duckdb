#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
图片管理模块
处理图片复制和查找
"""

import shutil
from pathlib import Path

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"
OUTPUT_IMAGES_DIR = BASE_DIR / "output_images"

def ensure_output_images_dir():
    """确保输出图片目录存在"""
    OUTPUT_IMAGES_DIR.mkdir(exist_ok=True)
    print(f"📁 输出图片目录: {OUTPUT_IMAGES_DIR}")

def copy_images_to_output():
    """复制图片到输出目录，支持 png 和 mmd 格式"""
    if not IMAGES_DIR.exists():
        print("⚠️  源图片目录不存在")
        return
    
    ensure_output_images_dir()
    
    # 复制所有 PNG 文件
    png_files = list(IMAGES_DIR.glob("*.png"))
    for png_file in png_files:
        dest_path = OUTPUT_IMAGES_DIR / png_file.name
        shutil.copy2(png_file, dest_path)
        print(f"📋 复制图片: {png_file.name}")
    
    # 查找并复制 mermaid 文件（如果存在）
    mmd_files = list(IMAGES_DIR.glob("*.mmd")) + list(IMAGES_DIR.glob("*.mermaid"))
    for mmd_file in mmd_files:
        dest_path = OUTPUT_IMAGES_DIR / mmd_file.name
        shutil.copy2(mmd_file, dest_path)
        print(f"📋 复制 Mermaid 文件: {mmd_file.name}")
    
    print(f"✅ 图片复制完成，共 {len(png_files)} 个 PNG 文件，{len(mmd_files)} 个 Mermaid 文件")

def get_image_for_figure(fig_num):
    """根据图号获取对应的图片文件"""
    # 首先在输出目录查找
    pattern = f"{fig_num}_*.png"
    matches = list(OUTPUT_IMAGES_DIR.glob(pattern))
    if matches:
        return matches[0]
    
    # 如果输出目录没有，在原始目录查找
    matches = list(IMAGES_DIR.glob(pattern))
    if matches:
        return matches[0]
    
    return None