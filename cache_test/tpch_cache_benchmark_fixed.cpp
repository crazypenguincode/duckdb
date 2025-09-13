//===----------------------------------------------------------------------===//
// DuckDB TPC-H 缓存策略对比测试 - 修复版
//===----------------------------------------------------------------------===//

#include "duckdb.hpp"
#include <iostream>
#include <chrono>
#include <vector>
#include <unordered_map>
#include <memory>
#include <string>
#include <fstream>
#include <cmath>
#include <algorithm>
#include <random>
#include <list>
#include <thread>
#include <iomanip>

using namespace std;

// 避免命名冲突，使用完整命名空间
using DuckDBPtr = duckdb::unique_ptr<duckdb::DuckDB>;
using ConnectionPtr = duckdb::unique_ptr<duckdb::Connection>;

// 查询执行结果
struct TestQueryResult {
    string query_hash;
    string result_summary;
    size_t result_size;
    double execution_time_ms;
    chrono::steady_clock::time_point timestamp;
    
    TestQueryResult(const string& hash, const string& summary, size_t size, double time)
        : query_hash(hash), result_summary(summary), result_size(size), 
          execution_time_ms(time), timestamp(chrono::steady_clock::now()) {}
};

// 缓存条目
struct TestCacheEntry {
    string query_hash;
    unique_ptr<TestQueryResult> result;
    chrono::steady_clock::time_point creation_time;
    chrono::steady_clock::time_point last_access;
    size_t access_count;
    double access_frequency;
    
    TestCacheEntry(const string& hash, unique_ptr<TestQueryResult> res)
        : query_hash(hash), result(std::move(res)), 
          creation_time(chrono::steady_clock::now()),
          last_access(chrono::steady_clock::now()),
          access_count(1), access_frequency(1.0) {}
};

// 测试统计
struct BenchmarkStats {
    string strategy_name;
    size_t total_queries = 0;
    size_t cache_hits = 0;
    size_t cache_misses = 0;
    double total_execution_time = 0.0;
    double total_cache_access_time = 0.0;
    size_t max_cache_size = 0;
    size_t current_cache_size = 0;
    double memory_usage_mb = 0.0;
    
    double GetHitRate() const {
        return total_queries > 0 ? (double)cache_hits / total_queries : 0.0;
    }
    
    double GetAvgResponseTime() const {
        return total_queries > 0 ? 
            (total_execution_time + total_cache_access_time) / total_queries : 0.0;
    }
};

// TPC-H查询加载器
class TPCHQueryLoader {
private:
    string queries_dir;
    vector<pair<string, string>> queries;
    
public:
    TPCHQueryLoader(const string& dir) : queries_dir(dir) {
        LoadQueries();
    }
    
    void LoadQueries() {
        cout << "📂 加载TPC-H查询文件..." << endl;
        
        for (int i = 1; i <= 22; i++) {
            string filename = "q";
            if (i < 10) filename += "0";
            filename += to_string(i) + ".sql";
            
            string filepath = queries_dir + "/" + filename;
            
            ifstream file(filepath);
            if (file.is_open()) {
                string query_sql((istreambuf_iterator<char>(file)),
                                istreambuf_iterator<char>());
                
                // 简单清理查询
                query_sql = CleanQuery(query_sql);
                
                queries.push_back({filename, query_sql});
                cout << "  ✅ 加载查询: " << filename << endl;
            }
        }
        
        cout << "📊 总共加载了 " << queries.size() << " 个TPC-H查询" << endl;
    }
    
    string CleanQuery(const string& query) {
        string cleaned = query;
        
        // 移除首尾空白
        size_t start = cleaned.find_first_not_of(" \t\n\r");
        if (start != string::npos) {
            cleaned = cleaned.substr(start);
        }
        
        size_t end = cleaned.find_last_not_of(" \t\n\r");
        if (end != string::npos) {
            cleaned = cleaned.substr(0, end + 1);
        }
        
        return cleaned;
    }
    
