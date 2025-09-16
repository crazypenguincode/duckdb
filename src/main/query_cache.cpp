//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache.hpp"
#include "duckdb/main/query_cache_persistence.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/common/types/hash.hpp"
#include "duckdb/parser/statement/select_statement.hpp"
#include "duckdb/parser/statement/explain_statement.hpp"
#include "duckdb/parser/tableref/basetableref.hpp"
#include "duckdb/parser/tableref/subqueryref.hpp"
#include "duckdb/parser/tableref/joinref.hpp"
#include "duckdb/parser/query_node/select_node.hpp"
#include "duckdb/parser/query_node/cte_node.hpp"
#include <regex>
#include <cmath>

namespace duckdb {

// MLCachePredictor implementation
MLCachePredictor::MLCachePredictor(double learning_rate, double decay_factor) 
    : learning_rate(learning_rate), decay_factor(decay_factor) {
    // Initialize weights for features: complexity, exec_time, result_size, access_freq, 
    // temporal_locality, table_count, join_count, has_aggregation, has_subquery
    weights = {0.2, 0.3, 0.1, 0.25, 0.15, 0.05, 0.05, 0.1, 0.1};
}

double MLCachePredictor::Predict(const MLCacheFeatures &features) const {
    auto feature_vec = FeaturesToVector(features);
    double score = 0.0;
    for (size_t i = 0; i < weights.size() && i < feature_vec.size(); i++) {
        score += weights[i] * feature_vec[i];
    }
    // Apply sigmoid activation
    return 1.0 / (1.0 + std::exp(-score));
}

void MLCachePredictor::Update(const MLCacheFeatures &features, double actual_utility) {
    auto feature_vec = FeaturesToVector(features);
    double predicted = Predict(features);
    double error = actual_utility - predicted;
    
    // Gradient descent update with decay
    double effective_lr = learning_rate * std::pow(decay_factor, update_count / 100.0);
    for (size_t i = 0; i < weights.size() && i < feature_vec.size(); i++) {
        weights[i] += effective_lr * error * feature_vec[i];
    }
    update_count++;
}

vector<double> MLCachePredictor::FeaturesToVector(const MLCacheFeatures &features) const {
    return {
        features.query_complexity_score,
        features.execution_time_ms / 1000.0,  // Normalize to seconds
        features.result_size_bytes / (1024.0 * 1024.0),  // Normalize to MB
        features.access_frequency,
        features.temporal_locality,
        static_cast<double>(features.table_count) / 10.0,  // Normalize
        static_cast<double>(features.join_count) / 5.0,    // Normalize
        features.has_aggregation ? 1.0 : 0.0,
        features.has_subquery ? 1.0 : 0.0
    };
}

// AdaptiveParameterTuner implementation
AdaptiveParameterTuner::AdaptiveParameterTuner(AdaptiveTuningConfig config) 
    : config(std::move(config)) {
    tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
}

void AdaptiveParameterTuner::UpdateMetrics(const SystemPerformanceMetrics &metrics, QueryCacheConfig &cache_config) {
    // Add metrics to history
    metrics_history.push_back(metrics);
    
    // Keep history size within bounds
    while (metrics_history.size() > config.metrics_history_size) {
        metrics_history.pop_front();
    }
    
    // Check if we should tune parameters
    if (ShouldTune()) {
        bool adjusted = false;
        
        // Calculate current performance score
        double current_performance = CalculatePerformanceScore(metrics);
        
        // Try different parameter adjustments
        if (config.adapt_cache_size) {
            adjusted |= AdaptCacheSize(cache_config, metrics);
        }
        
        if (config.adapt_memory_limit) {
            adjusted |= AdaptMemoryLimit(cache_config, metrics);
        }
        
        if (config.adapt_ttl) {
            adjusted |= AdaptTTL(cache_config, metrics);
        }
        
        if (config.adapt_eviction_strategy) {
            adjusted |= AdaptEvictionStrategy(cache_config, metrics);
        }
        
        if (adjusted) {
            tuning_stats.total_adjustments++;
            tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
            
            // Update performance model
            UpdatePerformanceModel(metrics, current_performance);
        }
    }
}

bool AdaptiveParameterTuner::ForceTuning(QueryCacheConfig &cache_config) {
    if (metrics_history.empty()) {
        return false;
    }
    
    const auto &latest_metrics = metrics_history.back();
    bool adjusted = false;
    
    if (config.adapt_cache_size) {
        adjusted |= AdaptCacheSize(cache_config, latest_metrics);
    }
    
    if (config.adapt_memory_limit) {
        adjusted |= AdaptMemoryLimit(cache_config, latest_metrics);
    }
    
    if (config.adapt_ttl) {
        adjusted |= AdaptTTL(cache_config, latest_metrics);
    }
    
    if (config.adapt_eviction_strategy) {
        adjusted |= AdaptEvictionStrategy(cache_config, latest_metrics);
    }
    
    if (adjusted) {
        tuning_stats.total_adjustments++;
        tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
    }
    
    return adjusted;
}

double AdaptiveParameterTuner::PredictPerformance(const QueryCacheConfig &config, const SystemPerformanceMetrics &metrics) const {
    // Simple linear model for performance prediction
    double score = performance_model.bias;
    score += performance_model.cache_size_weight * (static_cast<double>(config.max_entries) / 1000.0);
    score += performance_model.memory_weight * (static_cast<double>(config.max_memory_bytes) / (1024.0 * 1024.0));
    score += performance_model.ttl_weight * (static_cast<double>(config.ttl_seconds) / 3600.0);
    score += performance_model.hit_rate_weight * metrics.cache_hit_rate;
    
    return std::max(0.0, std::min(1.0, score)); // Clamp to [0, 1]
}

bool AdaptiveParameterTuner::ShouldTune() const {
    auto now = std::chrono::steady_clock::now();
    auto time_since_last = std::chrono::duration_cast<std::chrono::milliseconds>(now - tuning_stats.last_tuning_time).count();
    
    return time_since_last >= static_cast<long>(config.tuning_interval_ms) && metrics_history.size() >= 3;
}

double AdaptiveParameterTuner::CalculatePerformanceScore(const SystemPerformanceMetrics &metrics) const {
    // Composite performance score (higher is better)
    double score = 0.0;
    score += metrics.cache_hit_rate * 0.4;                    // 40% weight on hit rate
    score += (1.0 - metrics.cpu_usage_percent / 100.0) * 0.2; // 20% weight on CPU availability
    score += (1.0 - metrics.memory_usage_percent / 100.0) * 0.2; // 20% weight on memory availability
    score += (1.0 / (1.0 + metrics.avg_query_time_ms / 1000.0)) * 0.2; // 20% weight on query speed
    
    return std::max(0.0, std::min(1.0, score));
}

bool AdaptiveParameterTuner::AdaptCacheSize(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 2) {
        return false;
    }
    
