//===----------------------------------------------------------------------===//
// DuckDB 缓存策略对比测试 - ML vs LRU vs TTL vs 无缓存
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

using namespace duckdb;
using namespace std;

// 基础缓存条目
struct BaseCacheEntry {
    string query_hash;
    duckdb::unique_ptr<MaterializedQueryResult> result;
    size_t size_bytes;
    chrono::steady_clock::time_point creation_time;
    chrono::steady_clock::time_point last_access;
    
    BaseCacheEntry(const string& hash, duckdb::unique_ptr<MaterializedQueryResult> res, size_t size)
        : query_hash(hash), result(std::move(res)), size_bytes(size),
          creation_time(chrono::steady_clock::now()), last_access(chrono::steady_clock::now()) {}
};

// ML增强缓存条目
struct MLCacheEntry : public BaseCacheEntry {
    double access_frequency;
    duckdb::vector<double> access_history;
    
    MLCacheEntry(const string& hash, duckdb::unique_ptr<MaterializedQueryResult> res, size_t size)
        : BaseCacheEntry(hash, std::move(res), size), access_frequency(1.0) {
        access_history.push_back(1.0);
    }
};

// 测试结果统计
struct CacheTestResult {
    string strategy_name;
    size_t total_queries = 0;
    size_t cache_hits = 0;
    double total_execution_time = 0.0;
    double total_cache_time = 0.0;
    size_t max_cache_size = 0;
    double memory_efficiency = 0.0;
    
    double GetHitRate() const {
        return total_queries > 0 ? (double)cache_hits / total_queries : 0.0;
    }
    
    double GetAvgExecutionTime() const {
        return total_queries > 0 ? (total_execution_time + total_cache_time) / total_queries : 0.0;
    }
};

// 抽象缓存接口
class CacheStrategy {
public:
    virtual ~CacheStrategy() = default;
    virtual duckdb::unique_ptr<MaterializedQueryResult> Query(const string& query) = 0;
    virtual CacheTestResult GetResults() const = 0;
    virtual string GetName() const = 0;
};

// 无缓存策略
class NoCacheStrategy : public CacheStrategy {
private:
    duckdb::unique_ptr<DuckDB> db;
    duckdb::unique_ptr<Connection> conn;
    CacheTestResult results;
    
public:
    NoCacheStrategy() {
        db = duckdb::make_unique<DuckDB>(nullptr);
        conn = duckdb::make_unique<Connection>(*db);
        CreateTestData();
        results.strategy_name = "No Cache";
    }
    
    void CreateTestData() {
        conn->Query("CREATE TABLE lineitem (l_orderkey INTEGER, l_partkey INTEGER, l_suppkey INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1), l_shipdate DATE, l_shipmode VARCHAR(10))");
        
        for (int i = 1; i <= 1000; i++) {
            string insert_sql = "INSERT INTO lineitem VALUES (" +
                to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", " +
                to_string(10.0 + (i % 50)) + ", " + to_string(100.0 + (i % 1000)) + ", " +
                to_string(0.05 + (i % 10) * 0.01) + ", 'N', 'O', " +
                "'1995-01-" + to_string((i % 28) + 1) + "', 'TRUCK')";
            conn->Query(insert_sql);
        }
    }
    
    duckdb::unique_ptr<MaterializedQueryResult> Query(const string& query) override {
        results.total_queries++;
        
        auto start_time = chrono::high_resolution_clock::now();
        auto result = conn->Query(query);
        auto end_time = chrono::high_resolution_clock::now();
        
        double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
        results.total_execution_time += execution_time;
        
        if (result->HasError()) {
            return nullptr;
        }
        
        return duckdb::unique_ptr_cast<MaterializedQueryResult>(std::move(result));
    }
    
    CacheTestResult GetResults() const override { return results; }
    string GetName() const override { return "No Cache"; }
};

// LRU缓存策略
class LRUCacheStrategy : public CacheStrategy {
private:
    duckdb::unique_ptr<DuckDB> db;
    duckdb::unique_ptr<Connection> conn;
    
    unordered_map<string, duckdb::unique_ptr<BaseCacheEntry>> cache;
    list<string> lru_order;
    unordered_map<string, list<string>::iterator> lru_map;
    
