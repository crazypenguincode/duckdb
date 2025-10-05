#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markdown到LaTeX转换脚本 - 增强版本v7
基于v6版本，新增支持images-man目录下手动图片的处理
支持![描述](images-man/图片名称.png)格式的图片引用转换
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
        self.images_man_dir = self.overleaf_dir / "images-man"  # 新增images-man目录
        self.references_dir = self.overleaf_dir / "references"
        
        # 创建必要的目录
        self.chapters_dir.mkdir(parents=True, exist_ok=True)
        self.images_dir.mkdir(parents=True, exist_ok=True)
        self.images_man_dir.mkdir(parents=True, exist_ok=True)  # 创建images-man目录
        self.references_dir.mkdir(parents=True, exist_ok=True)
        self.abstract_dir = self.overleaf_dir / "abstract"
        self.abstract_dir.mkdir(parents=True, exist_ok=True)
        
        # 章节文件映射
        self.chapter_files = {
            0: "第0章-摘要.md",  # 添加摘要文件
            1: "第一章-绪论.md",
            2: "第二章-相关背景与理论基础.md", 
            3: "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
            4: "第四章-智能缓存替换策略.md",
            5: "第五章-多策略融合的持久化存储技术.md",
            6: "第六章-实验与分析.md",
            7: "第七章-总结与展望.md"
        }
        
        # 图片计数器
        self.figure_counter = {}
        self.table_counter = {}
        
        # 参考文献映射
        self.reference_mapping = {}
        
        # 表格标题存储 - 使用v2版本的简单方式
        self.table_titles = {}
        
    def extract_and_convert_images(self, force_regenerate=False):
        """提取并转换Mermaid图片为PNG - 使用v5版本的优化实现"""
        print("正在提取和转换图片...")
        
        # 如果强制重新生成，先清理旧图片
        if force_regenerate:
            print("强制重新生成模式，清理旧图片...")
            md_images_dir = self.md_dir / "images"
            if md_images_dir.exists():
                for img_file in md_images_dir.glob("*.png"):
                    img_file.unlink()
                    print(f"删除旧图片: {img_file.name}")
                for img_file in md_images_dir.glob("*.mmd"):
                    img_file.unlink()
                    print(f"删除旧mmd文件: {img_file.name}")
        
        # 运行图片提取脚本
        extract_script = self.md_dir / "extract_all_images_hq.py"
        if extract_script.exists():
            try:
                result = subprocess.run(["python3", str(extract_script)], 
                                      cwd=str(self.md_dir), 
                                      capture_output=True, text=True, check=True)
                print("图片提取完成")
                if result.stdout:
                    print("\n提取输出:")
                    print(result.stdout)
            except subprocess.CalledProcessError as e:
                print(f"图片提取失败: {e}")
                if e.stderr:
                    print(f"错误信息: {e.stderr}")
                return False
        else:
            print(f"图片提取脚本不存在: {extract_script}")
            return False
        
        # 复制图片到overleaf_test/images目录
        md_images_dir = self.md_dir / "images"
        copied_count = 0
        if md_images_dir.exists():
            for img_file in md_images_dir.glob("*.png"):
                dest_file = self.images_dir / img_file.name
                shutil.copy2(img_file, dest_file)
                print(f"复制Mermaid图片: {img_file.name}")
                copied_count += 1
            print(f"共复制 {copied_count} 个Mermaid图片文件")
        else:
            print(f"Mermaid图片目录不存在: {md_images_dir}")
        
        # 复制images-man目录下的图片到overleaf_test/images-man目录
        md_images_man_dir = self.md_dir / "images-man"
        if md_images_man_dir.exists():
            for img_file in md_images_man_dir.glob("*.png"):
                dest_file = self.images_man_dir / img_file.name
                shutil.copy2(img_file, dest_file)
                print(f"复制手动图片: {img_file.name}")
                copied_count += 1
            print(f"共复制 {len(list(md_images_man_dir.glob('*.png')))} 个手动图片文件")
        else:
            print(f"手动图片目录不存在: {md_images_man_dir}")
        
        return copied_count > 0
    
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
        """将Mermaid图表转换为LaTeX图片格式 - 使用v5版本的优化浮动体处理"""
        
        # 初始化图片计数器
        if chapter_num not in self.figure_counter:
            self.figure_counter[chapter_num] = 0
        
        def replace_mermaid(match):
            # 更新图片计数器
            self.figure_counter[chapter_num] += 1
            
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
                fig_num = f"{chapter_num}.{self.figure_counter[chapter_num]}"
            
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
                width = "1\\textwidth"
            elif "对比" in clean_title or "比较" in clean_title:
                width = "0.95\\textwidth"
            else:
                width = "0.95\\textwidth"
            
            # 选择合适的浮动参数
            float_params = "htbp"
            # if needs_here:
            #     # 需要就近显示，使用htbp参数，优先here，然后top，bottom，最后page
            #     float_params = "htbp"
            # else:
            #     # 不需要就近显示，使用tbp参数，让LaTeX自动选择最佳位置
            #     float_params = "tbp"
            
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
    
    def convert_manual_images(self, content: str) -> str:
        """转换手动图片引用格式 ![描述](images-man/图片名称.png)"""
        import urllib.parse
        
        def replace_manual_image(match):
            alt_text = match.group(1)  # 图片描述
            image_path = match.group(2)  # images-man/图片名称.png
            
            # URL解码，处理%20等编码字符
            image_path = urllib.parse.unquote(image_path)
            
            # 提取图片文件名
            if image_path.startswith('images-man/'):
                image_filename = image_path[11:]  # 去掉 'images-man/' 前缀
            else:
                image_filename = image_path
            
            # 生成LaTeX图片代码
            latex_figure = f"""
\\begin{{figure}}[htbp]
\t\\centering
\t\\includegraphics[width=0.8\\textwidth]{{images-man/{image_filename}}}
\t\\caption{{{alt_text}}}
\\end{{figure}}

"""
            return latex_figure
        
        # 匹配 ![描述](images-man/图片名称.png) 格式
        pattern = r'!\[([^\]]+)\]\(([^\)]+\.png)\)'
        content = re.sub(pattern, replace_manual_image, content)
        
        return content
    
    def convert_figure_titles(self, content: str) -> str:
        """移除独立的图片标题，因为标题会在LaTeX图片的caption中显示"""
        pattern = r'\*\*图(\d+\.\d+)\s+([^*]+)\*\*\s*\n?'
        content = re.sub(pattern, '', content)
        return content
    
    def convert_table_titles(self, content: str) -> str:
        """提取并存储表格标题信息，然后移除独立的表格标题 - 按文档顺序存储"""
        pattern = r'\*\*表(\d+\.\d+)\s+([^*]+)\*\*\s*\n?'
        
        # 按照在文档中出现的顺序提取标题
        matches = list(re.finditer(pattern, content))
        
        # 为每个章节创建有序的标题列表
        for match in matches:
            table_num = match.group(1)  # 如 "6.1"
            title = match.group(2).strip()  # 如 "实验平台硬件配置详情"
            
            # 提取章节号
            chapter_num = int(table_num.split('.')[0])
            
            # 为每个章节维护一个有序的标题列表
            if not hasattr(self, 'ordered_table_titles'):
                self.ordered_table_titles = {}
            if chapter_num not in self.ordered_table_titles:
                self.ordered_table_titles[chapter_num] = []
            
            # 按照出现顺序添加标题
            self.ordered_table_titles[chapter_num].append(title)
            
            # 同时保持原有的字典格式以兼容其他代码
            self.table_titles[table_num] = title
        
        # 移除原始标题
        content = re.sub(pattern, '', content)
        return content
    
    def escape_latex_special_chars(self, text: str) -> str:
        """转义LaTeX特殊字符"""
        # 转义特殊字符，但保留已经转义的
        text = re.sub(r'(?<!\\)&', r'\\&', text)
        text = re.sub(r'(?<!\\)%', r'\\%', text)
        text = re.sub(r'(?<!\\)\$', r'\\$', text)
        text = re.sub(r'(?<!\\)#', r'\\#', text)
        text = re.sub(r'(?<!\\)_', r'\\_', text)
        
        # 转换HTML标签为LaTeX格式
        text = text.replace('<br/>', '\\newline ')
        text = text.replace('<br>', '\\newline ')
        
        return text
    
    def convert_tables(self, content: str, chapter_num: int) -> str:
        """转换Markdown表格为LaTeX格式 - 按顺序编号，直接使用找到的标题"""
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

            # 生成LaTeX表格 - 使用v2版本的简单列宽设置
            num_cols = len(header_cols)
            if num_cols <= 3:
                col_spec = 'p{4cm}' * num_cols
            elif num_cols == 4:
                col_spec = 'p{3cm}' * num_cols
            else:
                col_spec = 'p{2.5cm}' * num_cols

            label = f"table{chapter_num}_{table_num}"

            # 简化标题处理：直接按照表格在文档中的出现顺序匹配标题
            caption = f"表{chapter_num}.{table_num}"  # 默认标题
            
            # 使用有序的标题列表，直接按照表格出现的顺序获取标题
            if (hasattr(self, 'ordered_table_titles') and 
                chapter_num in self.ordered_table_titles and
                len(self.ordered_table_titles[chapter_num]) >= table_num):
                # 直接使用第table_num个标题（索引从0开始，所以减1）
                caption = self.ordered_table_titles[chapter_num][table_num - 1]
            
            # 使用v2版本的简单table环境，不使用复杂的longtable
            latex_table = f"""

\\begin{{table}}[!htb]
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
            
            latex_table += """        \\hline
    \\end{tabular}
