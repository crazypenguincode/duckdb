//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache.cpp - Enhanced CTE Caching Implementation
//
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/common/types/hash.hpp"
#include "duckdb/parser/statement/select_statement.hpp"
#include "duckdb/parser/statement/explain_statement.hpp"
#include "duckdb/parser/tableref/basetableref.hpp"
#include "duckdb/parser/tableref/subqueryref.hpp"
#include "duckdb/parser/tableref/joinref.hpp"
#include "duckdb/parser/query_node/select_node.hpp"
#include "duckdb/parser/query_node/cte_node.hpp"
#include "duckdb/planner/logical_operator.hpp"
#include "duckdb/planner/operator/logical_materialized_cte.hpp"
#include "duckdb/planner/operator/logical_cteref.hpp"
#include "duckdb/optimizer/optimizer.hpp"
#include <regex>
#include <cmath>
#include <sstream>
#include <iomanip>

namespace duckdb {

//===----------------------------------------------------------------------===//
// CTE Cache Entry - Enhanced for Multi-Stage Caching
//===----------------------------------------------------------------------===//

struct CTECacheEntry {
    // Parser stage cache
    unique_ptr<SelectStatement> parsed_statement;
    CommonTableExpressionMap parsed_cte_map;
    
    // Planner stage cache  
    unique_ptr<LogicalOperator> logical_plan;
    vector<LogicalType> logical_types;
    
    // Optimizer stage cache
    unique_ptr<LogicalOperator> optimized_plan;
    vector<LogicalType> optimized_types;
    
    // Executor stage cache (existing)
    unique_ptr<MaterializedQueryResult> execution_result;
    
    // Metadata
    string cte_signature;
    vector<string> cte_names;
    std::chrono::steady_clock::time_point created_at;
    std::chrono::steady_clock::time_point last_accessed;
    idx_t access_count;
    
    // Stage flags
    bool has_parsed_cache;
    bool has_logical_cache;
    bool has_optimized_cache;
    bool has_execution_cache;
    
    CTECacheEntry() : access_count(0), has_parsed_cache(false), 
                     has_logical_cache(false), has_optimized_cache(false), 
                     has_execution_cache(false) {
        created_at = std::chrono::steady_clock::now();
        last_accessed = created_at;
    }
};

//===----------------------------------------------------------------------===//
// Multi-Stage CTE Cache Manager
//===----------------------------------------------------------------------===//

class MultiStageCTECache {
private:
    unordered_map<string, unique_ptr<CTECacheEntry>> cache_entries;
    mutable mutex cache_mutex;
    
    // Statistics
    idx_t parser_hits = 0;
    idx_t planner_hits = 0; 
    idx_t optimizer_hits = 0;
    idx_t executor_hits = 0;
    idx_t total_requests = 0;
    
public:
    // Generate CTE signature for caching
    string GenerateCTESignature(const CommonTableExpressionMap &cte_map) {
        string signature = "CTE:";
        vector<string> cte_parts;
        
        for (const auto &cte : cte_map.map) {
            string cte_part = cte.first + "={" + cte.second->query->ToString() + "}";
            cte_parts.push_back(cte_part);
        }
        
        // Sort for consistent signature
        sort(cte_parts.begin(), cte_parts.end());
        for (const auto &part : cte_parts) {
            signature += part + ";";
        }
        
        return signature;
    }
    
    // Cache parsed CTE
    void CacheParsedCTE(const string &signature, unique_ptr<SelectStatement> statement,
                       const CommonTableExpressionMap &cte_map) {
        lock_guard<mutex> lock(cache_mutex);
        
        auto it = cache_entries.find(signature);
        if (it == cache_entries.end()) {
            cache_entries[signature] = make_uniq<CTECacheEntry>();
        }
        
        auto &entry = cache_entries[signature];
        entry->parsed_statement = unique_ptr_cast<SQLStatement, SelectStatement>(statement->Copy());
        entry->parsed_cte_map = cte_map.Copy();
        entry->cte_signature = signature;
        entry->has_parsed_cache = true;
        
        // Extract CTE names
        entry->cte_names.clear();
        for (const auto &cte : cte_map.map) {
            entry->cte_names.push_back(cte.first);
        }
        
        printf("DEBUG: Cached parsed CTE with signature: %s\n", signature.c_str());
    }
    
    // Cache logical plan
    void CacheLogicalPlan(const string &signature, unique_ptr<LogicalOperator> plan,
                         const vector<LogicalType> &types) {
        lock_guard<mutex> lock(cache_mutex);
        
        auto it = cache_entries.find(signature);
        if (it == cache_entries.end()) {
            cache_entries[signature] = make_uniq<CTECacheEntry>();
        }
        
        auto &entry = cache_entries[signature];
        // Note: LogicalOperator doesn't have a Copy method, so we store the original
        // In a real implementation, we'd need to implement deep copying
        entry->logical_plan = std::move(plan);
        entry->logical_types = types;
        entry->has_logical_cache = true;
        
        printf("DEBUG: Cached logical plan for CTE: %s\n", signature.c_str());
    }
    
    // Cache optimized plan
    void CacheOptimizedPlan(const string &signature, unique_ptr<LogicalOperator> plan,
                           const vector<LogicalType> &types) {
        lock_guard<mutex> lock(cache_mutex);
        
        auto it = cache_entries.find(signature);
        if (it == cache_entries.end()) {
            cache_entries[signature] = make_uniq<CTECacheEntry>();
        }
        
        auto &entry = cache_entries[signature];
        entry->optimized_plan = std::move(plan);
        entry->optimized_types = types;
        entry->has_optimized_cache = true;
        
        printf("DEBUG: Cached optimized plan for CTE: %s\n", signature.c_str());
    }
    
    // Cache execution result
    void CacheExecutionResult(const string &signature, unique_ptr<MaterializedQueryResult> result) {
        lock_guard<mutex> lock(cache_mutex);
        
        auto it = cache_entries.find(signature);
        if (it == cache_entries.end()) {
            cache_entries[signature] = make_uniq<CTECacheEntry>();
        }
        
        auto &entry = cache_entries[signature];
        entry->execution_result = std::move(result);
        entry->has_execution_cache = true;
        
        printf("DEBUG: Cached execution result for CTE: %s\n", signature.c_str());
    }
    
