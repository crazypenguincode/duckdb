//===----------------------------------------------------------------------===//
//                         DuckDB
//
// test_cache_strategies.cpp
//
// Test file for evaluating different cache eviction strategies
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/database.hpp"
#include "duckdb/common/types/column/column_data_collection.hpp"
#include <iostream>
#include <chrono>
#include <random>
#include <vector>
#include <string>
#include <fstream>

using namespace duckdb;
using namespace std;

// Test workload generator
class CacheTestWorkload {
public:
    struct QueryPattern {
        string query;
        double frequency;  // How often this query appears
        double complexity; // Query complexity score
        idx_t result_size; // Expected result size
        double exec_time;  // Simulated execution time
    };
    
    vector<QueryPattern> patterns;
    mt19937 rng;
    
    CacheTestWorkload() : rng(42) {
        // Generate different query patterns
        GenerateQueryPatterns();
    }
    
    void GenerateQueryPatterns() {
        // High frequency, simple queries
        patterns.push_back({"SELECT * FROM users WHERE id = ?", 0.3, 0.1, 1024, 10.0});
        patterns.push_back({"SELECT name FROM users WHERE active = true", 0.25, 0.2, 2048, 15.0});
        
        // Medium frequency, medium complexity
        patterns.push_back({"SELECT u.name, p.title FROM users u JOIN posts p ON u.id = p.user_id", 0.2, 0.5, 8192, 50.0});
        patterns.push_back({"SELECT COUNT(*) FROM orders WHERE date > '2023-01-01'", 0.15, 0.3, 512, 25.0});
        
        // Low frequency, complex queries
        patterns.push_back({"WITH cte AS (SELECT user_id, COUNT(*) as cnt FROM orders GROUP BY user_id) SELECT * FROM cte JOIN users ON cte.user_id = users.id", 0.05, 0.8, 16384, 200.0});
        patterns.push_back({"SELECT u.name, SUM(o.amount) FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.name HAVING SUM(o.amount) > 1000", 0.03, 0.7, 4096, 150.0});
        
        // Very rare, very complex queries
        patterns.push_back({"SELECT * FROM (SELECT DISTINCT user_id FROM orders WHERE amount > (SELECT AVG(amount) FROM orders)) t JOIN users u ON t.user_id = u.id", 0.02, 0.9, 32768, 500.0});
    }
    
    QueryPattern GenerateQuery() {
        uniform_real_distribution<double> dist(0.0, 1.0);
        double rand_val = dist(rng);
        
        double cumulative = 0.0;
        for (const auto &pattern : patterns) {
            cumulative += pattern.frequency;
            if (rand_val <= cumulative) {
                return pattern;
            }
        }
        return patterns.back(); // Fallback
    }
};

// Performance metrics collector
struct PerformanceMetrics {
    idx_t total_queries = 0;
    idx_t cache_hits = 0;
    idx_t cache_misses = 0;
    double total_execution_time = 0.0;
    double total_cache_lookup_time = 0.0;
    idx_t total_evictions = 0;
    double memory_usage_mb = 0.0;
    
    double GetHitRate() const {
        return total_queries > 0 ? static_cast<double>(cache_hits) / total_queries : 0.0;
    }
    
    double GetAvgExecutionTime() const {
        return total_queries > 0 ? total_execution_time / total_queries : 0.0;
    }
    
    double GetAvgLookupTime() const {
        return total_queries > 0 ? total_cache_lookup_time / total_queries : 0.0;
    }
};

// Cache strategy tester
class CacheStrategyTester {
private:
    unique_ptr<QueryCache> cache;
    CacheTestWorkload workload;
    PerformanceMetrics metrics;
    
public:
    CacheStrategyTester(CacheEvictionStrategy strategy) {
        QueryCacheConfig config;
        config.max_entries = 100;  // Small cache for testing
        config.max_memory_bytes = 10 * 1024 * 1024; // 10MB
        config.ttl_seconds = 300; // 5 minutes
        config.eviction_strategy = strategy;
        config.enabled = true;
        
        cache = make_uniq<QueryCache>(config);
    }
    