\\end{table}
"""
            return latex_table
        
        # 使用v2版本的简单表格匹配正则表达式
        table_pattern = r'(?:^\|.*\|[ \t]*$\n){2,}'
        content = re.sub(table_pattern, replace_table, content, flags=re.MULTILINE)
        
        return content
    
    def convert_references(self, content: str) -> str:
        """转换参考文献引用格式，支持单个引用和范围引用"""
        # 先处理单个引用
        for md_ref, latex_ref in self.reference_mapping.items():
            content = content.replace(md_ref, latex_ref)
        
        # 处理范围引用格式，如 [2-4] -> \cite{c2,c3,c4}
        def expand_range_reference(match):
            range_text = match.group(1)  # 获取 "2-4" 部分
            if '-' in range_text:
                try:
                    start, end = range_text.split('-')
                    start_num = int(start.strip())
                    end_num = int(end.strip())
                    
                    # 生成范围内的所有引用
                    cite_keys = []
                    for i in range(start_num, end_num + 1):
                        cite_keys.append(f"c{i}")
                    
                    return f"\\cite{{{','.join(cite_keys)}}}"
                except (ValueError, AttributeError):
                    # 如果解析失败，返回原始文本
                    return match.group(0)
            else:
                # 不是范围格式，返回原始文本
                return match.group(0)
        
        # 使用正则表达式匹配范围引用格式
        content = re.sub(r'\[(\d+\s*-\s*\d+)\]', expand_range_reference, content)
        
        return content
    
    def clean_latex_content(self, content: str) -> str:
        """清理和优化LaTeX内容"""
        # 移除多余的空行
        content = re.sub(r'\n{3,}', '\n\n', content)
        
        # 先处理行内代码和数学公式，避免与其他格式转换冲突
        code_placeholders = {}
        math_placeholders = {}
        code_counter = 0
        math_counter = 0
        
        def protect_code(match):
            nonlocal code_counter
            code_content = match.group(1)
            placeholder = f"__CODE_PLACEHOLDER_{code_counter}__"
            code_placeholders[placeholder] = code_content
            code_counter += 1
            return placeholder
        
        def protect_math(match):
            nonlocal math_counter
            math_content = match.group(0)  # 保留完整的$...$格式
            placeholder = f"__MATH_PLACEHOLDER_{math_counter}__"
            math_placeholders[placeholder] = math_content
            math_counter += 1
            return placeholder
        
        # 保护数学公式（行内公式和显示公式）
        content = re.sub(r'\$\$[^$]+\$\$', protect_math, content)  # 显示公式 $$...$$
        content = re.sub(r'\$[^$\n]+\$', protect_math, content)    # 行内公式 $...$
        
        # 保护行内代码
        content = re.sub(r'`([^`]+)`', protect_code, content)
        
        # 转换代码块
        content = re.sub(r'```(\w+)?\n(.*?)\n```', 
                        r'\\begin{verbatim}\n\2\n\\end{verbatim}', 
                        content, flags=re.DOTALL)
        
        # 转换列表格式 - 在其他格式转换之前处理
        content = self.convert_lists(content)
        
        # 转换粗体格式
        content = re.sub(r'\*\*([^*]+)\*\*', r'\\textbf{\1}', content)
        
        # 转换斜体格式 - 避免与LaTeX命令冲突
        content = re.sub(r'(?<!\\)\*([^*\\\n]+)\*(?!\\)', r'\\textit{\1}', content)
        
        # 转义LaTeX特殊字符，但要避免对表格内容重复转义
        # 转义%符号，但保留已经转义的
        content = re.sub(r'(?<!\\)%', r'\\%', content)
        
        # 对于&符号，只在非表格环境中转义
        lines = content.split('\n')
        processed_lines = []
        in_table = False
        
        for line in lines:
            # 检查是否在表格环境中
            if '\\begin{table}' in line:
                in_table = True
            elif '\\end{table}' in line:
                in_table = False
                processed_lines.append(line)
                continue
            
            # 如果不在表格中，则转义&符号
            if not in_table:
                line = re.sub(r'(?<!\\)&', r'\\&', line)
            
            processed_lines.append(line)
        
        content = '\n'.join(processed_lines)
        
        # 转义其他特殊字符
        content = re.sub(r'(?<!\\)\$', r'\\$', content)
        content = re.sub(r'(?<!\\)#', r'\\#', content)
        
        # 先恢复数学公式，保持原始格式
        for placeholder, math_content in math_placeholders.items():
            content = content.replace(placeholder, math_content)
        
        # 再恢复行内代码，应用texttt格式，避免占位符被转义
        for placeholder, code_content in code_placeholders.items():
            content = content.replace(placeholder, f'\\texttt{{{code_content}}}')
        
        # 转义下划线，但避免转义LaTeX命令参数中的下划线和数学公式中的下划线
        content = re.sub(r'(?<!\\)_', r'\\_', content)
        
        # 在LaTeX命令的大括号内和数学公式内恢复下划线（不转义）
        def restore_underscore_in_latex(match):
            cmd = match.group(0)
            # 在LaTeX命令的大括号内，将 \_ 恢复为 _
            return cmd.replace('\\_', '_')
        
        def restore_underscore_in_math(match):
            math_expr = match.group(0)
            # 在数学公式内，将 \_ 恢复为 _
            return math_expr.replace('\\_', '_')
        
        # 恢复LaTeX命令内的下划线
        content = re.sub(r'\\[a-zA-Z]+\{[^}]*\}', restore_underscore_in_latex, content)
        
        # 恢复数学公式内的下划线
        content = re.sub(r'\$\$[^$]+\$\$', restore_underscore_in_math, content)  # 显示公式
        content = re.sub(r'\$[^$\n]+\$', restore_underscore_in_math, content)    # 行内公式
        
        return content
    
    def convert_lists(self, content: str) -> str:
        """转换Markdown列表为LaTeX格式"""
        lines = content.split('\n')
        result_lines = []
        in_itemize = False
        in_enumerate = False
        current_indent = 0
        
        i = 0
        while i < len(lines):
            line = lines[i]
            original_line = line
            stripped_line = line.lstrip()
            
            # 计算缩进级别
            indent_level = len(line) - len(stripped_line)
            
            # 检查是否是无序列表项 (- 或 *)
            unordered_match = re.match(r'^(\s*)([-*])\s+(.+)$', line)
            # 检查是否是有序列表项 (数字.)
            ordered_match = re.match(r'^(\s*)(\d+\.)\s+(.+)$', line)
            
            if unordered_match:
                indent, marker, content_text = unordered_match.groups()
                new_indent = len(indent)
                
                # 处理嵌套级别变化
                if not in_itemize or new_indent != current_indent:
                    if in_enumerate:
                        result_lines.append('\\end{enumerate}')
                        in_enumerate = False
                    if in_itemize and new_indent != current_indent:
                        result_lines.append('\\end{itemize}')
                        in_itemize = False
                    
                    if not in_itemize:
                        result_lines.append('\\begin{itemize}')
                        in_itemize = True
                        current_indent = new_indent
                
                result_lines.append(f'\\item {content_text}')
                
            elif ordered_match:
                indent, marker, content_text = ordered_match.groups()
                new_indent = len(indent)
                
                # 处理嵌套级别变化
                if not in_enumerate or new_indent != current_indent:
                    if in_itemize:
                        result_lines.append('\\end{itemize}')
                        in_itemize = False
                    if in_enumerate and new_indent != current_indent:
                        result_lines.append('\\end{enumerate}')
                        in_enumerate = False
                    
                    if not in_enumerate:
                        result_lines.append('\\begin{enumerate}')
                        in_enumerate = True
                        current_indent = new_indent
                
                result_lines.append(f'\\item {content_text}')
                
            else:
                # 不是列表项
                if stripped_line == '' or not stripped_line:
                    # 空行，可能结束列表
                    if in_itemize or in_enumerate:
                        # 检查下一行是否还是列表项
                        next_is_list = False
                        if i + 1 < len(lines):
                            next_line = lines[i + 1].strip()
                            if (re.match(r'^[-*]\s+', next_line) or 
                                re.match(r'^\d+\.\s+', next_line)):
                                next_is_list = True
                        
                        if not next_is_list:
                            # 结束列表
                            if in_itemize:
                                result_lines.append('\\end{itemize}')
                                in_itemize = False
                            if in_enumerate:
                                result_lines.append('\\end{enumerate}')
                                in_enumerate = False
                            current_indent = 0
                    
                    result_lines.append(original_line)
                else:
                    # 非空行，非列表项
                    # 如果当前在列表中，检查是否是列表项的续行
                    if (in_itemize or in_enumerate) and indent_level > current_indent:
                        # 可能是列表项的续行，保持在当前项中
                        if result_lines and result_lines[-1].startswith('\\item'):
                            # 将续行内容添加到上一个item中
                            result_lines[-1] += ' ' + stripped_line
                        else:
                            result_lines.append(original_line)
                    else:
                        # 结束列表
                        if in_itemize:
                            result_lines.append('\\end{itemize}')
                            in_itemize = False
                        if in_enumerate:
                            result_lines.append('\\end{enumerate}')
                            in_enumerate = False
                        current_indent = 0
                        result_lines.append(original_line)
            
            i += 1
        
        # 确保在文档结尾关闭所有列表
        if in_itemize:
            result_lines.append('\\end{itemize}')
        if in_enumerate:
            result_lines.append('\\end{enumerate}')
        
        return '\n'.join(result_lines)
    
    def parse_reference_to_bibitem(self, ref_num: str, ref_text: str) -> str:
        """将参考文献解析为\\bibitem格式"""
        # 清理参考文献文本
        ref_text = ref_text.strip()
        
        # 移除可能的编号前缀
        ref_text = re.sub(r'^\[\d+\]\s*', '', ref_text)
        
        # 生成\\bibitem格式
        bibitem_entry = f"\\bibitem{{c{ref_num}}} {{{ref_text}}}\n\n"
        
        return bibitem_entry
    
    def convert_abstract(self) -> bool:
        """转换摘要文件"""
        filename = self.chapter_files.get(0)
        if not filename:
            print("摘要文件映射不存在")
            return False
        
        input_file = self.md_dir / filename
        if not input_file.exists():
            print(f"摘要输入文件不存在: {input_file}")
            return False
        
        print(f"正在转换摘要: {filename}")
        
        # 读取Markdown内容
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 摘要特殊处理：移除标题，只保留正文内容
        content = re.sub(r'^# 摘要\s*\n', '', content)  # 移除"# 摘要"标题
        
        # 执行基本转换步骤（摘要通常不包含图表）
        content = self.convert_references(content)
        
        # 对摘要进行特殊的清理，不应用章节标题转换
        content = self.clean_abstract_content(content)
        
        # 生成完整的LaTeX摘要格式
        latex_content = f"""\\chapter*{{\\xiaosan\\heiti{{摘\\quad 要}}}}
