-- 测试查询缓存功能
.timer on

-- 启用查询缓存
SET enable_query_cache = true;
SET query_cache_max_size = '10MB';

-- 显示当前设置
SELECT 'Current cache settings:' as info;
PRAGMA enable_query_cache;
PRAGMA query_cache_max_size;

-- 第一次执行查询（应该不会命中缓存）
SELECT 'First execution (no cache):' as info;
SELECT COUNT(*) FROM generate_series(1, 1000000);

-- 第二次执行相同查询（应该命中缓存）
SELECT 'Second execution (should hit cache):' as info;
SELECT COUNT(*) FROM generate_series(1, 1000000);

-- 第三次执行相同查询（应该命中缓存）
SELECT 'Third execution (should hit cache):' as info;
SELECT COUNT(*) FROM generate_series(1, 1000000);

-- 执行不同的查询（不会命中缓存）
SELECT 'Different query (no cache):' as info;
SELECT COUNT(*) FROM generate_series(1, 500000);

-- 再次执行不同的查询（应该命中缓存）
SELECT 'Same different query (should hit cache):' as info;
SELECT COUNT(*) FROM generate_series(1, 500000);