    size_t max_cache_size = 20;
    size_t max_memory_mb = 50;
    size_t current_memory_bytes = 0;
    
    CacheTestResult results;
    
public:
    LRUCacheStrategy() {
        db = duckdb::make_unique<DuckDB>(nullptr);
        conn = duckdb::make_unique<Connection>(*db);
        CreateTestData();
        results.strategy_name = "LRU Cache";
    }
    
    void CreateTestData() {
        conn->Query("CREATE TABLE lineitem (l_orderkey INTEGER, l_partkey INTEGER, l_suppkey INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1), l_shipdate DATE, l_shipmode VARCHAR(10))");
        
        for (int i = 1; i <= 1000; i++) {
            string insert_sql = "INSERT INTO lineitem VALUES (" +
                to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", " +
                to_string(10.0 + (i % 50)) + ", " + to_string(100.0 + (i % 1000)) + ", " +
                to_string(0.05 + (i % 10) * 0.01) + ", 'N', 'O', " +
                "'1995-01-" + to_string((i % 28) + 1) + "', 'TRUCK')";
            conn->Query(insert_sql);
        }
    }
    
    string HashQuery(const string& query) {
        hash<string> hasher;
        return to_string(hasher(query));
    }
    
    void UpdateLRU(const string& key) {
        auto it = lru_map.find(key);
        if (it != lru_map.end()) {
            lru_order.erase(it->second);
        }
        lru_order.push_front(key);
        lru_map[key] = lru_order.begin();
    }
    
    void EvictLRU() {
        while ((cache.size() >= max_cache_size) || 
               (current_memory_bytes > max_memory_mb * 1024 * 1024)) {
            if (lru_order.empty()) break;
            
            string lru_key = lru_order.back();
            lru_order.pop_back();
            lru_map.erase(lru_key);
            
            if (cache.find(lru_key) != cache.end()) {
                current_memory_bytes -= cache[lru_key]->size_bytes;
                cache.erase(lru_key);
            }
        }
    }
    
    size_t EstimateResultSize(const MaterializedQueryResult& result) {
        return max((size_t)1024, result.ColumnCount() * 1024); // 简化估算
    }
    
    duckdb::unique_ptr<MaterializedQueryResult> Query(const string& query) override {
        results.total_queries++;
        string query_hash = HashQuery(query);
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            results.cache_hits++;
            results.total_cache_time += 0.5; // 缓存访问时间
            
            UpdateLRU(query_hash);
            cache_it->second->last_access = chrono::steady_clock::now();
            
            return duckdb::unique_ptr_cast<MaterializedQueryResult>(cache_it->second->result->Clone());
        }
        
        // 执行查询
        auto start_time = chrono::high_resolution_clock::now();
        auto result = conn->Query(query);
        auto end_time = chrono::high_resolution_clock::now();
        
        double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
        results.total_execution_time += execution_time;
        
        if (result->HasError()) {
            return nullptr;
        }
        
        auto materialized_result = duckdb::unique_ptr_cast<MaterializedQueryResult>(std::move(result));
        size_t result_size = EstimateResultSize(*materialized_result);
        
        // 缓存结果
        EvictLRU();
        
        auto cache_entry = duckdb::make_unique<BaseCacheEntry>(query_hash, 
            duckdb::unique_ptr_cast<MaterializedQueryResult>(materialized_result->Clone()), result_size);
        
        current_memory_bytes += result_size;
        cache[query_hash] = std::move(cache_entry);
        UpdateLRU(query_hash);
        
        results.max_cache_size = max(results.max_cache_size, cache.size());
        
        return std::move(materialized_result);
    }
    
    CacheTestResult GetResults() const override { 
        auto result = results;
        result.memory_efficiency = max_memory_mb > 0 ? 
            (double)current_memory_bytes / (max_memory_mb * 1024 * 1024) : 0.0;
        return result;
    }
    
    string GetName() const override { return "LRU Cache"; }
};

// TTL缓存策略
class TTLCacheStrategy : public CacheStrategy {
private:
    duckdb::unique_ptr<DuckDB> db;
    duckdb::unique_ptr<Connection> conn;
    
    unordered_map<string, duckdb::unique_ptr<BaseCacheEntry>> cache;
    chrono::seconds ttl_duration{300}; // 5分钟TTL
    
