#!/usr/bin/env python3
"""
简单的查询缓存测试脚本
"""

import duckdb
import time

def test_query_cache():
    print("=== DuckDB查询缓存测试 ===")
    
    # 连接到TPC-H数据库
    conn = duckdb.connect('/Users/max/test/tpc/tpch-sf1.db')
    
    # 检查初始缓存状态
    print("\n1. 检查初始缓存状态:")
    try:
        result = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
        print(f"   初始状态: 条目={result[0][0]}, 命中={result[0][1]}, 未命中={result[0][2]}, 启用={result[0][6]}")
    except Exception as e:
        print(f"   错误: {e}")
        return
    
    # 测试查询
    test_query = "SELECT COUNT(*) FROM orders"
    print(f"\n2. 测试查询: {test_query}")
    
    # 第一次执行
    print("   第一次执行...")
    start_time = time.perf_counter()
    result1 = conn.execute(test_query).fetchall()
    end_time = time.perf_counter()
    time1 = (end_time - start_time) * 1000
    print(f"   结果: {result1[0][0]}, 耗时: {time1:.2f}ms")
    
    # 检查缓存状态
    cache_stats = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
    print(f"   缓存状态: 条目={cache_stats[0][0]}, 命中={cache_stats[0][1]}, 未命中={cache_stats[0][2]}")
    
    # 第二次执行
    print("   第二次执行...")
    start_time = time.perf_counter()
    result2 = conn.execute(test_query).fetchall()
    end_time = time.perf_counter()
    time2 = (end_time - start_time) * 1000
    print(f"   结果: {result2[0][0]}, 耗时: {time2:.2f}ms")
    
    # 检查缓存状态
    cache_stats = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
    print(f"   缓存状态: 条目={cache_stats[0][0]}, 命中={cache_stats[0][1]}, 未命中={cache_stats[0][2]}")
    
    # 第三次执行
    print("   第三次执行...")
    start_time = time.perf_counter()
    result3 = conn.execute(test_query).fetchall()
    end_time = time.perf_counter()
    time3 = (end_time - start_time) * 1000
    print(f"   结果: {result3[0][0]}, 耗时: {time3:.2f}ms")
    
    # 检查最终缓存状态
    cache_stats = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
    print(f"   最终缓存状态: 条目={cache_stats[0][0]}, 命中={cache_stats[0][1]}, 未命中={cache_stats[0][2]}")
    
    # 分析结果
    print(f"\n3. 性能分析:")
    print(f"   第一次执行: {time1:.2f}ms")
    print(f"   第二次执行: {time2:.2f}ms (加速比: {time1/time2:.2f}x)")
    print(f"   第三次执行: {time3:.2f}ms (加速比: {time1/time3:.2f}x)")
    
    if cache_stats[0][1] > 0:  # 有缓存命中
        print("   ✓ 查询缓存工作正常!")
    else:
        print("   ✗ 查询缓存没有命中")
    
    conn.close()

if __name__ == "__main__":
    test_query_cache()