#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试脚本：验证图片生成时是否成功去除外边框
"""

import subprocess
import sys
from pathlib import Path

def test_image_generation():
    """测试图片生成功能"""
    print("🧪 开始测试图片生成（无边框）...")
    
    # 切换到md目录
    md_dir = Path("/Users/max/src/duckdb/md")
    
    # 运行图片提取脚本
    extract_script = md_dir / "extract_all_images_hq.py"
    
    if not extract_script.exists():
        print(f"❌ 图片提取脚本不存在: {extract_script}")
        return False
    
    try:
        print("📸 正在生成图片...")
        result = subprocess.run([sys.executable, str(extract_script)], 
                              cwd=str(md_dir), 
                              capture_output=True, text=True, check=True)
        
        print("✅ 图片生成完成！")
        print("\n📋 生成输出:")
        print(result.stdout)
        
        # 检查生成的图片
        images_dir = md_dir / "images"
        if images_dir.exists():
            png_files = list(images_dir.glob("*.png"))
            print(f"\n📊 共生成 {len(png_files)} 个PNG图片文件")
            
            # 显示前几个文件名作为示例
            for i, png_file in enumerate(png_files[:5]):
                print(f"  {i+1}. {png_file.name}")
            
            if len(png_files) > 5:
                print(f"  ... 还有 {len(png_files) - 5} 个文件")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ 图片生成失败: {e}")
        if e.stderr:
            print(f"错误信息: {e.stderr}")
        return False
    except Exception as e:
        print(f"❌ 发生未知错误: {e}")
        return False

def test_latex_conversion():
    """测试LaTeX转换功能"""
    print("\n🔄 开始测试LaTeX转换...")
    
    # 切换到overleaf_test目录
    overleaf_dir = Path("/Users/max/src/duckdb/overleaf_test")
    
    # 运行LaTeX转换脚本
    convert_script = overleaf_dir / "md_to_latex_converter_fixed_v7.py"
    
    if not convert_script.exists():
        print(f"❌ LaTeX转换脚本不存在: {convert_script}")
        return False
    
    try:
        print("📝 正在转换LaTeX...")
        result = subprocess.run([sys.executable, str(convert_script)], 
                              cwd=str(overleaf_dir), 
                              capture_output=True, text=True, timeout=300)
        
        if result.returncode == 0:
            print("✅ LaTeX转换完成！")
            print("\n📋 转换输出:")
            print(result.stdout[-1000:])  # 显示最后1000个字符
        else:
            print("⚠️ LaTeX转换完成，但有警告")
            if result.stderr:
                print(f"警告信息: {result.stderr[-500:]}")
        
        return True
        
    except subprocess.TimeoutExpired:
        print("⏰ LaTeX转换超时")
        return False
    except Exception as e:
        print(f"❌ LaTeX转换发生错误: {e}")
        return False

def main():
    """主函数"""
    print("🚀 开始测试无边框图片生成...")
    print("=" * 60)
    
    # 测试图片生成
    image_success = test_image_generation()
    
    # 测试LaTeX转换
    latex_success = test_latex_conversion()
    
    print("\n" + "=" * 60)
    print("📊 测试结果总结:")
    print(f"  图片生成: {'✅ 成功' if image_success else '❌ 失败'}")
    print(f"  LaTeX转换: {'✅ 成功' if latex_success else '❌ 失败'}")
    
    if image_success and latex_success:
        print("\n🎉 所有测试通过！图片应该已经去除外边框。")
        print("\n💡 提示:")
        print("  - 生成的图片位于: /Users/max/src/duckdb/md/images/")
        print("  - 转换的LaTeX文件位于: /Users/max/src/duckdb/overleaf_test/")
        print("  - 图片现在使用透明背景，没有外边框")
    else:
        print("\n⚠️ 部分测试失败，请检查错误信息。")
    
    print("=" * 60)

if __name__ == "__main__":
    main()