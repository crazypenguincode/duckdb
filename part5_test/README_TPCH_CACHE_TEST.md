# TPC-H 缓存性能测试工具

这个工具集用于测试TPC-H查询在DuckDB中的缓存性能表现，包括有缓存和无缓存情况下的执行时间对比。

## 文件说明

### 主要脚本

1. **`tpch_cache_performance_test.py`** - 完整版测试脚本
   - 测试所有22个TPC-H查询
   - 执行1次和10次重复测试
   - 生成详细的性能报告和可视化图表
   - 预计耗时: 10-30分钟

2. **`tpch_cache_quick_test.py`** - 快速测试脚本
   - 只测试前5个TPC-H查询
   - 执行1次和3次重复测试
   - 用于快速验证和调试
   - 预计耗时: 2-5分钟

3. **`verify_tpch_environment.py`** - 环境验证脚本
   - 验证DuckDB可执行文件
   - 验证TPC-H数据库文件
   - 验证TPC-H查询文件
   - 测试缓存功能

4. **`run_tpch_cache_test.sh`** - 自动运行脚本
   - 自动检查环境
   - 运行完整测试
   - 生成报告

## 环境要求

### 必需文件和路径

1. **DuckDB可执行文件**: `/Users/max/src/duckdb/build/release/duckdb`
2. **TPC-H数据库**: `/Users/max/test/tpc/tpch-sf1.db`
3. **TPC-H查询文件**: `/Users/max/src/duckdb/extension/tpch/dbgen/queries/`

### 系统要求
- Python 3.6+
- macOS/Linux系统
- 足够的磁盘空间存储结果文件

## 使用方法

### 1. 环境验证（推荐第一步）

```bash
cd part5_test
python3 verify_tpch_environment.py
```

这将检查所有必需的文件和配置是否正确。

### 2. 快速测试（推荐用于调试）

```bash
cd part5_test
python3 tpch_cache_quick_test.py
```

快速测试只运行前5个查询，用于验证脚本是否正常工作。

### 3. 完整测试

```bash
cd part5_test
python3 tpch_cache_performance_test.py
```

或使用自动化脚本：

```bash
./run_tpch_cache_test.sh
```

## 输出文件

测试完成后，结果将保存在 `part5_test/tpch_cache_results/` 目录下：

### JSON格式结果
- `tpch_cache_performance_YYYYMMDD_HHMMSS.json` - 完整测试结果
- `tpch_quick_test_YYYYMMDD_HHMMSS.json` - 快速测试结果

### CSV格式汇总
- `tpch_performance_summary_YYYYMMDD_HHMMSS.csv` - 性能数据汇总

### Markdown报告
- `tpch_cache_report_YYYYMMDD_HHMMSS.md` - 详细测试报告
- `tpch_quick_report_YYYYMMDD_HHMMSS.md` - 快速测试报告

### Mermaid图表
- `tpch_speedup_bar_chart_YYYYMMDD_HHMMSS.md` - 加速比柱状图
- `tpch_performance_line_chart_YYYYMMDD_HHMMSS.md` - 性能对比折线图

## 测试配置

### 完整测试
- **查询数量**: 22个TPC-H查询 (Q01-Q22)
- **测试迭代**: 1次, 10次
- **超时设置**: 300秒 (5分钟)

### 快速测试
- **查询数量**: 5个TPC-H查询 (Q01-Q05)
- **测试迭代**: 1次, 3次
- **超时设置**: 120秒 (2分钟)

## 性能指标

脚本会计算以下性能指标：

1. **执行时间** - 查询的总执行时间
2. **加速比** - 无缓存时间 / 有缓存时间
3. **节省时间** - 无缓存时间 - 有缓存时间
4. **缓存效率** - (节省时间 / 无缓存时间) × 100%

## 图表说明

### 柱状图 (Bar Chart)
- 显示每个查询的缓存加速比
- 按查询ID排序
- 不同迭代次数分别显示

### 折线图 (Line Chart)
- 对比有缓存和无缓存的执行时间
- 显示所有查询的性能趋势
- 包含复杂度分析

## 故障排除

### 常见问题

1. **DuckDB可执行文件不存在**
   - 确保已编译DuckDB: `make release`
   - 检查路径是否正确

2. **TPC-H数据库文件不存在**
   - 确保已创建TPC-H数据库
   - 检查数据库路径和权限

3. **查询执行超时**
   - 检查数据库大小和系统性能
   - 可以修改脚本中的超时设置

4. **查询执行失败**
   - 检查SQL语法
   - 确认数据库表结构完整

### 调试建议

1. 先运行环境验证脚本
2. 使用快速测试验证基本功能
3. 检查生成的错误日志
4. 逐个查询进行测试

## 自定义配置

可以通过修改脚本中的以下变量来自定义测试：

```python
# 修改路径
self.duckdb_path = "/your/path/to/duckdb"
self.tpch_db_path = "/your/path/to/tpch-sf1.db"
self.queries_dir = "/your/path/to/queries"

# 修改测试配置
self.test_iterations = [1, 5, 10]  # 测试次数
self.max_queries = 10  # 查询数量限制
```

## 注意事项

1. **测试时间**: 完整测试可能需要较长时间，建议先运行快速测试
2. **系统负载**: 测试期间避免运行其他高负载任务
3. **磁盘空间**: 确保有足够空间存储结果文件
4. **数据一致性**: 测试期间不要修改数据库文件

## 联系支持

如果遇到问题，请检查：
1. 环境验证脚本的输出
2. 生成的错误日志
3. 系统资源使用情况