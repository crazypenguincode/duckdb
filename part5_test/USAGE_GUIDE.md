# 第五章表5.7缓存测试使用指南

## 概述

本测试框架实现了第五章表5.7中描述的四种数据集类型的完整测试，用于对比开启缓存与不开启缓存的性能差异。

## 已生成的数据集

✅ **所有数据集已成功生成！**

| 数据集类型 | 数据规模 | 查询特点 | 测试目标 | 状态 |
|------------|----------|----------|----------|------|
| **重复查询集** | 1000个查询 | 高重复率(90.4%) | 缓存命中率测试 | ✅ 已生成 |
| **参数化查询集** | 520个查询 | 13个模板，参数变化 | SQL标准化测试 | ✅ 已生成 |
| **CTE查询集** | 200个查询 | 复杂CTE结构 | CTE缓存优化测试 | ✅ 已生成 |
| **并发查询集** | 2335个查询 | 5个并发场景 | 并发性能测试 | ✅ 已生成 |

## 快速开始

### 1. 简单缓存测试（推荐开始）

```bash
# 运行简单的缓存性能测试
cd part5_test/scripts
python3 run_simple_cache_test.py <duckdb_path>

# 示例
python3 run_simple_cache_test.py ../duckdb
```

这个测试会：
- 创建一个小型测试数据库
- 运行4种不同类型的查询
- 对比有缓存vs无缓存的性能
- 生成详细的性能报告

### 2. 完整测试套件

```bash
# 运行所有测试（包括TPC基准测试）
python3 run_all_cache_tests.py <duckdb_path>

# 示例
python3 run_all_cache_tests.py ../duckdb
```

这个测试会：
- 验证所有数据集
- 运行缓存性能测试
- 运行TPC-H和TPC-DS基准测试
- 生成完整的测试报告

### 3. 单独测试特定数据集

```bash
# 测试重复查询集
python3 cache_performance_test.py <duckdb_path> <db_path> repeat_queries

# 测试参数化查询集
python3 cache_performance_test.py <duckdb_path> <db_path> parameterized_queries

# 测试CTE查询集
python3 cache_performance_test.py <duckdb_path> <db_path> cte_queries

# 测试并发查询集
python3 cache_performance_test.py <duckdb_path> <db_path> concurrent_queries
```

## 数据集详情

### 1. 重复查询集
- **文件位置**: `dataset/repeat_queries/`
- **总查询数**: 1000个
- **唯一查询数**: 96个
- **重复率**: 90.4%
- **主要文件**:
  - `repeat_queries_all.sql`: 所有查询
  - `repeat_queries_batch_*.sql`: 分批查询文件
  - `repeat_queries_stats.json`: 统计信息

### 2. 参数化查询集
- **文件位置**: `dataset/parameterized_queries/`
- **总查询数**: 520个
- **模板数**: 13个
- **平均每模板**: 40个查询
- **主要文件**:
  - `parameterized_queries_all.sql`: 所有查询
  - `template_*_queries.sql`: 各模板的查询
  - `parameterized_stats.json`: 统计信息

### 3. CTE查询集
- **文件位置**: `dataset/cte_queries/`
- **总查询数**: 200个
- **模板数**: 10个
- **复杂度分布**:
  - 高复杂度: 70个
  - 极高复杂度: 69个
  - 中等复杂度: 61个
- **主要文件**:
  - `cte_queries_all.sql`: 所有查询
  - `cte_queries_*.sql`: 按复杂度分类
  - `cte_stats.json`: 统计信息

### 4. 并发查询集
- **文件位置**: `dataset/concurrent_queries/`
- **总查询数**: 2335个
- **测试场景**: 5个
- **持续时间分布**:
  - 快速查询: 1731个
  - 中等查询: 513个
  - 慢查询: 91个
- **主要文件**:
  - `concurrent_queries_all.sql`: 所有查询
  - `concurrent_queries_*.sql`: 各场景查询
  - `concurrent_stats.json`: 统计信息

