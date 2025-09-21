# EXPLAIN CACHE 功能测试

## 测试查询缓存的EXPLAIN功能

### 基本测试
```sql
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 执行一些查询来填充缓存
SELECT 1 as test_value;
SELECT 2 as another_value;
SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2) t;

-- 查看缓存状态
EXPLAIN CACHE;

-- 使用不同格式查看缓存状态
EXPLAIN (CACHE, FORMAT JSON);
EXPLAIN (CACHE, FORMAT HTML);
```

### 预期输出
EXPLAIN CACHE 应该显示：
1. 缓存配置信息（是否启用、最大条目数、TTL等）
2. 缓存统计信息（命中率、内存使用等）
3. 缓存条目详情（查询哈希、访问次数、ML分数等）
4. Bloom Filter信息
5. ML预测器信息（如果启用ML策略）
6. 自适应调优信息（如果启用）

### 功能特点
- 支持多种输出格式（TEXT、JSON、HTML）
- 显示详细的缓存内部状态
- 包含ML和自适应调优的高级信息
- 提供缓存性能分析数据

### 使用场景
1. 调试查询缓存性能问题
2. 监控缓存使用情况
3. 优化缓存配置参数
4. 分析查询模式和缓存效果