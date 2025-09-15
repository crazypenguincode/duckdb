#!/usr/bin/env python3
"""
并发查询测试脚本
"""

import threading
import time
import json
import sqlite3
import statistics
from datetime import datetime
import os

class ConcurrentQueryTester:
    def __init__(self, db_path, scenario_name, queries):
        self.db_path = db_path
        self.scenario_name = scenario_name
        self.queries = queries
        self.results = []
        self.lock = threading.Lock()
    
    def execute_user_queries(self, user_id, user_queries):
        """执行单个用户的查询"""
        user_results = []
        
        try:
            conn = sqlite3.connect(self.db_path)
            conn.execute("PRAGMA cache_size = 10000")  # 设置缓存
            
            for query_info in user_queries:
                # 思考时间
                time.sleep(query_info['think_time'])
                
                start_time = time.time()
                try:
                    cursor = conn.execute(query_info['sql_query'])
                    results = cursor.fetchall()
                    end_time = time.time()
                    
                    execution_time = (end_time - start_time) * 1000  # 转换为毫秒
                    
                    result = {
                        'user_id': user_id,
                        'query_id': query_info['query_id'],
                        'template_id': query_info['template_id'],
                        'execution_time_ms': execution_time,
                        'result_count': len(results),
                        'success': True,
                        'timestamp': datetime.now().isoformat(),
                        'is_repeat': query_info.get('is_repeat', False)
                    }
                    
                except Exception as e:
                    result = {
                        'user_id': user_id,
                        'query_id': query_info['query_id'],
                        'template_id': query_info['template_id'],
                        'execution_time_ms': 0,
                        'result_count': 0,
                        'success': False,
                        'error': str(e),
                        'timestamp': datetime.now().isoformat(),
                        'is_repeat': query_info.get('is_repeat', False)
                    }
                
                user_results.append(result)
            
            conn.close()
            
        except Exception as e:
            print(f"User {user_id} connection error: {e}")
        
        # 线程安全地添加结果
        with self.lock:
            self.results.extend(user_results)
    
    def run_concurrent_test(self):
        """运行并发测试"""
        print(f"开始并发测试: {self.scenario_name}")
        
        # 按用户分组查询
        user_queries = {}
        for query_info in self.queries:
            user_id = query_info['user_id']
            if user_id not in user_queries:
                user_queries[user_id] = []
            user_queries[user_id].append(query_info)
        
        # 创建线程
        threads = []
        start_time = time.time()
        
        for user_id, queries in user_queries.items():
            thread = threading.Thread(
                target=self.execute_user_queries,
                args=(user_id, queries)
            )
            threads.append(thread)
        
        # 启动线程
        for thread in threads:
            thread.start()
        
        # 等待所有线程完成
        for thread in threads:
            thread.join()
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # 分析结果
        return self.analyze_results(total_time)
    
    def analyze_results(self, total_time):
        """分析测试结果"""
        successful_results = [r for r in self.results if r['success']]
        failed_results = [r for r in self.results if not r['success']]
        
        if not successful_results:
            return {
                'scenario': self.scenario_name,
                'total_time': total_time,
                'total_queries': len(self.results),
                'successful_queries': 0,
                'failed_queries': len(failed_results),
                'success_rate': 0.0
            }
        
        execution_times = [r['execution_time_ms'] for r in successful_results]
        
        analysis = {
            'scenario': self.scenario_name,
            'total_time': total_time,
            'total_queries': len(self.results),
            'successful_queries': len(successful_results),
            'failed_queries': len(failed_results),
            'success_rate': len(successful_results) / len(self.results) * 100,
            'avg_execution_time_ms': statistics.mean(execution_times),
            'median_execution_time_ms': statistics.median(execution_times),
            'min_execution_time_ms': min(execution_times),
            'max_execution_time_ms': max(execution_times),
            'std_execution_time_ms': statistics.stdev(execution_times) if len(execution_times) > 1 else 0,
            'queries_per_second': len(successful_results) / total_time,
            'concurrent_users': len(set(r['user_id'] for r in self.results))
        }
        
        return analysis

def main():
    """主函数"""
    import sys
    
    if len(sys.argv) != 3:
        print("Usage: python concurrent_test.py <db_path> <scenario_name>")
        sys.exit(1)
    
    db_path = sys.argv[1]
    scenario_name = sys.argv[2]
    
    # 加载查询数据
    with open('concurrent_queries.json', 'r', encoding='utf-8') as f:
        all_queries = json.load(f)
    
    # 过滤指定场景的查询
    scenario_queries = [q for q in all_queries if q['scenario'] == scenario_name]
    
    if not scenario_queries:
        print(f"未找到场景: {scenario_name}")
        sys.exit(1)
    
    # 运行测试
    tester = ConcurrentQueryTester(db_path, scenario_name, scenario_queries)
    results = tester.run_concurrent_test()
    
    # 保存结果
    output_file = f"concurrent_test_results_{scenario_name.replace(' ', '_').lower()}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    # 打印结果
    print(f"\n测试完成: {scenario_name}")
    print(f"总查询数: {results['total_queries']}")
    print(f"成功查询数: {results['successful_queries']}")
    print(f"成功率: {results['success_rate']:.2f}%")
    print(f"平均执行时间: {results['avg_execution_time_ms']:.2f}ms")
    print(f"QPS: {results['queries_per_second']:.2f}")
    print(f"并发用户数: {results['concurrent_users']}")
    print(f"结果已保存到: {output_file}")

if __name__ == "__main__":
    main()
