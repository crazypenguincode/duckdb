#!/usr/bin/env python3
"""
生成所有测试数据集的脚本
"""

import os
import sys
import subprocess
from pathlib import Path

def main():
    """主函数"""
    print("开始生成第五章表5.7的所有测试数据集...")
    
    base_dir = Path(__file__).parent.parent
    
    # 定义所有数据集生成脚本
    generators = [
        {
            'name': '重复查询集',
            'script': base_dir / 'dataset' / 'repeat_queries' / 'generate_repeat_queries.py',
            'description': '1000个查询，高重复率(80%)'
        },
        {
            'name': '参数化查询集',
            'script': base_dir / 'dataset' / 'parameterized_queries' / 'generate_parameterized_queries.py',
            'description': '500个模板，参数变化'
        },
        {
            'name': 'CTE查询集',
            'script': base_dir / 'dataset' / 'cte_queries' / 'generate_cte_queries.py',
            'description': '200个查询，复杂CTE结构'
        },
        {
            'name': '并发查询集',
            'script': base_dir / 'dataset' / 'concurrent_queries' / 'generate_concurrent_queries.py',
            'description': '100个查询，高并发访问'
        }
    ]
    
    success_count = 0
    total_count = len(generators)
    
    for i, generator in enumerate(generators, 1):
        print(f"\n[{i}/{total_count}] 生成 {generator['name']}...")
        print(f"描述: {generator['description']}")
        print(f"脚本: {generator['script']}")
        
        try:
            # 确保脚本存在
            if not Path(generator['script']).exists():
                print(f"❌ 脚本文件不存在: {generator['script']}")
                continue
            
            # 运行生成脚本
            result = subprocess.run([
                sys.executable, str(generator['script'])
            ], cwd=Path(generator['script']).parent, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {generator['name']} 生成成功")
                if result.stdout:
                    print(f"输出: {result.stdout.strip()}")
                success_count += 1
            else:
                print(f"❌ {generator['name']} 生成失败")
                if result.stderr:
                    print(f"错误: {result.stderr.strip()}")
                    
        except Exception as e:
            print(f"❌ 生成 {generator['name']} 时发生异常: {e}")
    
    print(f"\n=== 数据集生成完成 ===")
    print(f"成功: {success_count}/{total_count}")
    print(f"成功率: {success_count/total_count*100:.1f}%")
    
    if success_count == total_count:
        print("🎉 所有数据集生成成功！")
        return True
    else:
        print("⚠️ 部分数据集生成失败")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)