#!/bin/bash

# 动态更新策略测试运行脚本
# 用于执行第五章5.6节的动态更新策略测试

echo "=========================================="
echo "动态更新策略测试 - 第五章5.6节"
echo "=========================================="

# 设置脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到python3命令"
    exit 1
fi

# 检查DuckDB可执行文件
DUCKDB_PATH="$PROJECT_ROOT/build/release/duckdb"
if [ ! -f "$DUCKDB_PATH" ]; then
    echo "错误: 未找到DuckDB可执行文件: $DUCKDB_PATH"
    echo "请先编译DuckDB项目"
    exit 1
fi

# 创建必要的目录
mkdir -p "$PROJECT_ROOT/part5_test/results"
mkdir -p "$PROJECT_ROOT/part5_test/dataset"

# 检查测试数据库
TEST_DB="$PROJECT_ROOT/part5_test/test_cache.db"
if [ ! -f "$TEST_DB" ]; then
    echo "创建测试数据库..."
    
    # 创建基础测试数据
    cat << 'EOF' | "$DUCKDB_PATH" "$TEST_DB"
-- 创建测试表
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    registration_date DATE
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INTEGER
);

-- 插入测试数据
INSERT INTO customers 
SELECT 
    i as customer_id,
    'Customer_' || i as customer_name,
    'customer' || i || '@example.com' as email,
    DATE '2020-01-01' + INTERVAL (i % 1000) DAY as registration_date
FROM range(1, 10001) t(i);

INSERT INTO orders
SELECT 
    i as order_id,
    (i % 10000) + 1 as customer_id,
    DATE '2023-01-01' + INTERVAL (i % 365) DAY as order_date,
    (random() * 1000 + 10)::DECIMAL(10,2) as total_amount,
    CASE (i % 4) 
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        ELSE 'delivered'
    END as status
FROM range(1, 50001) t(i);

INSERT INTO products
SELECT 
    i as product_id,
    'Product_' || i as product_name,
    CASE (i % 5)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Books'
        WHEN 3 THEN 'Home'
        ELSE 'Sports'
    END as category,
    (random() * 500 + 10)::DECIMAL(10,2) as price,
    (random() * 100 + 1)::INTEGER as stock_quantity
FROM range(1, 5001) t(i);

-- 创建索引
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);

.quit
EOF
    
    echo "测试数据库创建完成"
fi

# 运行动态策略测试
echo "开始执行动态更新策略测试..."
echo "预计耗时: 10-15分钟"
echo ""

cd "$SCRIPT_DIR"
python3 dynamic_update_strategy_test.py

# 检查测试结果
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "测试完成！"
    echo "=========================================="
    echo "结果文件位置: $PROJECT_ROOT/part5_test/results/"
    echo ""
    echo "生成的文件包括:"
    echo "- dynamic_update_strategy_*.json (详细测试结果)"
    echo "- dynamic_strategy_summary_*.csv (结果摘要)"
    echo "- dynamic_strategy_report_*.md (测试报告)"
    echo ""
    echo "可以使用以下命令查看最新结果:"
    echo "ls -la $PROJECT_ROOT/part5_test/results/dynamic_*"
else
    echo ""
    echo "测试执行失败，请检查错误信息"
    exit 1
fi