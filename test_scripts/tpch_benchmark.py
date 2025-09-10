#!/usr/bin/env python3
"""
TPC-H基准测试脚本
用于生成TPC-H测试数据并执行基准查询
"""

import os
import time
import sqlite3
import random
import json
import subprocess
from datetime import datetime, timedelta
from typing import List, Dict, Any

class TPCHBenchmark:
    """TPC-H基准测试类"""
    
    def __init__(self, scale_factor: int = 1):
        self.scale_factor = scale_factor
        self.db_path = f"/tmp/tpch_sf{scale_factor}.db"
        self.results = {}
        
    def generate_test_data(self):
        """生成TPC-H测试数据"""
        print(f"生成TPC-H Scale Factor {self.scale_factor} 测试数据...")
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # 创建TPC-H表结构
        self.create_tpch_schema(cursor)
        
        # 生成数据
        self.generate_nation_data(cursor)
        self.generate_region_data(cursor)
        self.generate_supplier_data(cursor)
        self.generate_customer_data(cursor)
        self.generate_part_data(cursor)
        self.generate_partsupp_data(cursor)
        self.generate_orders_data(cursor)
        self.generate_lineitem_data(cursor)
        
        conn.commit()
        conn.close()
        
        print("TPC-H测试数据生成完成")
    
    def create_tpch_schema(self, cursor):
        """创建TPC-H表结构"""
        
        # NATION表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS nation (
                n_nationkey INTEGER PRIMARY KEY,
                n_name TEXT NOT NULL,
                n_regionkey INTEGER NOT NULL,
                n_comment TEXT
            )
        """)
        
        # REGION表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS region (
                r_regionkey INTEGER PRIMARY KEY,
                r_name TEXT NOT NULL,
                r_comment TEXT
            )
        """)
        
        # SUPPLIER表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS supplier (
                s_suppkey INTEGER PRIMARY KEY,
                s_name TEXT NOT NULL,
                s_address TEXT,
                s_nationkey INTEGER NOT NULL,
                s_phone TEXT,
                s_acctbal REAL,
                s_comment TEXT
            )
        """)
        
        # CUSTOMER表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS customer (
                c_custkey INTEGER PRIMARY KEY,
                c_name TEXT NOT NULL,
                c_address TEXT,
                c_nationkey INTEGER NOT NULL,
                c_phone TEXT,
                c_acctbal REAL,
                c_mktsegment TEXT,
                c_comment TEXT
            )
        """)
        
        # PART表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS part (
                p_partkey INTEGER PRIMARY KEY,
                p_name TEXT NOT NULL,
                p_mfgr TEXT,
                p_brand TEXT,
                p_type TEXT,
                p_size INTEGER,
                p_container TEXT,
                p_retailprice REAL,
                p_comment TEXT
            )
        """)
        
        # PARTSUPP表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS partsupp (
                ps_partkey INTEGER,
                ps_suppkey INTEGER,
                ps_availqty INTEGER,
                ps_supplycost REAL,
                ps_comment TEXT,
                PRIMARY KEY (ps_partkey, ps_suppkey)
            )
        """)
        
        # ORDERS表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                o_orderkey INTEGER PRIMARY KEY,
                o_custkey INTEGER NOT NULL,
                o_orderstatus TEXT,
                o_totalprice REAL,
                o_orderdate TEXT,
                o_orderpriority TEXT,
                o_clerk TEXT,
                o_shippriority INTEGER,
                o_comment TEXT
            )
        """)
        
        # LINEITEM表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS lineitem (
                l_orderkey INTEGER,
                l_partkey INTEGER,
                l_suppkey INTEGER,
                l_linenumber INTEGER,
                l_quantity REAL,
                l_extendedprice REAL,
                l_discount REAL,
                l_tax REAL,
                l_returnflag TEXT,
                l_linestatus TEXT,
                l_shipdate TEXT,
                l_commitdate TEXT,
                l_receiptdate TEXT,
                l_shipinstruct TEXT,
                l_shipmode TEXT,
                l_comment TEXT,
                PRIMARY KEY (l_orderkey, l_linenumber)
            )
        """)
    
    def generate_nation_data(self, cursor):
        """生成NATION表数据"""
        nations = [
            (0, 'ALGERIA', 0, 'haggle. carefully final deposits detect slyly agai'),
            (1, 'ARGENTINA', 1, 'al foxes promise slyly according to the regular accounts. bold requests alon'),
            (2, 'BRAZIL', 1, 'y alongside of the pending deposits. carefully special packages are about the ironic forges. slyly special'),
            (3, 'CANADA', 1, 'eas hang ironic, silent packages. slyly regular packages are furiously over the tithes. fluffily bold'),
            (4, 'EGYPT', 4, 'y above the carefully unusual theodolites. final dugouts are quickly across the furiously regular d'),
            (5, 'ETHIOPIA', 0, 'ven packages wake quickly. regu'),
            (6, 'FRANCE', 3, 'refully final requests. regular, ironi'),
            (7, 'GERMANY', 3, 'l platelets. regular accounts x-ray: unusual, regular acco'),
            (8, 'INDIA', 2, 'ss excuses cajole slyly across the packages. deposits print aroun'),
            (9, 'INDONESIA', 2, 'slyly express asymptotes. regular deposits haggle slyly. carefully ironic hockey players sleep blithely. carefull'),
            (10, 'IRAN', 4, 'efully alongside of the slyly final dependencies.'),
            (11, 'IRAQ', 4, 'nic deposits boost atop the quickly final requests. quickly regula'),
            (12, 'JAPAN', 2, 'ously. final, express gifts cajole a'),
            (13, 'JORDAN', 4, 'ic deposits are blithely about the carefully regular pa'),
            (14, 'KENYA', 0, 'pending excuses haggle furiously deposits. pending, express pinto beans wake fluffily past t'),
            (15, 'MOROCCO', 0, 'rns. blithely bold courts among the closely regular packages use furiously bold platelets?'),
            (16, 'MOZAMBIQUE', 0, 's. ironic, unusual asymptotes wake blithely r'),
            (17, 'PERU', 1, 'platelets. blithely pending dependencies use fluffily across the even pinto beans. carefully silent accoun'),
            (18, 'CHINA', 2, 'c dependencies. furiously express notornis sleep slyly regular accounts. ideas sleep. depos'),
            (19, 'ROMANIA', 3, 'ular asymptotes are about the furious multipliers. express dependencies nag above the ironically ironic account'),
            (20, 'SAUDI ARABIA', 4, 'ts. silent requests haggle. closely express packages sleep across the blithely'),
            (21, 'VIETNAM', 2, 'hely iro'),
            (22, 'RUSSIA', 3, 'requests against the platelets use never according to the quickly regular pint'),
            (23, 'UNITED KINGDOM', 3, 'eans boost carefully special requests. accounts are. carefull'),
            (24, 'UNITED STATES', 1, 'y final packages. slow foxes cajole quickly. quickly silent platelets breach ironic accounts. unusual pinto be')
        ]
        
        cursor.executemany(
            "INSERT OR REPLACE INTO nation VALUES (?, ?, ?, ?)",
            nations
        )
    
    def generate_region_data(self, cursor):
        """生成REGION表数据"""
        regions = [
            (0, 'AFRICA', 'lar deposits. blithely final packages cajole. regular waters are final requests. regular accounts are according to'),
            (1, 'AMERICA', 'hs use ironic, even requests. s'),
            (2, 'ASIA', 'ges. thinly even pinto beans ca'),
            (3, 'EUROPE', 'ly final courts cajole furiously final excuse'),
            (4, 'MIDDLE EAST', 'uickly special accounts cajole carefully blithely close requests. carefully final asymptotes haggle furiousl')
        ]
        
        cursor.executemany(
            "INSERT OR REPLACE INTO region VALUES (?, ?, ?)",
            regions
        )
    
    def generate_supplier_data(self, cursor):
        """生成SUPPLIER表数据"""
        suppliers = []
        num_suppliers = 10000 * self.scale_factor
        
        for i in range(num_suppliers):
            suppliers.append((
                i + 1,
                f"Supplier#{i+1:09d}",
                f"Address {i+1}",
                random.randint(0, 24),  # nationkey
                f"{random.randint(10, 99)}-{random.randint(100, 999)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}",
                round(random.uniform(-999.99, 9999.99), 2),
                f"Comment for supplier {i+1}"
            ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO supplier VALUES (?, ?, ?, ?, ?, ?, ?)",
            suppliers
        )
    
    def generate_customer_data(self, cursor):
        """生成CUSTOMER表数据"""
        customers = []
        num_customers = 150000 * self.scale_factor
        segments = ['AUTOMOBILE', 'BUILDING', 'FURNITURE', 'MACHINERY', 'HOUSEHOLD']
        
        for i in range(num_customers):
            customers.append((
                i + 1,
                f"Customer#{i+1:09d}",
                f"Address {i+1}",
                random.randint(0, 24),  # nationkey
                f"{random.randint(10, 99)}-{random.randint(100, 999)}-{random.randint(100, 999)}-{random.randint(1000, 9999)}",
                round(random.uniform(-999.99, 9999.99), 2),
                random.choice(segments),
                f"Comment for customer {i+1}"
            ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO customer VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            customers
        )
    
    def generate_part_data(self, cursor):
        """生成PART表数据"""
        parts = []
        num_parts = 200000 * self.scale_factor
        
        brands = [f"Brand#{i}" for i in range(1, 6)]
        types = ['STANDARD', 'SMALL', 'MEDIUM', 'LARGE', 'ECONOMY', 'PROMO']
        containers = ['SM CASE', 'SM BOX', 'SM PACK', 'SM PKG', 'MED BAG', 'MED BOX', 'MED PKG', 'MED PACK', 'LG CASE', 'LG BOX', 'LG PACK', 'LG PKG', 'JUMBO CASE', 'JUMBO BOX', 'JUMBO BAG', 'JUMBO PACK', 'JUMBO PKG', 'WRAP CASE', 'WRAP BOX', 'WRAP BAG', 'WRAP PACK', 'WRAP PKG']
        
        for i in range(num_parts):
            parts.append((
                i + 1,
                f"Part {i+1}",
                f"Manufacturer#{random.randint(1, 5)}",
                random.choice(brands),
                f"{random.choice(types)} {random.choice(['ANODIZED', 'BURNISHED', 'PLATED', 'POLISHED', 'BRUSHED'])} {random.choice(['TIN', 'NICKEL', 'BRASS', 'STEEL', 'COPPER'])}",
                random.randint(1, 50),
                random.choice(containers),
                round(random.uniform(900.00, 2000.00), 2),
                f"Comment for part {i+1}"
            ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO part VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            parts
        )
    
    def generate_partsupp_data(self, cursor):
        """生成PARTSUPP表数据"""
        partsupps = []
        num_parts = 200000 * self.scale_factor
        num_suppliers = 10000 * self.scale_factor
        
        # 每个part有4个supplier
        for part_id in range(1, num_parts + 1):
            suppliers = random.sample(range(1, num_suppliers + 1), min(4, num_suppliers))
            for supp_id in suppliers:
                partsupps.append((
                    part_id,
                    supp_id,
                    random.randint(1, 9999),
                    round(random.uniform(1.00, 1000.00), 2),
                    f"Comment for partsupp {part_id}-{supp_id}"
                ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO partsupp VALUES (?, ?, ?, ?, ?)",
            partsupps
        )
    
    def generate_orders_data(self, cursor):
        """生成ORDERS表数据"""
        orders = []
        num_orders = 1500000 * self.scale_factor
        num_customers = 150000 * self.scale_factor
        
        statuses = ['O', 'F', 'P']
        priorities = ['1-URGENT', '2-HIGH', '3-MEDIUM', '4-NOT SPECIFIED', '5-LOW']
        
        base_date = datetime(1992, 1, 1)
        
        for i in range(num_orders):
            order_date = base_date + timedelta(days=random.randint(0, 2557))  # 7年范围
            
            orders.append((
                i + 1,
                random.randint(1, num_customers),
                random.choice(statuses),
                round(random.uniform(1000.00, 500000.00), 2),
                order_date.strftime('%Y-%m-%d'),
                random.choice(priorities),
                f"Clerk#{random.randint(1, 1000):09d}",
                random.randint(0, 1),
                f"Comment for order {i+1}"
            ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO orders VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            orders
        )
    
    def generate_lineitem_data(self, cursor):
        """生成LINEITEM表数据"""
        lineitems = []
        num_orders = 1500000 * self.scale_factor
        num_parts = 200000 * self.scale_factor
        num_suppliers = 10000 * self.scale_factor
        
        return_flags = ['R', 'A', 'N']
        line_statuses = ['O', 'F']
        ship_instructions = ['DELIVER IN PERSON', 'COLLECT COD', 'NONE', 'TAKE BACK RETURN']
        ship_modes = ['REG AIR', 'AIR', 'RAIL', 'SHIP', 'TRUCK', 'MAIL', 'FOB']
        
        base_date = datetime(1992, 1, 1)
        
        for order_id in range(1, min(num_orders + 1, 100000)):  # 限制数量以节省时间
            num_lines = random.randint(1, 7)
            
            for line_num in range(1, num_lines + 1):
                ship_date = base_date + timedelta(days=random.randint(1, 2557))
                commit_date = ship_date + timedelta(days=random.randint(-30, 30))
                receipt_date = ship_date + timedelta(days=random.randint(1, 30))
                
                quantity = random.randint(1, 50)
                price = round(random.uniform(900.00, 2000.00), 2)
                discount = round(random.uniform(0.00, 0.10), 2)
                tax = round(random.uniform(0.00, 0.08), 2)
                
                lineitems.append((
                    order_id,
                    random.randint(1, num_parts),
                    random.randint(1, num_suppliers),
                    line_num,
                    quantity,
                    round(price * quantity, 2),
                    discount,
                    tax,
                    random.choice(return_flags),
                    random.choice(line_statuses),
                    ship_date.strftime('%Y-%m-%d'),
                    commit_date.strftime('%Y-%m-%d'),
                    receipt_date.strftime('%Y-%m-%d'),
                    random.choice(ship_instructions),
                    random.choice(ship_modes),
                    f"Comment for lineitem {order_id}-{line_num}"
                ))
        
        cursor.executemany(
            "INSERT OR REPLACE INTO lineitem VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            lineitems
        )
    
    def get_tpch_queries(self) -> Dict[str, str]:
        """获取TPC-H查询"""
        return {
            "Q1": """
                SELECT
                    l_returnflag,
                    l_linestatus,
                    SUM(l_quantity) as sum_qty,
                    SUM(l_extendedprice) as sum_base_price,
                    SUM(l_extendedprice * (1 - l_discount)) as sum_disc_price,
                    SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge,
                    AVG(l_quantity) as avg_qty,
                    AVG(l_extendedprice) as avg_price,
                    AVG(l_discount) as avg_disc,
                    COUNT(*) as count_order
                FROM lineitem
                WHERE l_shipdate <= '1998-09-01'
                GROUP BY l_returnflag, l_linestatus
                ORDER BY l_returnflag, l_linestatus
            """,
            
            "Q3": """
                SELECT
                    l_orderkey,
                    SUM(l_extendedprice * (1 - l_discount)) as revenue,
                    o_orderdate,
                    o_shippriority
                FROM customer, orders, lineitem
                WHERE c_mktsegment = 'BUILDING'
                    AND c_custkey = o_custkey
                    AND l_orderkey = o_orderkey
                    AND o_orderdate < '1995-03-15'
                    AND l_shipdate > '1995-03-15'
                GROUP BY l_orderkey, o_orderdate, o_shippriority
                ORDER BY revenue DESC, o_orderdate
                LIMIT 10
            """,
            
            "Q6": """
                SELECT
                    SUM(l_extendedprice * l_discount) as revenue
                FROM lineitem
                WHERE l_shipdate >= '1994-01-01'
                    AND l_shipdate < '1995-01-01'
                    AND l_discount BETWEEN 0.05 AND 0.07
                    AND l_quantity < 24
            """,
            
            "Q10": """
                SELECT
                    c_custkey,
                    c_name,
                    SUM(l_extendedprice * (1 - l_discount)) as revenue,
                    c_acctbal,
                    n_name,
                    c_address,
                    c_phone,
                    c_comment
                FROM customer, orders, lineitem, nation
                WHERE c_custkey = o_custkey
                    AND l_orderkey = o_orderkey
                    AND o_orderdate >= '1993-10-01'
                    AND o_orderdate < '1994-01-01'
                    AND l_returnflag = 'R'
                    AND c_nationkey = n_nationkey
                GROUP BY c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment
                ORDER BY revenue DESC
                LIMIT 20
            """,
            
            "Q14": """
                SELECT
                    100.00 * SUM(CASE WHEN p_type LIKE 'PROMO%' 
                                 THEN l_extendedprice * (1 - l_discount)
                                 ELSE 0 END) / SUM(l_extendedprice * (1 - l_discount)) as promo_revenue
                FROM lineitem, part
                WHERE l_partkey = p_partkey
                    AND l_shipdate >= '1995-09-01'
                    AND l_shipdate < '1995-10-01'
            """
        }
    
    def run_benchmark(self) -> Dict[str, Any]:
        """运行TPC-H基准测试"""
        print("开始TPC-H基准测试...")
        
        # 检查数据是否存在
        if not os.path.exists(self.db_path):
            self.generate_test_data()
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        queries = self.get_tpch_queries()
        results = {}
        
        for query_name, query_sql in queries.items():
            print(f"执行查询 {query_name}...")
            
            # 执行查询多次取平均值
            times = []
            for run in range(3):
                start_time = time.time()
                
                try:
                    cursor.execute(query_sql)
                    result = cursor.fetchall()
                    
                    end_time = time.time()
                    execution_time = end_time - start_time
                    times.append(execution_time)
                    
                    if run == 0:  # 只记录第一次的结果
                        results[query_name] = {
                            'execution_time_s': execution_time,
                            'result_count': len(result),
                            'result_sample': result[:5] if result else []
                        }
                
                except Exception as e:
                    print(f"查询 {query_name} 执行失败: {e}")
                    results[query_name] = {
                        'execution_time_s': 0,
                        'result_count': 0,
                        'error': str(e)
                    }
                    break
            
            if times:
                results[query_name]['avg_execution_time_s'] = sum(times) / len(times)
                results[query_name]['min_execution_time_s'] = min(times)
                results[query_name]['max_execution_time_s'] = max(times)
        
        conn.close()
        
        return results
    
    def generate_report(self, results: Dict[str, Any]):
        """生成测试报告"""
        report_path = f"/tmp/tpch_sf{self.scale_factor}_report.json"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        print(f"\nTPC-H基准测试报告已保存到: {report_path}")
        
        # 打印简要报告
        print(f"\n=== TPC-H Scale Factor {self.scale_factor} 基准测试报告 ===")
        
        total_time = 0
        successful_queries = 0
        
        for query_name, data in results.items():
            if 'error' not in data:
                print(f"{query_name}: {data['avg_execution_time_s']:.2f}s (结果: {data['result_count']} 行)")
                total_time += data['avg_execution_time_s']
                successful_queries += 1
            else:
                print(f"{query_name}: 执行失败 - {data['error']}")
        
        print(f"\n总执行时间: {total_time:.2f}s")
        print(f"成功查询数: {successful_queries}/{len(results)}")
        print(f"平均查询时间: {total_time/successful_queries:.2f}s" if successful_queries > 0 else "N/A")

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='TPC-H基准测试')
    parser.add_argument('--scale-factor', type=int, default=1, help='TPC-H Scale Factor (默认: 1)')
    parser.add_argument('--generate-only', action='store_true', help='只生成数据，不运行查询')
    
    args = parser.parse_args()
    
    benchmark = TPCHBenchmark(scale_factor=args.scale_factor)
    
    try:
        if args.generate_only:
            benchmark.generate_test_data()
            print("数据生成完成")
        else:
            results = benchmark.run_benchmark()
            benchmark.generate_report(results)
            
        print("TPC-H基准测试完成！")
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()
    finally:
        # 清理数据库文件（可选）
        # if os.path.exists(benchmark.db_path):
        #     os.remove(benchmark.db_path)
        pass

if __name__ == "__main__":
    main()