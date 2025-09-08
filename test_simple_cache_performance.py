#!/usr/bin/env python3
"""
简化的DuckDB查询缓存测试脚本 - 使用内存数据库
"""

import subprocess
import tempfile
import os
import time

def test_query_cache():
    duckdb_path = "./build/release/duckdb"
    
    # 创建测试SQL文件 - 使用内存数据库
    sql_content = """
-- 启用查询缓存
PRAGMA enable_query_cache=true;

-- 创建测试表
CREATE TABLE test_table AS SELECT range AS id, range * 2 AS value FROM range(100000);

-- 检查初始状态
.print "=== 初始缓存状态 ==="
SELECT * FROM pragma_query_cache_stats();

-- 第一次执行查询
.print "=== 第一次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 第二次执行相同查询
.print "=== 第二次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 第三次执行相同查询
.print "=== 第三次执行 SELECT COUNT(*) FROM test_table ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 测试不同查询
.print "=== 执行不同查询 SELECT SUM(value) FROM test_table ==="
.timer on
SELECT SUM(value) FROM test_table;
.timer off

-- 检查缓存状态
SELECT * FROM pragma_query_cache_stats();

-- 再次执行第一个查询
.print "=== 再次执行第一个查询 ==="
.timer on
SELECT COUNT(*) FROM test_table;
.timer off

-- 最终缓存状态
.print "=== 最终缓存状态 ==="
SELECT * FROM pragma_query_cache_stats();
"""
    
    # 写入临时文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        f.write(sql_content)
        temp_file = f.name
    
    try:
        # 执行测试
        print("开始查询缓存测试...")
        result = subprocess.run(
            [duckdb_path, "-init", temp_file],  # 使用内存数据库
            capture_output=True,
            text=True,
            timeout=30  # 减少超时时间
        )
        
        print("=== 测试输出 ===")
        print(result.stdout)
        
        if result.stderr:
            print("=== 错误输出 ===")
            print(result.stderr)
            
        # 分析结果
        analyze_cache_performance(result.stdout)
        
    finally:
        # 清理临时文件
        try:
            os.unlink(temp_file)
        except:
            pass

def analyze_cache_performance(output):
    """分析缓存性能"""
    lines = output.split('\n')
    
    cache_stats = []
    execution_times = []
    
    # 提取缓存统计信息
    for i, line in enumerate(lines):
        if '│' in line and line.count('│') >= 6:
            parts = [p.strip() for p in line.split('│') if p.strip()]
            if len(parts) >= 6 and parts[0].isdigit():
                stats = {
                    'total_entries': int(parts[0]),
                    'total_hits': int(parts[1]),
                    'total_misses': int(parts[2]),
                    'hit_rate': float(parts[3]),
                    'memory_usage_bytes': int(parts[4]),
                    'enabled': parts[6] == 'true' if len(parts) > 6 else True
                }
                cache_stats.append(stats)
        
        # 提取执行时间
        if 'Run Time' in line and 'real' in line:
            parts = line.split()
            for j, part in enumerate(parts):
                if part == 'real' and j + 1 < len(parts):
                    time_str = parts[j + 1]
                    if time_str.endswith('s'):
                        execution_times.append(float(time_str[:-1]))
                    break
    
    print("\n=== 性能分析结果 ===")
    print(f"提取到 {len(cache_stats)} 个缓存统计记录")
    print(f"提取到 {len(execution_times)} 个执行时间记录")
    
    if cache_stats:
        print("\n缓存统计变化:")
        for i, stats in enumerate(cache_stats):
            print(f"  记录 {i+1}: 条目={stats['total_entries']}, 命中={stats['total_hits']}, 未命中={stats['total_misses']}, 命中率={stats['hit_rate']:.1%}")
    
    if execution_times:
        print(f"\n执行时间:")
        for i, time_val in enumerate(execution_times):
            print(f"  执行 {i+1}: {time_val:.6f}s")
        
        # 计算加速比
        if len(execution_times) >= 2:
            speedup = execution_times[0] / execution_times[1]
            print(f"\n第一次 vs 第二次加速比: {speedup:.2f}x")
            
            if speedup > 1.5:
                print("✅ 查询缓存显著提升了性能!")
            elif speedup > 1.1:
                print("✅ 查询缓存提升了性能")
            else:
                print("⚠️  查询缓存效果不明显")
        
        # 分析多次执行的性能
        if len(execution_times) >= 3:
            print(f"\n多次执行分析:")
            print(f"  第1次: {execution_times[0]:.6f}s (首次执行)")
            print(f"  第2次: {execution_times[1]:.6f}s (缓存命中)")
            print(f"  第3次: {execution_times[2]:.6f}s (缓存命中)")
            
            avg_cached_time = (execution_times[1] + execution_times[2]) / 2
            overall_speedup = execution_times[0] / avg_cached_time
            print(f"  平均缓存加速比: {overall_speedup:.2f}x")
    
    # 检查缓存是否真正工作
    if cache_stats and len(cache_stats) >= 2:
        initial_hits = cache_stats[0]['total_hits']
        final_hits = cache_stats[-1]['total_hits']
        
        if final_hits > initial_hits:
            print(f"✅ 缓存正常工作! 总命中次数从 {initial_hits} 增加到 {final_hits}")
            
            # 分析缓存效率
            total_queries = final_hits + cache_stats[-1]['total_misses']
            if total_queries > 0:
                hit_rate = final_hits / total_queries
                print(f"✅ 整体缓存命中率: {hit_rate:.1%}")
        else:
            print("❌ 缓存可能没有正常工作，没有检测到缓存命中")

if __name__ == "__main__":
    test_query_cache()