#include "duckdb.hpp"
#include <iostream>
#include <chrono>

using namespace duckdb;
using namespace std;

int main() {
    try {
        // 创建数据库连接
        DuckDB db(nullptr);
        Connection con(db);
        
        // 启用查询缓存
        con.Query("SET enable_query_cache=true");
        con.Query("SET query_cache_max_size=100MB");
        
        // 创建测试表
        con.Query("CREATE TABLE test_table AS SELECT i, i*2 as doubled FROM range(1000000) t(i)");
        
        cout << "=== 查询缓存测试 ===" << endl;
        
        // 第一次执行查询（应该执行实际查询并缓存结果）
        auto start1 = chrono::high_resolution_clock::now();
        auto result1 = con.Query("SELECT COUNT(*), SUM(doubled) FROM test_table WHERE i > 500000");
        auto end1 = chrono::high_resolution_clock::now();
        auto duration1 = chrono::duration_cast<chrono::milliseconds>(end1 - start1);
        
        cout << "第一次查询结果: ";
        result1->Print();
        cout << "第一次查询耗时: " << duration1.count() << " ms" << endl;
        
        // 第二次执行相同查询（应该从缓存返回）
        auto start2 = chrono::high_resolution_clock::now();
        auto result2 = con.Query("SELECT COUNT(*), SUM(doubled) FROM test_table WHERE i > 500000");
        auto end2 = chrono::high_resolution_clock::now();
        auto duration2 = chrono::duration_cast<chrono::milliseconds>(end2 - start2);
        
        cout << "第二次查询结果: ";
        result2->Print();
        cout << "第二次查询耗时: " << duration2.count() << " ms" << endl;
        
        // 检查缓存统计
        auto cache_stats = con.Query("SELECT * FROM duckdb_cache_stats()");
        cout << "缓存统计: ";
        cache_stats->Print();
        
        // 验证结果是否一致
        if (result1->ToString() == result2->ToString()) {
            cout << "✓ 查询结果一致" << endl;
        } else {
            cout << "✗ 查询结果不一致" << endl;
        }
        
        // 检查性能提升
        if (duration2.count() < duration1.count()) {
            cout << "✓ 缓存查询更快 (提升 " << (duration1.count() - duration2.count()) << " ms)" << endl;
        } else {
            cout << "? 缓存查询未显示性能提升" << endl;
        }
        
    } catch (const std::exception& e) {
        cout << "错误: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}