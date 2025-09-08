# DuckDB查询缓存性能测试套件

这个测试套件用于全面评估DuckDB查询缓存的性能，包括执行时间、内存使用、不同缓存策略的对比等。

## 文件说明

### 主要测试脚本

1. **`test_query_cache_performance.py`** - 主要性能测试
   - 对比启用/禁用缓存的查询执行时间
   - 测试简单查询和TPC-H复杂查询
   - 分析缓存命中率和加速比

2. **`test_cache_memory_analysis.py`** - 内存使用分析
   - 监控缓存对内存使用的影响
   - 测试不同缓存大小的内存开销
   - 生成内存使用图表和报告

3. **`test_cache_strategies.py`** - 缓存策略对比
   - 测试TTL、LRU、ML等不同驱逐策略
   - 对比不同持久化策略的性能
   - 分析最佳策略配置

4. **`run_cache_tests.py`** - 综合测试套件
   - 运行所有测试脚本
   - 生成综合性能报告
   - 提供测试建议和推荐配置

### 辅助脚本

- **`install_test_dependencies.py`** - 安装测试依赖包

## 快速开始

### 1. 安装依赖

```bash
python3 install_test_dependencies.py
```

### 2. 运行完整测试套件

```bash
# 使用TPC-H数据库（如果存在）
python3 run_cache_tests.py --db-path /Users/max/test/tpc/tpch-sf1.db

# 使用内存数据库（自动生成测试数据）
python3 run_cache_tests.py

# 快速测试模式（减少测试时间）
python3 run_cache_tests.py --quick
```

### 3. 运行单独的测试

```bash
# 性能测试
python3 test_query_cache_performance.py --iterations 10

# 内存分析
python3 test_cache_memory_analysis.py --test-scaling

# 策略对比
python3 test_cache_strategies.py --workload-duration 5
```

## 测试参数

### 通用参数

- `--db-path`: TPC-H数据库路径（默认: `/Users/max/test/tpc/tpch-sf1.db`）
- `--output-dir`: 结果输出目录（默认: `cache_test_results`）

### 性能测试参数

- `--iterations`: 每个查询的重复次数（默认: 5）
- `--output`: 结果JSON文件名

### 内存分析参数

- `--iterations`: 测试迭代次数（默认: 3）
- `--test-scaling`: 启用缓存大小扩展测试

### 策略测试参数

- `--workload-duration`: 工作负载持续时间（分钟，默认: 2）

## 测试结果

测试完成后会生成以下文件：

```
cache_test_results/
├── comprehensive_report.json    # 综合测试报告（JSON格式）
├── test_summary.txt            # 文本摘要报告
├── performance_results.json    # 性能测试详细结果
├── strategy_results.json       # 策略测试结果
└── memory_analysis/            # 内存分析结果
    ├── memory_results.json
    ├── memory_report.txt
    ├── memory_comparison.png    # 内存使用对比图
    └── cache_size_scaling.png   # 缓存大小扩展图
```

## 测试内容

### 1. 性能测试

- **简单查询**: COUNT、AVG、MAX等基础聚合查询
- **复杂查询**: TPC-H标准查询（Q1, Q3, Q5, Q6, Q10）
- **对比指标**:
  - 执行时间（平均、最小、最大、标准差）
  - 缓存命中率
  - 加速比
  - 内存使用量

### 2. 内存分析

- **基线内存**: 无缓存时的内存使用
- **缓存开销**: 启用缓存后的额外内存消耗
- **扩展性测试**: 不同缓存大小对内存的影响
- **实时监控**: 查询执行过程中的内存变化

### 3. 策略对比

- **驱逐策略**:
  - TTL (Time-To-Live): 基于时间的驱逐
  - LRU (Least Recently Used): 最近最少使用
  - ML (Machine Learning): 基于机器学习的智能驱逐

- **持久化策略**:
  - MEMORY_ONLY: 仅内存存储
  - WAL_FORMAT: WAL格式持久化
  - MATERIALIZED_VIEW: 物化视图持久化
  - HYBRID: 混合策略（热数据内存，冷数据磁盘）

## 测试数据

### TPC-H数据库

如果指定的TPC-H数据库存在，测试将使用真实的TPC-H数据：
- 标准的TPC-H表结构
- 真实的查询复杂度
- 更准确的性能评估

### 自动生成数据

如果TPC-H数据库不存在，测试会自动生成模拟数据：
- 简化的表结构
- 可配置的数据量
- 保持查询逻辑的一致性

## 结果解读

### 性能指标

- **加速比 > 2.0**: 缓存效果非常好
- **加速比 1.3-2.0**: 缓存效果良好
- **加速比 1.1-1.3**: 缓存有一定效果
- **加速比 < 1.1**: 缓存效果不明显

### 内存开销

- **< 10MB**: 内存开销很小
- **10-50MB**: 内存开销适中
- **> 50MB**: 内存开销较大，需要调整

### 命中率

- **> 80%**: 命中率很高
- **60-80%**: 命中率良好
- **40-60%**: 命中率一般
- **< 40%**: 命中率较低

## 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查数据库路径是否正确
   - 确保有读取权限

2. **缓存配置不生效**
   - 当前DuckDB版本可能不支持某些缓存配置
   - 测试会自动降级到基础功能

3. **内存监控失败**
   - 确保安装了psutil包
   - 检查系统权限

4. **图表生成失败**
   - 确保安装了matplotlib包
   - 在无GUI环境下可能需要设置后端

### 性能优化建议

1. **启用缓存的条件**:
   - 有重复查询的工作负载
   - 查询执行时间 > 100ms
   - 有足够的内存空间

2. **缓存大小配置**:
   - 根据内存容量设置合理的缓存大小
   - 监控命中率，调整缓存策略

3. **驱逐策略选择**:
   - 查询模式规律：选择LRU
   - 时间敏感数据：选择TTL
   - 复杂模式：选择ML

## 扩展测试

可以根据需要修改测试脚本：

1. **添加自定义查询**: 在查询字典中添加新的测试查询
2. **调整测试参数**: 修改迭代次数、缓存大小等参数
3. **扩展监控指标**: 添加CPU使用率、磁盘I/O等监控
4. **自定义报告格式**: 修改报告生成逻辑

## 注意事项

1. 测试可能需要较长时间，建议在空闲时运行
2. 确保有足够的磁盘空间存储测试结果
3. 测试过程中避免运行其他高负载程序
4. 定期清理测试生成的临时文件

## 联系方式

如有问题或建议，请联系开发团队。