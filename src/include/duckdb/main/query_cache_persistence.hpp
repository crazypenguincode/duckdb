//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache_persistence.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/common.hpp"
#include "duckdb/common/mutex.hpp"
#include "duckdb/common/file_system.hpp"
#include "duckdb/main/materialized_query_result.hpp"
#include "duckdb/main/query_cache.hpp"
#include "duckdb/storage/buffer_manager.hpp"
#include "duckdb/storage/data_table.hpp"
#include <fstream>
#include <memory>

namespace duckdb {

////! 持久化策略类型
//enum class CachePersistenceStrategy {
//    MEMORY_ONLY,        // 策略3: 仅内存，不落盘
//    MATERIALIZED_VIEW,  // 策略1: 使用物化视图落盘
//    WAL_FORMAT,         // 策略2: 使用WAL格式顺序读写
//    HYBRID              // 策略4: 混合策略（热数据内存，冷数据落盘）
//};
//
////! 持久化配置
//struct CachePersistenceConfig {
//    CachePersistenceStrategy strategy = CachePersistenceStrategy::MEMORY_ONLY;
//    string persistence_path = "cache_storage";
//    idx_t memory_threshold_bytes = 50 * 1024 * 1024; // 50MB
//    idx_t wal_buffer_size = 4 * 1024 * 1024; // 4MB WAL缓冲区
//    bool enable_compression = true;
//    bool enable_async_write = true;
//    idx_t sync_interval_ms = 5000; // 5秒同步间隔
//};

//! WAL格式的记录类型
enum class WALRecordType : uint8_t {
    CACHE_INSERT = 1,
    CACHE_UPDATE = 2,
    CACHE_DELETE = 3,
    CHECKPOINT = 4
};

//! WAL记录头部
struct WALRecordHeader {
    WALRecordType type;
    uint32_t record_size;
    uint64_t timestamp;
    uint32_t checksum;
};

//! 缓存持久化接口基类
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
    virtual bool DeleteEntry(const string &key) = 0;
    
    //! 检查条目是否存在
    virtual bool EntryExists(const string &key) = 0;
    
    //! 获取所有缓存键
    virtual vector<string> GetAllKeys() = 0;
    
    //! 清空所有持久化数据
    virtual bool Clear() = 0;
    
    //! 同步数据到磁盘
    virtual bool Sync() = 0;
    
    //! 获取存储统计信息
    virtual idx_t GetStorageSize() const = 0;
    
    //! 关闭持久化存储
    virtual void Close() = 0;
};

//! 策略3: 仅内存实现（默认策略）
class MemoryOnlyPersistence : public CachePersistenceInterface {
public:
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
};

//! 策略1: 物化视图持久化实现
class MaterializedViewPersistence : public CachePersistenceInterface {
public:
    MaterializedViewPersistence(ClientContext &context);
    
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

private:
    ClientContext &context;
    CachePersistenceConfig config;
    string schema_name;
    mutex persistence_mutex;
    
    //! 创建物化视图表
    bool CreateMaterializedViewTable(const string &key, const MaterializedQueryResult &result);
    
    //! 获取物化视图表名
    string GetTableName(const string &key) const;
    
    //! 序列化查询结果元数据
    string SerializeMetadata(const QueryCacheEntry &entry) const;
    
    //! 反序列化查询结果元数据
    bool DeserializeMetadata(const string &metadata, QueryCacheEntry &entry) const;
};

//! 策略2: WAL格式持久化实现
class WALFormatPersistence : public CachePersistenceInterface {
public:
    WALFormatPersistence(ClientContext &context);
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

private:
    ClientContext &context;
    CachePersistenceConfig config;
    string wal_file_path;
    string index_file_path;
    unique_ptr<std::fstream> wal_file;
    unique_ptr<std::fstream> index_file;
    mutex wal_mutex;
    
    //! WAL文件中的条目索引
    struct WALIndex {
        uint64_t offset;
        uint32_t size;
        uint64_t timestamp;
        bool is_deleted;
    };
    unordered_map<string, WALIndex> index_map;
    
    //! WAL缓冲区
    vector<uint8_t> wal_buffer;
    idx_t buffer_offset = 0;
    
    //! 写入WAL记录
    bool WriteWALRecord(WALRecordType type, const string &key, const void *data, uint32_t size);
    
    //! 读取WAL记录
    bool ReadWALRecord(uint64_t offset, WALRecordHeader &header, vector<uint8_t> &data);
    
    //! 刷新WAL缓冲区
    bool FlushWALBuffer();
    
    //! 加载索引文件
    bool LoadIndex();
    
    //! 保存索引文件
    bool SaveIndex();
    
    //! 序列化缓存条目
    vector<uint8_t> SerializeEntry(const QueryCacheEntry &entry) const;
    
    //! 反序列化缓存条目
    unique_ptr<QueryCacheEntry> DeserializeEntry(const vector<uint8_t> &data) const;
    
    //! 计算校验和
    uint32_t CalculateChecksum(const void *data, uint32_t size) const;
    
    //! 压缩数据
    vector<uint8_t> CompressData(const vector<uint8_t> &data) const;
    
    //! 解压数据
    vector<uint8_t> DecompressData(const vector<uint8_t> &data) const;
};

//! 策略4: 混合持久化实现（热数据内存，冷数据落盘）
class HybridPersistence : public CachePersistenceInterface {
public:
    HybridPersistence(ClientContext &context);
    
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

private:
    ClientContext &context;
    CachePersistenceConfig config;
    
    //! 内存存储（热数据）
    unique_ptr<MemoryOnlyPersistence> memory_storage;
    
    //! 磁盘存储（冷数据）
    unique_ptr<WALFormatPersistence> disk_storage;
    
    //! 热数据访问统计
    struct AccessStats {
        idx_t access_count = 0;
        std::chrono::steady_clock::time_point last_access;
        idx_t data_size = 0;
    };
    unordered_map<string, AccessStats> access_stats;
    mutable mutex stats_mutex;
    
    //! 当前内存使用量
    std::atomic<idx_t> memory_usage{0};
    
    //! 判断是否为热数据
    bool IsHotData(const string &key) const;
    
    //! 将冷数据迁移到磁盘
    bool MigrateToDisk(const string &key);
    
    //! 将热数据迁移到内存
    bool MigrateToMemory(const string &key);
    
    //! 更新访问统计
    void UpdateAccessStats(const string &key, idx_t data_size);
    
    //! 清理冷数据
    void CleanupColdData();
};

//! 持久化工厂类
class CachePersistenceFactory {
public:
    static unique_ptr<CachePersistenceInterface> CreatePersistence(
        CachePersistenceStrategy strategy, 
        ClientContext *context = nullptr);
};

} // namespace duckdb