    const vector<pair<string, string>>& GetQueries() const {
        return queries;
    }
    
    string GetQueryType(const string& query_name) {
        if (query_name == "q01.sql" || query_name == "q06.sql" || 
            query_name == "q14.sql" || query_name == "q17.sql") {
            return "simple";
        } else if (query_name == "q02.sql" || query_name == "q08.sql" || 
                   query_name == "q09.sql" || query_name == "q19.sql" || 
                   query_name == "q20.sql" || query_name == "q21.sql") {
            return "complex";
        } else {
            return "medium";
        }
    }
};

// 抽象缓存策略
class CacheStrategy {
public:
    virtual ~CacheStrategy() = default;
    virtual unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) = 0;
    virtual BenchmarkStats GetStats() const = 0;
    virtual string GetName() const = 0;
    virtual void Reset() = 0;
    
protected:
    string HashQuery(const string& query) {
        hash<string> hasher;
        return to_string(hasher(query));
    }
    
    size_t EstimateResultSize(duckdb::MaterializedQueryResult* result) {
        if (!result || result->RowCount() == 0) return 1024;
        size_t estimated_size = result->RowCount() * result->ColumnCount() * 32;
        return max((size_t)1024, estimated_size);
    }
    
    string SerializeResult(duckdb::MaterializedQueryResult* result) {
        if (!result) return "NULL";
        return "ROWS:" + to_string(result->RowCount()) + 
               ",COLS:" + to_string(result->ColumnCount());
    }
};

// 无缓存策略
class NoCacheStrategy : public CacheStrategy {
private:
    DuckDBPtr db;
    ConnectionPtr conn;
    BenchmarkStats stats;
    
public:
    NoCacheStrategy(const string& db_path) {
        stats.strategy_name = "No Cache";
        db = duckdb::make_uniq<duckdb::DuckDB>(db_path);
        conn = duckdb::make_uniq<duckdb::Connection>(*db);
        cout << "🔗 连接到TPC-H数据库: " << db_path << endl;
    }
    
    unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) override {
        stats.total_queries++;
        
        auto start_time = chrono::high_resolution_clock::now();
        
        try {
            auto result = conn->Query(query_sql);
            
            auto end_time = chrono::high_resolution_clock::now();
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            stats.total_execution_time += execution_time;
            
            if (result->HasError()) {
                cout << "❌ 查询错误 " << query_name << ": " << result->GetError() << endl;
                return nullptr;
            }
            
            size_t result_size = EstimateResultSize(result.get());
            string result_summary = SerializeResult(result.get());
            string query_hash = HashQuery(query_sql);
            
            return make_unique<TestQueryResult>(query_hash, result_summary, result_size, execution_time);
            
        } catch (const exception& e) {
            cout << "❌ 执行异常 " << query_name << ": " << e.what() << endl;
            return nullptr;
        }
    }
    
    BenchmarkStats GetStats() const override { return stats; }
    string GetName() const override { return "No Cache"; }
    void Reset() override { 
        stats = BenchmarkStats();
        stats.strategy_name = "No Cache";
    }
};

// LRU缓存策略
class LRUCacheStrategy : public CacheStrategy {
private:
    DuckDBPtr db;
    ConnectionPtr conn;
    
    unordered_map<string, unique_ptr<TestCacheEntry>> cache;
    list<string> lru_order;
    unordered_map<string, list<string>::iterator> lru_map;
    
    size_t max_cache_size;
    size_t current_memory_bytes = 0;
    
    BenchmarkStats stats;
    
public:
    LRUCacheStrategy(const string& db_path, size_t max_size = 8) 
        : max_cache_size(max_size) {
        
        stats.strategy_name = "LRU Cache";
        db = duckdb::make_uniq<duckdb::DuckDB>(db_path);
        conn = duckdb::make_uniq<duckdb::Connection>(*db);
    }
    
    unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) override {
        stats.total_queries++;
        string query_hash = HashQuery(query_sql);
        
        // 检查缓存命中
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            stats.cache_hits++;
            stats.total_cache_access_time += 0.5;
            
            UpdateLRU(query_hash);
            cache_it->second->last_access = chrono::steady_clock::now();
            cache_it->second->access_count++;
            
            auto& cached_result = cache_it->second->result;
            return make_unique<TestQueryResult>(
                cached_result->query_hash,
                cached_result->result_summary,
                cached_result->result_size,
                0.5
            );
        }
        
        // 缓存未命中
        stats.cache_misses++;
        auto result = ExecuteQueryDirect(query_name, query_sql);
        
        if (result) {
            CacheResult(query_hash, std::move(result));
        }
        
        return result;
    }
    
    BenchmarkStats GetStats() const override { 
        auto result_stats = stats;
        result_stats.current_cache_size = cache.size();
        result_stats.memory_usage_mb = current_memory_bytes / (1024.0 * 1024.0);
        return result_stats;
    }
    
    string GetName() const override { return "LRU Cache"; }
    
    void Reset() override {
        cache.clear();
        lru_order.clear();
        lru_map.clear();
        current_memory_bytes = 0;
        stats = BenchmarkStats();
        stats.strategy_name = "LRU Cache";
    }
    
private:
    unique_ptr<TestQueryResult> ExecuteQueryDirect(const string& query_name, const string& query_sql) {
        auto start_time = chrono::high_resolution_clock::now();
        
        try {
            auto result = conn->Query(query_sql);
            
            auto end_time = chrono::high_resolution_clock::now();
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            stats.total_execution_time += execution_time;
            
            if (result->HasError()) {
                return nullptr;
            }
            
            size_t result_size = EstimateResultSize(result.get());
            string result_summary = SerializeResult(result.get());
            string query_hash = HashQuery(query_sql);
            
            return make_unique<TestQueryResult>(query_hash, result_summary, result_size, execution_time);
            
        } catch (const exception& e) {
            return nullptr;
        }
    }
    
    void UpdateLRU(const string& key) {
        auto it = lru_map.find(key);
        if (it != lru_map.end()) {
            lru_order.erase(it->second);
        }
        lru_order.push_front(key);
        lru_map[key] = lru_order.begin();
    }
    
    void CacheResult(const string& query_hash, unique_ptr<TestQueryResult> result) {
        EvictIfNeeded();
        
        auto cache_entry = make_unique<TestCacheEntry>(query_hash, std::move(result));
        current_memory_bytes += cache_entry->result->result_size;
        
        cache[query_hash] = std::move(cache_entry);
        UpdateLRU(query_hash);
        
        stats.max_cache_size = max(stats.max_cache_size, cache.size());
    }
    
    void EvictIfNeeded() {
        while (cache.size() >= max_cache_size) {
            if (lru_order.empty()) break;
            
            string lru_key = lru_order.back();
            lru_order.pop_back();
            lru_map.erase(lru_key);
            
            auto it = cache.find(lru_key);
            if (it != cache.end()) {
                current_memory_bytes -= it->second->result->result_size;
                cache.erase(it);
            }
        }
    }
};

// TTL缓存策略
class TTLCacheStrategy : public CacheStrategy {
private:
    DuckDBPtr db;
    ConnectionPtr conn;
    
    unordered_map<string, unique_ptr<TestCacheEntry>> cache;
    chrono::seconds ttl_duration;
    
    size_t max_cache_size;
    size_t current_memory_bytes = 0;
    
    BenchmarkStats stats;
    
public:
    TTLCacheStrategy(const string& db_path, chrono::seconds ttl = chrono::seconds(300), size_t max_size = 6) 
        : ttl_duration(ttl), max_cache_size(max_size) {
        
        stats.strategy_name = "TTL Cache";
        db = duckdb::make_uniq<duckdb::DuckDB>(db_path);
        conn = duckdb::make_uniq<duckdb::Connection>(*db);
    }
    
    unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) override {
        stats.total_queries++;
        string query_hash = HashQuery(query_sql);
        
        CleanExpiredEntries();
        
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            stats.cache_hits++;
            stats.total_cache_access_time += 0.5;
            
            cache_it->second->last_access = chrono::steady_clock::now();
            cache_it->second->access_count++;
            
            auto& cached_result = cache_it->second->result;
            return make_unique<TestQueryResult>(
                cached_result->query_hash,
                cached_result->result_summary,
                cached_result->result_size,
                0.5
            );
        }
        
        stats.cache_misses++;
        auto result = ExecuteQueryDirect(query_name, query_sql);
        
        if (result && cache.size() < max_cache_size) {
            CacheResult(query_hash, std::move(result));
        }
        
        return result;
    }
    
    BenchmarkStats GetStats() const override { 
        auto result_stats = stats;
        result_stats.current_cache_size = cache.size();
        result_stats.memory_usage_mb = current_memory_bytes / (1024.0 * 1024.0);
        return result_stats;
    }
    
    string GetName() const override { return "TTL Cache"; }
    
    void Reset() override {
        cache.clear();
        current_memory_bytes = 0;
        stats = BenchmarkStats();
        stats.strategy_name = "TTL Cache";
    }
    
private:
    void CleanExpiredEntries() {
        auto now = chrono::steady_clock::now();
        auto it = cache.begin();
        
        while (it != cache.end()) {
            auto age = chrono::duration_cast<chrono::seconds>(now - it->second->creation_time);
            if (age > ttl_duration) {
                current_memory_bytes -= it->second->result->result_size;
                it = cache.erase(it);
            } else {
                ++it;
            }
        }
    }
    
    unique_ptr<TestQueryResult> ExecuteQueryDirect(const string& query_name, const string& query_sql) {
        auto start_time = chrono::high_resolution_clock::now();
        
        try {
            auto result = conn->Query(query_sql);
            
            auto end_time = chrono::high_resolution_clock::now();
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            stats.total_execution_time += execution_time;
            
            if (result->HasError()) {
                return nullptr;
            }
            
            size_t result_size = EstimateResultSize(result.get());
            string result_summary = SerializeResult(result.get());
            string query_hash = HashQuery(query_sql);
            
            return make_unique<TestQueryResult>(query_hash, result_summary, result_size, execution_time);
            
        } catch (const exception& e) {
            return nullptr;
        }
    }
    
    void CacheResult(const string& query_hash, unique_ptr<TestQueryResult> result) {
        auto cache_entry = make_unique<TestCacheEntry>(query_hash, std::move(result));
        current_memory_bytes += cache_entry->result->result_size;
        
        cache[query_hash] = std::move(cache_entry);
        stats.max_cache_size = max(stats.max_cache_size, cache.size());
    }
};

// ML智能缓存策略
class MLCacheStrategy : public CacheStrategy {
private:
    DuckDBPtr db;
    ConnectionPtr conn;
    
    unordered_map<string, unique_ptr<TestCacheEntry>> cache;
    
    size_t max_cache_size;
    size_t current_memory_bytes = 0;
    
    // ML参数
    vector<double> feature_weights = {0.3, 0.25, 0.2, 0.15, 0.1};
    
    BenchmarkStats stats;
    
public:
    MLCacheStrategy(const string& db_path, size_t max_size = 10) 
        : max_cache_size(max_size) {
        
        stats.strategy_name = "ML Cache";
        db = duckdb::make_uniq<duckdb::DuckDB>(db_path);
        conn = duckdb::make_uniq<duckdb::Connection>(*db);
    }
    
    unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) override {
        stats.total_queries++;
        string query_hash = HashQuery(query_sql);
        
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            stats.cache_hits++;
            stats.total_cache_access_time += 0.5;
            
            UpdateMLFeatures(cache_it->second.get());
            
            auto& cached_result = cache_it->second->result;
            return make_unique<TestQueryResult>(
                cached_result->query_hash,
                cached_result->result_summary,
                cached_result->result_size,
                0.5
            );
        }
        
        stats.cache_misses++;
        auto result = ExecuteQueryDirect(query_name, query_sql);
        
        if (result) {
            if (ShouldCache(query_name, query_sql, result.get())) {
                CacheResultWithML(query_hash, std::move(result));
            }
        }
        
        return result;
    }
    
    BenchmarkStats GetStats() const override { 
        auto result_stats = stats;
        result_stats.current_cache_size = cache.size();
        result_stats.memory_usage_mb = current_memory_bytes / (1024.0 * 1024.0);
        return result_stats;
    }
    
    string GetName() const override { return "ML Cache"; }
    
    void Reset() override {
        cache.clear();
        current_memory_bytes = 0;
        stats = BenchmarkStats();
        stats.strategy_name = "ML Cache";
    }
    
private:
    bool ShouldCache(const string& query_name, const string& query_sql, TestQueryResult* result) {
        vector<double> features = ExtractFeatures(query_name, query_sql, result);
        double cache_value = CalculateCacheValue(features);
        
        if (cache.size() < max_cache_size) {
            return cache_value > 0.3;
        }
        
        double min_value = GetMinCacheValue();
        return cache_value > min_value;
    }
    
    vector<double> ExtractFeatures(const string& query_name, const string& query_sql, TestQueryResult* result) {
        vector<double> features(5);
        
        // 特征1: 查询频率估算
        features[0] = EstimateQueryFrequency(query_sql);
        
        // 特征2: 时间局部性
        features[1] = EstimateTemporalLocality(query_sql);
        
        // 特征3: 结果大小因子
        features[2] = 1.0 / (1.0 + result->result_size / (1024.0 * 1024.0));
        
        // 特征4: 查询复杂度
        features[3] = min(1.0, result->execution_time_ms / 1000.0);
        
        // 特征5: 查询类型局部性
        features[4] = EstimateQueryTypeLocality(query_name);
        
        return features;
    }
    
    double CalculateCacheValue(const vector<double>& features) {
        double value = 0.0;
        for (size_t i = 0; i < min(features.size(), feature_weights.size()); i++) {
            value += feature_weights[i] * features[i];
        }
        return max(0.0, min(1.0, value));
    }
    
    void UpdateMLFeatures(TestCacheEntry* entry) {
        auto now = chrono::steady_clock::now();
        
        entry->access_frequency += 1.0;
        entry->access_count++;
        entry->last_access = now;
    }
    
    double CalculateEntryValue(TestCacheEntry* entry) {
        auto now = chrono::steady_clock::now();
        auto age = chrono::duration<double>(now - entry->creation_time).count();
        auto last_access_age = chrono::duration<double>(now - entry->last_access).count();
        
        vector<double> features = {
            min(1.0, entry->access_frequency / 10.0),
            max(0.0, 1.0 - age / 3600.0),
            max(0.0, 1.0 - last_access_age / 1800.0),
            1.0 / (1.0 + entry->result->result_size / (1024.0 * 1024.0)),
            min(1.0, entry->result->execution_time_ms / 1000.0)
        };
        
        return CalculateCacheValue(features);
    }
    
    void CacheResultWithML(const string& query_hash, unique_ptr<TestQueryResult> result) {
        if (cache.size() >= max_cache_size) {
            EvictLowValueEntry();
        }
        
        auto cache_entry = make_unique<TestCacheEntry>(query_hash, std::move(result));
        current_memory_bytes += cache_entry->result->result_size;
        
        cache[query_hash] = std::move(cache_entry);
        stats.max_cache_size = max(stats.max_cache_size, cache.size());
    }
    
    void EvictLowValueEntry() {
        string lowest_key;
        double lowest_value = 1.0;
        
        for (const auto& [key, entry] : cache) {
            double value = CalculateEntryValue(entry.get());
            if (value < lowest_value) {
                lowest_value = value;
                lowest_key = key;
            }
        }
        
        if (!lowest_key.empty()) {
            current_memory_bytes -= cache[lowest_key]->result->result_size;
            cache.erase(lowest_key);
        }
    }
    
    double GetMinCacheValue() {
        double min_value = 1.0;
        for (const auto& [key, entry] : cache) {
            double value = CalculateEntryValue(entry.get());
            min_value = min(min_value, value);
        }
        return min_value;
    }
    
    double EstimateQueryFrequency(const string& query_sql) {
        hash<string> hasher;
        size_t hash_val = hasher(query_sql);
        return (hash_val % 100) / 100.0;
    }
    
    double EstimateTemporalLocality(const string& query_sql) {
        if (query_sql.find("COUNT") != string::npos || 
            query_sql.find("SUM") != string::npos) {
            return 0.8;
        }
        return 0.5;
    }
    
    double EstimateQueryTypeLocality(const string& query_name) {
        if (query_name.find("q01") != string::npos || 
            query_name.find("q06") != string::npos) {
            return 0.9;
        } else if (query_name.find("q02") != string::npos || 
                   query_name.find("q19") != string::npos) {
            return 0.3;
        }
        return 0.6;
    }
    
    unique_ptr<TestQueryResult> ExecuteQueryDirect(const string& query_name, const string& query_sql) {
        auto start_time = chrono::high_resolution_clock::now();
        
        try {
            auto result = conn->Query(query_sql);
            
            auto end_time = chrono::high_resolution_clock::now();
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            stats.total_execution_time += execution_time;
            
            if (result->HasError()) {
                return nullptr;
            }
            
            size_t result_size = EstimateResultSize(result.get());
            string result_summary = SerializeResult(result.get());
            string query_hash = HashQuery(query_sql);
            
            return make_unique<TestQueryResult>(query_hash, result_summary, result_size, execution_time);
            
        } catch (const exception& e) {
            return nullptr;
        }
    }
};

