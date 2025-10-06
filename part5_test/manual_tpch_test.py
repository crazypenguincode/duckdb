#!/usr/bin/env python3
"""
手动TPC-H缓存性能测试脚本
测试前3个查询的缓存性能对比
"""

import os
import sys
import time
import json
import subprocess
from datetime import datetime

def run_query_with_cache(duckdb_path, db_path, query_file, enable_cache=True):
    """运行单个查询并测量时间"""
    try:
        # 读取查询文件
        with open(query_file, 'r', encoding='utf-8') as f:
            sql_content = f.read().strip()
        
        # 构建命令
        cache_setting = "SET enable_query_cache=true;" if enable_cache else "SET enable_query_cache=false;"
        full_sql = f"{cache_setting} {sql_content}"
        
        cmd = [duckdb_path, db_path, "-c", full_sql]
        
        # 执行查询并测量时间
        start_time = time.time()
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        end_time = time.time()
        
        execution_time = end_time - start_time
        
        return {
            'success': result.returncode == 0,
            'execution_time': execution_time,
            'stdout': result.stdout[:200] if result.stdout else '',
            'stderr': result.stderr[:200] if result.stderr else ''
        }
    except Exception as e:
        return {
            'success': False,
            'execution_time': 0,
            'error': str(e)
        }

def main():
    print("=== TPC-H 缓存性能测试 (前3个查询) ===")
    
    # 配置路径
    duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 检查文件是否存在
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        return
    
    if not os.path.exists(db_path):
        print(f"错误: 数据库文件不存在: {db_path}")
        return
        
    if not os.path.exists(queries_dir):
        print(f"错误: 查询目录不存在: {queries_dir}")
        return
    
    print(f"DuckDB路径: {duckdb_path}")
    print(f"数据库路径: {db_path}")
    print(f"查询目录: {queries_dir}")
    print()
    
    results = {}
    
    # 测试前3个查询
    for i in range(1, 4):
        query_file = os.path.join(queries_dir, f"q{i:02d}.sql")
        if not os.path.exists(query_file):
            print(f"警告: 查询文件不存在: {query_file}")
            continue
        
        print(f"测试查询 Q{i:02d}...")
        
        # 测试无缓存
        print(f"  无缓存测试...")
        no_cache_result = run_query_with_cache(duckdb_path, db_path, query_file, enable_cache=False)
        
        # 测试有缓存 (第一次 - 冷缓存)
        print(f"  有缓存测试 (冷缓存)...")
        cold_cache_result = run_query_with_cache(duckdb_path, db_path, query_file, enable_cache=True)
        
        # 测试有缓存 (第二次 - 热缓存)
        print(f"  有缓存测试 (热缓存)...")
        hot_cache_result = run_query_with_cache(duckdb_path, db_path, query_file, enable_cache=True)
        
        results[f"Q{i:02d}"] = {
            'no_cache': no_cache_result,
            'cold_cache': cold_cache_result,
            'hot_cache': hot_cache_result
        }
        
        # 输出结果
        if no_cache_result['success'] and cold_cache_result['success'] and hot_cache_result['success']:
            print(f"  结果: 无缓存={no_cache_result['execution_time']:.3f}s, "
                  f"冷缓存={cold_cache_result['execution_time']:.3f}s, "
                  f"热缓存={hot_cache_result['execution_time']:.3f}s")
        else:
            print(f"  错误: 查询执行失败")
            if not no_cache_result['success']:
                print(f"    无缓存错误: {no_cache_result.get('stderr', 'Unknown error')}")
            if not cold_cache_result['success']:
                print(f"    冷缓存错误: {cold_cache_result.get('stderr', 'Unknown error')}")
            if not hot_cache_result['success']:
                print(f"    热缓存错误: {hot_cache_result.get('stderr', 'Unknown error')}")
        print()
    
    # 保存结果
    output_file = "manual_tpch_results.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            'timestamp': datetime.now().isoformat(),
            'test_config': {
                'duckdb_path': duckdb_path,
                'db_path': db_path,
                'queries_dir': queries_dir
            },
            'results': results
        }, f, indent=2, ensure_ascii=False)
    
    print(f"测试完成！结果已保存到: {output_file}")
    
    # 生成简单的性能对比报告
    print("\n=== 性能对比报告 ===")
    for query_name, query_results in results.items():
        if all(r['success'] for r in query_results.values()):
            no_cache_time = query_results['no_cache']['execution_time']
            hot_cache_time = query_results['hot_cache']['execution_time']
            speedup = no_cache_time / hot_cache_time if hot_cache_time > 0 else 0
            print(f"{query_name}: 无缓存={no_cache_time:.3f}s, 热缓存={hot_cache_time:.3f}s, 加速比={speedup:.2f}x")

if __name__ == "__main__":
    main()