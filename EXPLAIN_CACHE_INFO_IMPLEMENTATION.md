# EXPLAIN中的查询缓存信息显示功能

## 功能概述

我们成功为DuckDB的EXPLAIN功能添加了查询缓存信息显示，现在EXPLAIN ANALYZE会显示查询的缓存状态和统计信息。

## 实现的功能

### 1. 缓存状态显示
- **Cache: HIT** - 查询结果来自缓存
- **Cache: MISS** - 查询未命中缓存，需要执行查询

### 2. 缓存统计信息
- 显示缓存条目总数
- 显示缓存命中率
- 显示缓存键信息（部分显示）

### 3. 支持的输出格式
- **TEXT格式**: 在EXPLAIN ANALYZE的文本输出中显示缓存信息
- **JSON格式**: 在JSON输出中包含完整的缓存信息对象

## 技术实现

### 1. 修改的核心文件

#### QueryProfiler相关
- `src/include/duckdb/main/query_profiler.hpp`: 添加缓存信息字段到QueryInfo结构
- `src/main/query_profiler.cpp`: 实现缓存信息设置和显示逻辑

#### ClientContext相关  
- `src/main/client_context.cpp`: 在查询执行时设置缓存命中/未命中信息

### 2. 关键数据结构

```cpp
struct QueryInfo {
    string query_name;
    ProfilingInfo query_global_info;
    //! Whether this query was served from cache
    bool cache_hit;
    //! Cache key used for this query (if cacheable)
    string cache_key;
    //! Cache statistics at query time
    struct CacheStats {
        idx_t total_entries = 0;
        idx_t total_hits = 0;
        idx_t total_misses = 0;
        double hit_rate = 0.0;
    } cache_stats;
};
```

### 3. 关键方法

```cpp
// 设置缓存信息
void QueryProfiler::SetCacheInfo(bool cache_hit, const string &cache_key);

// 在TEXT格式输出中显示缓存信息
void QueryProfiler::QueryTreeToStream(std::ostream &ss) const;

// 在JSON格式输出中包含缓存信息
string QueryProfiler::ToJSON() const;
```

## 使用示例

### 基本使用
```sql
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 执行EXPLAIN ANALYZE查看缓存信息
EXPLAIN ANALYZE SELECT COUNT(*) FROM my_table;
```

### 输出示例

#### TEXT格式输出
```
┌────────────────────────────────────────────────┐
│┌──────────────────────────────────────────────┐│
││              Total Time: 0.0282s             ││
││                  Cache: MISS                 ││
││        Cache Stats: 5 entries, 80.0% hit rate││
│└──────────────────────────────────────────────┘│
└────────────────────────────────────────────────┘
```

#### JSON格式输出
```json
{
  "cache_info": {
    "cache_hit": false,
    "cache_key": "16058505074873977230",
    "statistics": {
      "total_entries": 5,
      "total_hits": 4,
      "total_misses": 1,
      "hit_rate": 0.8
    }
  },
  "children": [...]
}
```

## 重要说明

### EXPLAIN ANALYZE的缓存行为
- **EXPLAIN ANALYZE不会使用缓存的结果**，因为它需要实际执行查询来收集性能数据
- 显示的缓存信息反映的是查询执行时的缓存状态
- 缓存状态通常显示为"MISS"，因为EXPLAIN ANALYZE需要重新执行查询

### 缓存信息的含义
- **Cache: HIT**: 表示相同的查询之前已被缓存
- **Cache: MISS**: 表示这是首次执行该查询或缓存已过期
- **Cache Stats**: 显示整个缓存系统的统计信息

## 测试验证

### 测试脚本
```bash
#!/bin/bash
echo "PRAGMA enable_query_cache = true; EXPLAIN ANALYZE SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;" | ./build/release/duckdb
```

### 验证结果
- ✅ 缓存信息正确显示在EXPLAIN ANALYZE输出中
- ✅ TEXT格式输出包含缓存状态和统计信息
- ✅ JSON格式输出包含完整的缓存信息对象
- ✅ 缓存命中/未命中状态正确跟踪

## 未来改进方向

1. **缓存预测信息**: 显示查询是否适合缓存
2. **缓存性能影响**: 显示缓存对查询性能的影响
3. **缓存策略信息**: 显示使用的缓存策略和配置
4. **缓存键详情**: 提供更详细的缓存键信息

## 总结

这个功能为DuckDB的查询分析提供了重要的缓存可见性，帮助用户：
- 了解查询是否受益于缓存
- 监控缓存系统的性能
- 调试缓存相关的问题
- 优化查询缓存配置

通过在EXPLAIN ANALYZE中显示缓存信息，用户现在可以更好地理解查询执行的完整图景，包括缓存系统的作用。