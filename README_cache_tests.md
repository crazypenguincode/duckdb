# DuckDB 跨进程缓存持久化测试套件

本测试套件专门用于测试和验证DuckDB的跨进程缓存持久化功能，包括WAL格式、物化视图、混合策略等多种持久化方案的性能对比。

## 📁 文件结构

```
├── src/include/duckdb/main/query_cache_persistence.hpp  # 持久化接口头文件
├── src/main/query_cache_persistence.cpp                 # 持久化实现文件
├── cache_persistence_performance_test.cpp               # 原有性能测试程序
├── cross_process_cache_test.cpp                        # C++跨进程测试程序
├── cross_process_cache_persistence_test.py             # Python跨进程测试脚本
├── verify_cache_implementation.py                      # 功能验证脚本
├── run_cross_process_cache_tests.sh                    # 完整测试运行脚本
└── README_CACHE_TESTS.md                               # 本说明文件
```

## 🚀 快速开始

### 1. 功能验证（推荐首先运行）

```bash
# 快速验证基本功能是否正常
python3 verify_cache_implementation.py
```

这个脚本会验证：
- DuckDB基本功能
- 缓存设置和配置
- 持久化策略切换
- 简单缓存行为
- 跨进程模拟测试

### 2. 完整性能测试

```bash
# 运行完整的跨进程缓存性能测试
./run_cross_process_cache_tests.sh
```

这个脚本会：
- 编译DuckDB和C++测试程序
- 运行C++性能测试
- 运行Python性能测试
- 生成详细的性能报告

### 3. 单独运行测试

#### Python测试脚本
```bash
python3 cross_process_cache_persistence_test.py
```

#### C++测试程序（需要先编译）
```bash
# 编译
cd build/release
make -j$(nproc) duckdb
g++ -std=c++17 -O3 -I../../src/include -L./src ../../cross_process_cache_test.cpp -lduckdb -lpthread -o cross_process_cache_test

# 运行
export LD_LIBRARY_PATH="$PWD/src:$LD_LIBRARY_PATH"
./cross_process_cache_test
```

## 🧪 测试内容

### 持久化策略测试

测试套件包含以下持久化策略的性能对比：

1. **MEMORY_ONLY** - 仅内存缓存，不持久化
2. **WAL_FORMAT** - WAL格式持久化，适合频繁写入
3. **MATERIALIZED_VIEW** - 物化视图持久化，适合复杂查询
4. **HYBRID** - 混合策略，热数据内存+冷数据磁盘
5. **CROSS_PROCESS** - 跨进程优化策略
6. **ML_INTELLIGENT** - 机器学习智能策略

### 测试查询类型

- **简单聚合查询** - 基础COUNT、AVG、SUM操作
- **复杂连接CTE** - 多表连接和公共表表达式
- **窗口函数查询** - ROW_NUMBER、LAG、滚动聚合
- **递归CTE查询** - 递归公共表表达式

### 性能指标

- 第一次执行时间（冷启动）
- 同进程缓存命中时间
- 跨进程缓存命中时间
- 缓存加速比
- 缓存命中率
- 结果数据大小

## 📊 测试报告

测试完成后会生成以下报告文件：

- `cross_process_cache_performance_report.md` - C++测试详细报告
- `cross_process_cache_persistence_report.md` - Python测试详细报告
- `cross_process_cache_test_data.json` - 详细测试数据
- `duckdb_cache_verification_report.md` - 功能验证报告

## 🔧 技术实现

### 核心特性

1. **WAL格式持久化**
   - 顺序写入，高性能
   - 支持压缩和校验和
   - 适合高频写入场景

2. **物化视图持久化**
   - 直接存储查询结果
   - 支持复杂查询结构
   - 适合复杂分析查询

3. **混合策略**
   - 智能热冷数据分离
   - 内存+磁盘双层存储
   - 自动数据迁移

4. **跨进程缓存**
   - 进程间缓存共享
   - 文件锁防冲突
   - 专为多进程优化

5. **ML智能策略**
   - 机器学习预测
   - 自适应缓存决策
   - 在线学习优化

### 关键技术点

- **布隆过滤器** - 快速缓存存在性检查
- **LRU淘汰策略** - 智能缓存管理
- **压缩存储** - 减少磁盘占用
- **异步写入** - 提高写入性能
- **进程锁机制** - 保证跨进程一致性

## 🎯 使用建议

### 策略选择指南

| 应用场景 | 推荐策略 | 原因 |
|---------|---------|------|
| 高频简单查询 | WAL_FORMAT | 写入性能好，开销低 |
| 复杂分析查询 | MATERIALIZED_VIEW | 复杂结果直接复用 |
| 多进程应用 | CROSS_PROCESS | 专门优化跨进程性能 |
| 智能化场景 | ML_INTELLIGENT | 自适应优化决策 |
| 通用场景 | HYBRID | 各种查询都有良好表现 |

### 配置参数调优

```sql
-- 基础缓存配置
SET enable_query_cache=true;
SET query_cache_max_size='500MB';

-- 持久化配置
SET query_cache_persistence_strategy='WAL_FORMAT';
SET query_cache_persistence_path='/path/to/cache';

-- 高级配置
SET query_cache_bloom_filter_size=1000000;
SET query_cache_ttl_seconds=3600;
```

## 🐛 故障排除

### 常见问题

1. **编译失败**
   - 检查DuckDB源码完整性
   - 确保CMake和编译器版本兼容
   - 检查依赖库是否安装

2. **测试运行失败**
   - 检查DuckDB可执行文件路径
   - 确保有足够的磁盘空间
   - 检查文件权限设置

3. **缓存效果不明显**
   - 增加查询复杂度
   - 调整缓存大小配置
   - 检查持久化策略设置

4. **跨进程测试失败**
   - 检查共享目录权限
   - 确保进程间无冲突
   - 验证文件锁机制

### 调试技巧

```bash
# 启用详细日志
export DUCKDB_LOG_LEVEL=DEBUG

# 检查缓存统计
SELECT * FROM pragma_query_cache_stats();

# 监控缓存文件
ls -la /path/to/cache/

# 检查进程状态
ps aux | grep duckdb
```

## 📈 性能优化建议

1. **内存配置**
   - 根据可用内存调整缓存大小
   - 考虑其他应用的内存需求
   - 监控内存使用情况

2. **磁盘I/O优化**
   - 使用SSD存储缓存文件
   - 配置合适的WAL缓冲区大小
   - 启用压缩减少I/O

3. **并发控制**
   - 合理设置进程锁超时
   - 避免过多并发写入
   - 监控锁竞争情况

4. **缓存策略**
   - 根据查询模式选择策略
   - 定期清理过期缓存
   - 监控缓存命中率

## 🤝 贡献指南

欢迎贡献代码和改进建议！

1. Fork项目
2. 创建特性分支
3. 提交更改
4. 创建Pull Request

### 开发环境设置

```bash
# 克隆DuckDB源码
git clone https://github.com/duckdb/duckdb.git
cd duckdb

# 编译开发版本
make debug

# 运行测试
python3 verify_cache_implementation.py
```

## 📝 更新日志

### v1.0.0 (2024-01-XX)
- 初始版本发布
- 支持5种持久化策略
- 完整的跨进程测试套件
- 详细的性能报告生成

### 计划功能
- [ ] 分布式缓存支持
- [ ] 更多ML算法集成
- [ ] 实时监控面板
- [ ] 自动调优工具

## 📄 许可证

本项目遵循DuckDB的MIT许可证。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- GitHub Issues
- DuckDB社区论坛
- 邮件联系

---

*最后更新: 2024-01-XX*