    // Get trend in hit rate and memory usage
    double hit_rate_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.cache_hit_rate; });
    double memory_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.memory_usage_percent; });
    
    idx_t old_size = cache_config.max_entries;
    
    // Increase cache size if hit rate is declining and memory usage is low
    if (hit_rate_trend < -0.05 && current_metrics.memory_usage_percent < 70.0) {
        cache_config.max_entries = std::min(config.max_cache_size, 
                                           static_cast<idx_t>(cache_config.max_entries * 1.2));
        tuning_stats.cache_size_adjustments++;
    }
    // Decrease cache size if memory usage is high
    else if (current_metrics.memory_usage_percent > 85.0 || memory_trend > 0.1) {
        cache_config.max_entries = std::max(config.min_cache_size,
                                           static_cast<idx_t>(cache_config.max_entries * 0.8));
        tuning_stats.cache_size_adjustments++;
    }
    
    return cache_config.max_entries != old_size;
}

bool AdaptiveParameterTuner::AdaptMemoryLimit(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 2) {
        return false;
    }
    
    idx_t old_limit = cache_config.max_memory_bytes;
    idx_t old_limit_mb = old_limit / (1024 * 1024);
    
    // Adjust memory limit based on system memory usage
    if (current_metrics.memory_usage_percent < 60.0) {
        // Increase memory limit if system has plenty of memory
        idx_t new_limit_mb = std::min(config.max_memory_mb, static_cast<idx_t>(old_limit_mb * 1.3));
        cache_config.max_memory_bytes = new_limit_mb * 1024 * 1024;
        tuning_stats.memory_limit_adjustments++;
    } else if (current_metrics.memory_usage_percent > 80.0) {
        // Decrease memory limit if system is under memory pressure
        idx_t new_limit_mb = std::max(config.min_memory_mb, static_cast<idx_t>(old_limit_mb * 0.7));
        cache_config.max_memory_bytes = new_limit_mb * 1024 * 1024;
        tuning_stats.memory_limit_adjustments++;
    }
    
    return cache_config.max_memory_bytes != old_limit;
}

bool AdaptiveParameterTuner::AdaptTTL(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 3) {
        return false;
    }
    
    // Get trend in access patterns
    double hit_rate_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.cache_hit_rate; });
    
    idx_t old_ttl = cache_config.ttl_seconds;
    
    // Increase TTL if hit rate is good and stable
    if (current_metrics.cache_hit_rate > 0.7 && hit_rate_trend > -0.02) {
        cache_config.ttl_seconds = std::min(config.max_ttl_seconds,
                                           static_cast<idx_t>(cache_config.ttl_seconds * 1.2));
        tuning_stats.ttl_adjustments++;
    }
    // Decrease TTL if hit rate is poor or declining
    else if (current_metrics.cache_hit_rate < 0.3 || hit_rate_trend < -0.1) {
        cache_config.ttl_seconds = std::max(config.min_ttl_seconds,
                                           static_cast<idx_t>(cache_config.ttl_seconds * 0.8));
        tuning_stats.ttl_adjustments++;
    }
    
    return cache_config.ttl_seconds != old_ttl;
}