## 测试结果

测试完成后会生成以下文件：

1. **JSON格式结果**: 
   - `simple_cache_test_results_*.json`
   - `cache_test_results_*.json`
   - `cache_performance_test_results_*.json`

2. **Markdown报告**: 
   - `cache_test_results_*.md`

3. **性能指标**:
   - 缓存命中率
   - 平均执行时间对比
   - 性能提升百分比
   - 并发性能(QPS)
   - 系统资源使用情况

## 示例输出

### 简单缓存测试示例输出
```
=== 开始缓存性能测试 ===

[1/4] 测试: 简单聚合查询
  执行次数: 1.2.3.4.5 ✓
    平均无缓存时间: 45.23ms
    平均缓存时间: 12.45ms
    性能提升: 72.47%

[2/4] 测试: 条件过滤查询
  执行次数: 1.2.3.4.5 ✓
    平均无缓存时间: 23.67ms
    平均缓存时间: 8.91ms
    性能提升: 62.35%

=== 测试摘要 ===
成功测试的查询: 4/4
平均性能提升: 67.21%
性能提升范围: 58.12% - 75.43%
```

## 高级用法

### 自定义测试参数

编辑生成脚本中的参数：
```python
# 在 generate_repeat_queries.py 中
TOTAL_QUERIES = 1000  # 总查询数
REPEAT_RATE = 0.8     # 重复率

# 在 generate_concurrent_queries.py 中
CONCURRENT_USERS = [50, 20, 5, 30, 25]  # 并发用户数
```

### 添加自定义查询

1. 在相应目录下创建新的SQL文件
2. 修改生成脚本添加新的查询模板
3. 重新运行数据集生成

### TPC基准测试

如果您有TPC-H和TPC-DS数据库：
```bash
# 确保数据库文件存在
ls -la /Users/max/test/tpc/tpch-sf1.db
ls -la /Users/max/test/tpc/tpcds_sf1.db

# 运行完整测试（包括TPC基准）
python3 run_all_cache_tests.py ../duckdb
```

## 故障排除

### 常见问题

1. **DuckDB路径错误**
   ```bash
   # 检查DuckDB可执行文件
   ls -la ../duckdb
   # 或使用绝对路径
   python3 run_simple_cache_test.py /path/to/duckdb
   ```

2. **权限问题**
   ```bash
   # 确保脚本有执行权限
   chmod +x scripts/*.py
   ```

3. **内存不足**
   ```bash
   # 减少并发用户数或查询数量
   # 编辑相应的生成脚本
   ```

### 调试模式

```bash
# 启用详细输出
export DEBUG=1
python3 run_simple_cache_test.py ../duckdb
```

## 性能优化建议

1. **系统配置**:
   - 建议至少4GB可用内存
   - SSD存储获得更好性能
   - 关闭不必要的后台程序

2. **DuckDB配置**:
   ```sql
   -- 调整内存限制
   SET memory_limit = '2GB';
   
   -- 启用查询缓存
   SET enable_query_cache = true;
   
   -- 调整线程数
   SET threads = 4;
   ```

3. **测试优化**:
   - 先运行简单测试验证环境
   - 逐步增加测试规模
   - 监控系统资源使用情况

## 扩展功能

### 添加新的测试类型

1. 在`dataset/`下创建新目录
2. 编写数据生成脚本
3. 在主测试脚本中添加新的测试逻辑

### 集成到CI/CD

```yaml
# GitHub Actions 示例
- name: Run Cache Tests
  run: |
    cd part5_test/scripts
    python3 run_simple_cache_test.py ../duckdb
```

## 相关文档

- [第五章实验设计](../md/第五章-实验与分析.md)
- [DuckDB查询缓存](../src/main/query_cache.cpp)
- [完整README](README.md)

---

**注意**: 这个测试框架是为第五章表5.7的实验设计而创建的，所有数据集和测试用例都已经生成并验证通过。您可以直接使用这些数据进行缓存性能对比实验。