//===----------------------------------------------------------------------===//
//                         DuckDB
//
// test/ml_cache_benchmark.cpp
//
// 机器学习缓存系统性能测试和对比
//===----------------------------------------------------------------------===//

#include "duckdb/main/ml_cache_predictor.hpp"
#include "duckdb/main/query_cache.hpp"
#include "duckdb/main/database.hpp"
#include "duckdb/main/connection.hpp"
#include <iostream>
#include <chrono>
#include <random>
#include <thread>
#include <iomanip>

using namespace duckdb;
using namespace std;

struct BenchmarkResult {
    string strategy_name;
    double hit_rate;
    double avg_response_time_ms;
    size_t total_queries;
    size_t cache_hits;
    size_t cache_misses;
    double memory_usage_mb;
};

class MLCacheBenchmark {
public:
    MLCacheBenchmark() {
        cout << "初始化机器学习缓存基准测试..." << endl;
    }
    
    void RunBenchmark() {
        cout << "\n=== 机器学习缓存系统性能基准测试 ===" << endl;
        
        // 测试不同缓存策略
        vector<BenchmarkResult> results;
        
        cout << "\n1. 测试ML缓存策略..." << endl;
        results.push_back(TestMLCacheStrategy());
        
        cout << "\n2. 测试LRU缓存策略..." << endl;
        results.push_back(TestLRUCacheStrategy());
        
        cout << "\n3. 测试TTL缓存策略..." << endl;
        results.push_back(TestTTLCacheStrategy());
        
        cout << "\n4. 测试无缓存基准..." << endl;
        results.push_back(TestNoCacheBaseline());
        
        // 输出对比结果
        PrintBenchmarkResults(results);
        
        // 分析ML组件性能
        TestMLComponents();
    }

private:
    BenchmarkResult TestMLCacheStrategy() {
        OnlineLearningCacheManager ml_manager(1000);
        return RunCacheTest("ML-Based", ml_manager);
    }
    
    BenchmarkResult TestLRUCacheStrategy() {
        // 模拟LRU策略
        return RunTraditionalCacheTest("LRU-Based", CacheEvictionStrategy::LRU_BASED);
    }
    
    BenchmarkResult TestTTLCacheStrategy() {
        return RunTraditionalCacheTest("TTL-Based", CacheEvictionStrategy::TTL_BASED);
    }
    
    BenchmarkResult TestNoCacheBaseline() {
        return RunNoCacheTest("No-Cache");
    }
    
    BenchmarkResult RunCacheTest(const string &strategy_name, OnlineLearningCacheManager &ml_manager) {
        BenchmarkResult result;
        result.strategy_name = strategy_name;
        
        // 模拟查询负载
        vector<string> queries = GenerateTestQueries();
        unordered_map<string, bool> cache_state;
        
        size_t total_queries = 2000;
        size_t cache_hits = 0;
        double total_response_time = 0.0;
        
        random_device rd;
        mt19937 gen(rd());
        uniform_int_distribution<> query_dist(0, queries.size() - 1);
        
        // 预热阶段 - 让ML模型学习访问模式
        cout << "  预热ML模型..." << endl;
        for (size_t i = 0; i < 500; i++) {
            string query = queries[query_dist(gen)];
            CacheValueFeatures features = GenerateFeatures(query, i);
            
            // 模拟访问模式 - 某些查询更频繁
            bool frequent_query = (hash<string>{}(query) % 3 == 0);
            double utility = frequent_query ? 0.8 : 0.3;
            
            ml_manager.RecordCacheEvent(query, features, false, utility);
        }
        
        cout << "  执行性能测试..." << endl;
        
        // 正式测试阶段
        for (size_t i = 0; i < total_queries; i++) {
            auto start_time = chrono::high_resolution_clock::now();
            
            string query = queries[query_dist(gen)];
            CacheValueFeatures features = GenerateFeatures(query, i);
            
            // 使用ML管理器做缓存决策
            CacheDecision decision = ml_manager.MakeCacheDecision(query, features, 0.5);
            
            bool cache_hit = false;
            if (decision.should_cache && cache_state.count(query)) {
                cache_hit = true;
                cache_hits++;
                // 模拟缓存命中的快速响应
                this_thread::sleep_for(chrono::microseconds(50));
            } else {
                // 模拟查询执行
                int exec_time_ms = SimulateQueryExecution(query);
                this_thread::sleep_for(chrono::milliseconds(exec_time_ms));
                
                // 根据ML决策更新缓存状态
                if (decision.should_cache) {
                    cache_state[query] = true;
                }
            }
            
            // 记录缓存事件用于持续学习
            double utility = cache_hit ? 0.9 : 0.1;
            ml_manager.RecordCacheEvent(query, features, cache_hit, utility);
            
            auto end_time = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::microseconds>(end_time - start_time);
            total_response_time += duration.count() / 1000.0;
        }
        
        result.total_queries = total_queries;
        result.cache_hits = cache_hits;
        result.cache_misses = total_queries - cache_hits;
        result.hit_rate = static_cast<double>(cache_hits) / total_queries;
        result.avg_response_time_ms = total_response_time / total_queries;
        result.memory_usage_mb = EstimateMemoryUsage(cache_state.size());
        
        return result;
    }
    
