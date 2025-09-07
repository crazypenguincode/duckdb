#!/usr/bin/env python3
"""
TPCH Q05 查询缓存测试脚本 - 简化版本
直接使用SQL脚本测试缓存功能
"""

import subprocess
import time
import os
import tempfile
from datetime import datetime

class SimpleCacheTester:
    """简化的缓存测试器"""
    
    def __init__(self, duckdb_path: str = "./build/release/duckdb"):
        """初始化测试器"""
        self.duckdb_path = duckdb_path
        self.db_file = tempfile.mktemp(suffix='.duckdb')
    
    def create_test_sql_file(self) -> str:
        """创建测试SQL文件"""
        sql_content = """
-- TPCH Q05 查询缓存测试
-- 创建测试数据
DROP TABLE IF EXISTS region;
DROP TABLE IF EXISTS nation;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS lineitem;

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
(3, 'Supplier#000000003', '789 Pine Rd', 9, '62-555-123-4567', 1500.00, 'Fast supplier'),
(4, 'Supplier#000000004', '321 Elm St', 11, '81-333-444-5555', 1800.00, 'Quality supplier'),
(5, 'Supplier#000000005', '654 Maple Ave', 21, '84-666-777-8888', 2200.00, 'Premium supplier');

INSERT INTO customer VALUES 
(1, 'Customer#000000001', '111 First St', 2, '86-111-222-3333', 5000.00, 'BUILDING', 'Good customer'),
(2, 'Customer#000000002', '222 Second St', 8, '91-444-555-6666', 3000.00, 'AUTOMOBILE', 'Regular customer'),
(3, 'Customer#000000003', '333 Third St', 9, '62-777-888-9999', 4000.00, 'MACHINERY', 'VIP customer'),
(4, 'Customer#000000004', '444 Fourth St', 11, '81-999-000-1111', 6000.00, 'FURNITURE', 'Premium customer'),
(5, 'Customer#000000005', '555 Fifth St', 21, '84-222-333-4444', 3500.00, 'HOUSEHOLD', 'Loyal customer');

INSERT INTO orders VALUES 
(1, 1, 'O', 15000.00, '1994-06-15', '1-URGENT', 'Clerk#000000001', 0, 'Order 1'),
(2, 2, 'O', 25000.00, '1994-08-20', '2-HIGH', 'Clerk#000000002', 0, 'Order 2'),
(3, 3, 'O', 35000.00, '1994-10-10', '3-MEDIUM', 'Clerk#000000003', 0, 'Order 3'),
(4, 1, 'O', 12000.00, '1994-12-05', '1-URGENT', 'Clerk#000000001', 0, 'Order 4'),
(5, 4, 'O', 18000.00, '1994-09-25', '2-HIGH', 'Clerk#000000004', 0, 'Order 5'),
(6, 5, 'O', 22000.00, '1994-11-30', '3-MEDIUM', 'Clerk#000000005', 0, 'Order 6');

INSERT INTO lineitem VALUES 
(1, 1, 1, 1, 10.00, 1000.00, 0.05, 0.08, 'N', 'O', '1994-07-01', '1994-06-30', '1994-07-05', 'DELIVER IN PERSON', 'TRUCK', 'Line 1'),
(1, 2, 2, 2, 20.00, 2000.00, 0.10, 0.08, 'N', 'O', '1994-07-15', '1994-07-10', '1994-07-20', 'TAKE BACK RETURN', 'MAIL', 'Line 2'),
(2, 3, 3, 1, 15.00, 1500.00, 0.08, 0.08, 'N', 'O', '1994-09-01', '1994-08-30', '1994-09-05', 'DELIVER IN PERSON', 'SHIP', 'Line 3'),
(2, 1, 1, 2, 25.00, 2500.00, 0.12, 0.08, 'N', 'O', '1994-09-15', '1994-09-10', '1994-09-20', 'NONE', 'AIR', 'Line 4'),
(3, 2, 2, 1, 30.00, 3000.00, 0.15, 0.08, 'N', 'O', '1994-11-01', '1994-10-30', '1994-11-05', 'COLLECT COD', 'RAIL', 'Line 5'),
(4, 3, 3, 1, 12.00, 1200.00, 0.06, 0.08, 'N', 'O', '1994-12-20', '1994-12-15', '1994-12-25', 'DELIVER IN PERSON', 'TRUCK', 'Line 6'),
(5, 4, 4, 1, 18.00, 1800.00, 0.07, 0.08, 'N', 'O', '1994-10-05', '1994-09-30', '1994-10-10', 'NONE', 'SHIP', 'Line 7'),
(5, 5, 5, 2, 22.00, 2200.00, 0.09, 0.08, 'N', 'O', '1994-10-20', '1994-10-15', '1994-10-25', 'COLLECT COD', 'TRUCK', 'Line 8'),
(6, 1, 1, 1, 16.00, 1600.00, 0.11, 0.08, 'N', 'O', '1994-12-10', '1994-12-05', '1994-12-15', 'DELIVER IN PERSON', 'RAIL', 'Line 9'),
(6, 2, 2, 2, 24.00, 2400.00, 0.13, 0.08, 'N', 'O', '1994-12-25', '1994-12-20', '1994-12-30', 'TAKE BACK RETURN', 'AIR', 'Line 10');

-- 启用查询缓存
PRAGMA enable_query_cache;
PRAGMA clear_query_cache;

.print "🎯 TPCH Q05 查询缓存测试开始"
.print "=================================="

-- 显示初始缓存状态
.print "📊 初始缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试1: 原始Q05查询 - 第一次执行"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试2: 原始Q05查询 - 第二次执行（应该命中缓存）"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试3: CTE版本Q05查询 - 第一次执行"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试4: CTE版本Q05查询 - 第二次执行（应该命中缓存）"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试5: 嵌套CTE版本Q05查询 - 第一次执行"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试6: 嵌套CTE版本Q05查询 - 第二次执行（应该命中缓存）"
.timer on

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

.timer off
.print "📊 执行后缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🔍 测试7: 原始Q05查询 - 第三次执行（验证缓存持久性）"
.timer on

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

.timer off
.print "📊 最终缓存状态:"
SELECT * FROM pragma_query_cache_stats();

.print ""
.print "🎉 TPCH Q05 查询缓存测试完成！"
        """
        
        # 创建临时SQL文件
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(sql_content)
            return f.name
    
    def run_test(self):
        """运行测试"""
        print("🎯 TPCH Q05 查询缓存测试")
        print("测试原始SQL查询缓存和CTE子语句缓存功能")
        print("=" * 60)
        print()
        
        # 检查DuckDB可执行文件
        if not os.path.exists(self.duckdb_path):
            print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
            print("请确保已编译DuckDB或指定正确的路径")
            return
        
        # 创建测试SQL文件
        sql_file = self.create_test_sql_file()
        
        try:
            print(f"📝 使用DuckDB执行测试: {self.duckdb_path}")
            print(f"📁 数据库文件: {self.db_file}")
            print(f"📄 SQL脚本: {sql_file}")
            print()
            
            # 执行测试
            start_time = time.time()
            result = subprocess.run(
                [self.duckdb_path, self.db_file, f".read {sql_file}"],
                capture_output=True,
                text=True,
                timeout=120
            )
            end_time = time.time()
            
            print(f"⏱️  总执行时间: {end_time - start_time:.4f}s")
            print()
            
            if result.stdout:
                print("📋 测试输出:")
                print("-" * 60)
                print(result.stdout)
            
            if result.stderr:
                print("⚠️ 错误信息:")
                print("-" * 60)
                print(result.stderr)
            
            # 生成简单的报告
            self.generate_simple_report(result.stdout, end_time - start_time)
            
        except subprocess.TimeoutExpired:
            print("❌ 测试超时")
        except Exception as e:
            print(f"❌ 测试执行失败: {e}")
        finally:
            # 清理临时文件
            try:
                os.unlink(sql_file)
                if os.path.exists(self.db_file):
                    os.unlink(self.db_file)
            except:
                pass
    
    def generate_simple_report(self, output: str, total_time: float):
        """生成简单报告"""
        print()
        print("📊 测试总结报告")
        print("=" * 60)
        
        # 分析输出中的缓存统计信息
        cache_stats = []
        lines = output.split('\n')
        
        for i, line in enumerate(lines):
            if 'pragma_query_cache_stats' in line:
                # 查找下一行的统计数据
                for j in range(i+1, min(i+5, len(lines))):
                    if '|' in lines[j] and 'total_entries' not in lines[j]:
                        parts = [p.strip() for p in lines[j].split('|')]
                        if len(parts) >= 5:
                            try:
                                stats = {
                                    'total_entries': int(parts[0]),
                                    'total_hits': int(parts[1]),
                                    'total_misses': int(parts[2]),
                                    'hit_rate': float(parts[3]),
                                    'memory_usage': int(parts[4])
                                }
                                cache_stats.append(stats)
                                break
                            except ValueError:
                                pass
        
        if cache_stats:
            initial_stats = cache_stats[0] if cache_stats else {}
            final_stats = cache_stats[-1] if cache_stats else {}
            
            print(f"🎯 缓存性能分析:")
            print(f"   初始缓存条目: {initial_stats.get('total_entries', 0)}")
            print(f"   最终缓存条目: {final_stats.get('total_entries', 0)}")
            print(f"   总缓存命中: {final_stats.get('total_hits', 0)}")
            print(f"   总缓存未命中: {final_stats.get('total_misses', 0)}")
            print(f"   最终命中率: {final_stats.get('hit_rate', 0):.2%}")
            print(f"   内存使用: {final_stats.get('memory_usage', 0):,} 字节")
            print()
            
            # 分析缓存效果
            total_hits = final_stats.get('total_hits', 0)
            total_tests = 7  # 我们有7个测试
            
            if total_hits > 0:
                print(f"✅ 缓存功能正常工作!")
                print(f"   在{total_tests}个测试中有{total_hits}次缓存命中")
                print(f"   缓存命中率: {total_hits/total_tests*100:.1f}%")
            else:
                print(f"⚠️ 缓存未命中，可能的原因:")
                print(f"   - 查询结果为空，不被缓存")
                print(f"   - 缓存策略需要调整")
                print(f"   - 查询被识别为不可缓存")
        
        print(f"⏱️  总测试时间: {total_time:.4f}s")
        
        # 保存详细输出到文件
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"tpch_q05_cache_test_{timestamp}.txt"
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(f"TPCH Q05 查询缓存测试报告\n")
            f.write(f"测试时间: {datetime.now().isoformat()}\n")
            f.write(f"总执行时间: {total_time:.4f}s\n")
            f.write("=" * 60 + "\n\n")
            f.write("详细输出:\n")
            f.write(output)
        
        print(f"💾 详细报告已保存到: {report_file}")

def main():
    """主函数"""
    tester = SimpleCacheTester()
    tester.run_test()

if __name__ == "__main__":
    main()