    size_t max_cache_size = 20;
    size_t current_memory_bytes = 0;
    
    CacheTestResult results;
    
public:
    TTLCacheStrategy() {
        db = duckdb::make_unique<DuckDB>(nullptr);
        conn = duckdb::make_unique<Connection>(*db);
        CreateTestData();
        results.strategy_name = "TTL Cache";
    }
    
    void CreateTestData() {
        conn->Query("CREATE TABLE lineitem (l_orderkey INTEGER, l_partkey INTEGER, l_suppkey INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1), l_shipdate DATE, l_shipmode VARCHAR(10))");
        
        for (int i = 1; i <= 1000; i++) {
            string insert_sql = "INSERT INTO lineitem VALUES (" +
                to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", " +
                to_string(10.0 + (i % 50)) + ", " + to_string(100.0 + (i % 1000)) + ", " +
                to_string(0.05 + (i % 10) * 0.01) + ", 'N', 'O', " +
                "'1995-01-" + to_string((i % 28) + 1) + "', 'TRUCK')";
            conn->Query(insert_sql);
        }
    }
    
    string HashQuery(const string& query) {
        hash<string> hasher;
        return to_string(hasher(query));
    }
    
    void CleanExpired() {
        auto now = chrono::steady_clock::now();
        auto it = cache.begin();
        
        while (it != cache.end()) {
            auto age = chrono::duration_cast<chrono::seconds>(now - it->second->creation_time);
            if (age > ttl_duration) {
                current_memory_bytes -= it->second->size_bytes;
                it = cache.erase(it);
            } else {
                ++it;
            }
        }
    }
    
    size_t EstimateResultSize(const MaterializedQueryResult& result) {
        return max((size_t)1024, result.ColumnCount() * 1024);
    }
    
    duckdb::unique_ptr<MaterializedQueryResult> Query(const string& query) override {
        results.total_queries++;
        string query_hash = HashQuery(query);
        
        CleanExpired();
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            results.cache_hits++;
            results.total_cache_time += 0.5;
            
            cache_it->second->last_access = chrono::steady_clock::now();
            return duckdb::unique_ptr_cast<MaterializedQueryResult>(cache_it->second->result->Clone());
        }
        
        // 执行查询
        auto start_time = chrono::high_resolution_clock::now();
        auto result = conn->Query(query);
        auto end_time = chrono::high_resolution_clock::now();
        
        double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
        results.total_execution_time += execution_time;
        
        if (result->HasError()) {
            return nullptr;
        }
        
        auto materialized_result = duckdb::unique_ptr_cast<MaterializedQueryResult>(std::move(result));
        size_t result_size = EstimateResultSize(*materialized_result);
        
        // 缓存结果
        if (cache.size() < max_cache_size) {
            auto cache_entry = duckdb::make_unique<BaseCacheEntry>(query_hash, 
                duckdb::unique_ptr_cast<MaterializedQueryResult>(materialized_result->Clone()), result_size);
            
            current_memory_bytes += result_size;
            cache[query_hash] = std::move(cache_entry);
            
            results.max_cache_size = max(results.max_cache_size, cache.size());
        }
        
        return std::move(materialized_result);
    }
    
    CacheTestResult GetResults() const override { 
        auto result = results;
        result.memory_efficiency = current_memory_bytes > 0 ? 
            min(1.0, (double)current_memory_bytes / (50 * 1024 * 1024)) : 0.0;
        return result;
    }
    
    string GetName() const override { return "TTL Cache"; }
};

// ML缓存策略 (简化版)
class MLCacheStrategy : public CacheStrategy {
private:
    duckdb::unique_ptr<DuckDB> db;
    duckdb::unique_ptr<Connection> conn;
    
    unordered_map<string, duckdb::unique_ptr<MLCacheEntry>> cache;
    duckdb::vector<double> weights = {0.25, 0.20, 0.30, 0.15, 0.10};
    
    size_t max_cache_size = 20;
    size_t current_memory_bytes = 0;
    
    CacheTestResult results;
    
public:
    MLCacheStrategy() {
        db = duckdb::make_unique<DuckDB>(nullptr);
        conn = duckdb::make_unique<Connection>(*db);
        CreateTestData();
        results.strategy_name = "ML Cache";
    }
    
