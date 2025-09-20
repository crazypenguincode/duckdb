#!/usr/bin/env python3
"""
最小化布隆过滤器测试脚本
专门测试布隆过滤器的禁用功能
"""

import subprocess
import sys
import time
import os

def test_bloom_filter_basic(duckdb_path):
    """测试基本的布隆过滤器功能"""
    
    print("🎯 最小化布隆过滤器测试")
    print("=" * 50)
    
    # 简单的测试查询
    test_query = "SELECT COUNT(*), AVG(i) FROM generate_series(1, 1000) AS t(i)"
    
    configurations = [
        ("禁用布隆过滤器", 0),
        ("启用布隆过滤器", 100000)
    ]
    
    results = {}
    
    for config_name, bloom_size in configurations:
        print(f"\n📊 测试配置: {config_name} (大小: {bloom_size})")
        
        times = []
        for i in range(3):
            # 构建查询命令
            full_query = f"""
            SET enable_query_cache=true;
            SET query_cache_bloom_filter_size={bloom_size};
            {test_query}
            """
            
            try:
                start_time = time.time()
                result = subprocess.run(
                    [duckdb_path],
                    input=full_query,
                    text=True,
                    capture_output=True,
                    timeout=10
                )
                end_time = time.time()
                
                execution_time = (end_time - start_time) * 1000
                
                if result.returncode == 0:
                    times.append(execution_time)
                    print(f"   第{i+1}次: {execution_time:.2f}ms")
                else:
                    print(f"   第{i+1}次: 失败 - {result.stderr}")
                    
            except subprocess.TimeoutExpired:
                print(f"   第{i+1}次: 超时")
            except Exception as e:
                print(f"   第{i+1}次: 错误 - {e}")
        
        if times:
            avg_time = sum(times) / len(times)
            results[config_name] = avg_time
            print(f"   ✅ 平均时间: {avg_time:.2f}ms")
        else:
            print(f"   ❌ 所有测试失败")
            results[config_name] = None
    
    # 分析结果
    print("\n" + "=" * 50)
    print("📊 测试结果分析")
    print("=" * 50)
    
    if all(v is not None for v in results.values()):
        disabled_time = results["禁用布隆过滤器"]
        enabled_time = results["启用布隆过滤器"]
        
        print(f"禁用布隆过滤器: {disabled_time:.2f}ms")
        print(f"启用布隆过滤器: {enabled_time:.2f}ms")
        
        if disabled_time > 0:
            diff_percent = ((disabled_time - enabled_time) / disabled_time) * 100
            print(f"性能差异: {diff_percent:.1f}%")
            
            if abs(diff_percent) < 5:
                print("✅ 结果正常：布隆过滤器对简单查询影响很小")
            elif diff_percent > 0:
                print("✅ 结果正常：启用布隆过滤器略有优势")
            else:
                print("⚠️  异常：禁用布隆过滤器反而更快，可能存在问题")
        else:
            print("❌ 无法计算性能差异")
    else:
        print("❌ 测试失败，无法进行分析")
    
    return results

def main():
    if len(sys.argv) != 2:
        print("用法: python3 minimal_bloom_test.py <duckdb_path>")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"❌ DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    try:
        # 运行测试
        results = test_bloom_filter_basic(duckdb_path)
        
        print("\n🎉 最小化布隆过滤器测试完成！")
        
    except KeyboardInterrupt:
        print("\n⚠️ 测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()