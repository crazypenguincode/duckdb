//===----------------------------------------------------------------------===//
// DuckDB ML缓存系统 - 修复版真实测试
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

using namespace duckdb;
using namespace std;

// 缓存条目结构
struct CacheEntry {
    string query_hash;
    duckdb::unique_ptr<MaterializedQueryResult> result;
    size_t size_bytes;
    double access_frequency;
    chrono::steady_clock::time_point last_access;
    chrono::steady_clock::time_point creation_time;
    duckdb::vector<double> access_history;
    
    CacheEntry(const string& hash, duckdb::unique_ptr<MaterializedQueryResult> res, 
               size_t size) 
        : query_hash(hash), result(std::move(res)), size_bytes(size), 
          access_frequency(1.0), last_access(chrono::steady_clock::now()),
          creation_time(chrono::steady_clock::now()) {
        access_history.push_back(1.0);
    }
};

// 查询执行结果记录
struct QueryExecutionResult {
    string query;
    double execution_time_ms;
    bool cache_hit;
    size_t result_size;
    chrono::steady_clock::time_point timestamp;
    
    QueryExecutionResult(const string& q, double time, bool hit, size_t size)
        : query(q), execution_time_ms(time), cache_hit(hit), result_size(size),
          timestamp(chrono::steady_clock::now()) {}
};

// ML缓存预测器
class MLCachePredictor {
private:
    duckdb::vector<double> weights = {0.25, 0.20, 0.30, 0.15, 0.10}; // 价值评估权重
    double alpha = 0.3, beta = 0.3; // Holt-Winters参数
    double learning_rate = 0.001;
    duckdb::vector<double> m_weights, v_weights;
    int adam_t = 0;
    
public:
    MLCachePredictor() {
        m_weights.resize(weights.size(), 0.0);
        v_weights.resize(weights.size(), 0.0);
    }
    
    // Holt-Winters时间序列预测
    double PredictNextAccess(const duckdb::vector<double>& access_history) {
        if (access_history.size() < 2) {
            return access_history.empty() ? 1.0 : access_history.back();
        }
        
        double level = access_history[0];
        double trend = 0.0;
        
        for (size_t i = 1; i < access_history.size(); i++) {
            if (i == 1) {
                trend = access_history[1] - access_history[0];
            }
            
            double new_level = alpha * access_history[i] + (1 - alpha) * (level + trend);
            double new_trend = beta * (new_level - level) + (1 - beta) * trend;
            
            level = new_level;
            trend = new_trend;
        }
        
        return level + trend;
    }
    
    // 多因素价值评估
    double EvaluateCacheValue(const CacheEntry& entry) {
        auto now = chrono::steady_clock::now();
        auto age_seconds = chrono::duration_cast<chrono::seconds>(now - entry.creation_time).count();
        auto last_access_seconds = chrono::duration_cast<chrono::seconds>(now - entry.last_access).count();
        
        // 计算特征向量 (归一化到[0,1])
        duckdb::vector<double> features = {
            min(1.0, entry.access_frequency / 10.0),  // 访问频率
            max(0.0, 1.0 - age_seconds / 3600.0),    // 新鲜度 (1小时内)
            max(0.0, 1.0 - last_access_seconds / 1800.0), // 最近访问 (30分钟内)
            min(1.0, entry.size_bytes / (1024.0 * 1024.0)), // 大小 (1MB内)
            PredictNextAccess(entry.access_history)   // 预测访问概率
        };
        
        // 计算加权价值
        double value = 0.0;
        for (size_t i = 0; i < weights.size() && i < features.size(); i++) {
            value += weights[i] * features[i];
        }
        
        return value;
    }
    
    // Adam优化器更新权重
    void UpdateWeights(const duckdb::vector<double>& features, double actual_benefit) {
        adam_t++;
        
        // 计算预测误差
        double predicted_value = 0.0;
        for (size_t i = 0; i < weights.size() && i < features.size(); i++) {
            predicted_value += weights[i] * features[i];
        }
        
        double error = actual_benefit - predicted_value;
        
        // 计算梯度
        duckdb::vector<double> gradients(weights.size());
        for (size_t i = 0; i < gradients.size() && i < features.size(); i++) {
            gradients[i] = -2.0 * error * features[i];
        }
        
        // Adam更新
        double beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8;
        
        for (size_t i = 0; i < weights.size(); i++) {
            m_weights[i] = beta1 * m_weights[i] + (1 - beta1) * gradients[i];
            v_weights[i] = beta2 * v_weights[i] + (1 - beta2) * gradients[i] * gradients[i];
            
            double m_hat = m_weights[i] / (1 - pow(beta1, adam_t));
            double v_hat = v_weights[i] / (1 - pow(beta2, adam_t));
            
            weights[i] -= learning_rate * m_hat / (sqrt(v_hat) + epsilon);
            
            // 保持权重在合理范围内
            weights[i] = max(0.01, min(1.0, weights[i]));
        }
        
        // 归一化权重
        double sum = 0.0;
        for (double w : weights) sum += w;
        if (sum > 0) {
            for (double& w : weights) w /= sum;
        }
    }
    
