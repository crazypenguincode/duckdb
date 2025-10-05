#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
高质量图片提取和导出脚本
从第1-7章文档中提取所有Mermaid图表，导出为高质量PNG格式
"""

import os
import re
import subprocess
import json
from pathlib import Path

class HighQualityImageExtractor:
    def __init__(self, base_dir="/Users/max/src/duckdb/md"):
        self.base_dir = Path(base_dir)
        self.images_dir = self.base_dir / "images"
        self.images_dir.mkdir(exist_ok=True)
        
        # 章节文件映射
        self.chapter_files = {
            1: "第一章-绪论.md",
            2: "第二章-相关背景与理论基础.md", 
            3: "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
            4: "第四章-智能缓存替换策略.md",
            5: "第五章-多策略融合的持久化存储技术.md",
            6: "第六章-实验与分析.md",
            7: "第七章-总结与展望.md"
        }
        
        self.extracted_images = []
        self.create_mermaid_config()
        
    def create_mermaid_config(self):
        """创建Mermaid配置文件以优化图片质量"""
        config_content = {
            "theme": "neutral",
            "themeVariables": {
                "primaryColor": "#ffffff",
                "primaryTextColor": "#000000", 
                "primaryBorderColor": "#333333",
                "lineColor": "#333333",
                "secondaryColor": "#f8f8f8",
                "tertiaryColor": "#f0f0f0",
                "background": "#ffffff",
                "mainBkg": "#ffffff",
                "secondBkg": "#f8f8f8",
                "tertiaryBkg": "#f0f0f0"
            },
            "flowchart": {
                "htmlLabels": True,
                "curve": "basis",
                "padding": 20
            },
            "sequence": {
                "diagramMarginX": 50,
                "diagramMarginY": 20,
                "actorMargin": 50,
                "width": 150,
                "height": 65,
                "boxMargin": 10,
                "boxTextMargin": 5,
                "noteMargin": 10,
                "messageMargin": 35
            },
            "gantt": {
                "titleTopMargin": 25,
                "barHeight": 20,
                "fontFamily": "Arial",
                "fontSize": 11,
                "gridLineStartPadding": 35,
                "bottomPadding": 25,
                "rightPadding": 75
            }
        }
        
        self.config_file = self.images_dir / "mermaid-config.json"
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(config_content, f, indent=2)
        
        print(f"Created Mermaid config file: {self.config_file}")
        
    def extract_mermaid_diagrams(self, content, chapter_num):
        """从文档内容中提取Mermaid图表"""
        diagrams = []
        
        # 匹配Mermaid代码块
        pattern = r'```mermaid\n(.*?)\n```'
        mermaid_matches = list(re.finditer(pattern, content, re.DOTALL))
        
        # 查找所有图片标题
        title_pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
        title_matches = list(re.finditer(title_pattern, content))
        
        # 为每个mermaid块找到最近的标题
        for mermaid_match in mermaid_matches:
            mermaid_pos = mermaid_match.start()
            mermaid_end = mermaid_match.end()
            diagram_content = mermaid_match.group(1).strip()
            
            # 找到最近的标题
            best_title = None
            best_distance = float('inf')
            
            for title_match in title_matches:
                title_pos = title_match.start()
                distance = abs(mermaid_end - title_pos)
                
                # 优先选择在mermaid块后面且距离最近的标题（在200字符内）
                if title_pos > mermaid_end and distance < 200 and distance < best_distance:
                    best_title = title_match
                    best_distance = distance
                # 如果没有后面的标题，选择前面最近的（在500字符内）
                elif best_title is None and title_pos < mermaid_pos and (mermaid_pos - title_pos) < 500:
                    if (mermaid_pos - title_pos) < best_distance:
                        best_title = title_match
                        best_distance = mermaid_pos - title_pos
            
            if best_title:
                fig_num = best_title.group(1)  # 如 "5.18"
                title = best_title.group(2).strip()  # 如 "机器学习模型特征重要性分布"
            else:
                # 如果找不到标题，使用默认值
                fig_num = f"{chapter_num}.0"
                title = "未命名图表"
            
            diagrams.append({
                'chapter': chapter_num,
                'fig_num': fig_num,
                'title': title,
                'content': diagram_content
            })
            
        return diagrams
    
    def save_mermaid_file(self, diagram):
        """保存Mermaid源文件"""
        filename = f"{diagram['chapter']}-图{diagram['fig_num']} {diagram['title']}.mmd"
        filepath = self.images_dir / filename
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(diagram['content'])
        
        return filepath
    
    def generate_high_quality_png(self, mmd_file):
        """生成高质量PNG文件"""
        png_file = mmd_file.with_suffix('.png')
        
        # 高质量参数配置
        high_quality_params = [
            'mmdc', '-i', str(mmd_file), '-o', str(png_file),
            '--theme', 'neutral',
            '--backgroundColor', 'white',  # 使用白色背景而不是透明，提高清晰度
            '--width', '1600',             # 更大的宽度
            '--height', '1200',            # 更大的高度
            '--scale', '3',                # 3倍缩放，大幅提高清晰度
            '--configFile', str(self.config_file)  # 使用自定义配置
        ]
        
        try:
            print(f"Generating high-quality PNG for: {mmd_file.name}")
            result = subprocess.run(high_quality_params, 
                                  capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                print(f"✓ Successfully generated: {png_file.name}")
                return png_file
            else:
                print(f"✗ Failed to generate PNG for {mmd_file.name}")
                print(f"Error: {result.stderr}")
                return self.generate_fallback_png(mmd_file)
                
        except subprocess.TimeoutExpired:
            print(f"✗ Timeout generating PNG for {mmd_file.name}")
            return self.generate_fallback_png(mmd_file)
        except FileNotFoundError:
            print("✗ mermaid-cli (mmdc) not found. Please install it:")
            print("npm install -g @mermaid-js/mermaid-cli")
            return self.create_placeholder(mmd_file)
    
    def generate_fallback_png(self, mmd_file):
        """生成标准质量PNG作为备选"""
        png_file = mmd_file.with_suffix('.png')
        
        fallback_params = [
            'mmdc', '-i', str(mmd_file), '-o', str(png_file),
            '--theme', 'neutral',
            '--backgroundColor', 'white',
            '--width', '1200',
            '--height', '800',
            '--scale', '2'
        ]
        
        try:
            print(f"Trying fallback generation for: {mmd_file.name}")
            result = subprocess.run(fallback_params, 
                                  capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print(f"✓ Generated fallback PNG: {png_file.name}")
                return png_file
            else:
                print(f"✗ Fallback generation also failed for {mmd_file.name}")
                return self.create_placeholder(mmd_file)
                
        except Exception as e:
            print(f"✗ Fallback generation error: {e}")
            return self.create_placeholder(mmd_file)
    
    def create_placeholder(self, mmd_file):
        """创建占位符文件"""
        placeholder_file = mmd_file.with_suffix('.png.placeholder')
        placeholder_content = f"""# PNG placeholder for {mmd_file.name}