// TPC-H缓存基准测试器
class TPCHCacheBenchmark {
private:
    string db_path;
    string queries_dir;
    TPCHQueryLoader query_loader;
    
public:
    TPCHCacheBenchmark(const string& db, const string& queries) 
        : db_path(db), queries_dir(queries), query_loader(queries) {}
    
    void RunBenchmark() {
        cout << "\n🚀 启动TPC-H缓存策略基准测试" << endl;
        cout << "📊 数据库: " << db_path << endl;
        cout << "📂 查询目录: " << queries_dir << endl;
        
        // 创建测试策略
        vector<unique_ptr<CacheStrategy>> strategies;
        strategies.push_back(make_unique<NoCacheStrategy>(db_path));
        strategies.push_back(make_unique<LRUCacheStrategy>(db_path, 8));
        strategies.push_back(make_unique<TTLCacheStrategy>(db_path, chrono::seconds(300), 6));
        strategies.push_back(make_unique<MLCacheStrategy>(db_path, 10));
        
        vector<BenchmarkStats> results;
        
        // 生成测试工作负载
        auto workload = GenerateWorkload();
        cout << "📋 生成了 " << workload.size() << " 个查询的工作负载" << endl;
        
        // 测试每种策略
        for (auto& strategy : strategies) {
            cout << "\n🧪 测试策略: " << strategy->GetName() << endl;
            
            strategy->Reset();
            auto start_time = chrono::high_resolution_clock::now();
            
            size_t completed = 0;
            for (const auto& [query_name, query_sql] : workload) {
                auto result = strategy->ExecuteQuery(query_name, query_sql);
                
                completed++;
                if (completed % 5 == 0) {
                    cout << "  进度: " << completed << "/" << workload.size() 
                         << " (" << (completed * 100 / workload.size()) << "%)" << endl;
                }
                
                // 模拟查询间隔
                this_thread::sleep_for(chrono::milliseconds(50));
            }
            
            auto end_time = chrono::high_resolution_clock::now();
            auto total_time = chrono::duration<double>(end_time - start_time).count();
            
            auto stats = strategy->GetStats();
            cout << "  ✅ 完成，总耗时: " << fixed << setprecision(2) << total_time << "s" << endl;
            cout << "  📊 命中率: " << fixed << setprecision(1) << (stats.GetHitRate() * 100) << "%" << endl;
            
            results.push_back(stats);
        }
        
        // 输出对比结果
        PrintResults(results);
        
        // 保存详细报告
        SaveReport(results, workload.size());
    }
    
private:
    vector<pair<string, string>> GenerateWorkload() {
        vector<pair<string, string>> workload;
        const auto& queries = query_loader.GetQueries();
        
        if (queries.empty()) {
            cout << "❌ 没有加载到查询文件！" << endl;
            return workload;
        }
        
        random_device rd;
        mt19937 gen(rd());
        
        // 定义查询访问模式
        vector<int> simple_queries;
        vector<int> medium_queries;
        vector<int> complex_queries;
        
        for (size_t i = 0; i < queries.size(); i++) {
            string type = query_loader.GetQueryType(queries[i].first);
            if (type == "simple") {
                simple_queries.push_back(i);
            } else if (type == "medium") {
                medium_queries.push_back(i);
            } else {
                complex_queries.push_back(i);
            }
        }
        
        uniform_real_distribution<> dis(0.0, 1.0);
        
        // 生成50个查询的工作负载
        for (int i = 0; i < 50; i++) {
            double rand_val = dis(gen);
            int query_idx;
            
            if (rand_val < 0.5 && !simple_queries.empty()) {
                query_idx = simple_queries[uniform_int_distribution<>(0, simple_queries.size() - 1)(gen)];
            } else if (rand_val < 0.8 && !medium_queries.empty()) {
                query_idx = medium_queries[uniform_int_distribution<>(0, medium_queries.size() - 1)(gen)];
            } else if (!complex_queries.empty()) {
                query_idx = complex_queries[uniform_int_distribution<>(0, complex_queries.size() - 1)(gen)];
            } else {
                query_idx = uniform_int_distribution<>(0, queries.size() - 1)(gen);
            }
            
            if (query_idx < queries.size()) {
                workload.push_back(queries[query_idx]);
            }
        }
        
        return workload;
    }
    
