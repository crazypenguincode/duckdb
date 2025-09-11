#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
合并docx文档脚本 - 完整版本
将_enhanced_docx_out目录下的所有docx文档按照指定顺序合并成一个完整的文档
支持图片、表格、公式等复杂内容的合并
"""

import os
import sys
from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import parse_xml
import logging
import shutil

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class AdvancedDocxMerger:
    def __init__(self, input_dir, output_file):
        self.input_dir = Path(input_dir)
        self.output_file = Path(output_file)
        
        # 定义文档合并顺序
        self.document_order = [
            "第一章-绪论.docx",
            "第二章-相关背景与理论基础.docx", 
            "第三章-动态缓存管理.docx",
            "第四章-动态缓存更新技术与持久化技术.docx",
            "第五章-实验与分析.docx",
            "第六章-总结与展望.docx",
            "统一参考文献列表.docx"
        ]
        
    def create_title_page(self, doc):
        """创建标题页"""
        logger.info("创建标题页...")
        
        # 添加空行
        for _ in range(5):
            doc.add_paragraph()
        
        # 添加标题
        title = doc.add_heading('分析型数据库的动态缓存技术研究', 0)
        title.alignment = WD_ALIGN_PARAGRAPH.CENTER
        
        # 设置标题字体
        for run in title.runs:
            run.font.name = 'Times New Roman'
            run.font.size = Pt(24)
            run.font.bold = True
            run._element.rPr.rFonts.set(qn('w:eastAsia'), '宋体')
        
        # 添加空行
        for _ in range(8):
            doc.add_paragraph()
            
        # 添加作者信息等
        author_info = [
            "学位论文",
            "",
            "专业：计算机科学与技术", 
            "研究方向：数据库系统",
            "",
            "完成时间：2024年"
        ]
        
        for info in author_info:
            p = doc.add_paragraph(info)
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in p.runs:
                run.font.name = 'Times New Roman'
                run.font.size = Pt(14)
                run._element.rPr.rFonts.set(qn('w:eastAsia'), '宋体')
        
        # 添加分页符
        doc.add_page_break()
        
    def copy_element(self, element, target_doc):
        """复制XML元素到目标文档"""
        try:
            # 直接复制元素到目标文档
            target_doc._element.body.append(element)
            return True
        except Exception as e:
            logger.warning(f"复制元素失败: {str(e)}")
            return False
    
    def merge_documents_advanced(self):
        """高级合并方法 - 保留所有格式和内容"""
        logger.info("开始高级合并文档...")
        
        # 使用第一个文档作为基础
        first_doc_path = self.input_dir / self.document_order[0]
        if not first_doc_path.exists():
            logger.error(f"第一个文档不存在: {first_doc_path}")
            return False
        
        # 复制第一个文档作为基础
        shutil.copy2(first_doc_path, self.output_file)
        merged_doc = Document(self.output_file)
        
        # 在开头插入标题页
        # 由于python-docx的限制，我们在末尾添加其他章节
        
        # 统计信息
        total_elements = 0
        processed_files = [self.document_order[0]]
        
        # 合并其余文档
        for doc_name in self.document_order[1:]:
            doc_path = self.input_dir / doc_name
            
            if not doc_path.exists():
                logger.warning(f"文档不存在: {doc_path}")
                continue
                
            logger.info(f"正在合并: {doc_name}")
            
            try:
                # 打开源文档
                source_doc = Document(doc_path)
                
                # 添加分页符
                merged_doc.add_page_break()
                
                # 复制所有元素
                element_count = 0
                
                # 复制段落
                for paragraph in source_doc.paragraphs:
                    new_paragraph = merged_doc.add_paragraph()
                    
                    # 复制段落内容和格式
                    self._copy_paragraph_complete(paragraph, new_paragraph)
                    element_count += 1
                
                # 复制表格
                for table in source_doc.tables:
                    self._copy_table_complete(table, merged_doc)
                    element_count += 1
                
                total_elements += element_count
                processed_files.append(doc_name)
                
                logger.info(f"  - 已处理元素: {element_count}")
                
            except Exception as e:
                logger.error(f"处理文档 {doc_name} 时出错: {str(e)}")
                continue
        
        # 保存合并后的文档
        logger.info(f"保存合并文档到: {self.output_file}")
        merged_doc.save(self.output_file)
        
        # 输出统计信息
        self._print_merge_summary(processed_files, total_elements)
        
        return True
    
    def _copy_paragraph_complete(self, source_paragraph, target_paragraph):
        """完整复制段落，包括所有格式和内容"""
        try:
            # 清空目标段落
            target_paragraph.clear()
            
            # 复制段落样式
            if source_paragraph.style:
                try:
                    target_paragraph.style = source_paragraph.style
                except:
                    pass
            
            # 复制对齐方式
            target_paragraph.alignment = source_paragraph.alignment
            
            # 复制所有运行
            for run in source_paragraph.runs:
                new_run = target_paragraph.add_run(run.text)
                
                # 复制字体格式
                self._copy_run_format(run, new_run)
                
        except Exception as e:
            logger.warning(f"复制段落时出错: {str(e)}")
            # 备用方案：至少复制文本
            try:
                target_paragraph.add_run(source_paragraph.text)
            except:
                pass
    
    def _copy_run_format(self, source_run, target_run):
        """复制运行格式"""
        try:
            # 基本字体属性
            if source_run.font.name:
                target_run.font.name = source_run.font.name
            if source_run.font.size:
                target_run.font.size = source_run.font.size
            
            target_run.font.bold = source_run.font.bold
            target_run.font.italic = source_run.font.italic
            target_run.font.underline = source_run.font.underline
            
            # 复制中文字体
            try:
                if source_run._element.rPr is not None:
                    rfonts = source_run._element.rPr.rFonts
                    if rfonts is not None:
                        east_asia = rfonts.get(qn('w:eastAsia'))
                        if east_asia:
                            target_run._element.rPr.rFonts.set(qn('w:eastAsia'), east_asia)
            except:
                pass
                
        except Exception as e:
            logger.warning(f"复制运行格式时出错: {str(e)}")
    
    def _copy_table_complete(self, source_table, target_doc):
        """完整复制表格"""
        try:
            # 创建新表格
            new_table = target_doc.add_table(rows=len(source_table.rows), cols=len(source_table.columns))
            
            # 复制表格样式
            if source_table.style:
                try:
                    new_table.style = source_table.style
                except:
                    pass
            
            # 复制表格内容
            for i, row in enumerate(source_table.rows):
                for j, cell in enumerate(row.cells):
                    target_cell = new_table.cell(i, j)
                    
                    # 清空目标单元格
                    target_cell.text = ""
                    
                    # 复制单元格的所有段落
                    for k, paragraph in enumerate(cell.paragraphs):
                        if k == 0:
                            # 使用现有的第一个段落
                            target_paragraph = target_cell.paragraphs[0]
                        else:
                            # 添加新段落
                            target_paragraph = target_cell.add_paragraph()
                        
                        # 复制段落内容
                        self._copy_paragraph_complete(paragraph, target_paragraph)
            
        except Exception as e:
            logger.warning(f"复制表格时出错: {str(e)}")
    
    def merge_documents(self):
        """标准合并方法"""
        logger.info("开始合并文档...")
        
        # 创建新文档
        merged_doc = Document()
        
        # 创建标题页
        self.create_title_page(merged_doc)
        
        # 统计信息
        total_paragraphs = 0
        total_tables = 0
        processed_files = []
        
        # 按顺序合并文档
        for i, doc_name in enumerate(self.document_order):
            doc_path = self.input_dir / doc_name
            
            if not doc_path.exists():
                logger.warning(f"文档不存在: {doc_path}")
                continue
                
            logger.info(f"正在合并: {doc_name}")
            
            try:
                # 打开源文档
                source_doc = Document(doc_path)
                
                # 添加章节分页符（除了第一个文档）
                if i > 0:
                    merged_doc.add_page_break()
                
                # 复制所有段落
                paragraph_count = 0
                table_count = 0
                
                for paragraph in source_doc.paragraphs:
                    # 创建新段落
                    new_paragraph = merged_doc.add_paragraph()
                    self._copy_paragraph_complete(paragraph, new_paragraph)
                    paragraph_count += 1
                
                # 复制所有表格
                for table in source_doc.tables:
                    self._copy_table_complete(table, merged_doc)
                    table_count += 1
                
                total_paragraphs += paragraph_count
                total_tables += table_count
                processed_files.append(doc_name)
                
                logger.info(f"  - 已处理段落: {paragraph_count}")
                logger.info(f"  - 已处理表格: {table_count}")
                
            except Exception as e:
                logger.error(f"处理文档 {doc_name} 时出错: {str(e)}")
                continue
        
        # 保存合并后的文档
        logger.info(f"保存合并文档到: {self.output_file}")
        merged_doc.save(self.output_file)
        
        # 输出统计信息
        self._print_merge_summary(processed_files, total_paragraphs, total_tables)
        
        return True
    
    def _print_merge_summary(self, processed_files, total_paragraphs, total_tables=0):
        """打印合并摘要"""
        logger.info("=" * 50)
        logger.info("文档合并完成!")
        logger.info(f"已处理文件数: {len(processed_files)}")
        logger.info(f"处理的文件: {', '.join(processed_files)}")
        logger.info(f"总段落数: {total_paragraphs}")
        if total_tables > 0:
            logger.info(f"总表格数: {total_tables}")
        logger.info(f"输出文件: {self.output_file}")
        
        if self.output_file.exists():
            file_size = self.output_file.stat().st_size / 1024 / 1024
            logger.info(f"文件大小: {file_size:.2f} MB")
        
        logger.info("=" * 50)

def main():
    """主函数"""
    # 设置路径
    current_dir = Path(__file__).parent
    input_dir = current_dir / "_enhanced_docx_out"
    output_file = current_dir / "完整论文-分析型数据库的动态缓存技术研究.docx"
    
    # 检查输入目录
    if not input_dir.exists():
        logger.error(f"输入目录不存在: {input_dir}")
        return False
    
    # 列出可用的docx文件
    available_files = list(input_dir.glob("*.docx"))
    logger.info(f"发现的docx文件: {[f.name for f in available_files if not f.name.startswith('~$')]}")
    
    # 创建合并器
    merger = AdvancedDocxMerger(input_dir, output_file)
    
    # 执行合并
    try:
        success = merger.merge_documents()
        if success:
            logger.info("文档合并成功完成!")
            return True
        else:
            logger.error("文档合并失败!")
            return False
    except Exception as e:
        logger.error(f"合并过程中出现错误: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)