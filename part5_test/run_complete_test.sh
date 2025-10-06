#!/bin/bash

# TPC-H缓存性能测试完整运行脚本
# 作者: AI助手
# 日期: 2025年10月6日

echo "🚀 TPC-H缓存性能测试启动"
echo "=========================="

# 设置工作目录
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"
echo "📁 工作目录: $SCRIPT_DIR"

# 检查环境
echo "🔧 检查测试环境..."

# 检查DuckDB可执行文件
DUCKDB_PATH="/Users/max/src/duckdb/build/release/duckdb"
if [ ! -f "$DUCKDB_PATH" ]; then
    echo "❌ DuckDB可执行文件不存在: $DUCKDB_PATH"
    exit 1
else
    echo "✅ DuckDB可执行文件存在"
fi

# 检查数据库文件
DB_PATH="/Users/max/test/tpc/tpch-sf1.db"
if [ ! -f "$DB_PATH" ]; then
    echo "⚠️  TPC-H数据库文件不存在: $DB_PATH"
    echo "   将使用内存数据库进行演示测试"
    USE_MEMORY_DB=true
else
    echo "✅ TPC-H数据库文件存在"
    USE_MEMORY_DB=false
fi

# 检查查询文件目录
QUERIES_DIR="/Users/max/src/duckdb/extension/tpch/dbgen/queries"
if [ ! -d "$QUERIES_DIR" ]; then
    echo "❌ TPC-H查询目录不存在: $QUERIES_DIR"
    exit 1
else
    echo "✅ TPC-H查询目录存在"
    QUERY_COUNT=$(ls "$QUERIES_DIR"/*.sql 2>/dev/null | wc -l)
    echo "   发现 $QUERY_COUNT 个查询文件"
fi

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
else
    echo "✅ Python3 可用"
    PYTHON_VERSION=$(python3 --version)
    echo "   版本: $PYTHON_VERSION"
fi

echo ""
echo "🧪 开始性能测试..."
echo "=================="

# 终止可能存在的DuckDB进程
echo "🔄 清理环境..."
pkill -f duckdb 2>/dev/null || true
sleep 2

# 选择测试脚本
if [ "$USE_MEMORY_DB" = true ]; then
    TEST_SCRIPT="tpch_cache_working_demo.py"
    echo "📊 使用演示版本测试 (内存数据库)"
else
    TEST_SCRIPT="tpch_cache_final_test.py"
    echo "📊 使用完整版本测试 (文件数据库)"
fi

# 检查测试脚本是否存在
if [ ! -f "$TEST_SCRIPT" ]; then
    echo "❌ 测试脚本不存在: $TEST_SCRIPT"
    echo "可用的测试脚本："
    ls -1 tpch_*.py 2>/dev/null || echo "   无可用脚本"
    exit 1
fi

# 运行测试
echo "🏃 执行测试: $TEST_SCRIPT"
echo "开始时间: $(date)"
echo ""

# 设置超时时间 (30分钟)
timeout 1800 python3 "$TEST_SCRIPT"
TEST_EXIT_CODE=$?

echo ""
echo "结束时间: $(date)"

# 检查测试结果
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ 测试完成"
elif [ $TEST_EXIT_CODE -eq 124 ]; then
    echo "⏰ 测试超时 (30分钟)"
else
    echo "❌ 测试失败 (退出码: $TEST_EXIT_CODE)"
fi

# 收集结果文件
echo ""
echo "📋 测试结果文件:"
echo "==============="

RESULT_FILES=(
    "*results*.json"
    "*report*.md"
    "*.log"
)

for pattern in "${RESULT_FILES[@]}"; do
    files=$(ls $pattern 2>/dev/null)
    if [ ! -z "$files" ]; then
        for file in $files; do
            if [ -f "$file" ]; then
                size=$(ls -lh "$file" | awk '{print $5}')
                echo "📄 $file ($size)"
            fi
        done
    fi
done

# 生成简要统计
echo ""
echo "📊 快速统计:"
echo "==========="

# 统计JSON结果文件
for json_file in *results*.json; do
    if [ -f "$json_file" ]; then
        echo "分析文件: $json_file"
        python3 -c "
import json
import sys
try:
    with open('$json_file', 'r') as f:
        data = json.load(f)
    
    if 'results' in data:
        results = data['results']
        total_queries = len(results)
        success_count = 0
        
        for query_id, result in results.items():
            if isinstance(result, dict):
                if 'no_cache_runs' in result:
                    successful_runs = sum(1 for run in result['no_cache_runs'] if run.get('success', False))
                    if successful_runs > 0:
                        success_count += 1
        
        print(f'  总查询数: {total_queries}')
        print(f'  成功查询: {success_count}')
        print(f'  成功率: {success_count/total_queries*100:.1f}%' if total_queries > 0 else '  成功率: N/A')
    else:
        print('  数据格式未识别')
        
except Exception as e:
    print(f'  解析错误: {e}')
" 2>/dev/null
        echo ""
    fi
done

echo "🎉 测试流程完成！"
echo ""
echo "📖 查看详细结果:"
echo "  cat *results*.json | python3 -m json.tool"
echo ""
echo "📈 查看报告:"
echo "  cat TPCH_CACHE_TEST_FINAL_SUMMARY.md"
echo ""
echo "🔄 重新运行测试:"
echo "  ./run_complete_test.sh"