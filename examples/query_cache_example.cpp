//===----------------------------------------------------------------------===//
//                         DuckDB Query Cache Example
//
// query_cache_example.cpp
//
// This example demonstrates how to use the query cache system with bloom filter
//===----------------------------------------------------------------------===//

#include "duckdb.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/query_cache.hpp"
#include <iostream>
#include <chrono>

using namespace duckdb;
using namespace std;

void PrintCacheStats(const QueryCache::CacheStats &stats) {
    cout << "=== Query Cache Statistics ===" << endl;
    cout << "Total entries: " << stats.total_entries << endl;
    cout << "Total hits: " << stats.total_hits << endl;
    cout << "Total misses: " << stats.total_misses << endl;
    cout << "Hit rate: " << (stats.hit_rate * 100) << "%" << endl;
    cout << "False positive rate: " << (stats.false_positive_rate * 100) << "%" << endl;
    cout << "Memory usage: " << (stats.memory_usage_bytes / 1024.0 / 1024.0) << " MB" << endl;
    cout << "===============================" << endl << endl;
}

void ExecuteAndTime(Connection &conn, const string &query, const string &description) {
    cout << "Executing: " << description << endl;
    cout << "Query: " << query << endl;
    
    auto start = chrono::high_resolution_clock::now();
    auto result = conn.Query(query);
    auto end = chrono::high_resolution_clock::now();
    
    auto duration = chrono::duration_cast<chrono::microseconds>(end - start);
    cout << "Execution time: " << duration.count() << " microseconds" << endl;
    
    if (result->HasError()) {
        cout << "Error: " << result->GetError() << endl;
    } else {
        cout << "Rows returned: " << result->RowCount() << endl;
    }
    cout << endl;
}

int main() {
    try {
        // Create database and connection
        DuckDB db(nullptr);
        Connection conn(db);
        
        // Enable query caching
        conn.context->SetQueryCacheEnabled(true);
        
        cout << "=== DuckDB Query Cache Demo ===" << endl << endl;
        
        // Create a test table with some data
        cout << "Setting up test data..." << endl;
        conn.Query("CREATE TABLE test_table AS SELECT i as id, 'value_' || i as name FROM range(1000000) t(i)");
        cout << "Created test table with 1M rows" << endl << endl;
        
        // Test 1: Execute a SELECT query multiple times
        string test_query1 = "SELECT COUNT(*) as total_count FROM test_table WHERE id % 100 = 0";
        
        ExecuteAndTime(conn, test_query1, "First execution (cache miss)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        ExecuteAndTime(conn, test_query1, "Second execution (cache hit)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        ExecuteAndTime(conn, test_query1, "Third execution (cache hit)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 2: Execute a different query
        string test_query2 = "SELECT AVG(id) as avg_id FROM test_table WHERE id < 50000";
        
        ExecuteAndTime(conn, test_query2, "Different query (cache miss)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        ExecuteAndTime(conn, test_query2, "Same different query (cache hit)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 3: Test with CTE (Common Table Expression)
        string cte_query = R"(
            WITH ranked_data AS (
                SELECT id, name, ROW_NUMBER() OVER (ORDER BY id) as rn
                FROM test_table 
                WHERE id BETWEEN 1000 AND 2000
            )
            SELECT COUNT(*) as cte_count FROM ranked_data WHERE rn <= 100
        )";
        
        ExecuteAndTime(conn, cte_query, "CTE query (cache miss)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        ExecuteAndTime(conn, cte_query, "CTE query repeated (cache hit)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 4: Test with subquery
        string subquery = R"(
            SELECT COUNT(*) as subquery_count 
            FROM (
                SELECT id FROM test_table 
                WHERE id IN (SELECT id FROM test_table WHERE id % 1000 = 0)
            ) sub
        )";
        
        ExecuteAndTime(conn, subquery, "Subquery (cache miss)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        ExecuteAndTime(conn, subquery, "Subquery repeated (cache hit)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 5: Test non-cacheable queries (INSERT, UPDATE, DELETE)
        cout << "Testing non-cacheable queries..." << endl;
        
        auto insert_result = conn.Query("INSERT INTO test_table VALUES (2000000, 'new_value')");
        cout << "INSERT query executed (not cached)" << endl;
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 6: Clear cache and verify
        cout << "Clearing cache..." << endl;
        conn.context->ClearQueryCache();
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 7: Execute cached query again after clearing
        ExecuteAndTime(conn, test_query1, "Query after cache clear (cache miss)");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        // Test 8: Disable caching and test
        cout << "Disabling query cache..." << endl;
        conn.context->SetQueryCacheEnabled(false);
        
        ExecuteAndTime(conn, test_query1, "Query with caching disabled");
        PrintCacheStats(conn.context->GetQueryCacheStats());
        
        cout << "=== Demo completed successfully ===" << endl;
        
    } catch (const std::exception &e) {
        cout << "Error: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}