bool AdaptiveParameterTuner::AdaptEvictionStrategy(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 5) {
        return false;
    }
    
    CacheEvictionStrategy old_strategy = cache_config.eviction_strategy;
    
    // Choose strategy based on workload characteristics
    if (current_metrics.concurrent_queries > 10 && current_metrics.avg_query_time_ms > 100.0) {
        // High concurrency, complex queries -> ML-based eviction
        cache_config.eviction_strategy = CacheEvictionStrategy::ML_BASED;
    } else if (current_metrics.cache_hit_rate > 0.8) {
        // High hit rate -> LRU works well
        cache_config.eviction_strategy = CacheEvictionStrategy::LRU_BASED;
    } else {
        // Default to TTL for simplicity
        cache_config.eviction_strategy = CacheEvictionStrategy::TTL_BASED;
    }
    
    if (cache_config.eviction_strategy != old_strategy) {
        tuning_stats.strategy_changes++;
        return true;
    }
    
    return false;
}

void AdaptiveParameterTuner::UpdatePerformanceModel(const SystemPerformanceMetrics &metrics, double actual_performance) {
    // Simple gradient descent update for the linear model
    double predicted = PredictPerformance(QueryCacheConfig{}, metrics); // Use default config for prediction
    double error = actual_performance - predicted;
    
    // Update weights
    performance_model.cache_size_weight += config.learning_rate * error * 0.1; // Normalized cache size impact
    performance_model.memory_weight += config.learning_rate * error * 0.1;
    performance_model.ttl_weight += config.learning_rate * error * 0.1;
    performance_model.hit_rate_weight += config.learning_rate * error * metrics.cache_hit_rate;
    performance_model.bias += config.learning_rate * error;
    
    // Keep weights in reasonable bounds
    performance_model.cache_size_weight = std::max(-1.0, std::min(1.0, performance_model.cache_size_weight));
    performance_model.memory_weight = std::max(-1.0, std::min(1.0, performance_model.memory_weight));
    performance_model.ttl_weight = std::max(-1.0, std::min(1.0, performance_model.ttl_weight));
    performance_model.hit_rate_weight = std::max(-1.0, std::min(1.0, performance_model.hit_rate_weight));
    performance_model.bias = std::max(-1.0, std::min(1.0, performance_model.bias));
}

double AdaptiveParameterTuner::GetTrend(std::function<double(const SystemPerformanceMetrics&)> extractor) const {
    if (metrics_history.size() < 2) {
        return 0.0;
    }
    
    // Simple linear regression to get trend
    double sum_x = 0.0, sum_y = 0.0, sum_xy = 0.0, sum_x2 = 0.0;
    size_t n = metrics_history.size();
    
    for (size_t i = 0; i < n; i++) {
        double x = static_cast<double>(i);
        double y = extractor(metrics_history[i]);
        sum_x += x;
        sum_y += y;
        sum_xy += x * y;
        sum_x2 += x * x;
    }
    
    double slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x);
    return slope;
}

QueryCache::QueryCache(QueryCacheConfig config) 
    : config(std::move(config)), 
      bloom_filter(this->config.bloom_filter_size, this->config.bloom_filter_hash_functions),
      ml_predictor(this->config.ml_learning_rate, this->config.ml_decay_factor),
      last_metrics_update(std::chrono::steady_clock::now()) {
    // 延迟初始化持久化策略，直到有ClientContext可用
    // persistence将在InitializeWithContext中初始化
    
    // Initialize adaptive tuner if enabled
    if (this->config.adaptive_tuning_config.enabled) {
        adaptive_tuner = make_uniq<AdaptiveParameterTuner>(this->config.adaptive_tuning_config);
    }
}

QueryCache::~QueryCache() {
    if (persistence) {
        persistence->Sync();
        persistence->Close();
    }
}

bool QueryCache::InitializeWithContext(ClientContext *context) {
    client_context = context;
    
    // 初始化持久化层
    if (!InitializePersistence()) {
        return false;
    }
    
    // 如果使用跨进程缓存策略，自动加载现有缓存条目
    if (config.persistence_strategy == CachePersistenceStrategy::CROSS_PROCESS && persistence) {
        printf("Loading existing cross-process cache entries...\n");
        
        // 获取所有缓存键
        auto keys = persistence->GetAllKeys();
        printf("Found %zu existing cache entries to load\n", keys.size());
        
        // 预加载热点缓存条目（限制数量避免内存过载）
        idx_t max_preload = std::min(static_cast<idx_t>(keys.size()), config.max_entries / 2);
        for (idx_t i = 0; i < max_preload; i++) {
            auto entry = persistence->LoadEntry(keys[i]);
            if (entry) {
                lock_guard<mutex> lock(cache_mutex);
                cache[keys[i]] = std::move(entry);
                bloom_filter.Add(keys[i]);
            }
        }
        
        printf("Pre-loaded %zu cache entries from cross-process storage\n", cache.size());
    }
    
    return true;
}

bool QueryCache::MightBeCached(const string &query_hash) const {
    if (!config.enabled) {
        return false;
    }
    lock_guard<mutex> lock(cache_mutex);
    return bloom_filter.MightContain(query_hash);
}

