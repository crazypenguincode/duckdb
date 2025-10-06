#!/usr/bin/env python3
"""
简单的TPC-H缓存测试脚本
"""

import subprocess
import time
import json
from pathlib import Path

def main():
    print("=== TPC-H缓存性能测试 ===")
    
    # 配置
    duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
    database_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 检查文件存在性
    files_to_check = [
        (duckdb_exe, "DuckDB可执行文件"),
        (database_path, "TPC-H数据库"),
        (queries_dir, "查询目录")
    ]
    
    for file_path, description in files_to_check:
        if not Path(file_path).exists():
            print(f"❌ {description}不存在: {file_path}")
            return
        else:
            print(f"✅ {description}存在: {file_path}")
    
    # 测试前3个查询
    test_queries = ["q01.sql", "q02.sql", "q03.sql"]
    results = {}
    
    for query_file in test_queries:
        query_path = Path(queries_dir) / query_file
        if not query_path.exists():
            print(f"❌ 查询文件不存在: {query_path}")
            continue
            
        print(f"\n测试查询: {query_file}")
        
        # 读取查询内容
        with open(query_path, 'r') as f:
            query_sql = f.read()
        
        # 测试无缓存
        print("  测试无缓存...")
        cmd_no_cache = [
            duckdb_exe, database_path,
            "-c", "PRAGMA query_cache_mode='disabled'; " + query_sql
        ]
        
        start_time = time.time()
        try:
            result = subprocess.run(cmd_no_cache, capture_output=True, text=True, timeout=30)
            no_cache_time = time.time() - start_time
            print(f"    无缓存执行时间: {no_cache_time:.3f}秒")
        except subprocess.TimeoutExpired:
            print("    无缓存执行超时")
            no_cache_time = None
        except Exception as e:
            print(f"    无缓存执行错误: {e}")
            no_cache_time = None
        
        # 测试有缓存 - 第一次执行
        print("  测试有缓存(第一次)...")
        cmd_cache = [
            duckdb_exe, database_path,
            "-c", "PRAGMA query_cache_mode='enabled'; " + query_sql
        ]
        
        start_time = time.time()
        try:
            result = subprocess.run(cmd_cache, capture_output=True, text=True, timeout=30)
            cache_first_time = time.time() - start_time
            print(f"    有缓存第一次执行时间: {cache_first_time:.3f}秒")
        except subprocess.TimeoutExpired:
            print("    有缓存第一次执行超时")
            cache_first_time = None
        except Exception as e:
            print(f"    有缓存第一次执行错误: {e}")
            cache_first_time = None
        
        # 测试有缓存 - 第二次执行
        print("  测试有缓存(第二次)...")
        start_time = time.time()
        try:
            result = subprocess.run(cmd_cache, capture_output=True, text=True, timeout=30)
            cache_second_time = time.time() - start_time
            print(f"    有缓存第二次执行时间: {cache_second_time:.3f}秒")
        except subprocess.TimeoutExpired:
            print("    有缓存第二次执行超时")
            cache_second_time = None
        except Exception as e:
            print(f"    有缓存第二次执行错误: {e}")
            cache_second_time = None
        
        # 记录结果
        results[query_file] = {
            "no_cache_time": no_cache_time,
            "cache_first_time": cache_first_time,
            "cache_second_time": cache_second_time
        }
    
    # 输出结果
    print("\n=== 测试结果汇总 ===")
    for query_file, times in results.items():
        print(f"\n{query_file}:")
        if times["no_cache_time"]:
            print(f"  无缓存: {times['no_cache_time']:.3f}秒")
        if times["cache_first_time"]:
            print(f"  有缓存(第1次): {times['cache_first_time']:.3f}秒")
        if times["cache_second_time"]:
            print(f"  有缓存(第2次): {times['cache_second_time']:.3f}秒")
            if times["no_cache_time"] and times["cache_second_time"]:
                speedup = times["no_cache_time"] / times["cache_second_time"]
                print(f"  加速比: {speedup:.2f}x")
    
    # 保存结果到文件
    with open("simple_tpch_results.json", "w") as f:
        json.dump(results, f, indent=2)
    
    print(f"\n结果已保存到: simple_tpch_results.json")

if __name__ == "__main__":
    main()