    // Get cached parsed CTE
    unique_ptr<SelectStatement> GetCachedParsedCTE(const string &signature) {
        lock_guard<mutex> lock(cache_mutex);
        total_requests++;
        
        auto it = cache_entries.find(signature);
        if (it != cache_entries.end() && it->second->has_parsed_cache) {
            parser_hits++;
            it->second->access_count++;
            it->second->last_accessed = std::chrono::steady_clock::now();
            printf("DEBUG: Parser cache hit for CTE: %s\n", signature.c_str());
            auto copied_statement = it->second->parsed_statement->Copy();
            return unique_ptr_cast<SQLStatement, SelectStatement>(std::move(copied_statement));
        }
        
        return nullptr;
    }
    
    // Get cached logical plan
    LogicalOperator* GetCachedLogicalPlan(const string &signature) {
        lock_guard<mutex> lock(cache_mutex);
        total_requests++;
        
        auto it = cache_entries.find(signature);
        if (it != cache_entries.end() && it->second->has_logical_cache) {
            planner_hits++;
            it->second->access_count++;
            it->second->last_accessed = std::chrono::steady_clock::now();
            printf("DEBUG: Planner cache hit for CTE: %s\n", signature.c_str());
            return it->second->logical_plan.get();
        }
        
        return nullptr;
    }
    
    // Get cached optimized plan
    LogicalOperator* GetCachedOptimizedPlan(const string &signature) {
        lock_guard<mutex> lock(cache_mutex);
        total_requests++;
        
        auto it = cache_entries.find(signature);
        if (it != cache_entries.end() && it->second->has_optimized_cache) {
            optimizer_hits++;
            it->second->access_count++;
            it->second->last_accessed = std::chrono::steady_clock::now();
            printf("DEBUG: Optimizer cache hit for CTE: %s\n", signature.c_str());
            return it->second->optimized_plan.get();
        }
        
        return nullptr;
    }
    
    // Get cached execution result
    unique_ptr<MaterializedQueryResult> GetCachedExecutionResult(const string &signature) {
        lock_guard<mutex> lock(cache_mutex);
        total_requests++;
        
        auto it = cache_entries.find(signature);
        if (it != cache_entries.end() && it->second->has_execution_cache) {
            executor_hits++;
            it->second->access_count++;
            it->second->last_accessed = std::chrono::steady_clock::now();
            printf("DEBUG: Executor cache hit for CTE: %s\n", signature.c_str());
            
            // Clone the result
            auto& original_collection = it->second->execution_result->Collection();
            auto collection_copy = make_uniq<ColumnDataCollection>(Allocator::DefaultAllocator(), original_collection.Types());
            
            ColumnDataScanState scan_state;
            original_collection.InitializeScan(scan_state, ColumnDataScanProperties::DISALLOW_ZERO_COPY);
            
            ColumnDataAppendState append_state;
            collection_copy->InitializeAppend(append_state);
            
            DataChunk chunk;
            original_collection.InitializeScanChunk(chunk);
            while (original_collection.Scan(scan_state, chunk)) {
                collection_copy->Append(append_state, chunk);
            }
            
            return make_uniq<MaterializedQueryResult>(
                it->second->execution_result->statement_type,
                it->second->execution_result->properties,
                it->second->execution_result->names,
                std::move(collection_copy),
                it->second->execution_result->client_properties
            );
        }
        
        return nullptr;
    }
    
    // Get cache statistics
    struct CacheStats {
        idx_t parser_hits;
        idx_t planner_hits;
        idx_t optimizer_hits;
        idx_t executor_hits;
        idx_t total_requests;
        idx_t total_entries;
        double parser_hit_rate;
        double planner_hit_rate;
        double optimizer_hit_rate;
        double executor_hit_rate;
        double overall_hit_rate;
    };
    
    CacheStats GetCacheStats() const {
        lock_guard<mutex> lock(cache_mutex);
        
        CacheStats stats;
        stats.parser_hits = parser_hits;
        stats.planner_hits = planner_hits;
        stats.optimizer_hits = optimizer_hits;
        stats.executor_hits = executor_hits;
        stats.total_requests = total_requests;
        stats.total_entries = cache_entries.size();
        
        if (total_requests > 0) {
            stats.parser_hit_rate = (double)parser_hits / total_requests * 100.0;
            stats.planner_hit_rate = (double)planner_hits / total_requests * 100.0;
            stats.optimizer_hit_rate = (double)optimizer_hits / total_requests * 100.0;
            stats.executor_hit_rate = (double)executor_hits / total_requests * 100.0;
            
            idx_t total_hits = parser_hits + planner_hits + optimizer_hits + executor_hits;
            stats.overall_hit_rate = (double)total_hits / total_requests * 100.0;
        } else {
            stats.parser_hit_rate = 0.0;
            stats.planner_hit_rate = 0.0;
            stats.optimizer_hit_rate = 0.0;
            stats.executor_hit_rate = 0.0;
            stats.overall_hit_rate = 0.0;
        }
        
        return stats;
    }
    
    void Clear() {
        lock_guard<mutex> lock(cache_mutex);
        cache_entries.clear();
        parser_hits = planner_hits = optimizer_hits = executor_hits = total_requests = 0;
    }
};

// Global multi-stage CTE cache instance
static MultiStageCTECache g_multi_stage_cte_cache;

//===----------------------------------------------------------------------===//
// Enhanced QueryCacheKeyGenerator with Multi-Stage CTE Support
//===----------------------------------------------------------------------===//

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
        
