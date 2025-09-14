# 第五章实验测试 - 完整构建和启动指南

## 🎯 测试目标

本测试套件用于验证第五章《实验与分析——系统性能评估与测试》中提出的动态缓存技术的各项性能指标，包括：

- 实验平台搭建验证
- 动态缓存技术性能评估  
- 布隆过滤器影响评估
- SQL缓存技术性能评估
- 持久化策略测试
- 综合性能评估与对比分析

## 📋 测试环境要求

### 硬件要求
- **CPU**: Apple M4 Pro 或同等性能处理器（14核心推荐）
- **内存**: 48GB 或更多（最低16GB）
- **存储**: 200GB+ 可用空间
- **网络**: 稳定的网络连接

### 软件要求
- **操作系统**: macOS 15.5+ / Linux / Windows
- **Python**: 3.7+ （已验证 3.13.6）
- **DuckDB**: 1.3.2+
- **依赖包**: `duckdb`, `psutil`, `statistics`, `json`

### 测试数据
- **TPC-H数据库**: `/Users/max/test/tpc/tpch-sf1.db` (575MB)
- **TPC-H查询文件**: `/Users/max/src/duckdb/extension/tpch/dbgen/queries/` (22个查询文件)

## 🚀 快速启动

### 方法一：一键启动（推荐）

```bash
# 1. 进入项目目录
cd /Users/max/src/duckdb

# 2. 验证环境
python3 part5_test/verify_environment.py

# 3. 运行所有测试
python3 part5_test/run_all_tests.py
```

### 方法二：使用启动脚本

```bash
# 1. 进入项目目录
cd /Users/max/src/duckdb

# 2. 设置执行权限
chmod +x part5_test/start_tests.sh

# 3. 运行启动脚本
./part5_test/start_tests.sh
```

### 方法三：逐个运行测试

```bash
# 进入项目目录
cd /Users/max/src/duckdb

# 按顺序运行各项测试
python3 part5_test/5.1.platform_setup.py      # 实验平台搭建测试
python3 part5_test/5.2.cache_performance.py   # 动态缓存性能测试
python3 part5_test/5.3.bloom_filter.py        # 布隆过滤器测试
python3 part5_test/5.4.sql_cache.py           # SQL缓存技术测试
python3 part5_test/5.7.persistence.py         # 持久化策略测试
python3 part5_test/5.8.comprehensive.py       # 综合性能评估
```

## 📊 测试脚本详解

### 5.1 实验平台搭建测试
```bash
python3 part5_test/5.1.platform_setup.py
```
- **功能**: 验证硬件环境、软件环境、数据集准备和缓存配置
- **输出**: `part5_test/5.1.platform_setup_results.json`
- **预期时间**: 30秒

### 5.2 动态缓存技术性能评估
```bash
python3 part5_test/5.2.cache_performance.py
```
- **功能**: 测试查询响应时间、系统吞吐量、内存使用效率
- **输出**: `part5_test/5.2.cache_performance_results.json`
- **预期时间**: 2-5分钟

### 5.3 布隆过滤器影响评估
```bash
python3 part5_test/5.3.bloom_filter.py
```
- **功能**: 测试假阳性率控制和过滤效率
- **输出**: `part5_test/5.3.bloom_filter_results.json`
- **预期时间**: 1-2分钟

### 5.4 SQL缓存技术性能评估
```bash
python3 part5_test/5.4.sql_cache.py
```
- **功能**: 测试SQL标准化、复杂度评分、CTE缓存
- **输出**: `part5_test/5.4.sql_cache_results.json`
- **预期时间**: 1-3分钟

### 5.7 持久化策略测试
```bash
python3 part5_test/5.7.persistence.py
```
- **功能**: 测试WAL格式、物化视图、混合持久化策略
- **输出**: `part5_test/5.7.persistence_results.json`
- **预期时间**: 1-2分钟

### 5.8 综合性能评估
```bash
python3 part5_test/5.8.comprehensive.py
```
- **功能**: TPC-H基准测试对比、可扩展性测试
- **输出**: `part5_test/5.8.comprehensive_results.json`
- **预期时间**: 2-4分钟

## 📄 测试结果文件

### JSON格式结果文件
- `5.1.platform_setup_results.json` - 平台搭建测试详细结果
- `5.2.cache_performance_results.json` - 缓存性能测试数据
- `5.3.bloom_filter_results.json` - 布隆过滤器测试数据
- `5.4.sql_cache_results.json` - SQL缓存测试数据
- `5.7.persistence_results.json` - 持久化策略测试数据
- `5.8.comprehensive_results.json` - 综合性能测试数据

