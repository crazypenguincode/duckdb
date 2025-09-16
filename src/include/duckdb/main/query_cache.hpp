//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/bloom_filter.hpp"
#include "duckdb/common/common.hpp"
#include "duckdb/common/mutex.hpp"
#include "duckdb/common/unordered_map.hpp"
#include "duckdb/main/materialized_query_result.hpp"
#include "duckdb/parser/sql_statement.hpp"
#include <chrono>
#include <memory>
#include <queue>

namespace duckdb {

// Forward declarations for persistence
class CachePersistenceInterface;
enum class CachePersistenceStrategy;
struct QueryCacheConfig;
//struct CachePersistenceConfig;
//! 持久化策略类型
enum class CachePersistenceStrategy {
	MEMORY_ONLY,        // 策略3: 仅内存，不落盘
	MATERIALIZED_VIEW,  // 策略1: 使用物化视图落盘
	WAL_FORMAT,         // 策略2: 使用WAL格式顺序读写
	HYBRID,             // 策略4: 混合策略（热数据内存，冷数据落盘）
	CROSS_PROCESS       // 策略5: 跨进程缓存策略（专为多进程环境优化）
};

//! 持久化配置
struct CachePersistenceConfig {
	CachePersistenceStrategy strategy = CachePersistenceStrategy::MEMORY_ONLY;
	string persistence_path = "cache_storage";
	idx_t memory_threshold_bytes = 50 * 1024 * 1024; // 50MB
	idx_t wal_buffer_size = 4 * 1024 * 1024; // 4MB WAL缓冲区
	bool enable_compression = true;
	bool enable_async_write = true;
	idx_t sync_interval_ms = 5000; // 5秒同步间隔
	
	// 跨进程缓存专用配置
	bool auto_load_on_startup = true;        // 启动时自动加载缓存
	bool aggressive_persistence = true;      // 积极持久化策略
	idx_t cross_process_check_interval_ms = 1000; // 跨进程缓存检查间隔
	string shared_cache_file = "shared_cache.db"; // 共享缓存文件名
	bool enable_process_lock = true;         // 启用进程锁防止冲突
};
class ClientContext;



//! Cache eviction strategies
enum class CacheEvictionStrategy {
    TTL_BASED,      // Time-to-live based eviction
    LRU_BASED,      // Least Recently Used eviction
    ML_BASED        // Machine Learning based eviction
};

//! Machine learning features for cache prediction
struct MLCacheFeatures {
    double query_complexity_score = 0.0;    // Based on query structure
    double execution_time_ms = 0.0;         // Query execution time
    double result_size_bytes = 0.0;         // Size of result set
    double access_frequency = 0.0;          // How often this query is accessed
    double temporal_locality = 0.0;         // Time-based access pattern
    idx_t table_count = 0;                  // Number of tables in query
    idx_t join_count = 0;                   // Number of joins
    bool has_aggregation = false;           // Whether query has aggregation
    bool has_subquery = false;              // Whether query has subqueries
};

//! System performance metrics for adaptive tuning
struct SystemPerformanceMetrics {
    double cpu_usage_percent = 0.0;         // Current CPU usage
    double memory_usage_percent = 0.0;      // Current memory usage
    double cache_hit_rate = 0.0;            // Current cache hit rate
    double avg_query_time_ms = 0.0;         // Average query execution time
    double cache_memory_usage_mb = 0.0;     // Cache memory usage in MB
    idx_t concurrent_queries = 0;           // Number of concurrent queries
    double disk_io_rate_mbps = 0.0;         // Disk I/O rate in MB/s
    std::chrono::steady_clock::time_point timestamp; // When metrics were collected
    
    SystemPerformanceMetrics() : timestamp(std::chrono::steady_clock::now()) {}
};

//! Adaptive parameter tuning configuration
struct AdaptiveTuningConfig {
    bool enabled = true;                     // Enable adaptive tuning
    idx_t tuning_interval_ms = 30000;       // Tuning interval (30 seconds)
    idx_t metrics_history_size = 100;       // Number of historical metrics to keep
    double learning_rate = 0.1;             // Learning rate for parameter updates
    double performance_threshold = 0.05;    // Minimum performance improvement threshold
    