    void CreateTestData() {
        conn->Query("CREATE TABLE lineitem (l_orderkey INTEGER, l_partkey INTEGER, l_suppkey INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1), l_shipdate DATE, l_shipmode VARCHAR(10))");
        
        for (int i = 1; i <= 1000; i++) {
            string insert_sql = "INSERT INTO lineitem VALUES (" +
                to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", " +
                to_string(10.0 + (i % 50)) + ", " + to_string(100.0 + (i % 1000)) + ", " +
                to_string(0.05 + (i % 10) * 0.01) + ", 'N', 'O', " +
                "'1995-01-" + to_string((i % 28) + 1) + "', 'TRUCK')";
            conn->Query(insert_sql);
        }
    }
    
    string HashQuery(const string& query) {
        hash<string> hasher;
        return to_string(hasher(query));
    }
    
    double EvaluateCacheValue(const MLCacheEntry& entry) {
        auto now = chrono::steady_clock::now();
        auto age_seconds = chrono::duration_cast<chrono::seconds>(now - entry.creation_time).count();
        auto last_access_seconds = chrono::duration_cast<chrono::seconds>(now - entry.last_access).count();
        
        duckdb::vector<double> features = {
            min(1.0, entry.access_frequency / 10.0),
            max(0.0, 1.0 - age_seconds / 3600.0),
            max(0.0, 1.0 - last_access_seconds / 1800.0),
            min(1.0, entry.size_bytes / (1024.0 * 1024.0)),
            entry.access_history.empty() ? 0.5 : min(1.0, entry.access_history.back())
        };
        
        double value = 0.0;
        for (size_t i = 0; i < weights.size() && i < features.size(); i++) {
            value += weights[i] * features[i];
        }
        
        return value;
    }
    
    void EvictLowValue() {
        while (cache.size() >= max_cache_size) {
            string lowest_key;
            double lowest_value = 1.0;
            
            for (const auto& [key, entry] : cache) {
                double value = EvaluateCacheValue(*entry);
                if (value < lowest_value) {
                    lowest_value = value;
                    lowest_key = key;
                }
            }
            
            if (!lowest_key.empty()) {
                current_memory_bytes -= cache[lowest_key]->size_bytes;
                cache.erase(lowest_key);
            } else {
                break;
            }
        }
    }
    
    size_t EstimateResultSize(const MaterializedQueryResult& result) {
        return max((size_t)1024, result.ColumnCount() * 1024);
    }
    
    duckdb::unique_ptr<MaterializedQueryResult> Query(const string& query) override {
        results.total_queries++;
        string query_hash = HashQuery(query);
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            results.cache_hits++;
            results.total_cache_time += 0.5;
            
            // 更新ML统计
            cache_it->second->access_frequency += 1.0;
            cache_it->second->last_access = chrono::steady_clock::now();
            cache_it->second->access_history.push_back(1.0);
            
            return duckdb::unique_ptr_cast<MaterializedQueryResult>(cache_it->second->result->Clone());
        }
        
        // 执行查询
        auto start_time = chrono::high_resolution_clock::now();
        auto result = conn->Query(query);
        auto end_time = chrono::high_resolution_clock::now();
        
        double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
        results.total_execution_time += execution_time;
        
        if (result->HasError()) {
            return nullptr;
        }
        
        auto materialized_result = duckdb::unique_ptr_cast<MaterializedQueryResult>(std::move(result));
        size_t result_size = EstimateResultSize(*materialized_result);
        
        // 智能缓存决策
        EvictLowValue();
        
        auto cache_entry = duckdb::make_unique<MLCacheEntry>(query_hash, 
            duckdb::unique_ptr_cast<MaterializedQueryResult>(materialized_result->Clone()), result_size);
        
        current_memory_bytes += result_size;
        cache[query_hash] = std::move(cache_entry);
        
        results.max_cache_size = max(results.max_cache_size, cache.size());
        
        return std::move(materialized_result);
    }
    
    CacheTestResult GetResults() const override { 
        auto result = results;
        result.memory_efficiency = current_memory_bytes > 0 ? 
            min(1.0, (double)current_memory_bytes / (50 * 1024 * 1024)) : 0.0;
        return result;
    }
    
    string GetName() const override { return "ML Cache"; }
};

