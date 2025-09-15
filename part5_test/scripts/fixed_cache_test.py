#!/usr/bin/env python3
"""
修复版缓存测试脚本
使用持久连接来确保缓存在查询间保持
"""

import os
import sys
import time
import subprocess
import tempfile
from pathlib import Path
from datetime import datetime

def create_duckdb_session_script(duckdb_path, db_path, queries):
    """创建一个DuckDB会话脚本，在同一个连接中执行多个查询"""
    
    # 创建临时SQL脚本文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        # 写入所有查询到同一个脚本中
        for query in queries:
            f.write(query + '\n')
        script_path = f.name
    
    return script_path

def run_cache_comparison_test(duckdb_path, db_path):
    """运行缓存对比测试"""
    print("=== 修复版缓存对比测试 ===")
    
    # 创建测试数据
    setup_sql = """
    DROP TABLE IF EXISTS test_data;
    CREATE TABLE test_data AS 
    SELECT 
        i as id,
        'category_' || (i % 10) as category,
        'item_' || i as name,
        random() * 1000 as value,
        (random() * 100)::int as score
    FROM range(10000) t(i);
    
    CREATE INDEX idx_category ON test_data(category);
    CREATE INDEX idx_value ON test_data(value);
    """
    
    print("创建测试数据...")
    result = subprocess.run([
        duckdb_path, str(db_path), "-c", setup_sql
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"✗ 创建测试数据失败: {result.stderr}")
        return False
    
    print("✓ 测试数据创建成功")
    
    # 测试查询
    test_query = """
    WITH category_summary AS (
        SELECT 
            category,
            COUNT(*) as item_count,
            AVG(value) as avg_value,
            MAX(score) as max_score
        FROM test_data 
        WHERE value > 200
        GROUP BY category
    )
    SELECT 
        category,
        item_count,
        ROUND(avg_value, 2) as avg_value,
        max_score
    FROM category_summary
    WHERE item_count > 500
    ORDER BY avg_value DESC;
    """
    
    # 方法1：使用交互式会话测试缓存
    print("\n--- 方法1：交互式会话测试 ---")
    success = test_with_interactive_session(duckdb_path, db_path, test_query)
    
    if success:
        return True
    
    # 方法2：使用单个脚本文件测试
    print("\n--- 方法2：单脚本文件测试 ---")
    return test_with_single_script(duckdb_path, db_path, test_query)

def test_with_interactive_session(duckdb_path, db_path, test_query):
    """使用交互式会话测试缓存"""
    
    # 创建包含多次查询的脚本
    session_commands = f"""
-- 禁用缓存，执行查询3次
SET enable_query_cache = false;
.timer on
{test_query}
{test_query}
{test_query}

-- 启用缓存，执行查询5次
SET enable_query_cache = true;
{test_query}
{test_query}
{test_query}
{test_query}
{test_query}
"""
    
    # 创建临时脚本文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        f.write(session_commands)
        script_path = f.name
    
    try:
        print("执行交互式会话测试...")
        start_time = time.time()
        
        # 执行脚本
        result = subprocess.run([
            duckdb_path, str(db_path), "-init", script_path
        ], capture_output=True, text=True, timeout=60)
        
        total_time = time.time() - start_time
        
        if result.returncode == 0:
            print(f"✓ 交互式会话测试完成，总耗时: {total_time:.2f}秒")
            
            # 分析输出中的时间信息
            output_lines = result.stdout.split('\n')
            times = []
            
            for line in output_lines:
                if 'Run Time' in line or 'time:' in line.lower():
                    print(f"  时间信息: {line.strip()}")
                    # 尝试提取时间数值
                    import re
                    time_match = re.search(r'(\d+\.?\d*)\s*ms', line)
                    if time_match:
                        times.append(float(time_match.group(1)))
            
            if len(times) >= 6:  # 至少有6次执行的时间
                no_cache_times = times[:3]
                cache_times = times[3:6]
                
                avg_no_cache = sum(no_cache_times) / len(no_cache_times)
                avg_cache = sum(cache_times) / len(cache_times)
                
                print(f"\n=== 性能分析 ===")
                print(f"无缓存平均时间: {avg_no_cache:.2f}ms")
                print(f"缓存平均时间: {avg_cache:.2f}ms")
                
                if avg_cache < avg_no_cache:
                    improvement = (avg_no_cache - avg_cache) / avg_no_cache * 100
                    print(f"✓ 缓存生效！性能提升: {improvement:.2f}%")
                    return True
                else:
                    print("⚠️ 缓存效果不明显")
            
            return False
        else:
            print(f"✗ 交互式会话测试失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"✗ 交互式会话测试异常: {e}")
        return False
    finally:
        # 清理临时文件
        try:
            os.unlink(script_path)
        except:
            pass

def test_with_single_script(duckdb_path, db_path, test_query):
    """使用单个脚本文件测试缓存"""
    
    print("创建单脚本测试...")
    
    # 创建测试脚本，在同一个会话中执行多次查询
    script_content = f"""
-- 测试脚本：在同一会话中测试缓存效果
.echo on
.timer on

-- 第一阶段：禁用缓存
.print "=== 禁用缓存测试 ==="
SET enable_query_cache = false;

.print "第1次执行（无缓存）"
{test_query}

.print "第2次执行（无缓存）"
{test_query}

.print "第3次执行（无缓存）"
{test_query}

-- 第二阶段：启用缓存
.print "=== 启用缓存测试 ==="
SET enable_query_cache = true;

.print "第1次执行（缓存，首次）"
{test_query}

.print "第2次执行（缓存，应该命中）"
{test_query}

.print "第3次执行（缓存，应该命中）"
{test_query}

.print "第4次执行（缓存，应该命中）"
{test_query}

.print "测试完成"
"""
    
    # 写入临时脚本文件
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
        f.write(script_content)
        script_path = f.name
    
    try:
        print("执行单脚本测试...")
        
        # 执行脚本
        result = subprocess.run([
            duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
        ], capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            print("✓ 单脚本测试执行成功")
            
            # 显示输出
            print("\n=== 测试输出 ===")
            output_lines = result.stdout.split('\n')
            
            for line in output_lines:
                if any(keyword in line for keyword in ['Run Time', 'time:', '第', '次执行', '缓存']):
                    print(line)
            
            # 简单分析：查找时间模式
            import re
            times = []
            current_phase = "unknown"
            
            for line in output_lines:
                if "禁用缓存" in line:
                    current_phase = "no_cache"
                elif "启用缓存" in line:
                    current_phase = "cache"
                elif "Run Time" in line:
                    time_match = re.search(r'(\d+\.?\d*)\s*ms', line)
                    if time_match:
                        exec_time = float(time_match.group(1))
                        times.append((current_phase, exec_time))
                        print(f"  检测到执行时间: {exec_time}ms ({current_phase})")
            
            # 分析结果
            if len(times) >= 4:
                no_cache_times = [t[1] for t in times if t[0] == "no_cache"]
                cache_times = [t[1] for t in times if t[0] == "cache"]
                
                if no_cache_times and cache_times:
                    avg_no_cache = sum(no_cache_times) / len(no_cache_times)
                    avg_cache = sum(cache_times) / len(cache_times)
                    
                    print(f"\n=== 最终分析 ===")
                    print(f"无缓存执行次数: {len(no_cache_times)}")
                    print(f"缓存执行次数: {len(cache_times)}")
                    print(f"无缓存平均时间: {avg_no_cache:.2f}ms")
                    print(f"缓存平均时间: {avg_cache:.2f}ms")
                    
                    if avg_cache < avg_no_cache:
                        improvement = (avg_no_cache - avg_cache) / avg_no_cache * 100
                        print(f"✓ 缓存生效！性能提升: {improvement:.2f}%")
                        return True
                    else:
                        print("⚠️ 缓存效果不明显或未生效")
                        
                        # 提供更多诊断信息
                        if abs(avg_cache - avg_no_cache) < 1.0:
                            print("💡 提示: 查询执行时间很短，缓存效果可能不明显")
                        else:
                            print("💡 提示: 可能需要更复杂的查询来观察缓存效果")
            
            return False
        else:
            print(f"✗ 单脚本测试失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"✗ 单脚本测试异常: {e}")
        return False
    finally:
        # 清理临时文件
        try:
            os.unlink(script_path)
        except:
            pass

def test_cache_with_different_queries(duckdb_path, db_path):
    """使用不同复杂度的查询测试缓存"""
    print("\n=== 不同复杂度查询缓存测试 ===")
    
    queries = [
        {
            'name': '简单聚合查询',
            'sql': 'SELECT category, COUNT(*) FROM test_data GROUP BY category ORDER BY category;'
        },
        {
            'name': '复杂分析查询',
            'sql': '''
            WITH ranked_data AS (
                SELECT 
                    category,
                    value,
                    score,
                    ROW_NUMBER() OVER (PARTITION BY category ORDER BY value DESC) as rank
                FROM test_data
                WHERE value > 100
            ),
            category_stats AS (
                SELECT 
                    category,
                    COUNT(*) as total_items,
                    AVG(value) as avg_value,
                    STDDEV(value) as std_value,
                    MAX(score) as max_score
                FROM ranked_data
                WHERE rank <= 100
                GROUP BY category
            )
            SELECT 
                category,
                total_items,
                ROUND(avg_value, 2) as avg_value,
                ROUND(std_value, 2) as std_value,
                max_score
            FROM category_stats
            ORDER BY avg_value DESC;
            '''
        }
    ]
    
    for query_info in queries:
        print(f"\n--- 测试: {query_info['name']} ---")
        
        # 创建测试脚本
        script_content = f"""
.timer on
SET enable_query_cache = false;
{query_info['sql']}
{query_info['sql']}

SET enable_query_cache = true;
{query_info['sql']}
{query_info['sql']}
{query_info['sql']}
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as f:
            f.write(script_content)
            script_path = f.name
        
        try:
            result = subprocess.run([
                duckdb_path, str(db_path), "-init", script_path, "-c", ".quit"
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print(f"✓ {query_info['name']} 测试完成")
                
                # 查找时间信息
                import re
                times = []
                for line in result.stdout.split('\n'):
                    if 'Run Time' in line:
                        time_match = re.search(r'(\d+\.?\d*)\s*ms', line)
                        if time_match:
                            times.append(float(time_match.group(1)))
                
                if len(times) >= 4:
                    no_cache_avg = sum(times[:2]) / 2
                    cache_avg = sum(times[2:]) / len(times[2:])
                    
                    print(f"  无缓存平均: {no_cache_avg:.2f}ms")
                    print(f"  缓存平均: {cache_avg:.2f}ms")
                    
                    if cache_avg < no_cache_avg:
                        improvement = (no_cache_avg - cache_avg) / no_cache_avg * 100
                        print(f"  ✓ 性能提升: {improvement:.2f}%")
                    else:
                        print(f"  ⚠️ 无明显提升")
            else:
                print(f"✗ {query_info['name']} 测试失败: {result.stderr}")
                
        except Exception as e:
            print(f"✗ {query_info['name']} 测试异常: {e}")
        finally:
            try:
                os.unlink(script_path)
            except:
                pass

def main():
    """主函数"""
    if len(sys.argv) != 2:
        print("Usage: python fixed_cache_test.py <duckdb_path>")
        print("Example: python fixed_cache_test.py /Users/max/src/duckdb/build/release/duckdb")
        sys.exit(1)
    
    duckdb_path = sys.argv[1]
    
    # 检查DuckDB可执行文件
    if not os.path.exists(duckdb_path):
        print(f"错误: DuckDB可执行文件不存在: {duckdb_path}")
        sys.exit(1)
    
    print("修复版DuckDB缓存测试")
    print(f"DuckDB路径: {duckdb_path}")
    print(f"测试时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # 测试数据库路径
    db_path = Path("fixed_cache_test.db")
    
    try:
        # 删除旧的测试数据库
        if db_path.exists():
            db_path.unlink()
        
        # 运行主要缓存测试
        success = run_cache_comparison_test(duckdb_path, db_path)
        
        # 运行不同查询的缓存测试
        test_cache_with_different_queries(duckdb_path, db_path)
        
        print("\n" + "=" * 60)
        print("=== 测试总结 ===")
        
        if success:
            print("🎉 缓存功能正常工作！")
            print("✓ 在同一会话中，重复查询显示出缓存效果")
        else:
            print("⚠️ 缓存效果不明显")
            print("💡 可能的原因:")
            print("   1. 查询执行时间太短，缓存开销大于收益")
            print("   2. 数据集太小，I/O不是瓶颈")
            print("   3. 需要更复杂的查询来体现缓存价值")
        
        print("\n🔧 建议:")
        print("   1. 使用更大的数据集进行测试")
        print("   2. 使用更复杂的查询（多表连接、复杂聚合等）")
        print("   3. 在生产环境中测试真实工作负载")
        
        # 清理测试数据库
        if db_path.exists():
            db_path.unlink()
            print(f"\n🧹 已清理测试数据库: {db_path}")
        
    except KeyboardInterrupt:
        print("\n测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n测试过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()