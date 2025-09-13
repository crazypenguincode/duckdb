//===----------------------------------------------------------------------===//
// DuckDB TPC-H 改进版ML缓存策略测试
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

// 避免命名冲突
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

// 改进版缓存条目
struct ImprovedCacheEntry {
    string query_hash;
    string query_name;
    unique_ptr<TestQueryResult> result;
    chrono::steady_clock::time_point creation_time;
    chrono::steady_clock::time_point last_access;
    
    // 访问统计
    size_t access_count;
    double access_frequency;
    vector<double> access_intervals;
    
    // ML特征
    double query_complexity_score;
    double temporal_locality_score;
    double size_efficiency_score;
    double predicted_next_access;
    double cache_value_score;
    
    // 查询类型
    string query_type; // "simple", "medium", "complex"
    
    ImprovedCacheEntry(const string& hash, const string& name, unique_ptr<TestQueryResult> res)
        : query_hash(hash), query_name(name), result(std::move(res)), 
          creation_time(chrono::steady_clock::now()),
          last_access(chrono::steady_clock::now()),
          access_count(1), access_frequency(1.0),
          query_complexity_score(0.5), temporal_locality_score(0.5),
          size_efficiency_score(0.5), predicted_next_access(3600.0),
          cache_value_score(0.5), query_type("medium") {}
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
    
    // 按查询类型统计
    map<string, size_t> type_hits;
    map<string, size_t> type_total;
    
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
                
                query_sql = CleanQuery(query_sql);
                queries.push_back({filename, query_sql});
                cout << "  ✅ 加载查询: " << filename << endl;
            }
        }
        
        cout << "📊 总共加载了 " << queries.size() << " 个TPC-H查询" << endl;
    }
    
    string CleanQuery(const string& query) {
        string cleaned = query;
        
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
        // 基于TPC-H查询特点分类
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

// 改进版ML智能缓存策略
class ImprovedMLCacheStrategy {
private:
    DuckDBPtr db;
    ConnectionPtr conn;
    
    unordered_map<string, unique_ptr<ImprovedCacheEntry>> cache;
    
    size_t max_cache_size;
    size_t current_memory_bytes = 0;
    
    // 改进的ML参数 - 基于分析结果调整
    struct MLWeights {
        double frequency_weight = 0.40;      // 增加频率权重
        double recency_weight = 0.20;        // 时间权重
        double complexity_weight = 0.25;     // 增加复杂度权重
        double size_efficiency_weight = 0.10; // 大小效率权重
        double type_locality_weight = 0.05;   // 类型局部性权重
    } weights;
    
    // 动态权重调整参数
    double learning_rate = 0.01;
    size_t weight_update_interval = 10;
    size_t queries_since_update = 0;
    
    BenchmarkStats stats;
    TPCHQueryLoader* query_loader;
    
public:
    ImprovedMLCacheStrategy(const string& db_path, TPCHQueryLoader* loader, size_t max_size = 10) 
        : max_cache_size(max_size), query_loader(loader) {
        
        stats.strategy_name = "Improved ML Cache";
        db = duckdb::make_uniq<duckdb::DuckDB>(db_path);
        conn = duckdb::make_uniq<duckdb::Connection>(*db);
    }
    
    unique_ptr<TestQueryResult> ExecuteQuery(const string& query_name, const string& query_sql) {
        stats.total_queries++;
        queries_since_update++;
        string query_hash = HashQuery(query_sql);
        
        // 更新查询类型统计
        string query_type = query_loader->GetQueryType(query_name);
        stats.type_total[query_type]++;
        
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            stats.cache_hits++;
            stats.type_hits[query_type]++;
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
                CacheResultWithImprovedML(query_hash, query_name, std::move(result));
            }
        }
        
        // 定期更新权重
        if (queries_since_update >= weight_update_interval) {
            UpdateWeights();
            queries_since_update = 0;
        }
        
        return result;
    }
    
    BenchmarkStats GetStats() const { 
        auto result_stats = stats;
        result_stats.current_cache_size = cache.size();
        result_stats.memory_usage_mb = current_memory_bytes / (1024.0 * 1024.0);
        return result_stats;
    }
    
    string GetName() const { return "Improved ML Cache"; }
    
    void Reset() {
        cache.clear();
        current_memory_bytes = 0;
        queries_since_update = 0;
        stats = BenchmarkStats();
        stats.strategy_name = "Improved ML Cache";
    }
    
