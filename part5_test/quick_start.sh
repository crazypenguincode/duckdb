#!/bin/bash

# 第五章实验测试一键启动脚本
# 快速运行所有第五章的实验测试

echo "🚀 第五章实验测试启动脚本"
echo "=================================="

# 检查当前目录
if [ ! -f "5.1.platform_setup.py" ]; then
    echo "❌ 错误: 请在part5_test目录下运行此脚本"
    echo "正确用法: cd /Users/max/src/duckdb/part5_test && ./quick_start.sh"
    exit 1
fi

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: Python3 未安装"
    exit 1
fi

echo "✅ 环境检查通过"
echo ""

# 显示选项菜单
echo "请选择运行模式:"
echo "1. 🏃 快速验证 (运行完整验证脚本)"
echo "2. 📋 单项测试 (选择特定测试)"
echo "3. 📊 查看最新结果 (显示测试报告)"
echo "4. 🧹 清理结果文件"
echo ""

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo "🏃 开始运行完整验证..."
        python3 run_chapter5_verification.py
        echo ""
        echo "✅ 验证完成! 查看结果:"
        echo "  📄 综合报告: chapter5_comprehensive_report.json"
        echo "  📋 测试报告: Chapter5_Test_Report.md"
        echo "  📊 验证报告: Chapter5_Final_Verification_Report.md"
        ;;
    2)
        echo "📋 可用的测试脚本:"
        echo "  1. 5.1.platform_setup.py - 实验平台搭建"
        echo "  2. 5.2.cache_performance.py - 缓存性能测试"
        echo "  3. 5.3.bloom_filter.py - 布隆过滤器测试"
        echo "  4. 5.4.sql_cache.py - SQL缓存技术测试"
        echo "  5. 5.7.persistence.py - 持久化策略测试"
        echo "  6. 5.8.comprehensive.py - 综合性能评估"
        echo ""
        read -p "请选择要运行的测试 (1-6): " test_choice
        
        case $test_choice in
            1) python3 5.1.platform_setup.py ;;
            2) python3 5.2.cache_performance.py ;;
            3) python3 5.3.bloom_filter.py ;;
            4) python3 5.4.sql_cache.py ;;
            5) python3 5.7.persistence.py ;;
            6) python3 5.8.comprehensive.py ;;
            *) echo "❌ 无效选择" ;;
        esac
        ;;
    3)
        echo "📊 显示最新测试结果..."
        echo ""
        if [ -f "Chapter5_Test_Report.md" ]; then
            echo "📋 测试报告摘要:"
            head -20 Chapter5_Test_Report.md
            echo ""
            echo "完整报告请查看: Chapter5_Test_Report.md"
        else
            echo "❌ 未找到测试报告，请先运行测试"
        fi
        
        if [ -f "chapter5_comprehensive_report.json" ]; then
            echo ""
            echo "📊 性能指标摘要:"
            python3 -c "
import json
try:
    with open('chapter5_comprehensive_report.json', 'r') as f:
        data = json.load(f)
    summary = data.get('test_summary', {})
    performance = data.get('performance_summary', {})
    print(f'  总测试数: {summary.get(\"total_tests\", \"N/A\")}')
    print(f'  成功率: {summary.get(\"success_rate\", \"N/A\")}%')
    print(f'  执行时间: {summary.get(\"total_execution_time\", \"N/A\")}s')
    print('  性能指标:')
    for key, value in performance.items():
        print(f'    {key}: {value}')
except Exception as e:
    print(f'  读取报告失败: {e}')
"
        else
            echo "❌ 未找到综合报告，请先运行测试"
        fi
        ;;
    4)
        echo "🧹 清理结果文件..."
        rm -f *.json
        rm -f Chapter5_*.md
        echo "✅ 清理完成"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "🎯 使用提示:"
echo "  - 完整验证: ./quick_start.sh 选择选项1"
echo "  - 单项测试: ./quick_start.sh 选择选项2"
echo "  - 查看结果: ./quick_start.sh 选择选项3"
echo "  - 清理文件: ./quick_start.sh 选择选项4"
echo ""
echo "📚 更多信息请查看: README.md"