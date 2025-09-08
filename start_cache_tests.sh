#!/bin/bash

# DuckDB查询缓存测试套件快速启动脚本

echo "DuckDB查询缓存测试套件"
echo "======================"

# 检查Python版本
python_version=$(python3 --version 2>&1)
echo "Python版本: $python_version"

# 检查当前目录
echo "当前目录: $(pwd)"

# 检查必要文件是否存在
required_files=(
    "verify_cache_setup.py"
    "test_query_cache_performance.py"
    "test_cache_memory_analysis.py"
    "test_cache_strategies.py"
    "run_cache_tests.py"
    "install_test_dependencies.py"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        missing_files+=("$file")
    fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo "错误: 缺少以下文件:"
    printf '  %s\n' "${missing_files[@]}"
    exit 1
fi

echo "✓ 所有测试脚本文件存在"

# 运行验证脚本
echo ""
echo "运行环境验证..."
echo "=================="
python3 verify_cache_setup.py

verification_result=$?

echo ""
echo "快速启动选项:"
echo "=============="

if [[ $verification_result -eq 0 ]]; then
    echo "1. 安装依赖包:"
    echo "   python3 install_test_dependencies.py"
    echo ""
    echo "2. 运行快速测试:"
    echo "   python3 run_cache_tests.py --quick"
    echo ""
    echo "3. 运行完整测试:"
    echo "   python3 run_cache_tests.py"
    echo ""
    echo "4. 运行单独的测试:"
    echo "   python3 test_query_cache_performance.py"
    echo "   python3 test_cache_memory_analysis.py"
    echo "   python3 test_cache_strategies.py"
    echo ""
    echo "5. 使用TPC-H数据库:"
    echo "   python3 run_cache_tests.py --db-path /Users/max/test/tpc/tpch-sf1.db"
else
    echo "请先解决验证过程中发现的问题，然后重新运行此脚本"
fi

echo ""
echo "更多信息请查看: README_cache_tests.md"