#!/usr/bin/env python3
"""
DuckDB查询缓存最佳实践示例
演示如何在应用程序中正确使用查询缓存功能
"""

import duckdb
import time
import json
from typing import Dict, List, Any

class DuckDBCacheDemo:
    def __init__(self, db_path: str = ":memory:"):
        """初始化DuckDB连接"""
        self.conn = duckdb.connect(db_path)
        
        # 启用查询缓存
        self.conn.execute("PRAGMA enable_query_cache=true")
        print("✅ 查询缓存已启用")
        
        # 创建测试数据
        self.setup_test_data()
    
    def setup_test_data(self):
        """创建测试数据"""
        print("📊 创建测试数据...")
        
        # 创建订单表
        self.conn.execute("""
            CREATE TABLE orders AS 
            SELECT 
                range AS order_id,
                (range % 1000) AS customer_id,
                (range * 1.5 + 100) AS total_price,
                CASE (range % 3) 
                    WHEN 0 THEN 'COMPLETED' 
                    WHEN 1 THEN 'PENDING' 
                    ELSE 'CANCELLED' 
                END AS status,
                DATE '2023-01-01' + INTERVAL (range % 365) DAY AS order_date
            FROM range(100000)
        """)
        
        # 创建产品表
        self.conn.execute("""
            CREATE TABLE products AS
            SELECT 
                range AS product_id,
                'Product_' || range AS product_name,
                (range * 0.1 + 10) AS price,
                CASE (range % 5)
                    WHEN 0 THEN 'Electronics'
                    WHEN 1 THEN 'Clothing'
                    WHEN 2 THEN 'Books'
                    WHEN 3 THEN 'Home'
                    ELSE 'Sports'
                END AS category
            FROM range(10000)
        """)
        
        print("✅ 测试数据创建完成")
    
    def get_cache_stats(self) -> Dict[str, Any]:
        """获取缓存统计信息"""
        result = self.conn.execute("SELECT * FROM pragma_query_cache_stats()").fetchone()
        if result:
            return {
                'total_entries': result[0],
                'total_hits': result[1],
                'total_misses': result[2],
                'hit_rate': result[3],
                'memory_usage_bytes': result[4],
                'false_positive_rate': result[5],
                'enabled': result[6]
            }
        return {}
    
    def execute_with_timing(self, query: str, description: str = "") -> Dict[str, Any]:
        """执行查询并测量时间"""
        start_time = time.time()
        result = self.conn.execute(query).fetchall()
        end_time = time.time()
        
        execution_time = end_time - start_time
        cache_stats = self.get_cache_stats()
        
        return {
            'description': description,
            'query': query,
            'execution_time': execution_time,
            'result_count': len(result),
            'cache_stats': cache_stats
        }
    
    def demo_simple_queries(self):
        """演示简单查询的缓存效果"""
        print("\n🔍 测试简单查询缓存效果")
        print("=" * 50)
        
        queries = [
            ("SELECT COUNT(*) FROM orders", "订单总数统计"),
            ("SELECT AVG(total_price) FROM orders", "平均订单金额"),
            ("SELECT COUNT(DISTINCT customer_id) FROM orders", "独立客户数量"),
            ("SELECT MAX(order_date) FROM orders", "最新订单日期")
        ]
        
        results = []
        
        for query, desc in queries:
            print(f"\n📋 {desc}")
            
            # 第一次执行
            result1 = self.execute_with_timing(query, f"{desc} - 第1次")
            print(f"   第1次执行: {result1['execution_time']:.6f}s")
            
            # 第二次执行（应该命中缓存）
            result2 = self.execute_with_timing(query, f"{desc} - 第2次")
            print(f"   第2次执行: {result2['execution_time']:.6f}s")
            
            # 计算加速比
            if result2['execution_time'] > 0:
                speedup = result1['execution_time'] / result2['execution_time']
                print(f"   🚀 加速比: {speedup:.2f}x")
                
                if speedup > 1.5:
                    print("   ✅ 缓存效果显著!")
                elif speedup > 1.1:
                    print("   ✅ 缓存有效果")
                else:
                    print("   ⚠️  缓存效果不明显")
            
            # 显示缓存统计
            stats = result2['cache_stats']
            print(f"   📊 缓存统计: 条目={stats.get('total_entries', 0)}, "
                  f"命中={stats.get('total_hits', 0)}, "
                  f"命中率={stats.get('hit_rate', 0):.1%}")
            
            results.append({
                'query': desc,
                'first_execution': result1,
                'second_execution': result2,
                'speedup': speedup if result2['execution_time'] > 0 else 1.0
            })
        
        return results
    
    def demo_complex_queries(self):
        """演示复杂查询的缓存效果"""
        print("\n🔍 测试复杂查询缓存效果")
        print("=" * 50)
        
        queries = [
            ("""
                SELECT 
                    status,
                    COUNT(*) as order_count,
                    AVG(total_price) as avg_price,
                    SUM(total_price) as total_revenue
                FROM orders 
                GROUP BY status 
                ORDER BY total_revenue DESC
            """, "订单状态分析"),
            
            ("""
                SELECT 
                    EXTRACT(MONTH FROM order_date) as month,
                    COUNT(*) as monthly_orders,
                    SUM(total_price) as monthly_revenue
                FROM orders 
                WHERE order_date >= '2023-01-01'
                GROUP BY EXTRACT(MONTH FROM order_date)
                ORDER BY month
            """, "月度订单趋势"),
            
            ("""
                SELECT 
                    customer_id,
                    COUNT(*) as order_count,
                    SUM(total_price) as total_spent
                FROM orders 
                GROUP BY customer_id 
                HAVING COUNT(*) > 50
                ORDER BY total_spent DESC 
                LIMIT 10
            """, "高价值客户分析")
        ]
        
        results = []
        
        for query, desc in queries:
            print(f"\n📋 {desc}")
            
            # 第一次执行
            result1 = self.execute_with_timing(query, f"{desc} - 第1次")
            print(f"   第1次执行: {result1['execution_time']:.6f}s")
            
            # 第二次执行
            result2 = self.execute_with_timing(query, f"{desc} - 第2次")
            print(f"   第2次执行: {result2['execution_time']:.6f}s")
            
            # 第三次执行
            result3 = self.execute_with_timing(query, f"{desc} - 第3次")
            print(f"   第3次执行: {result3['execution_time']:.6f}s")
            
            # 计算平均缓存性能
            cached_avg = (result2['execution_time'] + result3['execution_time']) / 2
            if cached_avg > 0:
                speedup = result1['execution_time'] / cached_avg
                print(f"   🚀 平均加速比: {speedup:.2f}x")
            
            # 显示缓存统计
            stats = result3['cache_stats']
            print(f"   📊 最终缓存统计: 条目={stats.get('total_entries', 0)}, "
                  f"命中={stats.get('total_hits', 0)}, "
                  f"命中率={stats.get('hit_rate', 0):.1%}")
            
            results.append({
                'query': desc,
                'executions': [result1, result2, result3],
                'speedup': speedup if cached_avg > 0 else 1.0
            })
        
        return results
    
    def demo_cache_strategies(self):
        """演示不同缓存策略"""
        print("\n🔍 测试不同缓存策略")
        print("=" * 50)
        
        # 这里可以测试不同的缓存配置
        # 由于Python绑定的限制，我们主要展示统计信息
        
        stats = self.get_cache_stats()
        print(f"📊 当前缓存配置:")
        print(f"   - 缓存启用: {stats.get('enabled', False)}")
        print(f"   - 总条目数: {stats.get('total_entries', 0)}")
        print(f"   - 总命中数: {stats.get('total_hits', 0)}")
        print(f"   - 总未命中数: {stats.get('total_misses', 0)}")
        print(f"   - 命中率: {stats.get('hit_rate', 0):.1%}")
        print(f"   - 内存使用: {stats.get('memory_usage_bytes', 0)} 字节")
        print(f"   - 误报率: {stats.get('false_positive_rate', 0):.4f}")
    
    def run_comprehensive_demo(self):
        """运行综合演示"""
        print("🎯 DuckDB查询缓存功能演示")
        print("=" * 60)
        
        # 显示初始状态
        initial_stats = self.get_cache_stats()
        print(f"📊 初始缓存状态: 启用={initial_stats.get('enabled', False)}")
        
        # 测试简单查询
        simple_results = self.demo_simple_queries()
        
        # 测试复杂查询
        complex_results = self.demo_complex_queries()
        
        # 显示缓存策略信息
        self.demo_cache_strategies()
        
        # 生成总结报告
        self.generate_summary_report(simple_results, complex_results)
    
    def generate_summary_report(self, simple_results: List, complex_results: List):
        """生成总结报告"""
        print("\n📋 性能测试总结报告")
        print("=" * 60)
        
        # 计算总体统计
        all_speedups = []
        total_cache_hits = 0
        
        for result in simple_results + complex_results:
            if 'speedup' in result:
                all_speedups.append(result['speedup'])
        
        final_stats = self.get_cache_stats()
        total_cache_hits = final_stats.get('total_hits', 0)
        
        avg_speedup = sum(all_speedups) / len(all_speedups) if all_speedups else 1.0
        max_speedup = max(all_speedups) if all_speedups else 1.0
        
        print(f"🎯 总体性能指标:")
        print(f"   - 测试查询数量: {len(simple_results) + len(complex_results)}")
        print(f"   - 平均加速比: {avg_speedup:.2f}x")
        print(f"   - 最大加速比: {max_speedup:.2f}x")
        print(f"   - 总缓存命中: {total_cache_hits}")
        print(f"   - 最终命中率: {final_stats.get('hit_rate', 0):.1%}")
        
        print(f"\n💡 使用建议:")
        if avg_speedup > 2.0:
            print("   ✅ 查询缓存效果优秀，建议在生产环境中启用")
        elif avg_speedup > 1.5:
            print("   ✅ 查询缓存效果良好，适合重复查询场景")
        elif avg_speedup > 1.1:
            print("   ⚠️  查询缓存有一定效果，建议根据具体场景评估")
        else:
            print("   ❌ 查询缓存效果不明显，可能不适合当前查询模式")
        
        print(f"\n🔧 优化建议:")
        print("   - 在长时间运行的应用程序中使用查询缓存")
        print("   - 对重复执行的分析查询启用缓存")
        print("   - 监控缓存命中率，调整缓存策略")
        print("   - 考虑查询复杂度和数据变化频率")
    
    def close(self):
        """关闭连接"""
        if self.conn:
            self.conn.close()
            print("🔒 数据库连接已关闭")

def main():
    """主函数"""
    demo = DuckDBCacheDemo()
    
    try:
        demo.run_comprehensive_demo()
    finally:
        demo.close()

if __name__ == "__main__":
    main()