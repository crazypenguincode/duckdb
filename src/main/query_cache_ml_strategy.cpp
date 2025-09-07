//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache_ml_strategy.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache_ml_strategy.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/common/types/hash.hpp"
#include "duckdb/main/client_context.hpp"
#include <algorithm>
#include <random>
#include <cmath>

namespace duckdb {

//===----------------------------------------------------------------------===//
// DecisionTreeCacheModel Implementation
//===----------------------------------------------------------------------===//

DecisionTreeCacheModel::DecisionTreeCacheModel() {
    // 初始化一个简单的默认决策树
    root = make_uniq<DecisionNode>();
    root->is_leaf = true;
    root->decision = CacheDecision::CACHE_IN_MEMORY;
    root->confidence = 0.5;
}

CacheDecision DecisionTreeCacheModel::Predict(const MLFeatureVector &features) {
    if (!root) {
        return CacheDecision::DO_NOT_CACHE;
    }
    
    DecisionNode *current = root.get();
    while (!current->is_leaf) {
        auto feature_vector = features.ToVector();
        if (current->feature_index < 0 || current->feature_index >= (int)feature_vector.size()) {
            break;
        }
        
        if (feature_vector[current->feature_index] <= current->threshold) {
            current = current->left.get();
        } else {
            current = current->right.get();
        }
        
        if (!current) {
            break;
        }
    }
    
    return current ? current->decision : CacheDecision::DO_NOT_CACHE;
}

void DecisionTreeCacheModel::Train(const vector<pair<MLFeatureVector, CacheDecision>> &training_data) {
    if (training_data.empty()) {
        return;
    }
    
    root = BuildTree(training_data);
}

void DecisionTreeCacheModel::Update(const MLFeatureVector &features, CacheDecision actual_decision, double reward) {
    // 简化的在线学习：收集数据用于下次重训练
    // 实际实现中可以使用增量学习算法
}

double DecisionTreeCacheModel::GetConfidence(const MLFeatureVector &features) {
    if (!root) {
        return 0.0;
    }
    
    DecisionNode *current = root.get();
    while (!current->is_leaf && current->left && current->right) {
        auto feature_vector = features.ToVector();
        if (current->feature_index < 0 || current->feature_index >= (int)feature_vector.size()) {
            break;
        }
        
        if (feature_vector[current->feature_index] <= current->threshold) {
            current = current->left.get();
        } else {
            current = current->right.get();
        }
    }
    
    return current ? current->confidence : 0.0;
}

unique_ptr<DecisionTreeCacheModel::DecisionNode> 
DecisionTreeCacheModel::BuildTree(const vector<pair<MLFeatureVector, CacheDecision>> &data, int depth) {
    auto node = make_uniq<DecisionNode>();
    
    // 停止条件：深度过大或数据太少
    if (depth > 10 || data.size() < 5) {
        node->is_leaf = true;
        // 选择最常见的决策
        unordered_map<CacheDecision, int> decision_counts;
        for (const auto &item : data) {
            decision_counts[item.second]++;
        }
        
        CacheDecision best_decision = CacheDecision::DO_NOT_CACHE;
        int max_count = 0;
        for (const auto &count : decision_counts) {
            if (count.second > max_count) {
                max_count = count.second;
                best_decision = count.first;
            }
        }
        
        node->decision = best_decision;
        node->confidence = static_cast<double>(max_count) / data.size();
        return node;
    }
    
    // 寻找最佳分割
    double best_gain = -1.0;
    int best_feature = -1;
    double best_threshold = 0.0;
    
    auto feature_vector = data[0].first.ToVector();
    for (int feature_idx = 0; feature_idx < (int)feature_vector.size(); feature_idx++) {
        // 尝试不同的阈值
        vector<double> feature_values;
        for (const auto &item : data) {
            auto features = item.first.ToVector();
            if (feature_idx < (int)features.size()) {
                feature_values.push_back(features[feature_idx]);
            }
        }
        
        sort(feature_values.begin(), feature_values.end());
        
        for (size_t i = 1; i < feature_values.size(); i++) {
            double threshold = (feature_values[i-1] + feature_values[i]) / 2.0;
            double gain = CalculateInformationGain(data, feature_idx, threshold);
            
            if (gain > best_gain) {
                best_gain = gain;
                best_feature = feature_idx;
                best_threshold = threshold;
            }
        }
    }
    
    // 如果没有找到好的分割，创建叶子节点
    if (best_feature == -1 || best_gain <= 0.0) {
        node->is_leaf = true;
        node->decision = CacheDecision::CACHE_IN_MEMORY; // 默认决策
        node->confidence = 0.5;
        return node;
    }
    
    // 创建分割
    node->feature_index = best_feature;
    node->threshold = best_threshold;
    
    vector<pair<MLFeatureVector, CacheDecision>> left_data, right_data;
    for (const auto &item : data) {
        auto features = item.first.ToVector();
        if (best_feature < (int)features.size()) {
            if (features[best_feature] <= best_threshold) {
                left_data.push_back(item);
            } else {
                right_data.push_back(item);
            }
        }
    }
    
    if (!left_data.empty()) {
        node->left = BuildTree(left_data, depth + 1);
    }
    if (!right_data.empty()) {
        node->right = BuildTree(right_data, depth + 1);
    }
    
    return node;
}

double DecisionTreeCacheModel::CalculateInformationGain(const vector<pair<MLFeatureVector, CacheDecision>> &data, 
                                                       int feature_index, double threshold) {
    // 计算原始熵
    vector<CacheDecision> all_decisions;
    for (const auto &item : data) {
        all_decisions.push_back(item.second);
    }
    double original_entropy = CalculateEntropy(all_decisions);
    
    // 分割数据
    vector<CacheDecision> left_decisions, right_decisions;
    for (const auto &item : data) {
        auto features = item.first.ToVector();
        if (feature_index < (int)features.size()) {
            if (features[feature_index] <= threshold) {
                left_decisions.push_back(item.second);
            } else {
                right_decisions.push_back(item.second);
            }
        }
    }
    
    if (left_decisions.empty() || right_decisions.empty()) {
        return 0.0;
    }
    
    // 计算加权熵
    double left_entropy = CalculateEntropy(left_decisions);
    double right_entropy = CalculateEntropy(right_decisions);
    double weighted_entropy = (left_decisions.size() * left_entropy + 
                              right_decisions.size() * right_entropy) / data.size();
    
    return original_entropy - weighted_entropy;
}

double DecisionTreeCacheModel::CalculateEntropy(const vector<CacheDecision> &decisions) {
    if (decisions.empty()) {
        return 0.0;
    }
    
    unordered_map<CacheDecision, int> counts;
    for (const auto &decision : decisions) {
        counts[decision]++;
    }
    
    double entropy = 0.0;
    for (const auto &count : counts) {
        double probability = static_cast<double>(count.second) / decisions.size();
        if (probability > 0.0) {
            entropy -= probability * log2(probability);
        }
    }
    
    return entropy;
}

//===----------------------------------------------------------------------===//
// ReinforcementLearningCacheModel Implementation
//===----------------------------------------------------------------------===//

ReinforcementLearningCacheModel::ReinforcementLearningCacheModel(double learning_rate, double discount_factor)
    : learning_rate(learning_rate), discount_factor(discount_factor) {
}

CacheDecision ReinforcementLearningCacheModel::Predict(const MLFeatureVector &features) {
    string state = FeaturesToState(features);
    return SelectAction(state);
}

void ReinforcementLearningCacheModel::Train(const vector<pair<MLFeatureVector, CacheDecision>> &training_data) {
    // 初始化Q表
    for (const auto &item : training_data) {
        string state = FeaturesToState(item.first);
        if (q_table.find(state) == q_table.end()) {
            q_table[state] = {
                {CacheDecision::CACHE_IN_MEMORY, 0.0},
                {CacheDecision::CACHE_TO_DISK, 0.0},
                {CacheDecision::CACHE_MATERIALIZED, 0.0},
                {CacheDecision::DO_NOT_CACHE, 0.0}
            };
        }
    }
}

void ReinforcementLearningCacheModel::Update(const MLFeatureVector &features, 
                                           CacheDecision actual_decision, double reward) {
    string state = FeaturesToState(features);
    
    // 确保状态存在于Q表中
    if (q_table.find(state) == q_table.end()) {
        q_table[state] = {
            {CacheDecision::CACHE_IN_MEMORY, 0.0},
            {CacheDecision::CACHE_TO_DISK, 0.0},
            {CacheDecision::CACHE_MATERIALIZED, 0.0},
            {CacheDecision::DO_NOT_CACHE, 0.0}
        };
    }
    
    // 更新Q值 (简化的Q-learning更新)
    double old_q = q_table[state][actual_decision];
    double max_future_q = 0.0;
    
    // 找到下一状态的最大Q值（这里简化为当前状态）
    for (const auto &action_q : q_table[state]) {
        max_future_q = std::max(max_future_q, action_q.second);
    }
    
    double new_q = old_q + learning_rate * (reward + discount_factor * max_future_q - old_q);
    q_table[state][actual_decision] = new_q;
}

double ReinforcementLearningCacheModel::GetConfidence(const MLFeatureVector &features) {
    string state = FeaturesToState(features);
    
    if (q_table.find(state) == q_table.end()) {
        return 0.0;
    }
    
    // 计算最大Q值与其他Q值的差距作为置信度
    double max_q = -std::numeric_limits<double>::infinity();
    double second_max_q = -std::numeric_limits<double>::infinity();
    
    for (const auto &action_q : q_table[state]) {
        if (action_q.second > max_q) {
            second_max_q = max_q;
            max_q = action_q.second;
        } else if (action_q.second > second_max_q) {
            second_max_q = action_q.second;
        }
    }
    
    return std::min(1.0, std::max(0.0, (max_q - second_max_q) / (std::abs(max_q) + 1.0)));
}

string ReinforcementLearningCacheModel::FeaturesToState(const MLFeatureVector &features) {
    // 将连续特征离散化为状态字符串
    auto feature_vector = features.ToVector();
    string state = "";
    
    for (size_t i = 0; i < feature_vector.size(); i++) {
        // 简单的离散化：分为5个区间
        int bucket = std::min(4, static_cast<int>(feature_vector[i] * 5));
        state += to_string(bucket);
        if (i < feature_vector.size() - 1) {
            state += "_";
        }
    }
    
    return state;
}

CacheDecision ReinforcementLearningCacheModel::SelectAction(const string &state) {
    if (q_table.find(state) == q_table.end()) {
        // 如果状态不存在，随机选择动作
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(0, 3);
        
        CacheDecision actions[] = {
            CacheDecision::CACHE_IN_MEMORY,
            CacheDecision::CACHE_TO_DISK,
            CacheDecision::CACHE_MATERIALIZED,
            CacheDecision::DO_NOT_CACHE
        };
        
        return actions[dis(gen)];
    }
    
    // ε-greedy策略
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_real_distribution<> dis(0.0, 1.0);
    
    if (dis(gen) < exploration_rate) {
        // 探索：随机选择动作
        std::uniform_int_distribution<> action_dis(0, 3);
        CacheDecision actions[] = {
            CacheDecision::CACHE_IN_MEMORY,
            CacheDecision::CACHE_TO_DISK,
            CacheDecision::CACHE_MATERIALIZED,
            CacheDecision::DO_NOT_CACHE
        };
        return actions[action_dis(gen)];
    } else {
        // 利用：选择Q值最大的动作
        CacheDecision best_action = CacheDecision::DO_NOT_CACHE;
        double best_q = -std::numeric_limits<double>::infinity();
        
        for (const auto &action_q : q_table[state]) {
            if (action_q.second > best_q) {
                best_q = action_q.second;
                best_action = action_q.first;
            }
        }
        
        return best_action;
    }
}

void ReinforcementLearningCacheModel::UpdateQValue(const string &state, CacheDecision action, 
                                                  double reward, const string &next_state) {
    if (q_table.find(state) == q_table.end()) {
        return;
    }
    
    double max_next_q = 0.0;
    if (q_table.find(next_state) != q_table.end()) {
        for (const auto &action_q : q_table[next_state]) {
            max_next_q = std::max(max_next_q, action_q.second);
        }
    }
    
    double old_q = q_table[state][action];
    double new_q = old_q + learning_rate * (reward + discount_factor * max_next_q - old_q);
    q_table[state][action] = new_q;
}

//===----------------------------------------------------------------------===//
// MLIntelligentPersistence Implementation
//===----------------------------------------------------------------------===//

MLIntelligentPersistence::MLIntelligentPersistence(ClientContext &context) : context(context) {
    memory_storage = make_uniq<MemoryOnlyPersistence>();
    disk_storage = make_uniq<WALFormatPersistence>();
    materialized_storage = make_uniq<MaterializedViewPersistence>(context);
    
    // 默认使用决策树模型
    ml_model = MLCacheStrategyFactory::CreateDecisionTreeModel();
}

bool MLIntelligentPersistence::Initialize(const CachePersistenceConfig &config) {
    this->config = config;
    
    bool memory_ok = memory_storage->Initialize(config);
    bool disk_ok = disk_storage->Initialize(config);
    bool materialized_ok = materialized_storage->Initialize(config);
    
    if (memory_ok && disk_ok && materialized_ok) {
        printf("MLIntelligentPersistence initialized successfully\n");
        return true;
    }
    
    return false;
}

bool MLIntelligentPersistence::PersistEntry(const string &key, const QueryCacheEntry &entry) {
    // 提取特征
    auto features = ExtractFeatures(key, entry);
    
    // 使用ML模型预测最佳缓存策略
    auto decision = ml_model->Predict(features);
    
    // 根据决策选择存储后端
    auto storage = SelectStorage(decision);
    if (!storage) {
        return false;
    }
    
    bool success = storage->PersistEntry(key, entry);
    
    // 更新访问统计
    UpdateAccessStats(key, success, 0.0);
    
    // 记录决策用于后续学习
    {
        lock_guard<mutex> lock(stats_mutex);
        ml_stats.total_predictions++;
        
        // 收集训练数据
        training_data.emplace_back(features, decision);
        if (training_data.size() > max_training_data_size) {
            training_data.erase(training_data.begin());
        }
        
        // 定期重训练模型
        if (ml_stats.total_predictions % 1000 == 0) {
            TrainModel();
        }
    }
    
    return success;
}

unique_ptr<QueryCacheEntry> MLIntelligentPersistence::LoadEntry(const string &key) {
    auto start_time = std::chrono::high_resolution_clock::now();
    
    // 尝试从不同存储后端加载
    unique_ptr<QueryCacheEntry> entry;
    bool found = false;
    CacheDecision found_location = CacheDecision::DO_NOT_CACHE;
    
    // 按优先级尝试加载
    entry = memory_storage->LoadEntry(key);
    if (entry) {
        found = true;
        found_location = CacheDecision::CACHE_IN_MEMORY;
        lock_guard<mutex> lock(stats_mutex);
        ml_stats.memory_hits++;
    }
    
    if (!entry) {
        entry = disk_storage->LoadEntry(key);
        if (entry) {
            found = true;
            found_location = CacheDecision::CACHE_TO_DISK;
            lock_guard<mutex> lock(stats_mutex);
            ml_stats.disk_hits++;
        }
    }
    
    if (!entry) {
        entry = materialized_storage->LoadEntry(key);
        if (entry) {
            found = true;
            found_location = CacheDecision::CACHE_MATERIALIZED;
            lock_guard<mutex> lock(stats_mutex);
            ml_stats.materialized_hits++;
        }
    }
    
    auto end_time = std::chrono::high_resolution_clock::now();
    double access_time = std::chrono::duration<double, std::milli>(end_time - start_time).count();
    
    // 更新访问统计和ML模型
    if (found && entry) {
        UpdateAccessStats(key, true, access_time);
        
        // 计算奖励并更新模型
        auto features = ExtractFeatures(key, *entry);
        double reward = CalculateReward(key, found_location, true, access_time);
        ml_model->Update(features, found_location, reward);
    } else {
        UpdateAccessStats(key, false, access_time);
    }
    
    return entry;
}

bool MLIntelligentPersistence::DeleteEntry(const string &key) {
    bool deleted = false;
    
    deleted |= memory_storage->DeleteEntry(key);
    deleted |= disk_storage->DeleteEntry(key);
    deleted |= materialized_storage->DeleteEntry(key);
    
    // 清理访问统计
    access_stats.erase(key);
    
    return deleted;
}

bool MLIntelligentPersistence::EntryExists(const string &key) {
    return memory_storage->EntryExists(key) || 
           disk_storage->EntryExists(key) || 
           materialized_storage->EntryExists(key);
}

vector<string> MLIntelligentPersistence::GetAllKeys() {
    auto memory_keys = memory_storage->GetAllKeys();
    auto disk_keys = disk_storage->GetAllKeys();
    auto materialized_keys = materialized_storage->GetAllKeys();
    
    unordered_set<string> all_keys_set;
    for (const auto &key : memory_keys) all_keys_set.insert(key);
    for (const auto &key : disk_keys) all_keys_set.insert(key);
    for (const auto &key : materialized_keys) all_keys_set.insert(key);
    
    return vector<string>(all_keys_set.begin(), all_keys_set.end());
}

bool MLIntelligentPersistence::Clear() {
    bool cleared = true;
    cleared &= memory_storage->Clear();
    cleared &= disk_storage->Clear();
    cleared &= materialized_storage->Clear();
    
    access_stats.clear();
    training_data.clear();
    
    lock_guard<mutex> lock(stats_mutex);
    ml_stats = MLStats{};
    
    return cleared;
}

bool MLIntelligentPersistence::Sync() {
    bool synced = true;
    synced &= memory_storage->Sync();
    synced &= disk_storage->Sync();
    synced &= materialized_storage->Sync();
    return synced;
}

idx_t MLIntelligentPersistence::GetStorageSize() const {
    return memory_storage->GetStorageSize() + 
           disk_storage->GetStorageSize() + 
           materialized_storage->GetStorageSize();
}

void MLIntelligentPersistence::Close() {
    memory_storage->Close();
    disk_storage->Close();
    materialized_storage->Close();
}

void MLIntelligentPersistence::SetMLModel(unique_ptr<MLCacheModel> model) {
    ml_model = std::move(model);
}

MLIntelligentPersistence::MLStats MLIntelligentPersistence::GetMLStats() const {
    lock_guard<mutex> lock(stats_mutex);
    auto stats = ml_stats;
    
    if (stats.total_predictions > 0) {
        stats.accuracy = static_cast<double>(stats.correct_predictions) / stats.total_predictions;
    }
    
    return stats;
}

MLFeatureVector MLIntelligentPersistence::ExtractFeatures(const string &key, const QueryCacheEntry &entry) {
    MLFeatureVector features;
    
    // 基本特征
    features.query_complexity = entry.ml_features.query_complexity_score;
    features.execution_time = entry.ml_features.execution_time_ms;
    features.result_size = entry.ml_features.result_size_bytes;
    
    // 访问模式特征
    auto it = access_stats.find(key);
    if (it != access_stats.end()) {
        features.access_frequency = static_cast<double>(it->second.access_count);
        
        auto now = std::chrono::steady_clock::now();
        auto time_since_last = std::chrono::duration_cast<std::chrono::seconds>(
            now - it->second.last_access).count();
        features.temporal_locality = 1.0 / (1.0 + time_since_last / 3600.0);
        
        features.spatial_locality = 0.5; // 简化实现
        features.cost_benefit_ratio = features.access_frequency / (features.result_size / 1024.0 + 1.0);
    }
    
    // 缓存命中概率预测（基于历史数据）
    features.cache_hit_probability = std::min(1.0, features.access_frequency / 10.0);
    
    return features;
}

double MLIntelligentPersistence::CalculateReward(const string &key, CacheDecision decision, 
                                                bool was_hit, double access_time) {
    double reward = 0.0;
    
    if (was_hit) {
        // 命中奖励，访问时间越短奖励越高
        reward += 1.0 - std::min(1.0, access_time / 100.0);
        
        // 根据存储类型调整奖励
        switch (decision) {
            case CacheDecision::CACHE_IN_MEMORY:
                reward += 0.5; // 内存访问最快
                break;
            case CacheDecision::CACHE_TO_DISK:
                reward += 0.2; // 磁盘访问中等
                break;
            case CacheDecision::CACHE_MATERIALIZED:
                reward += 0.3; // 物化视图访问较快
                break;
            default:
                break;
        }
    } else {
        // 未命中惩罚
        reward -= 0.5;
    }
    
    return reward;
}

CachePersistenceInterface* MLIntelligentPersistence::SelectStorage(CacheDecision decision) {
    switch (decision) {
        case CacheDecision::CACHE_IN_MEMORY:
            return memory_storage.get();
        case CacheDecision::CACHE_TO_DISK:
            return disk_storage.get();
        case CacheDecision::CACHE_MATERIALIZED:
            return materialized_storage.get();
        default:
            return nullptr;
    }
}

void MLIntelligentPersistence::UpdateAccessStats(const string &key, bool was_hit, double access_time) {
    auto &stats = access_stats[key];
    stats.access_count++;
    stats.last_access = std::chrono::steady_clock::now();
    
    if (stats.access_count == 1) {
        stats.first_access = stats.last_access;
        stats.avg_access_time = access_time;
    } else {
        stats.avg_access_time = (stats.avg_access_time * (stats.access_count - 1) + access_time) / stats.access_count;
    }
}

void MLIntelligentPersistence::TrainModel() {
    if (training_data.size() < 10) {
        return;
    }
    
    printf("Training ML model with %zu samples\n", training_data.size());
    ml_model->Train(training_data);
}

//===----------------------------------------------------------------------===//
// MLCacheStrategyFactory Implementation
//===----------------------------------------------------------------------===//

unique_ptr<MLCacheModel> MLCacheStrategyFactory::CreateDecisionTreeModel() {
    return make_uniq<DecisionTreeCacheModel>();
}

unique_ptr<MLCacheModel> MLCacheStrategyFactory::CreateReinforcementLearningModel(
    double learning_rate, double discount_factor) {
    return make_uniq<ReinforcementLearningCacheModel>(learning_rate, discount_factor);
}

unique_ptr<MLCacheModel> MLCacheStrategyFactory::CreateEnsembleModel(vector<unique_ptr<MLCacheModel>> models) {
    // 简化实现：返回第一个模型
    // 实际实现中应该创建一个集成模型类
    if (!models.empty()) {
        return std::move(models[0]);
    }
    return CreateDecisionTreeModel();
}

} // namespace duckdb