    // Parameter bounds
    idx_t min_cache_size = 100;             // Minimum cache entries
    idx_t max_cache_size = 10000;           // Maximum cache entries
    idx_t min_memory_mb = 10;               // Minimum memory usage (MB)
    idx_t max_memory_mb = 1000;             // Maximum memory usage (MB)
    idx_t min_ttl_seconds = 300;            // Minimum TTL (5 minutes)
    idx_t max_ttl_seconds = 7200;           // Maximum TTL (2 hours)
    
    // Adaptation strategies
    bool adapt_cache_size = true;           // Adapt max_entries
    bool adapt_memory_limit = true;         // Adapt max_memory_bytes
    bool adapt_ttl = true;                  // Adapt TTL
    bool adapt_eviction_strategy = true;    // Adapt eviction strategy
};

//! Adaptive parameter tuner using online learning
class AdaptiveParameterTuner {
public:
    explicit AdaptiveParameterTuner(AdaptiveTuningConfig config = AdaptiveTuningConfig());
    
    //! Update system metrics and potentially adjust parameters
    void UpdateMetrics(const SystemPerformanceMetrics &metrics, QueryCacheConfig &cache_config);
    
    //! Get current tuning statistics
    struct TuningStats {
        idx_t total_adjustments = 0;
        idx_t cache_size_adjustments = 0;
        idx_t memory_limit_adjustments = 0;
        idx_t ttl_adjustments = 0;
        idx_t strategy_changes = 0;
        double avg_performance_improvement = 0.0;
        std::chrono::steady_clock::time_point last_tuning_time;
    };
    TuningStats GetTuningStats() const { return tuning_stats; }
    
    //! Force a tuning cycle (for testing)
    bool ForceTuning(QueryCacheConfig &cache_config);
    
    //! Get performance prediction for given configuration
    double PredictPerformance(const QueryCacheConfig &config, const SystemPerformanceMetrics &metrics) const;
    
private:
    AdaptiveTuningConfig config;
    TuningStats tuning_stats;
    
    //! Historical performance metrics
    std::deque<SystemPerformanceMetrics> metrics_history;
    
    //! Performance model weights (simple linear model)
    struct PerformanceModel {
        double cache_size_weight = 0.3;
        double memory_weight = 0.25;
        double ttl_weight = 0.2;
        double hit_rate_weight = 0.25;
        double bias = 0.0;
    } performance_model;
    
    //! Check if it's time to tune parameters
    bool ShouldTune() const;
    
    //! Calculate performance score from metrics
    double CalculatePerformanceScore(const SystemPerformanceMetrics &metrics) const;
    
    //! Adapt cache size based on system load
    bool AdaptCacheSize(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics);
    
    //! Adapt memory limit based on available memory
    bool AdaptMemoryLimit(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics);
    
    //! Adapt TTL based on access patterns
    bool AdaptTTL(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics);
    
    //! Adapt eviction strategy based on workload characteristics
    bool AdaptEvictionStrategy(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics);
    
    //! Update performance model with new data
    void UpdatePerformanceModel(const SystemPerformanceMetrics &metrics, double actual_performance);
    
    //! Get trend from metrics history
    double GetTrend(std::function<double(const SystemPerformanceMetrics&)> extractor) const;
};

//! Cache entry for storing query results
struct QueryCacheEntry {
    //! The cached result
    unique_ptr<MaterializedQueryResult> result;
    //! Timestamp when the entry was created
    std::chrono::steady_clock::time_point created_at;
    //! Access count for LRU eviction
    idx_t access_count;
    //! Last access time
    std::chrono::steady_clock::time_point last_accessed;
    //! ML features for this cache entry
    MLCacheFeatures ml_features;
    //! ML prediction score (higher = more likely to be accessed again)
    double ml_score = 0.5;
    //! Priority for eviction (lower = evict first)
    double eviction_priority = 0.0;
    
