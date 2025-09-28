#!/usr/bin/env python3
"""测试列表转换"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from md_to_latex_converter_fixed_v6 import MarkdownToLatexConverter

def test():
    converter = MarkdownToLatexConverter()
    
    test_md = """
- **TPC标准基准测试**：系统实现了54.2%的性能提升
- **专项功能测试**：获得68.6%的性能提升

1. **高重复率查询环境**：缓存技术能够发挥最大价值
2. **复杂分析查询**：性能收益远超开销
"""
    
    result = converter.convert_lists(test_md)
    print("转换结果:")
    print(result)

if __name__ == "__main__":
    test()