\\addcontentsline{{toc}}{{chapter}}{{摘要}}

{content}

\\vspace{{0.5cm}}
% \\hspace{{-1cm}}
\\sihao{{\\heiti{{关键词：}}}}\\xiaosi{{数据库系统，查询缓存、CTE、缓存策略，缓存持久化}}
"""
        
        # 写入abstract.tex文件
        output_file = self.abstract_dir / "abstract.tex"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(latex_content)
        
        print(f"生成摘要LaTeX文件: {output_file}")
        return True
    
    def clean_abstract_content(self, content: str) -> str:
        """专门用于清理摘要内容的函数"""
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
        
        # 转换粗体格式
        content = re.sub(r'\*\*([^*]+)\*\*', r'\\textbf{\1}', content)
        
        # 转换斜体格式 - 避免与LaTeX命令冲突
        content = re.sub(r'(?<!\\)\*([^*\\\n]+)\*(?!\\)', r'\\textit{\1}', content)
        
        # 转义LaTeX特殊字符
        content = re.sub(r'(?<!\\)&', r'\\&', content)
        content = re.sub(r'(?<!\\)%', r'\\%', content)
        content = re.sub(r'(?<!\\)#', r'\\#', content)
        content = re.sub(r'(?<!\\)_', r'\\_', content)
        
        # 转换HTML标签为LaTeX格式
        content = content.replace('<br/>', '\\newline ')
        content = content.replace('<br>', '\\newline ')
        
        # 先恢复数学公式，保持原始格式
        for placeholder, math_content in math_placeholders.items():
            content = content.replace(placeholder, math_content)
        
        # 再恢复行内代码，应用texttt格式
        for placeholder, code_content in code_placeholders.items():
            content = content.replace(placeholder, f'\\texttt{{{code_content}}}')
        
        # 清理多余的空行
        content = re.sub(r'\n{3,}', '\n\n', content)
        
        # 确保段落间有适当的间距
        content = content.strip()
        
        return content

    def convert_chapter(self, chapter_num: int) -> bool:
        """转换单个章节 - 融合版本"""
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
        
        # 执行转换步骤 - 使用v2版本的简单顺序
        content = self.convert_headers(content)
        content = self.convert_mermaid_to_figures(content, chapter_num)  # 使用v5版本的优化图片处理
        content = self.convert_manual_images(content)  # 新增：处理手动图片引用
        content = self.convert_figure_titles(content)  # 处理独立的图片标题
        content = self.convert_table_titles(content)   # 处理独立的表格标题
        content = self.convert_tables(content, chapter_num)  # 使用v2版本的简单表格转换
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
        # 重新计算统计信息，确保准确性
        total_figures = sum(self.figure_counter.values())
        total_tables = sum(self.table_counter.values())
        
        report = {
            "conversion_summary": {
                "total_chapters": len(self.chapter_files),
                "chapters_converted": 0,
                "total_figures": total_figures,
                "total_tables": total_tables,
                "total_references": len(self.reference_mapping)
            },
            "chapter_details": {},
            "files_generated": [],
            "version_info": {
                "version": "v7 - 增强版本",
                "improvements": {
                    "table_conversion": "使用v2版本的简单有效表格转换，避免v5版本的复杂逻辑导致的错乱",
                    "image_processing": "使用v5版本的优化图片处理，包括智能浮动体和强制重新生成",
                    "manual_images": "新增支持images-man目录下手动图片的处理和转换",
                    "stability": "结合多个版本的优点，确保转换结果的稳定性和正确性"
                }
            },
            "detailed_statistics": {
                "figure_counter": dict(self.figure_counter),
                "table_counter": dict(self.table_counter)
            }
        }
        
        # 统计转换的章节数量和详细信息
        chapters_converted = 0
        for chapter_num in range(1, 8):
            figures = self.figure_counter.get(chapter_num, 0)
            tables = self.table_counter.get(chapter_num, 0)
            
            if figures > 0 or tables > 0:
                chapters_converted += 1
            
            # 记录所有章节的详细信息，包括没有图表的章节
            report["chapter_details"][f"chapter_{chapter_num}"] = {
                "figures": figures,
                "tables": tables
            }
        
        report["conversion_summary"]["chapters_converted"] = chapters_converted
        
        # 记录生成的文件
        # 检查摘要文件
        abstract_file = self.abstract_dir / "abstract.tex"
        if abstract_file.exists():
            report["files_generated"].append(str(abstract_file.relative_to(self.base_dir)))
        
        # 检查章节文件
        for chapter_num in range(1, 8):
            tex_file = self.chapters_dir / f"chapter-{chapter_num}.tex"
            if tex_file.exists():
                report["files_generated"].append(str(tex_file.relative_to(self.base_dir)))
        
        # 保存报告
        report_dir = self.base_dir / "overleaf_test"
        report_dir.mkdir(exist_ok=True)
        report_file = report_dir / "conversion_report_v6.json"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        
        return report
    
    def generate_latex_preamble(self):
        """生成优化的LaTeX导言区配置文件"""
        preamble_content = """% LaTeX导言区配置 - 融合版本v6