        // Enhanced CTE detection and caching
        if (select.node && !select.node->cte_map.map.empty()) {
            printf("DEBUG: SELECT statement contains CTE, analyzing for multi-stage caching\n");
            
            // Generate CTE signature for multi-stage caching
            string cte_signature = g_multi_stage_cte_cache.GenerateCTESignature(select.node->cte_map);
            printf("DEBUG: CTE signature: %s\n", cte_signature.c_str());
            
            // Check if we have any cached stages for this CTE
            auto cached_parsed = g_multi_stage_cte_cache.GetCachedParsedCTE(cte_signature);
            if (cached_parsed) {
                printf("DEBUG: Found cached parsed CTE\n");
            }
            
            auto cached_logical = g_multi_stage_cte_cache.GetCachedLogicalPlan(cte_signature);
            if (cached_logical) {
                printf("DEBUG: Found cached logical plan for CTE\n");
            }
            
            auto cached_optimized = g_multi_stage_cte_cache.GetCachedOptimizedPlan(cte_signature);
            if (cached_optimized) {
                printf("DEBUG: Found cached optimized plan for CTE\n");
            }
            
            auto cached_result = g_multi_stage_cte_cache.GetCachedExecutionResult(cte_signature);
            if (cached_result) {
                printf("DEBUG: Found cached execution result for CTE\n");
            }
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

string QueryCacheKeyGenerator::GenerateKey(const SQLStatement &statement, 
                                         const case_insensitive_map_t<BoundParameterData> *parameters) {
    // Create a string representation of the statement
    string statement_str = statement.ToString();
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey - original statement: '%s'\n", statement_str.c_str());
    
    // Enhanced CTE handling
    if (statement.type == StatementType::SELECT_STATEMENT) {
        auto &select = static_cast<const SelectStatement &>(statement);
        if (select.node && !select.node->cte_map.map.empty()) {
            // For CTE queries, include CTE signature in the key
            string cte_signature = g_multi_stage_cte_cache.GenerateCTESignature(select.node->cte_map);
            statement_str += "|" + cte_signature;
            printf("DEBUG: QueryCacheKeyGenerator::GenerateKey - added CTE signature: '%s'\n", cte_signature.c_str());
        }
    }
    
    // Normalize the query
    string normalized = NormalizeQuery(statement_str);
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey - normalized: '%s'\n", normalized.c_str());
    
    // Add parameter values if present
    if (parameters) {
        for (const auto &param : *parameters) {
            normalized += "|" + param.first + "=" + param.second.GetValue().ToString();
        }
        printf("DEBUG: QueryCacheKeyGenerator::GenerateKey - with parameters: '%s'\n", normalized.c_str());
    }
    
    // Generate hash
    auto hash_result = Hash(normalized.c_str(), normalized.length());
    string key = to_string(hash_result);
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey - final key: '%s' (from normalized: '%s')\n", key.c_str(), normalized.c_str());
    return key;
}

//===----------------------------------------------------------------------===//
// Enhanced QueryCache with Multi-Stage CTE Support
//===----------------------------------------------------------------------===//

// Add method to get multi-stage CTE cache statistics
QueryCache::MultiStageCTEStats QueryCache::GetMultiStageCTEStats() const {
    auto stats = g_multi_stage_cte_cache.GetCacheStats();
    
    MultiStageCTEStats result;
    result.parser_hits = stats.parser_hits;
    result.planner_hits = stats.planner_hits;
    result.optimizer_hits = stats.optimizer_hits;
    result.executor_hits = stats.executor_hits;
    result.total_requests = stats.total_requests;
    result.total_entries = stats.total_entries;
    result.parser_hit_rate = stats.parser_hit_rate;
    result.planner_hit_rate = stats.planner_hit_rate;
    result.optimizer_hit_rate = stats.optimizer_hit_rate;
    result.executor_hit_rate = stats.executor_hit_rate;
    result.overall_hit_rate = stats.overall_hit_rate;
    
    return result;
}

// Enhanced CacheResult method with multi-stage CTE caching
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
    
    // Record access for ML training
    RecordAccess(query_hash, features, false);
    
    // Update adaptive tuning
    UpdateAdaptiveTuning();

    // Evict if necessary
    EvictIfNeeded();
}

// Clear multi-stage CTE cache
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
    
    // Clear multi-stage CTE cache
    g_multi_stage_cte_cache.Clear();
}

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

QueryCache::QueryCache(QueryCacheConfig config) 
    : config(std::move(config)), 
      bloom_filter(this->config.bloom_filter_size, this->config.bloom_filter_hash_functions),
      last_metrics_update(std::chrono::steady_clock::now()),
      ml_predictor(this->config.ml_learning_rate, this->config.ml_decay_factor) {
    
    // Initialize adaptive tuner if enabled
    if (this->config.adaptive_tuning_config.enabled) {
        adaptive_tuner = make_uniq<AdaptiveParameterTuner>(this->config.adaptive_tuning_config);
    }
}

QueryCache::~QueryCache() {
    // Cleanup if needed
}

