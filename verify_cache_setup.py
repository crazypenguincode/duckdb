#!/usr/bin/env python3
"""
简单的DuckDB查询缓存功能验证脚本
"""

import duckdb
import time
import sys

def test_basic_functionality():
    """测试基本的查询缓存功能"""
    print("测试DuckDB查询缓存基本功能...")
    
    try:
        # 创建连接
        conn = duckdb.connect()
        
        # 创建测试表
        print("1. 创建测试表...")
        conn.execute("""
            CREATE TABLE test_orders AS 
            SELECT 
                i as order_id,
                (i % 100) as customer_id,
                (i % 1000) / 10.0 as amount
            FROM range(10000) t(i)
        """)
        
        # 尝试启用查询缓存
        print("2. 尝试启用查询缓存...")
        try:
            conn.execute("SET enable_query_cache = true")
            print("   ✓ 查询缓存设置成功")
        except Exception as e:
            print(f"   ⚠ 查询缓存设置失败: {e}")
            print("   注意: 当前DuckDB版本可能不支持查询缓存")
        
        # 执行测试查询
        test_query = "SELECT COUNT(*) as total_orders FROM test_orders WHERE amount > 50"
        
        print("3. 执行测试查询...")
        
        # 第一次执行
        start_time = time.perf_counter()
        result1 = conn.execute(test_query).fetchall()
        time1 = (time.perf_counter() - start_time) * 1000
        
        print(f"   第一次执行: {time1:.2f}ms, 结果: {result1}")
        
        # 第二次执行
        start_time = time.perf_counter()
        result2 = conn.execute(test_query).fetchall()
        time2 = (time.perf_counter() - start_time) * 1000
        
        print(f"   第二次执行: {time2:.2f}ms, 结果: {result2}")
        
        # 分析结果
        if result1 == result2:
            print("   ✓ 查询结果一致")
            
            if time2 < time1 * 0.8:  # 如果第二次执行时间明显更短
                print(f"   ✓ 可能存在缓存效果 (加速比: {time1/time2:.2f}x)")
            else:
                print("   - 未观察到明显的缓存加速效果")
        else:
            print("   ✗ 查询结果不一致")
        
        # 测试更复杂的查询
        print("4. 测试复杂查询...")
        complex_query = """
            SELECT 
                customer_id,
                COUNT(*) as order_count,
                AVG(amount) as avg_amount,
                SUM(amount) as total_amount
            FROM test_orders 
            WHERE amount BETWEEN 20 AND 80
            GROUP BY customer_id
            HAVING COUNT(*) > 50
            ORDER BY total_amount DESC
            LIMIT 10
        """
        
        # 执行复杂查询两次
        start_time = time.perf_counter()
        complex_result1 = conn.execute(complex_query).fetchall()
        complex_time1 = (time.perf_counter() - start_time) * 1000
        
        start_time = time.perf_counter()
        complex_result2 = conn.execute(complex_query).fetchall()
        complex_time2 = (time.perf_counter() - start_time) * 1000
        
        print(f"   复杂查询第一次: {complex_time1:.2f}ms")
        print(f"   复杂查询第二次: {complex_time2:.2f}ms")
        
        if complex_result1 == complex_result2:
            print("   ✓ 复杂查询结果一致")
            if complex_time2 < complex_time1 * 0.8:
                print(f"   ✓ 复杂查询可能存在缓存效果 (加速比: {complex_time1/complex_time2:.2f}x)")
            else:
                print("   - 复杂查询未观察到明显缓存效果")
        
        # 尝试获取缓存统计信息
        print("5. 尝试获取缓存统计信息...")
        try:
            # 这些API可能在当前版本中不存在
            stats_result = conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchall()
            print(f"   缓存统计: {stats_result}")
        except Exception as e:
            print(f"   ⚠ 无法获取缓存统计: {e}")
        
        conn.close()
        print("\n✓ 基本功能测试完成")
        return True
        
    except Exception as e:
        print(f"\n✗ 测试失败: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_python_packages():
    """测试Python包的可用性"""
    print("测试Python包依赖...")
    
    packages = {
        'duckdb': 'DuckDB Python包',
        'psutil': '系统监控包',
        'time': '时间处理包',
        'json': 'JSON处理包',
        'statistics': '统计计算包'
    }
    
    missing_packages = []
    
    for package, description in packages.items():
        try:
            __import__(package)
            print(f"   ✓ {description} - 可用")
        except ImportError:
            print(f"   ✗ {description} - 缺失")
            missing_packages.append(package)
    
    # 测试可选包
    optional_packages = {
        'matplotlib': '图表生成包',
        'pandas': '数据分析包'
    }
    
    for package, description in optional_packages.items():
        try:
            __import__(package)
            print(f"   ✓ {description} - 可用")
        except ImportError:
            print(f"   ⚠ {description} - 缺失 (可选)")
    
    if missing_packages:
        print(f"\n需要安装缺失的包: {', '.join(missing_packages)}")
        print("运行: pip install " + " ".join(missing_packages))
        return False
    else:
        print("\n✓ 所有必需的包都已安装")
        return True

def main():
    print("DuckDB查询缓存功能验证")
    print("=" * 50)
    
    # 测试Python包
    packages_ok = test_python_packages()
    
    print("\n" + "=" * 50)
    
    # 测试基本功能
    if packages_ok:
        functionality_ok = test_basic_functionality()
    else:
        print("跳过功能测试，因为缺少必需的包")
        functionality_ok = False
    
    print("\n" + "=" * 50)
    print("验证总结:")
    
    if packages_ok and functionality_ok:
        print("✓ 验证通过，可以运行完整的测试套件")
        print("\n建议运行:")
        print("  python3 run_cache_tests.py --quick")
        return 0
    elif packages_ok:
        print("⚠ 包依赖正常，但功能测试有问题")
        print("  可能是DuckDB版本不支持查询缓存，但测试脚本仍可运行")
        return 0
    else:
        print("✗ 验证失败，需要安装缺失的包")
        return 1

if __name__ == "__main__":
    sys.exit(main())