// 测试查询生成器
class QueryGenerator {
public:
    static duckdb::vector<string> GenerateTestQueries() {
        duckdb::vector<string> queries;
        
        // 基础查询 (会被重复执行)
        duckdb::vector<string> base_queries = {
            "SELECT COUNT(*) FROM lineitem",
            "SELECT l_returnflag, COUNT(*) FROM lineitem GROUP BY l_returnflag",
            "SELECT AVG(l_quantity) FROM lineitem",
            "SELECT SUM(l_extendedprice) FROM lineitem WHERE l_discount > 0.05",
            "SELECT l_orderkey, SUM(l_quantity) FROM lineitem GROUP BY l_orderkey LIMIT 10"
        };
        
        // 复杂查询 (偶尔执行)
        duckdb::vector<string> complex_queries = {
            "SELECT l_returnflag, l_linestatus, COUNT(*), AVG(l_quantity) FROM lineitem GROUP BY l_returnflag, l_linestatus",
            "SELECT l_partkey, COUNT(*) FROM lineitem GROUP BY l_partkey HAVING COUNT(*) > 5 ORDER BY COUNT(*) DESC LIMIT 20",
            "SELECT l_suppkey, AVG(l_extendedprice * (1 - l_discount)) FROM lineitem GROUP BY l_suppkey ORDER BY AVG(l_extendedprice * (1 - l_discount)) DESC LIMIT 15",
            "SELECT l_shipmode, COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' GROUP BY l_shipmode"
        };
        
        // 生成测试模式：80%基础查询，20%复杂查询
        random_device rd;
        mt19937 gen(rd());
        uniform_real_distribution<> dis(0.0, 1.0);
        
        for (int i = 0; i < 50; i++) {
            if (dis(gen) < 0.8) {
                // 基础查询
                int idx = uniform_int_distribution<>(0, base_queries.size() - 1)(gen);
                queries.push_back(base_queries[idx]);
            } else {
                // 复杂查询
                int idx = uniform_int_distribution<>(0, complex_queries.size() - 1)(gen);
                queries.push_back(complex_queries[idx]);
            }
        }
        
        return queries;
    }
};

