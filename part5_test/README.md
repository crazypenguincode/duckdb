# 第五章 实验与分析 - 测试套件

本测试套件用于验证第五章中提出的动态缓存技术的各项性能指标和功能特性。

## 📁 目录结构

```
part5_test/
├── 5.1.platform_setup.py          # 实验平台搭建测试
├── 5.2.cache_performance.py       # 动态缓存技术性能评估
├── 5.3.bloom_filter.py           # 布隆过滤器影响评估
├── 5.4.sql_cache.py              # SQL缓存技术性能评估
├── 5.7.persistence.py            # 持久化策略测试
├── 5.8.comprehensive.py          # 综合性能评估
├── run_all_tests.py               # 主测试脚本
├── start_tests.sh                 # 启动脚本
└── README.md                      # 本文档
```

## 🚀 快速开始

### 方法一：使用启动脚本（推荐）

```bash
# 进入DuckDB项目目录
cd /Users/max/src/duckdb

# 运行启动脚本
chmod +x part5_test/start_tests.sh
./part5_test/start_tests.sh
```

### 方法二：直接运行Python脚本

```bash
# 运行所有测试
python3 part5_test/run_all_tests.py

# 或运行单个测试
python3 part5_test/5.1.platform_setup.py
python3 part5_test/5.2.cache_performance.py
# ... 其他测试脚本
```

## 📋 测试内容详解

### 5.1 实验平台搭建测试 (`5.1.platform_setup.py`)

**测试目标**: 验证实验环境的完整性和可用性

**测试内容**:
- 硬件环境配置检查（CPU、内存、存储）
- 软件环境配置验证（操作系统、编译工具、DuckDB）
- 测试数据集准备状态（TPC-H查询文件、测试数据库）
- 缓存系统配置参数验证

**预期结果**:
- 硬件配置满足测试要求
- 软件依赖完整安装
- 测试数据集准备就绪
- 缓存配置参数合理

### 5.2 动态缓存技术性能评估 (`5.2.cache_performance.py`)

**测试目标**: 评估动态缓存系统的整体性能表现

**测试内容**:
- 查询响应时间分析（不同复杂度查询的性能改善）
- 系统吞吐量测试（并发性能和扩展能力）
- 内存使用效率分析（内存占用模式和缓存命中率）

**关键指标**:
- 查询响应时间改善：30-90%
- 系统峰值吞吐量：>15,000 QPS
- 缓存命中率：>85%
- 内存利用率：>95%

### 5.3 布隆过滤器影响评估 (`5.3.bloom_filter.py`)

**测试目标**: 验证布隆过滤器的过滤效果和性能影响

**测试内容**:
- 假阳性率控制效果测试
- 不同参数配置的性能对比
- 过滤效率分析
- 动态参数调整验证

**关键指标**:
- 假阳性率控制：<1%
- 过滤效率：>80%
- 查询延迟降低：>25%
- 内存访问减少：>70%

### 5.4 SQL缓存技术性能评估 (`5.4.sql_cache.py`)

**测试目标**: 验证SQL标准化和CTE缓存的效果

**测试内容**:
- SQL标准化成功率测试
- 查询复杂度评分验证
- CTE识别和缓存效果分析
- 递归CTE优化验证

**关键指标**:
- SQL标准化成功率：>90%
- 复杂度评分相关性：>0.9
- CTE识别准确率：>85%
- 递归CTE性能改善：>80%

### 5.7 持久化策略测试 (`5.7.persistence.py`)

**测试目标**: 评估不同持久化策略的性能和可靠性

**测试内容**:
- WAL格式持久化性能测试
- 物化视图持久化效果分析
- 混合持久化策略对比
- 数据完整性和恢复能力验证

**关键指标**:
- WAL写入速度：>8,000 MB/s
- 数据完整性：>99.8%
- 压缩比：>4:1
- 恢复时间：<180s

### 5.8 综合性能评估 (`5.8.comprehensive.py`)

**测试目标**: 与传统数据库系统进行全面对比

**测试内容**:
- TPC-H基准测试对比
- 可扩展性测试（数据量和并发度）
- 实际应用场景性能验证
- 资源利用率分析

**关键指标**:
- TPC-H性能改善：>60%
- 最大数据量支持：1TB+
- 最大并发支持：500+
- 资源利用率优化：>25%

## 📊 测试结果

测试完成后，将生成以下结果文件：

### JSON格式结果文件
- `5.1.platform_setup_results.json` - 平台搭建测试结果
- `5.2.cache_performance_results.json` - 缓存性能测试结果
- `5.3.bloom_filter_results.json` - 布隆过滤器测试结果
- `5.4.sql_cache_results.json` - SQL缓存测试结果
- `5.7.persistence_results.json` - 持久化策略测试结果
- `5.8.comprehensive_results.json` - 综合性能测试结果

### 综合报告
- `chapter5_comprehensive_report.json` - 完整的JSON格式综合报告
- `Chapter5_Test_Report.md` - Markdown格式的可读性报告

## 🔧 环境要求

### 硬件要求
- CPU: 多核处理器（推荐8核以上）
- 内存: 8GB以上（推荐16GB+）
- 存储: 100GB以上可用空间
- 网络: 稳定的网络连接

### 软件要求
- 操作系统: macOS/Linux/Windows
- Python: 3.7+
- DuckDB: 0.9.0+
- 必要的Python包: `duckdb`, `psutil`, `statistics`

### 测试数据
- TPC-H测试数据库: `/Users/max/test/tpc/tpch-sf1.db`
- TPC-H查询文件: `/Users/max/src/duckdb/extension/tpch/dbgen/queries/`

## 🛠️ 故障排除

### 常见问题

1. **Python包缺失**
   ```bash
   pip3 install duckdb psutil
   ```

2. **测试数据库不存在**
   - 检查路径 `/Users/max/test/tpc/tpch-sf1.db` 是否存在
   - 如果不存在，测试将使用模拟数据

3. **权限问题**
   ```bash
   chmod +x part5_test/*.py
   chmod +x part5_test/start_tests.sh
   ```

4. **测试超时**
   - 某些测试可能需要较长时间，请耐心等待
   - 可以单独运行特定测试进行调试

### 调试模式

如需调试特定测试，可以直接运行单个脚本：

```bash
# 启用详细输出
python3 -v part5_test/5.1.platform_setup.py

# 查看错误信息
python3 part5_test/5.2.cache_performance.py 2>&1 | tee debug.log
```

## 📈 性能基准

基于标准测试环境的预期性能指标：

| 测试项目 | 基准值 | 目标改善 | 实际结果 |
|---------|--------|----------|----------|
| 查询响应时间 | 100ms | -60% | 待测试 |
| 系统吞吐量 | 4000 QPS | +300% | 待测试 |
| 缓存命中率 | 0% | >85% | 待测试 |
| 内存利用率 | 70% | >95% | 待测试 |
| 数据完整性 | 95% | >99.8% | 待测试 |

## 🤝 贡献指南

如需扩展或修改测试套件：

1. 遵循现有的代码结构和命名规范
2. 添加适当的错误处理和日志输出
3. 更新相关文档和注释
4. 确保新测试与现有测试兼容

## 📞 支持

如遇到问题或需要帮助：

1. 查看生成的错误日志
2. 检查环境配置是否正确
3. 参考故障排除部分
4. 联系开发团队获取支持

---

**最后更新**: 2024年9月14日  
**版本**: 1.0.0  
**兼容性**: DuckDB 0.9.0+, Python 3.7+