% 结合v2版本的简单表格转换和v5版本的优化图片处理

\\documentclass[12pt,a4paper]{book}

% 基础包
\\usepackage[UTF8]{ctex}
\\usepackage{geometry}
\\usepackage{graphicx}
\\usepackage{float}
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
        
        preamble_file = self.overleaf_dir / "preamble_v6.tex"
        with open(preamble_file, 'w', encoding='utf-8') as f:
            f.write(preamble_content)
        
        print(f"生成融合版LaTeX导言区文件: {preamble_file}")
        return preamble_file
    
    def run(self):
        """运行完整的转换流程"""
        print("开始Markdown到LaTeX转换 (v7 - 增强版本)...")
        print("基于v6版本，新增支持images-man目录下手动图片的处理")
        print(f"输入目录: {self.md_dir}")
        print(f"输出目录: {self.overleaf_dir}")
        
        # 步骤1: 生成优化的LaTeX导言区
        self.generate_latex_preamble()
        
        # 步骤2: 提取和转换图片（使用v5版本的强制重新生成）
        image_success = self.extract_and_convert_images(force_regenerate=True)
        if not image_success:
            print("警告: 图片生成失败，但继续转换流程")
        
        # 步骤3: 处理参考文献
        self.process_references()
        
        # 步骤4: 转换摘要
        abstract_success = self.convert_abstract()
        if not abstract_success:
            print("警告: 摘要转换失败")
        
        # 步骤5: 转换各章节
        success_count = 0
        for chapter_num in range(1, 8):
            if self.convert_chapter(chapter_num):
                success_count += 1
        
        # 步骤6: 生成报告
        report = self.generate_conversion_report()
        
        # 打印摘要
        print("\n" + "="*60)
        print("\n转换完成! (v7 - 增强版本)")
        print(f"摘要转换: {'成功' if abstract_success else '失败'}")
        print(f"成功转换章节: {success_count}/{len(self.chapter_files)-1}")  # 减1是因为第0章是摘要
        print(f"总图片数量: {report['conversion_summary']['total_figures']}")
        print(f"总表格数量: {report['conversion_summary']['total_tables']}")
        print(f"总参考文献: {report['conversion_summary']['total_references']}")
        
        print("\nv7增强版本特点:")
        for key, value in report["version_info"]["improvements"].items():
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
        print("\n📋 v7增强版本说明:")
        print("✅ 表格转换: 使用v2版本的简单有效方法，避免复杂逻辑导致的错乱")
        print("✅ 图片处理: 使用v5版本的优化浮动体处理和智能标题匹配")
        print("✅ 手动图片: 新增支持images-man目录下手动图片的处理和转换")
        print("✅ 稳定性: 结合多个版本的优点，确保转换结果正确")
        print("✅ 兼容性: 生成标准的LaTeX代码，易于编译和调试")

def main():
    """主函数"""
    converter = MarkdownToLatexConverter()
    converter.run()

if __name__ == "__main__":
    main()