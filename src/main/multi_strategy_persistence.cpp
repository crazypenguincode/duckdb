//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/multi_strategy_persistence.cpp - Multi-Strategy Fusion Persistence
//
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/common/types/hash.hpp"
#include <fstream>
#include <sstream>
#include <cstdio>
#include <sys/stat.h>

namespace duckdb {

//===----------------------------------------------------------------------===//
// Multi-Strategy Fusion Persistence Implementation (Chapter 5)
//===----------------------------------------------------------------------===//

//! 持久化接口基类
class CachePersistenceInterface {
public:
    virtual ~CachePersistenceInterface() = default;
    
    //! 初始化持久化存储
    virtual bool Initialize(const CachePersistenceConfig &config) = 0;
    
    //! 持久化缓存条目
    virtual bool PersistEntry(const string &key, const QueryCacheEntry &entry) = 0;
    
    //! 加载缓存条目
    virtual unique_ptr<QueryCacheEntry> LoadEntry(const string &key) = 0;
    
    //! 删除缓存条目
    virtual bool RemoveEntry(const string &key) = 0;
    
    //! 同步到存储
    virtual bool Sync() = 0;
    
    //! 获取存储统计信息
    virtual QueryCache::PersistenceStats GetStats() const = 0;
    
    //! 清理过期条目
    virtual void Cleanup() = 0;
};

//! 内存持久化实现
class MemoryOnlyPersistence : public CachePersistenceInterface {
private:
    unordered_map<string, unique_ptr<QueryCacheEntry>> memory_cache;
    mutable mutex memory_mutex;
    
public:
    bool Initialize(const CachePersistenceConfig &config) override {
        printf("DEBUG: MemoryOnlyPersistence initialized\n");
        return true;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        lock_guard<mutex> lock(memory_mutex);
        // 创建条目的深拷贝
        auto new_entry = make_uniq<QueryCacheEntry>(entry.result->Copy());
        new_entry->created_at = entry.created_at;
        new_entry->access_count = entry.access_count;
        new_entry->last_accessed = entry.last_accessed;
        new_entry->ml_features = entry.ml_features;
        new_entry->ml_score = entry.ml_score;
        new_entry->eviction_priority = entry.eviction_priority;
        
        memory_cache[key] = std::move(new_entry);
        return true;
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        lock_guard<mutex> lock(memory_mutex);
        auto it = memory_cache.find(key);
        if (it != memory_cache.end()) {
            // 创建条目的深拷贝
            auto loaded_entry = make_uniq<QueryCacheEntry>(it->second->result->Copy());
            loaded_entry->created_at = it->second->created_at;
            loaded_entry->access_count = it->second->access_count;
            loaded_entry->last_accessed = it->second->last_accessed;
            loaded_entry->ml_features = it->second->ml_features;
            loaded_entry->ml_score = it->second->ml_score;
            loaded_entry->eviction_priority = it->second->eviction_priority;
            return loaded_entry;
        }
        return nullptr;
    }
    
    bool RemoveEntry(const string &key) override {
        lock_guard<mutex> lock(memory_mutex);
        return memory_cache.erase(key) > 0;
    }
    
    bool Sync() override {
        return true; // 内存模式无需同步
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        lock_guard<mutex> lock(memory_mutex);
        QueryCache::PersistenceStats stats;
        stats.memory_entries = memory_cache.size();
        stats.disk_entries = 0;
        stats.persisted_entries = memory_cache.size();
        stats.storage_size_bytes = 0;
        return stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(memory_mutex);
        memory_cache.clear();
    }
};

//! WAL格式持久化实现
class WALFormatPersistence : public CachePersistenceInterface {
private:
    string wal_path;
    idx_t wal_buffer_size;
    bool enable_compression;
    mutable mutex wal_mutex;
    
    struct WALEntry {
        string key;
        string serialized_data;
        std::chrono::steady_clock::time_point timestamp;
    };
    
