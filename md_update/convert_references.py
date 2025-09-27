#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
参考文献格式转换脚本
将脚注格式 [^n] 转换为标准编号格式 [n]
"""

import re
import os

def convert_references_in_file(file_path):
    """转换单个文件中的参考文献格式"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 创建引用映射表
        reference_mapping = {
            '[^1]': '[1]',   # Selinger et al. 1979
            '[^2]': '[2]',   # Gray & Reuter 1992
            '[^3]': '[3]',   # Graefe 1993
            '[^4]': '[4]',   # Ioannidis 1996
            '[^5]': '[6]',   # Bloom 1970
            '[^6]': '[29]',  # Amdahl 1967
            '[^7]': '[30]',  # Silberschatz et al. 2018
            '[^8]': '[9]',   # Gupta & Mumick 1999
            '[^9]': '[6]',   # Bloom 1970
            '[^10]': '[7]',  # Kirsch & Mitzenmacher 2008
            '[^11]': '[14]', # Fan et al. 2000
            '[^12]': '[15]', # Kumar et al. 2004
            '[^13]': '[16]', # Guo et al. 2010
            '[^14]': '[17]', # O'Neil et al. 1996
            '[^15]': '[18]', # DeCandia et al. 2007
            '[^16]': '[19]', # Mackert & Lohman 1986
            '[^17]': '[20]', # Stillger et al. 2001
            '[^18]': '[21]', # Ding et al. 2019
            '[^19]': '[22]', # Li et al. 2020
            '[^20]': '[23]', # Megiddo & Modha 2003
            '[^21]': '[24]', # Bansal & Modha 2004
            '[^22]': '[5]',  # Zhou et al. 2002
            '[^23]': '[25]', # Melton & Simon 2001
            '[^24]': '[3]',  # Graefe 1993
            '[^25]': '[26]', # Chaudhuri 1998
            '[^26]': '[27]', # Ramakrishnan & Gehrke 2003
        }
        
        # 第二章特殊映射
        chapter2_mapping = {
            '[^1]': '[1]',   # Selinger et al. 1979
            '[^2]': '[3]',   # Graefe 1993
            '[^3]': '[4]',   # Ioannidis 1996
            '[^4]': '[5]',   # Megiddo & Modha 2003
            '[^5]': '[6]',   # Bloom 1970
            '[^6]': '[7]',   # Kirsch & Mitzenmacher 2008
        }
        
        # 第三章特殊映射
        chapter3_mapping = {
            '[^1]': '[1]',   # Selinger et al. 1979
            '[^2]': '[28]',  # Kemper & Neumann 2011
            '[^3]': '[3]',   # Graefe 1993
            '[^4]': '[4]',   # Ioannidis 1996
            '[^5]': '[6]',   # Bloom 1970
            '[^6]': '[29]',  # Amdahl 1967
            '[^7]': '[30]',  # Silberschatz et al. 2018
            '[^8]': '[9]',   # Gupta & Mumick 1999
            '[^9]': '[7]',   # Kirsch & Mitzenmacher 2008
            '[^10]': '[7]',  # Kirsch & Mitzenmacher 2008
        }
        
        # 第四章特殊映射
        chapter4_mapping = {
            '[^1]': '[31]',  # Brewer 2000
            '[^2]': '[32]',  # Lamport 1978
            '[^3]': '[17]',  # O'Neil et al. 1996
            '[^4]': '[33]',  # Little 1961
            '[^5]': '[34]',  # Cesa-Bianchi & Lugosi 2006
            '[^6]': '[35]',  # Sutton & Barto 2018
        }
        
        # 根据文件名选择映射表
        if '第一章' in file_path:
            mapping = reference_mapping
        elif '第二章' in file_path:
            mapping = chapter2_mapping
        elif '第三章' in file_path:
            mapping = chapter3_mapping
        elif '第四章' in file_path:
            mapping = chapter4_mapping
        else:
            mapping = {}
        
        # 执行替换
        for old_ref, new_ref in mapping.items():
            content = content.replace(old_ref, new_ref)
        
        # 写回文件
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"已处理文件: {file_path}")
        return True
        
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def main():
    """主函数"""
    base_dir = "/Users/max/src/duckdb/md_update"
    
    # 需要处理的文件列表
    files_to_process = [
        "第一章-绪论.md",
        "第二章-相关背景与理论基础.md", 
        "第三章-基于布隆过滤器的SQL和CTE动态缓存技术.md",
        "第四章-动态缓存更新技术与持久化技术.md"
    ]
    
    success_count = 0
    total_count = len(files_to_process)
    
    for filename in files_to_process:
        file_path = os.path.join(base_dir, filename)
        if os.path.exists(file_path):
            if convert_references_in_file(file_path):
                success_count += 1
        else:
            print(f"文件不存在: {file_path}")
    
    print(f"\n处理完成: {success_count}/{total_count} 个文件成功处理")

if __name__ == "__main__":
    main()