private:
    bool ShouldCache(const string& query_name, const string& query_sql, TestQueryResult* result) {
        vector<double> features = ExtractImprovedFeatures(query_name, query_sql, result);
        double cache_value = CalculateImprovedCacheValue(features);
        
        if (cache.size() < max_cache_size) {
            // 降低缓存阈值，更积极地缓存
            return cache_value > 0.2;
        }
        
        double min_value = GetMinCacheValue();
        return cache_value > min_value * 1.1; // 需要明显更高的价值才替换
    }
    
    vector<double> ExtractImprovedFeatures(const string& query_name, const string& query_sql, TestQueryResult* result) {
        vector<double> features(5);
        
        // 特征1: 改进的查询频率估算 (基于查询类型)
        features[0] = EstimateImprovedQueryFrequency(query_name, query_sql);
        
        // 特征2: 时间局部性 (基于查询模式)
        features[1] = EstimateImprovedTemporalLocality(query_sql);
        
        // 特征3: 查询复杂度 (基于执行时间和查询类型)
        features[2] = EstimateQueryComplexity(query_name, result->execution_time_ms);
        
        // 特征4: 大小效率 (结果大小 vs 执行成本)
        features[3] = EstimateSizeEfficiency(result->result_size, result->execution_time_ms);
        
        // 特征5: 查询类型局部性
        features[4] = EstimateTypeLocality(query_name);
        
        return features;
    }
    
    double CalculateImprovedCacheValue(const vector<double>& features) {
        double value = 0.0;
        
        value += weights.frequency_weight * features[0];
        value += weights.recency_weight * features[1];
        value += weights.complexity_weight * features[2];
        value += weights.size_efficiency_weight * features[3];
        value += weights.type_locality_weight * features[4];
        
        return max(0.0, min(1.0, value));
    }
    
    void UpdateMLFeatures(ImprovedCacheEntry* entry) {
        auto now = chrono::steady_clock::now();
        
        // 更新访问统计
        entry->access_frequency += 1.0;
        entry->access_count++;
        
        // 记录访问间隔
        auto interval = chrono::duration<double>(now - entry->last_access).count();
        entry->access_intervals.push_back(interval);
        
        // 保持间隔历史
        if (entry->access_intervals.size() > 10) {
            entry->access_intervals.erase(entry->access_intervals.begin());
        }
        
        // 更新ML特征
        entry->temporal_locality_score = CalculateTemporalLocality(entry);
        entry->predicted_next_access = PredictNextAccess(entry);
        entry->cache_value_score = CalculateEntryValue(entry);
        
        entry->last_access = now;
    }
    
    double CalculateTemporalLocality(ImprovedCacheEntry* entry) {
        if (entry->access_intervals.empty()) return 0.5;
        
        // 计算访问间隔的稳定性
        double avg_interval = 0.0;
        for (double interval : entry->access_intervals) {
            avg_interval += interval;
        }
        avg_interval /= entry->access_intervals.size();
        
        // 间隔越短且越稳定，时间局部性越高
        double stability = 1.0;
        if (entry->access_intervals.size() > 1) {
            double variance = 0.0;
            for (double interval : entry->access_intervals) {
                variance += pow(interval - avg_interval, 2);
            }
            variance /= entry->access_intervals.size();
            stability = 1.0 / (1.0 + sqrt(variance) / avg_interval);
        }
        
        double locality = stability / (1.0 + avg_interval / 300.0); // 5分钟基准
        return max(0.0, min(1.0, locality));
    }
    
    double PredictNextAccess(ImprovedCacheEntry* entry) {
        if (entry->access_intervals.empty()) return 3600.0;
        
        // 使用指数加权移动平均预测
        double prediction = entry->access_intervals.back();
        double alpha = 0.3;
        
        for (int i = entry->access_intervals.size() - 2; i >= 0; i--) {
            prediction = alpha * entry->access_intervals[i] + (1 - alpha) * prediction;
        }
        
        return prediction;
    }
    
    double CalculateEntryValue(ImprovedCacheEntry* entry) {
        auto now = chrono::steady_clock::now();
        auto age = chrono::duration<double>(now - entry->creation_time).count();
        auto last_access_age = chrono::duration<double>(now - entry->last_access).count();
        
        vector<double> features = {
            min(1.0, entry->access_frequency / 5.0), // 降低频率基准
            entry->temporal_locality_score,
            entry->query_complexity_score,
            entry->size_efficiency_score,
            EstimateTypeLocality(entry->query_name)
        };
        
        return CalculateImprovedCacheValue(features);
    }
    
    void CacheResultWithImprovedML(const string& query_hash, const string& query_name, unique_ptr<TestQueryResult> result) {
        if (cache.size() >= max_cache_size) {
            EvictLowValueEntry();
        }
        
        auto cache_entry = make_unique<ImprovedCacheEntry>(query_hash, query_name, std::move(result));
        
        // 初始化ML特征
        cache_entry->query_type = query_loader->GetQueryType(query_name);
        cache_entry->query_complexity_score = EstimateQueryComplexity(query_name, cache_entry->result->execution_time_ms);
        cache_entry->size_efficiency_score = EstimateSizeEfficiency(cache_entry->result->result_size, cache_entry->result->execution_time_ms);
        cache_entry->cache_value_score = CalculateEntryValue(cache_entry.get());
        
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
    
    void UpdateWeights() {
        // 基于命中率动态调整权重
        if (stats.total_queries < 10) return;
        
        double current_hit_rate = stats.GetHitRate();
        double target_hit_rate = 0.6; // 目标命中率
        
        if (current_hit_rate < target_hit_rate) {
            // 命中率低，增加频率和复杂度权重
            weights.frequency_weight = min(0.5, weights.frequency_weight + learning_rate);
            weights.complexity_weight = min(0.3, weights.complexity_weight + learning_rate);
            weights.recency_weight = max(0.1, weights.recency_weight - learning_rate * 0.5);
        } else if (current_hit_rate > target_hit_rate + 0.1) {
            // 命中率过高，可能缓存了太多低价值项目
            weights.size_efficiency_weight = min(0.2, weights.size_efficiency_weight + learning_rate);
            weights.frequency_weight = max(0.3, weights.frequency_weight - learning_rate * 0.5);
        }
        
        // 归一化权重
        double total_weight = weights.frequency_weight + weights.recency_weight + 
                             weights.complexity_weight + weights.size_efficiency_weight + 
                             weights.type_locality_weight;
        
        weights.frequency_weight /= total_weight;
        weights.recency_weight /= total_weight;
        weights.complexity_weight /= total_weight;
        weights.size_efficiency_weight /= total_weight;
        weights.type_locality_weight /= total_weight;
    }
    
    // 改进的特征估算函数
    double EstimateImprovedQueryFrequency(const string& query_name, const string& query_sql) {
        // 基于查询类型和模式估算频率
        string type = query_loader->GetQueryType(query_name);
        
        double base_frequency = 0.3;
        if (type == "simple") {
            base_frequency = 0.8; // 简单查询更频繁
        } else if (type == "complex") {
            base_frequency = 0.4; // 复杂查询中等频率
        }
        
        // 基于查询模式调整
        if (query_sql.find("COUNT") != string::npos || 
            query_sql.find("SUM") != string::npos) {
            base_frequency += 0.2; // 聚合查询更频繁
        }
        
        return min(1.0, base_frequency);
    }
    
    double EstimateImprovedTemporalLocality(const string& query_sql) {
        double locality = 0.5;
        
        // 基于查询模式
        if (query_sql.find("COUNT") != string::npos) locality += 0.2;
        if (query_sql.find("SUM") != string::npos) locality += 0.2;
        if (query_sql.find("AVG") != string::npos) locality += 0.1;
        if (query_sql.find("GROUP BY") != string::npos) locality += 0.1;
        
        // 复杂查询时间局部性较低
        if (query_sql.find("JOIN") != string::npos) locality -= 0.1;
        if (query_sql.find("HAVING") != string::npos) locality -= 0.1;
        
        return max(0.0, min(1.0, locality));
    }
    
    double EstimateQueryComplexity(const string& query_name, double execution_time_ms) {
        string type = query_loader->GetQueryType(query_name);
        
        double complexity = 0.3;
        if (type == "simple") {
            complexity = 0.2;
        } else if (type == "complex") {
            complexity = 0.8;
        } else {
            complexity = 0.5;
        }
        
        // 基于执行时间调整
        if (execution_time_ms > 1000) complexity += 0.2; // >1s
        if (execution_time_ms > 5000) complexity += 0.2; // >5s
        
        return min(1.0, complexity);
    }
    
    double EstimateSizeEfficiency(size_t result_size, double execution_time_ms) {
        // 执行时间长但结果小的查询效率高，值得缓存
        double time_factor = min(1.0, execution_time_ms / 1000.0);
        double size_factor = 1.0 / (1.0 + result_size / (1024.0 * 1024.0));
        
        return time_factor * size_factor;
    }
    
    double EstimateTypeLocality(const string& query_name) {
        string type = query_loader->GetQueryType(query_name);
        
        if (type == "simple") return 0.9;
        if (type == "complex") return 0.3;
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

// 对比测试函数
void RunImprovedMLTest(const string& db_path, const string& queries_dir) {
    cout << "\n🚀 启动改进版ML缓存策略测试" << endl;
    
    TPCHQueryLoader query_loader(queries_dir);
    ImprovedMLCacheStrategy improved_ml(db_path, &query_loader, 10);
    
    // 生成测试工作负载
    const auto& queries = query_loader.GetQueries();
    vector<pair<string, string>> workload;
    
    random_device rd;
    mt19937 gen(rd());
    uniform_real_distribution<> dis(0.0, 1.0);
    
    // 生成更真实的工作负载
    for (int i = 0; i < 60; i++) {
        double rand_val = dis(gen);
        int query_idx;
        
        if (rand_val < 0.6) {
            // 60% 简单和中等查询
            vector<int> simple_medium;
            for (size_t j = 0; j < queries.size(); j++) {
                string type = query_loader.GetQueryType(queries[j].first);
                if (type == "simple" || type == "medium") {
                    simple_medium.push_back(j);
                }
            }
            if (!simple_medium.empty()) {
                query_idx = simple_medium[uniform_int_distribution<>(0, simple_medium.size() - 1)(gen)];
            } else {
                query_idx = uniform_int_distribution<>(0, queries.size() - 1)(gen);
            }
        } else {
            // 40% 复杂查询
            vector<int> complex_queries;
            for (size_t j = 0; j < queries.size(); j++) {
                string type = query_loader.GetQueryType(queries[j].first);
                if (type == "complex") {
                    complex_queries.push_back(j);
                }
            }
            if (!complex_queries.empty()) {
                query_idx = complex_queries[uniform_int_distribution<>(0, complex_queries.size() - 1)(gen)];
            } else {
                query_idx = uniform_int_distribution<>(0, queries.size() - 1)(gen);
            }
        }
        
        if (query_idx < queries.size()) {
            workload.push_back(queries[query_idx]);
        }
    }
    
    cout << "📋 生成了 " << workload.size() << " 个查询的改进工作负载" << endl;
    
    // 执行测试
    cout << "\n🧪 测试改进版ML缓存策略..." << endl;
    
    auto start_time = chrono::high_resolution_clock::now();
    
    size_t completed = 0;
    for (const auto& [query_name, query_sql] : workload) {
        auto result = improved_ml.ExecuteQuery(query_name, query_sql);
        
        completed++;
        if (completed % 10 == 0) {
            cout << "  进度: " << completed << "/" << workload.size() 
                 << " (" << (completed * 100 / workload.size()) << "%)" << endl;
        }
        
        this_thread::sleep_for(chrono::milliseconds(50));
    }
    
    auto end_time = chrono::high_resolution_clock::now();
    auto total_time = chrono::duration<double>(end_time - start_time).count();
    
    auto stats = improved_ml.GetStats();
    
    cout << "\n" << string(80, '=') << endl;
    cout << "改进版ML缓存策略测试结果" << endl;
    cout << string(80, '=') << endl;
    
    cout << "📊 总体性能:" << endl;
    cout << "  • 总查询数: " << stats.total_queries << endl;
    cout << "  • 缓存命中: " << stats.cache_hits << " (" << fixed << setprecision(1) << (stats.GetHitRate() * 100) << "%)" << endl;
    cout << "  • 缓存未命中: " << stats.cache_misses << endl;
    cout << "  • 平均响应时间: " << fixed << setprecision(1) << stats.GetAvgResponseTime() << "ms" << endl;
    cout << "  • 缓存大小: " << stats.current_cache_size << "/" << stats.max_cache_size << endl;
    cout << "  • 内存使用: " << fixed << setprecision(1) << stats.memory_usage_mb << "MB" << endl;
    cout << "  • 总耗时: " << fixed << setprecision(2) << total_time << "s" << endl;
    
    cout << "\n📈 按查询类型统计:" << endl;
    for (const auto& [type, total] : stats.type_total) {
        size_t hits = stats.type_hits.count(type) ? stats.type_hits.at(type) : 0;
        double hit_rate = total > 0 ? (double)hits / total * 100 : 0.0;
        cout << "  • " << type << " 查询: " << hits << "/" << total 
             << " (" << fixed << setprecision(1) << hit_rate << "%)" << endl;
    }
    
    // 保存改进版结果
    ofstream report("cache_test/results/improved_ml_benchmark_report.json");
    report << "{\n";
    report << "  \"test_info\": {\n";
    report << "    \"timestamp\": \"" << chrono::system_clock::to_time_t(chrono::system_clock::now()) << "\",\n";
    report << "    \"strategy\": \"Improved ML Cache\",\n";
    report << "    \"workload_size\": " << workload.size() << "\n";
    report << "  },\n";
    report << "  \"results\": {\n";
    report << "    \"hit_rate\": " << stats.GetHitRate() << ",\n";
    report << "    \"avg_response_time\": " << stats.GetAvgResponseTime() << ",\n";
    report << "    \"cache_hits\": " << stats.cache_hits << ",\n";
    report << "    \"cache_misses\": " << stats.cache_misses << ",\n";
    report << "    \"current_cache_size\": " << stats.current_cache_size << ",\n";
    report << "    \"memory_usage_mb\": " << stats.memory_usage_mb << "\n";
    report << "  }\n";
    report << "}\n";
    report.close();
    
    cout << "\n📄 改进版测试报告已保存: cache_test/results/improved_ml_benchmark_report.json" << endl;
    cout << "\n🎉 改进版ML缓存测试完成！" << endl;
}

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
        
        RunImprovedMLTest(db_path, queries_dir);
        
    } catch (const exception& e) {
        cout << "❌ 测试失败: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}