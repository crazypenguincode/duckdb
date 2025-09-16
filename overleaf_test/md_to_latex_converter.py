#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markdown到LaTeX转换脚本
将md目录下的第一章到第六章的.md文件转换为overleaf/chapters/目录下对应的chapter-1到6.tex文件
"""

import os
import re
import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class MarkdownToLatexConverter:
    def __init__(self, base_dir="/Users/max/src/duckdb"):
        self.base_dir = Path(base_dir)
        self.md_dir = self.base_dir / "md"
        self.overleaf_dir = self.base_dir / "overleaf"
        self.chapters_dir = self.overleaf_dir / "chapters"
        self.images_dir = self.overleaf_dir / "images"
        self.references_dir = self.overleaf_dir / "references"
        
        # 创建必要的目录
        self.chapters_dir.mkdir(parents=True, exist_ok=True)
        self.images_dir.mkdir(parents=True, exist_ok=True)
        self.references_dir.mkdir(parents=True, exist_ok=True)
        
        # 章节文件映射
        self.chapter_files = {
            1: "第一章-绪论.md",
            2: "第二章-相关背景与理论基础.md", 
            3: "第三章-动态缓存管理.md",
            4: "第四章-动态缓存更新技术与持久化技术.md",
            5: "第五章-实验与分析.md",
            6: "第六章-总结与展望.md"
        }
        
        # 图片计数器
        self.figure_counter = {}
        self.table_counter = {}
        
        # 参考文献映射
        self.reference_mapping = {}
        
    def extract_and_convert_images(self):
        """提取并转换Mermaid图片为PNG"""
        print("正在提取和转换图片...")
        
        # 运行图片提取脚本
        extract_script = self.md_dir / "extract_all_images.py"
        if extract_script.exists():
            try:
                subprocess.run(["python3", str(extract_script)], 
                             cwd=str(self.md_dir), check=True)
                print("图片提取完成")
            except subprocess.CalledProcessError as e:
                print(f"图片提取失败: {e}")
        
        # 复制图片到overleaf/images目录
        md_images_dir = self.md_dir / "images"
        if md_images_dir.exists():
            for img_file in md_images_dir.glob("*.png"):
                shutil.copy2(img_file, self.images_dir)
                print(f"复制图片: {img_file.name}")
    
    def process_references(self):
        """处理参考文献，生成paper-manual.bib文件"""
        print("正在处理参考文献...")
        
        ref_file = self.md_dir / "统一参考文献列表.md"
        if not ref_file.exists():
            print(f"参考文献文件不存在: {ref_file}")
            return
        
        with open(ref_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取参考文献条目
        bib_content = []
        
        # 只处理"按顺序编号的完整参考文献"部分
        # 找到这个部分的开始和结束
        start_marker = "## 按顺序编号的完整参考文献"
        end_marker = "## 按章节分组的参考文献映射"
        
        start_pos = content.find(start_marker)
        end_pos = content.find(end_marker)
        
        if start_pos == -1:
            print("未找到参考文献部分")
            return
        
        if end_pos == -1:
            end_pos = len(content)
        
        ref_section = content[start_pos:end_pos]
        # 使用更简单的正则表达式匹配参考文献
        lines = ref_section.split('\n')
        for line in lines:
            line = line.strip()
            # 匹配 [数字] 开头的行
            match = re.match(r'\[(\d+)\]\s+(.+)', line)
            if match:
                ref_num, ref_text = match.groups()
                ref_text = ref_text.strip()
                
                # 过滤掉映射信息和其他非参考文献内容
                if (ref_text and 
                    not ref_text.startswith('→') and 
                    not ref_text.startswith('**') and 
                    not '→' in ref_text and
                    len(ref_text) > 20 and
                    ('.' in ref_text or '[' in ref_text)):
                    
                    # 清理引用文本
                    ref_text = re.sub(r'\n+', ' ', ref_text)
                    ref_text = re.sub(r'\s+', ' ', ref_text)
                    
                    # 解析参考文献信息
                    bib_entry = self.parse_reference_to_bibitem(ref_num, ref_text)
                    bib_content.append(bib_entry)
                    
                    # 建立映射关系
                    self.reference_mapping[f"[{ref_num}]"] = f"\\cite{{c{ref_num}}}"
        
        # 写入bib文件
        bib_file = self.references_dir / "paper-manual.bib"
        with open(bib_file, 'w', encoding='utf-8') as f:
            f.writelines(bib_content)
        
        print(f"生成参考文献文件: {bib_file}")
        print(f"共处理 {len(bib_content)} 条参考文献")
    
    def convert_headers(self, content: str) -> str:
        """转换标题格式，去除序号"""
        def remove_numbering(match):
            title = match.group(1).strip()
            # 去除各种格式的序号
            # 1. 去除"第X章"格式
            title = re.sub(r'^第[一二三四五六七八九十\d]+章\s*', '', title)
            # 2. 去除数字序号如 1.1、2.1.1、6.1.2.1等
            title = re.sub(r'^\d+(\.\d+)*\s+', '', title)
            # 3. 去除"第X节"格式
            title = re.sub(r'^第[一二三四五六七八九十\d]+节\s*', '', title)
            # 4. 去除中文序号如"一、"、"二、"等
            title = re.sub(r'^[一二三四五六七八九十]+[、\.]\s*', '', title)
            # 5. 去除字母序号如"A."、"B."等
            title = re.sub(r'^[A-Za-z]+\.\s*', '', title)
            # 6. 去除括号序号如"(1)"、"（一）"等
            title = re.sub(r'^[\(（]\d+[\)）]\s*', '', title)
            title = re.sub(r'^[\(（][一二三四五六七八九十]+[\)）]\s*', '', title)
            
            return title.strip()
        
        # # -> \chapter{}
        content = re.sub(r'^# (.+)$', lambda m: f'\\chapter{{{remove_numbering(m)}}}', content, flags=re.MULTILINE)
        
        # ## -> \section{}
        content = re.sub(r'^## (.+)$', lambda m: f'\\section{{{remove_numbering(m)}}}', content, flags=re.MULTILINE)
        
        # ### -> \subsection{}
        content = re.sub(r'^### (.+)$', lambda m: f'\\subsection{{{remove_numbering(m)}}}', content, flags=re.MULTILINE)
        
        # #### -> \subsubsection{}
        content = re.sub(r'^#### (.+)$', lambda m: f'\\subsubsection{{{remove_numbering(m)}}}', content, flags=re.MULTILINE)
        
        return content
    
    def convert_mermaid_to_figures(self, content: str, chapter_num: int) -> str:
        """将Mermaid图表转换为LaTeX图片格式"""
        
        def replace_mermaid(match):
            mermaid_content = match.group(1)
            mermaid_pos = match.start()
            
            # 在前后文中找到图片标题
            before_text = content[:mermaid_pos]
            after_text = content[match.end():]
            
            # 查找标题模式，提取完整的图号和标题
            title_pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
            
            fig_num = None
            clean_title = "未命名图表"
            
            # 优先在前面查找标题
            matches_before = list(re.finditer(title_pattern, before_text))
            if matches_before:
                last_match = matches_before[-1]
                fig_num = last_match.group(1)  # 如 "5.18"
                clean_title = last_match.group(2).strip()  # 如 "机器学习模型特征重要性分布"
            else:
                # 在后面查找标题
                match_after = re.search(title_pattern, after_text[:200])
                if match_after:
                    fig_num = match_after.group(1)
                    clean_title = match_after.group(2).strip()
            
            if not fig_num:
                fig_num = f"{chapter_num}.0"
            
            # 使用真实的图号生成文件名
            img_filename = f"{chapter_num}-图{fig_num} {clean_title}.png"
            label = f"fig{chapter_num}_{fig_num.replace('.', '_')}"
            
            # 生成LaTeX图片代码，caption和textbf都只包含图片名字
            latex_figure = f"""\\begin{{figure}}[!htb]
