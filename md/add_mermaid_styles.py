             # -*- coding: utf-8 -*-
"""
Mermaid样式增强脚本
为所有mermaid图表中的节点添加统一的背景色样式
"""

import os
import re
from pathlib import Path

class MermaidStyleEnhancer:
    def __init__(self, base_dir="/Users/max/src/duckdb/md"):
        self.base_dir = Path(base_dir)
        
        # 预定义的颜色方案
        self.color_schemes = {
            'default': {
                'primary': '#e3f2fd',      # 浅蓝色 - 主要节点
                'secondary': '#f3e5f5',    # 浅紫色 - 次要节点
                'success': '#e8f5e8',      # 浅绿色 - 成功/结果节点
                'warning': '#fff3e0',      # 浅橙色 - 警告/重要节点
                'info': '#e0f2f1',         # 浅青色 - 信息节点
                'light': '#f5f5f5',        # 浅灰色 - 普通节点
            },
            'professional': {
                'primary': '#bbdefb',      # 蓝色系
                'secondary': '#c8e6c9',    # 绿色系
                'success': '#dcedc8',      # 浅绿色系
                'warning': '#ffe0b2',      # 橙色系
                'info': '#b3e5fc',         # 浅蓝色系
                'light': '#eceff1',        # 灰色系
            },
            'academic': {
                'primary': '#e1f5fe',      # 学术蓝
                'secondary': '#f1f8e9',    # 学术绿
                'success': '#e8f5e8',      # 成功绿
                'warning': '#fff8e1',      # 警告黄
                'info': '#e3f2fd',         # 信息蓝
                'light': '#fafafa',        # 纯净白
            }
        }
        
        # 节点类型映射（根据节点内容自动分类）
        self.node_type_patterns = {
            'primary': [
                r'管理器|Manager|核心|Core|主要|Main|系统|System',
                r'缓存管理器|Cache Manager|查询管理|Query Manager'
            ],
            'secondary': [
                r'过滤器|Filter|检测|Detection|分析|Analysis',
                r'布隆过滤器|Bloom Filter|签名|Signature'
            ],
            'success': [
                r'成功|Success|完成|Complete|返回|Return|结果|Result',
                r'命中|Hit|缓存结果|Cache Result'
            ],
            'warning': [
                r'更新|Update|警告|Warning|重要|Important|关键|Critical',
                r'缓存更新|Cache Update|持久化|Persistence'
            ],
            'info': [
                r'接口|Interface|客户端|Client|输入|Input|输出|Output',
                r'SQL|查询|Query|解析|Parse'
            ]
        }
    
    def extract_mermaid_blocks(self, content):
        """提取文档中的所有mermaid代码块"""
        pattern = r'```mermaid\n(.*?)\n```'
        blocks = []
        
        for match in re.finditer(pattern, content, re.DOTALL):
            start_pos = match.start()
            end_pos = match.end()
            mermaid_content = match.group(1)
            blocks.append({
                'start': start_pos,
                'end': end_pos,
                'content': mermaid_content,
                'full_match': match.group(0)
            })
        
        return blocks
    
    def extract_nodes_from_mermaid(self, mermaid_content):
        """从mermaid内容中提取所有节点"""
        nodes = set()
        
        # 匹配各种节点定义格式
        patterns = [
            r'(\w+)\[([^\]]+)\]',           # A[文本]
            r'(\w+)\{([^}]+)\}',            # A{文本}
            r'(\w+)\(([^)]+)\)',            # A(文本)
            r'(\w+)\(\(([^)]+)\)\)',        # A((文本))
            r'(\w+)>([^>]+)]',              # A>文本]
            r'(\w+)\[\[([^\]]+)\]\]',       # A[[文本]]
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, mermaid_content)
            for match in matches:
                node_id = match[0]
                node_text = match[1] if len(match) > 1 else match[0]
                nodes.add((node_id, node_text))
        
        return nodes
    
    def classify_node_type(self, node_text):
        """根据节点文本内容分类节点类型"""
        for node_type, patterns in self.node_type_patterns.items():
            for pattern in patterns:
                if re.search(pattern, node_text, re.IGNORECASE):
                    return node_type
        return 'light'  # 默认类型
    
    def generate_style_statements(self, nodes, color_scheme='academic'):
        """生成样式语句"""
        if color_scheme not in self.color_schemes:
            color_scheme = 'academic'
        
        colors = self.color_schemes[color_scheme]
        style_statements = []
        
        for node_id, node_text in nodes:
            node_type = self.classify_node_type(node_text)
            color = colors.get(node_type, colors['light'])
            style_statements.append(f"    style {node_id} fill:{color}")
        
        return style_statements
    
    def enhance_mermaid_block(self, mermaid_content, color_scheme='academic'):
        """为单个mermaid块添加样式"""
        # 提取节点
        nodes = self.extract_nodes_from_mermaid(mermaid_content)
        
        if not nodes:
            return mermaid_content
        
        # 检查是否已经有样式定义
        existing_styles = re.findall(r'style\s+\w+\s+fill:', mermaid_content)
        
        # 生成新的样式语句
        new_styles = self.generate_style_statements(nodes, color_scheme)
        
        # 如果已经有样式，只添加缺失的
        if existing_styles:
            existing_node_ids = set()
            for style in existing_styles:
                match = re.search(r'style\s+(\w+)\s+', style)
                if match:
                    existing_node_ids.add(match.group(1))
            
            # 只添加没有样式的节点
            filtered_styles = []
            for style in new_styles:
                node_id = re.search(r'style\s+(\w+)\s+', style).group(1)
                if node_id not in existing_node_ids:
                    filtered_styles.append(style)
            
            new_styles = filtered_styles
        
        # 添加样式到mermaid内容末尾
        if new_styles:
            enhanced_content = mermaid_content.rstrip()
            if not enhanced_content.endswith('\n'):
                enhanced_content += '\n'
            enhanced_content += '\n' + '\n'.join(new_styles)
            return enhanced_content
        
        return mermaid_content
    
    def process_file(self, file_path, color_scheme='academic', backup=True):
        """处理单个文件"""
        print(f"处理文件: {file_path.name}")
        
        # 读取文件内容
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"读取文件失败: {e}")
            return False
        
        # 备份原文件
        if backup:
            backup_path = file_path.with_suffix(f'{file_path.suffix}.backup')
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  已备份到: {backup_path.name}")
        
        # 提取mermaid块
        mermaid_blocks = self.extract_mermaid_blocks(content)
        
        if not mermaid_blocks:
            print(f"  未找到mermaid图表")
            return True
        
        print(f"  找到 {len(mermaid_blocks)} 个mermaid图表")
        
        # 从后往前处理，避免位置偏移
        modified_content = content
        for block in reversed(mermaid_blocks):
            enhanced_mermaid = self.enhance_mermaid_block(block['content'], color_scheme)
            
            if enhanced_mermaid != block['content']:
                # 替换内容
                new_block = f"```mermaid\n{enhanced_mermaid}\n```"
                modified_content = (
                    modified_content[:block['start']] + 
                    new_block + 
                    modified_content[block['end']:]
                )
                print(f"    增强了一个mermaid图表")
        
        # 保存修改后的文件
        if modified_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            print(f"  ✅ 文件已更新")
            return True
        else:
            print(f"  ℹ️  无需修改")
            return True
    
    def process_all_chapters(self, color_scheme='academic', backup=True):
        """处理所有章节文件"""
        chapter_files = [
            "第一章-绪论.md",
            "第二章-相关背景与理论基础.md", 
            "第三章-动态缓存管理.md",
            "第四章-动态缓存更新技术与持久化技术.md",
            "第五章-实验与分析.md",
            "第六章-总结与展望.md",
        ]
        
        print(f"🎨 开始为mermaid图表添加背景色样式")
        print(f"📁 工作目录: {self.base_dir}")
        print(f"🎨 使用配色方案: {color_scheme}")
        print(f"💾 备份原文件: {'是' if backup else '否'}")
        print("=" * 60)
        
        processed_files = 0
        total_files = 0
        
        for chapter_file in chapter_files:
            file_path = self.base_dir / chapter_file
            total_files += 1
            
            if not file_path.exists():
                print(f"⚠️  文件不存在: {chapter_file}")
                continue
            
            if self.process_file(file_path, color_scheme, backup):
                processed_files += 1
            
            print()  # 空行分隔
        
        print("=" * 60)
        print(f"✅ 处理完成!")
        print(f"📊 处理统计: {processed_files}/{total_files} 个文件")
        
        if backup:
            print(f"💾 备份文件位置: *.md.backup")
        
        print(f"🎨 使用的配色方案详情:")
        colors = self.color_schemes[color_scheme]
        for color_type, color_code in colors.items():
            print(f"  {color_type}: {color_code}")
    
    def preview_color_scheme(self, scheme_name='academic'):
        """预览配色方案"""
        if scheme_name not in self.color_schemes:
            print(f"❌ 配色方案 '{scheme_name}' 不存在")
            print(f"可用方案: {list(self.color_schemes.keys())}")
            return
        
        colors = self.color_schemes[scheme_name]
        print(f"🎨 配色方案预览: {scheme_name}")
        print("=" * 40)
        
        for color_type, color_code in colors.items():
            print(f"{color_type:12} : {color_code}")
        
        print("\n节点类型映射:")
        for node_type, patterns in self.node_type_patterns.items():
            color = colors.get(node_type, colors['light'])
            print(f"{node_type:12} ({color}): {patterns[0] if patterns else 'N/A'}")

