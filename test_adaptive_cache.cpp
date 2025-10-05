#include "duckdb/main/query_cache.hpp"
#include <iostream>
#include <thread>
#include <chrono>
#include <random>
#include <iomanip>
#include <functional>

using namespace duckdb;
using namespace std;

// 简化的模拟查询结果生成（仅用于测试）
unique_ptr<MaterializedQueryResult> CreateMockResult(const string& query, idx_t row_count = 100) {
    // 这里返回nullptr，因为我们主要测试自适应机制，不需要真实的查询结果
    // 在实际应用中，这里会返回真实的查询结果
    return nullptr;
}

// 生成ML特征
MLCacheFeatures GenerateMLFeatures(const string& query, double execution_time = 0.0) {
    MLCacheFeatures features;
    
    // 基于查询字符串生成特征
    features.query_complexity_score = static_cast<double>(query.length()) / 1000.0;
    features.execution_time_ms = execution_time > 0 ? execution_time : 50.0 + (rand() % 200);
    features.result_size_bytes = 1000.0 + (rand() % 10000);
    features.access_frequency = 1.0;
    features.temporal_locality = 1.0;
    features.table_count = 1 + (rand() % 3);
    features.join_count = rand() % 2;
    features.has_aggregation = (rand() % 2) == 1;
    features.has_subquery = (rand() % 3) == 1;
    
    return features;
}

// 模拟系统指标变化
SystemPerformanceMetrics GenerateSystemMetrics(int scenario) {
    SystemPerformanceMetrics metrics;
    
    switch (scenario) {
        case 0: // 正常负载
            metrics.cpu_usage_percent = 40.0 + (rand() % 20);
            metrics.memory_usage_percent = 50.0 + (rand() % 20);
            metrics.cache_hit_rate = 0.7 + (rand() % 20) / 100.0;
            metrics.avg_query_time_ms = 80.0 + (rand() % 40);
            break;
        case 1: // 高负载
            metrics.cpu_usage_percent = 80.0 + (rand() % 15);
            metrics.memory_usage_percent = 85.0 + (rand() % 10);
            metrics.cache_hit_rate = 0.5 + (rand() % 30) / 100.0;
            metrics.avg_query_time_ms = 200.0 + (rand() % 100);
            break;
        case 2: // 低负载
            metrics.cpu_usage_percent = 20.0 + (rand() % 20);
            metrics.memory_usage_percent = 30.0 + (rand() % 20);
            metrics.cache_hit_rate = 0.9 + (rand() % 10) / 100.0;
            metrics.avg_query_time_ms = 30.0 + (rand() % 20);
            break;
        case 3: // 变化负载
            metrics.cpu_usage_percent = 30.0 + (rand() % 60);
            metrics.memory_usage_percent = 40.0 + (rand() % 50);
            metrics.cache_hit_rate = 0.3 + (rand() % 60) / 100.0;
            metrics.avg_query_time_ms = 50.0 + (rand() % 200);
            break;
    }
    
    metrics.cache_memory_usage_mb = 50.0 + (rand() % 100);
    metrics.concurrent_queries = 5 + (rand() % 20);
    metrics.disk_io_rate_mbps = 10.0 + (rand() % 40);
    metrics.timestamp = std::chrono::steady_clock::now();
    
    return metrics;
}

void PrintCacheStats(const QueryCache& cache) {
    auto stats = cache.GetStats();
    auto adaptive_stats = cache.GetAdaptiveTuningStats();
    
    cout << "=== Cache Statistics ===" << endl;
    cout << "Total Entries: " << stats.total_entries << endl;
    cout << "Hit Rate: " << fixed << setprecision(2) << stats.hit_rate << "%" << endl;
    cout << "Memory Usage: " << (stats.memory_usage_bytes / (1024*1024)) << " MB" << endl;
    cout << "TTL Evictions: " << stats.ttl_evictions << endl;
    cout << "LRU Evictions: " << stats.lru_evictions << endl;
    cout << "ML Evictions: " << stats.ml_evictions << endl;
    cout << "Average ML Score: " << fixed << setprecision(3) << stats.avg_ml_score << endl;
    
    cout << "\n=== Adaptive Tuning Statistics ===" << endl;
    cout << "Enabled: " << (adaptive_stats.enabled ? "Yes" : "No") << endl;
    cout << "Total Adjustments: " << adaptive_stats.total_adjustments << endl;
    cout << "Avg Performance Improvement: " << fixed << setprecision(2) 
         << adaptive_stats.avg_performance_improvement << "%" << endl;
    
    cout << "\n=== Current System Metrics ===" << endl;
    cout << "CPU Usage: " << fixed << setprecision(1) << adaptive_stats.current_metrics.cpu_usage_percent << "%" << endl;
    cout << "Memory Usage: " << fixed << setprecision(1) << adaptive_stats.current_metrics.memory_usage_percent << "%" << endl;
    cout << "Cache Hit Rate: " << fixed << setprecision(2) << adaptive_stats.current_metrics.cache_hit_rate * 100.0 << "%" << endl;
    cout << "Avg Query Time: " << fixed << setprecision(1) << adaptive_stats.current_metrics.avg_query_time_ms << " ms" << endl;
    cout << "Concurrent Queries: " << adaptive_stats.current_metrics.concurrent_queries << endl;
    cout << endl;
}

