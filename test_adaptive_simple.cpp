#include <iostream>
#include <thread>
#include <chrono>
#include <random>
#include <iomanip>
#include <functional>
#include <deque>
#include <vector>
#include <string>
#include <algorithm>

// 简化的测试程序，专注于自适应机制测试
using namespace std;

// 模拟的基本类型定义
using idx_t = unsigned long long;

// 模拟的系统性能指标
struct SystemPerformanceMetrics {
    double cpu_usage_percent = 0.0;
    double memory_usage_percent = 0.0;
    double cache_hit_rate = 0.0;
    double avg_query_time_ms = 0.0;
    double cache_memory_usage_mb = 0.0;
    idx_t concurrent_queries = 0;
    double disk_io_rate_mbps = 0.0;
    chrono::steady_clock::time_point timestamp;
    
    SystemPerformanceMetrics() : timestamp(chrono::steady_clock::now()) {}
};

// 模拟的缓存淘汰策略
enum class CacheEvictionStrategy {
    TTL_BASED,
    LRU_BASED,
    ML_BASED
};

// 模拟的缓存配置
struct QueryCacheConfig {
    idx_t max_entries = 1000;
    idx_t max_memory_bytes = 100 * 1024 * 1024;
    idx_t ttl_seconds = 3600;
    CacheEvictionStrategy eviction_strategy = CacheEvictionStrategy::TTL_BASED;
};

// 模拟的自适应调优配置
struct AdaptiveTuningConfig {
    bool enabled = true;
    idx_t tuning_interval_ms = 30000;
    idx_t metrics_history_size = 100;
    double learning_rate = 0.1;
    double performance_threshold = 0.05;
    
    idx_t min_cache_size = 100;
    idx_t max_cache_size = 10000;
    idx_t min_memory_mb = 10;
    idx_t max_memory_mb = 1000;
    idx_t min_ttl_seconds = 300;
    idx_t max_ttl_seconds = 7200;
    
    bool adapt_cache_size = true;
    bool adapt_memory_limit = true;
    bool adapt_ttl = true;
    bool adapt_eviction_strategy = true;
};

// 简化的自适应参数调优器
class AdaptiveParameterTuner {
public:
    struct TuningStats {
        idx_t total_adjustments = 0;
        idx_t cache_size_adjustments = 0;
        idx_t memory_limit_adjustments = 0;
        idx_t ttl_adjustments = 0;
        idx_t strategy_changes = 0;
        double avg_performance_improvement = 0.0;
        chrono::steady_clock::time_point last_tuning_time;
    };

private:
    AdaptiveTuningConfig config;
    TuningStats tuning_stats;
    deque<SystemPerformanceMetrics> metrics_history;
    
    struct PerformanceModel {
        double cache_size_weight = 0.3;
        double memory_weight = 0.25;
        double ttl_weight = 0.2;
        double hit_rate_weight = 0.25;
        double bias = 0.0;
    } performance_model;

public:
    explicit AdaptiveParameterTuner(AdaptiveTuningConfig config = AdaptiveTuningConfig()) 
        : config(config) {
        tuning_stats.last_tuning_time = chrono::steady_clock::now();
        cout << "AdaptiveParameterTuner initialized with interval=" << config.tuning_interval_ms << " ms" << endl;
    }
    
    void UpdateMetrics(const SystemPerformanceMetrics &metrics, QueryCacheConfig &cache_config) {
        metrics_history.push_back(metrics);
        
        while (metrics_history.size() > config.metrics_history_size) {
            metrics_history.pop_front();
        }
        
        cout << "UpdateMetrics - hit_rate=" << fixed << setprecision(2) << metrics.cache_hit_rate * 100.0 
             << "%, memory_usage=" << setprecision(1) << metrics.cache_memory_usage_mb 
             << "MB, cpu_usage=" << setprecision(1) << metrics.cpu_usage_percent << "%" << endl;
        
        if (ShouldTune()) {
            cout << "Triggering adaptive tuning cycle" << endl;
            
            double baseline_performance = CalculatePerformanceScore(metrics);
            bool any_adjustment = false;
            
            if (config.adapt_cache_size && AdaptCacheSize(cache_config, metrics)) {
                tuning_stats.cache_size_adjustments++;
                any_adjustment = true;
            }
            
            if (config.adapt_memory_limit && AdaptMemoryLimit(cache_config, metrics)) {
                tuning_stats.memory_limit_adjustments++;
                any_adjustment = true;
            }
            
            if (config.adapt_ttl && AdaptTTL(cache_config, metrics)) {
                tuning_stats.ttl_adjustments++;
                any_adjustment = true;
            }
            
            if (config.adapt_eviction_strategy && AdaptEvictionStrategy(cache_config, metrics)) {
                tuning_stats.strategy_changes++;
                any_adjustment = true;
            }
            
            if (any_adjustment) {
                tuning_stats.total_adjustments++;
                tuning_stats.last_tuning_time = chrono::steady_clock::now();
                UpdatePerformanceModel(metrics, baseline_performance);
                cout << "Adaptive tuning completed - total_adjustments=" << tuning_stats.total_adjustments << endl;
            }
        }
    }
    