bool QueryCache::InitializeWithContext(ClientContext *context) {
    client_context = context;
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
        total_misses++;
        return nullptr;
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

string QueryCacheKeyGenerator::GenerateKey(const string &query) {
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey(string) - original query: '%s'\n", query.c_str());
    string normalized = NormalizeQuery(query);
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey(string) - normalized: '%s'\n", normalized.c_str());
    auto hash_result = Hash(normalized.c_str(), normalized.length());
    string key = to_string(hash_result);
    printf("DEBUG: QueryCacheKeyGenerator::GenerateKey(string) - final key: '%s' (from normalized: '%s')\n", key.c_str(), normalized.c_str());
    return key;
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

void QueryCache::UpdateAdaptiveTuning() {
    if (!adaptive_tuner) {
        return;
    }
    
    // 收集当前系统指标
    current_metrics = CollectSystemMetrics();
    
    // 更新自适应调优器
    adaptive_tuner->UpdateMetrics(current_metrics, config);
    
    last_metrics_update = std::chrono::steady_clock::now();
}

//===----------------------------------------------------------------------===//
// QueryCache EXPLAIN Implementation
//===----------------------------------------------------------------------===//

QueryCache::CacheExplainInfo QueryCache::GetExplainInfo() const {
    lock_guard<mutex> lock(cache_mutex);
    
    CacheExplainInfo info;
    
    // 基本配置信息
    info.enabled = config.enabled;
    info.max_entries = config.max_entries;
    info.max_memory_bytes = config.max_memory_bytes;
    info.ttl_seconds = config.ttl_seconds;
    info.eviction_strategy = config.eviction_strategy;
    info.persistence_strategy = config.persistence_strategy;
    
    // 统计信息
    info.stats = GetStats();
    info.cte_stats = GetMultiStageCTEStats();
    info.persistence_stats = GetPersistenceStats();
    info.adaptive_stats = GetAdaptiveTuningStats();
    
    // Bloom Filter信息
    info.bloom_filter_info.size = config.bloom_filter_size;
    info.bloom_filter_info.hash_functions = config.bloom_filter_hash_functions;
    info.bloom_filter_info.false_positive_rate = bloom_filter.GetFalsePositiveRate();
    info.bloom_filter_info.estimated_elements = cache.size();
    
    // ML预测器信息
    info.ml_predictor_info.weights = ml_predictor.GetWeights();
    info.ml_predictor_info.learning_rate = config.ml_learning_rate;
    info.ml_predictor_info.decay_factor = config.ml_decay_factor;
    info.ml_predictor_info.update_count = 0; // TODO: 从ml_predictor获取
    
    // 缓存条目详情
    auto now = std::chrono::steady_clock::now();
    for (const auto &entry : cache) {
        CacheExplainInfo::CacheEntryInfo entry_info;
        entry_info.query_hash = entry.first;
        
        // 生成查询预览（从hash无法还原原始查询，这里显示hash）
        entry_info.query_preview = "Hash: " + entry.first.substr(0, 16) + "...";
        
        entry_info.created_at = entry.second->created_at;
        entry_info.last_accessed = entry.second->last_accessed;
        entry_info.access_count = entry.second->access_count;
        entry_info.memory_usage_bytes = CalculateMemoryUsage(*entry.second->result);
        entry_info.ml_score = entry.second->ml_score;
        entry_info.eviction_priority = entry.second->eviction_priority;
        entry_info.ml_features = entry.second->ml_features;
        entry_info.is_expired = IsExpired(*entry.second);
        
        // 计算时间相关信息
        auto age = std::chrono::duration_cast<std::chrono::seconds>(now - entry.second->created_at);
        entry_info.age_seconds = static_cast<double>(age.count());
        
        auto time_since_access = std::chrono::duration_cast<std::chrono::seconds>(now - entry.second->last_accessed);
        entry_info.time_since_last_access_seconds = static_cast<double>(time_since_access.count());
        
        info.cache_entries.push_back(entry_info);
    }
    
    // 按访问次数排序
    std::sort(info.cache_entries.begin(), info.cache_entries.end(),
              [](const CacheExplainInfo::CacheEntryInfo &a, const CacheExplainInfo::CacheEntryInfo &b) {
                  return a.access_count > b.access_count;
              });
    
    return info;
}

string QueryCache::FormatExplainInfo(const CacheExplainInfo &info, ExplainFormat format) const {
    switch (format) {
        case ExplainFormat::JSON:
            return FormatExplainInfoJSON(info);
        case ExplainFormat::HTML:
            return FormatExplainInfoHTML(info);
        default:
            return FormatExplainInfoText(info);
    }
}

string QueryCache::FormatExplainInfoText(const CacheExplainInfo &info) const {
    std::ostringstream ss;
    
    ss << "┌─────────────────────────────────────────────────────────────────────────────────┐\n";
    ss << "│                              QUERY CACHE EXPLAIN                               │\n";
    ss << "├─────────────────────────────────────────────────────────────────────────────────┤\n";
    
    // 基本配置
    ss << "│ Configuration:                                                                  │\n";
    ss << "│   Enabled: " << std::setw(63) << std::left << (info.enabled ? "Yes" : "No") << " │\n";
    ss << "│   Max Entries: " << std::setw(59) << std::left << info.max_entries << " │\n";
    ss << "│   Max Memory: " << std::setw(58) << std::left << (info.max_memory_bytes / (1024*1024)) << " MB │\n";
    ss << "│   TTL: " << std::setw(65) << std::left << info.ttl_seconds << " seconds │\n";
    
    string eviction_str;
    switch (info.eviction_strategy) {
        case CacheEvictionStrategy::TTL_BASED: eviction_str = "TTL-based"; break;
        case CacheEvictionStrategy::LRU_BASED: eviction_str = "LRU-based"; break;
        case CacheEvictionStrategy::ML_BASED: eviction_str = "ML-based"; break;
    }
    ss << "│   Eviction Strategy: " << std::setw(52) << std::left << eviction_str << " │\n";
    
    ss << "├─────────────────────────────────────────────────────────────────────────────────┤\n";
    
    // 统计信息
    ss << "│ Statistics:                                                                     │\n";
    ss << "│   Total Entries: " << std::setw(56) << std::left << info.stats.total_entries << " │\n";
    ss << "│   Total Hits: " << std::setw(59) << std::left << info.stats.total_hits << " │\n";
    ss << "│   Total Misses: " << std::setw(57) << std::left << info.stats.total_misses << " │\n";
    ss << "│   Hit Rate: " << std::setw(58) << std::left << std::fixed << std::setprecision(2) << info.stats.hit_rate << "% │\n";
    ss << "│   Memory Usage: " << std::setw(52) << std::left << (info.stats.memory_usage_bytes / (1024*1024)) << " MB │\n";
    
    // 缓存条目详情（显示前5个）
    if (!info.cache_entries.empty()) {
        ss << "├─────────────────────────────────────────────────────────────────────────────────┤\n";
        ss << "│ Cache Entries (Top 5 by Access Count):                                         │\n";
        ss << "│ Hash            │ Access │ Age(s) │ Memory │ ML Score │ Expired │            │\n";
        ss << "├─────────────────┼────────┼────────┼────────┼──────────┼─────────┼────────────┤\n";
        
        size_t count = std::min(info.cache_entries.size(), static_cast<size_t>(5));
        for (size_t i = 0; i < count; i++) {
            const auto &entry = info.cache_entries[i];
            string hash_short = entry.query_hash.substr(0, 15);
            string memory_str = std::to_string(entry.memory_usage_bytes / 1024) + "KB";
            
            ss << "│ " << std::setw(15) << std::left << hash_short
               << " │ " << std::setw(6) << std::right << entry.access_count
               << " │ " << std::setw(6) << std::right << static_cast<int>(entry.age_seconds)
               << " │ " << std::setw(6) << std::right << memory_str
               << " │ " << std::setw(8) << std::right << std::fixed << std::setprecision(3) << entry.ml_score
               << " │ " << std::setw(7) << std::left << (entry.is_expired ? "Yes" : "No")
               << " │            │\n";
        }
    }
    
    ss << "└─────────────────────────────────────────────────────────────────────────────────┘\n";
    
    return ss.str();
}

string QueryCache::FormatExplainInfoJSON(const CacheExplainInfo &info) const {
    std::ostringstream ss;
    
    ss << "{\n";
    ss << "  \"query_cache\": {\n";
    
    // 配置信息
    ss << "    \"configuration\": {\n";
    ss << "      \"enabled\": " << (info.enabled ? "true" : "false") << ",\n";
    ss << "      \"max_entries\": " << info.max_entries << ",\n";
    ss << "      \"max_memory_bytes\": " << info.max_memory_bytes << ",\n";
    ss << "      \"ttl_seconds\": " << info.ttl_seconds << ",\n";
    ss << "      \"eviction_strategy\": \"";
    switch (info.eviction_strategy) {
        case CacheEvictionStrategy::TTL_BASED: ss << "TTL_BASED"; break;
        case CacheEvictionStrategy::LRU_BASED: ss << "LRU_BASED"; break;
        case CacheEvictionStrategy::ML_BASED: ss << "ML_BASED"; break;
    }
    ss << "\"\n";
    ss << "    },\n";
    
    // 统计信息
    ss << "    \"statistics\": {\n";
    ss << "      \"total_entries\": " << info.stats.total_entries << ",\n";
    ss << "      \"total_hits\": " << info.stats.total_hits << ",\n";
    ss << "      \"total_misses\": " << info.stats.total_misses << ",\n";
    ss << "      \"hit_rate\": " << std::fixed << std::setprecision(2) << info.stats.hit_rate << ",\n";
    ss << "      \"memory_usage_bytes\": " << info.stats.memory_usage_bytes << "\n";
    ss << "    },\n";
    
    // 缓存条目
    ss << "    \"cache_entries\": [\n";
    for (size_t i = 0; i < info.cache_entries.size(); i++) {
        if (i > 0) ss << ",\n";
        const auto &entry = info.cache_entries[i];
        ss << "      {\n";
        ss << "        \"query_hash\": \"" << entry.query_hash << "\",\n";
        ss << "        \"access_count\": " << entry.access_count << ",\n";
        ss << "        \"age_seconds\": " << std::fixed << std::setprecision(1) << entry.age_seconds << ",\n";
        ss << "        \"memory_usage_bytes\": " << entry.memory_usage_bytes << ",\n";
        ss << "        \"ml_score\": " << std::fixed << std::setprecision(3) << entry.ml_score << ",\n";
        ss << "        \"is_expired\": " << (entry.is_expired ? "true" : "false") << "\n";
        ss << "      }";
    }
    ss << "\n    ]\n";
    
    ss << "  }\n";
    ss << "}\n";
    
    return ss.str();
}

string QueryCache::FormatExplainInfoHTML(const CacheExplainInfo &info) const {
    std::ostringstream ss;
    
    ss << "<!DOCTYPE html>\n";
    ss << "<html>\n<head>\n";
    ss << "<title>Query Cache Explain</title>\n";
    ss << "<style>\n";
    ss << "body { font-family: Arial, sans-serif; margin: 20px; }\n";
    ss << "table { border-collapse: collapse; width: 100%; margin: 10px 0; }\n";
    ss << "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n";
    ss << "th { background-color: #f2f2f2; }\n";
    ss << ".section { margin: 20px 0; }\n";
    ss << ".metric { display: inline-block; margin: 5px 15px 5px 0; }\n";
    ss << ".expired { color: red; }\n";
    ss << ".active { color: green; }\n";
    ss << "</style>\n";
    ss << "</head>\n<body>\n";
    
    ss << "<h1>Query Cache Explain</h1>\n";
    
    // 配置信息
    ss << "<div class=\"section\">\n";
    ss << "<h2>Configuration</h2>\n";
    ss << "<div class=\"metric\"><strong>Enabled:</strong> " << (info.enabled ? "Yes" : "No") << "</div>\n";
    ss << "<div class=\"metric\"><strong>Max Entries:</strong> " << info.max_entries << "</div>\n";
    ss << "<div class=\"metric\"><strong>Max Memory:</strong> " << (info.max_memory_bytes / (1024*1024)) << " MB</div>\n";
    ss << "<div class=\"metric\"><strong>TTL:</strong> " << info.ttl_seconds << " seconds</div>\n";
    ss << "</div>\n";
    
    // 统计信息
    ss << "<div class=\"section\">\n";
    ss << "<h2>Statistics</h2>\n";
    ss << "<div class=\"metric\"><strong>Total Entries:</strong> " << info.stats.total_entries << "</div>\n";
    ss << "<div class=\"metric\"><strong>Total Hits:</strong> " << info.stats.total_hits << "</div>\n";
    ss << "<div class=\"metric\"><strong>Total Misses:</strong> " << info.stats.total_misses << "</div>\n";
    ss << "<div class=\"metric\"><strong>Hit Rate:</strong> " << std::fixed << std::setprecision(2) << info.stats.hit_rate << "%</div>\n";
    ss << "<div class=\"metric\"><strong>Memory Usage:</strong> " << (info.stats.memory_usage_bytes / (1024*1024)) << " MB</div>\n";
    ss << "</div>\n";
    
    // 缓存条目表格
    if (!info.cache_entries.empty()) {
        ss << "<div class=\"section\">\n";
        ss << "<h2>Cache Entries</h2>\n";
        ss << "<table>\n";
        ss << "<tr><th>Query Hash</th><th>Access Count</th><th>Age (seconds)</th><th>Memory (KB)</th><th>ML Score</th><th>Status</th></tr>\n";
        
        for (const auto &entry : info.cache_entries) {
            ss << "<tr>\n";
            ss << "<td>" << entry.query_hash.substr(0, 20) << "...</td>\n";
            ss << "<td>" << entry.access_count << "</td>\n";
            ss << "<td>" << static_cast<int>(entry.age_seconds) << "</td>\n";
            ss << "<td>" << (entry.memory_usage_bytes / 1024) << "</td>\n";
            ss << "<td>" << std::fixed << std::setprecision(3) << entry.ml_score << "</td>\n";
            ss << "<td class=\"" << (entry.is_expired ? "expired" : "active") << "\">" 
               << (entry.is_expired ? "Expired" : "Active") << "</td>\n";
            ss << "</tr>\n";
        }
        
        ss << "</table>\n";
        ss << "</div>\n";
    }
    
    ss << "</body>\n</html>\n";
    
    return ss.str();
}

//===----------------------------------------------------------------------===//
// AdaptiveParameterTuner Implementation
//===----------------------------------------------------------------------===//

AdaptiveParameterTuner::AdaptiveParameterTuner(AdaptiveTuningConfig config) : config(config) {
    tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
    printf("DEBUG: AdaptiveParameterTuner initialized with tuning_interval=%llu ms\n", (unsigned long long)config.tuning_interval_ms);
}

void AdaptiveParameterTuner::UpdateMetrics(const SystemPerformanceMetrics &metrics, QueryCacheConfig &cache_config) {
    // 添加新的指标到历史记录
    metrics_history.push_back(metrics);
    
    // 限制历史记录大小
    while (metrics_history.size() > config.metrics_history_size) {
        metrics_history.pop_front();
    }
    
    printf("DEBUG: UpdateMetrics - hit_rate=%.2f%%, memory_usage=%.1fMB, cpu_usage=%.1f%%\n", 
           metrics.cache_hit_rate * 100.0, metrics.cache_memory_usage_mb, metrics.cpu_usage_percent);
    
    // 检查是否需要调优
    if (ShouldTune()) {
        printf("DEBUG: Triggering adaptive tuning cycle\n");
        
        // 记录调优前的性能基线
        double baseline_performance = CalculatePerformanceScore(metrics);
        
        bool any_adjustment = false;
        
        // 1. 自适应缓存大小调整
        if (config.adapt_cache_size && AdaptCacheSize(cache_config, metrics)) {
            tuning_stats.cache_size_adjustments++;
            any_adjustment = true;
        }
        
        // 2. 自适应内存限制调整
        if (config.adapt_memory_limit && AdaptMemoryLimit(cache_config, metrics)) {
            tuning_stats.memory_limit_adjustments++;
            any_adjustment = true;
        }
        
        // 3. 自适应TTL调整
        if (config.adapt_ttl && AdaptTTL(cache_config, metrics)) {
            tuning_stats.ttl_adjustments++;
            any_adjustment = true;
        }
        
        // 4. 自适应淘汰策略切换
        if (config.adapt_eviction_strategy && AdaptEvictionStrategy(cache_config, metrics)) {
            tuning_stats.strategy_changes++;
            any_adjustment = true;
        }
        
        if (any_adjustment) {
            tuning_stats.total_adjustments++;
            tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
            
            // 更新性能模型
            UpdatePerformanceModel(metrics, baseline_performance);
            
            printf("DEBUG: Adaptive tuning completed - total_adjustments=%llu\n", (unsigned long long)tuning_stats.total_adjustments);
        }
    }
}

bool AdaptiveParameterTuner::ForceTuning(QueryCacheConfig &cache_config) {
    if (metrics_history.empty()) {
        printf("DEBUG: ForceTuning - no metrics history available\n");
        return false;
    }
    
    printf("DEBUG: ForceTuning triggered\n");
    
    // 使用最新的指标进行强制调优
    const auto &latest_metrics = metrics_history.back();
    
    bool any_adjustment = false;
    
    // 强制执行所有调优策略
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
        tuning_stats.last_tuning_time = std::chrono::steady_clock::now();
        printf("DEBUG: ForceTuning completed with adjustments\n");
    }
    
    return any_adjustment;
}

double AdaptiveParameterTuner::PredictPerformance(const QueryCacheConfig &config, const SystemPerformanceMetrics &metrics) const {
    // 使用简单的线性模型预测性能
    double predicted_score = performance_model.bias;
    
    // 缓存大小因子 (归一化到0-1)
    double cache_size_factor = static_cast<double>(config.max_entries) / this->config.max_cache_size;
    predicted_score += performance_model.cache_size_weight * cache_size_factor;
    
    // 内存因子 (归一化到0-1)
    double memory_factor = static_cast<double>(config.max_memory_bytes) / (this->config.max_memory_mb * 1024 * 1024);
    predicted_score += performance_model.memory_weight * memory_factor;
    
    // TTL因子 (归一化到0-1)
    double ttl_factor = static_cast<double>(config.ttl_seconds) / this->config.max_ttl_seconds;
    predicted_score += performance_model.ttl_weight * ttl_factor;
    
    // 命中率因子
    predicted_score += performance_model.hit_rate_weight * metrics.cache_hit_rate;
    
    // 应用sigmoid激活函数，确保输出在0-1之间
    return 1.0 / (1.0 + std::exp(-predicted_score));
}

bool AdaptiveParameterTuner::ShouldTune() const {
    auto now = std::chrono::steady_clock::now();
    auto time_since_last_tuning = std::chrono::duration_cast<std::chrono::milliseconds>(
        now - tuning_stats.last_tuning_time).count();
    
    return time_since_last_tuning >= static_cast<long>(config.tuning_interval_ms);
}

double AdaptiveParameterTuner::CalculatePerformanceScore(const SystemPerformanceMetrics &metrics) const {
    // 综合性能评分，考虑多个维度
    double score = 0.0;
    
    // 缓存命中率权重最高
    score += 0.4 * metrics.cache_hit_rate;
    
    // 查询响应时间（越低越好，需要反转）
    double normalized_query_time = std::max(0.0, 1.0 - metrics.avg_query_time_ms / 10000.0); // 假设10秒为最差情况
    score += 0.3 * normalized_query_time;
    
    // CPU使用率（适中最好，过高或过低都不好）
    double cpu_efficiency = 1.0 - std::abs(metrics.cpu_usage_percent - 70.0) / 100.0; // 70%为理想CPU使用率
    score += 0.2 * std::max(0.0, cpu_efficiency);
    
    // 内存使用效率
    double memory_efficiency = 1.0 - metrics.memory_usage_percent / 100.0;
    score += 0.1 * memory_efficiency;
    
    return std::max(0.0, std::min(1.0, score)); // 确保在0-1范围内
}

bool AdaptiveParameterTuner::AdaptCacheSize(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 3) {
        return false; // 需要足够的历史数据
    }
    
    // 分析缓存命中率趋势
    double hit_rate_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.cache_hit_rate; });
    
    idx_t old_max_entries = cache_config.max_entries;
    
    if (hit_rate_trend < -0.05 && current_metrics.memory_usage_percent < 80.0) {
        // 命中率下降且内存充足，增加缓存大小
        cache_config.max_entries = std::min(
            static_cast<idx_t>(cache_config.max_entries * 1.2), 
            config.max_cache_size
        );
        printf("DEBUG: Increasing cache size from %llu to %llu (hit_rate_trend=%.3f)\n", 
               (unsigned long long)old_max_entries, (unsigned long long)cache_config.max_entries, hit_rate_trend);
    } else if (current_metrics.memory_usage_percent > 90.0) {
        // 内存压力大，减少缓存大小
        cache_config.max_entries = std::max(
            static_cast<idx_t>(cache_config.max_entries * 0.8), 
            config.min_cache_size
        );
        printf("DEBUG: Decreasing cache size from %llu to %llu (memory_pressure=%.1f%%)\n", 
               (unsigned long long)old_max_entries, (unsigned long long)cache_config.max_entries, current_metrics.memory_usage_percent);
    }
    
    return cache_config.max_entries != old_max_entries;
}