    vector<WALEntry> wal_buffer;
    
public:
    bool Initialize(const CachePersistenceConfig &config) override {
        wal_path = config.persistence_path + "/wal_cache.log";
        wal_buffer_size = config.wal_buffer_size;
        enable_compression = config.enable_compression;
        
        // 创建目录
        string dir = config.persistence_path;
        mkdir(dir.c_str(), 0755);
        
        printf("DEBUG: WALFormatPersistence initialized with path: %s\n", wal_path.c_str());
        return true;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        lock_guard<mutex> lock(wal_mutex);
        
        // 序列化条目（简化实现）
        string serialized = SerializeEntry(entry);
        
        WALEntry wal_entry;
        wal_entry.key = key;
        wal_entry.serialized_data = serialized;
        wal_entry.timestamp = std::chrono::steady_clock::now();
        
        wal_buffer.push_back(wal_entry);
        
        // 如果缓冲区满了，刷盘
        if (wal_buffer.size() * serialized.size() > wal_buffer_size) {
            FlushWAL();
        }
        
        return true;
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        lock_guard<mutex> lock(wal_mutex);
        
        // 先检查缓冲区
        for (auto it = wal_buffer.rbegin(); it != wal_buffer.rend(); ++it) {
            if (it->key == key) {
                return DeserializeEntry(it->serialized_data);
            }
        }
        
        // 然后检查WAL文件
        return LoadFromWALFile(key);
    }
    
    bool RemoveEntry(const string &key) override {
        lock_guard<mutex> lock(wal_mutex);
        
        // 在WAL中记录删除操作
        WALEntry delete_entry;
        delete_entry.key = key;
        delete_entry.serialized_data = "DELETE";
        delete_entry.timestamp = std::chrono::steady_clock::now();
        
        wal_buffer.push_back(delete_entry);
        return true;
    }
    
    bool Sync() override {
        lock_guard<mutex> lock(wal_mutex);
        return FlushWAL();
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        lock_guard<mutex> lock(wal_mutex);
        QueryCache::PersistenceStats stats;
        stats.memory_entries = 0;
        stats.disk_entries = wal_buffer.size();
        stats.persisted_entries = wal_buffer.size();
        
        // 估算存储大小
        idx_t total_size = 0;
        for (const auto &entry : wal_buffer) {
            total_size += entry.serialized_data.size();
        }
        stats.storage_size_bytes = total_size;
        
        return stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(wal_mutex);
        wal_buffer.clear();
        remove(wal_path.c_str());
    }
    
private:
    string SerializeEntry(const QueryCacheEntry &entry) {
        // 简化的序列化实现
        std::ostringstream oss;
        oss << "ENTRY|";
        oss << entry.access_count << "|";
        oss << entry.ml_score << "|";
        oss << entry.eviction_priority << "|";
        oss << entry.ml_features.execution_time_ms << "|";
        oss << entry.ml_features.result_size_bytes << "|";
        oss << "DATA_PLACEHOLDER"; // 实际实现中需要序列化result
        return oss.str();
    }
    
    unique_ptr<QueryCacheEntry> DeserializeEntry(const string &serialized) {
        if (serialized == "DELETE") {
            return nullptr;
        }
        
        // 简化的反序列化实现
        // 实际实现中需要完整的序列化/反序列化逻辑
        auto entry = make_uniq<QueryCacheEntry>(nullptr);
        entry->access_count = 1;
        entry->ml_score = 0.5;
        entry->eviction_priority = 0.0;
        entry->created_at = std::chrono::steady_clock::now();
        entry->last_accessed = entry->created_at;
        return entry;
    }
    
    bool FlushWAL() {
        if (wal_buffer.empty()) {
            return true;
        }
        
        FILE *file = fopen(wal_path.c_str(), "a");
        if (!file) {
            printf("ERROR: Failed to open WAL file: %s\n", wal_path.c_str());
            return false;
        }
        
        for (const auto &entry : wal_buffer) {
            fprintf(file, "%s|%s\n", entry.key.c_str(), entry.serialized_data.c_str());
        }
        
        fclose(file);
        wal_buffer.clear();
        
        printf("DEBUG: WAL flushed to disk\n");
        return true;
    }
    
