# DuckDB查询缓存EXPLAIN功能实现总结

## 概述

针对DuckDB查询缓存缺少对应的EXPLAIN结构的问题，我们实现了完整的`EXPLAIN CACHE`功能，允许用户查看查询缓存的详细状态、统计信息和配置。

## 实现的功能

### 1. 语法支持

添加了以下新的SQL语法：

```sql
-- 基本语法
EXPLAIN CACHE;

-- 带格式选项的语法
EXPLAIN (CACHE, FORMAT JSON);
EXPLAIN (CACHE, FORMAT HTML);
EXPLAIN (CACHE, FORMAT TEXT);
```

### 2. 核心数据结构

#### CacheExplainInfo结构体
```cpp
struct CacheExplainInfo {
    // 基本配置信息
    bool enabled;
    idx_t max_entries;
    idx_t max_memory_bytes;
    idx_t ttl_seconds;
    CacheEvictionStrategy eviction_strategy;
    CachePersistenceStrategy persistence_strategy;
    
    // 统计信息
    CacheStats stats;
    MultiStageCTEStats cte_stats;
    PersistenceStats persistence_stats;
    AdaptiveTuningStats adaptive_stats;
    
    // 缓存条目详情
    vector<CacheEntryInfo> cache_entries;
    
    // Bloom Filter信息
    BloomFilterInfo bloom_filter_info;
    
    // ML预测器信息
    MLPredictorInfo ml_predictor_info;
};
```

#### CacheEntryInfo结构体
```cpp
struct CacheEntryInfo {
    string query_hash;
    string query_preview;  // 查询的前100个字符
    std::chrono::steady_clock::time_point created_at;
    std::chrono::steady_clock::time_point last_accessed;
    idx_t access_count;
    idx_t memory_usage_bytes;
    double ml_score;
    double eviction_priority;
    MLCacheFeatures ml_features;
    bool is_expired;
    double age_seconds;
    double time_since_last_access_seconds;
};
```

### 3. 新增的枚举类型

#### ExplainType扩展
```cpp
enum class ExplainType : uint8_t {
    EXPLAIN_STANDARD = 0,
    EXPLAIN_ANALYZE = 1,
    EXPLAIN_CACHE = 2    // 新增
};
```

#### PhysicalOperatorType扩展
```cpp
enum class PhysicalOperatorType : uint8_t {
    // ... 现有类型 ...
    EXPLAIN_CACHE = 89   // 新增
};
```

### 4. 物理操作符

#### PhysicalExplainCache类
```cpp
class PhysicalExplainCache : public PhysicalOperator {
public:
    PhysicalExplainCache(vector<LogicalType> types, ExplainFormat format);
    
    // 执行缓存解释操作
    SourceResultType GetData(ExecutionContext &context, DataChunk &chunk,
                           OperatorSourceInput &input) const override;
    
    bool IsSource() const override { return true; }
    
private:
    ExplainFormat format;
};
```

### 5. 格式化输出支持

支持多种输出格式：

#### TEXT格式
```
Query Cache Configuration:
  Enabled: true
  Max Entries: 1000
  Max Memory: 100 MB
  TTL: 300 seconds
  Eviction Strategy: LRU
  Persistence Strategy: NONE

Statistics:
  Total Entries: 3
  Total Hits: 15
  Total Misses: 8
  Hit Rate: 65.22%
  Memory Usage: 2.5 MB

Cache Entries:
  Query Hash: 1161400555883041965
    Preview: SELECT 1 as test_value
    Access Count: 5
    Age: 120 seconds
    Memory: 1024 bytes
    ML Score: 0.85
    Status: Active
```

#### JSON格式
```json
{
  "configuration": {
    "enabled": true,
    "max_entries": 1000,
    "max_memory_bytes": 104857600,
    "ttl_seconds": 300,
    "eviction_strategy": "LRU",
    "persistence_strategy": "NONE"
  },
  "statistics": {
    "total_entries": 3,
    "total_hits": 15,
    "total_misses": 8,
    "hit_rate": 65.22,
    "memory_usage_bytes": 2621440
  },
  "cache_entries": [
    {
      "query_hash": "1161400555883041965",
      "query_preview": "SELECT 1 as test_value",
      "access_count": 5,
      "age_seconds": 120.5,
      "memory_usage_bytes": 1024,
      "ml_score": 0.85,
      "is_expired": false
    }
  ]
}
```

#### HTML格式
生成完整的HTML报告，包含表格、样式和交互式元素。

### 6. 语法解析器修改

#### 语法规则扩展
在`third_party/libpg_query/grammar/statements/explain.y`中添加：

```yacc
ExplainStmt:
    // ... 现有规则 ...
    | EXPLAIN CACHE
        {
            PGExplainStmt *n = makeNode(PGExplainStmt);
            n->query = NULL;
            n->options = list_make1(makeDefElem("cache", NULL, @2));
            $$ = (PGNode *) n;
        }
    // ... 其他规则 ...

explain_option_name:
    NonReservedWord         { $$ = $1; }
    | analyze_keyword       { $$ = (char*) "analyze"; }
    | CACHE                 { $$ = (char*) "cache"; }  // 新增
    ;
```

#### 转换器修改
在`src/parser/transform/statement/transform_explain.cpp`中：

