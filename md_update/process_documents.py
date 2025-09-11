#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
文档处理脚本：将代码转换为伪代码，提取并生成图片
"""

import os
import re
import json
from pathlib import Path
import subprocess

class DocumentProcessor:
    def __init__(self, base_dir):
        self.base_dir = Path(base_dir)
        self.images_dir = self.base_dir / "images"
        self.images_dir.mkdir(exist_ok=True)
        self.image_index = []
        
    def convert_cpp_to_pseudocode(self, code_block):
        """将C++代码转换为伪代码"""
        lines = code_block.split('\n')
        pseudocode_lines = []
        
        for line in lines:
            line = line.strip()
            if not line or line.startswith('//') or line.startswith('/*'):
                continue
                
            # 转换常见的C++语法为伪代码
            line = re.sub(r'std::', '', line)
            line = re.sub(r'unique_ptr<([^>]+)>', r'UniquePointer<\1>', line)
            line = re.sub(r'shared_ptr<([^>]+)>', r'SharedPointer<\1>', line)
            line = re.sub(r'vector<([^>]+)>', r'Array<\1>', line)
            line = re.sub(r'unordered_map<([^>]+)>', r'HashMap<\1>', line)
            line = re.sub(r'string', 'String', line)
            line = re.sub(r'size_t', 'Integer', line)
            line = re.sub(r'uint64_t', 'UInt64', line)
            line = re.sub(r'uint32_t', 'UInt32', line)
            line = re.sub(r'double', 'Double', line)
            line = re.sub(r'bool', 'Boolean', line)
            line = re.sub(r'void', 'Void', line)
            line = re.sub(r'const', 'CONST', line)
            line = re.sub(r'auto', 'AUTO', line)
            line = re.sub(r'->', '→', line)
            line = re.sub(r'::', '.', line)
            line = re.sub(r'nullptr', 'NULL', line)
            
            # 简化复杂的模板和类型声明
            if 'template' in line.lower():
                line = re.sub(r'template<.*?>', 'TEMPLATE', line)
            
            # 移除复杂的类型修饰符
            line = re.sub(r'static constexpr', 'STATIC CONST', line)
            line = re.sub(r'std::atomic<([^>]+)>', r'Atomic<\1>', line)
            line = re.sub(r'std::chrono::[^:]+::[^:]+', 'TimePoint', line)
            
            if line:
                pseudocode_lines.append(line)
        
        return '\n'.join(pseudocode_lines)
    
    def extract_mermaid_diagrams(self, content, chapter_num):
        """提取Mermaid图表"""
        mermaid_pattern = r'```mermaid\n(.*?)\n```'
        diagrams = re.findall(mermaid_pattern, content, re.DOTALL)
        
        diagram_info = []
        for i, diagram in enumerate(diagrams):
            # 提取图表标题
            title_match = re.search(r'title\s+"([^"]+)"', diagram)
            if title_match:
                title = title_match.group(1)
            else:
                # 尝试从图表类型推断标题
                if 'graph' in diagram:
                    title = "流程图"
                elif 'pie' in diagram:
                    title = "饼图"
                elif 'xychart' in diagram:
                    title = "柱状图"
                elif 'sequenceDiagram' in diagram:
                    title = "序列图"
                else:
                    title = f"图表{i+1}"
            
            # 生成文件名
            filename_base = f"{chapter_num}.{i+1}_{title.replace(' ', '_').replace('/', '_')}"
            mmd_filename = f"{filename_base}.mmd"
            png_filename = f"{filename_base}.png"
            
            # 保存mermaid源文件
            mmd_path = self.images_dir / mmd_filename
            with open(mmd_path, 'w', encoding='utf-8') as f:
                f.write(diagram)
            
            diagram_info.append({
                'chapter': chapter_num,
                'index': i + 1,
                'title': title,
                'mmd_file': mmd_filename,
                'png_file': png_filename,
                'content': diagram
            })
        
        return diagram_info
    
    def generate_png_from_mermaid(self, mmd_file, png_file):
        """从Mermaid文件生成PNG图片"""
        try:
            # 使用mermaid-cli生成PNG
            cmd = f"mmdc -i {mmd_file} -o {png_file} -t dark -b transparent"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                return True
            else:
                print(f"生成PNG失败: {result.stderr}")
                return False
        except Exception as e:
            print(f"生成PNG时出错: {e}")
            return False
    
    def process_code_blocks(self, content):
        """处理代码块，将大段代码转换为伪代码"""
        def replace_code_block(match):
            language = match.group(1) if match.group(1) else ''
            code = match.group(2)
            
            # 如果代码块超过20行，转换为伪代码
            if len(code.split('\n')) > 20:
                if language.lower() in ['cpp', 'c++', 'c']:
                    pseudocode = self.convert_cpp_to_pseudocode(code)
                    return f"```pseudocode\n{pseudocode}\n```"
                elif language.lower() in ['python', 'py']:
                    # Python代码简化处理
                    lines = code.split('\n')
                    simplified_lines = []
                    for line in lines:
                        if line.strip() and not line.strip().startswith('#'):
                            # 简化Python语法
                            line = re.sub(r'def\s+(\w+)', r'FUNCTION \1', line)
                            line = re.sub(r'class\s+(\w+)', r'CLASS \1', line)
                            line = re.sub(r'if\s+', 'IF ', line)
                            line = re.sub(r'else:', 'ELSE:', line)
                            line = re.sub(r'elif\s+', 'ELIF ', line)
                            line = re.sub(r'for\s+', 'FOR ', line)
                            line = re.sub(r'while\s+', 'WHILE ', line)
                            line = re.sub(r'return\s+', 'RETURN ', line)
                            simplified_lines.append(line)
                    
                    pseudocode = '\n'.join(simplified_lines)
                    return f"```pseudocode\n{pseudocode}\n```"
                else:
                    # 其他语言的通用处理
                    lines = code.split('\n')
                    if len(lines) > 30:
                        # 保留前10行和后5行，中间用省略号
                        simplified = lines[:10] + ['    // ... 省略中间代码 ...'] + lines[-5:]
                        return f"```{language}\n" + '\n'.join(simplified) + "\n```"
            
            return match.group(0)  # 返回原始代码块
        
        # 匹配代码块的正则表达式
        code_block_pattern = r'```(\w+)?\n(.*?)\n```'
        return re.sub(code_block_pattern, replace_code_block, content, flags=re.DOTALL)
    
    def process_document(self, file_path):
        """处理单个文档"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取章节号
        chapter_match = re.search(r'第([一二三四五六七八九十\d]+)章', content)
        if chapter_match:
            chapter_num = chapter_match.group(1)
            # 转换中文数字为阿拉伯数字
            chinese_to_arabic = {
                '一': '1', '二': '2', '三': '3', '四': '4', '五': '5',
                '六': '6', '七': '7', '八': '8', '九': '9', '十': '10'
            }
            if chapter_num in chinese_to_arabic:
                chapter_num = chinese_to_arabic[chapter_num]
        else:
            chapter_num = os.path.basename(file_path).split('-')[0] if '-' in os.path.basename(file_path) else '0'
        
        # 提取Mermaid图表
        diagrams = self.extract_mermaid_diagrams(content, chapter_num)
        self.image_index.extend(diagrams)
        
        # 处理代码块
        processed_content = self.process_code_blocks(content)
        
        # 保存处理后的文档
        output_path = file_path.parent / f"{file_path.stem}_processed{file_path.suffix}"
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(processed_content)
        
        return len(diagrams)
    
    def generate_image_index(self):
        """生成图片索引文件"""
        index_content = "# 图片索引\n\n"
        index_content += "本文档包含的所有图表及其文件信息：\n\n"
        
        # 按章节分组
        chapters = {}
        for img in self.image_index:
            chapter = img['chapter']
            if chapter not in chapters:
                chapters[chapter] = []
            chapters[chapter].append(img)
        
        for chapter in sorted(chapters.keys(), key=lambda x: int(x) if x.isdigit() else 0):
            index_content += f"## 第{chapter}章\n\n"
            index_content += "| 图号 | 标题 | Mermaid文件 | PNG文件 |\n"
            index_content += "|------|------|-------------|----------|\n"
            
            for img in chapters[chapter]:
                index_content += f"| 图{chapter}.{img['index']} | {img['title']} | [{img['mmd_file']}](images/{img['mmd_file']}) | [{img['png_file']}](images/{img['png_file']}) |\n"
            
            index_content += "\n"
        
        # 保存索引文件
        index_path = self.base_dir / "图片索引.md"
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index_content)
        
        return index_path
    
    def generate_all_pngs(self):
        """生成所有PNG图片"""
        success_count = 0
        total_count = len(self.image_index)
        
        for img in self.image_index:
            mmd_path = self.images_dir / img['mmd_file']
            png_path = self.images_dir / img['png_file']
            
            if self.generate_png_from_mermaid(mmd_path, png_path):
                success_count += 1
                print(f"✓ 生成成功: {img['png_file']}")
            else:
                print(f"✗ 生成失败: {img['png_file']}")
        
        print(f"\nPNG生成完成: {success_count}/{total_count}")
        return success_count, total_count

