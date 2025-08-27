//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/parser/parser_cache.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/parser/parser_cache.hpp"
#include "duckdb/common/mutex.hpp"
#include "duckdb/common/unordered_map.hpp"
#include "duckdb/parser/sql_statement.hpp"
#include "duckdb/common/helper.hpp"
#include "duckdb/common/chrono.hpp"
#include "duckdb/common/bloom_filter.hpp"

namespace duckdb {

ParserCache& ParserCache::Get() {
    static ParserCache instance;
    return instance;
}

optional_ptr<CachedQueryResult> ParserCache::GetCachedResult(const string &query) {
    // 先检查布隆过滤器
    if (!bloom_filter.MayContain(query)) {
        return nullptr;
    }

    lock_guard<mutex> lock(cache_lock);
    auto it = query_cache.find(query);
    if (it != query_cache.end()) {
        return it->second.get();
    }
    return nullptr;
}

void ParserCache::CacheResult(const string &query, vector<unique_ptr<SQLStatement>> statements,
                            const PreservedError &error, bool success) {
    lock_guard<mutex> lock(cache_lock);

    // 如果缓存已满，移除最旧的条目
    if (query_cache.size() >= MAX_CACHE_SIZE) {
        auto oldest = query_cache.begin();
        bloom_filter.Remove(oldest->first);
        query_cache.erase(oldest);
    }

    auto cached_result = make_uniq<CachedQueryResult>();
    cached_result->statements = std::move(statements);
    cached_result->error = error;
    cached_result->success = success;
    cached_result->parse_time = CurrentTimestamp();

    query_cache[query] = std::move(cached_result);
    bloom_filter.Insert(query);
}

void ParserCache::ClearCache() {
    lock_guard<mutex> lock(cache_lock);
    query_cache.clear();
    bloom_filter.Clear();
}

} // namespace duckdb