int main() {
    cout << "=== DuckDB Adaptive Cache Testing ===" << endl;
    
    // 配置缓存
    QueryCacheConfig config;
    config.enabled = true;
    config.max_entries = 100;
    config.max_memory_bytes = 50 * 1024 * 1024; // 50MB
    config.ttl_seconds = 300; // 5分钟
    config.eviction_strategy = CacheEvictionStrategy::TTL_BASED;
    
    // 配置自适应调优
    AdaptiveTuningConfig adaptive_config;
    adaptive_config.enabled = true;
    adaptive_config.tuning_interval_ms = 5000; // 5秒调优间隔
    adaptive_config.adapt_cache_size = true;
    adaptive_config.adapt_memory_limit = true;
    adaptive_config.adapt_ttl = true;
    adaptive_config.adapt_eviction_strategy = true;
    
    config.adaptive_tuning_config = adaptive_config;
    
    // 创建缓存实例
    QueryCache cache(config);
    
    // 启用自适应调优
    cache.EnableAdaptiveTuning(true, adaptive_config);
    
    cout << "Cache initialized with adaptive tuning enabled" << endl;
    PrintCacheStats(cache);
    
    // 模拟不同的工作负载场景
    vector<string> scenarios = {"Normal Load", "High Load", "Low Load", "Variable Load"};
    
    for (int scenario = 0; scenario < 4; scenario++) {
        cout << "\n" << string(60, '=') << endl;
        cout << "Testing Scenario: " << scenarios[scenario] << endl;
        cout << string(60, '=') << endl;
        
        // 生成查询并缓存结果
        for (int i = 0; i < 20; i++) {
            string query = "SELECT * FROM table" + to_string(i % 5) + " WHERE id > " + to_string(i * 10);
            string query_hash = to_string(hash<string>{}(query));
            
            // 检查缓存
            auto cached_result = cache.GetCachedResult(query_hash);
            if (!cached_result) {
                // 模拟查询执行和特征生成
                auto features = GenerateMLFeatures(query);
                
                // 注意：这里我们跳过实际的缓存结果存储，因为需要真实的MaterializedQueryResult
                // 在实际应用中，这里会缓存真实的查询结果
                printf("DEBUG: Would cache query: %s\n", query.substr(0, 50).c_str());
            }
            
            // 模拟系统指标变化
            auto metrics = GenerateSystemMetrics(scenario);
            cache.UpdateSystemMetrics(metrics);
            
            // 每5个查询后强制执行一次自适应调优
            if ((i + 1) % 5 == 0) {
                cout << "\nForcing adaptive tuning cycle..." << endl;
                bool tuning_applied = cache.ForceAdaptiveTuning();
                cout << "Tuning applied: " << (tuning_applied ? "Yes" : "No") << endl;
                PrintCacheStats(cache);
            }
            
            // 短暂延迟模拟真实场景
            this_thread::sleep_for(chrono::milliseconds(100));
        }
        
        cout << "\nFinal statistics for " << scenarios[scenario] << ":" << endl;
        PrintCacheStats(cache);
        
        // 场景间的延迟
        this_thread::sleep_for(chrono::seconds(1));
    }
    
    cout << "\n" << string(60, '=') << endl;
    cout << "Adaptive Cache Testing Completed" << endl;
    cout << string(60, '=') << endl;
    
    // 最终统计
    PrintCacheStats(cache);
    
    // 测试缓存解释功能
    cout << "\n=== Cache Explain Information ===" << endl;
    auto explain_info = cache.GetExplainInfo();
    string explain_text = cache.FormatExplainInfo(explain_info, ExplainFormat::TEXT);
    cout << explain_text << endl;
    
    return 0;
}