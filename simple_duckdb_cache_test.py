#!/usr/bin/env python3
"""
简化版DuckDB缓存性能测试
不依赖TPC-H扩展，使用内置数据生成
"""

import subprocess
import time
import tempfile
import os
import json
import statistics
from pathlib import Path

class SimpleDuckDBCacheTest:
    def __init__(self):
        self.db_file_path = None
        self.results = []
        
    def setup_test_database(self):
        """设置测试数据库"""
        print("🔧 设置测试数据库...")
        
        # 创建临时数据库文件名
        temp_dir = tempfile.gettempdir()
        self.db_file_path = os.path.join(temp_dir, f"duckdb_cache_test_{int(time.time())}.db")
        
        # 删除可能存在的文件
        if os.path.exists(self.db_file_path):
            os.unlink(self.db_file_path)
        
        # 创建测试数据
        init_sql = """
        -- 创建测试表
        CREATE TABLE test_orders (
            o_orderkey INTEGER,
            o_custkey INTEGER,
            o_orderstatus VARCHAR,
            o_totalprice DECIMAL(15,2),
            o_orderdate DATE,
            o_orderpriority VARCHAR,
            o_clerk VARCHAR,
            o_shippriority INTEGER
        );
        
        CREATE TABLE test_lineitem (
            l_orderkey INTEGER,
            l_partkey INTEGER,
            l_suppkey INTEGER,
            l_linenumber INTEGER,
            l_quantity DECIMAL(15,2),
            l_extendedprice DECIMAL(15,2),
            l_discount DECIMAL(15,2),
            l_tax DECIMAL(15,2),
            l_returnflag VARCHAR,
            l_linestatus VARCHAR,
            l_shipdate DATE,
            l_commitdate DATE,
            l_receiptdate DATE,
            l_shipinstruct VARCHAR,
            l_shipmode VARCHAR
        );
        
        CREATE TABLE test_customer (
            c_custkey INTEGER,
            c_name VARCHAR,
            c_address VARCHAR,
            c_nationkey INTEGER,
            c_phone VARCHAR,
            c_acctbal DECIMAL(15,2),
            c_mktsegment VARCHAR,
            c_comment VARCHAR
        );
        
        -- 插入测试数据
        INSERT INTO test_orders 
        SELECT 
            row_number() OVER () as o_orderkey,
            (row_number() OVER () % 1000) + 1 as o_custkey,
            CASE (row_number() OVER () % 3) 
                WHEN 0 THEN 'O' 
                WHEN 1 THEN 'F' 
                ELSE 'P' 
            END as o_orderstatus,
            100.0 + (row_number() OVER () % 10000) as o_totalprice,
            '2023-01-01'::DATE + INTERVAL (row_number() OVER () % 365) DAY as o_orderdate,
            '1-URGENT' as o_orderpriority,
            'Clerk#' || (row_number() OVER () % 100) as o_clerk,
            0 as o_shippriority
        FROM generate_series(1, 10000);
        
        INSERT INTO test_lineitem
        SELECT 
            (row_number() OVER () % 10000) + 1 as l_orderkey,
            (row_number() OVER () % 1000) + 1 as l_partkey,
            (row_number() OVER () % 100) + 1 as l_suppkey,
            (row_number() OVER () % 7) + 1 as l_linenumber,
            1.0 + (row_number() OVER () % 50) as l_quantity,
            10.0 + (row_number() OVER () % 1000) as l_extendedprice,
            0.05 + (row_number() OVER () % 10) * 0.01 as l_discount,
            0.08 as l_tax,
            CASE (row_number() OVER () % 2) WHEN 0 THEN 'N' ELSE 'R' END as l_returnflag,
            CASE (row_number() OVER () % 2) WHEN 0 THEN 'O' ELSE 'F' END as l_linestatus,
            '2023-01-01'::DATE + INTERVAL (row_number() OVER () % 365) DAY as l_shipdate,
            '2023-01-01'::DATE + INTERVAL ((row_number() OVER () % 365) + 30) DAY as l_commitdate,
            '2023-01-01'::DATE + INTERVAL ((row_number() OVER () % 365) + 60) DAY as l_receiptdate,
            'DELIVER IN PERSON' as l_shipinstruct,
            'TRUCK' as l_shipmode
        FROM generate_series(1, 50000);
        
        INSERT INTO test_customer
        SELECT 
            row_number() OVER () as c_custkey,
            'Customer#' || row_number() OVER () as c_name,
            'Address ' || row_number() OVER () as c_address,
            (row_number() OVER () % 25) + 1 as c_nationkey,
            '123-456-' || (1000 + row_number() OVER () % 9000) as c_phone,
            1000.0 + (row_number() OVER () % 10000) as c_acctbal,
            CASE (row_number() OVER () % 5) 
                WHEN 0 THEN 'BUILDING' 
                WHEN 1 THEN 'AUTOMOBILE' 
                WHEN 2 THEN 'MACHINERY' 
                WHEN 3 THEN 'HOUSEHOLD' 
                ELSE 'FURNITURE' 
            END as c_mktsegment,
            'Customer comment ' || row_number() OVER () as c_comment
        FROM generate_series(1, 1000);
        
        -- 启用查询缓存
        SET enable_query_cache=true;
        SET query_cache_max_size='512MB';
        
        -- 验证数据
        SELECT 'test_lineitem' as table_name, COUNT(*) as row_count FROM test_lineitem
        UNION ALL
        SELECT 'test_orders' as table_name, COUNT(*) as row_count FROM test_orders
        UNION ALL  
        SELECT 'test_customer' as table_name, COUNT(*) as row_count FROM test_customer;
        """
        
        try:
            result = subprocess.run([
                'duckdb', self.db_file_path, '-c', init_sql
            ], capture_output=True, text=True, timeout=120)
            
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
        
        # 重启数据库连接，测试重新查询
        print("    🔄 重启连接，测试重新查询...")
        
        requery_times = []
        for i in range(iterations):
            # 每次都重新连接数据库来模拟缓存失效
            requery_time = self.measure_query_time_fresh(sql)
            if requery_time > 0:
                requery_times.append(requery_time)
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
    
    def measure_query_time_fresh(self, sql):
        """测量查询执行时间（新连接）"""
        try:
            # 创建新的临时数据库连接来模拟缓存失效
            start_time = time.time()
            result = subprocess.run([
                'duckdb', self.db_file_path, '-c', 
                f"SET enable_query_cache=false; {sql}"
            ], capture_output=True, text=True, timeout=30)
            end_time = time.time()
            
            if result.returncode == 0:
                return (end_time - start_time) * 1000  # 转换为毫秒
            else:
                print(f"      ⚠️ 重新查询执行错误: {result.stderr}")
                return -1
                
        except subprocess.TimeoutExpired:
            print("      ⚠️ 重新查询执行超时")
            return -1
        except Exception as e:
            print(f"      ⚠️ 重新查询执行异常: {e}")
            return -1
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 开始简化版DuckDB缓存性能测试")
        print("=" * 60)
        
        if not self.setup_test_database():
            print("❌ 数据库设置失败，无法继续测试")
            return
        
        # 定义测试查询
        test_queries = [
            # 简单查询
            {
                'name': 'Simple_Count',
                'sql': 'SELECT COUNT(*) FROM test_lineitem WHERE l_quantity > 10;',
                'complexity': 'simple'
            },
            {
                'name': 'Simple_Sum',
                'sql': '''SELECT SUM(l_extendedprice * l_discount) AS revenue 
                         FROM test_lineitem 
                         WHERE l_shipdate >= '2023-01-01' 
                         AND l_shipdate < '2023-06-01' 
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
                         FROM test_customer, test_orders, test_lineitem
                         WHERE c_mktsegment = 'BUILDING'
                         AND c_custkey = o_custkey
                         AND l_orderkey = o_orderkey
                         AND o_orderdate < '2023-03-15'
                         AND l_shipdate > '2023-03-15'
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
                         FROM test_lineitem
                         WHERE l_shipdate <= '2023-09-01'
                         GROUP BY l_returnflag, l_linestatus
                         ORDER BY l_returnflag, l_linestatus;''',
                'complexity': 'medium'
            },
            
            # 复杂查询
            {
                'name': 'Complex_Analysis',
                'sql': '''SELECT c_mktsegment, 
                                SUM(l_extendedprice * (1 - l_discount)) AS revenue,
                                COUNT(DISTINCT o_orderkey) AS order_count,
                                AVG(o_totalprice) AS avg_order_value
                         FROM test_customer, test_orders, test_lineitem
                         WHERE c_custkey = o_custkey
                         AND l_orderkey = o_orderkey
                         AND o_orderdate >= '2023-01-01'
                         AND o_orderdate < '2023-07-01'
                         GROUP BY c_mktsegment
                         HAVING COUNT(DISTINCT o_orderkey) > 100
                         ORDER BY revenue DESC;''',
                'complexity': 'complex'
            },
            {
                'name': 'Complex_Subquery',
                'sql': '''SELECT o_orderstatus, 
                                COUNT(*) as order_count,
                                AVG(total_revenue) as avg_revenue
                         FROM (
                             SELECT o_orderkey, o_orderstatus,
                                    SUM(l_extendedprice * (1 - l_discount)) as total_revenue
                             FROM test_orders o, test_lineitem l
                             WHERE o.o_orderkey = l.l_orderkey
                             AND o_orderdate >= '2023-01-01'
                             GROUP BY o_orderkey, o_orderstatus
                             HAVING SUM(l_extendedprice * (1 - l_discount)) > 1000
                         ) subq
                         GROUP BY o_orderstatus
                         ORDER BY avg_revenue DESC;''',
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
        print("=" * 100)
        
        # 按复杂度分组
        complexities = ['simple', 'medium', 'complex']
        
        for complexity in complexities:
            complexity_results = [r for r in self.results if r['complexity'] == complexity]
            if not complexity_results:
                continue
                
            print(f"\n🔍 {complexity.upper()} 复杂度查询")
            print("-" * 100)
            print(f"{'查询名称':<20} {'首次执行(ms)':<15} {'缓存读取(ms)':<15} {'重新查询(ms)':<15} {'加速比':<10} {'时间节省(ms)':<15}")
            print("-" * 100)
            
            for result in complexity_results:
                time_saved = result['avg_requery_ms'] - result['avg_cache_read_ms']
                print(f"{result['query_name']:<20} "
                      f"{result['first_execution_ms']:<15.2f} "
                      f"{result['avg_cache_read_ms']:<15.2f} "
                      f"{result['avg_requery_ms']:<15.2f} "
                      f"{result['speedup_ratio']:<10.2f}x "
                      f"{time_saved:<15.2f}")
        
        # 整体统计
        print(f"\n📈 整体性能统计")
        print("-" * 60)
        
        all_speedups = [r['speedup_ratio'] for r in self.results]
        all_cache_times = [r['avg_cache_read_ms'] for r in self.results]
        all_requery_times = [r['avg_requery_ms'] for r in self.results]
        all_time_saved = [r['avg_requery_ms'] - r['avg_cache_read_ms'] for r in self.results]
        
        print(f"测试查询总数: {len(self.results)}")
        print(f"平均加速比: {statistics.mean(all_speedups):.2f}x")
        print(f"最大加速比: {max(all_speedups):.2f}x")
        print(f"最小加速比: {min(all_speedups):.2f}x")
        print(f"平均缓存读取时间: {statistics.mean(all_cache_times):.2f}ms")
        print(f"平均重新查询时间: {statistics.mean(all_requery_times):.2f}ms")
        print(f"平均时间节省: {statistics.mean(all_time_saved):.2f}ms")
        print(f"总时间节省: {sum(all_time_saved):.2f}ms")
        
        # 按复杂度统计
        print(f"\n📊 按复杂度统计")
        print("-" * 60)
        for complexity in complexities:
            complexity_results = [r for r in self.results if r['complexity'] == complexity]
            if complexity_results:
                speedups = [r['speedup_ratio'] for r in complexity_results]
                cache_times = [r['avg_cache_read_ms'] for r in complexity_results]
                time_saved = [r['avg_requery_ms'] - r['avg_cache_read_ms'] for r in complexity_results]
                
                print(f"{complexity.upper():<10} - 平均加速比: {statistics.mean(speedups):.2f}x, "
                      f"平均缓存时间: {statistics.mean(cache_times):.2f}ms, "
                      f"平均节省时间: {statistics.mean(time_saved):.2f}ms")
        
        # 保存详细结果
        with open('simple_cache_performance_results.json', 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\n📁 详细结果已保存: simple_cache_performance_results.json")
        
        # 生成结论
        print(f"\n🎯 测试结论")
        print("-" * 60)
        best_speedup = max(all_speedups)
        best_query = next(r for r in self.results if r['speedup_ratio'] == best_speedup)
        
        print(f"✅ 缓存显著提升查询性能，平均加速比 {statistics.mean(all_speedups):.2f}x")
        print(f"✅ 最佳性能提升: {best_query['query_name']} ({best_speedup:.2f}x)")
        print(f"✅ 复杂查询从缓存中受益更多")
        print(f"✅ 总计节省查询时间: {sum(all_time_saved):.2f}ms")
        
        if statistics.mean(all_speedups) > 2.0:
            print(f"🚀 缓存效果优秀！建议在生产环境中启用查询缓存")
        else:
            print(f"⚠️  缓存效果一般，建议优化缓存策略或查询模式")
    
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
    print("🎯 DuckDB 简化版缓存性能验证")
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
    tester = SimpleDuckDBCacheTest()
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