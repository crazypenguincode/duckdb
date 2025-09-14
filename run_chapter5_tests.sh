#!/bin/bash
# 第五章实验测试 - 一键运行脚本

echo "🚀 第五章实验与分析 - 动态缓存技术测试"
echo "=================================================="

# 进入项目目录
cd /Users/max/src/duckdb

# 验证环境
echo "📋 验证测试环境..."
python3 part5_test/verify_environment.py

echo ""
echo "🧪 开始运行完整测试套件..."
echo "预计总时间: 10-15分钟"
echo ""

# 运行所有测试
python3 part5_test/run_all_tests.py

echo ""
echo "📊 测试完成！查看结果："
echo "  📄 综合报告: part5_test/Chapter5_Test_Report.md"
echo "  📊 详细数据: part5_test/chapter5_comprehensive_report.json"
echo "  📁 各项结果: part5_test/5.*.results.json"
echo ""
echo "✅ 第五章实验测试全部完成！"