    void RunTest(idx_t num_queries) {
        cout << "Running test with " << num_queries << " queries..." << endl;
        
        for (idx_t i = 0; i < num_queries; i++) {
            auto pattern = workload.GenerateQuery();
            string query_key = "query_" + to_string(i % 1000); // Simulate some repetition
            
            auto start_time = chrono::high_resolution_clock::now();
            
            // Try to get from cache
            auto cached_result = cache->MightBeCached(query_key) ? cache->GetCachedResult(query_key) : nullptr;
            
            auto lookup_end = chrono::high_resolution_clock::now();
            auto lookup_time = chrono::duration<double, milli>(lookup_end - start_time).count();
            
            if (cached_result) {
                // Cache hit
                metrics.cache_hits++;
                metrics.total_execution_time += 1.0; // Minimal time for cached result
            } else {
                // Cache miss - simulate query execution
                metrics.cache_misses++;
                
                // Simulate query execution time
                this_thread::sleep_for(chrono::microseconds(static_cast<int>(pattern.exec_time * 10)));
                metrics.total_execution_time += pattern.exec_time;
                
                // Create mock result and cache it
                auto mock_result = CreateMockResult(pattern);
                MLCacheFeatures features;
                features.query_complexity_score = pattern.complexity;
                features.execution_time_ms = pattern.exec_time;
                features.result_size_bytes = static_cast<double>(pattern.result_size);
                features.access_frequency = pattern.frequency;
                features.temporal_locality = 1.0;
                
                cache->CacheResult(query_key, std::move(mock_result), features);
            }
            
            auto end_time = chrono::high_resolution_clock::now();
            metrics.total_cache_lookup_time += lookup_time;
            metrics.total_queries++;
            
            // Print progress every 1000 queries
            if ((i + 1) % 1000 == 0) {
                cout << "Processed " << (i + 1) << " queries..." << endl;
            }
        }
        
        // Get final cache stats
        auto cache_stats = cache->GetStats();
        metrics.memory_usage_mb = cache_stats.memory_usage_bytes / (1024.0 * 1024.0);
        metrics.total_evictions = cache_stats.ttl_evictions + cache_stats.lru_evictions + cache_stats.ml_evictions;
    }
    
    PerformanceMetrics GetMetrics() const {
        return metrics;
    }
    
    QueryCache::CacheStats GetCacheStats() const {
        return cache->GetStats();
    }
    
private:
    unique_ptr<MaterializedQueryResult> CreateMockResult(const CacheTestWorkload::QueryPattern &pattern) {
        // Create a simple mock result
        vector<LogicalType> types = {LogicalType::INTEGER, LogicalType::VARCHAR};
        vector<string> names = {"id", "name"};
        
        auto collection = make_uniq<ColumnDataCollection>(Allocator::DefaultAllocator(), types);
        
        // Add some mock data based on result size
        idx_t num_rows = pattern.result_size / 64; // Rough estimate
        if (num_rows > 0) {
            DataChunk chunk;
            chunk.Initialize(Allocator::DefaultAllocator(), types);
            
            for (idx_t i = 0; i < std::min(num_rows, static_cast<idx_t>(1000)); i++) {
                chunk.SetCardinality(1);
                chunk.SetValue(0, 0, Value::INTEGER(static_cast<int32_t>(i)));
                chunk.SetValue(1, 0, Value("test_" + to_string(i)));
                
                ColumnDataAppendState append_state;
                collection->InitializeAppend(append_state);
                collection->Append(append_state, chunk);
            }
        }
        
        StatementProperties properties;
        ClientProperties client_props;
        
        return make_uniq<MaterializedQueryResult>(
            StatementType::SELECT_STATEMENT,
            properties,
            names,
            std::move(collection),
            client_props
        );
    }
};

// Test runner and results analyzer
class CacheTestRunner {
public:
    void RunAllTests() {
        cout << "=== Cache Strategy Performance Comparison ===" << endl << endl;
        
        vector<pair<CacheEvictionStrategy, string>> strategies = {
            {CacheEvictionStrategy::TTL_BASED, "TTL-Based"},
            {CacheEvictionStrategy::LRU_BASED, "LRU-Based"},
            {CacheEvictionStrategy::ML_BASED, "ML-Based"}
        };
        
        vector<pair<PerformanceMetrics, QueryCache::CacheStats>> results;
        
        for (const auto &strategy : strategies) {
            cout << "Testing " << strategy.second << " strategy..." << endl;
            
            CacheStrategyTester tester(strategy.first);
            tester.RunTest(10000); // Run 10k queries
            
            auto metrics = tester.GetMetrics();
            auto cache_stats = tester.GetCacheStats();
            
            results.push_back({metrics, cache_stats});
            
            PrintResults(strategy.second, metrics, cache_stats);
            cout << endl;
        }
        
        // Compare results
        CompareResults(strategies, results);
        
        // Save detailed results to file
        SaveResultsToFile(strategies, results);
    }
    
private:
    void PrintResults(const string &strategy_name, const PerformanceMetrics &metrics, 
                     const QueryCache::CacheStats &cache_stats) {
        cout << "--- " << strategy_name << " Results ---" << endl;
        cout << "Total Queries: " << metrics.total_queries << endl;
        cout << "Cache Hits: " << metrics.cache_hits << endl;
        cout << "Cache Misses: " << metrics.cache_misses << endl;
        cout << "Hit Rate: " << (metrics.GetHitRate() * 100.0) << "%" << endl;
        cout << "Avg Execution Time: " << metrics.GetAvgExecutionTime() << " ms" << endl;
        cout << "Avg Lookup Time: " << metrics.GetAvgLookupTime() << " ms" << endl;
        cout << "Memory Usage: " << metrics.memory_usage_mb << " MB" << endl;
        cout << "Total Evictions: " << metrics.total_evictions << endl;
        cout << "TTL Evictions: " << cache_stats.ttl_evictions << endl;
        cout << "LRU Evictions: " << cache_stats.lru_evictions << endl;
        cout << "ML Evictions: " << cache_stats.ml_evictions << endl;
        cout << "Avg ML Score: " << cache_stats.avg_ml_score << endl;
        cout << "False Positive Rate: " << (cache_stats.false_positive_rate * 100.0) << "%" << endl;
    }
    
