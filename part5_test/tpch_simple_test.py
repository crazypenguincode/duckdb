#!/usr/bin/env python3
"""TPC-H 缓存性能测试脚本"""

import os
import time
import subprocess
import json
from datetime import datetime

def test_cache_performance():
    print("🚀 TPC-H 缓存性能测试开始")
    
    # 配置
    duckdb_exe = '/Users/max/src/duckdb/build/release/duckdb'
    database = '/Users/max/test/tpc/tpch-sf1.db'
    
    # 环境检查
    if not os.path.exists(duckdb_exe):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_exe}")
        return
    if not os.path.exists(database):
        print(f"❌ 数据库文件不存在: {database}")
        return
    
    print("✅ 环境检查通过")
    
    # 测试查询
    test_sql = "SELECT COUNT(*) FROM lineitem LIMIT 1;"
    
    # 无缓存测试
    print("📊 无缓存测试...")
    no_cache_sql = f"SET enable_query_cache=false;\n{test_sql}"
    start_time = time.time()
    subprocess.run([duckdb_exe, database, "-c", no_cache_sql], 
                   capture_output=True, text=True, timeout=30)
    no_cache_time = time.time() - start_time
    print(f"⏱️  无缓存时间: {no_cache_time:.3f}s")
    
    # 缓存测试
    print("📊 缓存测试...")
    cache_sql = f"SET enable_query_cache=true;\n{test_sql}"
    
    # 预热
    subprocess.run([duckdb_exe, database, "-c", cache_sql], 
                   capture_output=True, text=True, timeout=30)
    
    # 实际测试
    start_time = time.time()
    subprocess.run([duckdb_exe, database, "-c", cache_sql], 
                   capture_output=True, text=True, timeout=30)
    cache_time = time.time() - start_time
    print(f"⏱️  缓存时间: {cache_time:.3f}s")
    
    # 计算性能提升
    speedup = no_cache_time / cache_time if cache_time > 0 else 0
    improvement = (no_cache_time - cache_time) / no_cache_time * 100 if no_cache_time > 0 else 0
    print(f"🚀 性能提升: {speedup:.2f}x ({improvement:.1f}%)")
    
    # 保存结果
    result = {
        'test_time': datetime.now().isoformat(),
        'no_cache_time': no_cache_time,
        'cache_time': cache_time,
        'speedup': speedup,
        'improvement_percent': improvement
    }
    
    with open('tpch_test_result.json', 'w') as f:
        json.dump(result, f, indent=2)
    
    print("✅ 测试完成，结果保存到 tpch_test_result.json")

if __name__ == "__main__":
    test_cache_performance()