//===----------------------------------------------------------------------===//
//                         DuckDB Query Cache Tests
//
// test_query_cache.cpp
//
// Basic tests for the query cache functionality
//===----------------------------------------------------------------------===//

#include "duckdb.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/query_cache.hpp"
#include <cassert>
#include <iostream>

using namespace duckdb;
using namespace std;

void test_bloom_filter() {
    cout << "Testing BloomFilter..." << endl;
    
    BloomFilter bf(1000, 3);
    
    // Test basic functionality
    bf.Add("test_query_1");
    bf.Add("test_query_2");
    
    assert(bf.MightContain("test_query_1"));
    assert(bf.MightContain("test_query_2"));
    assert(!bf.MightContain("test_query_3")); // Should be false (no false negatives)
    
    // Test clear
    bf.Clear();
    assert(!bf.MightContain("test_query_1"));
    
    cout << "BloomFilter tests passed!" << endl;
}

void test_query_cache_key_generator() {
    cout << "Testing QueryCacheKeyGenerator..." << endl;
    
    // Test query normalization
    string key1 = QueryCacheKeyGenerator::GenerateKey("SELECT * FROM table");
    string key2 = QueryCacheKeyGenerator::GenerateKey("select * from table");
    string key3 = QueryCacheKeyGenerator::GenerateKey("SELECT  *  FROM  table");
    
    assert(key1 == key2);
    assert(key1 == key3);
    
    // Test different queries produce different keys
    string key4 = QueryCacheKeyGenerator::GenerateKey("SELECT COUNT(*) FROM table");
    assert(key1 != key4);
    
    cout << "QueryCacheKeyGenerator tests passed!" << endl;
}

void test_query_cache() {
    cout << "Testing QueryCache..." << endl;
    
    QueryCache cache;
    
    // Test basic cache operations
    string test_key = "test_query_hash";
    
    // Should not be cached initially
    assert(!cache.MightBeCached(test_key));
    assert(cache.GetCachedResult(test_key) == nullptr);
    
    // Create a dummy result to cache
    vector<string> names = {"col1"};
    vector<LogicalType> types = {LogicalType::INTEGER};
    StatementProperties properties;
    auto result = make_uniq<MaterializedQueryResult>(names, types, properties);
    
    // Cache the result
    cache.CacheResult(test_key, std::move(result));
    
    // Should now be cached
    assert(cache.MightBeCached(test_key));
    auto cached_result = cache.GetCachedResult(test_key);
    assert(cached_result != nullptr);
    
    // Test cache stats
    auto stats = cache.GetStats();
    assert(stats.total_entries == 1);
    assert(stats.total_hits == 1);
    assert(stats.total_misses == 1); // From the initial GetCachedResult call
    
    // Test cache clear
    cache.Clear();
    assert(!cache.MightBeCached(test_key));
    
    cout << "QueryCache tests passed!" << endl;
}

void test_client_context_integration() {
    cout << "Testing ClientContext integration..." << endl;
    
    try {
        DuckDB db(nullptr);
        Connection conn(db);
        
        // Test cache enable/disable
        conn.context->SetQueryCacheEnabled(true);
        assert(conn.context->GetQueryCache().IsEnabled());
        
        conn.context->SetQueryCacheEnabled(false);
        assert(!conn.context->GetQueryCache().IsEnabled());
        
        // Re-enable for further tests
        conn.context->SetQueryCacheEnabled(true);
        
        // Create test table
        conn.Query("CREATE TABLE test_cache AS SELECT i as id FROM range(100) t(i)");
        
        // Execute query multiple times
        auto result1 = conn.Query("SELECT COUNT(*) FROM test_cache");
        auto result2 = conn.Query("SELECT COUNT(*) FROM test_cache");
        
        assert(!result1->HasError());
        assert(!result2->HasError());
        
        // Check cache stats
        auto stats = conn.context->GetQueryCacheStats();
        cout << "Cache hits: " << stats.total_hits << endl;
        cout << "Cache misses: " << stats.total_misses << endl;
        
        // Test cache clear
        conn.context->ClearQueryCache();
        auto stats_after_clear = conn.context->GetQueryCacheStats();
        assert(stats_after_clear.total_entries == 0);
        
        cout << "ClientContext integration tests passed!" << endl;
        
    } catch (const exception &e) {
        cout << "Error in ClientContext integration test: " << e.what() << endl;
        throw;
    }
}

void test_cte_and_subquery_caching() {
    cout << "Testing CTE and subquery caching..." << endl;
    
    try {
        DuckDB db(nullptr);
        Connection conn(db);
        
        conn.context->SetQueryCacheEnabled(true);
        
        // Create test table
        conn.Query("CREATE TABLE test_complex AS SELECT i as id, 'value_' || i as name FROM range(1000) t(i)");
        
        // Test CTE query
        string cte_query = R"(
            WITH ranked_data AS (
                SELECT id, name, ROW_NUMBER() OVER (ORDER BY id) as rn
                FROM test_complex 
                WHERE id < 100
            )
            SELECT COUNT(*) FROM ranked_data WHERE rn <= 50
        )";
        
        auto result1 = conn.Query(cte_query);
        auto result2 = conn.Query(cte_query);
        
        assert(!result1->HasError());
        assert(!result2->HasError());
        
        // Test subquery
        string subquery = R"(
            SELECT COUNT(*) 
            FROM (
                SELECT id FROM test_complex 
                WHERE id IN (SELECT id FROM test_complex WHERE id % 10 = 0)
            ) sub
        )";
        
        auto result3 = conn.Query(subquery);
        auto result4 = conn.Query(subquery);
        
        assert(!result3->HasError());
        assert(!result4->HasError());
        
        auto stats = conn.context->GetQueryCacheStats();
        cout << "Complex query cache stats - Hits: " << stats.total_hits 
             << ", Misses: " << stats.total_misses << endl;
        
        cout << "CTE and subquery caching tests passed!" << endl;
        
    } catch (const exception &e) {
        cout << "Error in CTE/subquery test: " << e.what() << endl;
        throw;
    }
}

int main() {
    try {
        cout << "=== Running Query Cache Tests ===" << endl << endl;
        
        test_bloom_filter();
        cout << endl;
        
        test_query_cache_key_generator();
        cout << endl;
        
        test_query_cache();
        cout << endl;
        
        test_client_context_integration();
        cout << endl;
        
        test_cte_and_subquery_caching();
        cout << endl;
        
        cout << "=== All tests passed! ===" << endl;
        
    } catch (const exception &e) {
        cout << "Test failed with error: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}