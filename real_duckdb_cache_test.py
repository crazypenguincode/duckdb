#!/usr/bin/env python3
"""
实际DuckDB缓存性能验证脚本
使用真实的DuckDB实例测试缓存性能
"""

import subprocess
import time
import tempfile
import os
import json
import statistics
from pathlib import Path

class RealDuckDBCacheTest:
    def __init__(self):
        self.db_file = None
        self.results = []
        
    def setup_test_database(self):
        """设置测试数据库"""
        print("🔧 设置测试数据库...")
        
        # 创建临时数据库文件名
        import tempfile
        temp_dir = tempfile.gettempdir()
        self.db_file_path = os.path.join(temp_dir, f"duckdb_cache_test_{int(time.time())}.db")
        
        # 删除可能存在的文件
        if os.path.exists(self.db_file_path):
            os.unlink(self.db_file_path)
        
        # 初始化数据库和数据
        init_sql = """
        -- 安装TPC-H扩展
        INSTALL tpch;
        LOAD tpch;
        
        -- 生成小规模测试数据
        CALL dbgen(sf=0.01);
        
        -- 启用查询缓存
        SET enable_query_cache=true;
        SET query_cache_max_size='512MB';
        
        -- 验证数据
        SELECT 'lineitem' as table_name, COUNT(*) as row_count FROM lineitem
        UNION ALL
        SELECT 'orders' as table_name, COUNT(*) as row_count FROM orders
        UNION ALL  
        SELECT 'customer' as table_name, COUNT(*) as row_count FROM customer;
        """
        
        try:
            result = subprocess.run([
                'duckdb', self.db_file_path, '-c', init_sql
            ], capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                print("✅ 测试数据库设置完成")
                print("📊 数据统计:")
                print(result.stdout)
                return True
            else:
                print(f"❌ 数据库设置失败: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ 数据库设置超时")
            return False
        except Exception as e:
            print(f"❌ 数据库设置异常: {e}")
            return False
    
    def run_query_test(self, query_name, sql, complexity, iterations=3):
        """运行单个查询的性能测试"""
        print(f"  🔍 测试查询: {query_name}")
        
        # 第一次执行 (冷启动)
        print("    🔄 第一次执行 (冷启动)...")
        first_time = self.measure_query_time(sql)
        if first_time < 0:
            print("    ❌ 第一次执行失败")
            return None
        
        # 缓存读取测试 (热启动)
        print("    📖 测试缓存读取...")
        cache_times = []
        for i in range(iterations):
            cache_time = self.measure_query_time(sql)
            if cache_time > 0:
                cache_times.append(cache_time)
            time.sleep(0.1)  # 短暂等待
        
        if not cache_times:
            print("    ❌ 缓存读取测试失败")
            return None
        
        avg_cache_time = statistics.mean(cache_times)
        
        # 清空缓存，测试重新查询
        print("    🔄 清空缓存，测试重新查询...")
        self.clear_cache()
        
        requery_times = []
        for i in range(iterations):
            requery_time = self.measure_query_time(sql)
            if requery_time > 0:
                requery_times.append(requery_time)
            # 每次查询后清空缓存
            self.clear_cache()
            time.sleep(0.1)
        
        if not requery_times:
            print("    ❌ 重新查询测试失败")
            return None
        
        avg_requery_time = statistics.mean(requery_times)
        speedup_ratio = avg_requery_time / avg_cache_time if avg_cache_time > 0 else 1.0
        
        result = {
            'query_name': query_name,
            'complexity': complexity,
            'first_execution_ms': first_time,
            'avg_cache_read_ms': avg_cache_time,
            'avg_requery_ms': avg_requery_time,
            'speedup_ratio': speedup_ratio,
            'cache_times': cache_times,
            'requery_times': requery_times
        }
        
        print(f"    ✅ 第一次执行: {first_time:.2f}ms")
        print(f"    ✅ 平均缓存读取: {avg_cache_time:.2f}ms")
        print(f"    ✅ 平均重新查询: {avg_requery_time:.2f}ms")
        print(f"    ✅ 加速比: {speedup_ratio:.2f}x")
        
        return result
    
    def measure_query_time(self, sql):
        """测量查询执行时间"""
        try:
            start_time = time.time()
            result = subprocess.run([
                'duckdb', self.db_file_path, '-c', sql
            ], capture_output=True, text=True, timeout=30)
            end_time = time.time()
            
            if result.returncode == 0:
                return (end_time - start_time) * 1000  # 转换为毫秒
            else:
                print(f"      ⚠️ 查询执行错误: {result.stderr}")
                return -1
                
        except subprocess.TimeoutExpired:
            print("      ⚠️ 查询执行超时")
            return -1
        except Exception as e:
            print(f"      ⚠️ 查询执行异常: {e}")
            return -1
    
    def clear_cache(self):
        """清空查询缓存"""
        try:
            subprocess.run([
                'duckdb', self.db_file_path, '-c', 
                'PRAGMA query_cache_clear;'
            ], capture_output=True, text=True, timeout=5)
        except:
            # 如果清空缓存失败，忽略错误
            pass
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始实际DuckDB缓存性能测试")
        print("=" * 60)
        
        if not self.setup_test_database():
            print("❌ 数据库设置失败，无法继续测试")
            return
        
        # 定义测试查询
        test_queries = [
            # 简单查询
            {
                'name': 'Simple_Count',
                'sql': 'SELECT COUNT(*) FROM lineitem WHERE l_quantity > 10;',
                'complexity': 'simple'
            },
            {
                'name': 'Simple_Sum',
                'sql': '''SELECT SUM(l_extendedprice * l_discount) AS revenue 
                         FROM lineitem 
                         WHERE l_shipdate >= '1994-01-01' 
                         AND l_shipdate < '1995-01-01' 
                         AND l_discount BETWEEN 0.05 AND 0.07 
                         AND l_quantity < 24;''',
                'complexity': 'simple'
            },
            
            # 中等复杂查询
            {
                'name': 'Medium_Join',
                'sql': '''SELECT l_orderkey, 
                                SUM(l_extendedprice * (1 - l_discount)) AS revenue,
                                o_orderdate, o_shippriority
                         FROM customer, orders, lineitem
                         WHERE c_mktsegment = 'BUILDING'
                         AND c_custkey = o_custkey
                         AND l_orderkey = o_orderkey
                         AND o_orderdate < '1995-03-15'
                         AND l_shipdate > '1995-03-15'
                         GROUP BY l_orderkey, o_orderdate, o_shippriority
                         ORDER BY revenue DESC, o_orderdate
                         LIMIT 10;''',
                'complexity': 'medium'
            },
            {
                'name': 'Medium_Aggregate',
                'sql': '''SELECT l_returnflag, l_linestatus,
                                SUM(l_quantity) AS sum_qty,
                                SUM(l_extendedprice) AS sum_base_price,
                                SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
                                AVG(l_quantity) AS avg_qty,
                                AVG(l_extendedprice) AS avg_price,
                                AVG(l_discount) AS avg_disc,
                                COUNT(*) AS count_order
                         FROM lineitem
                         WHERE l_shipdate <= '1998-09-01'
                         GROUP BY l_returnflag, l_linestatus
                         ORDER BY l_returnflag, l_linestatus;''',
                'complexity': 'medium'
            },
            
            # 复杂查询
            {
                'name': 'Complex_Analysis',
                'sql': '''SELECT n_name, 
                                SUM(l_extendedprice * (1 - l_discount)) AS revenue
                         FROM customer, orders, lineitem, supplier, nation, region
                         WHERE c_custkey = o_custkey
                         AND l_orderkey = o_orderkey
                         AND l_suppkey = s_suppkey
                         AND c_nationkey = n_nationkey
                         AND n_regionkey = r_regionkey
                         AND r_name = 'ASIA'
                         AND o_orderdate >= '1994-01-01'
                         AND o_orderdate < '1995-01-01'
                         GROUP BY n_name
                         ORDER BY revenue DESC;''',
                'complexity': 'complex'
            }
        ]
        
        # 运行测试
        for query in test_queries:
            print(f"\n📊 测试 {query['complexity'].upper()} 复杂度查询")
            print("-" * 50)
            
            result = self.run_query_test(
                query['name'], 
                query['sql'], 
                query['complexity']
            )
            
            if result:
                self.results.append(result)
        
        # 生成报告
        self.generate_report()
        
        # 清理
        self.cleanup()
    
    def generate_report(self):
        """生成测试报告"""
        if not self.results:
            print("❌ 没有测试结果")
            return
        
        print("\n📊 实际测试结果汇总")
        print("=" * 80)
        
        # 按复杂度分组
        complexities = ['simple', 'medium', 'complex']
        
        for complexity in complexities:
            complexity_results = [r for r in self.results if r['complexity'] == complexity]
            if not complexity_results:
                continue
                
            print(f"\n🔍 {complexity.upper()} 复杂度查询")
            print("-" * 80)
            print(f"{'查询名称':<20} {'首次执行(ms)':<15} {'缓存读取(ms)':<15} {'重新查询(ms)':<15} {'加速比':<10}")
            print("-" * 80)
            
            for result in complexity_results:
                print(f"{result['query_name']:<20} "
                      f"{result['first_execution_ms']:<15.2f} "
                      f"{result['avg_cache_read_ms']:<15.2f} "
                      f"{result['avg_requery_ms']:<15.2f} "
                      f"{result['speedup_ratio']:<10.2f}x")
        
        # 整体统计
        print(f"\n📈 整体性能统计")
        print("-" * 50)
        
        all_speedups = [r['speedup_ratio'] for r in self.results]
        all_cache_times = [r['avg_cache_read_ms'] for r in self.results]
        all_requery_times = [r['avg_requery_ms'] for r in self.results]
        
        print(f"平均加速比: {statistics.mean(all_speedups):.2f}x")
        print(f"最大加速比: {max(all_speedups):.2f}x")
        print(f"最小加速比: {min(all_speedups):.2f}x")
        print(f"平均缓存读取时间: {statistics.mean(all_cache_times):.2f}ms")
        print(f"平均重新查询时间: {statistics.mean(all_requery_times):.2f}ms")
        print(f"平均时间节省: {statistics.mean(all_requery_times) - statistics.mean(all_cache_times):.2f}ms")
        
        # 保存详细结果
        with open('real_cache_performance_results.json', 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\n📁 详细结果已保存: real_cache_performance_results.json")
    
    def cleanup(self):
        """清理临时文件"""
        if hasattr(self, 'db_file_path') and os.path.exists(self.db_file_path):
            try:
                os.unlink(self.db_file_path)
                print("🧹 临时文件已清理")
            except:
                pass

def main():
    """主函数"""
    print("🎯 DuckDB 实际缓存性能验证")
    print("测试目标: 验证缓存读取 vs 重新查询的实际性能差异")
    print("=" * 60)
    
    # 检查DuckDB是否可用
    try:
        result = subprocess.run(['duckdb', '--version'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print("❌ DuckDB不可用")
            return 1
        print(f"✅ DuckDB版本: {result.stdout.strip()}")
    except:
        print("❌ 找不到DuckDB命令")
        return 1
    
    # 运行测试
    tester = RealDuckDBCacheTest()
    try:
        tester.run_all_tests()
        print("\n🎉 测试完成！")
        return 0
    except KeyboardInterrupt:
        print("\n⚠️ 测试被用户中断")
        tester.cleanup()
        return 1
    except Exception as e:
        print(f"\n❌ 测试过程中发生错误: {e}")
        tester.cleanup()
        return 1

if __name__ == "__main__":
    exit(main())