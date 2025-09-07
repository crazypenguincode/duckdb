# DuckDB 查询缓存策略实现

本项目实现了三种不同的查询缓存更新策略，用于优化DuckDB的查询性能。

## 实现的缓存策略

### 1. TTL-based (Time-To-Live) 策略
- **原理**: 基于时间过期的缓存策略
- **特点**: 
  - 每个缓存条目都有固定的生存时间
  - 超过TTL时间的条目会被自动清除
  - 适合数据更新频率相对固定的场景
- **优势**: 简单可靠，内存使用可预测
- **劣势**: 可能清除仍有价值的缓存条目

### 2. LRU-based (Least Recently Used) 策略
- **原理**: 最近最少使用的缓存淘汰策略
- **特点**:
  - 跟踪每个缓存条目的访问时间
  - 当需要淘汰时，优先清除最久未访问的条目
  - 适合有明显访问模式的工作负载
- **优势**: 能保留热点数据，提高缓存命中率
- **劣势**: 对于访问模式复杂的场景效果有限

### 3. ML-based (Machine Learning) 策略
- **原理**: 基于机器学习的智能缓存策略
- **特点**:
  - 使用线性回归模型预测查询的缓存价值
  - 考虑多个特征：查询复杂度、执行时间、结果大小、访问频率等
  - 动态学习和适应查询模式
- **优势**: 能适应复杂的查询模式，智能决策
- **劣势**: 计算开销较大，需要训练时间

## 文件结构

```
src/include/duckdb/main/query_cache.hpp    # 缓存系统头文件
src/main/query_cache.cpp                   # 缓存系统实现
test_cache_strategies.cpp                  # 性能测试程序
test_cache.sql                            # SQL测试用例
test_cache_strategies.sh                  # 构建和测试脚本
```

## 核心数据结构

### MLCacheFeatures
机器学习特征结构，包含：
- `query_complexity_score`: 查询复杂度评分
- `execution_time_ms`: 查询执行时间
- `result_size_bytes`: 结果集大小
- `access_frequency`: 访问频率
- `temporal_locality`: 时间局部性
- `table_count`: 涉及表数量
- `join_count`: 连接操作数量
- `has_aggregation`: 是否包含聚合
- `has_subquery`: 是否包含子查询

### MLCachePredictor
机器学习预测器，实现：
- 线性回归模型
- 梯度下降优化
- 特征权重自适应调整

## 使用方法

### 1. 编译和测试
```bash
# 运行完整测试
./test_cache_strategies.sh

# 或者手动编译
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc) duckdb
g++ -std=c++17 -I../src/include -L. -lduckdb -pthread ../test_cache_strategies.cpp -o test_cache_strategies
./test_cache_strategies
```

### 2. 在代码中使用
```cpp
// 创建不同策略的缓存
QueryCacheConfig config;
config.eviction_strategy = CacheEvictionStrategy::ML_BASED;
auto cache = make_uniq<QueryCache>(config);

// 缓存查询结果
MLCacheFeatures features;
features.query_complexity_score = 0.7;
features.execution_time_ms = 150.0;
// ... 设置其他特征
cache->CacheResult(query_hash, std::move(result), features);

// 获取缓存结果
auto cached_result = cache->GetCachedResult(query_hash);
```

### 3. 配置参数
```cpp
QueryCacheConfig config;
config.max_entries = 1000;                    // 最大缓存条目数
config.max_memory_bytes = 100 * 1024 * 1024; // 最大内存使用
config.ttl_seconds = 3600;                   // TTL时间（秒）
config.eviction_strategy = CacheEvictionStrategy::ML_BASED;
config.ml_learning_rate = 0.01;              // ML学习率
config.ml_decay_factor = 0.95;               // ML衰减因子
```

## 性能测试结果

测试程序会生成详细的性能对比报告，包括：

### 关键指标
- **命中率 (Hit Rate)**: 缓存命中的查询比例
- **平均执行时间**: 包含缓存查找的总执行时间
- **内存使用**: 缓存占用的内存大小
- **淘汰次数**: 各策略的缓存淘汰统计

### 预期结果
1. **TTL策略**: 
   - 命中率: 中等
   - 内存使用: 稳定
   - 适用场景: 数据更新周期固定

2. **LRU策略**:
   - 命中率: 较高
   - 内存使用: 动态
   - 适用场景: 明显的热点查询

3. **ML策略**:
   - 命中率: 最高
   - 内存使用: 智能优化
   - 适用场景: 复杂多变的查询模式

## 扩展和优化

### 可能的改进方向
1. **更复杂的ML模型**: 使用神经网络或决策树
2. **在线学习**: 实时调整模型参数
3. **多级缓存**: 结合不同策略的分层缓存
4. **查询相似性**: 基于查询语义的缓存共享
5. **成本感知**: 考虑查询执行成本的缓存决策

### 监控和调试
- 使用 `GetStats()` 方法获取详细统计信息
- 通过日志跟踪缓存行为
- 调整ML模型参数以适应特定工作负载

## 注意事项

1. **线程安全**: 所有缓存操作都是线程安全的
2. **内存管理**: 缓存会自动管理内存使用，防止内存泄漏
3. **查询兼容性**: 只有SELECT类型的查询会被缓存
4. **参数绑定**: 支持参数化查询的缓存
5. **事务隔离**: 缓存结果不会影响事务的ACID特性

## 测试覆盖

- 单元测试: 各个组件的功能测试
- 性能测试: 不同工作负载下的性能对比
- 压力测试: 高并发场景下的稳定性测试
- 内存测试: 内存使用和泄漏检测

通过这个实现，DuckDB的查询缓存系统能够根据不同的应用场景选择最适合的缓存策略，从而显著提升查询性能。