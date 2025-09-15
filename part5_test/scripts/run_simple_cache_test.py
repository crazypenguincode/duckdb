#!/usr/bin/env python3
"""
简单的缓存性能测试脚本
快速验证缓存功能是否正常工作
"""

import os
import sys
import time
import subprocess
import json
from pathlib import Path
from datetime import datetime

def create_test_database(duckdb_path, db_path):
    """创建测试数据库"""
    print("创建测试数据库...")
    
    # 创建数据库的SQL
    create_sql = """
    -- 创建测试表
    CREATE TABLE test_table AS 
    SELECT 
        i as id,
        'name_' || i as name,
        random() * 1000 as value,
        (random() * 10)::int as category
    FROM range(10000) t(i);
    
    -- 创建索引
    CREATE INDEX idx_test_category ON test_table(category);
    CREATE INDEX idx_test_value ON test_table(value);
    """
    
    try:
        result = subprocess.run([
            duckdb_path, str(db_path), "-c", create_sql
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✓ 测试数据库创建成功")
            return True
        else:
            print(f"✗ 数据库创建失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"✗ 数据库创建异常: {e}")
        return False

def execute_query_with_timing(duckdb_path, db_path, query, cache_enabled=True):
    """执行查询并测量时间"""
    cache_setting = "SET enable_query_cache = true;" if cache_enabled else "SET enable_query_cache = false;"
    full_sql = f"{cache_setting}\n{query}"
    
    start_time = time.time()
    
    try:
        result = subprocess.run([
            duckdb_path, str(db_path), "-c", full_sql
        ], capture_output=True, text=True, timeout=30)
        
        end_time = time.time()
        execution_time = (end_time - start_time) * 1000  # 转换为毫秒
        
        if result.returncode == 0:
            return {
                'success': True,
                'time_ms': execution_time,
                'output': result.stdout.strip()
            }
        else:
            return {
                'success': False,
                'error': result.stderr,
                'time_ms': execution_time
            }
            
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'error': 'Query timeout',
            'time_ms': 30000
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'time_ms': 0
        }

def run_cache_test(duckdb_path, db_path):
    """运行缓存测试"""
    print("\n=== 开始缓存性能测试 ===")
    
    # 测试查询
    test_queries = [
        {
            'name': '简单聚合查询',
            'sql': 'SELECT category, COUNT(*), AVG(value) FROM test_table GROUP BY category ORDER BY category;'
        },
        {
            'name': '条件过滤查询',
            'sql': 'SELECT * FROM test_table WHERE value > 500 AND category = 5 ORDER BY value DESC LIMIT 10;'
        },
        {
            'name': '窗口函数查询',
            'sql': 'SELECT id, name, value, ROW_NUMBER() OVER (PARTITION BY category ORDER BY value DESC) as rank FROM test_table WHERE category IN (1,2,3);'
        },
        {
            'name': '复杂聚合查询',
            'sql': 'SELECT category, MIN(value) as min_val, MAX(value) as max_val, STDDEV(value) as std_val FROM test_table GROUP BY category HAVING COUNT(*) > 100;'
        }
    ]
    
    results = {
        'test_info': {
            'timestamp': datetime.now().isoformat(),
            'duckdb_path': duckdb_path,
            'db_path': str(db_path)
        },
        'queries': []
    }
    
    for i, query_info in enumerate(test_queries, 1):
        print(f"\n[{i}/{len(test_queries)}] 测试: {query_info['name']}")
        
        query_result = {
            'name': query_info['name'],
            'sql': query_info['sql'],
            'executions': []
        }
        
        # 执行多次测试
        print("  执行次数: ", end="")
        
        for run in range(5):  # 每个查询执行5次
            print(f"{run+1}", end="")
            
            # 无缓存执行
            uncached_result = execute_query_with_timing(
                duckdb_path, db_path, query_info['sql'], cache_enabled=False
            )
            
            # 有缓存执行
            cached_result = execute_query_with_timing(
                duckdb_path, db_path, query_info['sql'], cache_enabled=True
            )
            
            execution = {
                'run': run + 1,
                'uncached': uncached_result,
                'cached': cached_result
            }
            
            query_result['executions'].append(execution)
            
            if run < 4:
                print(".", end="")
            else:
                print(" ✓")
        
        # 计算统计信息
        successful_runs = [e for e in query_result['executions'] 
                          if e['uncached']['success'] and e['cached']['success']]
        
        if successful_runs:
            uncached_times = [e['uncached']['time_ms'] for e in successful_runs]
            cached_times = [e['cached']['time_ms'] for e in successful_runs]
            
            avg_uncached = sum(uncached_times) / len(uncached_times)
            avg_cached = sum(cached_times) / len(cached_times)
            improvement = (avg_uncached - avg_cached) / avg_uncached * 100 if avg_uncached > 0 else 0
            
            query_result['statistics'] = {
                'successful_runs': len(successful_runs),
                'avg_uncached_ms': avg_uncached,
                'avg_cached_ms': avg_cached,
                'improvement_pct': improvement,
                'min_uncached_ms': min(uncached_times),
                'max_uncached_ms': max(uncached_times),
                'min_cached_ms': min(cached_times),
                'max_cached_ms': max(cached_times)
            }
            
            print(f"    平均无缓存时间: {avg_uncached:.2f}ms")
            print(f"    平均缓存时间: {avg_cached:.2f}ms")
            print(f"    性能提升: {improvement:.2f}%")
        else:
            query_result['statistics'] = {
                'successful_runs': 0,
                'error': 'No successful executions'
            }
            print("    ✗ 所有执行都失败了")
        
        results['queries'].append(query_result)
    
    return results

def generate_summary_report(results):
    """生成摘要报告"""
    print("\n=== 测试摘要 ===")
    
    successful_queries = []
    total_queries = len(results['queries'])
    
    for query in results['queries']:
        if 'statistics' in query and 'improvement_pct' in query['statistics']:
            successful_queries.append(query)
    
    if successful_queries:
        improvements = [q['statistics']['improvement_pct'] for q in successful_queries]
        avg_improvement = sum(improvements) / len(improvements)
        
        print(f"成功测试的查询: {len(successful_queries)}/{total_queries}")
        print(f"平均性能提升: {avg_improvement:.2f}%")
        print(f"性能提升范围: {min(improvements):.2f}% - {max(improvements):.2f}%")
        
        # 显示每个查询的结果
        print("\n详细结果:")
        for query in successful_queries:
            stats = query['statistics']
            print(f"  {query['name']}: {stats['improvement_pct']:.2f}% "
                  f"({stats['avg_uncached_ms']:.2f}ms → {stats['avg_cached_ms']:.2f}ms)")
        
        return True
    else:
        print("没有成功的查询测试")
        return False

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("Usage: python run_simple_cache_test.py <duckdb_path> [db_path]")
        print("Example: python run_simple_cache_test.py ./duckdb")
        print("Example: python run_simple_cache_test.py ./duckdb test_cache.db")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    db_path = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("simple_cache_test.db")
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    print("简单缓存性能测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"测试数据库: {db_path}")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    try:
        # 删除旧的数据库文件
        if db_path.exists():
            db_path.unlink()
        
        # 创建测试数据库
        if not create_test_database(duckdb_path, db_path):
            print("数据库创建失败，退出测试")
            sys.exit(1)
        
        # 运行缓存测试
        results = run_cache_test(duckdb_path, db_path)
        
        # 保存详细结果
        result_file = Path(f"simple_cache_test_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        print(f"\n详细结果已保存到: {result_file}")
        
        # 生成摘要报告
        success = generate_summary_report(results)
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"已清理测试数据库: {db_path}")
        
        if success:
            print("\n🎉 缓存测试成功完成！")
            sys.exit(0)
        else:
            print("\n⚠️ 缓存测试部分失败")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()