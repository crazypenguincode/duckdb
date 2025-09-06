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

namespace duckdb {

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
};

//! Query result cache with bloom filter for fast lookups
class QueryCache {
public:
    explicit QueryCache(QueryCacheConfig config = QueryCacheConfig());
    ~QueryCache() = default;

    //! Check if a query result might be cached (using bloom filter)
    bool MightBeCached(const string &query_hash) const;
    
    //! Get cached result for a query
    unique_ptr<MaterializedQueryResult> GetCachedResult(const string &query_hash);
    
    //! Cache a query result
    void CacheResult(const string &query_hash, unique_ptr<MaterializedQueryResult> result);
    
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
    };
    CacheStats GetStats() const;
    
    //! Update configuration
    void UpdateConfig(const QueryCacheConfig &new_config);
    
    //! Check if caching is enabled
    bool IsEnabled() const { return config.enabled; }

private:
    //! Configuration
    QueryCacheConfig config;
    
    //! Bloom filter for fast negative lookups
    mutable BloomFilter bloom_filter;
    
    //! Actual cache storage
    unordered_map<string, unique_ptr<QueryCacheEntry>> cache;
    
    //! Mutex for thread safety
    mutable mutex cache_mutex;
    
    //! Statistics
    mutable idx_t total_hits = 0;
    mutable idx_t total_misses = 0;
    
    //! Evict old or least recently used entries
    void EvictIfNeeded();
    
    //! Calculate memory usage of a result
    idx_t CalculateMemoryUsage(const MaterializedQueryResult &result) const;
    
    //! Check if an entry has expired
    bool IsExpired(const QueryCacheEntry &entry) const;
    
    //! Remove expired entries
    void RemoveExpiredEntries();
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
    
private:
    //! Normalize a query string for consistent caching
    static string NormalizeQuery(const string &query);
    
    //! Extract table dependencies from a statement
    static vector<string> ExtractTableDependencies(const SQLStatement &statement);
};

} // namespace duckdb