bool AdaptiveParameterTuner::AdaptMemoryLimit(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 3) {
        return false;
    }
    
    idx_t old_memory_limit = cache_config.max_memory_bytes;
    
    // 根据系统内存使用情况调整
    if (current_metrics.memory_usage_percent < 60.0 && current_metrics.cache_hit_rate > 0.8) {
        // 内存充足且命中率高，可以增加内存限制
        cache_config.max_memory_bytes = std::min(
            static_cast<idx_t>(cache_config.max_memory_bytes * 1.3),
            config.max_memory_mb * 1024 * 1024
        );
        printf("DEBUG: Increasing memory limit from %llu to %llu MB\n", 
               (unsigned long long)(old_memory_limit / (1024*1024)), (unsigned long long)(cache_config.max_memory_bytes / (1024*1024)));
    } else if (current_metrics.memory_usage_percent > 85.0) {
        // 内存压力大，减少内存限制
        cache_config.max_memory_bytes = std::max(
            static_cast<idx_t>(cache_config.max_memory_bytes * 0.7),
            config.min_memory_mb * 1024 * 1024
        );
        printf("DEBUG: Decreasing memory limit from %llu to %llu MB\n", 
               (unsigned long long)(old_memory_limit / (1024*1024)), (unsigned long long)(cache_config.max_memory_bytes / (1024*1024)));
    }
    
    return cache_config.max_memory_bytes != old_memory_limit;
}

