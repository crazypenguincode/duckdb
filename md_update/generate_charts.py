#!/usr/bin/env python3
"""
图表生成脚本 - 将Mermaid图表转换为PNG格式
Chart Generation Script - Convert Mermaid Charts to PNG Format

本脚本用于：
1. 提取Markdown文档中的Mermaid图表
2. 生成对应的PNG图片文件
3. 更新文档中的图片引用
"""

import os
import re
import json
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Tuple

class MermaidToPNGConverter:
    """Mermaid图表转PNG转换器"""
    
    def __init__(self, input_dir: str = "/Users/max/src/duckdb/md_update", 
                 output_dir: str = "/Users/max/src/duckdb/md_update/images"):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        # 检查mermaid-cli是否安装
        self.check_mermaid_cli()
    
    def check_mermaid_cli(self):
        """检查mermaid-cli是否安装"""
        try:
            result = subprocess.run(['mmdc', '--version'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print(f"Mermaid CLI版本: {result.stdout.strip()}")
            else:
                print("警告: mermaid-cli未安装，将生成模拟图片")
        except FileNotFoundError:
            print("警告: mermaid-cli未找到，将生成模拟图片")
    
    def extract_mermaid_charts(self, markdown_file: Path) -> List[Dict]:
        """从Markdown文件中提取Mermaid图表"""
        charts = []
        
        with open(markdown_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 匹配Mermaid代码块
        pattern = r'```mermaid\n(.*?)\n```'
        matches = re.findall(pattern, content, re.DOTALL)
        
        for i, chart_content in enumerate(matches):
            chart_info = {
                'index': i,
                'content': chart_content.strip(),
                'file_name': f"{markdown_file.stem}_chart_{i+1}.png",
                'mermaid_file': f"{markdown_file.stem}_chart_{i+1}.mmd"
            }
            charts.append(chart_info)
        
        return charts
    
    def generate_png_from_mermaid(self, chart_info: Dict) -> bool:
        """从Mermaid内容生成PNG图片"""
        mermaid_file = self.output_dir / chart_info['mermaid_file']
        png_file = self.output_dir / chart_info['file_name']
        
        # 写入Mermaid文件
        with open(mermaid_file, 'w', encoding='utf-8') as f:
            f.write(chart_info['content'])
        
        try:
            # 尝试使用mermaid-cli生成PNG
            cmd = [
                'mmdc', 
                '-i', str(mermaid_file),
                '-o', str(png_file),
                '-t', 'neutral',
                '-b', 'white',
                '--width', '800',
                '--height', '600'
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✓ 生成图片: {png_file.name}")
                return True
            else:
                print(f"✗ 生成失败: {png_file.name} - {result.stderr}")
                return self.create_placeholder_image(png_file, chart_info)
                
        except FileNotFoundError:
            # mermaid-cli不可用，创建占位图片
            return self.create_placeholder_image(png_file, chart_info)
    
    def create_placeholder_image(self, png_file: Path, chart_info: Dict) -> bool:
        """创建占位图片"""
        try:
            from PIL import Image, ImageDraw, ImageFont
            
            # 创建800x600的白色图片
            img = Image.new('RGB', (800, 600), 'white')
            draw = ImageDraw.Draw(img)
            
            # 尝试使用系统字体
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 24)
                title_font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 32)
            except:
                font = ImageFont.load_default()
                title_font = ImageFont.load_default()
            
            # 绘制标题
            title = f"图表 {chart_info['index'] + 1}"
            draw.text((50, 50), title, fill='black', font=title_font)
            
            # 绘制图表类型
            chart_type = self.detect_chart_type(chart_info['content'])
            draw.text((50, 100), f"类型: {chart_type}", fill='gray', font=font)
            
            # 绘制说明文字
            draw.text((50, 150), "这是一个图表占位符", fill='gray', font=font)
            draw.text((50, 180), "实际图表需要mermaid-cli生成", fill='gray', font=font)
            
            # 绘制边框
            draw.rectangle([25, 25, 775, 575], outline='black', width=2)
            
            # 保存图片
            img.save(png_file)
            print(f"✓ 生成占位图片: {png_file.name}")
            return True
            
        except ImportError:
            # PIL不可用，创建简单的文本文件
            with open(png_file.with_suffix('.txt'), 'w', encoding='utf-8') as f:
                f.write(f"图表占位符: {chart_info['file_name']}\n")
                f.write(f"图表类型: {self.detect_chart_type(chart_info['content'])}\n")
                f.write("需要安装PIL和mermaid-cli来生成实际图片\n")
            print(f"✓ 生成文本占位符: {png_file.with_suffix('.txt').name}")
            return False
    
    def detect_chart_type(self, content: str) -> str:
        """检测图表类型"""
        content_lower = content.lower()
        
        if 'graph' in content_lower:
            return "流程图"
        elif 'pie' in content_lower:
            return "饼图"
        elif 'xychart' in content_lower:
            return "柱状图/折线图"
        elif 'scatter' in content_lower:
            return "散点图"
        elif 'sequencediagram' in content_lower:
            return "序列图"
        elif 'classDiagram' in content_lower:
            return "类图"
        else:
            return "未知类型"
    
    def update_markdown_with_images(self, markdown_file: Path, charts: List[Dict]):
        """更新Markdown文件，添加PNG图片引用"""
        with open(markdown_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 替换Mermaid代码块为图片引用
        pattern = r'```mermaid\n(.*?)\n```'
        matches = list(re.finditer(pattern, content, re.DOTALL))
        
        # 从后往前替换，避免位置偏移
        for i, match in enumerate(reversed(matches)):
            chart_index = len(matches) - 1 - i
            if chart_index < len(charts):
                chart_info = charts[chart_index]
                img_path = f"images/{chart_info['file_name']}"
                
                # 创建图片引用
                img_reference = f"![{chart_info['file_name']}]({img_path})"
                
                # 替换内容
                start, end = match.span()
                content = content[:start] + img_reference + content[end:]
        
        # 写回文件
        backup_file = markdown_file.with_suffix('.md.backup')
        markdown_file.rename(backup_file)
        
        with open(markdown_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✓ 更新文档: {markdown_file.name} (备份: {backup_file.name})")
    
    def process_all_markdown_files(self):
        """处理所有Markdown文件"""
        markdown_files = list(self.input_dir.glob("第*章-*.md"))
        
        print(f"找到 {len(markdown_files)} 个Markdown文件")
        
        total_charts = 0
        successful_charts = 0
        
        for md_file in sorted(markdown_files):
            print(f"\n处理文件: {md_file.name}")
            
            # 提取图表
            charts = self.extract_mermaid_charts(md_file)
            total_charts += len(charts)
            
            if not charts:
                print("  未找到Mermaid图表")
                continue
            
            print(f"  找到 {len(charts)} 个图表")
            
            # 生成PNG图片
            for chart_info in charts:
                if self.generate_png_from_mermaid(chart_info):
                    successful_charts += 1
            
            # 更新Markdown文件
            # self.update_markdown_with_images(md_file, charts)
        
        print(f"\n总结:")
        print(f"  总图表数: {total_charts}")
        print(f"  成功生成: {successful_charts}")
        print(f"  成功率: {successful_charts/total_charts*100:.1f}%" if total_charts > 0 else "  成功率: 0%")
    
    def generate_image_index(self):
        """生成图片索引文件"""
        index_file = self.output_dir / "图片索引.md"
        
        png_files = list(self.output_dir.glob("*.png"))
        txt_files = list(self.output_dir.glob("*.txt"))
        
        with open(index_file, 'w', encoding='utf-8') as f:
            f.write("# 图片索引\n\n")
            f.write(f"生成时间: {os.popen('date').read().strip()}\n\n")
            
            if png_files:
                f.write("## PNG图片文件\n\n")
                for png_file in sorted(png_files):
                    f.write(f"- ![{png_file.name}]({png_file.name})\n")
                f.write("\n")
            
            if txt_files:
                f.write("## 文本占位符\n\n")
                for txt_file in sorted(txt_files):
                    f.write(f"- [{txt_file.name}]({txt_file.name})\n")
                f.write("\n")
            
            f.write("## 安装说明\n\n")
            f.write("要生成实际的PNG图片，请安装以下工具：\n\n")
            f.write("```bash\n")
            f.write("# 安装Node.js和mermaid-cli\n")
            f.write("npm install -g @mermaid-js/mermaid-cli\n\n")
            f.write("# 安装Python PIL库\n")
            f.write("pip install Pillow\n")
            f.write("```\n")
        
        print(f"✓ 生成图片索引: {index_file.name}")

def main():
    """主函数"""
    print("开始图表转换...")
    
    converter = MermaidToPNGConverter()
    
    try:
        # 处理所有Markdown文件
        converter.process_all_markdown_files()
        
        # 生成图片索引
        converter.generate_image_index()
        
        print("\n图表转换完成!")
        
    except Exception as e:
        print(f"转换过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())