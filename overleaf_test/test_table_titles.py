#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

# 测试表格标题提取
test_content = """
**表5.12 重复查询集布隆过滤器性能测试（10000次测试）**

| 配置名称 | 平均查询时间(ms) | 总执行时间(s) | 相对基准提升(%) |
|----------|-----------------|--------------|----------------|
| 标准布隆过滤器 | 0.25 | 2.463 |  3.0% |

**表5.13 参数化查询集布隆过滤器性能测试（10000次测试）**

| 配置名称 | 平均查询时间(ms) | 总执行时间(s) |  相对基准提升(%) |
|----------|-----------------|--------------|----------------|
| 标准布隆过滤器 | 0.28 | 2.756 |  2.3% |
"""

print("测试内容:")
print(test_content)
print("\n" + "="*50)

# 测试正则表达式
pattern = r'\*\*表(\d+\.\d+)\s+([^*]+)\*\*\s*\n?'
matches = re.findall(pattern, test_content)

print(f"找到的匹配: {len(matches)}")
for i, match in enumerate(matches):
    table_num, title = match
    print(f"匹配 {i+1}: 表{table_num} -> {title.strip()}")

print("\n" + "="*50)

# 测试提取函数
table_titles = {}

def extract_title(match):
    table_num = match.group(1)  # 如 "5.3"
    title = match.group(2).strip()  # 如 "性能监控工具配置信息"
    table_titles[table_num] = title
    print(f"提取表格标题: {table_num} -> {title}")
    return ''  # 移除原始标题

content = re.sub(pattern, extract_title, test_content)
print(f"总共提取了 {len(table_titles)} 个表格标题")
print("提取的标题:")
for key, value in table_titles.items():
    print(f"  {key}: {value}")

print("\n处理后的内容:")
print(content)