bool AdaptiveParameterTuner::AdaptTTL(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 5) {
        return false;
    }
    
    // 分析查询时间趋势
    double query_time_trend = GetTrend([](const SystemPerformanceMetrics &m) { return m.avg_query_time_ms; });
    
    idx_t old_ttl = cache_config.ttl_seconds;
    
    if (current_metrics.cache_hit_rate > 0.85 && query_time_trend > 50.0) {
        // 命中率高但查询时间增长，延长TTL
        cache_config.ttl_seconds = std::min(
            static_cast<idx_t>(cache_config.ttl_seconds * 1.5),
            config.max_ttl_seconds
        );
        printf("DEBUG: Increasing TTL from %llu to %llu seconds (hit_rate=%.2f%%, query_time_trend=%.1f)\n", 
               (unsigned long long)old_ttl, (unsigned long long)cache_config.ttl_seconds, current_metrics.cache_hit_rate * 100.0, query_time_trend);
    } else if (current_metrics.cache_hit_rate < 0.5 || current_metrics.memory_usage_percent > 90.0) {
        // 命中率低或内存压力大，缩短TTL
        cache_config.ttl_seconds = std::max(
            static_cast<idx_t>(cache_config.ttl_seconds * 0.7),
            config.min_ttl_seconds
        );
        printf("DEBUG: Decreasing TTL from %llu to %llu seconds (hit_rate=%.2f%%, memory_usage=%.1f%%)\n", 
               (unsigned long long)old_ttl, (unsigned long long)cache_config.ttl_seconds, current_metrics.cache_hit_rate * 100.0, current_metrics.memory_usage_percent);
    }
    
    return cache_config.ttl_seconds != old_ttl;
}