unique_ptr<MaterializedQueryResult> QueryCache::GetCachedResult(const string &query_hash) {
    if (!config.enabled) {
        return nullptr;
    }
    
    lock_guard<mutex> lock(cache_mutex);
    
    auto it = cache.find(query_hash);
    if (it == cache.end()) {
        // 尝试从持久化存储加载
        auto persisted_entry = LoadFromPersistence(query_hash);
        if (persisted_entry) {
            // 将持久化的条目加载到内存缓存
            cache[query_hash] = std::move(persisted_entry);
            it = cache.find(query_hash);
        } else {
            total_misses++;
            return nullptr;
        }
    }
    
    auto &entry = it->second;
    
    // Check if entry has expired
    if (IsExpired(*entry)) {
        cache.erase(it);
        total_misses++;
        return nullptr;
    }
    
    // Update access statistics
    entry->access_count++;
    entry->last_accessed = std::chrono::steady_clock::now();
    total_hits++;
    
    // Update ML features for temporal locality
    auto now = std::chrono::steady_clock::now();
    auto time_since_last = std::chrono::duration_cast<std::chrono::seconds>(now - entry->last_accessed).count();
    entry->ml_features.temporal_locality = 1.0 / (1.0 + time_since_last / 3600.0); // Decay over hours
    entry->ml_features.access_frequency = static_cast<double>(entry->access_count);
    
    // Record access for ML training
    RecordAccess(query_hash, entry->ml_features, true);
    
    // Update adaptive tuning
    UpdateAdaptiveTuning();

    // Clone the result for return
    // Create a copy of the collection
    auto& original_collection = entry->result->Collection();
    auto collection_copy = make_uniq<ColumnDataCollection>(Allocator::DefaultAllocator(), original_collection.Types());
    
    // Copy all data chunks from the original collection
    ColumnDataScanState scan_state;
    original_collection.InitializeScan(scan_state, ColumnDataScanProperties::DISALLOW_ZERO_COPY);
    
    ColumnDataAppendState append_state;
    collection_copy->InitializeAppend(append_state);
    
    DataChunk chunk;
    original_collection.InitializeScanChunk(chunk);
    while (original_collection.Scan(scan_state, chunk)) {
        collection_copy->Append(append_state, chunk);
    }
    
    auto cloned_result = make_uniq<MaterializedQueryResult>(
        entry->result->statement_type,
        entry->result->properties,
        entry->result->names, 
        std::move(collection_copy),
        entry->result->client_properties
    );
    
    return cloned_result;
}

void QueryCache::CacheResult(const string &query_hash, unique_ptr<MaterializedQueryResult> result, 
                            const MLCacheFeatures &features) {
    if (!config.enabled || !result || result->HasError()) {
        return;
    }
    
    lock_guard<mutex> lock(cache_mutex);
    
    // Add to bloom filter
    bloom_filter.Add(query_hash);
    
    // Create cache entry
    auto entry = make_uniq<QueryCacheEntry>(std::move(result));
    entry->ml_features = features;
    
    // Calculate ML score if using ML strategy
    if (config.eviction_strategy == CacheEvictionStrategy::ML_BASED) {
        entry->ml_score = ml_predictor.Predict(features);
        entry->eviction_priority = entry->ml_score;
    } else if (config.eviction_strategy == CacheEvictionStrategy::LRU_BASED) {
        entry->eviction_priority = static_cast<double>(entry->last_accessed.time_since_epoch().count());
    } else {
        // TTL-based: priority based on creation time
        entry->eviction_priority = static_cast<double>(entry->created_at.time_since_epoch().count());
    }
    
    // Insert into cache
    cache[query_hash] = std::move(entry);
    
    // 持久化到存储
    if (persistence) {
        PersistEntry(query_hash, *cache[query_hash]);
    }
    
    // Record access for ML training
    RecordAccess(query_hash, features, false);
    
    // Update adaptive tuning
    UpdateAdaptiveTuning();

    // Evict if necessary
    EvictIfNeeded();
}

void QueryCache::Clear() {
    lock_guard<mutex> lock(cache_mutex);
    cache.clear();
    bloom_filter.Clear();
    total_hits = 0;
    total_misses = 0;
    ttl_evictions = 0;
    lru_evictions = 0;
    ml_evictions = 0;
    // Clear access history
    while (!access_history.empty()) {
        access_history.pop();
    }
}

QueryCache::CacheStats QueryCache::GetStats() const {
    lock_guard<mutex> lock(cache_mutex);
    
    CacheStats stats;
    stats.total_entries = cache.size();
    stats.total_hits = total_hits;
    stats.total_misses = total_misses;
    stats.hit_rate = (total_hits + total_misses) > 0 ? 
                     static_cast<double>(total_hits) / (total_hits + total_misses) : 0.0;
    stats.false_positive_rate = bloom_filter.GetFalsePositiveRate();
    stats.ttl_evictions = ttl_evictions;
    stats.lru_evictions = lru_evictions;
    stats.ml_evictions = ml_evictions;
    
    // Calculate memory usage and average ML score
    stats.memory_usage_bytes = 0;
    double total_ml_score = 0.0;
    for (const auto &entry : cache) {
        stats.memory_usage_bytes += CalculateMemoryUsage(*entry.second->result);
        total_ml_score += entry.second->ml_score;
    }
    stats.avg_ml_score = cache.empty() ? 0.0 : total_ml_score / cache.size();
    
    return stats;
}