# Install mermaid-cli to generate actual PNG files:
# npm install -g @mermaid-js/mermaid-cli

# Then run this script again to generate high-quality images
"""
        with open(placeholder_file, 'w', encoding='utf-8') as f:
            f.write(placeholder_content)
        return placeholder_file
    
    def process_chapter(self, chapter_num):
        """处理单个章节"""
        filename = self.chapter_files.get(chapter_num)
        if not filename:
            print(f"Chapter {chapter_num} not found")
            return []
        
        filepath = self.base_dir / filename
        if not filepath.exists():
            print(f"File not found: {filepath}")
            return []
        
        print(f"\n📖 Processing Chapter {chapter_num}: {filename}")
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {filepath}: {e}")
            return []
        
        # 提取图表
        diagrams = self.extract_mermaid_diagrams(content, chapter_num)
        print(f"Found {len(diagrams)} diagrams in Chapter {chapter_num}")
        
        processed_diagrams = []
        for i, diagram in enumerate(diagrams, 1):
            print(f"  Processing diagram {i}/{len(diagrams)}: 图{diagram['fig_num']} {diagram['title']}")
            
            # 保存mmd文件
            mmd_file = self.save_mermaid_file(diagram)
            
            # 生成高质量PNG文件
            png_file = self.generate_high_quality_png(mmd_file)
            
            diagram_info = {
                'chapter': chapter_num,
                'fig_num': diagram['fig_num'],
                'title': diagram['title'],
                'mmd_file': mmd_file.name,
                'png_file': png_file.name if png_file else None
            }
            
            processed_diagrams.append(diagram_info)
            self.extracted_images.append(diagram_info)
        
        return processed_diagrams
    
    def generate_index(self):
        """生成图片索引文件"""
        index_content = ["# 高质量图片索引\n\n"]
        index_content.append("本文档包含所有章节的高质量图表索引，包括Mermaid源文件(.mmd)和高质量PNG图片文件(.png)。\n\n")
        
        # 按章节分组
        chapters = {}
        for img in self.extracted_images:
            chapter = img['chapter']
            if chapter not in chapters:
                chapters[chapter] = []
            chapters[chapter].append(img)
        
        # 生成索引内容
        total_images = 0
        for chapter_num in sorted(chapters.keys()):
            images = chapters[chapter_num]
            index_content.append(f"## 第{chapter_num}章\n")
            index_content.append(f"共 {len(images)} 个高质量图表\n\n")
            
            for img in images:
                index_content.append(f"### 图{img['fig_num']} {img['title']}\n")
                index_content.append(f"- **Mermaid源文件**: [{img['mmd_file']}](images_hq/{img['mmd_file']})\n")
                if img['png_file'] and not img['png_file'].endswith('.placeholder'):
                    index_content.append(f"- **高质量PNG图片**: [{img['png_file']}](images_hq/{img['png_file']})\n")
                else:
                    index_content.append(f"- **PNG图片**: 生成失败或需要安装mermaid-cli\n")
                index_content.append("\n")
            
            total_images += len(images)
        
        # 添加统计信息
        index_content.insert(2, f"**总计**: {total_images} 个高质量图表\n\n")
        
        # 保存索引文件
        index_file = self.base_dir / "高质量图片索引.md"
        with open(index_file, 'w', encoding='utf-8') as f:
            f.write(''.join(index_content))
        
        print(f"\n📋 Generated index file: {index_file}")
        return index_file
    
    def run(self):
        """运行完整的提取流程"""
        print("🚀 开始提取高质量图片...")
        print(f"📁 输出目录: {self.images_dir}")
        
        # 处理所有章节
        for chapter_num in range(1, 8):
            self.process_chapter(chapter_num)
        
        # 生成索引
        self.generate_index()
        
        # 打印摘要
        successful_pngs = sum(1 for img in self.extracted_images 
                            if img['png_file'] and not img['png_file'].endswith('.placeholder'))
        
        print("\n" + "="*60)
        print("🎉 高质量图片提取完成!")
        print(f"📊 总共提取图片: {len(self.extracted_images)}")
        print(f"✅ 成功生成PNG: {successful_pngs}")
        print(f"❌ 生成失败: {len(self.extracted_images) - successful_pngs}")
        print(f"📁 文件保存位置: {self.images_dir}")
        print(f"📋 索引文件: 高质量图片索引.md")
        
        if successful_pngs < len(self.extracted_images):
            print("\n💡 提示: 如果有PNG生成失败，请确保已安装mermaid-cli:")
            print("   npm install -g @mermaid-js/mermaid-cli")
        
        print("="*60)

def main():
    """主函数"""
    extractor = HighQualityImageExtractor()
    extractor.run()

if __name__ == "__main__":
    main()