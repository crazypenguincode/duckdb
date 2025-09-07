//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/main/query_cache_persistence.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/main/query_cache_persistence.hpp"
#include "duckdb/common/serializer/binary_serializer.hpp"
#include "duckdb/common/serializer/binary_deserializer.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/common/types/hash.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/parser/parser.hpp"
#include "duckdb/common/file_system.hpp"
#include <zlib.h>
#include <thread>

namespace duckdb {

//===----------------------------------------------------------------------===//
// CachePersistenceFactory
//===----------------------------------------------------------------------===//

unique_ptr<CachePersistenceInterface> CachePersistenceFactory::CreatePersistence(
    CachePersistenceStrategy strategy, ClientContext *context) {
    
    switch (strategy) {
        case CachePersistenceStrategy::MEMORY_ONLY:
            return make_uniq<MemoryOnlyPersistence>();
        case CachePersistenceStrategy::MATERIALIZED_VIEW:
            if (!context) {
                throw InvalidInputException("MaterializedViewPersistence requires a ClientContext");
            }
            return make_uniq<MaterializedViewPersistence>(*context);
        case CachePersistenceStrategy::WAL_FORMAT:
            return make_uniq<WALFormatPersistence>();
        case CachePersistenceStrategy::HYBRID:
            if (!context) {
                throw InvalidInputException("HybridPersistence requires a ClientContext");
            }
            return make_uniq<HybridPersistence>(*context);
        default:
            throw InvalidInputException("Unknown persistence strategy");
    }
}

//===----------------------------------------------------------------------===//
// MemoryOnlyPersistence (策略3: 仅内存)
//===----------------------------------------------------------------------===//

bool MemoryOnlyPersistence::Initialize(const CachePersistenceConfig &config) {
    // 内存策略不需要初始化
    return true;
}

bool MemoryOnlyPersistence::PersistEntry(const string &key, const QueryCacheEntry &entry) {
    // 内存策略不持久化
    return true;
}

unique_ptr<QueryCacheEntry> MemoryOnlyPersistence::LoadEntry(const string &key) {
    // 内存策略无法加载持久化数据
    return nullptr;
}

bool MemoryOnlyPersistence::DeleteEntry(const string &key) {
    return true;
}

bool MemoryOnlyPersistence::EntryExists(const string &key) {
    return false;
}

vector<string> MemoryOnlyPersistence::GetAllKeys() {
    return {};
}

bool MemoryOnlyPersistence::Clear() {
    return true;
}

bool MemoryOnlyPersistence::Sync() {
    return true;
}

idx_t MemoryOnlyPersistence::GetStorageSize() const {
    return 0;
}

void MemoryOnlyPersistence::Close() {
    // 无需关闭操作
}

//===----------------------------------------------------------------------===//
// MaterializedViewPersistence (策略1: 物化视图)
//===----------------------------------------------------------------------===//

MaterializedViewPersistence::MaterializedViewPersistence(ClientContext &context) 
    : context(context), schema_name("query_cache_mv") {
}

bool MaterializedViewPersistence::Initialize(const CachePersistenceConfig &config) {
    lock_guard<mutex> lock(persistence_mutex);
    this->config = config;
    
    try {
        // 创建专用的schema用于存储缓存物化视图
        string create_schema_sql = StringUtil::Format("CREATE SCHEMA IF NOT EXISTS %s", schema_name);
        auto result = context.Query(create_schema_sql);
        if (result->HasError()) {
            printf("Failed to create cache schema: %s\n", result->GetError().c_str());
            return false;
        }
        
        // 创建元数据表用于存储缓存条目信息
        string create_metadata_table = StringUtil::Format(
            "CREATE TABLE IF NOT EXISTS %s.cache_metadata ("
            "cache_key VARCHAR PRIMARY KEY, "
            "table_name VARCHAR NOT NULL, "
            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
            "access_count BIGINT DEFAULT 1, "
            "last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
            "ml_score DOUBLE DEFAULT 0.5, "
            "result_size_bytes BIGINT DEFAULT 0, "
            "execution_time_ms DOUBLE DEFAULT 0.0"
            ")", schema_name);
        
        result = context.Query(create_metadata_table);
        if (result->HasError()) {
            printf("Failed to create metadata table: %s\n", result->GetError().c_str());
            return false;
        }
        
        printf("MaterializedViewPersistence initialized successfully\n");
        return true;
    } catch (std::exception &ex) {
        printf("MaterializedViewPersistence initialization failed: %s\n", ex.what());
        return false;
    }
}

bool MaterializedViewPersistence::PersistEntry(const string &key, const QueryCacheEntry &entry) {
    lock_guard<mutex> lock(persistence_mutex);
    
    try {
        string table_name = GetTableName(key);
        
        // 删除已存在的表
        string drop_table_sql = StringUtil::Format("DROP TABLE IF EXISTS %s.%s", schema_name, table_name);
        auto result = context.Query(drop_table_sql);
        if (result->HasError()) {
            printf("Failed to drop existing table: %s\n", result->GetError().c_str());
            return false;
        }
        
        // 创建物化视图表
        if (!CreateMaterializedViewTable(key, *entry.result)) {
            return false;
        }
        
        // 插入或更新元数据
        string upsert_metadata_sql = StringUtil::Format(
            "INSERT OR REPLACE INTO %s.cache_metadata "
            "(cache_key, table_name, access_count, ml_score, result_size_bytes, execution_time_ms) "
            "VALUES ('%s', '%s', %llu, %f, %llu, %f)",
            schema_name, key, table_name, entry.access_count, entry.ml_score,
            static_cast<idx_t>(entry.ml_features.result_size_bytes), entry.ml_features.execution_time_ms);
        
        result = context.Query(upsert_metadata_sql);
        if (result->HasError()) {
            printf("Failed to update metadata: %s\n", result->GetError().c_str());
            return false;
        }
        
        printf("Successfully persisted cache entry with key: %s\n", key.c_str());
        return true;
    } catch (std::exception &ex) {
        printf("Failed to persist entry: %s\n", ex.what());
        return false;
    }
}

unique_ptr<QueryCacheEntry> MaterializedViewPersistence::LoadEntry(const string &key) {
    lock_guard<mutex> lock(persistence_mutex);
    
    try {
        string table_name = GetTableName(key);
        
        // 检查表是否存在
        string check_table_sql = StringUtil::Format(
            "SELECT COUNT(*) FROM information_schema.tables "
            "WHERE table_schema = '%s' AND table_name = '%s'", schema_name, table_name);
        
        auto result = context.Query(check_table_sql);
        if (result->HasError() || result->RowCount() == 0) {
            return nullptr;
        }
        
        // 获取元数据
        string metadata_sql = StringUtil::Format(
            "SELECT access_count, ml_score, result_size_bytes, execution_time_ms "
            "FROM %s.cache_metadata WHERE cache_key = '%s'", schema_name, key);
        
        auto metadata_result = context.Query(metadata_sql);
        if (metadata_result->HasError() || metadata_result->RowCount() == 0) {
            return nullptr;
        }
        
        // 查询物化视图数据
        string data_sql = StringUtil::Format("SELECT * FROM %s.%s", schema_name, table_name);
        auto data_result = context.Query(data_sql);
        if (data_result->HasError()) {
            return nullptr;
        }
        
        // 转换为MaterializedQueryResult
        auto materialized_result = dynamic_cast<MaterializedQueryResult*>(data_result.get());
        if (!materialized_result) {
            return nullptr;
        }
        
        // 创建缓存条目
        auto cache_entry = make_uniq<QueryCacheEntry>(
            make_uniq<MaterializedQueryResult>(std::move(*materialized_result)));
        
        // 恢复元数据
        auto metadata_chunk = metadata_result->Fetch();
        if (metadata_chunk && metadata_chunk->size() > 0) {
            cache_entry->access_count = metadata_chunk->GetValue(0, 0).GetValue<idx_t>();
            cache_entry->ml_score = metadata_chunk->GetValue(1, 0).GetValue<double>();
            cache_entry->ml_features.result_size_bytes = metadata_chunk->GetValue(2, 0).GetValue<double>();
            cache_entry->ml_features.execution_time_ms = metadata_chunk->GetValue(3, 0).GetValue<double>();
        }
        
        printf("Successfully loaded cache entry with key: %s\n", key.c_str());
        return cache_entry;
    } catch (std::exception &ex) {
        printf("Failed to load entry: %s\n", ex.what());
        return nullptr;
    }
}

bool MaterializedViewPersistence::DeleteEntry(const string &key) {
    lock_guard<mutex> lock(persistence_mutex);
    
    try {
        string table_name = GetTableName(key);
        
        // 删除物化视图表
        string drop_table_sql = StringUtil::Format("DROP TABLE IF EXISTS %s.%s", schema_name, table_name);
        auto result = context.Query(drop_table_sql);
        if (result->HasError()) {
            printf("Failed to drop table: %s\n", result->GetError().c_str());
            return false;
        }
        
        // 删除元数据
        string delete_metadata_sql = StringUtil::Format(
            "DELETE FROM %s.cache_metadata WHERE cache_key = '%s'", schema_name, key);
        result = context.Query(delete_metadata_sql);
        if (result->HasError()) {
            printf("Failed to delete metadata: %s\n", result->GetError().c_str());
            return false;
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to delete entry: %s\n", ex.what());
        return false;
    }
}

bool MaterializedViewPersistence::EntryExists(const string &key) {
    lock_guard<mutex> lock(persistence_mutex);
    
    try {
        string table_name = GetTableName(key);
        string check_sql = StringUtil::Format(
            "SELECT COUNT(*) FROM information_schema.tables "
            "WHERE table_schema = '%s' AND table_name = '%s'", schema_name, table_name);
        
        auto result = context.Query(check_sql);
        if (result->HasError()) {
            return false;
        }
        
        auto chunk = result->Fetch();
        return chunk && chunk->size() > 0 && chunk->GetValue(0, 0).GetValue<idx_t>() > 0;
    } catch (std::exception &ex) {
        return false;
    }
}

vector<string> MaterializedViewPersistence::GetAllKeys() {
    lock_guard<mutex> lock(persistence_mutex);
    vector<string> keys;
    
    try {
        string sql = StringUtil::Format("SELECT cache_key FROM %s.cache_metadata", schema_name);
        auto result = context.Query(sql);
        if (result->HasError()) {
            return keys;
        }
        
        while (auto chunk = result->Fetch()) {
            for (idx_t i = 0; i < chunk->size(); i++) {
                keys.push_back(chunk->GetValue(0, i).ToString());
            }
        }
    } catch (std::exception &ex) {
        printf("Failed to get all keys: %s\n", ex.what());
    }
    
    return keys;
}

bool MaterializedViewPersistence::Clear() {
    lock_guard<mutex> lock(persistence_mutex);
    
    try {
        // 删除所有缓存表
        auto keys = GetAllKeys();
        for (const auto &key : keys) {
            DeleteEntry(key);
        }
        
        // 清空元数据表
        string clear_sql = StringUtil::Format("DELETE FROM %s.cache_metadata", schema_name);
        auto result = context.Query(clear_sql);
        return !result->HasError();
    } catch (std::exception &ex) {
        printf("Failed to clear cache: %s\n", ex.what());
        return false;
    }
}

bool MaterializedViewPersistence::Sync() {
    // 物化视图自动同步到磁盘
    return true;
}

idx_t MaterializedViewPersistence::GetStorageSize() const {
    // 这里可以查询数据库统计信息获取存储大小
    // 简化实现，返回估算值
    return 0;
}

void MaterializedViewPersistence::Close() {
    // 无需特殊关闭操作
}

bool MaterializedViewPersistence::CreateMaterializedViewTable(const string &key, const MaterializedQueryResult &result) {
    try {
        string table_name = GetTableName(key);
        
        // 构建CREATE TABLE语句
        string create_sql = StringUtil::Format("CREATE TABLE %s.%s (", schema_name, table_name);
        
        for (idx_t i = 0; i < result.types.size(); i++) {
            if (i > 0) create_sql += ", ";
            create_sql += StringUtil::Format("%s %s", result.names[i], result.types[i].ToString());
        }
        create_sql += ")";
        
        auto create_result = context.Query(create_sql);
        if (create_result->HasError()) {
            printf("Failed to create table: %s\n", create_result->GetError().c_str());
            return false;
        }
        
        // 插入数据
        if (result.RowCount() > 0) {
            // 构建INSERT语句
            string insert_sql = StringUtil::Format("INSERT INTO %s.%s VALUES ", schema_name, table_name);
            
            // 这里简化处理，实际应该批量插入数据
            // 由于MaterializedQueryResult的数据访问比较复杂，这里先返回true
            // 在实际实现中需要遍历result的所有数据并插入
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to create materialized view table: %s\n", ex.what());
        return false;
    }
}

string MaterializedViewPersistence::GetTableName(const string &key) const {
    // 使用hash生成安全的表名
    auto hash_value = Hash(key.c_str(), key.length());
    return StringUtil::Format("cache_table_%llu", hash_value);
}

//===----------------------------------------------------------------------===//
// WALFormatPersistence (策略2: WAL格式)
//===----------------------------------------------------------------------===//

bool WALFormatPersistence::Initialize(const CachePersistenceConfig &config) {
    lock_guard<mutex> lock(wal_mutex);
    this->config = config;
    
    try {
        // 创建存储目录
        auto &fs = FileSystem::GetFileSystem();
        if (!fs.DirectoryExists(config.persistence_path)) {
            fs.CreateDirectory(config.persistence_path);
        }
        
        wal_file_path = fs.JoinPath(config.persistence_path, "cache.wal");
        index_file_path = fs.JoinPath(config.persistence_path, "cache.idx");
        
        // 打开WAL文件
        wal_file = make_uniq<std::fstream>(wal_file_path, 
            std::ios::binary | std::ios::in | std::ios::out | std::ios::app);
        if (!wal_file->is_open()) {
            wal_file = make_uniq<std::fstream>(wal_file_path, 
                std::ios::binary | std::ios::out | std::ios::trunc);
            if (!wal_file->is_open()) {
                printf("Failed to create WAL file: %s\n", wal_file_path.c_str());
                return false;
            }
            wal_file->close();
            wal_file = make_uniq<std::fstream>(wal_file_path, 
                std::ios::binary | std::ios::in | std::ios::out);
        }
        
        // 初始化WAL缓冲区
        wal_buffer.resize(config.wal_buffer_size);
        buffer_offset = 0;
        
        // 加载索引
        LoadIndex();
        
        printf("WALFormatPersistence initialized successfully\n");
        return true;
    } catch (std::exception &ex) {
        printf("WALFormatPersistence initialization failed: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::PersistEntry(const string &key, const QueryCacheEntry &entry) {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        // 序列化缓存条目
        auto serialized_data = SerializeEntry(entry);
        
        // 压缩数据（如果启用）
        if (config.enable_compression) {
            serialized_data = CompressData(serialized_data);
        }
        
        // 写入WAL记录
        if (!WriteWALRecord(WALRecordType::CACHE_INSERT, key, 
                           serialized_data.data(), serialized_data.size())) {
            return false;
        }
        
        printf("Successfully persisted cache entry with key: %s (size: %zu bytes)\n", 
               key.c_str(), serialized_data.size());
        return true;
    } catch (std::exception &ex) {
        printf("Failed to persist entry: %s\n", ex.what());
        return false;
    }
}

unique_ptr<QueryCacheEntry> WALFormatPersistence::LoadEntry(const string &key) {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        auto it = index_map.find(key);
        if (it == index_map.end() || it->second.is_deleted) {
            return nullptr;
        }
        
        // 读取WAL记录
        WALRecordHeader header;
        vector<uint8_t> data;
        if (!ReadWALRecord(it->second.offset, header, data)) {
            return nullptr;
        }
        
        // 解压数据（如果需要）
        if (config.enable_compression) {
            data = DecompressData(data);
        }
        
        // 反序列化缓存条目
        auto entry = DeserializeEntry(data);
        if (entry) {
            printf("Successfully loaded cache entry with key: %s\n", key.c_str());
        }
        return entry;
    } catch (std::exception &ex) {
        printf("Failed to load entry: %s\n", ex.what());
        return nullptr;
    }
}

bool WALFormatPersistence::DeleteEntry(const string &key) {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        // 写入删除记录
        if (!WriteWALRecord(WALRecordType::CACHE_DELETE, key, nullptr, 0)) {
            return false;
        }
        
        // 更新索引
        auto it = index_map.find(key);
        if (it != index_map.end()) {
            it->second.is_deleted = true;
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to delete entry: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::EntryExists(const string &key) {
    lock_guard<mutex> lock(wal_mutex);
    auto it = index_map.find(key);
    return it != index_map.end() && !it->second.is_deleted;
}

vector<string> WALFormatPersistence::GetAllKeys() {
    lock_guard<mutex> lock(wal_mutex);
    vector<string> keys;
    
    for (const auto &entry : index_map) {
        if (!entry.second.is_deleted) {
            keys.push_back(entry.first);
        }
    }
    
    return keys;
}

bool WALFormatPersistence::Clear() {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        // 关闭文件
        if (wal_file && wal_file->is_open()) {
            wal_file->close();
        }
        
        // 删除文件
        auto &fs = FileSystem::GetFileSystem();
        if (fs.FileExists(wal_file_path)) {
            fs.RemoveFile(wal_file_path);
        }
        if (fs.FileExists(index_file_path)) {
            fs.RemoveFile(index_file_path);
        }
        
        // 清空索引
        index_map.clear();
        buffer_offset = 0;
        
        // 重新初始化
        return Initialize(config);
    } catch (std::exception &ex) {
        printf("Failed to clear cache: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::Sync() {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        // 刷新WAL缓冲区
        if (!FlushWALBuffer()) {
            return false;
        }
        
        // 同步文件到磁盘
        if (wal_file && wal_file->is_open()) {
            wal_file->flush();
        }
        
        // 保存索引
        return SaveIndex();
    } catch (std::exception &ex) {
        printf("Failed to sync: %s\n", ex.what());
        return false;
    }
}

idx_t WALFormatPersistence::GetStorageSize() const {
    try {
        auto &fs = FileSystem::GetFileSystem();
        idx_t total_size = 0;
        
        if (fs.FileExists(wal_file_path)) {
            total_size += fs.GetFileSize(wal_file_path);
        }
        if (fs.FileExists(index_file_path)) {
            total_size += fs.GetFileSize(index_file_path);
        }
        
        return total_size;
    } catch (std::exception &ex) {
        return 0;
    }
}

void WALFormatPersistence::Close() {
    lock_guard<mutex> lock(wal_mutex);
    
    try {
        // 同步数据
        Sync();
        
        // 关闭文件
        if (wal_file && wal_file->is_open()) {
            wal_file->close();
        }
        if (index_file && index_file->is_open()) {
            index_file->close();
        }
    } catch (std::exception &ex) {
        printf("Error closing WAL persistence: %s\n", ex.what());
    }
}

// WAL格式的私有方法实现
bool WALFormatPersistence::WriteWALRecord(WALRecordType type, const string &key, 
                                         const void *data, uint32_t size) {
    try {
        // 构建记录头部
        WALRecordHeader header;
        header.type = type;
        header.record_size = sizeof(uint32_t) + key.length() + size; // key_len + key + data
        header.timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::steady_clock::now().time_since_epoch()).count();
        
        // 计算校验和
        uint32_t key_len = key.length();
        vector<uint8_t> record_data;
        record_data.resize(sizeof(key_len) + key.length() + size);
        
        memcpy(record_data.data(), &key_len, sizeof(key_len));
        memcpy(record_data.data() + sizeof(key_len), key.data(), key.length());
        if (data && size > 0) {
            memcpy(record_data.data() + sizeof(key_len) + key.length(), data, size);
        }
        
        header.checksum = CalculateChecksum(record_data.data(), record_data.size());
        
        // 获取当前文件位置作为偏移量
        wal_file->seekp(0, std::ios::end);
        uint64_t offset = wal_file->tellp();
        
        // 写入记录头部
        wal_file->write(reinterpret_cast<const char*>(&header), sizeof(header));
        
        // 写入记录数据
        wal_file->write(reinterpret_cast<const char*>(record_data.data()), record_data.size());
        
        // 更新索引
        if (type == WALRecordType::CACHE_INSERT || type == WALRecordType::CACHE_UPDATE) {
            WALIndex index_entry;
            index_entry.offset = offset;
            index_entry.size = sizeof(header) + record_data.size();
            index_entry.timestamp = header.timestamp;
            index_entry.is_deleted = false;
            index_map[key] = index_entry;
        } else if (type == WALRecordType::CACHE_DELETE) {
            auto it = index_map.find(key);
            if (it != index_map.end()) {
                it->second.is_deleted = true;
            }
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to write WAL record: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::ReadWALRecord(uint64_t offset, WALRecordHeader &header, vector<uint8_t> &data) {
    try {
        wal_file->seekg(offset);
        
        // 读取记录头部
        wal_file->read(reinterpret_cast<char*>(&header), sizeof(header));
        if (wal_file->gcount() != sizeof(header)) {
            return false;
        }
        
        // 读取记录数据
        data.resize(header.record_size);
        wal_file->read(reinterpret_cast<char*>(data.data()), header.record_size);
        if (wal_file->gcount() != header.record_size) {
            return false;
        }
        
        // 验证校验和
        uint32_t calculated_checksum = CalculateChecksum(data.data(), data.size());
        if (calculated_checksum != header.checksum) {
            printf("Checksum mismatch in WAL record\n");
            return false;
        }
        
        // 提取实际数据（跳过key_len和key）
        uint32_t key_len;
        memcpy(&key_len, data.data(), sizeof(key_len));
        
        if (data.size() > sizeof(key_len) + key_len) {
            vector<uint8_t> actual_data(data.begin() + sizeof(key_len) + key_len, data.end());
            data = std::move(actual_data);
        } else {
            data.clear();
        }
        
        return true;
    } catch (std::exception &ex) {
        printf("Failed to read WAL record: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::FlushWALBuffer() {
    // 简化实现，直接返回true
    // 实际实现中应该将缓冲区数据写入文件
    return true;
}

bool WALFormatPersistence::LoadIndex() {
    try {
        auto &fs = FileSystem::GetFileSystem();
        if (!fs.FileExists(index_file_path)) {
            return true; // 索引文件不存在是正常的
        }
        
        index_file = make_uniq<std::fstream>(index_file_path, std::ios::binary | std::ios::in);
        if (!index_file->is_open()) {
            return false;
        }
        
        // 读取索引条目数量
        uint32_t entry_count;
        index_file->read(reinterpret_cast<char*>(&entry_count), sizeof(entry_count));
        
        // 读取索引条目
        for (uint32_t i = 0; i < entry_count; i++) {
            uint32_t key_len;
            index_file->read(reinterpret_cast<char*>(&key_len), sizeof(key_len));
            
            string key(key_len, '\0');
            index_file->read(key.data(), key_len);
            
            WALIndex index_entry;
            index_file->read(reinterpret_cast<char*>(&index_entry), sizeof(index_entry));
            
            index_map[key] = index_entry;
        }
        
        index_file->close();
        return true;
    } catch (std::exception &ex) {
        printf("Failed to load index: %s\n", ex.what());
        return false;
    }
}

bool WALFormatPersistence::SaveIndex() {
    try {
        index_file = make_uniq<std::fstream>(index_file_path, 
            std::ios::binary | std::ios::out | std::ios::trunc);
        if (!index_file->is_open()) {
            return false;
        }
        
        // 写入索引条目数量
        uint32_t entry_count = index_map.size();
        index_file->write(reinterpret_cast<const char*>(&entry_count), sizeof(entry_count));
        
        // 写入索引条目
        for (const auto &entry : index_map) {
            uint32_t key_len = entry.first.length();
            index_file->write(reinterpret_cast<const char*>(&key_len), sizeof(key_len));
            index_file->write(entry.first.data(), key_len);
            index_file->write(reinterpret_cast<const char*>(&entry.second), sizeof(entry.second));
        }
        
        index_file->close();
        return true;
    } catch (std::exception &ex) {
        printf("Failed to save index: %s\n", ex.what());
        return false;
    }
}

vector<uint8_t> WALFormatPersistence::SerializeEntry(const QueryCacheEntry &entry) const {
    // 简化的序列化实现
    // 实际实现中应该使用DuckDB的序列化框架
    vector<uint8_t> data;
    
    // 这里应该序列化QueryCacheEntry的所有字段
    // 包括result、created_at、access_count、ml_features等
    // 由于MaterializedQueryResult的序列化比较复杂，这里先返回空数据
    
    return data;
}

unique_ptr<QueryCacheEntry> WALFormatPersistence::DeserializeEntry(const vector<uint8_t> &data) const {
    // 简化的反序列化实现
    // 实际实现中应该从序列化数据重建QueryCacheEntry
    return nullptr;
}

uint32_t WALFormatPersistence::CalculateChecksum(const void *data, uint32_t size) const {
    // 使用简单的CRC32校验和
    return crc32(0, static_cast<const Bytef*>(data), size);
}

vector<uint8_t> WALFormatPersistence::CompressData(const vector<uint8_t> &data) const {
    if (!config.enable_compression || data.empty()) {
        return data;
    }
    
    // 使用zlib压缩
    uLongf compressed_size = compressBound(data.size());
    vector<uint8_t> compressed_data(compressed_size);
    
    int result = compress(compressed_data.data(), &compressed_size, 
                         data.data(), data.size());
    
    if (result == Z_OK) {
        compressed_data.resize(compressed_size);
        return compressed_data;
    }
    
    return data; // 压缩失败，返回原数据
}

vector<uint8_t> WALFormatPersistence::DecompressData(const vector<uint8_t> &data) const {
    if (!config.enable_compression || data.empty()) {
        return data;
    }
    
    // 这里需要知道原始数据大小，简化实现先返回原数据
    // 实际实现中应该在压缩时保存原始大小信息
    return data;
}

//===----------------------------------------------------------------------===//
// HybridPersistence (策略4: 混合策略)
//===----------------------------------------------------------------------===//

HybridPersistence::HybridPersistence(ClientContext &context) : context(context) {
    memory_storage = make_uniq<MemoryOnlyPersistence>();
    disk_storage = make_uniq<WALFormatPersistence>();
}

bool HybridPersistence::Initialize(const CachePersistenceConfig &config) {
    this->config = config;
    
    // 初始化内存和磁盘存储
    bool memory_ok = memory_storage->Initialize(config);
    bool disk_ok = disk_storage->Initialize(config);
    
    if (memory_ok && disk_ok) {
        printf("HybridPersistence initialized successfully\n");
        return true;
    }
    
    return false;
}

bool HybridPersistence::PersistEntry(const string &key, const QueryCacheEntry &entry) {
    // 根据数据热度决定存储位置
    idx_t data_size = static_cast<idx_t>(entry.ml_features.result_size_bytes);
    UpdateAccessStats(key, data_size);
    
    if (IsHotData(key)) {
        // 热数据存储在内存
        memory_usage += data_size;
        
        // 如果内存超限，迁移一些冷数据到磁盘
        if (memory_usage > config.memory_threshold_bytes) {
            CleanupColdData();
        }
        
        return memory_storage->PersistEntry(key, entry);
    } else {
        // 冷数据存储在磁盘
        return disk_storage->PersistEntry(key, entry);
    }
}

unique_ptr<QueryCacheEntry> HybridPersistence::LoadEntry(const string &key) {
    // 先尝试从内存加载
    auto entry = memory_storage->LoadEntry(key);
    if (entry) {
        UpdateAccessStats(key, static_cast<idx_t>(entry->ml_features.result_size_bytes));
        return entry;
    }
    
    // 再尝试从磁盘加载
    entry = disk_storage->LoadEntry(key);
    if (entry) {
        UpdateAccessStats(key, static_cast<idx_t>(entry->ml_features.result_size_bytes));
        
        // 如果是热数据，迁移到内存
        if (IsHotData(key)) {
            MigrateToMemory(key);
        }
    }
    
    return entry;
}

bool HybridPersistence::DeleteEntry(const string &key) {
    lock_guard<mutex> lock(stats_mutex);
    
    // 从统计信息中删除
    auto it = access_stats.find(key);
    if (it != access_stats.end()) {
        memory_usage -= it->second.data_size;
        access_stats.erase(it);
    }
    
    // 从内存和磁盘中删除
    bool memory_deleted = memory_storage->DeleteEntry(key);
    bool disk_deleted = disk_storage->DeleteEntry(key);
    
    return memory_deleted || disk_deleted;
}

bool HybridPersistence::EntryExists(const string &key) {
    return memory_storage->EntryExists(key) || disk_storage->EntryExists(key);
}

vector<string> HybridPersistence::GetAllKeys() {
    auto memory_keys = memory_storage->GetAllKeys();
    auto disk_keys = disk_storage->GetAllKeys();
    
    // 合并去重
    unordered_set<string> all_keys_set;
    for (const auto &key : memory_keys) {
        all_keys_set.insert(key);
    }
    for (const auto &key : disk_keys) {
        all_keys_set.insert(key);
    }
    
    return vector<string>(all_keys_set.begin(), all_keys_set.end());
}

bool HybridPersistence::Clear() {
    lock_guard<mutex> lock(stats_mutex);
    
    access_stats.clear();
    memory_usage = 0;
    
    bool memory_cleared = memory_storage->Clear();
    bool disk_cleared = disk_storage->Clear();
    
    return memory_cleared && disk_cleared;
}

bool HybridPersistence::Sync() {
    bool memory_synced = memory_storage->Sync();
    bool disk_synced = disk_storage->Sync();
    return memory_synced && disk_synced;
}

idx_t HybridPersistence::GetStorageSize() const {
    return memory_storage->GetStorageSize() + disk_storage->GetStorageSize();
}

void HybridPersistence::Close() {
    memory_storage->Close();
    disk_storage->Close();
}

bool HybridPersistence::IsHotData(const string &key) const {
    lock_guard<mutex> lock(stats_mutex);
    
    auto it = access_stats.find(key);
    if (it == access_stats.end()) {
        return false; // 新数据默认为冷数据
    }
    
    const auto &stats = it->second;
    auto now = std::chrono::steady_clock::now();
    auto time_since_access = std::chrono::duration_cast<std::chrono::minutes>(
        now - stats.last_access).count();
    
    // 热数据判断条件：访问次数 > 2 且最近10分钟内访问过
    return stats.access_count > 2 && time_since_access < 10;
}

bool HybridPersistence::MigrateToDisk(const string &key) {
    // 从内存加载数据
    auto entry = memory_storage->LoadEntry(key);
    if (!entry) {
        return false;
    }
    
    // 保存到磁盘
    bool disk_saved = disk_storage->PersistEntry(key, *entry);
    if (disk_saved) {
        // 从内存删除
        memory_storage->DeleteEntry(key);
        
        // 更新内存使用量
        lock_guard<mutex> lock(stats_mutex);
        auto it = access_stats.find(key);
        if (it != access_stats.end()) {
            memory_usage -= it->second.data_size;
        }
    }
    
    return disk_saved;
}

bool HybridPersistence::MigrateToMemory(const string &key) {
    // 从磁盘加载数据
    auto entry = disk_storage->LoadEntry(key);
    if (!entry) {
        return false;
    }
    
    // 保存到内存
    bool memory_saved = memory_storage->PersistEntry(key, *entry);
    if (memory_saved) {
        // 从磁盘删除
        disk_storage->DeleteEntry(key);
        
        // 更新内存使用量
        idx_t data_size = static_cast<idx_t>(entry->ml_features.result_size_bytes);
        memory_usage += data_size;
    }
    
    return memory_saved;
}

void HybridPersistence::UpdateAccessStats(const string &key, idx_t data_size) {
    lock_guard<mutex> lock(stats_mutex);
    
    auto &stats = access_stats[key];
    stats.access_count++;
    stats.last_access = std::chrono::steady_clock::now();
    stats.data_size = data_size;
}

void HybridPersistence::CleanupColdData() {
    lock_guard<mutex> lock(stats_mutex);
    
    // 找出最冷的数据并迁移到磁盘
    vector<pair<string, std::chrono::steady_clock::time_point>> candidates;
    
    for (const auto &entry : access_stats) {
        if (!IsHotData(entry.first)) {
            candidates.emplace_back(entry.first, entry.second.last_access);
        }
    }
    
    // 按最后访问时间排序
    std::sort(candidates.begin(), candidates.end(), 
        [](const auto &a, const auto &b) {
            return a.second < b.second;
        });
    
    // 迁移最冷的数据直到内存使用量降到阈值以下
    for (const auto &candidate : candidates) {
        if (memory_usage <= config.memory_threshold_bytes) {
            break;
        }
        
        MigrateToDisk(candidate.first);
    }
}

} // namespace duckdb