void QueryCache::UpdateConfig(const QueryCacheConfig &new_config) {
    lock_guard<mutex> lock(cache_mutex);
    config = new_config;
    
    // Resize bloom filter if needed
    if (bloom_filter.bit_array.size() != config.bloom_filter_size) {
        bloom_filter.Resize(config.bloom_filter_size);
        // Re-add all cached queries to bloom filter
        for (const auto &entry : cache) {
            bloom_filter.Add(entry.first);
        }
    }
    
    // Evict if new limits are smaller
    EvictIfNeeded();
}

void QueryCache::SetEvictionStrategy(CacheEvictionStrategy strategy) {
    lock_guard<mutex> lock(cache_mutex);
    config.eviction_strategy = strategy;
    
    // Update eviction priorities for all entries
    for (auto &entry : cache) {
        if (strategy == CacheEvictionStrategy::ML_BASED) {
            entry.second->ml_score = ml_predictor.Predict(entry.second->ml_features);
            entry.second->eviction_priority = entry.second->ml_score;
        } else if (strategy == CacheEvictionStrategy::LRU_BASED) {
            entry.second->eviction_priority = static_cast<double>(entry.second->last_accessed.time_since_epoch().count());
        } else {
            // TTL-based: priority based on creation time
            entry.second->eviction_priority = static_cast<double>(entry.second->created_at.time_since_epoch().count());
        }
    }
}

void QueryCache::EvictIfNeeded() {
    switch (config.eviction_strategy) {
        case CacheEvictionStrategy::TTL_BASED:
            EvictByTTL();
            break;
        case CacheEvictionStrategy::LRU_BASED:
            EvictByLRU();
            break;
        case CacheEvictionStrategy::ML_BASED:
            EvictByML();
            break;
    }
    
    // Update ML model periodically
    if (config.eviction_strategy == CacheEvictionStrategy::ML_BASED) {
        UpdateMLModel();
    }
}

void QueryCache::EvictByTTL() {
    // Remove expired entries first
    RemoveExpiredEntries();
    
    // Check memory limit
    idx_t current_memory = 0;
    for (const auto &entry : cache) {
        current_memory += CalculateMemoryUsage(*entry.second->result);
    }
    
    // Evict oldest entries if over limits
    while ((cache.size() > config.max_entries || current_memory > config.max_memory_bytes) 
           && !cache.empty()) {
        
        // Find oldest entry
        auto oldest_it = cache.begin();
        for (auto it = cache.begin(); it != cache.end(); ++it) {
            if (it->second->created_at < oldest_it->second->created_at) {
                oldest_it = it;
            }
        }
        
        current_memory -= CalculateMemoryUsage(*oldest_it->second->result);
        cache.erase(oldest_it);
        ttl_evictions++;
    }
}

void QueryCache::EvictByLRU() {
    // Remove expired entries first
    RemoveExpiredEntries();
    
    // Check memory limit
    idx_t current_memory = 0;
    for (const auto &entry : cache) {
        current_memory += CalculateMemoryUsage(*entry.second->result);
    }
    
    // Evict LRU entries if over limits
    while ((cache.size() > config.max_entries || current_memory > config.max_memory_bytes) 
           && !cache.empty()) {
        
        // Find LRU entry
        auto lru_it = cache.begin();
        for (auto it = cache.begin(); it != cache.end(); ++it) {
            if (it->second->last_accessed < lru_it->second->last_accessed) {
                lru_it = it;
            }
        }
        
        current_memory -= CalculateMemoryUsage(*lru_it->second->result);
        cache.erase(lru_it);
        lru_evictions++;
    }
}

void QueryCache::EvictByML() {
    // Remove expired entries first
    RemoveExpiredEntries();
    
    // Check memory limit
    idx_t current_memory = 0;
    for (const auto &entry : cache) {
        current_memory += CalculateMemoryUsage(*entry.second->result);
    }
    
    // Evict entries with lowest ML scores if over limits
    while ((cache.size() > config.max_entries || current_memory > config.max_memory_bytes) 
           && !cache.empty()) {
        
        // Find entry with lowest ML score (least likely to be accessed again)
        auto worst_it = cache.begin();
        for (auto it = cache.begin(); it != cache.end(); ++it) {
            if (it->second->ml_score < worst_it->second->ml_score) {
                worst_it = it;
            }
        }
        
        current_memory -= CalculateMemoryUsage(*worst_it->second->result);
        cache.erase(worst_it);
        ml_evictions++;
    }
}

idx_t QueryCache::CalculateMemoryUsage(const MaterializedQueryResult &result) const {
    // Rough estimation of memory usage
    idx_t memory = 0;
    
    // Column names and types
    for (const auto &name : result.names) {
        memory += name.size();
    }
    memory += result.types.size() * sizeof(LogicalType);
    
    // Data collection
    if (result.RowCount() > 0) {
        memory += result.RowCount() * result.types.size() * 8; // Rough estimate
    }
    
    return memory;
}

bool QueryCache::IsExpired(const QueryCacheEntry &entry) const {
    auto now = std::chrono::steady_clock::now();
    auto age = std::chrono::duration_cast<std::chrono::seconds>(now - entry.created_at);
    return age.count() > static_cast<long>(config.ttl_seconds);
}

