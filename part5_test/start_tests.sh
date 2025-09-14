#!/bin/bash
"""
第五章测试启动脚本
快速启动所有第五章的实验测试
"""

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}第五章 实验与分析 - 测试启动脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# 检查Python环境
echo -e "${YELLOW}检查Python环境...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: Python3 未安装${NC}"
    exit 1
fi

# 检查必要的Python包
echo -e "${YELLOW}检查Python依赖...${NC}"
python3 -c "import duckdb, psutil, json, statistics" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}安装必要的Python包...${NC}"
    pip3 install duckdb psutil
fi

# 检查测试数据库
echo -e "${YELLOW}检查测试数据库...${NC}"
if [ ! -f "/Users/max/test/tpc/tpch-sf1.db" ]; then
    echo -e "${YELLOW}警告: TPC-H测试数据库未找到，部分测试可能无法运行${NC}"
fi

# 检查TPC-H查询文件
echo -e "${YELLOW}检查TPC-H查询文件...${NC}"
if [ ! -d "/Users/max/src/duckdb/extension/tpch/dbgen/queries" ]; then
    echo -e "${YELLOW}警告: TPC-H查询文件未找到，将使用模拟数据${NC}"
fi

# 创建测试目录
echo -e "${YELLOW}创建测试目录...${NC}"
mkdir -p part5_test

# 设置权限
chmod +x part5_test/*.py

echo -e "${GREEN}环境检查完成！${NC}"
echo ""

# 显示测试选项
echo -e "${BLUE}请选择测试模式:${NC}"
echo "1. 运行所有测试 (推荐)"
echo "2. 运行单个测试"
echo "3. 快速验证测试"
echo "4. 查看测试说明"
echo ""

read -p "请输入选择 (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}开始运行所有测试...${NC}"
        python3 part5_test/run_all_tests.py
        ;;
    2)
        echo -e "${BLUE}可用的测试脚本:${NC}"
        echo "1. 5.1.platform_setup.py - 实验平台搭建测试"
        echo "2. 5.2.cache_performance.py - 动态缓存性能测试"
        echo "3. 5.3.bloom_filter.py - 布隆过滤器测试"
        echo "4. 5.4.sql_cache.py - SQL缓存技术测试"
        echo "5. 5.7.persistence.py - 持久化策略测试"
        echo "6. 5.8.comprehensive.py - 综合性能评估"
        echo ""
        read -p "请选择要运行的测试 (1-6): " test_choice
        
        case $test_choice in
            1) python3 part5_test/5.1.platform_setup.py ;;
            2) python3 part5_test/5.2.cache_performance.py ;;
            3) python3 part5_test/5.3.bloom_filter.py ;;
            4) python3 part5_test/5.4.sql_cache.py ;;
            5) python3 part5_test/5.7.persistence.py ;;
            6) python3 part5_test/5.8.comprehensive.py ;;
            *) echo -e "${RED}无效选择${NC}" ;;
        esac
        ;;
    3)
        echo -e "${GREEN}运行快速验证测试...${NC}"
        python3 part5_test/5.1.platform_setup.py
        echo -e "${GREEN}快速验证完成！${NC}"
        ;;
    4)
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}第五章测试说明${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo ""
        echo -e "${GREEN}测试脚本说明:${NC}"
        echo "• 5.1.platform_setup.py: 测试实验平台的硬件、软件环境配置"
        echo "• 5.2.cache_performance.py: 测试动态缓存技术的性能表现"
        echo "• 5.3.bloom_filter.py: 测试布隆过滤器的假阳性率和过滤效率"
        echo "• 5.4.sql_cache.py: 测试SQL标准化和CTE缓存技术"
        echo "• 5.7.persistence.py: 测试不同持久化策略的性能"
        echo "• 5.8.comprehensive.py: 综合性能评估和对比分析"
        echo ""
        echo -e "${GREEN}测试结果:${NC}"
        echo "• 测试结果保存在 part5_test/ 目录下"
        echo "• JSON格式结果文件: 5.*.results.json"
        echo "• 综合报告: chapter5_comprehensive_report.json"
        echo "• Markdown报告: Chapter5_Test_Report.md"
        echo ""
        echo -e "${GREEN}使用建议:${NC}"
        echo "• 首次运行建议选择 '运行所有测试'"
        echo "• 如需调试特定功能，可选择 '运行单个测试'"
        echo "• 测试完成后查看生成的报告文件"
        ;;
    *)
        echo -e "${RED}无效选择，退出${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}测试完成！${NC}"
echo -e "${BLUE}查看测试结果:${NC}"
echo "• 详细结果: part5_test/chapter5_comprehensive_report.json"
echo "• 报告文档: part5_test/Chapter5_Test_Report.md"
echo "• 各项测试结果: part5_test/5.*.results.json"