#!/usr/bin/env python3
"""
调试缓存功能的测试脚本
检查缓存是否正确开启和工作
"""

import os
import sys
import time
import subprocess
import json
from pathlib import Path
from datetime import datetime

def check_duckdb_cache_support(duckdb_path):
    """检查DuckDB是否支持查询缓存"""
    print("=== 检查DuckDB缓存支持 ===")
    
    try:
        # 检查是否有缓存相关的设置
        result = subprocess.run([
            duckdb_path, ":memory:", "-c", 
            "SELECT name, value FROM duckdb_settings() WHERE name LIKE '%cache%';"
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            print("✓ DuckDB缓存设置:")
            if result.stdout.strip():
                print(result.stdout)
            else:
                print("  未找到缓存相关设置")
        else:
            print(f"✗ 查询缓存设置失败: {result.stderr}")
            
        # 尝试设置缓存
        result2 = subprocess.run([
            duckdb_path, ":memory:", "-c", 
            "SET enable_query_cache = true; SELECT current_setting('enable_query_cache');"
        ], capture_output=True, text=True, timeout=10)
        
        if result2.returncode == 0:
            print("✓ 缓存设置测试:")
            print(f"  结果: {result2.stdout.strip()}")
            return True
        else:
            print(f"✗ 缓存设置失败: {result2.stderr}")
            return False
            
    except Exception as e:
        print(f"✗ 检查缓存支持时发生异常: {e}")
        return False

def test_cache_functionality(duckdb_path, db_path):
    """测试缓存功能是否正常工作"""
    print("\n=== 测试缓存功能 ===")
    
    # 创建测试数据
    create_sql = """
    CREATE TABLE cache_test AS 
    SELECT 
        i as id,
        'test_' || i as name,
        random() * 1000 as value
    FROM range(1000) t(i);
    """
    
    try:
        # 创建数据库
        result = subprocess.run([
            duckdb_path, str(db_path), "-c", create_sql
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"✗ 创建测试数据失败: {result.stderr}")
            return False
        
        print("✓ 测试数据创建成功")
        
        # 测试查询
        test_query = "SELECT COUNT(*), AVG(value) FROM cache_test WHERE value > 500;"
        
        # 第一次执行（无缓存）
        print("\n--- 第一次执行（无缓存） ---")
        start_time = time.time()
        result1 = subprocess.run([
            duckdb_path, str(db_path), "-c", 
            f"SET enable_query_cache = false; {test_query}"
        ], capture_output=True, text=True)
        time1 = (time.time() - start_time) * 1000
        
        if result1.returncode == 0:
            print(f"✓ 无缓存执行成功: {time1:.2f}ms")
            print(f"  结果: {result1.stdout.strip()}")
        else:
            print(f"✗ 无缓存执行失败: {result1.stderr}")
            return False
        
        # 第二次执行（启用缓存，第一次）
        print("\n--- 第二次执行（启用缓存，第一次） ---")
        start_time = time.time()
        result2 = subprocess.run([
            duckdb_path, str(db_path), "-c", 
            f"SET enable_query_cache = true; {test_query}"
        ], capture_output=True, text=True)
        time2 = (time.time() - start_time) * 1000
        
        if result2.returncode == 0:
            print(f"✓ 缓存执行成功（第一次）: {time2:.2f}ms")
            print(f"  结果: {result2.stdout.strip()}")
        else:
            print(f"✗ 缓存执行失败: {result2.stderr}")
            return False
        
        # 第三次执行（启用缓存，应该命中缓存）
        print("\n--- 第三次执行（启用缓存，应该命中缓存） ---")
        start_time = time.time()
        result3 = subprocess.run([
            duckdb_path, str(db_path), "-c", 
            f"SET enable_query_cache = true; {test_query}"
        ], capture_output=True, text=True)
        time3 = (time.time() - start_time) * 1000
        
        if result3.returncode == 0:
            print(f"✓ 缓存执行成功（第二次）: {time3:.2f}ms")
            print(f"  结果: {result3.stdout.strip()}")
        else:
            print(f"✗ 缓存执行失败: {result3.stderr}")
            return False
        
        # 分析结果
        print(f"\n=== 性能分析 ===")
        print(f"无缓存时间: {time1:.2f}ms")
        print(f"缓存第一次: {time2:.2f}ms")
        print(f"缓存第二次: {time3:.2f}ms")
        
        if time3 < time2:
            improvement = (time2 - time3) / time2 * 100
            print(f"✓ 缓存生效！性能提升: {improvement:.2f}%")
            return True
        else:
            print("⚠️ 缓存可能未生效，第二次执行时间未减少")
            
            # 检查是否是查询太简单导致的
            if time1 < 10 and time2 < 10 and time3 < 10:
                print("💡 提示: 查询执行时间很短，缓存效果可能不明显")
                print("   建议使用更复杂的查询进行测试")
            
            return False
            
    except Exception as e:
        print(f"✗ 测试缓存功能时发生异常: {e}")
        return False

def test_complex_query_cache(duckdb_path, db_path):
    """测试复杂查询的缓存效果"""
    print("\n=== 测试复杂查询缓存 ===")
    
    # 创建更大的测试数据
    create_sql = """
    DROP TABLE IF EXISTS large_test;
    CREATE TABLE large_test AS 
    SELECT 
        i as id,
        'category_' || (i % 10) as category,
        'name_' || i as name,
        random() * 10000 as value,
        (random() * 100)::int as score
    FROM range(50000) t(i);
    
    CREATE INDEX idx_category ON large_test(category);
    CREATE INDEX idx_value ON large_test(value);
    """
    
    try:
        # 创建大数据集
        print("创建大数据集...")
        result = subprocess.run([
            duckdb_path, str(db_path), "-c", create_sql
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode != 0:
            print(f"✗ 创建大数据集失败: {result.stderr}")
            return False
        
        print("✓ 大数据集创建成功")
        
        # 复杂查询
        complex_query = """
        WITH category_stats AS (
            SELECT 
                category,
                COUNT(*) as count,
                AVG(value) as avg_value,
                STDDEV(value) as std_value
            FROM large_test 
            WHERE value > 1000
            GROUP BY category
        ),
        ranked_categories AS (
            SELECT 
                *,
                ROW_NUMBER() OVER (ORDER BY avg_value DESC) as rank
            FROM category_stats
        )
        SELECT 
            category,
            count,
            avg_value,
            std_value,
            rank
        FROM ranked_categories
        WHERE rank <= 5
        ORDER BY rank;
        """
        
        print("执行复杂查询测试...")
        
        # 多次执行测试
        times = []
        for i in range(5):
            cache_enabled = i > 0  # 第一次不启用缓存，后续启用
            cache_setting = "SET enable_query_cache = true;" if cache_enabled else "SET enable_query_cache = false;"
            
            start_time = time.time()
            result = subprocess.run([
                duckdb_path, str(db_path), "-c", 
                f"{cache_setting} {complex_query}"
            ], capture_output=True, text=True, timeout=30)
            execution_time = (time.time() - start_time) * 1000
            
            if result.returncode == 0:
                times.append(execution_time)
                cache_status = "缓存" if cache_enabled else "无缓存"
                print(f"  第{i+1}次执行 ({cache_status}): {execution_time:.2f}ms")
            else:
                print(f"✗ 第{i+1}次执行失败: {result.stderr}")
                return False
        
        # 分析结果
        if len(times) >= 3:
            no_cache_time = times[0]
            cache_times = times[1:]
            avg_cache_time = sum(cache_times) / len(cache_times)
            
            print(f"\n=== 复杂查询性能分析 ===")
            print(f"无缓存时间: {no_cache_time:.2f}ms")
            print(f"平均缓存时间: {avg_cache_time:.2f}ms")
            
            if avg_cache_time < no_cache_time:
                improvement = (no_cache_time - avg_cache_time) / no_cache_time * 100
                print(f"✓ 缓存效果显著！性能提升: {improvement:.2f}%")
                return True
            else:
                print("⚠️ 缓存效果不明显")
                return False
        
        return False
        
    except Exception as e:
        print(f"✗ 测试复杂查询缓存时发生异常: {e}")
        return False

def check_cache_statistics(duckdb_path, db_path):
    """检查缓存统计信息"""
    print("\n=== 检查缓存统计信息 ===")
    
    try:
        # 尝试查询缓存统计
        stats_queries = [
            "SELECT * FROM duckdb_caches();",
            "SELECT * FROM duckdb_memory();",
            "PRAGMA show_tables;",
            "SELECT current_setting('enable_query_cache');",
        ]
        
        for query in stats_queries:
            print(f"\n执行: {query}")
            result = subprocess.run([
                duckdb_path, str(db_path), "-c", 
                f"SET enable_query_cache = true; {query}"
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                if result.stdout.strip():
                    print(f"✓ 结果:\n{result.stdout}")
                else:
                    print("✓ 查询成功，但无结果")
            else:
                print(f"✗ 查询失败: {result.stderr}")
    
    except Exception as e:
        print(f"✗ 检查缓存统计时发生异常: {e}")

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python debug_cache_test.py <duckdb_path>")
        print("Example: python debug_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    print("DuckDB缓存功能调试测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 测试数据库路径
    db_path = Path("debug_cache_test.db")
    
    try:
        # 删除旧的测试数据库
        if db_path.exists():
            db_path.unlink()
        
        # 第一步：检查缓存支持
        cache_supported = check_duckdb_cache_support(duckdb_path)
        
        if not cache_supported:
            print("\n❌ DuckDB可能不支持查询缓存功能")
            print("💡 建议:")
            print("   1. 检查DuckDB版本是否支持查询缓存")
            print("   2. 确认编译时是否启用了缓存功能")
            print("   3. 尝试使用最新版本的DuckDB")
            sys.exit(1)
        
        # 第二步：测试基本缓存功能
        basic_cache_works = test_cache_functionality(duckdb_path, db_path)
        
        # 第三步：测试复杂查询缓存
        complex_cache_works = test_complex_query_cache(duckdb_path, db_path)
        
        # 第四步：检查缓存统计
        check_cache_statistics(duckdb_path, db_path)
        
        # 总结
        print("\n" + "=" * 60)
        print("=== 测试总结 ===")
        
        if basic_cache_works and complex_cache_works:
            print("🎉 缓存功能正常工作！")
            print("✓ 基本缓存测试通过")
            print("✓ 复杂查询缓存测试通过")
        elif basic_cache_works:
            print("⚠️ 缓存功能部分工作")
            print("✓ 基本缓存测试通过")
            print("✗ 复杂查询缓存测试失败")
        else:
            print("❌ 缓存功能可能存在问题")
            print("✗ 基本缓存测试失败")
            
            print("\n💡 可能的原因:")
            print("   1. DuckDB版本不支持查询缓存")
            print("   2. 缓存功能未正确编译")
            print("   3. 查询太简单，缓存效果不明显")
            print("   4. 系统配置问题")
            
            print("\n🔧 建议解决方案:")
            print("   1. 检查DuckDB版本: ./duckdb --version")
            print("   2. 重新编译DuckDB并确保启用缓存功能")
            print("   3. 使用更复杂的查询进行测试")
            print("   4. 检查系统内存和权限设置")
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"\n🧹 已清理测试数据库: {db_path}")
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()