def main():
    """主函数"""
    enhancer = MermaidStyleEnhancer()
    
    # 预览配色方案
    print("🎨 可用的配色方案:")
    for scheme in enhancer.color_schemes.keys():
        print(f"  - {scheme}")
    print()
    
    # 预览默认配色方案
    enhancer.preview_color_scheme('academic')
    print()
    
    # 自动使用学术配色方案，备份原文件
    print("🚀 自动使用学术配色方案 (academic) 并备份原文件")
    print("=" * 60)
    
    try:
        # 执行处理
        enhancer.process_all_chapters('academic', True)
        
    except KeyboardInterrupt:
        print("\n\n❌ 用户取消操作")
    except Exception as e:
        print(f"\n❌ 处理过程中出现错误: {e}")

def main_interactive():
    """交互式主函数"""
    enhancer = MermaidStyleEnhancer()
    
    # 预览配色方案
    print("🎨 可用的配色方案:")
    for scheme in enhancer.color_schemes.keys():
        print(f"  - {scheme}")
    print()
    
    # 预览默认配色方案
    enhancer.preview_color_scheme('academic')
    print()
    
    # 询问用户选择
    print("请选择操作:")
    print("1. 使用学术配色方案 (academic) - 推荐")
    print("2. 使用专业配色方案 (professional)")
    print("3. 使用默认配色方案 (default)")
    print("4. 仅预览配色方案")
    
    try:
        choice = input("请输入选择 (1-4, 默认为1): ").strip()
        if not choice:
            choice = '1'
        
        if choice == '4':
            scheme = input("请输入要预览的配色方案名称 (academic/professional/default): ").strip()
            if not scheme:
                scheme = 'academic'
            enhancer.preview_color_scheme(scheme)
            return
        
        scheme_map = {
            '1': 'academic',
            '2': 'professional', 
            '3': 'default'
        }
        
        selected_scheme = scheme_map.get(choice, 'academic')
        
        # 询问是否备份
        backup_choice = input("是否备份原文件? (y/n, 默认为y): ").strip().lower()
        backup = backup_choice != 'n'
        
        # 执行处理
        enhancer.process_all_chapters(selected_scheme, backup)
        
    except KeyboardInterrupt:
        print("\n\n❌ 用户取消操作")
    except Exception as e:
        print(f"\n❌ 处理过程中出现错误: {e}")

if __name__ == "__main__":
    main()