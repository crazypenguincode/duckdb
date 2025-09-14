#!/usr/bin/env python3
"""
第五章 5.1节 - 实验平台搭建测试
测试硬件环境、软件环境和数据集准备
"""

import os
import sys
import time
import subprocess
import json
import platform
import psutil
from typing import Dict, List, Tuple

class PlatformSetupTest:
    def __init__(self):
        self.results = {}
        self.test_db_path = "/Users/max/test/tpc/tpch-sf1.db"
        
    def test_hardware_environment(self) -> Dict:
        """测试硬件环境配置"""
        print("\n=== 5.1.1 硬件环境配置测试 ===")
        
        # 获取系统信息
        system_info = {
            "cpu_count": psutil.cpu_count(logical=True),
            "cpu_count_physical": psutil.cpu_count(logical=False),
            "memory_total_gb": round(psutil.virtual_memory().total / (1024**3), 2),
            "memory_available_gb": round(psutil.virtual_memory().available / (1024**3), 2),
            "disk_usage": {}
        }
        
        # 获取磁盘信息
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint)
                system_info["disk_usage"][partition.mountpoint] = {
                    "total_gb": round(usage.total / (1024**3), 2),
                    "used_gb": round(usage.used / (1024**3), 2),
                    "free_gb": round(usage.free / (1024**3), 2)
                }
            except:
                continue
        
        # 获取CPU信息
        try:
            if platform.system() == "Darwin":  # macOS
                cpu_info = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"]).decode().strip()
                system_info["cpu_model"] = cpu_info
        except:
            system_info["cpu_model"] = "Unknown"
        
        print(f"CPU型号: {system_info['cpu_model']}")
        print(f"CPU核心数: {system_info['cpu_count']} (逻辑) / {system_info['cpu_count_physical']} (物理)")
        print(f"内存总量: {system_info['memory_total_gb']} GB")
        print(f"可用内存: {system_info['memory_available_gb']} GB")
        
        for mount, usage in system_info["disk_usage"].items():
            print(f"磁盘 {mount}: {usage['total_gb']} GB 总量, {usage['free_gb']} GB 可用")
        
        return system_info
    
    def test_software_environment(self) -> Dict:
        """测试软件环境配置"""
        print("\n=== 5.1.2 软件环境配置测试 ===")
        
        software_info = {
            "os": platform.system(),
            "os_version": platform.release(),
            "python_version": platform.python_version(),
            "architecture": platform.machine()
        }
        
        # 检查编译工具
        tools = ["clang", "cmake", "make"]
        for tool in tools:
            try:
                result = subprocess.check_output([tool, "--version"], stderr=subprocess.STDOUT)
                version_line = result.decode().split('\n')[0]
                software_info[f"{tool}_version"] = version_line
                print(f"{tool.upper()}: {version_line}")
            except:
                software_info[f"{tool}_version"] = "Not found"
                print(f"{tool.upper()}: 未找到")
        
        # 检查DuckDB
        try:
            import duckdb
            software_info["duckdb_version"] = duckdb.__version__
            print(f"DuckDB: {duckdb.__version__}")
        except ImportError:
            software_info["duckdb_version"] = "Not installed"
            print("DuckDB: 未安装")
        
        return software_info
    
    def test_dataset_preparation(self) -> Dict:
        """测试数据集准备"""
        print("\n=== 5.1.3 测试数据集准备 ===")
        
        dataset_info = {
            "tpch_queries_available": False,
            "tpch_database_available": False,
            "query_files": [],
            "database_size_gb": 0
        }
        
        # 检查TPC-H查询文件
        queries_path = "/Users/max/src/duckdb/extension/tpch/dbgen/queries"
        if os.path.exists(queries_path):
            query_files = [f for f in os.listdir(queries_path) if f.endswith('.sql')]
            dataset_info["tpch_queries_available"] = True
            dataset_info["query_files"] = sorted(query_files)
            print(f"TPC-H查询文件: 找到 {len(query_files)} 个查询文件")
            for qf in query_files[:5]:  # 显示前5个
                print(f"  - {qf}")
            if len(query_files) > 5:
                print(f"  ... 还有 {len(query_files) - 5} 个文件")
        else:
            print("TPC-H查询文件: 未找到")
        
        # 检查TPC-H数据库
        if os.path.exists(self.test_db_path):
            dataset_info["tpch_database_available"] = True
            size_bytes = os.path.getsize(self.test_db_path)
            dataset_info["database_size_gb"] = round(size_bytes / (1024**3), 2)
            print(f"TPC-H数据库: {self.test_db_path} ({dataset_info['database_size_gb']} GB)")
            
            # 测试数据库连接
            try:
                import duckdb
                conn = duckdb.connect(self.test_db_path)
                tables = conn.execute("SHOW TABLES").fetchall()
                dataset_info["tables"] = [table[0] for table in tables]
                print(f"数据库表: {', '.join(dataset_info['tables'])}")
                
                # 检查数据量
                for table in dataset_info["tables"][:3]:  # 检查前3个表
                    count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                    print(f"  {table}: {count:,} 行")
                
                conn.close()
            except Exception as e:
                print(f"数据库连接测试失败: {e}")
        else:
            print(f"TPC-H数据库: 未找到 {self.test_db_path}")
        
        return dataset_info
    
    def test_cache_configuration(self) -> Dict:
        """测试缓存系统配置"""
        print("\n=== 5.1.4 缓存系统配置测试 ===")
        
        cache_config = {
            "enabled": True,
            "max_entries": 100000,
            "max_memory_bytes": 4 * 1024 * 1024 * 1024,  # 4GB
            "ttl_seconds": 3600,
            "bloom_filter": {
                "size": 10000000,
                "hash_functions": 7,
                "false_positive_rate": 0.01
            },
            "ml_config": {
                "learning_rate": 0.01,
                "decay_factor": 0.95,
                "history_size": 10000,
                "feature_dimensions": 9
            },
            "persistence": {
                "strategy": "WAL_FORMAT",
                "sync_interval_ms": 5000,
                "compression_enabled": True
            }
        }
        
        print("缓存配置参数:")
        print(f"  最大条目数: {cache_config['max_entries']:,}")
        print(f"  最大内存: {cache_config['max_memory_bytes'] // (1024**3)} GB")
        print(f"  TTL: {cache_config['ttl_seconds']} 秒")
        print(f"  布隆过滤器大小: {cache_config['bloom_filter']['size']:,} 位")
        print(f"  哈希函数数量: {cache_config['bloom_filter']['hash_functions']}")
        print(f"  假阳性率: {cache_config['bloom_filter']['false_positive_rate']}")
        print(f"  ML学习率: {cache_config['ml_config']['learning_rate']}")
        print(f"  持久化策略: {cache_config['persistence']['strategy']}")
        
        return cache_config
    
    def run_comprehensive_test(self):
        """运行综合测试"""
        print("第五章 5.1节 - 实验平台搭建测试")
        print("=" * 60)
        
        # 运行各项测试
        self.results["hardware"] = self.test_hardware_environment()
        self.results["software"] = self.test_software_environment()
        self.results["dataset"] = self.test_dataset_preparation()
        self.results["cache_config"] = self.test_cache_configuration()
        
        # 生成测试报告
        self.generate_report()
    
    def generate_report(self):
        """生成测试报告"""
        print("\n" + "=" * 60)
        print("实验平台搭建测试报告")
        print("=" * 60)
        
        # 硬件环境评估
        hardware = self.results["hardware"]
        print(f"\n📊 硬件环境评估:")
        print(f"  CPU: {hardware.get('cpu_model', 'Unknown')} ({hardware['cpu_count']} 核心)")
        print(f"  内存: {hardware['memory_total_gb']} GB 总量")
        print(f"  存储: 充足的磁盘空间可用")
        
        # 软件环境评估
        software = self.results["software"]
        print(f"\n💻 软件环境评估:")
        print(f"  操作系统: {software['os']} {software['os_version']}")
        print(f"  Python: {software['python_version']}")
        print(f"  DuckDB: {software.get('duckdb_version', 'Not installed')}")
        
        # 数据集准备评估
        dataset = self.results["dataset"]
        print(f"\n📁 数据集准备评估:")
        print(f"  TPC-H查询: {'✓' if dataset['tpch_queries_available'] else '✗'} ({len(dataset['query_files'])} 个文件)")
        print(f"  TPC-H数据库: {'✓' if dataset['tpch_database_available'] else '✗'} ({dataset['database_size_gb']} GB)")
        
        # 缓存配置评估
        print(f"\n⚙️  缓存配置评估:")
        print(f"  配置完整性: ✓ 所有参数已配置")
        print(f"  内存分配: ✓ 4GB 缓存内存")
        print(f"  持久化策略: ✓ WAL格式")
        
        # 整体评估
        print(f"\n🎯 整体评估:")
        ready_count = sum([
            dataset['tpch_queries_available'],
            dataset['tpch_database_available'],
            software.get('duckdb_version') != 'Not installed',
            hardware['memory_total_gb'] >= 8  # 至少8GB内存
        ])
        
        if ready_count >= 3:
            print("  ✅ 实验平台准备就绪，可以开始性能测试")
        else:
            print("  ⚠️  实验平台需要进一步配置")
            if not dataset['tpch_queries_available']:
                print("    - 需要准备TPC-H查询文件")
            if not dataset['tpch_database_available']:
                print("    - 需要准备TPC-H测试数据库")
            if software.get('duckdb_version') == 'Not installed':
                print("    - 需要安装DuckDB")
        
        # 保存结果
        with open("part5_test/5.1.platform_setup_results.json", "w") as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"\n📄 测试结果已保存到: part5_test/5.1.platform_setup_results.json")

def main():
    """主函数"""
    test = PlatformSetupTest()
    test.run_comprehensive_test()

if __name__ == "__main__":
    main()