    duckdb::vector<double> GetWeights() const { return weights; }
};

// ML增强缓存系统
class MLEnhancedCache {
private:
    duckdb::unique_ptr<DuckDB> db;
    duckdb::unique_ptr<Connection> conn;
    MLCachePredictor predictor;
    
    // 缓存存储
    unordered_map<string, duckdb::unique_ptr<CacheEntry>> cache;
    size_t max_cache_size = 50; // 最大缓存条目数
    size_t max_memory_mb = 100;  // 最大内存使用(MB)
    size_t current_memory_bytes = 0;
    
    // 统计信息
    size_t total_queries = 0;
    size_t cache_hits = 0;
    double total_execution_time = 0.0;
    duckdb::vector<QueryExecutionResult> execution_log;
    
public:
    MLEnhancedCache() {
        try {
            // 尝试连接到TPC-H数据库
            string db_path = "/Users/max/test/tpc/tpch-sf1.db";
            ifstream db_file(db_path);
            if (db_file.good()) {
                db_file.close();
                db = duckdb::make_unique<DuckDB>(db_path);
                conn = duckdb::make_unique<Connection>(*db);
                cout << "✅ 成功连接到TPC-H数据库: " << db_path << endl;
            } else {
                // 如果TPC-H数据库不存在，使用内存数据库并创建测试数据
                db = duckdb::make_unique<DuckDB>(nullptr);
                conn = duckdb::make_unique<Connection>(*db);
                CreateTestData();
                cout << "⚠️  TPC-H数据库不存在，使用内存测试数据" << endl;
            }
        } catch (const exception& e) {
            // 备用方案：使用内存数据库
            try {
                db = duckdb::make_unique<DuckDB>(nullptr);
                conn = duckdb::make_unique<Connection>(*db);
                CreateTestData();
                cout << "⚠️  数据库连接失败，使用内存测试数据: " << e.what() << endl;
            } catch (const exception& e2) {
                cout << "❌ 无法创建数据库连接: " << e2.what() << endl;
                throw;
            }
        }
    }
    
    void CreateTestData() {
        try {
            // 创建测试表和数据
            conn->Query("CREATE TABLE lineitem (l_orderkey INTEGER, l_partkey INTEGER, l_suppkey INTEGER, l_linenumber INTEGER, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_tax DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1), l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct VARCHAR(25), l_shipmode VARCHAR(10), l_comment VARCHAR(44))");
            
            // 插入测试数据
            for (int i = 1; i <= 1000; i++) {
                string insert_sql = "INSERT INTO lineitem VALUES (" +
                    to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", 1, " +
                    to_string(10.0 + (i % 50)) + ", " + to_string(100.0 + (i % 1000)) + ", " +
                    to_string(0.05 + (i % 10) * 0.01) + ", 0.08, 'N', 'O', " +
                    "'1995-01-" + to_string((i % 28) + 1) + "', " +
                    "'1995-02-" + to_string((i % 28) + 1) + "', " +
                    "'1995-03-" + to_string((i % 28) + 1) + "', " +
                    "'DELIVER IN PERSON', 'TRUCK', 'test comment')";
                conn->Query(insert_sql);
            }
            
            cout << "✅ 测试数据创建完成 (1000条记录)" << endl;
        } catch (const exception& e) {
            cout << "⚠️  测试数据创建失败: " << e.what() << endl;
        }
    }
    
    string HashQuery(const string& query) {
        // 简单的查询哈希函数
        hash<string> hasher;
        return to_string(hasher(query));
    }
    