    TuningStats GetTuningStats() const { return tuning_stats; }
    
    bool ForceTuning(QueryCacheConfig &cache_config) {
        if (metrics_history.empty()) {
            cout << "ForceTuning - no metrics history available" << endl;
            return false;
        }
        
        cout << "ForceTuning triggered" << endl;
        const auto &latest_metrics = metrics_history.back();
        
        bool any_adjustment = false;
        
        if (AdaptCacheSize(cache_config, latest_metrics)) {
            tuning_stats.cache_size_adjustments++;
            any_adjustment = true;
        }
        
        if (AdaptMemoryLimit(cache_config, latest_metrics)) {
            tuning_stats.memory_limit_adjustments++;
            any_adjustment = true;
        }
        
        if (AdaptTTL(cache_config, latest_metrics)) {
            tuning_stats.ttl_adjustments++;
            any_adjustment = true;
        }
        
        if (AdaptEvictionStrategy(cache_config, latest_metrics)) {
            tuning_stats.strategy_changes++;
            any_adjustment = true;
        }
        
        if (any_adjustment) {
            tuning_stats.total_adjustments++;
            tuning_stats.last_tuning_time = chrono::steady_clock::now();
            cout << "ForceTuning completed with adjustments" << endl;
        }
        
        return any_adjustment;
    }

private:
    bool ShouldTune() const {
        auto now = chrono::steady_clock::now();
        auto time_since_last_tuning = chrono::duration_cast<chrono::milliseconds>(
            now - tuning_stats.last_tuning_time).count();
        return time_since_last_tuning >= static_cast<long>(config.tuning_interval_ms);
    }
    
    double CalculatePerformanceScore(const SystemPerformanceMetrics &metrics) const {
        double score = 0.0;
        score += 0.4 * metrics.cache_hit_rate;
        double normalized_query_time = max(0.0, 1.0 - metrics.avg_query_time_ms / 10000.0);
        score += 0.3 * normalized_query_time;
        double cpu_efficiency = 1.0 - abs(metrics.cpu_usage_percent - 70.0) / 100.0;
        score += 0.2 * max(0.0, cpu_efficiency);
        double memory_efficiency = 1.0 - metrics.memory_usage_percent / 100.0;
        score += 0.1 * memory_efficiency;
        return max(0.0, min(1.0, score));
    }
    