bool AdaptiveParameterTuner::AdaptEvictionStrategy(QueryCacheConfig &cache_config, const SystemPerformanceMetrics &current_metrics) {
    if (metrics_history.size() < 10) {
        return false; // 需要更多历史数据来做策略决策
    }
    
    CacheEvictionStrategy old_strategy = cache_config.eviction_strategy;
    CacheEvictionStrategy new_strategy = old_strategy;
    
    // 分析工作负载特征
    double hit_rate_variance = 0.0;
    double avg_hit_rate = 0.0;
    
    // 计算命中率的方差，用于判断工作负载的稳定性
    for (const auto &metrics : metrics_history) {
        avg_hit_rate += metrics.cache_hit_rate;
    }
    avg_hit_rate /= metrics_history.size();
    
    for (const auto &metrics : metrics_history) {
        double diff = metrics.cache_hit_rate - avg_hit_rate;
        hit_rate_variance += diff * diff;
    }
    hit_rate_variance /= metrics_history.size();
    
    printf("DEBUG: Analyzing eviction strategy - avg_hit_rate=%.3f, variance=%.6f, concurrent_queries=%llu\n", 
           avg_hit_rate, hit_rate_variance, (unsigned long long)current_metrics.concurrent_queries);
    
    // 策略选择逻辑
    if (hit_rate_variance > 0.01 && current_metrics.concurrent_queries > 10) {
        // 工作负载变化大且并发高，使用ML策略
        new_strategy = CacheEvictionStrategy::ML_BASED;
        printf("DEBUG: Switching to ML_BASED strategy (high variance workload)\n");
    } else if (avg_hit_rate > 0.8 && current_metrics.avg_query_time_ms < 100.0) {
        // 命中率高且查询快，使用LRU策略
        new_strategy = CacheEvictionStrategy::LRU_BASED;
        printf("DEBUG: Switching to LRU_BASED strategy (stable high-performance workload)\n");
    } else if (current_metrics.memory_usage_percent > 80.0 || current_metrics.cache_memory_usage_mb > 500.0) {
        // 内存压力大，使用TTL策略快速释放空间
        new_strategy = CacheEvictionStrategy::TTL_BASED;
        printf("DEBUG: Switching to TTL_BASED strategy (memory pressure)\n");
    }
    
    // 避免频繁切换策略
    if (new_strategy != old_strategy) {
        auto now = std::chrono::steady_clock::now();
        auto time_since_last_change = std::chrono::duration_cast<std::chrono::minutes>(
            now - tuning_stats.last_tuning_time).count();
        
        if (time_since_last_change < 5) { // 5分钟内不重复切换
            printf("DEBUG: Strategy change suppressed (too frequent)\n");
            return false;
        }
        
        cache_config.eviction_strategy = new_strategy;
        printf("DEBUG: Eviction strategy changed from %d to %d\n", (int)old_strategy, (int)new_strategy);
        return true;
    }
    
    return false;
}

void AdaptiveParameterTuner::UpdatePerformanceModel(const SystemPerformanceMetrics &metrics, double actual_performance) {
    // 简单的在线学习更新性能模型权重
    double predicted_performance = PredictPerformance({}, metrics); // 使用默认配置预测
    double error = actual_performance - predicted_performance;
    
    // 梯度下降更新
    double lr = config.learning_rate;
    performance_model.hit_rate_weight += lr * error * metrics.cache_hit_rate;
    performance_model.cache_size_weight += lr * error * 0.5; // 假设中等缓存大小
    performance_model.memory_weight += lr * error * (1.0 - metrics.memory_usage_percent / 100.0);
    performance_model.ttl_weight += lr * error * 0.5; // 假设中等TTL
    performance_model.bias += lr * error;
    
    printf("DEBUG: Updated performance model - hit_rate_weight=%.3f, error=%.3f\n", 
           performance_model.hit_rate_weight, error);
}

double AdaptiveParameterTuner::GetTrend(std::function<double(const SystemPerformanceMetrics&)> extractor) const {
    if (metrics_history.size() < 3) {
        return 0.0;
    }
    
    // 简单的线性趋势计算（最近值 - 较早值）
    size_t n = metrics_history.size();
    double recent_avg = 0.0;
    double early_avg = 0.0;
    
    // 取最近1/3的平均值
    size_t recent_count = std::max(1UL, n / 3);
    for (size_t i = n - recent_count; i < n; i++) {
        recent_avg += extractor(metrics_history[i]);
    }
    recent_avg /= recent_count;
    
    // 取较早1/3的平均值
    size_t early_count = std::max(1UL, n / 3);
    for (size_t i = 0; i < early_count; i++) {
        early_avg += extractor(metrics_history[i]);
    }
    early_avg /= early_count;
    
    return recent_avg - early_avg;
}