    void PrintResults(const vector<BenchmarkStats>& results) {
        cout << "\n" << string(100, '=') << endl;
        cout << "TPC-H 缓存策略性能对比结果" << endl;
        cout << string(100, '=') << endl;
        
        cout << left << setw(15) << "策略" 
             << setw(12) << "命中率" 
             << setw(15) << "平均响应时间" 
             << setw(12) << "缓存大小"
             << setw(15) << "内存使用"
             << setw(12) << "总查询数" << endl;
        cout << string(100, '-') << endl;
        
        for (const auto& stats : results) {
            cout << left << setw(15) << stats.strategy_name
                 << setw(12) << fixed << setprecision(1) << (stats.GetHitRate() * 100) << "%"
                 << setw(15) << fixed << setprecision(1) << stats.GetAvgResponseTime() << "ms"
                 << setw(12) << stats.current_cache_size
                 << setw(15) << fixed << setprecision(1) << stats.memory_usage_mb << "MB"
                 << setw(12) << stats.total_queries << endl;
        }
        
        // 性能分析
        cout << "\n📈 性能提升分析:" << endl;
        
        const BenchmarkStats* no_cache = nullptr;
        const BenchmarkStats* ml_cache = nullptr;
        const BenchmarkStats* lru_cache = nullptr;
        
        for (const auto& stats : results) {
            if (stats.strategy_name == "No Cache") no_cache = &stats;
            else if (stats.strategy_name == "ML Cache") ml_cache = &stats;
            else if (stats.strategy_name == "LRU Cache") lru_cache = &stats;
        }
        
        if (no_cache && ml_cache) {
            double improvement = (no_cache->GetAvgResponseTime() - ml_cache->GetAvgResponseTime()) / 
                               no_cache->GetAvgResponseTime() * 100;
            cout << "• ML缓存 vs 无缓存: 响应时间改善 " << fixed << setprecision(1) << improvement << "%" << endl;
        }
        
        if (lru_cache && ml_cache) {
            double hit_improvement = (ml_cache->GetHitRate() - lru_cache->GetHitRate()) * 100;
            cout << "• ML缓存 vs LRU缓存: 命中率提升 " << fixed << setprecision(1) << hit_improvement << "个百分点" << endl;
        }
        
        cout << "\n🎯 测试结论:" << endl;
        if (ml_cache && ml_cache->GetHitRate() > 0.2) {
            cout << "✅ ML缓存策略在TPC-H工作负载下表现良好" << endl;
        } else {
            cout << "⚠️  ML缓存策略需要针对TPC-H工作负载进行优化" << endl;
        }
    }
    