    bool AdaptCacheSize(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
        if (metrics_history.size() < 3) return false;
        
        double hit_rate_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.cache_hit_rate; });
        idx_t old_max_entries = cache_config.max_entries;
        
        if (hit_rate_trend < -0.05 && current_metrics.memory_usage_percent < 80.0) {
            cache_config.max_entries = min(static_cast<idx_t>(cache_config.max_entries * 1.2), config.max_cache_size);
            cout << "Increasing cache size from " << old_max_entries << " to " << cache_config.max_entries 
                 << " (hit_rate_trend=" << fixed << setprecision(3) << hit_rate_trend << ")" << endl;
        } else if (current_metrics.memory_usage_percent > 90.0) {
            cache_config.max_entries = max(static_cast<idx_t>(cache_config.max_entries * 0.8), config.min_cache_size);
            cout << "Decreasing cache size from " << old_max_entries << " to " << cache_config.max_entries 
                 << " (memory_pressure=" << setprecision(1) << current_metrics.memory_usage_percent << "%)" << endl;
        }
        
        return cache_config.max_entries != old_max_entries;
    }
    
    bool AdaptMemoryLimit(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
        if (metrics_history.size() < 3) return false;
        
        idx_t old_memory_limit = cache_config.max_memory_bytes;
        
        if (current_metrics.memory_usage_percent < 60.0 && current_metrics.cache_hit_rate > 0.8) {
            cache_config.max_memory_bytes = min(
                static_cast<idx_t>(cache_config.max_memory_bytes * 1.3),
                config.max_memory_mb * 1024 * 1024
            );
            cout << "Increasing memory limit from " << (old_memory_limit / (1024*1024)) 
                 << " to " << (cache_config.max_memory_bytes / (1024*1024)) << " MB" << endl;
        } else if (current_metrics.memory_usage_percent > 85.0) {
            cache_config.max_memory_bytes = max(
                static_cast<idx_t>(cache_config.max_memory_bytes * 0.7),
                config.min_memory_mb * 1024 * 1024
            );
            cout << "Decreasing memory limit from " << (old_memory_limit / (1024*1024)) 
                 << " to " << (cache_config.max_memory_bytes / (1024*1024)) << " MB" << endl;
        }
        
        return cache_config.max_memory_bytes != old_memory_limit;
    }
    
    bool AdaptTTL(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
        if (metrics_history.size() < 5) return false;
        
        double query_time_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.avg_query_time_ms; });
        idx_t old_ttl = cache_config.ttl_seconds;
        
        if (current_metrics.cache_hit_rate > 0.85 && query_time_trend > 50.0) {
            cache_config.ttl_seconds = min(static_cast<idx_t>(cache_config.ttl_seconds * 1.5), config.max_ttl_seconds);
            cout << "Increasing TTL from " << old_ttl << " to " << cache_config.ttl_seconds 
                 << " seconds (hit_rate=" << setprecision(2) << current_metrics.cache_hit_rate * 100.0 
                 << "%, query_time_trend=" << setprecision(1) << query_time_trend << ")" << endl;
        } else if (current_metrics.cache_hit_rate < 0.5 || current_metrics.memory_usage_percent > 90.0) {
            cache_config.ttl_seconds = max(static_cast<idx_t>(cache_config.ttl_seconds * 0.7), config.min_ttl_seconds);
            cout << "Decreasing TTL from " << old_ttl << " to " << cache_config.ttl_seconds 
                 << " seconds (hit_rate=" << setprecision(2) << current_metrics.cache_hit_rate * 100.0 
                 << "%, memory_usage=" << setprecision(1) << current_metrics.memory_usage_percent << "%)" << endl;
        }
        
        return cache_config.ttl_seconds != old_ttl;
    }
    
    bool AdaptEvictionStrategy(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
        if (metrics_history.size() < 10) return false;
        
        double hit_rate_variance = 0.0;
        double avg_hit_rate = 0.0;
        
        for (const auto &metrics : metrics_history) {
            avg_hit_rate += metrics.cache_hit_rate;
        }
        avg_hit_rate /= metrics_history.size();
        
        for (const auto &metrics : metrics_history) {
            double diff = metrics.cache_hit_rate - avg_hit_rate;
            hit_rate_variance += diff * diff;
        }
        hit_rate_variance /= metrics_history.size();
        
        cout << "Analyzing eviction strategy - avg_hit_rate=" << setprecision(3) << avg_hit_rate 
             << ", variance=" << setprecision(6) << hit_rate_variance 
             << ", concurrent_queries=" << current_metrics.concurrent_queries << endl;
        
        CacheEvictionStrategy old_strategy = cache_config.eviction_strategy;
        CacheEvictionStrategy new_strategy = old_strategy;
        
        if (hit_rate_variance > 0.01 && current_metrics.concurrent_queries > 10) {
            new_strategy = CacheEvictionStrategy::ML_BASED;
            cout << "Switching to ML_BASED strategy (high variance workload)" << endl;
        } else if (avg_hit_rate > 0.8 && current_metrics.avg_query_time_ms < 100.0) {
            new_strategy = CacheEvictionStrategy::LRU_BASED;
            cout << "Switching to LRU_BASED strategy (stable high-performance workload)" << endl;
        } else if (current_metrics.memory_usage_percent > 80.0 || current_metrics.cache_memory_usage_mb > 500.0) {
            new_strategy = CacheEvictionStrategy::TTL_BASED;
            cout << "Switching to TTL_BASED strategy (memory pressure)" << endl;
        }
        
        if (new_strategy != old_strategy) {
            auto now = chrono::steady_clock::now();
            auto time_since_last_change = chrono::duration_cast<chrono::minutes>(
                now - tuning_stats.last_tuning_time).count();
            
            if (time_since_last_change < 5) {
                cout << "Strategy change suppressed (too frequent)" << endl;
                return false;
            }
            
            cache_config.eviction_strategy = new_strategy;
            cout << "Eviction strategy changed from " << (int)old_strategy << " to " << (int)new_strategy << endl;
            return true;
        }
        
        return false;
    }
    
    void UpdatePerformanceModel(const SystemPerformanceMetrics &metrics, double actual_performance) {
        double lr = config.learning_rate;
        performance_model.hit_rate_weight += lr * actual_performance * metrics.cache_hit_rate;
        performance_model.cache_size_weight += lr * actual_performance * 0.5;
        performance_model.memory_weight += lr * actual_performance * (1.0 - metrics.memory_usage_percent / 100.0);
        performance_model.ttl_weight += lr * actual_performance * 0.5;
        performance_model.bias += lr * actual_performance;
        
        cout << "Updated performance model - hit_rate_weight=" << setprecision(3) 
             << performance_model.hit_rate_weight << endl;
    }
    
    double GetTrend(function<double(const SystemPerformanceMetrics&)> extractor) const {
        if (metrics_history.size() < 3) return 0.0;
        
        size_t n = metrics_history.size();
        double recent_avg = 0.0;
        double early_avg = 0.0;
        
        size_t recent_count = max(1UL, n / 3);
        for (size_t i = n - recent_count; i < n; i++) {
            recent_avg += extractor(metrics_history[i]);
        }
        recent_avg /= recent_count;
        
        size_t early_count = max(1UL, n / 3);
        for (size_t i = 0; i < early_count; i++) {
            early_avg += extractor(metrics_history[i]);
        }
        early_avg /= early_count;
        
        return recent_avg - early_avg;
    }
};

