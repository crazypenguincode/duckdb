#!/usr/bin/env python3
"""
硬件性能基准测试脚本
用于获取真实的硬件性能数据
"""

import time
import os
import subprocess
import psutil
import json
import threading
from concurrent.futures import ThreadPoolExecutor
import tempfile
import random
import string

class HardwareBenchmark:
    """硬件基准测试类"""
    
    def __init__(self):
        self.results = {}
        
    def get_system_info(self):
        """获取系统信息"""
        print("获取系统信息...")
        
        # 获取CPU信息
        cpu_info = {
            "physical_cores": psutil.cpu_count(logical=False),
            "logical_cores": psutil.cpu_count(logical=True),
            "cpu_freq": psutil.cpu_freq()._asdict() if psutil.cpu_freq() else {},
            "cpu_percent": psutil.cpu_percent(interval=1)
        }
        
        # 获取内存信息
        memory = psutil.virtual_memory()
        memory_info = {
            "total_gb": round(memory.total / (1024**3), 2),
            "available_gb": round(memory.available / (1024**3), 2),
            "used_gb": round(memory.used / (1024**3), 2),
            "percent": memory.percent
        }
        
        # 获取磁盘信息
        disk = psutil.disk_usage('/')
        disk_info = {
            "total_gb": round(disk.total / (1024**3), 2),
            "used_gb": round(disk.used / (1024**3), 2),
            "free_gb": round(disk.free / (1024**3), 2),
            "percent": round(disk.used / disk.total * 100, 2)
        }
        
        # 尝试获取macOS特定信息
        try:
            # 获取CPU品牌
            cpu_brand = subprocess.check_output(
                ["sysctl", "-n", "machdep.cpu.brand_string"], 
                text=True
            ).strip()
        except:
            cpu_brand = "Unknown"
            
        try:
            # 获取内存类型
            hw_model = subprocess.check_output(
                ["sysctl", "-n", "hw.model"], 
                text=True
            ).strip()
        except:
            hw_model = "Unknown"
        
        return {
            "cpu": cpu_info,
            "memory": memory_info,
            "disk": disk_info,
            "cpu_brand": cpu_brand,
            "hw_model": hw_model
        }
    
    def test_disk_performance(self):
        """测试磁盘性能"""
        print("测试磁盘性能...")
        
        # 创建临时测试文件
        test_file = "/tmp/disk_performance_test.dat"
        file_size_mb = 100  # 100MB测试文件
        
        results = {}
        
        # 测试写入性能
        print("  测试磁盘写入性能...")
        write_data = os.urandom(1024 * 1024)  # 1MB随机数据
        
        start_time = time.time()
        with open(test_file, 'wb') as f:
            for _ in range(file_size_mb):
                f.write(write_data)
                f.flush()
                os.fsync(f.fileno())  # 强制写入磁盘
        
        write_time = time.time() - start_time
        write_speed_mb_s = file_size_mb / write_time
        
        results['write_speed_mb_s'] = round(write_speed_mb_s, 1)
        results['write_time_s'] = round(write_time, 2)
        
        # 测试读取性能
        print("  测试磁盘读取性能...")
        start_time = time.time()
        with open(test_file, 'rb') as f:
            while f.read(1024 * 1024):  # 每次读取1MB
                pass
        
        read_time = time.time() - start_time
        read_speed_mb_s = file_size_mb / read_time
        
        results['read_speed_mb_s'] = round(read_speed_mb_s, 1)
        results['read_time_s'] = round(read_time, 2)
        
        # 测试随机读写性能
        print("  测试随机读写性能...")
        random_results = self.test_random_io(test_file, file_size_mb)
        results.update(random_results)
        
        # 清理测试文件
        if os.path.exists(test_file):
            os.remove(test_file)
        
        return results
    
    def test_random_io(self, test_file, file_size_mb):
        """测试随机I/O性能"""
        results = {}
        
        # 随机写入测试
        start_time = time.time()
        with open(test_file, 'r+b') as f:
            for _ in range(1000):  # 1000次随机写入
                position = random.randint(0, file_size_mb * 1024 * 1024 - 4096)
                f.seek(position)
                f.write(os.urandom(4096))  # 写入4KB
        
        random_write_time = time.time() - start_time
        results['random_write_iops'] = round(1000 / random_write_time, 1)
        
        # 随机读取测试
        start_time = time.time()
        with open(test_file, 'rb') as f:
            for _ in range(1000):  # 1000次随机读取
                position = random.randint(0, file_size_mb * 1024 * 1024 - 4096)
                f.seek(position)
                f.read(4096)  # 读取4KB
        
        random_read_time = time.time() - start_time
        results['random_read_iops'] = round(1000 / random_read_time, 1)
        
        return results
    
    def test_memory_performance(self):
        """测试内存性能"""
        print("测试内存性能...")
        
        results = {}
        
        # 测试内存分配性能
        print("  测试内存分配性能...")
        start_time = time.time()
        
        # 分配1GB内存
        memory_blocks = []
        block_size = 1024 * 1024  # 1MB块
        num_blocks = 1024  # 1024个块 = 1GB
        
        for _ in range(num_blocks):
            block = bytearray(block_size)
            memory_blocks.append(block)
        
        allocation_time = time.time() - start_time
        results['memory_allocation_time_s'] = round(allocation_time, 2)
        results['memory_allocation_speed_gb_s'] = round(1.0 / allocation_time, 2)
        
        # 测试内存写入性能
        print("  测试内存写入性能...")
        start_time = time.time()
        
        for block in memory_blocks:
            # 写入随机数据
            for i in range(0, len(block), 8):
                block[i:i+8] = (i % 256).to_bytes(8, 'little')
        
        write_time = time.time() - start_time
        results['memory_write_time_s'] = round(write_time, 2)
        results['memory_write_speed_gb_s'] = round(1.0 / write_time, 2)
        
        # 测试内存读取性能
        print("  测试内存读取性能...")
        start_time = time.time()
        
        checksum = 0
        for block in memory_blocks:
            for i in range(0, len(block), 8):
                checksum += int.from_bytes(block[i:i+8], 'little')
        
        read_time = time.time() - start_time
        results['memory_read_time_s'] = round(read_time, 2)
        results['memory_read_speed_gb_s'] = round(1.0 / read_time, 2)
        results['checksum'] = checksum  # 防止编译器优化
        
        # 清理内存
        del memory_blocks
        
        return results
    
    def test_cpu_performance(self):
        """测试CPU性能"""
        print("测试CPU性能...")
        
        results = {}
        
        # 单线程CPU测试
        print("  测试单线程CPU性能...")
        start_time = time.time()
        
        # 计算密集型任务：计算前100万个质数
        def is_prime(n):
            if n < 2:
                return False
            for i in range(2, int(n ** 0.5) + 1):
                if n % i == 0:
                    return False
            return True
        
        primes = []
        n = 2
        while len(primes) < 100000:  # 前10万个质数
            if is_prime(n):
                primes.append(n)
            n += 1
        
        single_thread_time = time.time() - start_time
        results['single_thread_time_s'] = round(single_thread_time, 2)
        results['single_thread_primes_per_s'] = round(100000 / single_thread_time, 1)
        
        # 多线程CPU测试
        print("  测试多线程CPU性能...")
        num_threads = psutil.cpu_count(logical=True)
        
        def worker_task(start_n, count):
            """工作线程任务"""
            primes = []
            n = start_n
            while len(primes) < count:
                if is_prime(n):
                    primes.append(n)
                n += 1
            return primes
        
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=num_threads) as executor:
            futures = []
            primes_per_thread = 10000 // num_threads
            
            for i in range(num_threads):
                start_n = 2 + i * 1000  # 错开起始点
                future = executor.submit(worker_task, start_n, primes_per_thread)
                futures.append(future)
            
            # 等待所有线程完成
            all_primes = []
            for future in futures:
                thread_primes = future.result()
                all_primes.extend(thread_primes)
        
        multi_thread_time = time.time() - start_time
        results['multi_thread_time_s'] = round(multi_thread_time, 2)
        results['multi_thread_primes_per_s'] = round(len(all_primes) / multi_thread_time, 1)
        results['cpu_threads_used'] = num_threads
        results['speedup_ratio'] = round(single_thread_time / multi_thread_time, 2)
        
        return results
    
    def test_database_performance(self):
        """测试数据库相关性能"""
        print("测试数据库性能...")
        
        import sqlite3
        
        results = {}
        db_path = "/tmp/performance_test.db"
        
        # 创建测试数据库
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE test_table (
                id INTEGER PRIMARY KEY,
                name TEXT,
                value REAL,
                data BLOB
            )
        """)
        
        # 测试插入性能
        print("  测试数据库插入性能...")
        test_data = []
        for i in range(100000):
            test_data.append((
                i,
                f"name_{i}",
                random.uniform(0, 1000),
                os.urandom(100)  # 100字节随机数据
            ))
        
        start_time = time.time()
        cursor.executemany(
            "INSERT INTO test_table (id, name, value, data) VALUES (?, ?, ?, ?)",
            test_data
        )
        conn.commit()
        
        insert_time = time.time() - start_time
        results['db_insert_time_s'] = round(insert_time, 2)
        results['db_insert_rate_per_s'] = round(100000 / insert_time, 1)
        
        # 测试查询性能
        print("  测试数据库查询性能...")
        
        # 简单查询
        start_time = time.time()
        for _ in range(1000):
            cursor.execute("SELECT * FROM test_table WHERE id = ?", (random.randint(0, 99999),))
            cursor.fetchone()
        
        simple_query_time = time.time() - start_time
        results['db_simple_query_time_s'] = round(simple_query_time, 2)
        results['db_simple_query_rate_per_s'] = round(1000 / simple_query_time, 1)
        
        # 聚合查询
        start_time = time.time()
        cursor.execute("SELECT COUNT(*), AVG(value), MAX(value), MIN(value) FROM test_table")
        cursor.fetchone()
        
        aggregate_query_time = time.time() - start_time
        results['db_aggregate_query_time_s'] = round(aggregate_query_time, 2)
        
        conn.close()
        
        # 清理测试文件
        if os.path.exists(db_path):
            os.remove(db_path)
        
        return results
    
    def run_all_tests(self):
        """运行所有测试"""
        print("开始硬件性能基准测试...")
        
        # 获取系统信息
        self.results['system_info'] = self.get_system_info()
        
        # 运行各项测试
        self.results['disk_performance'] = self.test_disk_performance()
        self.results['memory_performance'] = self.test_memory_performance()
        self.results['cpu_performance'] = self.test_cpu_performance()
        self.results['database_performance'] = self.test_database_performance()
        
        return self.results
    
    def generate_report(self):
        """生成测试报告"""
        report_path = "/tmp/hardware_benchmark_report.json"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"\n硬件基准测试报告已保存到: {report_path}")
        
        # 打印简要报告
        print("\n=== 硬件性能基准测试报告 ===")
        
        # 系统信息
        sys_info = self.results['system_info']
        print(f"\n系统信息:")
        print(f"  CPU: {sys_info['cpu_brand']}")
        print(f"  物理核心: {sys_info['cpu']['physical_cores']}")
        print(f"  逻辑核心: {sys_info['cpu']['logical_cores']}")
        print(f"  总内存: {sys_info['memory']['total_gb']} GB")
        print(f"  可用内存: {sys_info['memory']['available_gb']} GB")
        print(f"  磁盘总容量: {sys_info['disk']['total_gb']} GB")
        print(f"  磁盘可用: {sys_info['disk']['free_gb']} GB")
        
        # 磁盘性能
        disk_perf = self.results['disk_performance']
        print(f"\n磁盘性能:")
        print(f"  顺序写入速度: {disk_perf['write_speed_mb_s']} MB/s")
        print(f"  顺序读取速度: {disk_perf['read_speed_mb_s']} MB/s")
        print(f"  随机写入IOPS: {disk_perf['random_write_iops']}")
        print(f"  随机读取IOPS: {disk_perf['random_read_iops']}")
        
        # 内存性能
        mem_perf = self.results['memory_performance']
        print(f"\n内存性能:")
        print(f"  内存分配速度: {mem_perf['memory_allocation_speed_gb_s']} GB/s")
        print(f"  内存写入速度: {mem_perf['memory_write_speed_gb_s']} GB/s")
        print(f"  内存读取速度: {mem_perf['memory_read_speed_gb_s']} GB/s")
        
        # CPU性能
        cpu_perf = self.results['cpu_performance']
        print(f"\nCPU性能:")
        print(f"  单线程性能: {cpu_perf['single_thread_primes_per_s']} 质数/秒")
        print(f"  多线程性能: {cpu_perf['multi_thread_primes_per_s']} 质数/秒")
        print(f"  多线程加速比: {cpu_perf['speedup_ratio']}x")
        
        # 数据库性能
        db_perf = self.results['database_performance']
        print(f"\n数据库性能:")
        print(f"  插入速率: {db_perf['db_insert_rate_per_s']} 记录/秒")
        print(f"  简单查询速率: {db_perf['db_simple_query_rate_per_s']} 查询/秒")
        print(f"  聚合查询时间: {db_perf['db_aggregate_query_time_s']} 秒")

def main():
    """主函数"""
    benchmark = HardwareBenchmark()
    
    try:
        results = benchmark.run_all_tests()
        benchmark.generate_report()
        
        print("\n硬件基准测试完成！")
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
    except Exception as e:
        print(f"测试过程中发生错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()