    BenchmarkResult RunTraditionalCacheTest(const string &strategy_name, CacheEvictionStrategy strategy) {
        BenchmarkResult result;
        result.strategy_name = strategy_name;
        
        // 简单的缓存模拟
        unordered_map<string, chrono::steady_clock::time_point> cache_state;
        size_t max_cache_size = 100;
        
        vector<string> queries = GenerateTestQueries();
        size_t total_queries = 2000;
        size_t cache_hits = 0;
        double total_response_time = 0.0;
        
        random_device rd;
        mt19937 gen(rd());
        uniform_int_distribution<> query_dist(0, queries.size() - 1);
        
        for (size_t i = 0; i < total_queries; i++) {
            auto start_time = chrono::high_resolution_clock::now();
            
            string query = queries[query_dist(gen)];
            
            bool cache_hit = cache_state.count(query) > 0;
            if (cache_hit) {
                cache_hits++;
                // 更新访问时间（LRU）
                cache_state[query] = chrono::steady_clock::now();
                this_thread::sleep_for(chrono::microseconds(50));
            } else {
                // 模拟查询执行
                int exec_time_ms = SimulateQueryExecution(query);
                this_thread::sleep_for(chrono::milliseconds(exec_time_ms));
                
                // 添加到缓存
                cache_state[query] = chrono::steady_clock::now();
                
                // 缓存淘汰
                if (cache_state.size() > max_cache_size) {
                    EvictFromCache(cache_state, strategy);
                }
            }
            
            auto end_time = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::microseconds>(end_time - start_time);
            total_response_time += duration.count() / 1000.0;
        }
        
        result.total_queries = total_queries;
        result.cache_hits = cache_hits;
        result.cache_misses = total_queries - cache_hits;
        result.hit_rate = static_cast<double>(cache_hits) / total_queries;
        result.avg_response_time_ms = total_response_time / total_queries;
        result.memory_usage_mb = EstimateMemoryUsage(cache_state.size());
        
        return result;
    }
    
    BenchmarkResult RunNoCacheTest(const string &strategy_name) {
        BenchmarkResult result;
        result.strategy_name = strategy_name;
        
        vector<string> queries = GenerateTestQueries();
        size_t total_queries = 2000;
        double total_response_time = 0.0;
        
        random_device rd;
        mt19937 gen(rd());
        uniform_int_distribution<> query_dist(0, queries.size() - 1);
        
        for (size_t i = 0; i < total_queries; i++) {
            auto start_time = chrono::high_resolution_clock::now();
            
            string query = queries[query_dist(gen)];
            
            // 每次都执行查询
            int exec_time_ms = SimulateQueryExecution(query);
            this_thread::sleep_for(chrono::milliseconds(exec_time_ms));
            
            auto end_time = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::microseconds>(end_time - start_time);
            total_response_time += duration.count() / 1000.0;
        }
        
        result.total_queries = total_queries;
        result.cache_hits = 0;
        result.cache_misses = total_queries;
        result.hit_rate = 0.0;
        result.avg_response_time_ms = total_response_time / total_queries;
        result.memory_usage_mb = 0.0;
        
        return result;
    }
    
    vector<string> GenerateTestQueries() {
        return {
            "SELECT * FROM users WHERE id = ?",
            "SELECT COUNT(*) FROM orders WHERE date > ?",
            "SELECT * FROM products WHERE category = ?",
            "SELECT AVG(price) FROM products",
            "SELECT * FROM logs WHERE level = 'ERROR'",
            "SELECT u.name, COUNT(o.id) FROM users u JOIN orders o ON u.id = o.user_id GROUP BY u.id",
            "SELECT * FROM inventory WHERE stock < 10",
            "SELECT SUM(amount) FROM transactions WHERE date = CURRENT_DATE",
            "SELECT * FROM categories ORDER BY name",
            "SELECT p.name, c.name FROM products p JOIN categories c ON p.category_id = c.id"
        };
    }
    