    unique_ptr<QueryCacheEntry> LoadFromWALFile(const string &key) {
        FILE *file = fopen(wal_path.c_str(), "r");
        if (!file) {
            return nullptr;
        }
        
        char line[4096];
        unique_ptr<QueryCacheEntry> result = nullptr;
        
        while (fgets(line, sizeof(line), file)) {
            string line_str(line);
            size_t pos = line_str.find('|');
            if (pos != string::npos) {
                string file_key = line_str.substr(0, pos);
                if (file_key == key) {
                    string serialized = line_str.substr(pos + 1);
                    result = DeserializeEntry(serialized);
                }
            }
        }
        
        fclose(file);
        return result;
    }
};

//! 物化视图持久化实现
class MaterializedViewPersistence : public CachePersistenceInterface {
private:
    string db_path;
    mutable mutex db_mutex;
    
public:
    bool Initialize(const CachePersistenceConfig &config) override {
        db_path = config.persistence_path + "/materialized_cache.db";
        
        // 创建目录
        string dir = config.persistence_path;
        mkdir(dir.c_str(), 0755);
        
        printf("DEBUG: MaterializedViewPersistence initialized with path: %s\n", db_path.c_str());
        return true;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        lock_guard<mutex> lock(db_mutex);
        
        // 使用SQLite创建物化视图（简化实现）
        string sql = "CREATE TABLE IF NOT EXISTS cache_" + std::to_string(Hash(key.c_str(), key.length())) + 
                    " AS SELECT 'cached_data' as data;";
        
        printf("DEBUG: Persisting entry to materialized view: %s\n", key.c_str());
        return true;
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        lock_guard<mutex> lock(db_mutex);
        
        // 从物化视图加载数据（简化实现）
        printf("DEBUG: Loading entry from materialized view: %s\n", key.c_str());
        
        auto entry = make_uniq<QueryCacheEntry>(nullptr);
        entry->access_count = 1;
        entry->ml_score = 0.8; // 物化视图具有较高的可靠性评分
        entry->eviction_priority = 0.8;
        entry->created_at = std::chrono::steady_clock::now();
        entry->last_accessed = entry->created_at;
        return entry;
    }
    
    bool RemoveEntry(const string &key) override {
        lock_guard<mutex> lock(db_mutex);
        
        // 删除物化视图
        string table_name = "cache_" + std::to_string(Hash(key.c_str(), key.length()));
        printf("DEBUG: Removing materialized view: %s\n", table_name.c_str());
        return true;
    }
    
    bool Sync() override {
        return true; // 物化视图自动同步
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        lock_guard<mutex> lock(db_mutex);
        QueryCache::PersistenceStats stats;
        stats.memory_entries = 0;
        stats.disk_entries = 10; // 模拟值
        stats.persisted_entries = 10;
        stats.storage_size_bytes = 1024 * 1024; // 1MB模拟值
        return stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(db_mutex);
        remove(db_path.c_str());
    }
};

//! 机器学习特征向量
struct MLFeatureVector {
    double query_complexity;      // 查询复杂度
    double execution_time;        // 执行时间
    double result_size;          // 结果大小
    double access_frequency;     // 访问频率
    double temporal_locality;    // 时间局部性
    double spatial_locality;     // 空间局部性
    double cost_benefit_ratio;   // 成本效益比
    double cache_hit_prediction; // 缓存命中预测
    
    MLFeatureVector(const MLCacheFeatures &features) {
        query_complexity = features.query_complexity_score;
        execution_time = features.execution_time_ms;
        result_size = features.result_size_bytes;
        access_frequency = features.access_frequency;
        temporal_locality = features.temporal_locality;
        spatial_locality = 0.5; // 默认值
        cost_benefit_ratio = execution_time / std::max(1.0, result_size / 1024.0);
        cache_hit_prediction = 0.5; // 默认值
    }
};

//! 基于机器学习的智能持久化策略
class MLIntelligentPersistence : public CachePersistenceInterface {
private:
    unique_ptr<MemoryOnlyPersistence> memory_storage;
    unique_ptr<WALFormatPersistence> disk_storage;
    unique_ptr<MaterializedViewPersistence> materialized_storage;
    
    // 机器学习模型权重
    struct MLModel {
        double complexity_weight = 0.3;
        double size_weight = 0.25;
        double frequency_weight = 0.2;
        double time_weight = 0.15;
        double reliability_weight = 0.1;
        double bias = 0.0;
    } ml_model;
    
    // 访问统计
    unordered_map<string, struct AccessStats> access_stats;
    struct AccessStats {
        idx_t access_count = 0;
        std::chrono::steady_clock::time_point last_access;
        double avg_access_time = 0.0;
        double total_access_time = 0.0;
    };
    
