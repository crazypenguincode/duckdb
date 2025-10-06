#!/usr/bin/env python3
"""
简化的TPC-H缓存性能测试脚本
"""

import os
import sys
import time
import json
import subprocess
from datetime import datetime

# 配置
DUCKDB_PATH = "/Users/max/src/duckdb/build/release/duckdb"
DATABASE_PATH = "/Users/max/test/tpc/tpch-sf1.db"
QUERIES_DIR = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"

def test_single_query(query_file, use_cache=True):
    """测试单个查询"""
    try:
        # 读取查询
        query_path = os.path.join(QUERIES_DIR, query_file)
        with open(query_path, 'r') as f:
            query = f.read().strip()
        
        if not query.endswith(';'):
            query += ';'
        
        # 设置缓存
        cache_setting = "SET enable_query_cache=true;" if use_cache else "SET enable_query_cache=false;"
        full_sql = f"{cache_setting} {query}"
        
        # 执行查询
        start = time.time()
        result = subprocess.run([
            DUCKDB_PATH, DATABASE_PATH, "-c", full_sql
        ], capture_output=True, text=True, timeout=60)
        end = time.time()
        
        if result.returncode == 0:
            return end - start
        else:
            print(f"查询 {query_file} 失败: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"执行 {query_file} 时出错: {e}")
        return None

def main():
    print("开始TPC-H缓存性能测试...")
    
    # 验证环境
    if not os.path.exists(DUCKDB_PATH):
        print(f"DuckDB可执行文件不存在: {DUCKDB_PATH}")
        return
    
    if not os.path.exists(DATABASE_PATH):
        print(f"数据库文件不存在: {DATABASE_PATH}")
        return
    
    if not os.path.exists(QUERIES_DIR):
        print(f"查询目录不存在: {QUERIES_DIR}")
        return
    
    # 测试前5个查询
    results = {}
    
    for i in range(1, 6):  # 只测试q01-q05
        query_file = f"q{i:02d}.sql"
        query_path = os.path.join(QUERIES_DIR, query_file)
        
        if not os.path.exists(query_path):
            print(f"查询文件不存在: {query_file}")
            continue
        
        print(f"\n测试查询: {query_file}")
        
        # 无缓存测试
        print("  无缓存测试...")
        no_cache_time = test_single_query(query_file, use_cache=False)
        
        # 有缓存测试
        print("  有缓存测试...")
        with_cache_time = test_single_query(query_file, use_cache=True)
        
        if no_cache_time and with_cache_time:
            improvement = ((no_cache_time - with_cache_time) / no_cache_time) * 100
            results[query_file] = {
                'no_cache': no_cache_time,
                'with_cache': with_cache_time,
                'improvement': improvement
            }
            print(f"  无缓存: {no_cache_time:.3f}秒")
            print(f"  有缓存: {with_cache_time:.3f}秒")
            print(f"  性能提升: {improvement:.1f}%")
    
    # 保存结果
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_file = f"tpch_simple_test_{timestamp}.json"
    
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n测试完成！结果保存到: {results_file}")
    
    # 生成简单的对比图表
    if results:
        chart_file = f"tpch_simple_chart_{timestamp}.md"
        with open(chart_file, 'w') as f:
            f.write("# TPC-H缓存性能测试结果\n\n")
            f.write("| 查询 | 无缓存(秒) | 有缓存(秒) | 性能提升(%) |\n")
            f.write("|------|-----------|-----------|------------|\n")
            
            for query, data in results.items():
                f.write(f"| {query} | {data['no_cache']:.3f} | {data['with_cache']:.3f} | {data['improvement']:.1f}% |\n")
        
        print(f"图表保存到: {chart_file}")

if __name__ == "__main__":
    main()