    QueryCacheEntry(unique_ptr<MaterializedQueryResult> result_p) 
        : result(std::move(result_p)), 
          created_at(std::chrono::steady_clock::now()),
          access_count(1),
          last_accessed(std::chrono::steady_clock::now()) {}
};

//! Configuration for the query cache
struct QueryCacheConfig {
    //! Maximum number of cached entries
    idx_t max_entries = 1000;
    //! Maximum memory usage in bytes
    idx_t max_memory_bytes = 100 * 1024 * 1024; // 100MB default
    //! TTL for cache entries in seconds
    idx_t ttl_seconds = 3600; // 1 hour default
    //! Bloom filter size
    idx_t bloom_filter_size = 1000000;
    //! Number of hash functions for bloom filter
    idx_t bloom_filter_hash_functions = 3;
    //! Enable/disable caching
    bool enabled = true;
    //! Cache eviction strategy
    CacheEvictionStrategy eviction_strategy = CacheEvictionStrategy::TTL_BASED;
    //! ML model parameters
    double ml_learning_rate = 0.01;
    double ml_decay_factor = 0.95;
    idx_t ml_history_size = 1000;
    //! Persistence strategy
    CachePersistenceStrategy persistence_strategy;
    //! Persistence configuration
    CachePersistenceConfig persistence_config;
    //! Adaptive tuning configuration
    AdaptiveTuningConfig adaptive_tuning_config;
};

//! Simple linear regression model for ML-based caching
class MLCachePredictor {
public:
    MLCachePredictor(double learning_rate = 0.01, double decay_factor = 0.95);
    
    //! Predict cache utility score for given features
    double Predict(const MLCacheFeatures &features) const;
    
    //! Update model with new training data
    void Update(const MLCacheFeatures &features, double actual_utility);
    
    //! Get feature importance weights
    vector<double> GetWeights() const { return weights; }
    
private:
    vector<double> weights;
    double learning_rate;
    double decay_factor;
    idx_t update_count = 0;
    
    //! Convert features to vector for computation
    vector<double> FeaturesToVector(const MLCacheFeatures &features) const;
};

//! Query result cache with bloom filter for fast lookups
class QueryCache {
public:
    explicit QueryCache(QueryCacheConfig config = QueryCacheConfig());
    ~QueryCache();
    
    //! Initialize with client context for persistence strategies that need it
    bool InitializeWithContext(ClientContext *context);

    //! Check if a query result might be cached (using bloom filter)
    bool MightBeCached(const string &query_hash) const;
    
    //! Get cached result for a query
    unique_ptr<MaterializedQueryResult> GetCachedResult(const string &query_hash);
    
    //! Cache a query result with ML features
    void CacheResult(const string &query_hash, unique_ptr<MaterializedQueryResult> result, 
                    const MLCacheFeatures &features = MLCacheFeatures{});
    
    //! Clear all cached results
    void Clear();
    
    //! Get cache statistics
    struct CacheStats {
        idx_t total_entries;
        idx_t total_hits;
        idx_t total_misses;
        idx_t memory_usage_bytes;
        double hit_rate;
        double false_positive_rate;
        idx_t ttl_evictions = 0;
        idx_t lru_evictions = 0;
        idx_t ml_evictions = 0;
        double avg_ml_score = 0.0;
    };
    CacheStats GetStats() const;
    
    //! Update configuration
    void UpdateConfig(const QueryCacheConfig &new_config);
    
    //! Check if caching is enabled
    bool IsEnabled() const { return config.enabled; }
    
    //! Set eviction strategy
    void SetEvictionStrategy(CacheEvictionStrategy strategy);
    
    //! Get ML predictor for testing
    const MLCachePredictor& GetMLPredictor() const { return ml_predictor; }
    
    //! Set persistence strategy
    bool SetPersistenceStrategy(CachePersistenceStrategy strategy, ClientContext *context = nullptr);
    
    //! Get persistence statistics
    struct PersistenceStats {
        idx_t storage_size_bytes = 0;
        idx_t persisted_entries = 0;
        idx_t memory_entries = 0;
        idx_t disk_entries = 0;
    };
    PersistenceStats GetPersistenceStats() const;
    
    //! Force sync to persistent storage
    bool SyncToPersistentStorage();
    
    //! Load cache from persistent storage
    bool LoadFromPersistentStorage();
    
    //! Enable/disable adaptive parameter tuning
    void EnableAdaptiveTuning(bool enabled = true, AdaptiveTuningConfig tuning_config = AdaptiveTuningConfig());
    
    //! Update system performance metrics for adaptive tuning
    void UpdateSystemMetrics(const SystemPerformanceMetrics &metrics);
    
