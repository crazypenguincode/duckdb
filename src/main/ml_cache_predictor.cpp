//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/ml_cache_predictor.cpp
//
// 机器学习缓存预测器实现
//===----------------------------------------------------------------------===//

#include "duckdb/main/ml_cache_predictor.hpp"
#include <algorithm>
#include <cmath>
#include <numeric>

namespace duckdb {

//===----------------------------------------------------------------------===//
// 时间序列访问模式预测器
//===----------------------------------------------------------------------===//

TimeSeriesPredictor::TimeSeriesPredictor(size_t window_size, double alpha, double beta, double gamma)
    : window_size(window_size), alpha(alpha), beta(beta), gamma(gamma),
      level(0.0), trend(0.0), seasonal_period(24) {
    access_history.reserve(window_size);
    seasonal_components.resize(seasonal_period, 1.0);
}

double TimeSeriesPredictor::PredictNextAccess(const string &query_hash) {
    auto it = query_patterns.find(query_hash);
    if (it == query_patterns.end()) {
        // 新查询，返回默认预测值
        return 0.1;
    }
    
    auto &pattern = it->second;
    if (pattern.access_times.size() < 2) {
        return 0.1;
    }
    
    // 使用Holt-Winters三重指数平滑法预测
    return HoltWintersPredict(pattern);
}

void TimeSeriesPredictor::RecordAccess(const string &query_hash, 
                                     std::chrono::steady_clock::time_point access_time) {
    auto &pattern = query_patterns[query_hash];
    pattern.access_times.push_back(access_time);
    pattern.access_count++;
    
    // 保持窗口大小
    if (pattern.access_times.size() > window_size) {
        pattern.access_times.erase(pattern.access_times.begin());
    }
    
    // 更新全局访问历史
    access_history.push_back({query_hash, access_time});
    if (access_history.size() > window_size) {
        access_history.erase(access_history.begin());
    }
    
    // 更新模式参数
    UpdatePattern(pattern);
}

double TimeSeriesPredictor::HoltWintersPredict(const AccessPattern &pattern) {
    if (pattern.access_times.size() < seasonal_period) {
        // 数据不足，使用简单指数平滑
        return SimpleExponentialSmoothing(pattern);
    }
    
    // 计算访问间隔序列
    vector<double> intervals;
    for (size_t i = 1; i < pattern.access_times.size(); i++) {
        auto interval = std::chrono::duration_cast<std::chrono::seconds>(
            pattern.access_times[i] - pattern.access_times[i-1]).count();
        intervals.push_back(1.0 / (1.0 + interval / 3600.0)); // 转换为访问频率
    }
    
    if (intervals.empty()) {
        return 0.1;
    }
    
    // Holt-Winters预测
    double forecast = pattern.level + pattern.trend;
    size_t seasonal_index = (intervals.size() - 1) % seasonal_period;
    forecast *= seasonal_components[seasonal_index];
    
    return std::max(0.0, std::min(1.0, forecast));
}

double TimeSeriesPredictor::SimpleExponentialSmoothing(const AccessPattern &pattern) {
    if (pattern.access_times.size() < 2) {
        return 0.1;
    }
    
    // 计算最近的访问频率
    auto now = std::chrono::steady_clock::now();
    auto last_access = pattern.access_times.back();
    auto time_since_last = std::chrono::duration_cast<std::chrono::seconds>(
        now - last_access).count();
    
    return 1.0 / (1.0 + time_since_last / 3600.0);
}

void TimeSeriesPredictor::UpdatePattern(AccessPattern &pattern) {
    if (pattern.access_times.size() < 2) {
        return;
    }
    
    // 计算访问间隔
    vector<double> intervals;
    for (size_t i = 1; i < pattern.access_times.size(); i++) {
        auto interval = std::chrono::duration_cast<std::chrono::seconds>(
            pattern.access_times[i] - pattern.access_times[i-1]).count();
        intervals.push_back(1.0 / (1.0 + interval / 3600.0));
    }
    
    if (intervals.empty()) {
        return;
    }
    
    // 更新Holt-Winters参数
    double current_value = intervals.back();
    
    // 初始化
    if (pattern.level == 0.0) {
        pattern.level = current_value;
        if (intervals.size() > 1) {
            pattern.trend = intervals.back() - intervals[intervals.size()-2];
        }
        return;
    }
    
    // 更新水平值
    double old_level = pattern.level;
    size_t seasonal_index = (intervals.size() - 1) % seasonal_period;
    pattern.level = alpha * (current_value / seasonal_components[seasonal_index]) + 
                   (1 - alpha) * (old_level + pattern.trend);
    
    // 更新趋势
    pattern.trend = beta * (pattern.level - old_level) + (1 - beta) * pattern.trend;
    
    // 更新季节性成分
    seasonal_components[seasonal_index] = gamma * (current_value / pattern.level) + 
                                        (1 - gamma) * seasonal_components[seasonal_index];
}

//===----------------------------------------------------------------------===//
// 多因素缓存价值评估器
//===----------------------------------------------------------------------===//

MultiFactorValueEstimator::MultiFactorValueEstimator() {
    // 初始化权重
    weights.frequency_weight = 0.25;
    weights.recency_weight = 0.20;
    weights.size_weight = 0.15;
    weights.computation_cost_weight = 0.30;
    weights.temporal_locality_weight = 0.10;
}

double MultiFactorValueEstimator::EstimateCacheValue(const CacheValueFeatures &features) {
    double value = 0.0;
    
    // 访问频率因子 (0-1)
    double frequency_factor = NormalizeFrequency(features.access_frequency);
    value += weights.frequency_weight * frequency_factor;
    
    // 时间局部性因子 (0-1)
    double recency_factor = CalculateRecencyFactor(features.last_access_time);
    value += weights.recency_weight * recency_factor;
    
    // 大小因子 (越小越好，0-1)
    double size_factor = CalculateSizeFactor(features.result_size_bytes);
    value += weights.size_weight * size_factor;
    
    // 计算成本因子 (0-1)
    double cost_factor = NormalizeComputationCost(features.computation_cost_ms);
    value += weights.computation_cost_weight * cost_factor;
    
    // 时间局部性因子
    double temporal_factor = features.temporal_locality;
    value += weights.temporal_locality_weight * temporal_factor;
    
    return std::max(0.0, std::min(1.0, value));
}

void MultiFactorValueEstimator::UpdateWeights(const vector<CacheValueSample> &samples) {
    if (samples.size() < 10) {
        return; // 样本不足
    }
    
    // 使用梯度下降优化权重
    const double learning_rate = 0.01;
    const int iterations = 100;
    
    for (int iter = 0; iter < iterations; iter++) {
        WeightGradients gradients = {0.0, 0.0, 0.0, 0.0, 0.0};
        double total_loss = 0.0;
        
        for (const auto &sample : samples) {
            double predicted = EstimateCacheValue(sample.features);
            double error = sample.actual_utility - predicted;
            total_loss += error * error;
            
            // 计算梯度
            double freq_factor = NormalizeFrequency(sample.features.access_frequency);
            double recency_factor = CalculateRecencyFactor(sample.features.last_access_time);
            double size_factor = CalculateSizeFactor(sample.features.result_size_bytes);
            double cost_factor = NormalizeComputationCost(sample.features.computation_cost_ms);
            double temporal_factor = sample.features.temporal_locality;
            
            gradients.frequency_weight += error * freq_factor;
            gradients.recency_weight += error * recency_factor;
            gradients.size_weight += error * size_factor;
            gradients.computation_cost_weight += error * cost_factor;
            gradients.temporal_locality_weight += error * temporal_factor;
        }
        
        // 更新权重
        weights.frequency_weight += learning_rate * gradients.frequency_weight / samples.size();
        weights.recency_weight += learning_rate * gradients.recency_weight / samples.size();
        weights.size_weight += learning_rate * gradients.size_weight / samples.size();
        weights.computation_cost_weight += learning_rate * gradients.computation_cost_weight / samples.size();
        weights.temporal_locality_weight += learning_rate * gradients.temporal_locality_weight / samples.size();
        
        // 归一化权重
        NormalizeWeights();
    }
}

double MultiFactorValueEstimator::NormalizeFrequency(double frequency) {
    // 使用对数归一化
    return std::log(1.0 + frequency) / std::log(1.0 + max_frequency);
}

double MultiFactorValueEstimator::CalculateRecencyFactor(std::chrono::steady_clock::time_point last_access) {
    auto now = std::chrono::steady_clock::now();
    auto time_diff = std::chrono::duration_cast<std::chrono::seconds>(now - last_access).count();
    
    // 指数衰减，1小时半衰期
    return std::exp(-time_diff / 3600.0);
}

double MultiFactorValueEstimator::CalculateSizeFactor(size_t size_bytes) {
    // 大小越小价值越高
    double size_mb = size_bytes / (1024.0 * 1024.0);
    return 1.0 / (1.0 + size_mb / 10.0); // 10MB为参考点
}

double MultiFactorValueEstimator::NormalizeComputationCost(double cost_ms) {
    // 成本越高价值越高
    return std::log(1.0 + cost_ms) / std::log(1.0 + max_computation_cost);
}

void MultiFactorValueEstimator::NormalizeWeights() {
    double sum = weights.frequency_weight + weights.recency_weight + 
                weights.size_weight + weights.computation_cost_weight + 
                weights.temporal_locality_weight;
    
    if (sum > 0.0) {
        weights.frequency_weight /= sum;
        weights.recency_weight /= sum;
        weights.size_weight /= sum;
        weights.computation_cost_weight /= sum;
        weights.temporal_locality_weight /= sum;
    }
}

//===----------------------------------------------------------------------===//
// Adam优化器实现
//===----------------------------------------------------------------------===//

AdamOptimizer::AdamOptimizer(double learning_rate, double beta1, double beta2, double epsilon)
    : learning_rate(learning_rate), beta1(beta1), beta2(beta2), epsilon(epsilon), t(0) {
}

void AdamOptimizer::UpdateParameters(vector<double> &parameters, const vector<double> &gradients) {
    if (parameters.size() != gradients.size()) {
        throw std::invalid_argument("Parameters and gradients size mismatch");
    }
    
    // 初始化动量向量
    if (m.empty()) {
        m.resize(parameters.size(), 0.0);
        v.resize(parameters.size(), 0.0);
    }
    
    t++; // 增加时间步
    
    for (size_t i = 0; i < parameters.size(); i++) {
        // 更新偏置一阶矩估计
        m[i] = beta1 * m[i] + (1.0 - beta1) * gradients[i];
        
        // 更新偏置二阶矩估计
        v[i] = beta2 * v[i] + (1.0 - beta2) * gradients[i] * gradients[i];
        
        // 偏置校正
        double m_hat = m[i] / (1.0 - std::pow(beta1, t));
        double v_hat = v[i] / (1.0 - std::pow(beta2, t));
        
        // 参数更新
        parameters[i] -= learning_rate * m_hat / (std::sqrt(v_hat) + epsilon);
    }
}

void AdamOptimizer::Reset() {
    m.clear();
    v.clear();
    t = 0;
}

//===----------------------------------------------------------------------===//
// 在线学习缓存管理器
//===----------------------------------------------------------------------===//

OnlineLearningCacheManager::OnlineLearningCacheManager(size_t max_samples)
    : max_training_samples(max_samples), adam_optimizer(0.001, 0.9, 0.999, 1e-8) {
    training_samples.reserve(max_samples);
}

void OnlineLearningCacheManager::RecordCacheEvent(const string &query_hash,
                                                const CacheValueFeatures &features,
                                                bool was_hit,
                                                double actual_utility) {
    // 记录时间序列访问
    time_series_predictor.RecordAccess(query_hash, std::chrono::steady_clock::now());
    
    // 记录训练样本
    CacheValueSample sample;
    sample.features = features;
    sample.actual_utility = actual_utility;
    sample.timestamp = std::chrono::steady_clock::now();
    
    training_samples.push_back(sample);
    
    // 保持样本数量限制
    if (training_samples.size() > max_training_samples) {
        training_samples.erase(training_samples.begin());
    }
    
    // 定期更新模型
    if (training_samples.size() % 50 == 0) {
        UpdateModels();
    }
}

double OnlineLearningCacheManager::PredictCacheValue(const string &query_hash,
                                                   const CacheValueFeatures &features) {
    // 结合时间序列预测和多因素价值评估
    double time_series_score = time_series_predictor.PredictNextAccess(query_hash);
    double value_score = value_estimator.EstimateCacheValue(features);
    
    // 加权组合
    return 0.4 * time_series_score + 0.6 * value_score;
}

CacheDecision OnlineLearningCacheManager::MakeCacheDecision(const string &query_hash,
                                                          const CacheValueFeatures &features,
                                                          double cache_pressure) {
    double predicted_value = PredictCacheValue(query_hash, features);
    
    CacheDecision decision;
    decision.should_cache = predicted_value > (0.3 + 0.4 * cache_pressure);
    decision.eviction_priority = 1.0 - predicted_value;
    decision.confidence = CalculateConfidence(features);
    
    return decision;
}

void OnlineLearningCacheManager::UpdateModels() {
    if (training_samples.size() < 10) {
        return;
    }
    
    // 更新多因素价值评估器
    value_estimator.UpdateWeights(training_samples);
    
    // 可以在这里添加更多的模型更新逻辑
}

double OnlineLearningCacheManager::CalculateConfidence(const CacheValueFeatures &features) {
    // 基于特征的置信度计算
    double confidence = 0.5; // 基础置信度
    
    // 访问频率越高，置信度越高
    if (features.access_frequency > 5) {
        confidence += 0.2;
    }
    
    // 计算成本越高，置信度越高
    if (features.computation_cost_ms > 1000) {
        confidence += 0.2;
    }
    
    // 时间局部性越强，置信度越高
    confidence += features.temporal_locality * 0.3;
    
    return std::max(0.0, std::min(1.0, confidence));
}

MLCacheStats OnlineLearningCacheManager::GetStats() const {
    MLCacheStats stats;
    stats.total_predictions = prediction_count;
    stats.total_updates = update_count;
    stats.training_samples = training_samples.size();
    
    // 计算预测准确率
    if (prediction_count > 0) {
        stats.prediction_accuracy = correct_predictions / static_cast<double>(prediction_count);
    }
    
    // 计算平均预测值
    if (!recent_predictions.empty()) {
        stats.avg_prediction_value = std::accumulate(recent_predictions.begin(), 
                                                   recent_predictions.end(), 0.0) / recent_predictions.size();
    }
    
    return stats;
}

} // namespace duckdb