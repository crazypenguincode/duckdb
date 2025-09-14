# 第五章实验测试报告

## 测试概览

**测试时间**: 2025-09-14T11:20:04.771883 - 2025-09-14T11:20:05.713209  
**测试环境**: Apple M4 Pro, 48GB RAM, DuckDB 1.3.2  
**总执行时间**: 0.94秒  

## 测试结果统计

| 指标 | 数值 |
|------|------|
| 总测试数 | 6 |
| 成功测试 | 3 ✅ |
| 失败测试 | 3 ❌ |
| 超时测试 | 0 ⏰ |
| 异常测试 | 0 💥 |
| 成功率 | 50.0% |

## 详细测试结果

### 5.1.platform_setup.py

**状态**: ✅ success  
**执行时间**: 0.37秒  

### 5.2.cache_performance.py

**状态**: ❌ failed  
**执行时间**: 0.04秒  

**错误信息**:
```
Traceback (most recent call last):
  File "/Users/max/src/duckdb/part5_test/5.2.cache_performance.py", line 12, in <module>
    import duckdb
ModuleNotFoundError: No module named 'duckdb'

```

### 5.3.bloom_filter.py

**状态**: ✅ success  
**执行时间**: 0.43秒  

### 5.4.sql_cache.py

**状态**: ❌ failed  
**执行时间**: 0.03秒  

**错误信息**:
```
Traceback (most recent call last):
  File "/Users/max/src/duckdb/part5_test/5.4.sql_cache.py", line 12, in <module>
    import duckdb
ModuleNotFoundError: No module named 'duckdb'

```

### 5.7.persistence.py

**状态**: ✅ success  
**执行时间**: 0.04秒  

### 5.8.comprehensive.py

**状态**: ❌ failed  
**执行时间**: 0.03秒  

**错误信息**:
```
Traceback (most recent call last):
  File "/Users/max/src/duckdb/part5_test/5.8.comprehensive.py", line 11, in <module>
    import duckdb
ModuleNotFoundError: No module named 'duckdb'

```

## 性能指标汇总

- **platform_readiness**: ✅ 就绪
- **bloom_filter**: ✅ 假阳性率 <1%
- **persistence**: ✅ 9.1/10 混合策略评分

## 总体评估

成功率: **50.0%**

🚨 **测试成功率较低，需要全面检查系统配置**

---
*报告生成时间: 2025-09-14T11:20:05.713381*