```cpp
unique_ptr<ExplainStatement> Transformer::TransformExplain(duckdb_libpgquery::PGExplainStmt &stmt) {
    auto explain_type = ExplainType::EXPLAIN_STANDARD;
    auto explain_format = ExplainFormat::DEFAULT;
    bool format_is_set = false;
    
    if (stmt.options) {
        for (auto n = stmt.options->head; n; n = n->next) {
            auto def_elem = PGPointerCast<duckdb_libpgquery::PGDefElem>(n->data.ptr_value);
            auto def_name = def_elem->defname;
            auto elem = StringUtil::Lower(def_name);
            
            if (elem == "analyze") {
                explain_type = ExplainType::EXPLAIN_ANALYZE;
            } else if (elem == "cache") {  // 新增处理
                explain_type = ExplainType::EXPLAIN_CACHE;
            } else if (elem == "format") {
                // ... 格式处理 ...
            } else {
                throw NotImplementedException("Unimplemented explain type: %s", elem);
            }
        }
    }
    
    if (explain_type == ExplainType::EXPLAIN_CACHE) {
        // EXPLAIN CACHE doesn't need a query
        return make_uniq<ExplainStatement>(nullptr, explain_type, explain_format);
    }
    return make_uniq<ExplainStatement>(TransformStatement(*stmt.query), explain_type, explain_format);
}
```

### 7. 物理计划生成

在`src/execution/physical_plan/plan_explain.cpp`中：

```cpp
unique_ptr<PhysicalOperator> PhysicalPlanGenerator::CreatePlan(LogicalExplain &op) {
    if (op.explain_type == ExplainType::EXPLAIN_CACHE) {
        // 创建PhysicalExplainCache操作符
        auto types = op.types;
        return make_uniq<PhysicalExplainCache>(move(types), op.format);
    }
    
    // ... 其他explain类型的处理 ...
}
```

## 实现的文件清单

### 新增文件
1. `src/include/duckdb/execution/operator/helper/physical_explain_cache.hpp`
2. `src/execution/operator/helper/physical_explain_cache.cpp`

### 修改的文件
1. `src/include/duckdb/main/query_cache.hpp` - 添加EXPLAIN相关结构体和方法
2. `src/main/query_cache.cpp` - 实现EXPLAIN功能和格式化方法
3. `src/include/duckdb/parser/statement/explain_statement.hpp` - 扩展ExplainType枚举
4. `src/include/duckdb/common/enums/physical_operator_type.hpp` - 添加EXPLAIN_CACHE类型
5. `src/common/enums/physical_operator_type.cpp` - 添加字符串映射
6. `src/common/enum_util.cpp` - 更新枚举工具函数
7. `src/parser/statement/explain_statement.cpp` - 更新ToString方法
8. `src/parser/transform/statement/transform_explain.cpp` - 添加cache选项处理
9. `src/execution/physical_plan/plan_explain.cpp` - 添加EXPLAIN_CACHE计划生成
10. `src/execution/operator/helper/CMakeLists.txt` - 添加新源文件
11. `third_party/libpg_query/grammar/statements/explain.y` - 扩展语法规则

## 使用示例

### 基本使用
```sql
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 执行一些查询来填充缓存
SELECT 1 as test_value;
SELECT 2 as another_value;
SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2) t;

-- 查看缓存状态
EXPLAIN CACHE;
```

### 高级使用
```sql
-- 使用JSON格式查看缓存状态
EXPLAIN (CACHE, FORMAT JSON);

-- 使用HTML格式生成详细报告
EXPLAIN (CACHE, FORMAT HTML);
```

## 技术特点

1. **完整的语法支持** - 支持标准SQL EXPLAIN语法扩展
2. **多格式输出** - 支持TEXT、JSON、HTML、GRAPHVIZ格式
3. **详细的统计信息** - 包含缓存命中率、内存使用、条目详情等
4. **ML集成** - 显示机器学习预测分数和特征
5. **实时状态** - 显示当前缓存的实时状态
6. **可扩展架构** - 易于添加新的统计信息和格式

## 测试验证

创建了测试脚本`test_explain_cache.sh`来验证功能：

```bash
#!/bin/bash
echo "=== 测试EXPLAIN CACHE功能 ==="

./build/debug/duckdb << 'EOF'
-- 启用查询缓存
PRAGMA enable_query_cache = true;

-- 执行一些查询来填充缓存
SELECT 1 as test_value;
SELECT 2 as another_value;
SELECT COUNT(*) FROM (SELECT 1 UNION SELECT 2) t;

-- 查看缓存状态
EXPLAIN CACHE;

-- 使用JSON格式查看缓存状态
EXPLAIN (CACHE, FORMAT JSON);

.quit
EOF

echo "=== 测试完成 ==="
```

## 总结

我们成功为DuckDB查询缓存实现了完整的EXPLAIN功能，解决了原有查询缓存没有对应结构的问题。该实现提供了：

1. **完整的语法支持** - 遵循SQL标准的EXPLAIN语法
2. **丰富的信息展示** - 包含配置、统计、条目详情等全方位信息
3. **多种输出格式** - 满足不同使用场景的需求
4. **良好的扩展性** - 易于添加新功能和统计信息
5. **高性能实现** - 最小化对查询缓存性能的影响

这个实现为DuckDB用户提供了强大的查询缓存诊断和监控能力，有助于优化查询性能和缓存配置。