//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache_ml_strategy.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/main/query_cache.hpp"
#include "duckdb/common/vector.hpp"
#include <unordered_map>
#include <queue>
#include <memory>

namespace duckdb {

//! 机器学习特征向量
struct MLFeatureVector {
    double query_complexity = 0.0;      // 查询复杂度
    double execution_time = 0.0;        // 执行时间
    double result_size = 0.0;           // 结果大小
    double access_frequency = 0.0;      // 访问频率
    double temporal_locality = 0.0;     // 时间局部性
    double spatial_locality = 0.0;      // 空间局部性
    double cost_benefit_ratio = 0.0;    // 成本效益比
    double cache_hit_probability = 0.0; // 缓存命中概率预测
    
    vector<double> ToVector() const {
        return {query_complexity, execution_time, result_size, access_frequency,
                temporal_locality, spatial_locality, cost_benefit_ratio, cache_hit_probability};
    }
};

//! 缓存决策类型
enum class CacheDecision {
    CACHE_IN_MEMORY,     // 缓存到内存
    CACHE_TO_DISK,       // 缓存到磁盘
    CACHE_MATERIALIZED,  // 缓存为物化视图
    DO_NOT_CACHE,        // 不缓存
    EVICT_FROM_MEMORY,   // 从内存中驱逐
    MIGRATE_TO_DISK      // 迁移到磁盘
};

//! 机器学习模型接口
class MLCacheModel {
public:
    virtual ~MLCacheModel() = default;
    
    //! 预测缓存决策
    virtual CacheDecision Predict(const MLFeatureVector &features) = 0;
    
    //! 训练模型
    virtual void Train(const vector<pair<MLFeatureVector, CacheDecision>> &training_data) = 0;
    
    //! 在线学习更新
    virtual void Update(const MLFeatureVector &features, CacheDecision actual_decision, double reward) = 0;
    
    //! 获取模型置信度
    virtual double GetConfidence(const MLFeatureVector &features) = 0;
};

//! 基于决策树的缓存模型
class DecisionTreeCacheModel : public MLCacheModel {
public:
    DecisionTreeCacheModel();
    
    CacheDecision Predict(const MLFeatureVector &features) override;
    void Train(const vector<pair<MLFeatureVector, CacheDecision>> &training_data) override;
    void Update(const MLFeatureVector &features, CacheDecision actual_decision, double reward) override;
    double GetConfidence(const MLFeatureVector &features) override;

private:
    struct DecisionNode {
        int feature_index = -1;
        double threshold = 0.0;
        CacheDecision decision = CacheDecision::DO_NOT_CACHE;
        unique_ptr<DecisionNode> left;
        unique_ptr<DecisionNode> right;
        bool is_leaf = false;
        double confidence = 0.0;
    };
    
    unique_ptr<DecisionNode> root;
    
    //! 构建决策树
    unique_ptr<DecisionNode> BuildTree(const vector<pair<MLFeatureVector, CacheDecision>> &data, int depth = 0);
    
    //! 计算信息增益
    double CalculateInformationGain(const vector<pair<MLFeatureVector, CacheDecision>> &data, 
                                   int feature_index, double threshold);
    
    //! 计算熵
    double CalculateEntropy(const vector<CacheDecision> &decisions);
};

//! 基于强化学习的缓存模型
class ReinforcementLearningCacheModel : public MLCacheModel {
public:
    ReinforcementLearningCacheModel(double learning_rate = 0.1, double discount_factor = 0.9);
    
    CacheDecision Predict(const MLFeatureVector &features) override;
    void Train(const vector<pair<MLFeatureVector, CacheDecision>> &training_data) override;
    void Update(const MLFeatureVector &features, CacheDecision actual_decision, double reward) override;
    double GetConfidence(const MLFeatureVector &features) override;

private:
    double learning_rate;
    double discount_factor;
    double exploration_rate = 0.1; // ε-greedy策略的探索率
    
    //! Q值表 (状态-动作值函数)
    unordered_map<string, unordered_map<CacheDecision, double>> q_table;
    
    //! 将特征向量转换为状态字符串
    string FeaturesToState(const MLFeatureVector &features);
    
    //! 选择动作（ε-greedy策略）
    CacheDecision SelectAction(const string &state);
    
    //! 更新Q值
    void UpdateQValue(const string &state, CacheDecision action, double reward, const string &next_state);
};

//! 策略5: 基于机器学习的智能缓存策略
class MLIntelligentPersistence : public CachePersistenceInterface {
public:
    MLIntelligentPersistence(ClientContext &context);
    
    bool Initialize(const CachePersistenceConfig &config) override;
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override;
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override;
    bool DeleteEntry(const string &key) override;
    bool EntryExists(const string &key) override;
    vector<string> GetAllKeys() override;
    bool Clear() override;
    bool Sync() override;
    idx_t GetStorageSize() const override;
    void Close() override;
    
    //! 设置ML模型
    void SetMLModel(unique_ptr<MLCacheModel> model);
    
    //! 获取性能统计
    struct MLStats {
        idx_t total_predictions = 0;
        idx_t correct_predictions = 0;
        double accuracy = 0.0;
        idx_t memory_hits = 0;
        idx_t disk_hits = 0;
        idx_t materialized_hits = 0;
        double avg_confidence = 0.0;
    };
    MLStats GetMLStats() const;

private:
    ClientContext &context;
    CachePersistenceConfig config;
    
    //! 不同的存储后端
    unique_ptr<MemoryOnlyPersistence> memory_storage;
    unique_ptr<WALFormatPersistence> disk_storage;
    unique_ptr<MaterializedViewPersistence> materialized_storage;
    
    //! ML模型
    unique_ptr<MLCacheModel> ml_model;
    
    //! 特征提取器
    MLFeatureVector ExtractFeatures(const string &key, const QueryCacheEntry &entry);
    
    //! 计算奖励函数
    double CalculateReward(const string &key, CacheDecision decision, bool was_hit, double access_time);
    
    //! 访问统计
    struct AccessStats {
        idx_t access_count = 0;
        std::chrono::steady_clock::time_point last_access;
        std::chrono::steady_clock::time_point first_access;
        double avg_access_time = 0.0;
        CacheDecision last_decision = CacheDecision::DO_NOT_CACHE;
    };
    unordered_map<string, AccessStats> access_stats;
    
    //! ML统计信息
    mutable MLStats ml_stats;
    mutable mutex stats_mutex;
    
    //! 训练数据收集
    vector<pair<MLFeatureVector, CacheDecision>> training_data;
    idx_t max_training_data_size = 10000;
    
    //! 定期训练模型
    void TrainModel();
    
    //! 更新访问统计
    void UpdateAccessStats(const string &key, bool was_hit, double access_time);
    
    //! 根据ML决策选择存储后端
    CachePersistenceInterface* SelectStorage(CacheDecision decision);
    
    //! 数据迁移
    bool MigrateEntry(const string &key, CacheDecision from_decision, CacheDecision to_decision);
};

//! ML缓存策略工厂
class MLCacheStrategyFactory {
public:
    //! 创建决策树模型
    static unique_ptr<MLCacheModel> CreateDecisionTreeModel();
    
    //! 创建强化学习模型
    static unique_ptr<MLCacheModel> CreateReinforcementLearningModel(double learning_rate = 0.1, 
                                                                    double discount_factor = 0.9);
    
    //! 创建集成模型（多个模型的组合）
    static unique_ptr<MLCacheModel> CreateEnsembleModel(vector<unique_ptr<MLCacheModel>> models);
};

} // namespace duckdb