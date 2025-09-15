#!/bin/bash
# 并发测试批处理脚本

DB_PATH="$1"
if [ -z "$DB_PATH" ]; then
    echo "Usage: $0 <database_path>"
    exit 1
fi

echo "开始并发测试..."
echo "数据库路径: $DB_PATH"
echo "测试时间: $(date)"
echo

# 测试所有场景
scenarios=("高并发轻量查询" "中等并发混合查询" "低并发重型查询" "混合负载测试" "缓存命中测试")

for scenario in "${scenarios[@]}"; do
    echo "正在测试场景: $scenario"
    python3 concurrent_test.py "$DB_PATH" "$scenario"
    echo "等待5秒后开始下一个测试..."
    sleep 5
    echo
done

echo "所有并发测试完成！"
