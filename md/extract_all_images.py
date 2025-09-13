#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
图片提取和导出脚本
从第1-6章文档中提取所有Mermaid图表，导出为mmd和png格式
"""

import os
import re
import subprocess
import json
from pathlib import Path

class ImageExtractor:
    def __init__(self, base_dir="/Users/max/src/duckdb/md"):
        self.base_dir = Path(base_dir)
        self.images_dir = self.base_dir / "images"
        self.images_dir.mkdir(exist_ok=True)
        
        # 章节文件映射
        self.chapter_files = {
            1: "第一章-绪论.md",
            2: "第二章-相关背景与理论基础.md", 
            3: "第三章-动态缓存管理.md",
            4: "第四章-动态缓存更新技术与持久化技术.md",
            5: "第五章-实验与分析.md",
            6: "第六章-总结与展望.md"
        }
        
        self.extracted_images = []
        
    def extract_mermaid_diagrams(self, content, chapter_num):
        """从文档内容中提取Mermaid图表"""
        diagrams = []
        
        # 匹配Mermaid代码块和图片标题
        pattern = r'```mermaid\n(.*?)\n```'
        matches = re.findall(pattern, content, re.DOTALL)
        
        # 查找图片标题（通常在图表前后）
        title_pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
        titles = re.findall(title_pattern, content)
        
        # 创建标题映射
        title_map = {}
        for fig_num, title in titles:
            title_map[fig_num] = title.strip()
        
        # 处理每个图表
        for i, diagram in enumerate(matches, 1):
            # 尝试找到对应的标题
            fig_num = f"{chapter_num}.{i}"
            title = title_map.get(fig_num, f"图表{i}")
            
            # 清理标题，移除特殊字符
            clean_title = re.sub(r'[^\w\u4e00-\u9fff\s-]', '', title)
            clean_title = re.sub(r'\s+', '_', clean_title.strip())
            
            diagrams.append({
                'chapter': chapter_num,
                'number': i,
                'fig_num': fig_num,
                'title': title,
                'clean_title': clean_title,
                'content': diagram.strip()
            })
            
        return diagrams
    
    def save_mermaid_file(self, diagram):
        """保存Mermaid源文件"""
        filename = f"{diagram['fig_num']}_{diagram['clean_title']}.mmd"
        filepath = self.images_dir / filename
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(diagram['content'])
        
        return filepath
    
    def generate_png(self, mmd_file):
        """使用mermaid-cli生成PNG文件"""
        png_file = mmd_file.with_suffix('.png')
        
        try:
            # 尝试使用mmdc命令
            result = subprocess.run([
                'mmdc', '-i', str(mmd_file), '-o', str(png_file),
                '--theme', 'default', '--backgroundColor', 'white'
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                return png_file
            else:
                print(f"Warning: Failed to generate PNG for {mmd_file.name}: {result.stderr}")
                return None
                
        except (subprocess.TimeoutExpired, FileNotFoundError) as e:
            print(f"Warning: mermaid-cli not available or timeout for {mmd_file.name}: {e}")
            # 创建一个占位符PNG文件
            placeholder_content = f"# PNG placeholder for {mmd_file.name}\n# Install mermaid-cli to generate actual PNG files\n# npm install -g @mermaid-js/mermaid-cli"
            placeholder_file = png_file.with_suffix('.png.placeholder')
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
        
        print(f"Processing Chapter {chapter_num}: {filename}")
        
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
        for diagram in diagrams:
            # 保存mmd文件
            mmd_file = self.save_mermaid_file(diagram)
            
            # 生成PNG文件
            png_file = self.generate_png(mmd_file)
            
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
        index_content = ["# 图片索引\n"]
        index_content.append("本文档包含所有章节的图表索引，包括Mermaid源文件(.mmd)和PNG图片文件(.png)。\n")
        
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
            index_content.append(f"共 {len(images)} 个图表\n")
            
            for img in images:
                index_content.append(f"### 图{img['fig_num']} {img['title']}\n")
                index_content.append(f"- **Mermaid源文件**: [{img['mmd_file']}](images/{img['mmd_file']})\n")
                if img['png_file']:
                    index_content.append(f"- **PNG图片**: [{img['png_file']}](images/{img['png_file']})\n")
                else:
                    index_content.append(f"- **PNG图片**: 生成失败\n")
                index_content.append("\n")
            
            total_images += len(images)
        
        # 添加统计信息
        index_content.insert(2, f"**总计**: {total_images} 个图表\n\n")
        
        # 添加文件列表
        index_content.append("## 文件列表\n")
        index_content.append("### Mermaid源文件 (.mmd)\n")
        for img in self.extracted_images:
            index_content.append(f"- {img['mmd_file']}\n")
        
        index_content.append("\n### PNG图片文件 (.png)\n")
        for img in self.extracted_images:
            if img['png_file']:
                index_content.append(f"- {img['png_file']}\n")
        
        # 保存索引文件
        index_file = self.base_dir / "图片索引.md"
        with open(index_file, 'w', encoding='utf-8') as f:
            f.write(''.join(index_content))
        
        print(f"Generated index file: {index_file}")
        return index_file
    
    def generate_summary_report(self):
        """生成处理摘要报告"""
        report = {
            'total_chapters': len(self.chapter_files),
            'total_images': len(self.extracted_images),
            'chapters_processed': {},
            'files_generated': {
                'mmd_files': [],
                'png_files': []
            }
        }
        
        # 按章节统计
        for img in self.extracted_images:
            chapter = img['chapter']
            if chapter not in report['chapters_processed']:
                report['chapters_processed'][chapter] = 0
            report['chapters_processed'][chapter] += 1
            
            report['files_generated']['mmd_files'].append(img['mmd_file'])
            if img['png_file']:
                report['files_generated']['png_files'].append(img['png_file'])
        
        # 保存报告
        report_file = self.base_dir / "图片提取报告.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def run(self):
        """运行完整的提取流程"""
        print("开始提取图片...")
        print(f"输出目录: {self.images_dir}")
        
        # 处理所有章节
        for chapter_num in range(1, 7):
            self.process_chapter(chapter_num)
        
        # 生成索引
        self.generate_index()
        
        # 生成报告
        report = self.generate_summary_report()
        
        # 打印摘要
        print("\n" + "="*50)
        print("图片提取完成!")
        print(f"总共处理章节: {report['total_chapters']}")
        print(f"总共提取图片: {report['total_images']}")
        print(f"生成mmd文件: {len(report['files_generated']['mmd_files'])}")
        print(f"生成png文件: {len(report['files_generated']['png_files'])}")
        
        print("\n各章节图片数量:")
        for chapter, count in sorted(report['chapters_processed'].items()):
            print(f"  第{chapter}章: {count}个图片")
        
        print(f"\n文件保存位置: {self.images_dir}")
        print("索引文件: 图片索引.md")
        print("="*50)

def main():
    """主函数"""
    extractor = ImageExtractor()
    extractor.run()

if __name__ == "__main__":
    main()