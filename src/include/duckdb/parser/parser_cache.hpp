//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/parser/parser_cache.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/common.hpp"
#include "duckdb/common/unordered_map.hpp"
#include "duckdb/common/unique_ptr.hpp"
#include "duckdb/common/mutex.hpp"
#include "duckdb/parser/sql_statement.hpp"
#include "duckdb/common/preserved_error.hpp"
#include "duckdb/common/bloom_filter.hpp"

namespace duckdb {

struct CachedQueryResult {
    vector<unique_ptr<SQLStatement>> statements;
    PreservedError error;
    bool success;
    time_t parse_time;
};

class ParserCache {
public:
    static ParserCache &Get();

    optional_ptr<CachedQueryResult> GetCachedResult(const string &query);
    void CacheResult(const string &query, vector<unique_ptr<SQLStatement>> statements,
                    const PreservedError &error, bool success);
    void ClearCache();

private:
    static constexpr size_t MAX_CACHE_SIZE = 100;
    mutex cache_lock;
    unordered_map<string, unique_ptr<CachedQueryResult>> query_cache;
    BloomFilter bloom_filter;
};

} // namespace duckdb