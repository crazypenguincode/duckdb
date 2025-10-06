#!/usr/bin/env python3
"""
TPC-H 缓存性能测试 - 简化版本
直接输出到终端，避免被其他进程覆盖
"""

import os
import sys
import time
import subprocess
from datetime import datetime

def test_environment():
    """测试环境检查"""
    print("🔍 环境检查...")
    
    duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    issues = []
    
    if not os.path.exists(duckdb_exe):
        issues.append(f"❌ DuckDB可执行文件不存在: {duckdb_exe}")
    else:
        print(f"✅ DuckDB可执行文件: {duckdb_exe}")
    
    if not os.path.exists(db_path):
        issues.append(f"❌ 数据库文件不存在: {db_path}")
    else:
        print(f"✅ 数据库文件: {db_path}")
    
    if not os.path.exists(queries_dir):
        issues.append(f"❌ 查询目录不存在: {queries_dir}")
    else:
        query_files = [f for f in os.listdir(queries_dir) if f.endswith('.sql')]
        print(f"✅ 查询目录: {queries_dir} (找到 {len(query_files)} 个SQL文件)")
    
    if issues:
        print("\n❌ 环境检查失败:")
        for issue in issues:
            print(f"  {issue}")
        return False
    
    print("✅ 环境检查通过!")
    return True

def run_single_query_test(duckdb_exe, db_path, query_file, query_name):
    """运行单个查询的缓存测试"""
    print(f"\n📊 测试查询: {query_name}")
    
    try:
        # 读取查询内容
        with open(query_file, 'r') as f:
            query_content = f.read()
        
        # 测试无缓存
        print("  🔄 测试无缓存...")
        no_cache_query = f"SET enable_query_cache=false; PRAGMA disable_optimizer;\n{query_content}"
        
        start_time = time.time()
        result = subprocess.run(
            [duckdb_exe, db_path],
            input=no_cache_query,
            text=True,
            capture_output=True,
            timeout=60
        )
        no_cache_time = time.time() - start_time
        
        if result.returncode != 0:
            print(f"    ❌ 无缓存查询失败")
            return None
        
        print(f"    ⏱️  无缓存时间: {no_cache_time:.3f}s")
        
        # 测试有缓存
        print("  ⚡ 测试有缓存...")
        cache_query = f"SET enable_query_cache=true;\n{query_content}"
        
        start_time = time.time()
        result = subprocess.run(
            [duckdb_exe, db_path],
            input=cache_query,
            text=True,
            capture_output=True,
            timeout=60
        )
        cache_time = time.time() - start_time
        
        if result.returncode != 0:
            print(f"    ❌ 缓存查询失败")
            return None
        
        print(f"    ⏱️  有缓存时间: {cache_time:.3f}s")
        
        # 计算性能提升
        if cache_time > 0:
            improvement = (no_cache_time - cache_time) / no_cache_time * 100
            speedup = no_cache_time / cache_time
            
            print(f"    📈 性能提升: {improvement:.1f}%")
            print(f"    📈 加速比: {speedup:.2f}x")
            
            return {
                'query': query_name,
                'no_cache_time': no_cache_time,
                'cache_time': cache_time,
                'improvement': improvement,
                'speedup': speedup
            }
        
    except subprocess.TimeoutExpired:
        print(f"    ⏰ 查询超时")
    except Exception as e:
        print(f"    ❌ 执行错误: {str(e)}")
    
    return None

def main():
    print("🚀 TPC-H 缓存性能测试 - 简化版本")
    print("=" * 50)
    
    # 环境检查
    if not test_environment():
        return
    
    # 配置
    duckdb_exe = "/Users/max/src/duckdb/build/release/duckdb"
    db_path = "/Users/max/test/tpc/tpch-sf1.db"
    queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
    
    # 测试前3个查询
    test_queries = []
    for i in range(1, 4):  # 只测试前3个查询
        query_file = os.path.join(queries_dir, f"q{i:02d}.sql")
        if os.path.exists(query_file):
            test_queries.append((query_file, f"q{i:02d}"))
    
    print(f"\n📋 将测试 {len(test_queries)} 个查询")
    
    # 执行测试
    results = []
    for query_file, query_name in test_queries:
        result = run_single_query_test(duckdb_exe, db_path, query_file, query_name)
        if result:
            results.append(result)
    
    # 生成总结
    if results:
        print(f"\n{'='*50}")
        print("📊 测试总结:")
        print(f"  成功测试查询: {len(results)}")
        
        avg_improvement = sum(r['improvement'] for r in results) / len(results)
        avg_speedup = sum(r['speedup'] for r in results) / len(results)
        
        print(f"  平均性能提升: {avg_improvement:.1f}%")
        print(f"  平均加速比: {avg_speedup:.2f}x")
        
        print("\n📋 详细结果:")
        for result in results:
            print(f"  {result['query']}: {result['improvement']:.1f}% 提升, {result['speedup']:.2f}x 加速")
        
        # 保存简单结果
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        result_file = f"tpch_simple_test_{timestamp}.txt"
        
        with open(result_file, 'w', encoding='utf-8') as f:
            f.write(f"TPC-H缓存性能测试结果 - {timestamp}\n")
            f.write("="*50 + "\n")
            f.write(f"成功测试查询: {len(results)}\n")
            f.write(f"平均性能提升: {avg_improvement:.1f}%\n")
            f.write(f"平均加速比: {avg_speedup:.2f}x\n\n")
            f.write("详细结果:\n")
            for result in results:
                f.write(f"{result['query']}: 无缓存={result['no_cache_time']:.3f}s, 有缓存={result['cache_time']:.3f}s, 提升={result['improvement']:.1f}%, 加速={result['speedup']:.2f}x\n")
        
        print(f"\n📄 结果已保存到: {result_file}")
        
    else:
        print("❌ 没有成功的测试结果")

if __name__ == "__main__":
    main()