\t\\centering
\t\\includegraphics[width=0.8\\textwidth]{{images/{img_filename}}}
\t\\caption{{{clean_title}}}
\t\\label{{{label}}}
\\end{{figure}}

\\textbf{{{clean_title}}}"""
            return latex_figure
        
        # 替换Mermaid代码块
        pattern = r'```mermaid\n(.*?)\n```'
        content = re.sub(pattern, replace_mermaid, content, flags=re.DOTALL)
        
        return content
    
    def convert_figure_titles(self, content: str) -> str:
        """转换独立的图片标题，只保留图片名称"""
        # 匹配 **图X.X 图片名称** 格式
        def replace_title(match):
            fig_num = match.group(1)  # 如 "5.18"
            title = match.group(2).strip()  # 如 "机器学习模型特征重要性分布"
            return f"**{title}**"
        
        pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
        content = re.sub(pattern, replace_title, content)
        
        return content
    
    def convert_figure_titles(self, content: str) -> str:
        """转换独立的图片标题，只保留图片名称"""
        # 匹配 **图X.X 图片名称** 格式
        def replace_title(match):
            fig_num = match.group(1)  # 如 "5.18"
            title = match.group(2).strip()  # 如 "机器学习模型特征重要性分布"
            return f"**{title}**"
        
        pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*'
        content = re.sub(pattern, replace_title, content)
        
        return content
    
    def convert_tables(self, content: str, chapter_num: int) -> str:
        """转换Markdown表格为LaTeX格式"""
        if chapter_num not in self.table_counter:
            self.table_counter[chapter_num] = 0
        
        def replace_table(match):
            self.table_counter[chapter_num] += 1
            table_num = self.table_counter[chapter_num]
            
            table_content = match.group(0)
            lines = table_content.strip().split('\n')
            
            if len(lines) < 2:
                return table_content
            
            # 解析表头
            header_line = lines[0]
            separator_line = lines[1] if len(lines) > 1 else ""
            data_lines = lines[2:] if len(lines) > 2 else []
            
            # 提取列
            header_cols = [col.strip() for col in header_line.split('|') if col.strip()]
            
            if not header_cols:
                return table_content
            
            # 生成LaTeX表格
            num_cols = len(header_cols)
            col_spec = 'c' * num_cols
            
            label = f"table{chapter_num}_{table_num}"
            caption = f"表{chapter_num}.{table_num}"
            
            latex_table = f"""
