#!/usr/bin/env python3
"""
TPCH Q05 查询缓存测试脚本
测试原始SQL查询缓存和作为CTE子语句的缓存功能
使用DuckDB命令行工具进行测试
"""

import subprocess
import time
import json
import os
import tempfile
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from datetime import datetime

@dataclass
class CacheTestResult:
    """缓存测试结果"""
    test_name: str
    query: str
    execution_time: float
    row_count: int
    cache_hit: bool
    cache_stats: Dict[str, Any]
    error: str = None

class TpchQ05CacheTester:
    """TPCH Q05 缓存测试器"""
    
    def __init__(self, duckdb_path: str = "./build/release/duckdb"):
        """初始化测试器"""
        self.duckdb_path = duckdb_path
        self.results: List[CacheTestResult] = []
        self.db_file = tempfile.mktemp(suffix='.duckdb')
        
        # 原始TPCH Q05查询
        self.original_q05 = """
        SELECT
            n_name,
            sum(l_extendedprice * (1 - l_discount)) AS revenue
        FROM
            customer,
            orders,
            lineitem,
            supplier,
            nation,
            region
        WHERE
            c_custkey = o_custkey
            AND l_orderkey = o_orderkey
            AND l_suppkey = s_suppkey
            AND c_nationkey = s_nationkey
            AND s_nationkey = n_nationkey
            AND n_regionkey = r_regionkey
            AND r_name = 'ASIA'
            AND o_orderdate >= CAST('1994-01-01' AS date)
            AND o_orderdate < CAST('1995-01-01' AS date)
        GROUP BY
            n_name
        ORDER BY
            revenue DESC;
        """
        
        # 作为CTE子语句的查询
        self.cte_q05 = """
        WITH asia_revenue AS (
            SELECT
                n_name,
                sum(l_extendedprice * (1 - l_discount)) AS revenue
            FROM
                customer,
                orders,
                lineitem,
                supplier,
                nation,
                region
            WHERE
                c_custkey = o_custkey
                AND l_orderkey = o_orderkey
                AND l_suppkey = s_suppkey
                AND c_nationkey = s_nationkey
                AND s_nationkey = n_nationkey
                AND n_regionkey = r_regionkey
                AND r_name = 'ASIA'
                AND o_orderdate >= CAST('1994-01-01' AS date)
                AND o_orderdate < CAST('1995-01-01' AS date)
            GROUP BY
                n_name
        )
        SELECT * FROM asia_revenue ORDER BY revenue DESC;
        """
        
        # 嵌套CTE查询
        self.nested_cte_q05 = """
        WITH base_data AS (
            SELECT
                c_custkey, o_custkey, o_orderkey, o_orderdate,
                l_orderkey, l_suppkey, l_extendedprice, l_discount,
                s_suppkey, s_nationkey as s_nation,
                c_nationkey, n_nationkey, n_name, n_regionkey,
                r_regionkey, r_name
            FROM
                customer,
                orders,
                lineitem,
                supplier,
                nation,
                region
            WHERE
                c_custkey = o_custkey
                AND l_orderkey = o_orderkey
                AND l_suppkey = s_suppkey
                AND c_nationkey = s_nationkey
                AND s_nationkey = n_nationkey
                AND n_regionkey = r_regionkey
                AND r_name = 'ASIA'
                AND o_orderdate >= CAST('1994-01-01' AS date)
                AND o_orderdate < CAST('1995-01-01' AS date)
        ),
        asia_revenue AS (
            SELECT
                n_name,
                sum(l_extendedprice * (1 - l_discount)) AS revenue
            FROM base_data
            GROUP BY n_name
        )
        SELECT * FROM asia_revenue ORDER BY revenue DESC;
        """
    
    def execute_duckdb_command(self, sql: str) -> Tuple[str, str, float]:
        """执行DuckDB命令并返回结果"""
        # 创建临时SQL文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(sql)
            sql_file = f.name
        
        try:
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, self.db_file, f".read {sql_file}"],
                capture_output=True,
                text=True,
                timeout=60
            )
            end_time = time.time()
            
            execution_time = end_time - start_time
            return result.stdout, result.stderr, execution_time
            
        except subprocess.TimeoutExpired:
            return "", "Command timed out", 60.0
        except Exception as e:
            return "", str(e), 0.0
        finally:
            # 清理临时文件
            try:
                os.unlink(sql_file)
            except:
                pass
    
    def setup_tpch_data(self):
        """设置TPCH测试数据"""
        print("🔧 设置TPCH测试数据...")
        
        setup_sql = """
        -- 尝试安装并加载TPCH扩展
        INSTALL tpch;
        LOAD tpch;
        
        -- 生成小规模TPCH数据 (scale factor 0.01)
        CALL dbgen(sf=0.01);
        
        -- 显示数据统计
        SELECT 'customer' as table_name, COUNT(*) as row_count FROM customer
        UNION ALL
        SELECT 'orders', COUNT(*) FROM orders
        UNION ALL
        SELECT 'lineitem', COUNT(*) FROM lineitem
        UNION ALL
        SELECT 'supplier', COUNT(*) FROM supplier
        UNION ALL
        SELECT 'nation', COUNT(*) FROM nation
        UNION ALL
        SELECT 'region', COUNT(*) FROM region;
        """
        
        stdout, stderr, exec_time = self.execute_duckdb_command(setup_sql)
        
        if stderr and "Error" in stderr:
            print(f"⚠️ TPCH扩展不可用，设置简化测试数据...")
            self.setup_simple_test_data()
        else:
            print("✅ TPCH数据设置完成")
            if stdout:
                print("📊 数据统计:")
                for line in stdout.strip().split('\n'):
                    if '|' in line and 'table_name' not in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            table_name = parts[0].strip()
                            row_count = parts[1].strip()
                            print(f"   {table_name}: {row_count} 行")
    
    def setup_simple_test_data(self):
        """设置简化的测试数据"""
        setup_sql = """
        -- 创建简化的表结构和数据
        CREATE TABLE region (
            r_regionkey INTEGER,
            r_name VARCHAR,
            r_comment VARCHAR
        );
        
        CREATE TABLE nation (
            n_nationkey INTEGER,
            n_name VARCHAR,
            n_regionkey INTEGER,
            n_comment VARCHAR
        );
        
        CREATE TABLE supplier (
            s_suppkey INTEGER,
            s_name VARCHAR,
            s_address VARCHAR,
            s_nationkey INTEGER,
            s_phone VARCHAR,
            s_acctbal DECIMAL,
            s_comment VARCHAR
        );
        
        CREATE TABLE customer (
            c_custkey INTEGER,
            c_name VARCHAR,
            c_address VARCHAR,
            c_nationkey INTEGER,
            c_phone VARCHAR,
            c_acctbal DECIMAL,
            c_mktsegment VARCHAR,
            c_comment VARCHAR
        );
        
        CREATE TABLE orders (
            o_orderkey INTEGER,
            o_custkey INTEGER,
            o_orderstatus VARCHAR,
            o_totalprice DECIMAL,
            o_orderdate DATE,
            o_orderpriority VARCHAR,
            o_clerk VARCHAR,
            o_shippriority INTEGER,
            o_comment VARCHAR
        );
        
        CREATE TABLE lineitem (
            l_orderkey INTEGER,
            l_partkey INTEGER,
            l_suppkey INTEGER,
            l_linenumber INTEGER,
            l_quantity DECIMAL,
            l_extendedprice DECIMAL,
            l_discount DECIMAL,
            l_tax DECIMAL,
            l_returnflag VARCHAR,
            l_linestatus VARCHAR,
            l_shipdate DATE,
            l_commitdate DATE,
            l_receiptdate DATE,
            l_shipinstruct VARCHAR,
            l_shipmode VARCHAR,
            l_comment VARCHAR
        );
        
        -- 插入测试数据
        INSERT INTO region VALUES (2, 'ASIA', 'Eastern Asia');
        
        INSERT INTO nation VALUES 
        (2, 'CHINA', 2, 'Large Asian country'),
        (8, 'INDIA', 2, 'South Asian country'),
        (9, 'INDONESIA', 2, 'Southeast Asian country'),
        (11, 'JAPAN', 2, 'Island nation in Asia'),
        (21, 'VIETNAM', 2, 'Southeast Asian country');
        
        INSERT INTO supplier VALUES 
        (1, 'Supplier#000000001', '123 Main St', 2, '86-123-456-7890', 1000.00, 'Good supplier'),
        (2, 'Supplier#000000002', '456 Oak Ave', 8, '91-987-654-3210', 2000.00, 'Reliable supplier'),
        (3, 'Supplier#000000003', '789 Pine Rd', 9, '62-555-123-4567', 1500.00, 'Fast supplier');
        
        INSERT INTO customer VALUES 
        (1, 'Customer#000000001', '111 First St', 2, '86-111-222-3333', 5000.00, 'BUILDING', 'Good customer'),
        (2, 'Customer#000000002', '222 Second St', 8, '91-444-555-6666', 3000.00, 'AUTOMOBILE', 'Regular customer'),
        (3, 'Customer#000000003', '333 Third St', 9, '62-777-888-9999', 4000.00, 'MACHINERY', 'VIP customer');
        
        INSERT INTO orders VALUES 
        (1, 1, 'O', 15000.00, '1994-06-15', '1-URGENT', 'Clerk#000000001', 0, 'Order 1'),
        (2, 2, 'O', 25000.00, '1994-08-20', '2-HIGH', 'Clerk#000000002', 0, 'Order 2'),
        (3, 3, 'O', 35000.00, '1994-10-10', '3-MEDIUM', 'Clerk#000000003', 0, 'Order 3'),
        (4, 1, 'O', 12000.00, '1994-12-05', '1-URGENT', 'Clerk#000000001', 0, 'Order 4');
        
        INSERT INTO lineitem VALUES 
        (1, 1, 1, 1, 10.00, 1000.00, 0.05, 0.08, 'N', 'O', '1994-07-01', '1994-06-30', '1994-07-05', 'DELIVER IN PERSON', 'TRUCK', 'Line 1'),
        (1, 2, 2, 2, 20.00, 2000.00, 0.10, 0.08, 'N', 'O', '1994-07-15', '1994-07-10', '1994-07-20', 'TAKE BACK RETURN', 'MAIL', 'Line 2'),
        (2, 3, 3, 1, 15.00, 1500.00, 0.08, 0.08, 'N', 'O', '1994-09-01', '1994-08-30', '1994-09-05', 'DELIVER IN PERSON', 'SHIP', 'Line 3'),
        (2, 1, 1, 2, 25.00, 2500.00, 0.12, 0.08, 'N', 'O', '1994-09-15', '1994-09-10', '1994-09-20', 'NONE', 'AIR', 'Line 4'),
        (3, 2, 2, 1, 30.00, 3000.00, 0.15, 0.08, 'N', 'O', '1994-11-01', '1994-10-30', '1994-11-05', 'COLLECT COD', 'RAIL', 'Line 5'),
        (4, 3, 3, 1, 12.00, 1200.00, 0.06, 0.08, 'N', 'O', '1994-12-20', '1994-12-15', '1994-12-25', 'DELIVER IN PERSON', 'TRUCK', 'Line 6');
        
        -- 显示数据统计
        SELECT 'customer' as table_name, COUNT(*) as row_count FROM customer
        UNION ALL
        SELECT 'orders', COUNT(*) FROM orders
        UNION ALL
        SELECT 'lineitem', COUNT(*) FROM lineitem
        UNION ALL
        SELECT 'supplier', COUNT(*) FROM supplier
        UNION ALL
        SELECT 'nation', COUNT(*) FROM nation
        UNION ALL
        SELECT 'region', COUNT(*) FROM region;
        """
        
        stdout, stderr, exec_time = self.execute_duckdb_command(setup_sql)
        
        if stderr and "Error" in stderr:
            print(f"❌ 简化数据设置失败: {stderr}")
        else:
            print("✅ 简化测试数据设置完成")
            if stdout:
                print("📊 数据统计:")
                for line in stdout.strip().split('\n'):
                    if '|' in line and 'table_name' not in line:
                        parts = line.split('|')
                        if len(parts) >= 2:
                            table_name = parts[0].strip()
                            row_count = parts[1].strip()
                            print(f"   {table_name}: {row_count} 行")
    
    def get_cache_stats(self) -> Dict[str, Any]:
        """获取缓存统计信息"""
        sql = "SELECT * FROM pragma_query_cache_stats();"
        stdout, stderr, exec_time = self.execute_duckdb_command(sql)
        
        if stderr and "Error" in stderr:
            return {
                'total_entries': 0,
                'total_hits': 0,
                'total_misses': 0,
                'hit_rate': 0.0,
                'memory_usage_bytes': 0
            }
        
        # 解析输出
        lines = stdout.strip().split('\n')
        for line in lines:
            if '|' in line and 'total_entries' not in line:
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 5:
                    try:
                        return {
                            'total_entries': int(parts[0]),
                            'total_hits': int(parts[1]),
                            'total_misses': int(parts[2]),
                            'hit_rate': float(parts[3]),
                            'memory_usage_bytes': int(parts[4])
                        }
                    except ValueError:
                        pass
        
        return {
            'total_entries': 0,
            'total_hits': 0,
            'total_misses': 0,
            'hit_rate': 0.0,
            'memory_usage_bytes': 0
        }
    
    def count_result_rows(self, output: str) -> int:
        """计算结果行数"""
        if not output:
            return 0
        
        lines = output.strip().split('\n')
        # 过滤掉表头和分隔符
        data_lines = [line for line in lines if line and '|' in line and not line.startswith('┌') and not line.startswith('├') and not line.startswith('└')]
        
        # 第一行通常是表头
        if len(data_lines) > 1:
            return len(data_lines) - 1
        return 0
    
    def execute_query_with_timing(self, query: str, test_name: str) -> CacheTestResult:
        """执行查询并记录时间"""
        print(f"🔍 执行测试: {test_name}")
        
        # 获取执行前的缓存统计
        stats_before = self.get_cache_stats()
        
        # 执行查询
        stdout, stderr, execution_time = self.execute_duckdb_command(query)
        
        # 获取执行后的缓存统计
        stats_after = self.get_cache_stats()
        
        if stderr and "Error" in stderr:
            error_msg = stderr
            print(f"   ❌ 执行失败: {error_msg}")
            
            return CacheTestResult(
                test_name=test_name,
                query=query.strip(),
                execution_time=execution_time,
                row_count=0,
                cache_hit=False,
                cache_stats=stats_after,
                error=error_msg
            )
        
        row_count = self.count_result_rows(stdout)
        
        # 判断是否缓存命中
        cache_hit = stats_after['total_hits'] > stats_before['total_hits']
        
        test_result = CacheTestResult(
            test_name=test_name,
            query=query.strip(),
            execution_time=execution_time,
            row_count=row_count,
            cache_hit=cache_hit,
            cache_stats=stats_after
        )
        
        print(f"   ⏱️  执行时间: {execution_time:.4f}s")
        print(f"   📊 结果行数: {row_count}")
        print(f"   🎯 缓存命中: {'是' if cache_hit else '否'}")
        
        return test_result
    
    def run_cache_tests(self):
        """运行缓存测试"""
        print("🚀 开始TPCH Q05缓存测试")
        print("=" * 60)
        
        # 启用查询缓存并清除缓存
        init_sql = """
        PRAGMA enable_query_cache;
        PRAGMA clear_query_cache;
        """
        
        stdout, stderr, exec_time = self.execute_duckdb_command(init_sql)
        print("✅ 查询缓存已启用并清除")
        print()
        
        # 测试1: 原始Q05查询 - 第一次执行
        self.results.append(
            self.execute_query_with_timing(
                self.original_q05, 
                "原始Q05查询 - 第一次执行"
            )
        )
        print()
        
        # 测试2: 原始Q05查询 - 第二次执行（应该命中缓存）
        self.results.append(
            self.execute_query_with_timing(
                self.original_q05, 
                "原始Q05查询 - 第二次执行（缓存测试）"
            )
        )
        print()
        
        # 测试3: CTE版本Q05查询 - 第一次执行
        self.results.append(
            self.execute_query_with_timing(
                self.cte_q05, 
                "CTE版本Q05查询 - 第一次执行"
            )
        )
        print()
        
        # 测试4: CTE版本Q05查询 - 第二次执行（应该命中缓存）
        self.results.append(
            self.execute_query_with_timing(
                self.cte_q05, 
                "CTE版本Q05查询 - 第二次执行（缓存测试）"
            )
        )
        print()
        
        # 测试5: 嵌套CTE版本Q05查询 - 第一次执行
        self.results.append(
            self.execute_query_with_timing(
                self.nested_cte_q05, 
                "嵌套CTE版本Q05查询 - 第一次执行"
            )
        )
        print()
        
        # 测试6: 嵌套CTE版本Q05查询 - 第二次执行（应该命中缓存）
        self.results.append(
            self.execute_query_with_timing(
                self.nested_cte_q05, 
                "嵌套CTE版本Q05查询 - 第二次执行（缓存测试）"
            )
        )
        print()
        
        # 测试7: 再次执行原始查询（验证缓存持久性）
        self.results.append(
            self.execute_query_with_timing(
                self.original_q05, 
                "原始Q05查询 - 第三次执行（缓存持久性测试）"
            )
        )
        print()
    
    def generate_report(self):
        """生成测试报告"""
        print("📋 生成测试报告")
        print("=" * 60)
        
        # 计算统计信息
        total_tests = len(self.results)
        successful_tests = len([r for r in self.results if r.error is None])
        cache_hits = len([r for r in self.results if r.cache_hit])
        
        # 获取最终缓存统计
        final_stats = self.get_cache_stats()
        
        print(f"📊 测试总结:")
        print(f"   总测试数: {total_tests}")
        print(f"   成功测试: {successful_tests}")
        print(f"   失败测试: {total_tests - successful_tests}")
        print(f"   缓存命中: {cache_hits}")
        print(f"   缓存命中率: {cache_hits/total_tests*100:.1f}%")
        print()
        
        print(f"🎯 最终缓存统计:")
        print(f"   缓存条目数: {final_stats['total_entries']}")
        print(f"   总命中次数: {final_stats['total_hits']}")
        print(f"   总未命中次数: {final_stats['total_misses']}")
        print(f"   命中率: {final_stats['hit_rate']:.2%}")
        print(f"   内存使用: {final_stats['memory_usage_bytes']:,} 字节")
        print()
        
        print("📝 详细测试结果:")
        print("-" * 60)
        
        for i, result in enumerate(self.results, 1):
            status = "✅ 成功" if result.error is None else "❌ 失败"
            cache_status = "🎯 命中" if result.cache_hit else "❌ 未命中"
            
            print(f"{i}. {result.test_name}")
            print(f"   状态: {status}")
            if result.error:
                print(f"   错误: {result.error}")
            else:
                print(f"   执行时间: {result.execution_time:.4f}s")
                print(f"   结果行数: {result.row_count}")
                print(f"   缓存状态: {cache_status}")
            print()
        
        # 性能对比分析
        self.analyze_performance()
    
    def analyze_performance(self):
        """分析性能对比"""
        print("⚡ 性能分析:")
        print("-" * 60)
        
        # 分组分析
        original_queries = [r for r in self.results if "原始Q05查询" in r.test_name and r.error is None]
        cte_queries = [r for r in self.results if "CTE版本Q05查询" in r.test_name and r.error is None]
        nested_cte_queries = [r for r in self.results if "嵌套CTE版本Q05查询" in r.test_name and r.error is None]
        
        def analyze_group(queries: List[CacheTestResult], group_name: str):
            if not queries:
                return
            
            first_exec = queries[0]
            cache_execs = queries[1:] if len(queries) > 1 else []
            
            print(f"📈 {group_name}:")
            print(f"   首次执行时间: {first_exec.execution_time:.4f}s")
            
            if cache_execs:
                avg_cache_time = sum(r.execution_time for r in cache_execs) / len(cache_execs)
                speedup = first_exec.execution_time / avg_cache_time if avg_cache_time > 0 else float('inf')
                cache_hit_rate = sum(1 for r in cache_execs if r.cache_hit) / len(cache_execs) * 100
                
                print(f"   缓存执行平均时间: {avg_cache_time:.4f}s")
                print(f"   性能提升: {speedup:.2f}x")
                print(f"   缓存命中率: {cache_hit_rate:.1f}%")
            print()
        
        analyze_group(original_queries, "原始SQL查询")
        analyze_group(cte_queries, "CTE查询")
        analyze_group(nested_cte_queries, "嵌套CTE查询")
        
        # 整体缓存效果分析
        first_time_queries = [r for r in self.results if "第一次执行" in r.test_name and r.error is None]
        cached_queries = [r for r in self.results if ("第二次执行" in r.test_name or "第三次执行" in r.test_name) and r.error is None]
        
        if first_time_queries and cached_queries:
            avg_first_time = sum(r.execution_time for r in first_time_queries) / len(first_time_queries)
            avg_cached_time = sum(r.execution_time for r in cached_queries) / len(cached_queries)
            overall_speedup = avg_first_time / avg_cached_time if avg_cached_time > 0 else float('inf')
            
            print(f"🏆 整体缓存效果:")
            print(f"   首次执行平均时间: {avg_first_time:.4f}s")
            print(f"   缓存执行平均时间: {avg_cached_time:.4f}s")
            print(f"   整体性能提升: {overall_speedup:.2f}x")
            print()
    
    def save_report_to_file(self, filename: str = "tpch_q05_cache_test_report.json"):
        """保存报告到文件"""
        report_data = {
            'test_timestamp': datetime.now().isoformat(),
            'test_summary': {
                'total_tests': len(self.results),
                'successful_tests': len([r for r in self.results if r.error is None]),
                'cache_hits': len([r for r in self.results if r.cache_hit]),
                'final_cache_stats': self.get_cache_stats()
            },
            'test_results': [
                {
                    'test_name': r.test_name,
                    'execution_time': r.execution_time,
                    'row_count': r.row_count,
                    'cache_hit': r.cache_hit,
                    'cache_stats': r.cache_stats,
                    'error': r.error,
                    'query_preview': r.query[:200] + "..." if len(r.query) > 200 else r.query
                }
                for r in self.results
            ]
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)
        
        print(f"💾 测试报告已保存到: {filename}")
    
    def cleanup(self):
        """清理临时文件"""
        try:
            if os.path.exists(self.db_file):
                os.unlink(self.db_file)
        except:
            pass
    
    def run_full_test(self):
        """运行完整测试"""
        try:
            # 检查DuckDB可执行文件
            if not os.path.exists(self.duckdb_path):
                print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
                print("请确保已编译DuckDB或指定正确的路径")
                return
            
            # 设置数据
            self.setup_tpch_data()
            print()
            
            # 运行缓存测试
            self.run_cache_tests()
            
            # 生成报告
            self.generate_report()
            
            # 保存报告
            self.save_report_to_file()
            
        except Exception as e:
            print(f"❌ 测试过程中发生错误: {e}")
            import traceback
            traceback.print_exc()
        finally:
            # 清理资源
            self.cleanup()

def main():
    """主函数"""
    print("🎯 TPCH Q05 查询缓存测试")
    print("测试原始SQL查询缓存和CTE子语句缓存功能")
    print("=" * 60)
    print()
    
    # 创建测试器并运行测试
    tester = TpchQ05CacheTester()
    tester.run_full_test()
    
    print()
    print("🎉 测试完成！")

if __name__ == "__main__":
    main()