// 模拟系统指标生成
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
    metrics.timestamp = chrono::steady_clock::now();
    
    return metrics;
}

void PrintConfig(const QueryCacheConfig& config) {
    cout << "=== Cache Configuration ===" << endl;
    cout << "Max Entries: " << config.max_entries << endl;
    cout << "Max Memory: " << (config.max_memory_bytes / (1024*1024)) << " MB" << endl;
    cout << "TTL: " << config.ttl_seconds << " seconds" << endl;
    cout << "Eviction Strategy: ";
    switch (config.eviction_strategy) {
        case CacheEvictionStrategy::TTL_BASED: cout << "TTL-based"; break;
        case CacheEvictionStrategy::LRU_BASED: cout << "LRU-based"; break;
        case CacheEvictionStrategy::ML_BASED: cout << "ML-based"; break;
    }
    cout << endl << endl;
}

void PrintTuningStats(const AdaptiveParameterTuner::TuningStats& stats) {
    cout << "=== Adaptive Tuning Statistics ===" << endl;
    cout << "Total Adjustments: " << stats.total_adjustments << endl;
    cout << "Cache Size Adjustments: " << stats.cache_size_adjustments << endl;
    cout << "Memory Limit Adjustments: " << stats.memory_limit_adjustments << endl;
    cout << "TTL Adjustments: " << stats.ttl_adjustments << endl;
    cout << "Strategy Changes: " << stats.strategy_changes << endl;
    cout << endl;
}

int main() {
    cout << "=== DuckDB Adaptive Cache Mechanism Testing ===" << endl;
    
    // 初始化配置
    QueryCacheConfig config;
    config.max_entries = 100;
    config.max_memory_bytes = 50 * 1024 * 1024; // 50MB
    config.ttl_seconds = 300; // 5分钟
    config.eviction_strategy = CacheEvictionStrategy::TTL_BASED;
    
    AdaptiveTuningConfig adaptive_config;
    adaptive_config.enabled = true;
    adaptive_config.tuning_interval_ms = 5000; // 5秒调优间隔
    adaptive_config.adapt_cache_size = true;
    adaptive_config.adapt_memory_limit = true;
    adaptive_config.adapt_ttl = true;
    adaptive_config.adapt_eviction_strategy = true;
    
    // 创建自适应调优器
    AdaptiveParameterTuner tuner(adaptive_config);
    
    cout << "Initial configuration:" << endl;
    PrintConfig(config);
    
    // 模拟不同的工作负载场景
    vector<string> scenarios = {"Normal Load", "High Load", "Low Load", "Variable Load"};
    
    for (int scenario = 0; scenario < 4; scenario++) {
        cout << string(60, '=') << endl;
        cout << "Testing Scenario: " << scenarios[scenario] << endl;
        cout << string(60, '=') << endl;
        
        // 在每个场景中运行20次迭代
        for (int i = 0; i < 20; i++) {
            // 生成系统指标
            auto metrics = GenerateSystemMetrics(scenario);
            
            // 更新自适应调优器
            tuner.UpdateMetrics(metrics, config);
            
            // 每5次迭代强制执行一次调优
            if ((i + 1) % 5 == 0) {
                cout << "\nForcing adaptive tuning cycle..." << endl;
                bool tuning_applied = tuner.ForceTuning(config);
                cout << "Tuning applied: " << (tuning_applied ? "Yes" : "No") << endl;
                
                cout << "\nCurrent configuration after tuning:" << endl;
                PrintConfig(config);
                PrintTuningStats(tuner.GetTuningStats());
            }
            
            // 短暂延迟模拟真实场景
            this_thread::sleep_for(chrono::milliseconds(200));
        }
        
        cout << "\nFinal configuration for " << scenarios[scenario] << ":" << endl;
        PrintConfig(config);
        PrintTuningStats(tuner.GetTuningStats());
        
        // 场景间的延迟
        this_thread::sleep_for(chrono::seconds(1));
    }
    
    cout << string(60, '=') << endl;
    cout << "Adaptive Cache Mechanism Testing Completed" << endl;
    cout << string(60, '=') << endl;
    
    // 最终统计
    cout << "Final configuration:" << endl;
    PrintConfig(config);
    PrintTuningStats(tuner.GetTuningStats());
    
    return 0;
}