这是表\\ref{{{label}}}。

\\begin{{table}}[!htb]
    \\caption{{{caption}}}
    \\label{{{label}}}
    \\centering
    \\begin{{tabular}}{{{col_spec}}}
        \\hline
"""
            
            # 添加表头
            header_row = " & ".join(header_cols) + " \\\\\n"
            latex_table += "        " + header_row
            latex_table += "        \\hline\n"
            
            # 添加数据行
            for line in data_lines:
                cols = [col.strip() for col in line.split('|') if col.strip()]
                if cols and len(cols) == num_cols:
                    data_row = " & ".join(cols) + " \\\\\n"
                    latex_table += "        " + data_row
            
            latex_table += """        \\hline
    \\end{tabular}
\\end{table}
"""
            return latex_table
        
        # 匹配Markdown表格
        table_pattern = r'^\|.*\|$\n^\|.*\|$\n(?:^\|.*\|$\n)*'
        content = re.sub(table_pattern, replace_table, content, flags=re.MULTILINE)
        
        return content
    
    def convert_references(self, content: str) -> str:
        """转换参考文献引用格式"""
        for md_ref, latex_ref in self.reference_mapping.items():
            content = content.replace(md_ref, latex_ref)
        
        return content
    
    def clean_latex_content(self, content: str) -> str:
        """清理和优化LaTeX内容"""
        # 移除多余的空行
        content = re.sub(r'\n{3,}', '\n\n', content)
        
        # 转换粗体格式
        content = re.sub(r'\*\*([^*]+)\*\*', r'\\textbf{\1}', content)
        
        # 转换斜体格式 - 避免与LaTeX命令冲突
        content = re.sub(r'(?<!\\)\*([^*\\\n]+)\*(?!\\)', r'\\textit{\1}', content)
        
        # 转换行内代码
        content = re.sub(r'`([^`]+)`', r'\\texttt{\1}', content)
        
        # 转换代码块
        content = re.sub(r'```(\w+)?\n(.*?)\n```', 
                        r'\\begin{verbatim}\n\2\n\\end{verbatim}', 
                        content, flags=re.DOTALL)
        
        # 简化的特殊字符处理 - 只处理最必要的字符
        # 避免处理已经是LaTeX命令的部分
        def escape_char(match):
            char = match.group(0)
            # 检查是否在LaTeX命令中
            if '\\' in match.string[max(0, match.start()-10):match.start()]:
                return char
            
            escape_map = {
                '&': '\\&',
                '%': '\\%',
                '$': '\\$',
                '#': '\\#'
            }
            return escape_map.get(char, char)
        
        # 只转义最关键的字符
        content = re.sub(r'[&%$#]', escape_char, content)
        
        return content
    
    def parse_reference_to_bibitem(self, ref_num: str, ref_text: str) -> str:
        """将参考文献解析为\bibitem格式"""
        # 清理参考文献文本
        ref_text = ref_text.strip()
        
        # 移除可能的编号前缀
        ref_text = re.sub(r'^\[\d+\]\s*', '', ref_text)
        
        # 生成\bibitem格式
        bibitem_entry = f"\\bibitem{{c{ref_num}}} {{{ref_text}}}\n\n"
        
        return bibitem_entry
    
    def convert_chapter(self, chapter_num: int) -> bool:
        """转换单个章节"""
        filename = self.chapter_files.get(chapter_num)
        if not filename:
            print(f"章节 {chapter_num} 文件不存在")
            return False
        
        input_file = self.md_dir / filename
        if not input_file.exists():
            print(f"输入文件不存在: {input_file}")
            return False
        
        print(f"正在转换第{chapter_num}章: {filename}")
        
        # 读取Markdown内容
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 执行转换步骤
        content = self.convert_headers(content)
        content = self.convert_mermaid_to_figures(content, chapter_num)
        content = self.convert_figure_titles(content)  # 新增：处理独立的图片标题
        content = self.convert_tables(content, chapter_num)
        content = self.convert_references(content)
        content = self.clean_latex_content(content)
        
        # 写入LaTeX文件
        output_file = self.chapters_dir / f"chapter-{chapter_num}.tex"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"生成LaTeX文件: {output_file}")
        return True
    
    def generate_conversion_report(self):
        """生成转换报告"""
        report = {
            "conversion_summary": {
                "total_chapters": len(self.chapter_files),
                "chapters_converted": 0,
                "total_figures": sum(self.figure_counter.values()),
                "total_tables": sum(self.table_counter.values()),
                "total_references": len(self.reference_mapping)
            },
            "chapter_details": {},
            "files_generated": []
        }
        
        for chapter_num in range(1, 7):
            if chapter_num in self.figure_counter or chapter_num in self.table_counter:
                report["conversion_summary"]["chapters_converted"] += 1
                report["chapter_details"][f"chapter_{chapter_num}"] = {
                    "figures": self.figure_counter.get(chapter_num, 0),
                    "tables": self.table_counter.get(chapter_num, 0)
                }
        
        # 记录生成的文件
        for chapter_num in range(1, 7):
            tex_file = self.chapters_dir / f"chapter-{chapter_num}.tex"
            if tex_file.exists():
                report["files_generated"].append(str(tex_file.relative_to(self.base_dir)))
        
        # 保存报告
        report_dir = self.base_dir / "overleaf_test"
        report_dir.mkdir(exist_ok=True)
        report_file = report_dir / "conversion_report.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def run(self):
        """运行完整的转换流程"""
        print("开始Markdown到LaTeX转换...")
        print(f"输入目录: {self.md_dir}")
        print(f"输出目录: {self.overleaf_dir}")
        
        # 步骤1: 提取和转换图片
        self.extract_and_convert_images()
        
        # 步骤2: 处理参考文献
        self.process_references()
        
        # 步骤3: 转换各章节
        success_count = 0
        for chapter_num in range(1, 7):
            if self.convert_chapter(chapter_num):
                success_count += 1
        
        # 步骤4: 生成报告
        report = self.generate_conversion_report()
        
        # 打印摘要
        print("\n" + "="*60)
        print("转换完成!")
        print(f"成功转换章节: {success_count}/{len(self.chapter_files)}")
        print(f"总图片数量: {report['conversion_summary']['total_figures']}")
        print(f"总表格数量: {report['conversion_summary']['total_tables']}")
        print(f"总参考文献: {report['conversion_summary']['total_references']}")
        
        print("\n各章节详情:")
        for chapter, details in report["chapter_details"].items():
            chapter_num = chapter.split('_')[1]
            print(f"  第{chapter_num}章: {details['figures']}个图片, {details['tables']}个表格")
        
        print(f"\n生成的文件:")
        for file_path in report["files_generated"]:
            print(f"  {file_path}")
        
        print(f"\n输出目录: {self.overleaf_dir}")
        print("="*60)

def main():
    """主函数"""
    converter = MarkdownToLatexConverter()
    converter.run()

if __name__ == "__main__":
    main()