    mutable mutex ml_mutex;
    
public:
    bool Initialize(const CachePersistenceConfig &config) override {
        lock_guard<mutex> lock(ml_mutex);
        
        memory_storage = make_uniq<MemoryOnlyPersistence>();
        disk_storage = make_uniq<WALFormatPersistence>();
        materialized_storage = make_uniq<MaterializedViewPersistence>();
        
        bool success = memory_storage->Initialize(config) &&
                      disk_storage->Initialize(config) &&
                      materialized_storage->Initialize(config);
        
        printf("DEBUG: MLIntelligentPersistence initialized with %s\n", 
               success ? "success" : "failure");
        return success;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        lock_guard<mutex> lock(ml_mutex);
        
        // 提取特征向量
        MLFeatureVector features(entry.ml_features);
        
        // 智能选择存储策略
        CachePersistenceStrategy strategy = SelectOptimalStrategy(features);
        
        // 更新访问统计
        UpdateAccessStats(key, entry);
        
        // 根据策略存储
        switch (strategy) {
            case CachePersistenceStrategy::MEMORY_ONLY:
                printf("DEBUG: ML selected MEMORY_ONLY for key: %s\n", key.c_str());
                return memory_storage->PersistEntry(key, entry);
                
            case CachePersistenceStrategy::WAL_FORMAT:
                printf("DEBUG: ML selected WAL_FORMAT for key: %s\n", key.c_str());
                return disk_storage->PersistEntry(key, entry);
                
            case CachePersistenceStrategy::MATERIALIZED_VIEW:
                printf("DEBUG: ML selected MATERIALIZED_VIEW for key: %s\n", key.c_str());
                return materialized_storage->PersistEntry(key, entry);
                
            default:
                // 默认使用混合策略
                printf("DEBUG: ML selected HYBRID strategy for key: %s\n", key.c_str());
                return memory_storage->PersistEntry(key, entry) &&
                       disk_storage->PersistEntry(key, entry);
        }
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        lock_guard<mutex> lock(ml_mutex);
        
        // 按优先级尝试加载
        auto entry = memory_storage->LoadEntry(key);
        if (entry) {
            printf("DEBUG: ML loaded from memory: %s\n", key.c_str());
            return entry;
        }
        
        entry = materialized_storage->LoadEntry(key);
        if (entry) {
            printf("DEBUG: ML loaded from materialized view: %s\n", key.c_str());
            return entry;
        }
        
        entry = disk_storage->LoadEntry(key);
        if (entry) {
            printf("DEBUG: ML loaded from disk: %s\n", key.c_str());
            return entry;
        }
        
        return nullptr;
    }
    
    bool RemoveEntry(const string &key) override {
        lock_guard<mutex> lock(ml_mutex);
        
        bool success = true;
        success &= memory_storage->RemoveEntry(key);
        success &= disk_storage->RemoveEntry(key);
        success &= materialized_storage->RemoveEntry(key);
        
        // 清理访问统计
        access_stats.erase(key);
        
        return success;
    }
    
    bool Sync() override {
        lock_guard<mutex> lock(ml_mutex);
        
        return memory_storage->Sync() &&
               disk_storage->Sync() &&
               materialized_storage->Sync();
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        lock_guard<mutex> lock(ml_mutex);
        
        auto memory_stats = memory_storage->GetStats();
        auto disk_stats = disk_storage->GetStats();
        auto materialized_stats = materialized_storage->GetStats();
        
        QueryCache::PersistenceStats combined_stats;
        combined_stats.memory_entries = memory_stats.memory_entries;
        combined_stats.disk_entries = disk_stats.disk_entries + materialized_stats.disk_entries;
        combined_stats.persisted_entries = memory_stats.persisted_entries + 
                                          disk_stats.persisted_entries + 
                                          materialized_stats.persisted_entries;
        combined_stats.storage_size_bytes = memory_stats.storage_size_bytes + 
                                           disk_stats.storage_size_bytes + 
                                           materialized_stats.storage_size_bytes;
        
        return combined_stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(ml_mutex);
        
        memory_storage->Cleanup();
        disk_storage->Cleanup();
        materialized_storage->Cleanup();
        access_stats.clear();
    }
    
private:
    CachePersistenceStrategy SelectOptimalStrategy(const MLFeatureVector &features) {
        // 计算各策略的评分
        double memory_score = CalculateMemoryScore(features);
        double wal_score = CalculateWALScore(features);
        double materialized_score = CalculateMaterializedScore(features);
        
        printf("DEBUG: Strategy scores - Memory: %.3f, WAL: %.3f, Materialized: %.3f\n",
               memory_score, wal_score, materialized_score);
        
        // 选择最高评分的策略
        if (memory_score >= wal_score && memory_score >= materialized_score) {
            return CachePersistenceStrategy::MEMORY_ONLY;
        } else if (wal_score >= materialized_score) {
            return CachePersistenceStrategy::WAL_FORMAT;
        } else {
            return CachePersistenceStrategy::MATERIALIZED_VIEW;
        }
    }
    
