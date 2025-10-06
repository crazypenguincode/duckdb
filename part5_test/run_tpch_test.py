#!/usr/bin/env python3
"""
快速TPC-H缓存测试脚本
"""

import os
import sys
import time
import json
import subprocess
import statistics
from datetime import datetime

def run_simple_test():
    """运行简单的TPC-H缓存测试"""
    
    # 配置
    duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    print("TPC-H缓存性能测试")
    print(f"DuckDB: {duckdb_exe}")
    print(f"数据库: {db_path}")
    print(f"查询目录: {queries_dir}")
    
    # 检查文件
    if not os.path.exists(duckdb_exe):
        print(f"❌ DuckDB可执行文件不存在")
        return
    
    if not os.path.exists(db_path):
        print(f"❌ 数据库文件不存在")
        return
        
    if not os.path.exists(queries_dir):
        print(f"❌ 查询目录不存在")
        return
    
    print("✅ 所有文件检查通过")
    
    # 测试简单查询
    test_query = "SELECT COUNT(*) FROM lineitem;"
    
    print("\n测试无缓存查询...")
    start_time = time.time()
    result = subprocess.run(
        [duckdb_exe, db_path],
        input="SET enable_query_cache=false;\n" + test_query,
        text=True,
        capture_output=True,
        timeout=60
    )
    no_cache_time = time.time() - start_time
    
    if result.returncode == 0:
        print(f"✅ 无缓存查询成功: {no_cache_time:.3f}s")
    else:
        print(f"❌ 无缓存查询失败: {result.stderr}")
        return
    
    print("\n测试有缓存查询...")
    start_time = time.time()
    result = subprocess.run(
        [duckdb_exe, db_path],
        input="SET enable_query_cache=true;\n" + test_query,
        text=True,
        capture_output=True,
        timeout=60
    )
    cache_time = time.time() - start_time
    
    if result.returncode == 0:
        print(f"✅ 有缓存查询成功: {cache_time:.3f}s")
    else:
        print(f"❌ 有缓存查询失败: {result.stderr}")
        return
    
    # 计算性能提升
    if no_cache_time > 0 and cache_time > 0:
        speedup = no_cache_time / cache_time
        improvement = (no_cache_time - cache_time) / no_cache_time * 100
        print(f"\n📊 性能对比:")
        print(f"   无缓存: {no_cache_time:.3f}s")
        print(f"   有缓存: {cache_time:.3f}s")
        print(f"   加速比: {speedup:.2f}x")
        print(f"   性能提升: {improvement:.1f}%")
    
    # 检查TPC-H查询文件
    print(f"\n📁 检查TPC-H查询文件:")
    query_files = []
    for i in range(1, 23):
        query_file = os.path.join(queries_dir, f"q{i:02d}.sql")
        if os.path.exists(query_file):
            query_files.append(query_file)
            print(f"   ✅ q{i:02d}.sql")
        else:
            print(f"   ❌ q{i:02d}.sql 不存在")
    
    print(f"\n找到 {len(query_files)} 个TPC-H查询文件")
    
    # 测试第一个TPC-H查询
    if query_files:
        print(f"\n测试第一个TPC-H查询: {os.path.basename(query_files[0])}")
        
        with open(query_files[0], 'r') as f:
            tpch_query = f.read()
        
        print("执行无缓存查询...")
        start_time = time.time()
        result = subprocess.run(
            [duckdb_exe, db_path],
            input="SET enable_query_cache=false;\n" + tpch_query,
            text=True,
            capture_output=True,
            timeout=300
        )
        tpch_no_cache_time = time.time() - start_time
        
        if result.returncode == 0:
            print(f"✅ TPC-H无缓存查询成功: {tpch_no_cache_time:.3f}s")
            
            print("执行有缓存查询...")
            start_time = time.time()
            result = subprocess.run(
                [duckdb_exe, db_path],
                input="SET enable_query_cache=true;\n" + tpch_query,
                text=True,
                capture_output=True,
                timeout=300
            )
            tpch_cache_time = time.time() - start_time
            
            if result.returncode == 0:
                print(f"✅ TPC-H有缓存查询成功: {tpch_cache_time:.3f}s")
                
                if tpch_no_cache_time > 0 and tpch_cache_time > 0:
                    speedup = tpch_no_cache_time / tpch_cache_time
                    improvement = (tpch_no_cache_time - tpch_cache_time) / tpch_no_cache_time * 100
                    print(f"\n📊 TPC-H查询性能对比:")
                    print(f"   无缓存: {tpch_no_cache_time:.3f}s")
                    print(f"   有缓存: {tpch_cache_time:.3f}s")
                    print(f"   加速比: {speedup:.2f}x")
                    print(f"   性能提升: {improvement:.1f}%")
            else:
                print(f"❌ TPC-H有缓存查询失败: {result.stderr}")
        else:
            print(f"❌ TPC-H无缓存查询失败: {result.stderr}")
    
    print("\n🎉 测试完成！")
    
    # 生成简单的Mermaid图表
    mermaid_chart = f"""
# TPC-H缓存测试结果

## 简单查询性能对比

```mermaid
xychart-beta
    title "查询执行时间对比"
    x-axis ["简单查询", "TPC-H Q01"]
    y-axis "执行时间(秒)" 0 --> {max(no_cache_time, cache_time, tpch_no_cache_time if 'tpch_no_cache_time' in locals() else 0, tpch_cache_time if 'tpch_cache_time' in locals() else 0) * 1.2:.1f}
    bar [无缓存] [{no_cache_time:.3f}, {tpch_no_cache_time if 'tpch_no_cache_time' in locals() else 0:.3f}]
    bar [有缓存] [{cache_time:.3f}, {tpch_cache_time if 'tpch_cache_time' in locals() else 0:.3f}]
```

## 性能提升百分比

```mermaid
xychart-beta
    title "缓存性能提升"
    x-axis ["简单查询", "TPC-H Q01"]
    y-axis "性能提升(%)" 0 --> 100
    line [性能提升] [{improvement:.1f}, {(tpch_no_cache_time - tpch_cache_time) / tpch_no_cache_time * 100 if 'tpch_no_cache_time' in locals() and 'tpch_cache_time' in locals() and tpch_no_cache_time > 0 else 0:.1f}]
```
    """
    
    with open("tpch_test_results.md", "w", encoding='utf-8') as f:
        f.write(mermaid_chart)
    
    print("📊 结果图表已保存到: tpch_test_results.md")

if __name__ == "__main__":
    run_simple_test()