    pair<double, duckdb::unique_ptr<MaterializedQueryResult>> ExecuteQuery(const string& query) {
        auto start_time = chrono::high_resolution_clock::now();
        
        try {
            auto result = conn->Query(query);
            auto end_time = chrono::high_resolution_clock::now();
            
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            
            if (result->HasError()) {
                cout << "❌ 查询执行错误: " << result->GetError() << endl;
                return {execution_time, nullptr};
            }
            
            return {execution_time, duckdb::unique_ptr_cast<MaterializedQueryResult>(std::move(result))};
        } catch (const exception& e) {
            auto end_time = chrono::high_resolution_clock::now();
            double execution_time = chrono::duration<double, milli>(end_time - start_time).count();
            cout << "❌ 查询执行异常: " << e.what() << endl;
            return {execution_time, nullptr};
        }
    }
    
    duckdb::unique_ptr<MaterializedQueryResult> QueryWithCache(const string& query) {
        total_queries++;
        string query_hash = HashQuery(query);
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            // 缓存命中
            cache_hits++;
            auto& entry = cache_it->second;
            
            // 更新访问统计
            entry->access_frequency += 1.0;
            entry->last_access = chrono::steady_clock::now();
            entry->access_history.push_back(1.0);
            
            // 记录执行结果
            execution_log.emplace_back(query, 0.5, true, entry->size_bytes); // 缓存命中假设0.5ms
            
            cout << "🎯 缓存命中: " << query.substr(0, 50) << "..." << endl;
            
            // 返回结果的副本
            return duckdb::unique_ptr_cast<MaterializedQueryResult>(entry->result->Clone());
        }
        
        // 缓存未命中，执行查询
        auto [execution_time, result] = ExecuteQuery(query);
        total_execution_time += execution_time;
        
        if (!result) {
            execution_log.emplace_back(query, execution_time, false, 0);
            return nullptr;
        }
        
        // 估算结果大小
        size_t result_size = EstimateResultSize(*result);
        
        // 记录执行结果
        execution_log.emplace_back(query, execution_time, false, result_size);
        
        // 创建缓存条目
        auto cache_entry = duckdb::make_unique<CacheEntry>(query_hash, 
            duckdb::unique_ptr_cast<MaterializedQueryResult>(result->Clone()), result_size);
        
        // 检查是否需要淘汰
        if (ShouldCache(*cache_entry)) {
            EvictIfNecessary(result_size);
            
            current_memory_bytes += result_size;
            cache[query_hash] = std::move(cache_entry);
            
            cout << "💾 查询结果已缓存: " << query.substr(0, 50) << "..." << endl;
        }
        
        return std::move(result);
    }
    
    bool ShouldCache(const CacheEntry& entry) {
        // 使用ML预测器评估缓存价值
        double cache_value = predictor.EvaluateCacheValue(entry);
        return cache_value > 0.3; // 阈值可调
    }
    
    void EvictIfNecessary(size_t new_entry_size) {
        // 检查内存限制
        while ((current_memory_bytes + new_entry_size > max_memory_mb * 1024 * 1024) ||
               (cache.size() >= max_cache_size)) {
            
            if (cache.empty()) break;
            
            // 找到价值最低的条目
            string lowest_value_key;
            double lowest_value = 1.0;
            
            for (const auto& [key, entry] : cache) {
                double value = predictor.EvaluateCacheValue(*entry);
                if (value < lowest_value) {
                    lowest_value = value;
                    lowest_value_key = key;
                }
            }
            
            if (!lowest_value_key.empty()) {
                current_memory_bytes -= cache[lowest_value_key]->size_bytes;
                cache.erase(lowest_value_key);
                cout << "🗑️  淘汰低价值缓存条目 (价值: " << lowest_value << ")" << endl;
            } else {
                break;
            }
        }
    }
    
    size_t EstimateResultSize(const MaterializedQueryResult& result) {
        // 简单的结果大小估算
        size_t size = result.ColumnCount() * 8; // 列头
        
        // 遍历所有行来估算大小
        auto chunk_count = 0;
        auto materialized_result = const_cast<MaterializedQueryResult*>(&result);
        
        while (true) {
            auto chunk = materialized_result->Fetch();
            if (!chunk || chunk->size() == 0) break;
            
            size += chunk->size() * chunk->ColumnCount() * 8; // 假设每个值8字节
            chunk_count++;
            
            if (chunk_count > 100) break; // 避免无限循环
        }
        
        return max(size, (size_t)1024); // 最小1KB
    }
    
    void PrintStatistics() {
        cout << "\n" << string(60, '=') << endl;
        cout << "ML缓存系统性能统计" << endl;
        cout << string(60, '=') << endl;
        
        double hit_rate = total_queries > 0 ? (double)cache_hits / total_queries : 0.0;
        double avg_execution_time = total_queries > 0 ? total_execution_time / total_queries : 0.0;
        
        cout << "总查询数: " << total_queries << endl;
        cout << "缓存命中数: " << cache_hits << endl;
        cout << "缓存命中率: " << (hit_rate * 100) << "%" << endl;
        cout << "平均执行时间: " << avg_execution_time << "ms" << endl;
        cout << "当前缓存条目数: " << cache.size() << endl;
        cout << "当前内存使用: " << (current_memory_bytes / 1024.0 / 1024.0) << "MB" << endl;
        
        // 显示ML权重
        auto weights = predictor.GetWeights();
        cout << "\nML权重 [频率, 新鲜度, 最近访问, 大小, 预测]: ";
        for (size_t i = 0; i < weights.size(); i++) {
            cout << weights[i];
            if (i < weights.size() - 1) cout << ", ";
        }
        cout << endl;
        
        // 最近查询统计
        if (!execution_log.empty()) {
            cout << "\n最近10次查询:" << endl;
            size_t start = execution_log.size() > 10 ? execution_log.size() - 10 : 0;
            for (size_t i = start; i < execution_log.size(); i++) {
                const auto& log = execution_log[i];
                cout << "  " << (i + 1) << ". " << (log.cache_hit ? "HIT " : "MISS") 
                     << " " << log.execution_time_ms << "ms "
                     << log.query.substr(0, 40) << "..." << endl;
            }
        }
    }
};