void QueryCache::RemoveExpiredEntries() {
    auto it = cache.begin();
    while (it != cache.end()) {
        if (IsExpired(*it->second)) {
            it = cache.erase(it);
        } else {
            ++it;
        }
    }
}

void QueryCache::UpdateMLModel() {
    // Process access history to train the ML model
    while (!access_history.empty() && access_history.size() > config.ml_history_size) {
        auto &record = access_history.front();
        
        // Calculate utility based on whether it was a hit and how recent it was
        auto now = std::chrono::steady_clock::now();
        auto time_diff = std::chrono::duration_cast<std::chrono::seconds>(now - record.access_time).count();
        double utility = record.was_hit ? (1.0 / (1.0 + time_diff / 3600.0)) : 0.0;
        
        // Update ML model
        ml_predictor.Update(record.features, utility);
        
        access_history.pop();
    }
}

void QueryCache::RecordAccess(const string &query_hash, const MLCacheFeatures &features, bool was_hit) {
    AccessRecord record;
    record.query_hash = query_hash;
    record.features = features;
    record.access_time = std::chrono::steady_clock::now();
    record.was_hit = was_hit;
    
    access_history.push(record);
    
    // Limit history size
    while (access_history.size() > config.ml_history_size) {
        access_history.pop();
    }
}

double QueryCache::CalculateQueryComplexity(const MLCacheFeatures &features) const {
    // Simple complexity calculation based on features
    double complexity = 0.0;
    complexity += features.table_count * 0.2;
    complexity += features.join_count * 0.3;
    complexity += features.has_aggregation ? 0.2 : 0.0;
    complexity += features.has_subquery ? 0.3 : 0.0;
    return std::min(complexity, 1.0);
}

// QueryCacheKeyGenerator implementation

string QueryCacheKeyGenerator::GenerateKey(const SQLStatement &statement, 
                                         const case_insensitive_map_t<BoundParameterData> *parameters) {
    // Create a string representation of the statement
    string statement_str = statement.ToString();
    
    // Normalize the query
    string normalized = NormalizeQuery(statement_str);
    
    // Add parameter values if present
    if (parameters) {
        for (const auto &param : *parameters) {
            normalized += "|" + param.first + "=" + param.second.GetValue().ToString();
        }
    }
    
    // Generate hash
    return to_string(Hash(normalized.c_str(), normalized.length()));
}

string QueryCacheKeyGenerator::GenerateKey(const string &query) {
    string normalized = NormalizeQuery(query);
    return to_string(Hash(normalized.c_str(), normalized.length()));
}

bool QueryCacheKeyGenerator::IsCacheable(const SQLStatement &statement) {
	printf("DEBUG: IsCacheable called with statement type: %d\n", (int)statement.type);
	switch (statement.type) {
	case StatementType::SELECT_STATEMENT: {
		printf("DEBUG: Statement is SELECT, checking for CTE...\n");
		auto &select = static_cast<const SelectStatement &>(statement);
		
		// Check if this is a pragma query - these should not be cached
		string query_str = statement.query;
		std::transform(query_str.begin(), query_str.end(), query_str.begin(), ::tolower);
		if (query_str.find("pragma_query_cache_stats") != string::npos) {
			printf("DEBUG: Statement contains pragma_query_cache_stats, not cacheable\n");
			return false;
		}
		
		if (select.node && !select.node->cte_map.map.empty()) {
			printf("DEBUG: SELECT statement contains CTE, still cacheable\n");
		}
		printf("DEBUG: Statement is SELECT, returning true\n");
		return true;
	}
	case StatementType::EXPLAIN_STATEMENT: {
		// Check if it's explaining a SELECT
		auto &explain = static_cast<const ExplainStatement &>(statement);
		bool result = explain.stmt && explain.stmt->type == StatementType::SELECT_STATEMENT;
		printf("DEBUG: Statement is EXPLAIN, returning %d\n", result);
		return result;
	}
	case StatementType::TRANSACTION_STATEMENT: {
		// This might be a wrapped SELECT statement - check the query string
		string query_str = statement.query;
		std::transform(query_str.begin(), query_str.end(), query_str.begin(), ::tolower);
		
		// Remove leading/trailing whitespace
		size_t start = query_str.find_first_not_of(" \t\n\r");
		if (start == string::npos) {
			printf("DEBUG: Empty query string in TRANSACTION_STATEMENT\n");
			return false;
		}
		size_t end = query_str.find_last_not_of(" \t\n\r");
		query_str = query_str.substr(start, end - start + 1);
		
		// Check for pragma queries first - these should not be cached
		if (query_str.find("pragma_query_cache_stats") != string::npos) {
			printf("DEBUG: TRANSACTION_STATEMENT contains pragma_query_cache_stats, not cacheable\n");
			return false;
		}
		
		// Check if it starts with SELECT or WITH (for CTE)
		bool is_select_like = query_str.substr(0, 6) == "select" || query_str.substr(0, 4) == "with";
		printf("DEBUG: TRANSACTION_STATEMENT contains query: '%.50s...', is_select_like=%d\n", 
		       query_str.c_str(), is_select_like);
		return is_select_like;
	}
	default:
		printf("DEBUG: Statement type %d is not cacheable\n", (int)statement.type);
		return false;
	}
}