### 综合报告文件
- `chapter5_comprehensive_report.json` - 完整JSON格式综合报告
- `Chapter5_Test_Report.md` - Markdown格式可读性报告
- `environment_verification.json` - 环境验证结果

## 🎯 预期测试结果

基于标准测试环境的预期性能指标：

| 测试项目 | 关键指标 | 预期结果 | 验证状态 |
|---------|----------|----------|----------|
| **平台搭建** | 环境完整性 | ✅ 就绪 | ✅ 已验证 |
| **缓存性能** | 查询响应时间改善 | 30-90% | 待测试 |
| **缓存性能** | 系统吞吐量 | >15,000 QPS | 待测试 |
| **缓存性能** | 缓存命中率 | >85% | 待测试 |
| **布隆过滤器** | 假阳性率控制 | <1% | 待测试 |
| **布隆过滤器** | 过滤效率 | >80% | 待测试 |
| **SQL缓存** | 标准化成功率 | >90% | 待测试 |
| **SQL缓存** | CTE识别准确率 | >85% | 待测试 |
| **持久化** | WAL写入速度 | >8,000 MB/s | 待测试 |
| **持久化** | 数据完整性 | >99.8% | 待测试 |
| **综合评估** | TPC-H性能改善 | >60% | 待测试 |
| **综合评估** | 资源利用率优化 | >25% | 待测试 |

## 🔧 故障排除

### 常见问题及解决方案

1. **Python包缺失**
   ```bash
   pip3 install duckdb psutil
   ```

2. **权限问题**
   ```bash
   chmod +x part5_test/*.py part5_test/*.sh
   ```

3. **测试数据库不存在**
   - 检查路径：`/Users/max/test/tpc/tpch-sf1.db`
   - 如果不存在，测试将使用模拟数据

4. **内存不足**
   - 确保至少有8GB可用内存
   - 关闭不必要的应用程序

5. **测试超时**
   - 某些测试可能需要较长时间
   - 可以单独运行特定测试进行调试

### 调试模式

```bash
# 启用详细输出
python3 -v part5_test/5.1.platform_setup.py

# 查看错误信息
python3 part5_test/5.2.cache_performance.py 2>&1 | tee debug.log

# 检查特定测试的输出
python3 part5_test/5.3.bloom_filter.py > test_output.txt 2>&1
```

## 📈 性能监控

### 实时监控命令

```bash
# 监控系统资源使用
top -pid $(pgrep -f "python3.*part5_test")

# 监控内存使用
watch -n 1 'ps aux | grep python3 | grep part5_test'

# 监控磁盘I/O
iostat -x 1

# 监控网络使用
netstat -i
```

### 性能分析工具

```bash
# 使用time命令测量执行时间
time python3 part5_test/run_all_tests.py

# 使用memory_profiler分析内存使用
pip3 install memory_profiler
python3 -m memory_profiler part5_test/5.2.cache_performance.py
```

## 🚀 完整构建语句

### 一键运行所有测试
```bash
#!/bin/bash
# 第五章完整测试构建脚本

echo "🚀 开始第五章实验测试..."

# 1. 进入项目目录
cd /Users/max/src/duckdb

# 2. 验证环境
echo "📋 验证测试环境..."
python3 part5_test/verify_environment.py

# 3. 运行所有测试
echo "🧪 运行完整测试套件..."
python3 part5_test/run_all_tests.py

# 4. 显示结果
echo "📊 测试完成！查看结果："
echo "  - 综合报告: part5_test/Chapter5_Test_Report.md"
echo "  - 详细数据: part5_test/chapter5_comprehensive_report.json"
echo "  - 各项结果: part5_test/5.*.results.json"

echo "✅ 第五章实验测试完成！"
```

### 保存为脚本文件
```bash
# 创建并保存构建脚本
cat > run_chapter5_tests.sh << 'EOF'
#!/bin/bash
cd /Users/max/src/duckdb
python3 part5_test/verify_environment.py
python3 part5_test/run_all_tests.py
echo "测试完成！查看 part5_test/Chapter5_Test_Report.md"
EOF

# 设置执行权限
chmod +x run_chapter5_tests.sh

# 运行测试
./run_chapter5_tests.sh
```

## 📞 技术支持

如遇到问题：

1. **查看日志**: 检查生成的错误日志和输出文件
2. **环境检查**: 运行 `python3 part5_test/verify_environment.py`
3. **单独测试**: 逐个运行测试脚本定位问题
4. **资源监控**: 确保系统资源充足
5. **联系支持**: 提供详细的错误信息和环境配置

---

**最后更新**: 2024年9月14日  
**测试版本**: 1.0.0  
**兼容环境**: macOS 15.5+, DuckDB 1.3.2+, Python 3.13.6+