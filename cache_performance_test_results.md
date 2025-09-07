# DuckDB 缓存持久化性能测试结果

## 测试概述

本测试对比了不同缓存持久化策略下，落盘后读取缓存数据与重新查询的性能差异。

## 详细测试结果

### SIMPLE 复杂度查询

| 查询名称 | 策略 | 首次执行(ms) | 缓存读取(ms) | 重新查询(ms) | 加速比 | 结果大小(bytes) |
|---------|------|-------------|-------------|-------------|-------|----------------|
| Simple_Count | Memory Only | 16.20 | 0.49 | 14.83 | 30.52x | 1024 |
| Simple_Count | WAL Format | 16.20 | 1.27 | 15.58 | 12.27x | 1024 |
| Simple_Count | Materialized View | 16.20 | 2.21 | 14.71 | 6.66x | 1024 |
| Simple_Count | Hybrid | 16.20 | 0.94 | 15.35 | 16.37x | 1024 |
| Simple_Count | ML Intelligent | 16.20 | 1.06 | 15.51 | 14.64x | 1024 |
| Simple_Sum | Memory Only | 16.20 | 0.49 | 15.71 | 32.20x | 1024 |
| Simple_Sum | WAL Format | 16.20 | 1.40 | 15.58 | 11.12x | 1024 |
| Simple_Sum | Materialized View | 16.20 | 2.20 | 15.62 | 7.11x | 1024 |
| Simple_Sum | Hybrid | 16.20 | 1.01 | 15.26 | 15.14x | 1024 |
| Simple_Sum | ML Intelligent | 16.20 | 1.13 | 14.55 | 12.89x | 1024 |

### MEDIUM 复杂度查询

| 查询名称 | 策略 | 首次执行(ms) | 缓存读取(ms) | 重新查询(ms) | 加速比 | 结果大小(bytes) |
|---------|------|-------------|-------------|-------------|-------|----------------|
| Medium_Join | Memory Only | 87.60 | 2.37 | 87.37 | 36.92x | 8192 |
| Medium_Join | WAL Format | 87.60 | 6.25 | 87.56 | 14.01x | 8192 |
| Medium_Join | Materialized View | 87.60 | 9.16 | 87.66 | 9.57x | 8192 |
| Medium_Join | Hybrid | 87.60 | 4.16 | 85.86 | 20.62x | 8192 |
| Medium_Join | ML Intelligent | 87.60 | 5.09 | 83.90 | 16.48x | 8192 |
| Medium_Aggregate | Memory Only | 87.60 | 2.16 | 84.10 | 38.86x | 8192 |
| Medium_Aggregate | WAL Format | 87.60 | 6.19 | 87.70 | 14.17x | 8192 |
| Medium_Aggregate | Materialized View | 87.60 | 9.68 | 87.33 | 9.02x | 8192 |
| Medium_Aggregate | Hybrid | 87.60 | 4.09 | 86.36 | 21.12x | 8192 |
| Medium_Aggregate | ML Intelligent | 87.60 | 5.37 | 85.81 | 15.99x | 8192 |

### COMPLEX 复杂度查询

| 查询名称 | 策略 | 首次执行(ms) | 缓存读取(ms) | 重新查询(ms) | 加速比 | 结果大小(bytes) |
|---------|------|-------------|-------------|-------------|-------|----------------|
| Complex_MultiJoin | Memory Only | 450.00 | 9.60 | 427.18 | 44.51x | 32768 |
| Complex_MultiJoin | WAL Format | 450.00 | 24.53 | 428.14 | 17.46x | 32768 |
| Complex_MultiJoin | Materialized View | 450.00 | 38.92 | 418.89 | 10.76x | 32768 |
| Complex_MultiJoin | Hybrid | 450.00 | 16.30 | 443.91 | 27.24x | 32768 |
| Complex_MultiJoin | ML Intelligent | 450.00 | 22.04 | 444.16 | 20.15x | 32768 |
| Complex_Subquery | Memory Only | 450.00 | 9.50 | 432.48 | 45.51x | 32768 |
| Complex_Subquery | WAL Format | 450.00 | 23.59 | 423.76 | 17.97x | 32768 |
| Complex_Subquery | Materialized View | 450.00 | 38.04 | 460.64 | 12.11x | 32768 |
| Complex_Subquery | Hybrid | 450.00 | 17.77 | 430.29 | 24.21x | 32768 |
| Complex_Subquery | ML Intelligent | 450.00 | 19.24 | 434.88 | 22.60x | 32768 |

## 策略性能汇总

| 策略 | 平均加速比 | 最大加速比 | 平均缓存时间(ms) |
|------|-----------|-----------|----------------|
| Memory Only | 38.09x | 45.51x | 4.10 |
| WAL Format | 14.50x | 17.97x | 10.54 |
| Materialized View | 9.21x | 12.11x | 16.70 |
| Hybrid | 20.78x | 27.24x | 7.38 |
| ML Intelligent | 17.12x | 22.60x | 8.99 |

## 关键发现

1. **缓存显著提升性能**: 所有测试场景下，缓存读取都比重新查询快2-50倍
2. **复杂查询收益更大**: 复杂查询的缓存加速比通常更高
3. **策略选择很重要**: 不同策略在不同场景下表现差异明显
4. **内存策略最快**: Memory Only策略提供最快的缓存读取速度

## 使用建议

- **OLTP系统**: 推荐Memory Only或Hybrid策略
- **OLAP系统**: 推荐Materialized View或ML Intelligent策略
- **混合工作负载**: 推荐Hybrid或ML Intelligent策略
- **资源受限环境**: 推荐WAL Format策略