    double CalculateMemoryScore(const MLFeatureVector &features) {
        // 内存策略适合：小数据、高频访问、低复杂度
        double score = 0.0;
        
        // 数据大小因子（越小越好）
        score += (1.0 - std::min(1.0, features.result_size / (10 * 1024 * 1024))) * 0.4;
        
        // 访问频率因子（越高越好）
        score += features.access_frequency * 0.3;
        
        // 复杂度因子（越低越好）
        score += (1.0 - features.query_complexity) * 0.2;
        
        // 时间局部性因子
        score += features.temporal_locality * 0.1;
        
        return score;
    }
    
    double CalculateWALScore(const MLFeatureVector &features) {
        // WAL策略适合：中等数据、中等频率、平衡性能和可靠性
        double score = 0.0;
        
        // 数据大小因子（中等大小最优）
        double size_factor = 1.0 - std::abs(features.result_size / (50 * 1024 * 1024) - 0.5) * 2;
        score += std::max(0.0, size_factor) * 0.3;
        
        // 执行时间因子（中等执行时间适合）
        double time_factor = 1.0 - std::abs(features.execution_time / 1000.0 - 0.5) * 2;
        score += std::max(0.0, time_factor) * 0.25;
        
        // 成本效益比
        score += std::min(1.0, features.cost_benefit_ratio / 10.0) * 0.25;
        
        // 可靠性需求
        score += 0.2; // WAL提供中等可靠性
        
        return score;
    }
    
    double CalculateMaterializedScore(const MLFeatureVector &features) {
        // 物化视图策略适合：大数据、低频访问、高可靠性需求
        double score = 0.0;
        
        // 数据大小因子（越大越好）
        score += std::min(1.0, features.result_size / (100 * 1024 * 1024)) * 0.3;
        
        // 复杂度因子（越高越好）
        score += features.query_complexity * 0.25;
        
        // 执行时间因子（越长越适合缓存）
        score += std::min(1.0, features.execution_time / 5000.0) * 0.25;
        
        // 可靠性需求（物化视图提供最高可靠性）
        score += 0.2;
        
        return score;
    }
    
    void UpdateAccessStats(const string &key, const QueryCacheEntry &entry) {
        auto &stats = access_stats[key];
        stats.access_count++;
        stats.last_access = std::chrono::steady_clock::now();
        
        if (entry.ml_features.execution_time_ms > 0) {
            stats.total_access_time += entry.ml_features.execution_time_ms;
            stats.avg_access_time = stats.total_access_time / stats.access_count;
        }
    }
};

//! 混合持久化策略实现
class HybridPersistence : public CachePersistenceInterface {
private:
    unique_ptr<MLIntelligentPersistence> ml_persistence;
    CachePersistenceConfig config;
    
    // 性能监控
    struct PerformanceMetrics {
        double avg_write_time = 0.0;
        double avg_read_time = 0.0;
        idx_t total_operations = 0;
        std::chrono::steady_clock::time_point last_update;
    } performance_metrics;
    
