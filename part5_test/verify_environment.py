#!/usr/bin/env python3
"""
快速验证测试 - 验证测试环境和脚本可用性
"""

import os
import sys
import json

def verify_test_environment():
    """验证测试环境"""
    print("第五章测试环境验证")
    print("=" * 50)
    
    # 检查Python版本
    python_version = sys.version_info
    print(f"Python版本: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    # 检查必要的包
    required_packages = ['json', 'os', 'sys', 'time', 'statistics']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✅ {package}: 已安装")
        except ImportError:
            missing_packages.append(package)
            print(f"❌ {package}: 未安装")
    
    # 检查可选包
    optional_packages = ['duckdb', 'psutil']
    for package in optional_packages:
        try:
            __import__(package)
            print(f"✅ {package}: 已安装")
        except ImportError:
            print(f"⚠️  {package}: 未安装（部分功能可能受限）")
    
    # 检查测试脚本
    test_scripts = [
        "5.1.platform_setup.py",
        "5.2.cache_performance.py", 
        "5.3.bloom_filter.py",
        "5.4.sql_cache.py",
        "5.7.persistence.py",
        "5.8.comprehensive.py",
        "run_all_tests.py"
    ]
    
    print(f"\n测试脚本检查:")
    for script in test_scripts:
        script_path = f"part5_test/{script}"
        if os.path.exists(script_path):
            print(f"✅ {script}: 存在")
        else:
            print(f"❌ {script}: 不存在")
    
    # 检查测试数据
    print(f"\n测试数据检查:")
    test_db_path = "/Users/max/test/tpc/tpch-sf1.db"
    if os.path.exists(test_db_path):
        size_mb = os.path.getsize(test_db_path) / (1024 * 1024)
        print(f"✅ TPC-H数据库: 存在 ({size_mb:.1f} MB)")
    else:
        print(f"⚠️  TPC-H数据库: 不存在，将使用模拟数据")
    
    queries_path = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    if os.path.exists(queries_path):
        query_files = [f for f in os.listdir(queries_path) if f.endswith('.sql')]
        print(f"✅ TPC-H查询文件: 存在 ({len(query_files)} 个文件)")
    else:
        print(f"⚠️  TPC-H查询文件: 不存在，将使用内置查询")
    
    # 生成验证报告
    verification_result = {
        "python_version": f"{python_version.major}.{python_version.minor}.{python_version.micro}",
        "missing_packages": missing_packages,
        "test_scripts_available": len([s for s in test_scripts if os.path.exists(f"part5_test/{s}")]),
        "total_test_scripts": len(test_scripts),
        "test_database_available": os.path.exists(test_db_path),
        "query_files_available": os.path.exists(queries_path),
        "environment_ready": len(missing_packages) == 0
    }
    
    # 保存验证结果
    os.makedirs("part5_test", exist_ok=True)
    with open("part5_test/environment_verification.json", "w") as f:
        json.dump(verification_result, f, indent=2)
    
    print(f"\n验证总结:")
    if verification_result["environment_ready"]:
        print("✅ 环境验证通过，可以运行所有测试")
    else:
        print("⚠️  环境存在问题，部分测试可能无法运行")
        print(f"   缺失包: {', '.join(missing_packages)}")
    
    print(f"📄 验证结果已保存到: part5_test/environment_verification.json")
    
    return verification_result

def main():
    """主函数"""
    result = verify_test_environment()
    
    if result["environment_ready"]:
        print(f"\n🚀 建议运行命令:")
        print(f"   python3 part5_test/run_all_tests.py")
    else:
        print(f"\n🔧 建议先安装缺失的包:")
        for package in result["missing_packages"]:
            print(f"   pip3 install {package}")

if __name__ == "__main__":
    main()