//===----------------------------------------------------------------------===//
// QueryCache Persistence Implementation
//===----------------------------------------------------------------------===//

bool QueryCache::SetPersistenceStrategy(CachePersistenceStrategy strategy, ClientContext *context) {
    // Placeholder implementation for persistence strategy
    return true;
}

QueryCache::PersistenceStats QueryCache::GetPersistenceStats() const {
    PersistenceStats stats;
    stats.storage_size_bytes = 0;
    stats.persisted_entries = 0;
    stats.memory_entries = cache.size();
    stats.disk_entries = 0;
    
    // TODO: 实现持久化统计信息的收集
    // 这里需要根据实际的持久化实现来填充统计信息
    
    return stats;
}

QueryCache::AdaptiveTuningStats QueryCache::GetAdaptiveTuningStats() const {
    AdaptiveTuningStats stats;
    stats.enabled = adaptive_tuner != nullptr;
    stats.current_metrics = current_metrics;
    
    if (adaptive_tuner) {
        auto tuning_stats = adaptive_tuner->GetTuningStats();
        stats.total_adjustments = tuning_stats.total_adjustments;
        stats.last_tuning_time = tuning_stats.last_tuning_time;
        
        // 计算平均性能改进（简化实现）
        if (tuning_stats.total_adjustments > 0) {
            stats.avg_performance_improvement = current_metrics.cache_hit_rate * 0.1; // 简化计算
        }
    } else {
        stats.total_adjustments = 0;
        stats.avg_performance_improvement = 0.0;
        stats.last_tuning_time = std::chrono::steady_clock::now();
    }
    
    return stats;
}

//===----------------------------------------------------------------------===//
// QueryCache Adaptive Tuning Methods
//===----------------------------------------------------------------------===//

void QueryCache::EnableAdaptiveTuning(bool enabled, AdaptiveTuningConfig tuning_config) {
    lock_guard<mutex> lock(cache_mutex);
    
    if (enabled && !adaptive_tuner) {
        adaptive_tuner = make_uniq<AdaptiveParameterTuner>(tuning_config);
        printf("DEBUG: Adaptive tuning enabled with interval=%llu ms\n", (unsigned long long)tuning_config.tuning_interval_ms);
    } else if (!enabled && adaptive_tuner) {
        adaptive_tuner.reset();
        printf("DEBUG: Adaptive tuning disabled\n");
    }
}

void QueryCache::UpdateSystemMetrics(const SystemPerformanceMetrics &metrics) {
    lock_guard<mutex> lock(cache_mutex);
    current_metrics = metrics;
    last_metrics_update = std::chrono::steady_clock::now();
    
    if (adaptive_tuner) {
        adaptive_tuner->UpdateMetrics(metrics, config);
    }
}

bool QueryCache::ForceAdaptiveTuning() {
    if (!adaptive_tuner) {
        printf("DEBUG: ForceAdaptiveTuning - adaptive tuner not enabled\n");
        return false;
    }
    
    lock_guard<mutex> lock(cache_mutex);
    
    // 收集当前系统指标
    current_metrics = CollectSystemMetrics();
    
    // 强制执行调优
    bool result = adaptive_tuner->ForceTuning(config);
    
    if (result) {
        printf("DEBUG: ForceAdaptiveTuning completed successfully\n");
        // 重新计算所有缓存条目的淘汰优先级
        for (auto &entry : cache) {
            if (config.eviction_strategy == CacheEvictionStrategy::ML_BASED) {
                entry.second->ml_score = ml_predictor.Predict(entry.second->ml_features);
                entry.second->eviction_priority = entry.second->ml_score;
            } else if (config.eviction_strategy == CacheEvictionStrategy::LRU_BASED) {
                entry.second->eviction_priority = static_cast<double>(
                    entry.second->last_accessed.time_since_epoch().count());
            } else {
                // TTL-based: priority based on creation time
                entry.second->eviction_priority = static_cast<double>(
                    entry.second->created_at.time_since_epoch().count());
            }
        }
    }
    
    return result;
}

SystemPerformanceMetrics QueryCache::CollectSystemMetrics() const {
    SystemPerformanceMetrics metrics;
    
    // 计算缓存相关指标
    auto stats = GetStats();
    metrics.cache_hit_rate = stats.hit_rate / 100.0; // 转换为0-1范围
    metrics.cache_memory_usage_mb = static_cast<double>(stats.memory_usage_bytes) / (1024.0 * 1024.0);
    
    // 计算平均查询时间（简化实现，基于缓存条目的访问模式）
    double total_complexity = 0.0;
    idx_t entry_count = 0;
    for (const auto &entry : cache) {
        total_complexity += entry.second->ml_features.execution_time_ms;
        entry_count++;
    }
    metrics.avg_query_time_ms = entry_count > 0 ? total_complexity / entry_count : 100.0;
    
    // 模拟系统指标（在实际实现中，这些应该从系统API获取）
    metrics.cpu_usage_percent = 50.0 + (rand() % 40); // 模拟50-90%的CPU使用率
    metrics.memory_usage_percent = 60.0 + (rand() % 30); // 模拟60-90%的内存使用率
    metrics.concurrent_queries = cache.size() / 10; // 简化的并发查询估算
    metrics.disk_io_rate_mbps = 10.0 + (rand() % 50); // 模拟10-60MB/s的I/O速率
    
    metrics.timestamp = std::chrono::steady_clock::now();
    
    return metrics;
}

double QueryCache::CalculateSystemLoad() const {
    auto metrics = CollectSystemMetrics();
    
    // 综合系统负载评分
    double load_score = 0.0;
    
    // CPU负载权重
    load_score += 0.3 * (metrics.cpu_usage_percent / 100.0);
    
    // 内存负载权重
    load_score += 0.3 * (metrics.memory_usage_percent / 100.0);
    
    // 缓存内存使用权重
    double cache_memory_ratio = metrics.cache_memory_usage_mb / (config.max_memory_bytes / (1024.0 * 1024.0));
    load_score += 0.2 * cache_memory_ratio;
    
    // 并发查询负载权重
    double concurrency_ratio = static_cast<double>(metrics.concurrent_queries) / 100.0; // 假设100为高并发
    load_score += 0.2 * std::min(1.0, concurrency_ratio);
    
    return std::min(1.0, load_score);
}

} // namespace duckdb