MLCacheFeatures QueryCacheKeyGenerator::ExtractMLFeatures(const SQLStatement &statement, 
                                                         double execution_time_ms,
                                                         idx_t result_size_bytes) {
    MLCacheFeatures features;
    features.execution_time_ms = execution_time_ms;
    features.result_size_bytes = static_cast<double>(result_size_bytes);
    features.query_complexity_score = CalculateComplexityScore(statement);
    
    // Extract features based on statement type
    if (statement.type == StatementType::SELECT_STATEMENT) {
        auto &select = static_cast<const SelectStatement &>(statement);
        if (select.node) {
            // Count tables, joins, etc. (simplified implementation)
            features.table_count = 1; // At least one table
            features.has_aggregation = false; // Would need deeper AST analysis
            features.has_subquery = !select.node->cte_map.map.empty();
        }
    }
    
    return features;
}

string QueryCacheKeyGenerator::NormalizeQuery(const string &query) {
    string normalized = query;
    
    // Convert to lowercase
    std::transform(normalized.begin(), normalized.end(), normalized.begin(), ::tolower);
    
    // Remove extra whitespace
    std::regex whitespace_regex("\\s+");
    normalized = std::regex_replace(normalized, whitespace_regex, " ");
    
    // Trim leading/trailing whitespace
    StringUtil::Trim(normalized);
    
    return normalized;
}

vector<string> QueryCacheKeyGenerator::ExtractTableDependencies(const SQLStatement &statement) {
    vector<string> dependencies;
    
    // This is a simplified implementation
    // In a full implementation, you would traverse the AST to extract all table references
    // including those in CTEs, subqueries, etc.
    
    if (statement.type == StatementType::SELECT_STATEMENT) {
        // Extract table names from SELECT statement
        // This would require a more sophisticated AST traversal
    }
    
    return dependencies;
}

double QueryCacheKeyGenerator::CalculateComplexityScore(const SQLStatement &statement) {
    double score = 0.0;
    
    // Basic complexity based on query string length and keywords
    string query_str = statement.query;
    std::transform(query_str.begin(), query_str.end(), query_str.begin(), ::tolower);
    
    // Count complexity indicators
    if (query_str.find("join") != string::npos) score += 0.3;
    if (query_str.find("group by") != string::npos) score += 0.2;
    if (query_str.find("order by") != string::npos) score += 0.1;
    if (query_str.find("having") != string::npos) score += 0.2;
    if (query_str.find("union") != string::npos) score += 0.2;
    if (query_str.find("with") != string::npos) score += 0.3; // CTE
    
    // Normalize by query length
    score += std::min(query_str.length() / 1000.0, 0.5);
    
    return std::min(score, 1.0);
}

//===----------------------------------------------------------------------===//
// QueryCache Persistence Methods
//===----------------------------------------------------------------------===//

bool QueryCache::SetPersistenceStrategy(CachePersistenceStrategy strategy, ClientContext *context) {
    lock_guard<mutex> lock(cache_mutex);
    
    // 同步当前数据
    if (persistence) {
        persistence->Sync();
        persistence->Close();
    }
    
    // 创建新的持久化策略
    client_context = context;
    persistence = CachePersistenceFactory::CreatePersistence(strategy, context);
    if (!persistence) {
        printf("Failed to create persistence strategy\n");
        return false;
    }
    
    config.persistence_strategy = strategy;
    return persistence->Initialize(config.persistence_config);
}

QueryCache::PersistenceStats QueryCache::GetPersistenceStats() const {
    lock_guard<mutex> lock(cache_mutex);
    
    PersistenceStats stats;
    if (persistence) {
        stats.storage_size_bytes = persistence->GetStorageSize();
        auto all_keys = persistence->GetAllKeys();
        stats.persisted_entries = all_keys.size();
    }
    
    stats.memory_entries = cache.size();
    stats.disk_entries = stats.persisted_entries - stats.memory_entries;
    
    return stats;
}

bool QueryCache::SyncToPersistentStorage() {
    lock_guard<mutex> lock(cache_mutex);
    
    if (!persistence) {
        return false;
    }
    
    // 同步所有内存中的条目到持久化存储
    for (const auto &entry : cache) {
        PersistEntry(entry.first, *entry.second);
    }
    
    return persistence->Sync();
}