    CacheValueFeatures GenerateFeatures(const string &query, size_t iteration) {
        CacheValueFeatures features;
        
        // 基于查询哈希生成一致的特征
        size_t query_hash = hash<string>{}(query);
        
        features.access_frequency = 1.0 + (query_hash % 20);
        features.last_access_time = chrono::steady_clock::now();
        features.result_size_bytes = 1024 * (1 + (query_hash % 100));
        features.computation_cost_ms = 100.0 + (query_hash % 1000);
        features.temporal_locality = 0.1 + 0.8 * ((query_hash % 100) / 100.0);
        
        return features;
    }
    
    int SimulateQueryExecution(const string &query) {
        // 基于查询复杂度模拟执行时间
        size_t query_hash = hash<string>{}(query);
        
        // 简单查询: 50-200ms
        // 复杂查询: 200-1000ms
        bool is_complex = query.find("JOIN") != string::npos || 
                         query.find("GROUP BY") != string::npos ||
                         query.find("ORDER BY") != string::npos;
        
        if (is_complex) {
            return 200 + (query_hash % 800);
        } else {
            return 50 + (query_hash % 150);
        }
    }
    
    void EvictFromCache(unordered_map<string, chrono::steady_clock::time_point> &cache_state, 
                       CacheEvictionStrategy strategy) {
        if (cache_state.empty()) return;
        
        string victim;
        
        if (strategy == CacheEvictionStrategy::LRU_BASED) {
            // 找到最久未访问的条目
            auto oldest_time = chrono::steady_clock::now();
            for (const auto &entry : cache_state) {
                if (entry.second < oldest_time) {
                    oldest_time = entry.second;
                    victim = entry.first;
                }
            }
        } else {
            // TTL策略 - 随机淘汰（简化实现）
            auto it = cache_state.begin();
            advance(it, rand() % cache_state.size());
            victim = it->first;
        }
        
        cache_state.erase(victim);
    }
    
    double EstimateMemoryUsage(size_t cache_entries) {
        // 估算每个缓存条目平均占用100KB
        return cache_entries * 0.1; // MB
    }
    
    void PrintBenchmarkResults(const vector<BenchmarkResult> &results) {
        cout << "\n=== 缓存策略性能对比结果 ===" << endl;
        cout << left << setw(15) << "策略" 
             << setw(12) << "命中率" 
             << setw(15) << "平均响应时间" 
             << setw(12) << "总查询数" 
             << setw(10) << "命中数" 
             << setw(10) << "未命中数" 
             << setw(12) << "内存使用" << endl;
        cout << string(90, '-') << endl;
        
        for (const auto &result : results) {
            cout << left << setw(15) << result.strategy_name
                 << setw(12) << fixed << setprecision(3) << result.hit_rate
                 << setw(15) << fixed << setprecision(2) << result.avg_response_time_ms << "ms"
                 << setw(12) << result.total_queries
                 << setw(10) << result.cache_hits
                 << setw(10) << result.cache_misses
                 << setw(12) << fixed << setprecision(1) << result.memory_usage_mb << "MB" << endl;
        }
        
        // 计算性能提升
        if (results.size() >= 4) {
            auto ml_result = results[0];
            auto lru_result = results[1];
            auto no_cache_result = results[3];
            
            cout << "\n=== 性能提升分析 ===" << endl;
            
            double hit_rate_improvement = (ml_result.hit_rate - lru_result.hit_rate) * 100;
            cout << "ML vs LRU 命中率提升: " << fixed << setprecision(2) << hit_rate_improvement << "%" << endl;
            
            double response_time_improvement = (lru_result.avg_response_time_ms - ml_result.avg_response_time_ms) / lru_result.avg_response_time_ms * 100;
            cout << "ML vs LRU 响应时间改善: " << fixed << setprecision(2) << response_time_improvement << "%" << endl;
            
            double overall_improvement = (no_cache_result.avg_response_time_ms - ml_result.avg_response_time_ms) / no_cache_result.avg_response_time_ms * 100;
            cout << "ML缓存 vs 无缓存 总体性能提升: " << fixed << setprecision(2) << overall_improvement << "%" << endl;
        }
    }
    
    void TestMLComponents() {
        cout << "\n=== ML组件性能测试 ===" << endl;
        
        // 测试时间序列预测器
        TestTimeSeriesPredictor();
        
        // 测试多因素价值评估器
        TestValueEstimator();
        
        // 测试Adam优化器
        TestAdamOptimizer();
    }
    