def main():
    base_dir = "/Users/max/src/duckdb/md_update"
    processor = DocumentProcessor(base_dir)
    
    # 处理所有章节文档
    chapter_files = [
        "第一章-绪论.md",
        "第二章-相关背景与理论基础.md", 
        "第三章-动态缓存管理.md",
        "第四章-动态缓存更新技术与持久化技术.md",
        "第五章-实验与分析.md",
        "第六章-总结与展望.md"
    ]
    
    total_diagrams = 0
    for filename in chapter_files:
        file_path = Path(base_dir) / filename
        if file_path.exists():
            print(f"处理文档: {filename}")
            diagram_count = processor.process_document(file_path)
            total_diagrams += diagram_count
            print(f"  提取图表: {diagram_count}个")
        else:
            print(f"文件不存在: {filename}")
    
    print(f"\n总共提取图表: {total_diagrams}个")
    
    # 生成图片索引
    index_path = processor.generate_image_index()
    print(f"生成图片索引: {index_path}")
    
    # 生成PNG图片（需要安装mermaid-cli）
    print("\n开始生成PNG图片...")
    success, total = processor.generate_all_pngs()
    
    print(f"\n处理完成!")
    print(f"- 处理文档: {len(chapter_files)}个")
    print(f"- 提取图表: {total_diagrams}个") 
    print(f"- 生成PNG: {success}/{total}")
    print(f"- 图片目录: {processor.images_dir}")
    print(f"- 索引文件: {index_path}")

if __name__ == "__main__":
    main()