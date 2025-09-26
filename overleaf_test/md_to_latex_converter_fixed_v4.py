#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markdown到LaTeX转换脚本 - 修复版本v4
专门解决图片浮动体格式错乱问题，优化Overleaf平台的显示效果
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
        
        # 表格标题存储
        self.table_titles = {}
        
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
        lines = ref_section.split('\n')
        for line in lines:
            line = line.strip()
            match = re.match(r'\[(\d+)\]\s+(.+)', line)
            if match:
                ref_num, ref_text = match.groups()
                ref_text = ref_text.strip()
                
                if (ref_text and 
                    not ref_text.startswith('→') and 
                    not ref_text.startswith('**') and 
                    not '→' in ref_text and
                    len(ref_text) > 20 and
                    ('.' in ref_text or '[' in ref_text)):
                    
                    ref_text = re.sub(r'\n+', ' ', ref_text)
                    ref_text = re.sub(r'\s+', ' ', ref_text)
                    
                    bib_entry = self.parse_reference_to_bibitem(ref_num, ref_text)
                    bib_content.append(bib_entry)
                    
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
            title = re.sub(r'^第[一二三四五六七八九十\d]+章\s*', '', title)
            title = re.sub(r'^\d+(\.\d+)*\s+', '', title)
            title = re.sub(r'^第[一二三四五六七八九十\d]+节\s*', '', title)
            title = re.sub(r'^[一二三四五六七八九十]+[、\.]\s*', '', title)
            title = re.sub(r'^[A-Za-z]+\.\s*', '', title)
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
        """将Mermaid图表转换为LaTeX图片格式 - 优化浮动体处理"""
        
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
            
            # 优先在后面查找标题（图片标题通常在图片后面）
            match_after = re.search(title_pattern, after_text[:200])
            if match_after:
                fig_num = match_after.group(1)
                clean_title = match_after.group(2).strip()
            else:
                # 如果后面没找到，在前面查找最近的标题
                matches_before = list(re.finditer(title_pattern, before_text))
                if matches_before:
                    # 找到距离当前位置最近的标题（最后一个匹配）
                    last_match = matches_before[-1]
                    # 检查这个标题是否距离当前图片很近（在同一段落内）
                    title_end_pos = last_match.end()
                    text_between = before_text[title_end_pos:].strip()
                    # 如果标题和图片之间只有很少的文本（比如小于100个字符），则认为是匹配的
                    if len(text_between) < 100:
                        fig_num = last_match.group(1)
                        clean_title = last_match.group(2).strip()
            
            if not fig_num:
                fig_num = f"{chapter_num}.0"
            
            # 使用真实的图号生成文件名
            img_filename = f"{chapter_num}-图{fig_num} {clean_title}.png"
            label = f"fig{chapter_num}_{fig_num.replace('.', '_')}"
            
            # 检查图片前后的文本内容，决定浮动策略
            context_before = before_text[-200:] if len(before_text) > 200 else before_text
            context_after = after_text[:200] if len(after_text) > 200 else after_text
            
            # 判断是否需要就近显示
            needs_here = (
                "如图" in context_before[-50:] or 
                "见图" in context_before[-50:] or 
                "图中" in context_after[:50] or
                "上图" in context_after[:50] or
                "下图" in context_before[-50:]
            )
            
            # 根据图片大小和内容选择合适的宽度
            if "流程" in clean_title or "架构" in clean_title or "框架" in clean_title:
                width = "0.9\\textwidth"
            elif "对比" in clean_title or "比较" in clean_title:
                width = "0.85\\textwidth"
            else:
                width = "0.8\\textwidth"
            
            # 选择合适的浮动参数
            if needs_here:
                # 需要就近显示，使用htbp参数，优先here，然后top，bottom，最后page
                float_params = "htbp"
            else:
                # 不需要就近显示，使用tbp参数，让LaTeX自动选择最佳位置
                float_params = "tbp"
            
            # 生成优化的LaTeX图片代码
            latex_figure = f"""
\\begin{{figure}}[{float_params}]
\t\\centering
\t\\includegraphics[width={width}]{{images/{img_filename}}}
\t\\caption{{{clean_title}}}
\t\\label{{{label}}}
\\end{{figure}}

"""
            return latex_figure
        
        # 替换Mermaid代码块
        pattern = r'```mermaid\n(.*?)\n```'
        content = re.sub(pattern, replace_mermaid, content, flags=re.DOTALL)
        
        return content
    
    def convert_figure_titles(self, content: str) -> str:
        """移除独立的图片标题，因为标题会在LaTeX图片的caption中显示"""
        pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*\s*\n?'
        content = re.sub(pattern, '', content)
        return content
    
    def convert_table_titles(self, content: str) -> str:
        """提取并存储表格标题信息，然后移除独立的表格标题"""
        pattern = r'\*\*表(\d+\.\d+)\s+([^*]+)\*\*\s*\n?'
        
        def extract_title(match):
            table_num = match.group(1)  # 如 "5.3"
            title = match.group(2).strip()  # 如 "性能监控工具配置信息"
            self.table_titles[table_num] = title
            return ''  # 移除原始标题
        
        content = re.sub(pattern, extract_title, content)
        return content
    
    def escape_latex_special_chars(self, text: str) -> str:
        """转义LaTeX特殊字符，但保护数学公式"""
        # 先保护数学公式
        math_placeholders = {}
        math_counter = 0
        
        def protect_math(match):
            nonlocal math_counter
            math_content = match.group(0)
            placeholder = f"__MATH_ESCAPE_PLACEHOLDER_{math_counter}__"
            math_placeholders[placeholder] = math_content
            math_counter += 1
            return placeholder
        
        # 保护数学公式
        text = re.sub(r'\$\$[^$]+\$\$', protect_math, text)  # 显示公式
        text = re.sub(r'\$[^$\n]+\$', protect_math, text)    # 行内公式
        
        # 转义特殊字符，但保留已经转义的
        text = re.sub(r'(?<!\\)&', r'\\&', text)
        text = re.sub(r'(?<!\\)%', r'\\%', text)
        text = re.sub(r'(?<!\\)\$', r'\\$', text)
        text = re.sub(r'(?<!\\)#', r'\\#', text)
        text = re.sub(r'(?<!\\)_', r'\\_', text)
        
        # 转换HTML标签为LaTeX格式
        text = text.replace('<br/>', '\\newline ')
        text = text.replace('<br>', '\\newline ')
        
        # 恢复数学公式
        for placeholder, math_content in math_placeholders.items():
            text = text.replace(placeholder, math_content)
        
        return text
    
    def convert_tables(self, content: str, chapter_num: int) -> str:
        """转换Markdown表格为LaTeX格式 - 优化浮动体处理"""
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
            header_cols = []
            if header_line.startswith('|') and header_line.endswith('|'):
                cols = header_line.split('|')[1:-1]
                header_cols = [col.strip() for col in cols if col.strip()]
            else:
                header_cols = [col.strip() for col in header_line.split('|') if col.strip()]

            if not header_cols:
                return table_content

            # 生成LaTeX表格 - 优化列宽设置
            num_cols = len(header_cols)
            if num_cols <= 2:
                col_spec = 'p{6cm}' * num_cols
            elif num_cols == 3:
                col_spec = 'p{4.5cm}' * num_cols
            elif num_cols == 4:
                col_spec = 'p{3.2cm}' * num_cols
            elif num_cols == 5:
                col_spec = 'p{2.5cm}' * num_cols
            else:
                col_spec = 'p{2cm}' * num_cols

            label = f"table{chapter_num}_{table_num}"

            # 查找表格标题
            caption = f"表{chapter_num}.{table_num}"  # 默认标题
            
            # 尝试从存储的标题中找到最匹配的标题
            available_keys = [k for k in self.table_titles.keys() if k.startswith(f"{chapter_num}.")]
            available_keys.sort(key=lambda x: float(x.split('.')[1]))
            
            if len(available_keys) >= table_num:
                actual_key = available_keys[table_num - 1]
                caption = self.table_titles[actual_key]
            
            # 判断表格大小，选择合适的浮动参数
            total_rows = len(data_lines)
            if total_rows > 10 or num_cols > 5:
                # 大表格，允许跨页显示
                float_params = "tbp"
                table_env = "longtable"
            else:
                # 小表格，优先在当前页显示
                float_params = "htbp"
                table_env = "table"
            
            if table_env == "longtable":
                # 使用longtable处理大表格
                latex_table = f"""
\\begin{{longtable}}{{{col_spec}}}
\\caption{{{caption}}} \\label{{{label}}} \\\\
\\hline
"""
                # 添加表头
                escaped_headers = []
                for header in header_cols:
                    escaped_headers.append(self.escape_latex_special_chars(header))
                
                header_row = " & ".join(escaped_headers) + " \\\\\n"
                latex_table += header_row
                latex_table += "\\hline\n"
                latex_table += "\\endfirsthead\n\n"
                
                # 续页表头
                latex_table += f"\\multicolumn{{{num_cols}}}{{c}}{{{{续表 {caption}}}}} \\\\\n"
                latex_table += "\\hline\n"
                latex_table += header_row
                latex_table += "\\hline\n"
                latex_table += "\\endhead\n\n"
                
                # 添加数据行
                for line in data_lines:
                    if line.strip():
                        if line.startswith('|') and line.endswith('|'):
                            cols = line.split('|')[1:-1]
                            cols = [col.strip() for col in cols]
                        else:
                            cols = [col.strip() for col in line.split('|')]
                        
                        if cols and len(cols) == num_cols:
                            escaped_cols = []
                            for col in cols:
                                escaped_cols.append(self.escape_latex_special_chars(col))
                            
                            data_row = " & ".join(escaped_cols) + " \\\\\n"
                            latex_table += data_row
                
                latex_table += "\\hline\n\\end{longtable}\n"
                
            else:
                # 使用普通table环境
                latex_table = f"""
\\begin{{{table_env}}}[{float_params}]
    \\caption{{{caption}}}
    \\label{{{label}}}
    \\centering
    \\begin{{tabular}}{{{col_spec}}}
        \\hline
"""
                
                # 添加表头
                escaped_headers = []
                for header in header_cols:
                    escaped_headers.append(self.escape_latex_special_chars(header))
                
                header_row = " & ".join(escaped_headers) + " \\\\\n"
                latex_table += "        " + header_row
                latex_table += "        \\hline\n"
                
                # 添加数据行
                for line in data_lines:
                    if line.strip():
                        if line.startswith('|') and line.endswith('|'):
                            cols = line.split('|')[1:-1]
                            cols = [col.strip() for col in cols]
                        else:
                            cols = [col.strip() for col in line.split('|')]
                        
                        if cols and len(cols) == num_cols:
                            escaped_cols = []
                            for col in cols:
                                escaped_cols.append(self.escape_latex_special_chars(col))
                            
                            data_row = " & ".join(escaped_cols) + " \\\\\n"
                            latex_table += "        " + data_row
                
                latex_table += f"""        \\hline
    \\end{{tabular}}
\\end{{{table_env}}}

"""
            return latex_table
        
        # 匹配Markdown表格
        table_pattern = r'(?:^\|.*\|[ \t]*$\n){2,}'
        content = re.sub(table_pattern, replace_table, content, flags=re.MULTILINE)
        
        return content
    
    def convert_references(self, content: str) -> str:
        """转换参考文献引用格式"""
        for md_ref, latex_ref in self.reference_mapping.items():
            content = content.replace(md_ref, latex_ref)
        
        return content
    
    def clean_latex_content(self, content: str) -> str:
        """清理和优化LaTeX内容，特别处理数学公式"""
        # 移除多余的空行，但保留必要的段落分隔
        content = re.sub(r'\n{4,}', '\n\n\n', content)  # 最多保留3个换行
        content = re.sub(r'\n{3}', '\n\n', content)     # 将3个换行减少为2个
        
        # 先保护数学公式和行内代码，避免与其他格式转换冲突
        math_placeholders = {}
        code_placeholders = {}
        math_counter = 0
        code_counter = 0
        
        def protect_math(match):
            nonlocal math_counter
            math_content = match.group(0)  # 保留完整的$...$格式
            placeholder = f"MATHPLACEHOLDER{math_counter}MATHPLACEHOLDER"
            math_placeholders[placeholder] = math_content
            math_counter += 1
            return placeholder
        
        def protect_code(match):
            nonlocal code_counter
            code_content = match.group(1)
            placeholder = f"CODEPLACEHOLDER{code_counter}CODEPLACEHOLDER"
            code_placeholders[placeholder] = code_content
            code_counter += 1
            return placeholder
        
        # 保护数学公式（行内公式和显示公式）
        content = re.sub(r'\$\$[^$]+?\$\$', protect_math, content)  # 显示公式 $$...$$
        content = re.sub(r'\$[^$\n]+?\$', protect_math, content)    # 行内公式 $...$
        
        # 保护行内代码
        content = re.sub(r'`([^`]+)`', protect_code, content)
        
        # 转换代码块
        content = re.sub(r'```(\w+)?\n(.*?)\n```', 
                        r'\\begin{verbatim}\n\2\n\\end{verbatim}', 
                        content, flags=re.DOTALL)
        
        # 转换粗体格式
        content = re.sub(r'\*\*([^*]+)\*\*', r'\\textbf{\1}', content)
        
        # 转换斜体格式 - 避免与LaTeX命令冲突
        content = re.sub(r'(?<!\\)\*([^*\\\n]+)\*(?!\\)', r'\\textit{\1}', content)
        
        # 转义LaTeX特殊字符，但要避免对表格内容重复转义
        content = re.sub(r'(?<!\\)%', r'\\%', content)
        
        # 对于&符号，只在非表格环境中转义
        lines = content.split('\n')
        processed_lines = []
        in_table = False
        in_longtable = False
        
        for line in lines:
            # 检查是否在表格环境中
            if '\\begin{table}' in line:
                in_table = True
            elif '\\end{table}' in line:
                in_table = False
                processed_lines.append(line)
                continue
            elif '\\begin{longtable}' in line:
                in_longtable = True
            elif '\\end{longtable}' in line:
                in_longtable = False
                processed_lines.append(line)
                continue
            
            # 如果不在表格中，则转义&符号
            if not in_table and not in_longtable:
                line = re.sub(r'(?<!\\)&', r'\\&', line)
            
            processed_lines.append(line)
        
        content = '\n'.join(processed_lines)
        
        # 转义其他特殊字符
        content = re.sub(r'(?<!\\)#', r'\\#', content)
        content = re.sub(r'(?<!\\)_', r'\\_', content)
        
        # 先恢复数学公式，保持原始格式
        for placeholder, math_content in math_placeholders.items():
            content = content.replace(placeholder, math_content)
        
        # 再恢复行内代码，应用texttt格式
        for placeholder, code_content in code_placeholders.items():
            content = content.replace(placeholder, f'\\texttt{{{code_content}}}')
        
        # 在LaTeX命令的大括号内恢复下划线（不转义）
        def restore_underscore_in_latex(match):
            cmd = match.group(0)
            return cmd.replace('\\_', '_')
        
        # 恢复LaTeX命令内的下划线
        content = re.sub(r'\\[a-zA-Z]+\{[^}]*\}', restore_underscore_in_latex, content)
        
        # 优化段落间距
        content = self.optimize_paragraph_spacing(content)
        
        return content
    
    def optimize_paragraph_spacing(self, content: str) -> str:
        """优化段落间距，减少不必要的空白"""
        lines = content.split('\n')
        optimized_lines = []
        prev_line_type = None
        
        for i, line in enumerate(lines):
            line_stripped = line.strip()
            
            # 判断行类型
            if not line_stripped:
                line_type = 'empty'
            elif line_stripped.startswith('\\chapter'):
                line_type = 'chapter'
            elif line_stripped.startswith('\\section'):
                line_type = 'section'
            elif line_stripped.startswith('\\subsection'):
                line_type = 'subsection'
            elif line_stripped.startswith('\\begin{figure}'):
                line_type = 'figure_start'
            elif line_stripped.startswith('\\end{figure}'):
                line_type = 'figure_end'
            elif line_stripped.startswith('\\begin{table}'):
                line_type = 'table_start'
            elif line_stripped.startswith('\\end{table}'):
                line_type = 'table_end'
            else:
                line_type = 'text'
            
            # 根据前后行类型决定是否添加空行
            if line_type == 'empty':
                # 空行处理逻辑
                if (prev_line_type in ['figure_end', 'table_end'] and 
                    i + 1 < len(lines) and 
                    lines[i + 1].strip().startswith(('\\section', '\\subsection', '\\chapter'))):
                    # 图表后面紧跟标题，保留一个空行
                    optimized_lines.append('')
                elif prev_line_type == 'text' and i + 1 < len(lines) and lines[i + 1].strip():
                    # 文本段落之间，保留一个空行
                    optimized_lines.append('')
                # 其他情况跳过空行
            else:
                optimized_lines.append(line)
            
            prev_line_type = line_type
        
        return '\n'.join(optimized_lines)
    
    def parse_reference_to_bibitem(self, ref_num: str, ref_text: str) -> str:
        """将参考文献解析为\\bibitem格式"""
        # 清理参考文献文本
        ref_text = ref_text.strip()
        
        # 移除可能的编号前缀
        ref_text = re.sub(r'^\[\d+\]\s*', '', ref_text)
        
        # 生成\\bibitem格式
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
        content = self.convert_figure_titles(content)  # 处理独立的图片标题
        content = self.convert_table_titles(content)   # 处理独立的表格标题
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
            "files_generated": [],
            "improvements_v4": {
                "float_optimization": "优化图片和表格浮动参数，使用htbp/tbp替代H",
                "spacing_optimization": "优化段落间距，减少不必要空白",
                "table_enhancement": "大表格使用longtable环境，支持跨页显示",
                "context_aware_positioning": "根据上下文智能选择图片定位策略"
            }
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
        report_file = report_dir / "conversion_report_v4.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def generate_latex_preamble(self):
        """生成优化的LaTeX导言区配置文件"""
        preamble_content = """% LaTeX导言区配置 - 优化版本v4
% 解决图片浮动体和间距问题

\\documentclass[12pt,a4paper]{book}

% 基础包
\\usepackage[UTF8]{ctex}
\\usepackage{geometry}
\\usepackage{graphicx}
\\usepackage{float}
\\usepackage{longtable}
\\usepackage{booktabs}
\\usepackage{array}
\\usepackage{multirow}
\\usepackage{multicol}

% 页面设置
\\geometry{
    left=3cm,
    right=2.5cm,
    top=2.5cm,
    bottom=2.5cm
}

% 浮动体参数优化
\\renewcommand{\\topfraction}{0.9}        % 页面顶部浮动体最大比例
\\renewcommand{\\bottomfraction}{0.8}     % 页面底部浮动体最大比例
\\setcounter{topnumber}{3}                % 页面顶部最多浮动体数量
\\setcounter{bottomnumber}{3}             % 页面底部最多浮动体数量
\\setcounter{totalnumber}{4}              % 每页最多浮动体总数
\\renewcommand{\\textfraction}{0.07}      % 页面文本最小比例
\\renewcommand{\\floatpagefraction}{0.7}  % 浮动页面浮动体最小比例

% 图表间距优化
\\setlength{\\floatsep}{12pt plus 2pt minus 2pt}           % 浮动体之间的间距
\\setlength{\\textfloatsep}{20pt plus 2pt minus 4pt}       % 浮动体与文本间距
\\setlength{\\intextsep}{14pt plus 2pt minus 2pt}          % 文中浮动体上下间距

% 段落间距
\\setlength{\\parskip}{6pt plus 2pt minus 1pt}
\\setlength{\\parindent}{2em}

% 标题间距
\\usepackage{titlesec}
\\titlespacing*{\\chapter}{0pt}{-20pt}{20pt}
\\titlespacing*{\\section}{0pt}{12pt}{6pt}
\\titlespacing*{\\subsection}{0pt}{10pt}{5pt}
\\titlespacing*{\\subsubsection}{0pt}{8pt}{4pt}

% 图表标题格式
\\usepackage{caption}
\\captionsetup{
    font=small,
    labelfont=bf,
    textfont=normal,
    justification=centering,
    singlelinecheck=false,
    skip=10pt
}

% 表格优化
\\usepackage{tabularx}
\\renewcommand{\\arraystretch}{1.2}

% 数学公式
\\usepackage{amsmath}
\\usepackage{amssymb}
\\usepackage{amsfonts}

% 参考文献
\\usepackage{cite}

% 超链接
\\usepackage[colorlinks=true,linkcolor=black,citecolor=black]{hyperref}

% 代码显示
\\usepackage{verbatim}
\\usepackage{fancyvrb}

% 防止孤行和寡行
\\widowpenalty=10000
\\clubpenalty=10000

% 页眉页脚
\\usepackage{fancyhdr}
\\pagestyle{fancy}
\\fancyhf{}
\\fancyhead[LE,RO]{\\thepage}
\\fancyhead[LO]{\\leftmark}
\\fancyhead[RE]{\\rightmark}
\\renewcommand{\\headrulewidth}{0.4pt}
"""
        
        preamble_file = self.overleaf_dir / "preamble_v4.tex"
        with open(preamble_file, 'w', encoding='utf-8') as f:
            f.write(preamble_content)
        
        print(f"生成优化的LaTeX导言区文件: {preamble_file}")
        return preamble_file
    
    def run(self):
        """运行完整的转换流程"""
        print("开始Markdown到LaTeX转换 (v4 - 浮动体优化版)...")
        print(f"输入目录: {self.md_dir}")
        print(f"输出目录: {self.overleaf_dir}")
        
        # 步骤1: 生成优化的LaTeX导言区
        self.generate_latex_preamble()
        
        # 步骤2: 提取和转换图片
        self.extract_and_convert_images()
        
        # 步骤3: 处理参考文献
        self.process_references()
        
        # 步骤4: 转换各章节
        success_count = 0
        for chapter_num in range(1, 7):
            if self.convert_chapter(chapter_num):
                success_count += 1
        
        # 步骤5: 生成报告
        report = self.generate_conversion_report()
        
        # 打印摘要
        print("\n" + "="*60)
        print("转换完成! (v4 - 浮动体优化版)")
        print(f"成功转换章节: {success_count}/{len(self.chapter_files)}")
        print(f"总图片数量: {report['conversion_summary']['total_figures']}")
        print(f"总表格数量: {report['conversion_summary']['total_tables']}")
        print(f"总参考文献: {report['conversion_summary']['total_references']}")
        
        print("\nv4版本改进:")
        for key, value in report["improvements_v4"].items():
            print(f"  • {value}")
        
        print("\n各章节详情:")
        for chapter, details in report["chapter_details"].items():
            chapter_num = chapter.split('_')[1]
            print(f"  第{chapter_num}章: {details['figures']}个图片, {details['tables']}个表格")
        
        print(f"\n生成的文件:")
        for file_path in report["files_generated"]:
            print(f"  {file_path}")
        
        print(f"\n输出目录: {self.overleaf_dir}")
        print("="*60)
        
        # 使用建议
        print("\n📋 Overleaf使用建议:")
        print("1. 在主文档中使用 \\input{preamble_v4.tex} 导入优化配置")
        print("2. 图片使用 htbp 参数，允许LaTeX自动选择最佳位置")
        print("3. 大表格使用 longtable 环境，支持跨页显示")
        print("4. 如需强制定位，使用 \\FloatBarrier 命令分隔章节")
        print("5. 编译时选择 XeLaTeX 或 pdfLaTeX 引擎")

def main():
    """主函数"""
    converter = MarkdownToLatexConverter()
    converter.run()

if __name__ == "__main__":
    main()