    void TestTimeSeriesPredictor() {
        cout << "\n--- 时间序列预测器性能测试 ---" << endl;
        
        TimeSeriesPredictor predictor(100, 0.3, 0.3, 0.3);
        
        auto start_time = chrono::high_resolution_clock::now();
        
        // 模拟1000次访问记录
        for (int i = 0; i < 1000; i++) {
            string query = "query_" + to_string(i % 10);
            predictor.RecordAccess(query, chrono::steady_clock::now());
        }
        
        // 测试1000次预测
        double total_prediction_time = 0.0;
        for (int i = 0; i < 1000; i++) {
            auto pred_start = chrono::high_resolution_clock::now();
            string query = "query_" + to_string(i % 10);
            double prediction = predictor.PredictNextAccess(query);
            auto pred_end = chrono::high_resolution_clock::now();
            
            total_prediction_time += chrono::duration_cast<chrono::microseconds>(pred_end - pred_start).count();
        }
        
        auto end_time = chrono::high_resolution_clock::now();
        auto total_time = chrono::duration_cast<chrono::milliseconds>(end_time - start_time).count();
        
        cout << "时间序列预测器统计:" << endl;
        cout << "  总处理时间: " << total_time << "ms" << endl;
        cout << "  平均预测时间: " << fixed << setprecision(2) << total_prediction_time / 1000.0 << "μs" << endl;
        cout << "  访问模式数量: " << predictor.GetPatternCount() << endl;
    }
    
    void TestValueEstimator() {
        cout << "\n--- 多因素价值评估器性能测试 ---" << endl;
        
        MultiFactorValueEstimator estimator;
        
        auto start_time = chrono::high_resolution_clock::now();
        
        // 测试1000次价值评估
        double total_estimation_time = 0.0;
        for (int i = 0; i < 1000; i++) {
            CacheValueFeatures features;
            features.access_frequency = 1.0 + (i % 20);
            features.last_access_time = chrono::steady_clock::now();
            features.result_size_bytes = 1024 * (1 + i % 100);
            features.computation_cost_ms = 100.0 + (i % 1000);
            features.temporal_locality = 0.1 + 0.8 * (i % 100) / 100.0;
            
            auto est_start = chrono::high_resolution_clock::now();
            double value = estimator.EstimateCacheValue(features);
            auto est_end = chrono::high_resolution_clock::now();
            
            total_estimation_time += chrono::duration_cast<chrono::microseconds>(est_end - est_start).count();
        }
        
        auto end_time = chrono::high_resolution_clock::now();
        auto total_time = chrono::duration_cast<chrono::milliseconds>(end_time - start_time).count();
        
        cout << "多因素价值评估器统计:" << endl;
        cout << "  总处理时间: " << total_time << "ms" << endl;
        cout << "  平均评估时间: " << fixed << setprecision(2) << total_estimation_time / 1000.0 << "μs" << endl;
        
        auto weights = estimator.GetWeights();
        cout << "  当前权重分布:" << endl;
        cout << "    频率权重: " << fixed << setprecision(3) << weights.frequency_weight << endl;
        cout << "    时间权重: " << fixed << setprecision(3) << weights.recency_weight << endl;
        cout << "    大小权重: " << fixed << setprecision(3) << weights.size_weight << endl;
        cout << "    成本权重: " << fixed << setprecision(3) << weights.computation_cost_weight << endl;
        cout << "    局部性权重: " << fixed << setprecision(3) << weights.temporal_locality_weight << endl;
    }
    
    void TestAdamOptimizer() {
        cout << "\n--- Adam优化器性能测试 ---" << endl;
        
        AdamOptimizer optimizer(0.01, 0.9, 0.999, 1e-8);
        
        // 测试优化一个简单的二次函数
        vector<double> parameters = {5.0, -3.0, 2.0}; // 初始参数
        
        auto start_time = chrono::high_resolution_clock::now();
        
        // 100次优化迭代
        for (int iter = 0; iter < 100; iter++) {
            // 计算梯度 (简化的二次函数梯度)
            vector<double> gradients = {
                2.0 * (parameters[0] - 1.0),
                2.0 * (parameters[1] + 2.0),
                2.0 * (parameters[2] - 0.5)
            };
            
            optimizer.UpdateParameters(parameters, gradients);
        }
        
        auto end_time = chrono::high_resolution_clock::now();
        auto total_time = chrono::duration_cast<chrono::microseconds>(end_time - start_time).count();
        
        cout << "Adam优化器统计:" << endl;
        cout << "  总优化时间: " << total_time << "μs" << endl;
        cout << "  平均迭代时间: " << fixed << setprecision(2) << total_time / 100.0 << "μs" << endl;
        cout << "  最终参数: [" << fixed << setprecision(3) 
             << parameters[0] << ", " << parameters[1] << ", " << parameters[2] << "]" << endl;
        cout << "  期望参数: [1.000, -2.000, 0.500]" << endl;
    }
};

int main() {
    try {
        MLCacheBenchmark benchmark;
        benchmark.RunBenchmark();
        
        cout << "\n🎉 机器学习缓存基准测试完成！" << endl;
        return 0;
    } catch (const exception &e) {
        cout << "❌ 测试失败: " << e.what() << endl;
        return 1;
    }
}