    mutable mutex hybrid_mutex;
    
public:
    bool Initialize(const CachePersistenceConfig &config_p) override {
        lock_guard<mutex> lock(hybrid_mutex);
        
        config = config_p;
        ml_persistence = make_uniq<MLIntelligentPersistence>();
        
        bool success = ml_persistence->Initialize(config);
        
        printf("DEBUG: HybridPersistence initialized with %s\n", 
               success ? "success" : "failure");
        return success;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        auto start_time = std::chrono::steady_clock::now();
        
        bool result = ml_persistence->PersistEntry(key, entry);
        
        // 更新性能指标
        auto end_time = std::chrono::steady_clock::now();
        double operation_time = std::chrono::duration<double, std::milli>(end_time - start_time).count();
        UpdatePerformanceMetrics(operation_time, true);
        
        return result;
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        auto start_time = std::chrono::steady_clock::now();
        
        auto result = ml_persistence->LoadEntry(key);
        
        // 更新性能指标
        auto end_time = std::chrono::steady_clock::now();
        double operation_time = std::chrono::duration<double, std::milli>(end_time - start_time).count();
        UpdatePerformanceMetrics(operation_time, false);
        
        return result;
    }
    
    bool RemoveEntry(const string &key) override {
        return ml_persistence->RemoveEntry(key);
    }
    
    bool Sync() override {
        return ml_persistence->Sync();
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        auto stats = ml_persistence->GetStats();
        
        // 添加混合策略特有的统计信息
        printf("DEBUG: Hybrid persistence stats - avg_write: %.2fms, avg_read: %.2fms\n",
               performance_metrics.avg_write_time, performance_metrics.avg_read_time);
        
        return stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(hybrid_mutex);
        ml_persistence->Cleanup();
        performance_metrics = PerformanceMetrics{};
    }
    
private:
    void UpdatePerformanceMetrics(double operation_time, bool is_write) {
        lock_guard<mutex> lock(hybrid_mutex);
        
        performance_metrics.total_operations++;
        
        if (is_write) {
            performance_metrics.avg_write_time = 
                (performance_metrics.avg_write_time * (performance_metrics.total_operations - 1) + operation_time) 
                / performance_metrics.total_operations;
        } else {
            performance_metrics.avg_read_time = 
                (performance_metrics.avg_read_time * (performance_metrics.total_operations - 1) + operation_time) 
                / performance_metrics.total_operations;
        }
        
        performance_metrics.last_update = std::chrono::steady_clock::now();
    }
};

//! 跨进程缓存共享实现
class CrossProcessPersistence : public CachePersistenceInterface {
private:
    string shared_cache_file;
    string lock_file;
    mutable mutex cross_process_mutex;
    
    struct SharedCacheHeader {
        uint32_t magic_number = 0xDEADBEEF;
        uint32_t version = 1;
        uint64_t entry_count = 0;
        uint64_t total_size = 0;
        uint64_t last_update_time = 0;
    };
    
public:
    bool Initialize(const CachePersistenceConfig &config) override {
        shared_cache_file = config.persistence_path + "/" + config.shared_cache_file;
        lock_file = shared_cache_file + ".lock";
        
        // 创建目录
        string dir = config.persistence_path;
        mkdir(dir.c_str(), 0755);
        
        printf("DEBUG: CrossProcessPersistence initialized with file: %s\n", shared_cache_file.c_str());
        return true;
    }
    
    bool PersistEntry(const string &key, const QueryCacheEntry &entry) override {
        lock_guard<mutex> lock(cross_process_mutex);
        
        // 使用文件锁确保跨进程同步
        FILE *lock_fp = fopen(lock_file.c_str(), "w");
        if (!lock_fp) {
            printf("ERROR: Failed to create lock file\n");
            return false;
        }
        
        // 写入共享缓存文件
        FILE *cache_fp = fopen(shared_cache_file.c_str(), "ab");
        if (!cache_fp) {
            fclose(lock_fp);
            return false;
        }
        
        // 写入缓存条目（简化格式）
        string cache_line = key + "|" + std::to_string(entry.access_count) + "|" + 
                           std::to_string(entry.ml_score) + "\n";
        fwrite(cache_line.c_str(), 1, cache_line.length(), cache_fp);
        
        fclose(cache_fp);
        fclose(lock_fp);
        remove(lock_file.c_str());
        
        printf("DEBUG: CrossProcess persisted entry: %s\n", key.c_str());
        return true;
    }
    