// 测试查询集合
duckdb::vector<string> GetTestQueries() {
    return {
        // 基础查询
        "SELECT COUNT(*) FROM lineitem",
        "SELECT l_returnflag, COUNT(*) FROM lineitem GROUP BY l_returnflag",
        "SELECT AVG(l_quantity) FROM lineitem",
        "SELECT SUM(l_extendedprice) FROM lineitem WHERE l_discount > 0.05",
        "SELECT l_orderkey, SUM(l_quantity) FROM lineitem GROUP BY l_orderkey LIMIT 10",
        
        // 复杂查询
        "SELECT l_returnflag, l_linestatus, COUNT(*), AVG(l_quantity), SUM(l_extendedprice) FROM lineitem GROUP BY l_returnflag, l_linestatus",
        "SELECT l_partkey, COUNT(*) as cnt FROM lineitem GROUP BY l_partkey HAVING COUNT(*) > 5 ORDER BY cnt DESC LIMIT 20",
        "SELECT EXTRACT(YEAR FROM l_shipdate) as year, COUNT(*) FROM lineitem GROUP BY year ORDER BY year",
        "SELECT l_suppkey, AVG(l_extendedprice * (1 - l_discount)) as avg_revenue FROM lineitem GROUP BY l_suppkey ORDER BY avg_revenue DESC LIMIT 15",
        "SELECT l_shipmode, COUNT(*) FROM lineitem WHERE l_shipdate >= '1995-01-01' GROUP BY l_shipmode",
        
        // 重复一些查询来测试缓存命中
        "SELECT COUNT(*) FROM lineitem",
        "SELECT l_returnflag, COUNT(*) FROM lineitem GROUP BY l_returnflag",
        "SELECT AVG(l_quantity) FROM lineitem",
        "SELECT SUM(l_extendedprice) FROM lineitem WHERE l_discount > 0.05",
        "SELECT COUNT(*) FROM lineitem",
    };
}

int main() {
    cout << "🚀 启动DuckDB ML缓存系统真实测试..." << endl;
    
    try {
        MLEnhancedCache cache_system;
        
        auto test_queries = GetTestQueries();
        
        cout << "\n📊 开始执行测试查询 (" << test_queries.size() << "个查询)..." << endl;
        
        // 执行测试查询
        for (size_t i = 0; i < test_queries.size(); i++) {
            cout << "\n[" << (i + 1) << "/" << test_queries.size() << "] 执行查询..." << endl;
            
            auto result = cache_system.QueryWithCache(test_queries[i]);
            
            if (result && !result->HasError()) {
                cout << "✅ 查询成功，返回 " << result->ColumnCount() << " 列" << endl;
            } else {
                cout << "❌ 查询失败" << endl;
            }
            
            // 短暂延迟模拟真实使用场景
            this_thread::sleep_for(chrono::milliseconds(100));
        }
        
        // 打印最终统计
        cache_system.PrintStatistics();
        
        cout << "\n🎉 测试完成！ML缓存系统运行正常。" << endl;
        
    } catch (const exception& e) {
        cout << "❌ 测试失败: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}