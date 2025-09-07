-- Test cache strategies with real SQL queries
-- This file tests the three cache eviction strategies: TTL, LRU, and ML-based

-- Create test tables
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    active BOOLEAN,
    created_at TIMESTAMP
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    amount DECIMAL(10,2),
    order_date DATE,
    status VARCHAR(50)
);

-- Insert test data
INSERT INTO users VALUES 
(1, 'Alice Johnson', 'alice@example.com', true, '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', true, '2023-02-20'),
(3, 'Charlie Brown', 'charlie@example.com', false, '2023-03-10'),
(4, 'Diana Prince', 'diana@example.com', true, '2023-04-05'),
(5, 'Eve Wilson', 'eve@example.com', true, '2023-05-12');

INSERT INTO orders VALUES
(1, 1, 150.00, '2023-06-01', 'completed'),
(2, 1, 75.50, '2023-06-15', 'completed'),
(3, 2, 200.00, '2023-06-10', 'pending'),
(4, 3, 50.25, '2023-06-20', 'cancelled'),
(5, 4, 300.75, '2023-06-25', 'completed'),
(6, 2, 125.00, '2023-07-01', 'completed'),
(7, 5, 89.99, '2023-07-05', 'pending'),
(8, 1, 175.25, '2023-07-10', 'completed');

-- Test queries for cache evaluation

-- High frequency, simple queries (should be cached well by all strategies)
SELECT * FROM users WHERE id = 1;
SELECT * FROM users WHERE id = 2;
SELECT name FROM users WHERE active = true;
SELECT COUNT(*) FROM users;

-- Medium frequency, medium complexity queries
SELECT u.name, COUNT(o.id) as order_count 
FROM users u 
LEFT JOIN orders o ON u.id = o.user_id 
GROUP BY u.name;

SELECT u.name, o.amount, o.order_date
FROM users u 
JOIN orders o ON u.id = o.user_id 
WHERE o.status = 'completed';

-- Low frequency, complex queries (ML strategy should handle these better)
WITH user_stats AS (
    SELECT 
        u.id,
        u.name,
        COUNT(o.id) as total_orders,
        COALESCE(SUM(o.amount), 0) as total_spent,
        COALESCE(AVG(o.amount), 0) as avg_order_value
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id AND o.status = 'completed'
    GROUP BY u.id, u.name
)
SELECT 
    name,
    total_orders,
    total_spent,
    avg_order_value,
    CASE 
        WHEN total_spent > 200 THEN 'High Value'
        WHEN total_spent > 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_tier
FROM user_stats
ORDER BY total_spent DESC;

-- Very complex query with subqueries (rare, but valuable to cache)
SELECT 
    u.name,
    u.email,
    recent_order.amount as last_order_amount,
    recent_order.order_date as last_order_date,
    user_totals.total_spent,
    user_totals.order_count
FROM users u
JOIN (
    SELECT 
        user_id,
        SUM(amount) as total_spent,
        COUNT(*) as order_count
    FROM orders 
    WHERE status = 'completed'
    GROUP BY user_id
) user_totals ON u.id = user_totals.user_id
JOIN (
    SELECT DISTINCT
        o1.user_id,
        o1.amount,
        o1.order_date
    FROM orders o1
    WHERE o1.order_date = (
        SELECT MAX(o2.order_date)
        FROM orders o2
        WHERE o2.user_id = o1.user_id
        AND o2.status = 'completed'
    )
) recent_order ON u.id = recent_order.user_id
WHERE u.active = true
ORDER BY user_totals.total_spent DESC;

-- Test cache statistics query (should not be cached)
SELECT 'Cache statistics query - should not be cached' as note;

-- Repeat some queries to test cache hits
SELECT * FROM users WHERE id = 1;  -- Should be cache hit
SELECT name FROM users WHERE active = true;  -- Should be cache hit
SELECT COUNT(*) FROM users;  -- Should be cache hit

-- Test temporal patterns (access same queries at different times)
SELECT u.name, o.amount 
FROM users u 
JOIN orders o ON u.id = o.user_id 
WHERE o.order_date >= '2023-06-01';

-- Clean up
-- DROP TABLE orders;
-- DROP TABLE users;