//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache.cpp
//
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
#include <regex>

namespace duckdb {

QueryCache::QueryCache(QueryCacheConfig config) 
    : config(std::move(config)), 
      bloom_filter(this->config.bloom_filter_size, this->config.bloom_filter_hash_functions) {
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

void QueryCache::CacheResult(const string &query_hash, unique_ptr<MaterializedQueryResult> result) {
    if (!config.enabled || !result || result->HasError()) {
        return;
    }
    
    lock_guard<mutex> lock(cache_mutex);
    
    // Add to bloom filter
    bloom_filter.Add(query_hash);
    
    // Create cache entry
    auto entry = make_uniq<QueryCacheEntry>(std::move(result));
    
    // Insert into cache
    cache[query_hash] = std::move(entry);
    
    // Evict if necessary
    EvictIfNeeded();
}

void QueryCache::Clear() {
    lock_guard<mutex> lock(cache_mutex);
    cache.clear();
    bloom_filter.Clear();
    total_hits = 0;
    total_misses = 0;
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
    
    // Calculate memory usage
    stats.memory_usage_bytes = 0;
    for (const auto &entry : cache) {
        stats.memory_usage_bytes += CalculateMemoryUsage(*entry.second->result);
    }
    
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

void QueryCache::EvictIfNeeded() {
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
    switch (statement.type) {
    case StatementType::SELECT_STATEMENT:
        return true;
    case StatementType::EXPLAIN_STATEMENT: {
        // Check if it's explaining a SELECT
        auto &explain = static_cast<const ExplainStatement &>(statement);
        return explain.stmt && explain.stmt->type == StatementType::SELECT_STATEMENT;
    }
    default:
        return false;
    }
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

} // namespace duckdb