    //! Get adaptive tuning statistics
    struct AdaptiveTuningStats {
        bool enabled = false;
        idx_t total_adjustments = 0;
        double avg_performance_improvement = 0.0;
        std::chrono::steady_clock::time_point last_tuning_time;
        SystemPerformanceMetrics current_metrics;
    };
    AdaptiveTuningStats GetAdaptiveTuningStats() const;
    
    //! Force adaptive tuning cycle (for testing)
    bool ForceAdaptiveTuning();

private:
    //! Configuration
    QueryCacheConfig config;
    
    //! Adaptive parameter tuner
    unique_ptr<AdaptiveParameterTuner> adaptive_tuner;
    
    //! System metrics collection
    SystemPerformanceMetrics current_metrics;
    std::chrono::steady_clock::time_point last_metrics_update;
    
    //! Bloom filter for fast negative lookups
    mutable BloomFilter bloom_filter;
    
    //! Actual cache storage
    unordered_map<string, unique_ptr<QueryCacheEntry>> cache;
    
    //! Mutex for thread safety
    mutable mutex cache_mutex;
    
    //! Statistics
    mutable idx_t total_hits = 0;
    mutable idx_t total_misses = 0;
    mutable idx_t ttl_evictions = 0;
    mutable idx_t lru_evictions = 0;
    mutable idx_t ml_evictions = 0;
    
    //! ML predictor for ML-based eviction
    MLCachePredictor ml_predictor;
    
    //! Access history for ML training
    struct AccessRecord {
        string query_hash;
        MLCacheFeatures features;
        std::chrono::steady_clock::time_point access_time;
        bool was_hit;
    };
    std::queue<AccessRecord> access_history;
    
    //! Evict old or least recently used entries based on strategy
    void EvictIfNeeded();
    
    //! TTL-based eviction
    void EvictByTTL();
    
    //! LRU-based eviction
    void EvictByLRU();
    
    //! ML-based eviction
    void EvictByML();
    
    //! Calculate memory usage of a result
    idx_t CalculateMemoryUsage(const MaterializedQueryResult &result) const;
    
    //! Check if an entry has expired
    bool IsExpired(const QueryCacheEntry &entry) const;
    
    //! Remove expired entries
    void RemoveExpiredEntries();
    
    //! Update ML model with access patterns
    void UpdateMLModel();
    
    //! Calculate query complexity score
    double CalculateQueryComplexity(const MLCacheFeatures &features) const;
    
    //! Record access for ML training
    void RecordAccess(const string &query_hash, const MLCacheFeatures &features, bool was_hit);
    
    //! Persistence interface
    unique_ptr<CachePersistenceInterface> persistence;
    
    //! Client context for persistence strategies that need it
    ClientContext *client_context = nullptr;
    
    //! Load entry from persistence if not in memory
    unique_ptr<QueryCacheEntry> LoadFromPersistence(const string &query_hash);
    
    //! Persist entry to storage
    bool PersistEntry(const string &query_hash, const QueryCacheEntry &entry);
    
    //! Initialize persistence layer
    bool InitializePersistence();
    
    //! Collect current system performance metrics
    SystemPerformanceMetrics CollectSystemMetrics() const;
    
    //! Update adaptive tuning if needed
    void UpdateAdaptiveTuning();
    
    //! Calculate system load based on current state
    double CalculateSystemLoad() const;
};

//! Utility class for generating cache keys from SQL statements
class QueryCacheKeyGenerator {
public:
    //! Generate a cache key for a SQL statement
    static string GenerateKey(const SQLStatement &statement, 
                            const case_insensitive_map_t<BoundParameterData> *parameters = nullptr);
    
    //! Generate a cache key from a query string (normalized)
    static string GenerateKey(const string &query);
    
    //! Check if a statement is cacheable
    static bool IsCacheable(const SQLStatement &statement);
    
    //! Extract ML features from a SQL statement
    static MLCacheFeatures ExtractMLFeatures(const SQLStatement &statement, 
                                           double execution_time_ms = 0.0,
                                           idx_t result_size_bytes = 0);
    
private:
    //! Normalize a query string for consistent caching
    static string NormalizeQuery(const string &query);
    
    //! Extract table dependencies from a statement
    static vector<string> ExtractTableDependencies(const SQLStatement &statement);
    
    //! Calculate query complexity score
    static double CalculateComplexityScore(const SQLStatement &statement);
};

} // namespace duckdb