bool QueryCache::LoadFromPersistentStorage() {
    lock_guard<mutex> lock(cache_mutex);
    
    if (!persistence) {
        return false;
    }
    
    try {
        auto all_keys = persistence->GetAllKeys();
        printf("Loading %zu entries from persistent storage\n", all_keys.size());
        
        for (const auto &key : all_keys) {
            auto entry = persistence->LoadEntry(key);
            if (entry) {
                // 添加到bloom filter
                bloom_filter.Add(key);
                // 不直接加载到内存缓存，而是在需要时懒加载
            }
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to load from persistent storage: %s\n", ex.what());
        return false;
    }
}

unique_ptr<QueryCacheEntry> QueryCache::LoadFromPersistence(const string &query_hash) {
    if (!persistence) {
        return nullptr;
    }
    
    try {
        return persistence->LoadEntry(query_hash);
    } catch (std::exception &ex) {
        printf("Failed to load entry from persistence: %s\n", ex.what());
        return nullptr;
    }
}

bool QueryCache::PersistEntry(const string &query_hash, const QueryCacheEntry &entry) {
    if (!persistence) {
        return false;
    }
    
    try {
        return persistence->PersistEntry(query_hash, entry);
    } catch (std::exception &ex) {
        printf("Failed to persist entry: %s\n", ex.what());
        return false;
    }
}

bool QueryCache::InitializePersistence() {
    if (!persistence) {
        if (client_context) {
            // 有ClientContext时使用WAL格式持久化策略
            persistence = CachePersistenceFactory::CreatePersistence(
                CachePersistenceStrategy::WAL_FORMAT, client_context);
        } else {
            // 没有ClientContext时使用内存策略
            persistence = CachePersistenceFactory::CreatePersistence(
                CachePersistenceStrategy::MEMORY_ONLY, client_context);
        }
    }
    
    if (persistence) {
        bool initialized = persistence->Initialize(config.persistence_config);
        if (initialized) {
            // 从持久化存储加载现有数据
            LoadFromPersistentStorage();
        }
        return initialized;
    }
    
    return false;
}

//===----------------------------------------------------------------------===//
// QueryCache Adaptive Tuning Methods
//===----------------------------------------------------------------------===//

void QueryCache::EnableAdaptiveTuning(bool enabled, AdaptiveTuningConfig tuning_config) {
    lock_guard<mutex> lock(cache_mutex);
    
    config.adaptive_tuning_config = tuning_config;
    config.adaptive_tuning_config.enabled = enabled;
    
    if (enabled) {
        adaptive_tuner = make_uniq<AdaptiveParameterTuner>(tuning_config);
        printf("Adaptive parameter tuning enabled with interval %llu ms\n", tuning_config.tuning_interval_ms);
    } else {
        adaptive_tuner.reset();
        printf("Adaptive parameter tuning disabled\n");
    }
}

void QueryCache::UpdateSystemMetrics(const SystemPerformanceMetrics &metrics) {
    lock_guard<mutex> lock(cache_mutex);
    
    current_metrics = metrics;
    last_metrics_update = std::chrono::steady_clock::now();
    
    // Update adaptive tuning if enabled
    if (adaptive_tuner) {
        adaptive_tuner->UpdateMetrics(metrics, config);
    }
}

QueryCache::AdaptiveTuningStats QueryCache::GetAdaptiveTuningStats() const {
    lock_guard<mutex> lock(cache_mutex);
    
    AdaptiveTuningStats stats;
    stats.enabled = config.adaptive_tuning_config.enabled;
    stats.current_metrics = current_metrics;
    
    if (adaptive_tuner) {
        auto tuning_stats = adaptive_tuner->GetTuningStats();
        stats.total_adjustments = tuning_stats.total_adjustments;
        stats.avg_performance_improvement = tuning_stats.avg_performance_improvement;
        stats.last_tuning_time = tuning_stats.last_tuning_time;
    }
    
    return stats;
}

bool QueryCache::ForceAdaptiveTuning() {
    lock_guard<mutex> lock(cache_mutex);
    
    if (!adaptive_tuner) {
        return false;
    }
    
    return adaptive_tuner->ForceTuning(config);
}

SystemPerformanceMetrics QueryCache::CollectSystemMetrics() const {
    SystemPerformanceMetrics metrics;
    
    // Collect cache-specific metrics
    auto cache_stats = GetStats();
    metrics.cache_hit_rate = cache_stats.hit_rate;
    metrics.cache_memory_usage_mb = static_cast<double>(cache_stats.memory_usage_bytes) / (1024.0 * 1024.0);
    metrics.avg_query_time_ms = 100.0; // This would need to be tracked separately
    metrics.concurrent_queries = 1; // This would need to be tracked separately
    
    // System metrics would typically be collected from OS APIs
    // For now, we'll use placeholder values
    metrics.cpu_usage_percent = 50.0;
    metrics.memory_usage_percent = 60.0;
    metrics.disk_io_rate_mbps = 10.0;
    
    return metrics;
}

void QueryCache::UpdateAdaptiveTuning() {
    if (!adaptive_tuner || !config.adaptive_tuning_config.enabled) {
        return;
    }
    
    // Collect current system metrics
    auto metrics = CollectSystemMetrics();
    
    // Update the tuner
    adaptive_tuner->UpdateMetrics(metrics, config);
}

double QueryCache::CalculateSystemLoad() const {
    // Simple system load calculation based on current metrics
    double load = 0.0;
    load += current_metrics.cpu_usage_percent / 100.0 * 0.4;
    load += current_metrics.memory_usage_percent / 100.0 * 0.3;
    load += (1.0 - current_metrics.cache_hit_rate) * 0.2;
    load += std::min(current_metrics.concurrent_queries / 10.0, 1.0) * 0.1;
    
    return std::max(0.0, std::min(1.0, load));
}

} // namespace duckdb