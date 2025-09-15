-- 创建测试数据库表结构
-- 用于第五章表5.7的四种数据集类型测试

-- 简单测试表
CREATE TABLE IF NOT EXISTS simple_test (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    value INTEGER,
    category VARCHAR(50),
    created_date DATE
);

-- 产品表
CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INTEGER,
    price DECIMAL(10,2),
    stock_quantity INTEGER,
    supplier_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(12,2),
    status VARCHAR(20),
    shipping_address TEXT
);

-- 订单详情表
CREATE TABLE IF NOT EXISTS order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 客户表
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(20),
    address TEXT,
    registration_date DATE
);

-- 分类表
CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100),
    parent_category_id INTEGER,
    description TEXT
);

-- 供应商表
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(150),
    address TEXT
);

-- 销售统计表（用于复杂查询测试）
CREATE TABLE IF NOT EXISTS sales_summary (
    summary_id INTEGER PRIMARY KEY,
    date_key DATE,
    product_id INTEGER,
    customer_id INTEGER,
    sales_amount DECIMAL(12,2),
    quantity_sold INTEGER,
    profit_margin DECIMAL(5,2)
);

-- 插入测试数据
INSERT INTO categories VALUES 
(1, '电子产品', NULL, '各类电子设备'),
(2, '服装', NULL, '男女服装'),
(3, '图书', NULL, '各类书籍'),
(4, '手机', 1, '智能手机'),
(5, '电脑', 1, '台式机和笔记本');

INSERT INTO suppliers VALUES
(1, '科技供应商A', '张三', '13800138001', 'supplier1@test.com', '北京市朝阳区'),
(2, '服装供应商B', '李四', '13800138002', 'supplier2@test.com', '上海市浦东区'),
(3, '图书供应商C', '王五', '13800138003', 'supplier3@test.com', '广州市天河区');

-- 生成产品数据
INSERT INTO products (product_id, product_name, category_id, price, stock_quantity, supplier_id)
SELECT 
    i+1,
    'Product_' || (i+1),
    (i % 5) + 1,
    ROUND(RANDOM() * 1000 + 10, 2),
    ROUND(RANDOM() * 100 + 1),
    (i % 3) + 1
FROM range(1000) AS t(i);

-- 生成客户数据
INSERT INTO customers (customer_id, customer_name, email, phone, address, registration_date)
SELECT 
    i+1,
    'Customer_' || (i+1),
    'customer' || (i+1) || '@test.com',
    '138' || LPAD((i+1)::text, 8, '0'),
    'Address_' || (i+1),
    DATE '2020-01-01' + (RANDOM() * 1000)::INTEGER
FROM range(500) AS t(i);

-- 生成订单数据
INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
SELECT 
    i+1,
    (RANDOM() * 500 + 1)::INTEGER,
    DATE '2023-01-01' + (RANDOM() * 365)::INTEGER,
    ROUND(RANDOM() * 5000 + 100, 2),
    CASE (RANDOM() * 4)::INTEGER
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        ELSE 'delivered'
    END
FROM range(2000) AS t(i);

-- 生成订单详情数据
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price)
SELECT 
    i+1,
    (RANDOM() * 2000 + 1)::INTEGER,
    (RANDOM() * 1000 + 1)::INTEGER,
    (RANDOM() * 10 + 1)::INTEGER,
    ROUND(RANDOM() * 500 + 10, 2)
FROM range(5000) AS t(i);

-- 生成简单测试数据
INSERT INTO simple_test (id, name, value, category, created_date)
SELECT 
    i+1,
    'Test_' || (i+1),
    (RANDOM() * 1000)::INTEGER,
    CASE (RANDOM() * 3)::INTEGER
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        ELSE 'C'
    END,
    DATE '2023-01-01' + (RANDOM() * 365)::INTEGER
FROM range(10000) AS t(i);

-- 生成销售统计数据
INSERT INTO sales_summary (summary_id, date_key, product_id, customer_id, sales_amount, quantity_sold, profit_margin)
SELECT 
    i,
    DATE '2023-01-01' + (RANDOM() * 365)::INTEGER,
    (RANDOM() * 1000 + 1)::INTEGER,
    (RANDOM() * 500 + 1)::INTEGER,
    ROUND(RANDOM() * 10000 + 100, 2),
    (RANDOM() * 50 + 1)::INTEGER,
    ROUND(RANDOM() * 30 + 5, 2)
FROM generate_series(1, 10000) AS i;

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales_summary(date_key);
CREATE INDEX IF NOT EXISTS idx_sales_product ON sales_summary(product_id);
CREATE INDEX IF NOT EXISTS idx_simple_category ON simple_test(category);
CREATE INDEX IF NOT EXISTS idx_simple_date ON simple_test(created_date);