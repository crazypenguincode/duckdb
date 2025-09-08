#!/usr/bin/env python3
"""
安装测试所需的Python依赖包
"""

import subprocess
import sys

def install_package(package):
    """安装Python包"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✓ 成功安装 {package}")
        return True
    except subprocess.CalledProcessError:
        print(f"✗ 安装 {package} 失败")
        return False

def main():
    print("安装DuckDB查询缓存测试所需的依赖包...")
    
    required_packages = [
        "duckdb",
        "psutil", 
        "matplotlib",
        "pandas"
    ]
    
    success_count = 0
    for package in required_packages:
        if install_package(package):
            success_count += 1
    
    print(f"\n安装完成: {success_count}/{len(required_packages)} 个包安装成功")
    
    if success_count == len(required_packages):
        print("✓ 所有依赖包安装成功，可以运行测试了")
        return 0
    else:
        print("⚠ 部分依赖包安装失败，可能影响测试功能")
        return 1

if __name__ == "__main__":
    sys.exit(main())