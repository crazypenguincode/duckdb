//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/ml_cache_predictor.hpp
//
// 机器学习缓存预测器头文件
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/common.hpp"
#include "duckdb/common/unordered_map.hpp"
#include <chrono>
#include <vector>
#include <queue>

namespace duckdb {

//===----------------------------------------------------------------------===//
// 时间序列访问模式预测
//===----------------------------------------------------------------------===//

struct AccessPattern {
    vector<std::chrono::steady_clock::time_point> access_times;
    size_t access_count = 0;
    double level = 0.0;      // Holt-Winters水平值
    double trend = 0.0;      // Holt-Winters趋势值
};

struct AccessRecord {
    string query_hash;
    std::chrono::steady_clock::time_point access_time;
};

class TimeSeriesPredictor {
public:
    TimeSeriesPredictor(size_t window_size = 100, double alpha = 0.3, double beta = 0.3, double gamma = 0.3);
    
    //! 预测下次访问概率
    double PredictNextAccess(const string &query_hash);
    
    //! 记录访问事件
    void RecordAccess(const string &query_hash, std::chrono::steady_clock::time_point access_time);
    
    //! 获取访问模式统计
    size_t GetPatternCount() const { return query_patterns.size(); }

private:
    //! Holt-Winters三重指数平滑预测
    double HoltWintersPredict(const AccessPattern &pattern);
    
    //! 简单指数平滑预测
    double SimpleExponentialSmoothing(const AccessPattern &pattern);
    
    //! 更新访问模式参数
    void UpdatePattern(AccessPattern &pattern);

private:
    size_t window_size;
    double alpha, beta, gamma;  // Holt-Winters参数
    size_t seasonal_period;     // 季节性周期
    
    unordered_map<string, AccessPattern> query_patterns;
    vector<AccessRecord> access_history;
    vector<double> seasonal_components;
    
    double level, trend;  // 全局Holt-Winters参数
};

//===----------------------------------------------------------------------===//
// 多因素缓存价值评估
//===----------------------------------------------------------------------===//

struct CacheValueFeatures {
    double access_frequency = 0.0;
    std::chrono::steady_clock::time_point last_access_time;
    size_t result_size_bytes = 0;
    double computation_cost_ms = 0.0;
    double temporal_locality = 0.0;
};

struct CacheValueWeights {
    double frequency_weight = 0.25;
    double recency_weight = 0.20;
    double size_weight = 0.15;
    double computation_cost_weight = 0.30;
    double temporal_locality_weight = 0.10;
};

struct WeightGradients {
    double frequency_weight = 0.0;
    double recency_weight = 0.0;
    double size_weight = 0.0;
    double computation_cost_weight = 0.0;
    double temporal_locality_weight = 0.0;
};

struct CacheValueSample {
    CacheValueFeatures features;
    double actual_utility;
    std::chrono::steady_clock::time_point timestamp;
};

class MultiFactorValueEstimator {
public:
    MultiFactorValueEstimator();
    
    //! 估算缓存价值
    double EstimateCacheValue(const CacheValueFeatures &features);
    
    //! 基于样本更新权重
    void UpdateWeights(const vector<CacheValueSample> &samples);
    
    //! 获取当前权重
    const CacheValueWeights& GetWeights() const { return weights; }

private:
    //! 归一化访问频率
    double NormalizeFrequency(double frequency);
    
    //! 计算时间局部性因子
    double CalculateRecencyFactor(std::chrono::steady_clock::time_point last_access);
    
    //! 计算大小因子
    double CalculateSizeFactor(size_t size_bytes);
    
    //! 归一化计算成本
    double NormalizeComputationCost(double cost_ms);
    
    //! 归一化权重
    void NormalizeWeights();

private:
    CacheValueWeights weights;
    double max_frequency = 100.0;
    double max_computation_cost = 10000.0;
};

//===----------------------------------------------------------------------===//
// Adam优化器
//===----------------------------------------------------------------------===//

class AdamOptimizer {
public:
    AdamOptimizer(double learning_rate = 0.001, double beta1 = 0.9, double beta2 = 0.999, double epsilon = 1e-8);
    
    //! 更新参数
    void UpdateParameters(vector<double> &parameters, const vector<double> &gradients);
    
    //! 重置优化器状态
    void Reset();

private:
    double learning_rate;
    double beta1, beta2, epsilon;
    size_t t;  // 时间步
    
    vector<double> m;  // 一阶矩估计
    vector<double> v;  // 二阶矩估计
};

//===----------------------------------------------------------------------===//
// 缓存决策结构
//===----------------------------------------------------------------------===//

struct CacheDecision {
    bool should_cache = false;
    double eviction_priority = 0.0;
    double confidence = 0.0;
};

//===----------------------------------------------------------------------===//
// ML统计信息
//===----------------------------------------------------------------------===//

struct MLCacheStats {
    size_t total_predictions = 0;
    size_t total_updates = 0;
    size_t training_samples = 0;
    double prediction_accuracy = 0.0;
    double avg_prediction_value = 0.0;
};

//===----------------------------------------------------------------------===//
// 在线学习缓存管理器
//===----------------------------------------------------------------------===//

class OnlineLearningCacheManager {
public:
    OnlineLearningCacheManager(size_t max_samples = 1000);
    
    //! 记录缓存事件用于学习
    void RecordCacheEvent(const string &query_hash,
                         const CacheValueFeatures &features,
                         bool was_hit,
                         double actual_utility);
    
    //! 预测缓存价值
    double PredictCacheValue(const string &query_hash, const CacheValueFeatures &features);
    
    //! 做出缓存决策
    CacheDecision MakeCacheDecision(const string &query_hash,
                                  const CacheValueFeatures &features,
                                  double cache_pressure);
    
    //! 获取ML统计信息
    MLCacheStats GetStats() const;

private:
    //! 更新机器学习模型
    void UpdateModels();
    
    //! 计算预测置信度
    double CalculateConfidence(const CacheValueFeatures &features);

private:
    TimeSeriesPredictor time_series_predictor;
    MultiFactorValueEstimator value_estimator;
    AdamOptimizer adam_optimizer;
    
    vector<CacheValueSample> training_samples;
    size_t max_training_samples;
    
    // 统计信息
    size_t prediction_count = 0;
    size_t update_count = 0;
    size_t correct_predictions = 0;
    vector<double> recent_predictions;
};

} // namespace duckdb