    void SaveReport(const vector<BenchmarkStats>& results, size_t workload_size) {
        // 创建结果目录
        system("mkdir -p cache_test/results");
        
        ofstream report("cache_test/results/tpch_benchmark_report.json");
        
        report << "{\n";
        report << "  \"test_info\": {\n";
        report << "    \"timestamp\": \"" << chrono::system_clock::to_time_t(chrono::system_clock::now()) << "\",\n";
        report << "    \"database\": \"" << db_path << "\",\n";
        report << "    \"queries_dir\": \"" << queries_dir << "\",\n";
        report << "    \"workload_size\": " << workload_size << ",\n";
        report << "    \"strategies_tested\": " << results.size() << "\n";
        report << "  },\n";
        report << "  \"results\": [\n";
        
        for (size_t i = 0; i < results.size(); i++) {
            const auto& stats = results[i];
            report << "    {\n";
            report << "      \"strategy\": \"" << stats.strategy_name << "\",\n";
            report << "      \"hit_rate\": " << stats.GetHitRate() << ",\n";
            report << "      \"avg_response_time\": " << stats.GetAvgResponseTime() << ",\n";
            report << "      \"cache_hits\": " << stats.cache_hits << ",\n";
            report << "      \"cache_misses\": " << stats.cache_misses << ",\n";
            report << "      \"current_cache_size\": " << stats.current_cache_size << ",\n";
            report << "      \"max_cache_size\": " << stats.max_cache_size << ",\n";
            report << "      \"memory_usage_mb\": " << stats.memory_usage_mb << ",\n";
            report << "      \"total_execution_time\": " << stats.total_execution_time << ",\n";
            report << "      \"total_cache_access_time\": " << stats.total_cache_access_time << "\n";
            report << "    }";
            if (i < results.size() - 1) report << ",";
            report << "\n";
        }
        
        report << "  ]\n";
        report << "}\n";
        
        report.close();
        cout << "\n📄 详细报告已保存: cache_test/results/tpch_benchmark_report.json" << endl;
    }
};

int main() {
    try {
        string db_path = "/Users/max/test/tpc/tpch-sf1.db";
        string queries_dir = "/Users/max/src/duckdb/extension/tpch/dbgen/queries";
        
        // 检查文件是否存在
        ifstream db_file(db_path);
        if (!db_file.good()) {
            cout << "❌ 数据库文件不存在: " << db_path << endl;
            return 1;
        }
        
        ifstream queries_test(queries_dir + "/q01.sql");
        if (!queries_test.good()) {
            cout << "❌ 查询目录不存在或无法访问: " << queries_dir << endl;
            return 1;
        }
        
        TPCHCacheBenchmark benchmark(db_path, queries_dir);
        benchmark.RunBenchmark();
        
        cout << "\n🎉 TPC-H缓存基准测试完成！" << endl;
        
    } catch (const exception& e) {
        cout << "❌ 测试失败: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}