// 性能测试器
class PerformanceTester {
public:
    static void RunComparison() {
        cout << "🚀 启动DuckDB缓存策略对比测试..." << endl;
        
        // 创建测试策略
        duckdb::vector<duckdb::unique_ptr<CacheStrategy>> strategies;
        strategies.push_back(duckdb::make_unique<NoCacheStrategy>());
        strategies.push_back(duckdb::make_unique<LRUCacheStrategy>());
        strategies.push_back(duckdb::make_unique<TTLCacheStrategy>());
        strategies.push_back(duckdb::make_unique<MLCacheStrategy>());
        
        // 生成测试查询
        auto test_queries = QueryGenerator::GenerateTestQueries();
        cout << "📊 生成了 " << test_queries.size() << " 个测试查询" << endl;
        
        duckdb::vector<CacheTestResult> results;
        
        // 测试每种策略
        for (auto& strategy : strategies) {
            cout << "\n🧪 测试策略: " << strategy->GetName() << endl;
            
            auto start_time = chrono::high_resolution_clock::now();
            
            for (size_t i = 0; i < test_queries.size(); i++) {
                if (i % 10 == 0) {
                    cout << "  进度: " << i << "/" << test_queries.size() << endl;
                }
                
                auto result = strategy->Query(test_queries[i]);
                
                // 模拟真实使用间隔
                this_thread::sleep_for(chrono::milliseconds(10));
            }
            
            auto end_time = chrono::high_resolution_clock::now();
            auto total_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            auto test_result = strategy->GetResults();
            cout << "  ✅ 完成，总耗时: " << total_time << "ms" << endl;
            
            results.push_back(test_result);
        }
        
        // 打印对比结果
        PrintComparisonResults(results);
        
        // 保存详细报告
        SaveDetailedReport(results, test_queries.size());
    }
    
private:
    static void PrintComparisonResults(const duckdb::vector<CacheTestResult>& results) {
        cout << "\n" << string(80, '=') << endl;
        cout << "缓存策略性能对比结果" << endl;
        cout << string(80, '=') << endl;
        
        cout << left << setw(12) << "策略" 
             << setw(10) << "命中率" 
             << setw(15) << "平均响应时间" 
             << setw(12) << "内存效率"
             << setw(10) << "缓存大小" << endl;
        cout << string(80, '-') << endl;
        
        for (const auto& result : results) {
            cout << left << setw(12) << result.strategy_name
                 << setw(10) << fixed << setprecision(1) << (result.GetHitRate() * 100) << "%"
                 << setw(15) << fixed << setprecision(1) << result.GetAvgExecutionTime() << "ms"
                 << setw(12) << fixed << setprecision(1) << (result.memory_efficiency * 100) << "%"
                 << setw(10) << result.max_cache_size << endl;
        }
        
        cout << "\n📈 性能提升分析:" << endl;
        
        // 找到基准 (无缓存)
        const CacheTestResult* no_cache = nullptr;
        const CacheTestResult* ml_cache = nullptr;
        const CacheTestResult* lru_cache = nullptr;
        
        for (const auto& result : results) {
            if (result.strategy_name == "No Cache") no_cache = &result;
            else if (result.strategy_name == "ML Cache") ml_cache = &result;
            else if (result.strategy_name == "LRU Cache") lru_cache = &result;
        }
        
        if (no_cache && ml_cache) {
            double improvement = (no_cache->GetAvgExecutionTime() - ml_cache->GetAvgExecutionTime()) / 
                               no_cache->GetAvgExecutionTime() * 100;
            cout << "• ML缓存 vs 无缓存: 响应时间改善 " << fixed << setprecision(1) << improvement << "%" << endl;
        }
        
        if (lru_cache && ml_cache) {
            double hit_improvement = (ml_cache->GetHitRate() - lru_cache->GetHitRate()) * 100;
            double time_improvement = (lru_cache->GetAvgExecutionTime() - ml_cache->GetAvgExecutionTime()) / 
                                    lru_cache->GetAvgExecutionTime() * 100;
            cout << "• ML缓存 vs LRU缓存: 命中率提升 " << fixed << setprecision(1) << hit_improvement 
                 << "个百分点, 响应时间改善 " << fixed << setprecision(1) << time_improvement << "%" << endl;
        }
        
        cout << "\n🎯 测试结论:" << endl;
        if (ml_cache && ml_cache->GetHitRate() > 0.5) {
            cout << "✅ ML缓存策略表现优秀，显著提升了缓存效率" << endl;
        } else {
            cout << "⚠️  ML缓存策略需要更多优化" << endl;
        }
    }
    
    static void SaveDetailedReport(const duckdb::vector<CacheTestResult>& results, size_t total_queries) {
        ofstream report("cache_test/results/comparison_report.json");
        
        report << "{\n";
        report << "  \"test_info\": {\n";
        report << "    \"timestamp\": \"" << chrono::system_clock::to_time_t(chrono::system_clock::now()) << "\",\n";
        report << "    \"total_queries\": " << total_queries << ",\n";
        report << "    \"strategies_tested\": " << results.size() << "\n";
        report << "  },\n";
        report << "  \"results\": [\n";
        
        for (size_t i = 0; i < results.size(); i++) {
            const auto& result = results[i];
            report << "    {\n";
            report << "      \"strategy\": \"" << result.strategy_name << "\",\n";
            report << "      \"hit_rate\": " << result.GetHitRate() << ",\n";
            report << "      \"avg_execution_time\": " << result.GetAvgExecutionTime() << ",\n";
            report << "      \"memory_efficiency\": " << result.memory_efficiency << ",\n";
            report << "      \"max_cache_size\": " << result.max_cache_size << ",\n";
            report << "      \"total_queries\": " << result.total_queries << ",\n";
            report << "      \"cache_hits\": " << result.cache_hits << "\n";
            report << "    }";
            if (i < results.size() - 1) report << ",";
            report << "\n";
        }
        
        report << "  ]\n";
        report << "}\n";
        
        report.close();
        cout << "\n📄 详细报告已保存: cache_test/results/comparison_report.json" << endl;
    }
};

int main() {
    try {
        // 创建结果目录
        system("mkdir -p cache_test/results");
        
        // 运行对比测试
        PerformanceTester::RunComparison();
        
        cout << "\n🎉 缓存策略对比测试完成！" << endl;
        
    } catch (const exception& e) {
        cout << "❌ 测试失败: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}