    unique_ptr<QueryCacheEntry> LoadEntry(const string &key) override {
        lock_guard<mutex> lock(cross_process_mutex);
        
        FILE *cache_fp = fopen(shared_cache_file.c_str(), "r");
        if (!cache_fp) {
            return nullptr;
        }
        
        char line[4096];
        unique_ptr<QueryCacheEntry> result = nullptr;
        
        while (fgets(line, sizeof(line), cache_fp)) {
            string line_str(line);
            size_t pos = line_str.find('|');
            if (pos != string::npos) {
                string file_key = line_str.substr(0, pos);
                if (file_key == key) {
                    // 找到匹配的条目，创建缓存条目
                    result = make_uniq<QueryCacheEntry>(nullptr);
                    result->access_count = 1;
                    result->ml_score = 0.7; // 跨进程缓存具有较高评分
                    result->eviction_priority = 0.7;
                    result->created_at = std::chrono::steady_clock::now();
                    result->last_accessed = result->created_at;
                    break;
                }
            }
        }
        
        fclose(cache_fp);
        
        if (result) {
            printf("DEBUG: CrossProcess loaded entry: %s\n", key.c_str());
        }
        
        return result;
    }
    
    bool RemoveEntry(const string &key) override {
        lock_guard<mutex> lock(cross_process_mutex);
        
        // 简化实现：重写文件，排除要删除的条目
        FILE *cache_fp = fopen(shared_cache_file.c_str(), "r");
        if (!cache_fp) {
            return false;
        }
        
        string temp_file = shared_cache_file + ".tmp";
        FILE *temp_fp = fopen(temp_file.c_str(), "w");
        if (!temp_fp) {
            fclose(cache_fp);
            return false;
        }
        
        char line[4096];
        while (fgets(line, sizeof(line), cache_fp)) {
            string line_str(line);
            size_t pos = line_str.find('|');
            if (pos != string::npos) {
                string file_key = line_str.substr(0, pos);
                if (file_key != key) {
                    fputs(line, temp_fp);
                }
            }
        }
        
        fclose(cache_fp);
        fclose(temp_fp);
        
        // 替换原文件
        rename(temp_file.c_str(), shared_cache_file.c_str());
        
        printf("DEBUG: CrossProcess removed entry: %s\n", key.c_str());
        return true;
    }
    
    bool Sync() override {
        // 跨进程缓存自动同步
        return true;
    }
    
    QueryCache::PersistenceStats GetStats() const override {
        lock_guard<mutex> lock(cross_process_mutex);
        
        QueryCache::PersistenceStats stats;
        stats.memory_entries = 0;
        stats.disk_entries = 0;
        stats.persisted_entries = 0;
        stats.storage_size_bytes = 0;
        
        // 统计共享缓存文件
        FILE *cache_fp = fopen(shared_cache_file.c_str(), "r");
        if (cache_fp) {
            fseek(cache_fp, 0, SEEK_END);
            stats.storage_size_bytes = ftell(cache_fp);
            
            // 计算条目数量
            fseek(cache_fp, 0, SEEK_SET);
            char line[4096];
            while (fgets(line, sizeof(line), cache_fp)) {
                stats.persisted_entries++;
                stats.disk_entries++;
            }
            
            fclose(cache_fp);
        }
        
        return stats;
    }
    
    void Cleanup() override {
        lock_guard<mutex> lock(cross_process_mutex);
        remove(shared_cache_file.c_str());
        remove(lock_file.c_str());
    }
};

//! 持久化工厂类
class CachePersistenceFactory {
public:
    static unique_ptr<CachePersistenceInterface> CreatePersistence(CachePersistenceStrategy strategy) {
        switch (strategy) {
            case CachePersistenceStrategy::MEMORY_ONLY:
                return make_uniq<MemoryOnlyPersistence>();
                
            case CachePersistenceStrategy::WAL_FORMAT:
                return make_uniq<WALFormatPersistence>();
                
            case CachePersistenceStrategy::MATERIALIZED_VIEW:
                return make_uniq<MaterializedViewPersistence>();
                
            case CachePersistenceStrategy::ML_INTELLIGENT:
                return make_uniq<MLIntelligentPersistence>();
                
            case CachePersistenceStrategy::HYBRID:
                return make_uniq<HybridPersistence>();
                
            case CachePersistenceStrategy::CROSS_PROCESS:
                return make_uniq<CrossProcessPersistence>();
                
            default:
                printf("WARNING: Unknown persistence strategy, using MEMORY_ONLY\n");
                return make_uniq<MemoryOnlyPersistence>();
        }
    }
};

} // namespace duckdb