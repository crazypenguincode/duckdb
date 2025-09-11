#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
测试图片转换问题
"""

import os
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).parent.absolute()
IMAGES_DIR = BASE_DIR / "images"
TEST_DIR = BASE_DIR / "_test_conversion"

def create_test_markdown():
    """创建测试用的 Markdown 文件"""
    TEST_DIR.mkdir(exist_ok=True)
    
    # 测试不同的图片引用方式
    test_content = """# 图片转换测试

## 方式1：绝对路径
![测试图片1](/Users/max/src/duckdb/md_update/images/1.1_研究背景与技术发展趋势.png)

## 方式2：相对路径
![测试图片2](../images/1.1_研究背景与技术发展趋势.png)

## 方式3：当前目录相对路径
![测试图片3](./images/1.1_研究背景与技术发展趋势.png)

## 方式4：复制到同目录
![测试图片4](test_image.png)

## 数学公式测试
这是内联公式：$E = mc^2$

这是块级公式：
$$\\frac{d}{dx}f(x) = \\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}$$
"""
    
    test_md = TEST_DIR / "test.md"
    with open(test_md, 'w', encoding='utf-8') as f:
        f.write(test_content)
    
    # 复制一张测试图片到同目录
    test_img_src = IMAGES_DIR / "1.1_研究背景与技术发展趋势.png"
    test_img_dst = TEST_DIR / "test_image.png"
    if test_img_src.exists():
        import shutil
        shutil.copy2(test_img_src, test_img_dst)
        print(f"复制测试图片: {test_img_dst}")
    
    # 创建 images 子目录并复制图片
    test_images_dir = TEST_DIR / "images"
    test_images_dir.mkdir(exist_ok=True)
    if test_img_src.exists():
        import shutil
        shutil.copy2(test_img_src, test_images_dir / "1.1_研究背景与技术发展趋势.png")
        print(f"复制到子目录: {test_images_dir}")
    
    return test_md

def test_pandoc_conversions(md_path):
    """测试不同的 pandoc 转换参数"""
    
    conversion_tests = [
        {
            "name": "基础转换",
            "cmd": ["pandoc", str(md_path), "-o", str(TEST_DIR / "test_basic.docx")],
            "output": TEST_DIR / "test_basic.docx"
        },
        {
            "name": "提取媒体",
            "cmd": ["pandoc", str(md_path), "-o", str(TEST_DIR / "test_extract.docx"), "--extract-media", str(TEST_DIR / "media")],
            "output": TEST_DIR / "test_extract.docx"
        },
        {
            "name": "资源路径",
            "cmd": ["pandoc", str(md_path), "-o", str(TEST_DIR / "test_resource.docx"), "--resource-path", str(TEST_DIR)],
            "output": TEST_DIR / "test_resource.docx"
        },
        {
            "name": "数据目录",
            "cmd": ["pandoc", str(md_path), "-o", str(TEST_DIR / "test_data.docx"), "--data-dir", str(BASE_DIR)],
            "output": TEST_DIR / "test_data.docx"
        }
    ]
    
    for test in conversion_tests:
        print(f"\n=== 测试: {test['name']} ===")
        print(f"命令: {' '.join(test['cmd'])}")
        
        # 删除之前的输出
        if test['output'].exists():
            test['output'].unlink()
        
        result = subprocess.run(test['cmd'], capture_output=True, text=True, cwd=TEST_DIR)
        
        print(f"返回码: {result.returncode}")
        if result.stdout:
            print(f"输出: {result.stdout}")
        if result.stderr:
            print(f"错误: {result.stderr}")
        
        if test['output'].exists():
            size = test['output'].stat().st_size
            print(f"✅ 文件生成成功，大小: {size} 字节")
            
            # 验证图片
            try:
                from docx import Document
                doc = Document(str(test['output']))
                
                image_count = 0
                for rel in doc.part.rels.values():
                    if "image" in rel.target_ref:
                        image_count += 1
                
                print(f"嵌入图片数量: {image_count}")
                
            except Exception as e:
                print(f"验证失败: {e}")
        else:
            print(f"❌ 文件生成失败")

def main():
    print("🧪 图片转换测试")
    print(f"工作目录: {BASE_DIR}")
    print(f"图片目录: {IMAGES_DIR}")
    print(f"测试目录: {TEST_DIR}")
    
    # 创建测试文件
    test_md = create_test_markdown()
    print(f"测试文件: {test_md}")
    
    # 测试转换
    test_pandoc_conversions(test_md)

if __name__ == "__main__":
    main()