    void CompareResults(const vector<pair<CacheEvictionStrategy, string>> &strategies,
                       const vector<pair<PerformanceMetrics, QueryCache::CacheStats>> &results) {
        cout << "=== Strategy Comparison ===" << endl;
        cout << "Strategy\t\tHit Rate\tAvg Exec Time\tMemory Usage\tEvictions" << endl;
        cout << "--------\t\t--------\t-------------\t------------\t---------" << endl;
        
        for (size_t i = 0; i < strategies.size(); i++) {
            const auto &metrics = results[i].first;
            cout << strategies[i].second << "\t\t"
                 << (metrics.GetHitRate() * 100.0) << "%\t\t"
                 << metrics.GetAvgExecutionTime() << " ms\t\t"
                 << metrics.memory_usage_mb << " MB\t\t"
                 << metrics.total_evictions << endl;
        }
        
        // Find best strategy for each metric
        cout << endl << "=== Best Strategies ===" << endl;
        
        // Best hit rate
        size_t best_hit_rate_idx = 0;
        for (size_t i = 1; i < results.size(); i++) {
            if (results[i].first.GetHitRate() > results[best_hit_rate_idx].first.GetHitRate()) {
                best_hit_rate_idx = i;
            }
        }
        cout << "Best Hit Rate: " << strategies[best_hit_rate_idx].second 
             << " (" << (results[best_hit_rate_idx].first.GetHitRate() * 100.0) << "%)" << endl;
        
        // Best execution time
        size_t best_exec_time_idx = 0;
        for (size_t i = 1; i < results.size(); i++) {
            if (results[i].first.GetAvgExecutionTime() < results[best_exec_time_idx].first.GetAvgExecutionTime()) {
                best_exec_time_idx = i;
            }
        }
        cout << "Best Avg Execution Time: " << strategies[best_exec_time_idx].second 
             << " (" << results[best_exec_time_idx].first.GetAvgExecutionTime() << " ms)" << endl;
        
        // Least evictions
        size_t least_evictions_idx = 0;
        for (size_t i = 1; i < results.size(); i++) {
            if (results[i].first.total_evictions < results[least_evictions_idx].first.total_evictions) {
                least_evictions_idx = i;
            }
        }
        cout << "Least Evictions: " << strategies[least_evictions_idx].second 
             << " (" << results[least_evictions_idx].first.total_evictions << " evictions)" << endl;
    }
    
    void SaveResultsToFile(const vector<pair<CacheEvictionStrategy, string>> &strategies,
                          const vector<pair<PerformanceMetrics, QueryCache::CacheStats>> &results) {
        ofstream file("cache_strategy_results.csv");
        if (!file.is_open()) {
            cout << "Warning: Could not save results to file" << endl;
            return;
        }
        
        // Write header
        file << "Strategy,Hit_Rate,Avg_Exec_Time_ms,Avg_Lookup_Time_ms,Memory_Usage_MB,Total_Evictions,"
             << "TTL_Evictions,LRU_Evictions,ML_Evictions,Avg_ML_Score,False_Positive_Rate" << endl;
        
        // Write data
        for (size_t i = 0; i < strategies.size(); i++) {
            const auto &metrics = results[i].first;
            const auto &cache_stats = results[i].second;
            
            file << strategies[i].second << ","
                 << metrics.GetHitRate() << ","
                 << metrics.GetAvgExecutionTime() << ","
                 << metrics.GetAvgLookupTime() << ","
                 << metrics.memory_usage_mb << ","
                 << metrics.total_evictions << ","
                 << cache_stats.ttl_evictions << ","
                 << cache_stats.lru_evictions << ","
                 << cache_stats.ml_evictions << ","
                 << cache_stats.avg_ml_score << ","
                 << cache_stats.false_positive_rate << endl;
        }
        
        file.close();
        cout << "Results saved to cache_strategy_results.csv" << endl;
    }
};

int main() {
    try {
        CacheTestRunner runner;
        runner.RunAllTests();
        
        cout << endl << "Cache strategy testing completed successfully!" << endl;
        return 0;
    } catch (const exception &e) {
        cout << "Error during testing: " << e.what() << endl;
        return 1;
    }
}