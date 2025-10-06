#!/usr/bin/env python3
"""
TPC-H 测试环境验证脚本
验证DuckDB可执行文件、TPC-H数据库和查询文件是否正确配置
"""

import os
import sys
import subprocess
from pathlib import Path

class TPCHEnvironmentVerifier:
    def __init__(self):
        self.duckdb_path = "/Users/max/src/duckdb/build/release/duckdb"
        self.tpch_db_path = "/Users/max/test/tpc/tpch-sf1.db"
        self.queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
        self.verification_results = {}
    
    def verify_duckdb_executable(self):
        """验证DuckDB可执行文件"""
        print("🔍 验证DuckDB可执行文件...")
        
        if not os.path.exists(self.duckdb_path):
            print(f"❌ DuckDB可执行文件不存在: {self.duckdb_path}")
            self.verification_results['duckdb_executable'] = False
            return False
        
        # 检查文件是否可执行
        if not os.access(self.duckdb_path, os.X_OK):
            print(f"❌ DuckDB文件不可执行: {self.duckdb_path}")
            self.verification_results['duckdb_executable'] = False
            return False
        
        # 测试DuckDB版本
        try:
            result = subprocess.run(
                [self.duckdb_path, "--version"],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                version_info = result.stdout.strip()
                print(f"✅ DuckDB可执行文件正常: {version_info}")
                self.verification_results['duckdb_executable'] = True
                self.verification_results['duckdb_version'] = version_info
                return True
            else:
                print(f"❌ DuckDB执行失败: {result.stderr}")
                self.verification_results['duckdb_executable'] = False
                return False
                
        except Exception as e:
            print(f"❌ DuckDB测试异常: {e}")
            self.verification_results['duckdb_executable'] = False
            return False
    
    def verify_tpch_database(self):
        """验证TPC-H数据库文件"""
        print("\n🔍 验证TPC-H数据库文件...")
        
        if not os.path.exists(self.tpch_db_path):
            print(f"❌ TPC-H数据库文件不存在: {self.tpch_db_path}")
            print("💡 请确保已创建TPC-H数据库文件")
            self.verification_results['tpch_database'] = False
            return False
        
        # 检查文件大小
        file_size = os.path.getsize(self.tpch_db_path)
        size_mb = file_size / (1024 * 1024)
        print(f"📊 数据库文件大小: {size_mb:.1f} MB")
        
        # 测试数据库连接和基本查询
        try:
            test_sql = f"""
            ATTACH '{self.tpch_db_path}' AS tpch;
            USE tpch;
            SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'main';
            """
            
            result = subprocess.run(
                [self.duckdb_path],
                input=test_sql,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                print("✅ TPC-H数据库连接正常")
                print(f"📋 查询输出: {result.stdout.strip()}")
                self.verification_results['tpch_database'] = True
                return True
            else:
                print(f"❌ TPC-H数据库查询失败: {result.stderr}")
                self.verification_results['tpch_database'] = False
                return False
                
        except Exception as e:
            print(f"❌ TPC-H数据库测试异常: {e}")
            self.verification_results['tpch_database'] = False
            return False
    
    def verify_tpch_queries(self):
        """验证TPC-H查询文件"""
        print("\n🔍 验证TPC-H查询文件...")
        
        if not os.path.exists(self.queries_dir):
            print(f"❌ TPC-H查询目录不存在: {self.queries_dir}")
            self.verification_results['tpch_queries'] = False
            return False
        
        # 检查查询文件
        expected_queries = [f"q{i:02d}.sql" for i in range(1, 23)]  # q01.sql 到 q22.sql
        existing_queries = []
        missing_queries = []
        
        for query_file in expected_queries:
            query_path = os.path.join(self.queries_dir, query_file)
            if os.path.exists(query_path):
                existing_queries.append(query_file)
            else:
                missing_queries.append(query_file)
        
        print(f"✅ 找到查询文件: {len(existing_queries)}/22")
        if missing_queries:
            print(f"⚠️ 缺失查询文件: {missing_queries}")
        
        # 测试第一个查询文件
        if existing_queries:
            first_query_path = os.path.join(self.queries_dir, existing_queries[0])
            try:
                with open(first_query_path, 'r', encoding='utf-8') as f:
                    query_content = f.read().strip()
                
                print(f"📄 示例查询文件 ({existing_queries[0]}):")
                print(f"   文件大小: {len(query_content)} 字符")
                print(f"   前100字符: {query_content[:100]}...")
                
                self.verification_results['tpch_queries'] = True
                self.verification_results['available_queries'] = len(existing_queries)
                return True
                
            except Exception as e:
                print(f"❌ 读取查询文件失败: {e}")
                self.verification_results['tpch_queries'] = False
                return False
        else:
            print("❌ 没有找到任何查询文件")
            self.verification_results['tpch_queries'] = False
            return False
    
    def test_cache_functionality(self):
        """测试缓存功能"""
        print("\n🔍 测试缓存功能...")
        
        if not (self.verification_results.get('duckdb_executable') and 
                self.verification_results.get('tpch_database')):
            print("⚠️ 跳过缓存测试 - 基础环境验证失败")
            return False
        
        # 测试缓存开关
        try:
            test_sql = f"""
            ATTACH '{self.tpch_db_path}' AS tpch;
            USE tpch;
            SET enable_query_cache = true;
            SELECT COUNT(*) FROM lineitem LIMIT 1;
            SET enable_query_cache = false;
            SELECT COUNT(*) FROM lineitem LIMIT 1;
            """
            
            result = subprocess.run(
                [self.duckdb_path],
                input=test_sql,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode == 0:
                print("✅ 缓存功能测试正常")
                self.verification_results['cache_functionality'] = True
                return True
            else:
                print(f"❌ 缓存功能测试失败: {result.stderr}")
                self.verification_results['cache_functionality'] = False
                return False
                
        except Exception as e:
            print(f"❌ 缓存功能测试异常: {e}")
            self.verification_results['cache_functionality'] = False
            return False
    
    def run_verification(self):
        """运行完整验证"""
        print("🎯 TPC-H 测试环境验证")
        print("=" * 50)
        
        # 验证步骤
        steps = [
            ("DuckDB可执行文件", self.verify_duckdb_executable),
            ("TPC-H数据库", self.verify_tpch_database),
            ("TPC-H查询文件", self.verify_tpch_queries),
            ("缓存功能", self.test_cache_functionality),
        ]
        
        all_passed = True
        
        for step_name, step_func in steps:
            try:
                if not step_func():
                    all_passed = False
            except Exception as e:
                print(f"❌ {step_name}验证过程中发生异常: {e}")
                all_passed = False
        
        # 生成验证报告
        self.generate_verification_report(all_passed)
        
        return all_passed
    
    def generate_verification_report(self, all_passed: bool):
        """生成验证报告"""
        print("\n" + "=" * 50)
        print("📋 验证结果汇总")
        print("=" * 50)
        
        if all_passed:
            print("🎉 环境验证通过! 可以运行TPC-H缓存性能测试")
        else:
            print("❌ 环境验证失败! 请修复以下问题:")
        
        print("\n📊 详细结果:")
        for key, value in self.verification_results.items():
            status = "✅" if value else "❌"
            print(f"   {status} {key}: {value}")
        
        if all_passed:
            print("\n🚀 建议的下一步操作:")
            print("   1. 运行快速测试: python3 tpch_cache_quick_test.py")
            print("   2. 运行完整测试: python3 tpch_cache_performance_test.py")
            print("   3. 或使用脚本: ./run_tpch_cache_test.sh")
        else:
            print("\n🔧 修复建议:")
            if not self.verification_results.get('duckdb_executable'):
                print("   - 编译DuckDB: make release")
            if not self.verification_results.get('tpch_database'):
                print("   - 创建TPC-H数据库或检查路径")
            if not self.verification_results.get('tpch_queries'):
                print("   - 检查TPC-H查询文件路径")

def main():
    """主函数"""
    verifier = TPCHEnvironmentVerifier()
    success = verifier.run_verification()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()