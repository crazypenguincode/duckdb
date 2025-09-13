//===----------------------------------------------------------------------===//
//                         DuckDB
//
// cache_test/duckdb_real_api_test.cpp
//
// 使用真实DuckDB API的缓存测试
//===----------------------------------------------------------------------===//

#include "duckdb.hpp"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <chrono>
#include <unordered_map>
#include <random>
#include <algorithm>
#include <iomanip>
#include <sstream>
#include <cmath>
#include <memory>

using namespace std;
using namespace chrono;
using namespace duckdb;

// 查询执行结果
struct QueryExecutionResult {
    string query_id;
    double execution_time_ms;
    size_t result_rows;
    size_t result_size_bytes;
    bool from_cache;
    string timestamp;
    bool success;
    string error_message;
};

// 缓存条目
struct CacheEntry {
    string query_hash;
    unique_ptr<MaterializedQueryResult> result;
    size_t size_bytes;
    double access_frequency;
    double last_access_time;
    double creation_time;
    double computation_cost;
    vector<double> access_history;
    
    CacheEntry(const string& hash, unique_ptr<MaterializedQueryResult> res, 
               size_t size, double cost) 
        : query_hash(hash), result(move(res)), size_bytes(size), 
          access_frequency(1.0), computation_cost(cost) {
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        last_access_time = creation_time = now;
        access_history.push_back(now);
    }
};

// 增强的ML缓存预测器
class RealMLCachePredictor {
private:
    struct QueryPattern {
        vector<double> access_times;
        vector<double> execution_times;
        double frequency = 0.0;
        double avg_execution_time = 0.0;
        double last_access = 0.0;
        int access_count = 0;
        double complexity_score = 0.0;
    };
    
    unordered_map<string, QueryPattern> patterns;
    
    // ML参数
    double alpha = 0.3;  // 时间序列平滑参数
    double beta = 0.3;   // 趋势参数
    vector<double> weights = {0.25, 0.20, 0.30, 0.15, 0.10}; // 价值评估权重
    
    // Adam优化器参数
    vector<double> m_weights, v_weights;
    double learning_rate = 0.001;
    double beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8;
    int adam_step = 0;
    
public:
    RealMLCachePredictor() {
        m_weights.resize(weights.size(), 0.0);
        v_weights.resize(weights.size(), 0.0);
    }
    
    void RecordAccess(const string& query_hash, double execution_time, const string& query_text) {
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        auto& pattern = patterns[query_hash];
        pattern.access_times.push_back(now);
        pattern.execution_times.push_back(execution_time);
        pattern.access_count++;
        pattern.last_access = now;
        
        // 计算查询复杂度
        pattern.complexity_score = CalculateQueryComplexity(query_text);
        
        // 更新平均执行时间 (指数移动平均)
        if (pattern.avg_execution_time == 0.0) {
            pattern.avg_execution_time = execution_time;
        } else {
            pattern.avg_execution_time = 0.8 * pattern.avg_execution_time + 0.2 * execution_time;
        }
        
        // 计算访问频率 (每小时访问次数)
        if (pattern.access_times.size() > 1) {
            double time_span = (now - pattern.access_times[0]) / (1000.0 * 3600.0);
            pattern.frequency = pattern.access_count / max(0.1, time_span);
        }
        
        // 限制历史记录大小
        if (pattern.access_times.size() > 50) {
            pattern.access_times.erase(pattern.access_times.begin(), 
                                     pattern.access_times.begin() + 25);
            pattern.execution_times.erase(pattern.execution_times.begin(),
                                        pattern.execution_times.begin() + 25);
        }
    }
    
    double PredictAccessProbability(const string& query_hash) {
        auto it = patterns.find(query_hash);
        if (it == patterns.end() || it->second.access_times.size() < 2) {
            return 0.4; // 默认概率
        }
        
        const auto& pattern = it->second;
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        // 计算访问间隔
        vector<double> intervals;
        for (size_t i = 1; i < pattern.access_times.size(); i++) {
            intervals.push_back(pattern.access_times[i] - pattern.access_times[i-1]);
        }
        
        if (intervals.empty()) return 0.4;
        
        // 使用Holt-Winters进行时间序列预测
        double level = intervals[0];
        double trend = 0.0;
        
        if (intervals.size() > 1) {
            trend = intervals[1] - intervals[0];
            
            for (size_t i = 2; i < intervals.size(); i++) {
                double new_level = alpha * intervals[i] + (1 - alpha) * (level + trend);
                double new_trend = beta * (new_level - level) + (1 - beta) * trend;
                level = new_level;
                trend = new_trend;
            }
        }
        
        // 预测下次访问间隔
        double predicted_interval = level + trend;
        double time_since_last = now - pattern.last_access;
        
        // 转换为概率 (考虑预测间隔和实际间隔的差异)
        if (predicted_interval <= 0) predicted_interval = 3600000; // 1小时默认
        
        double probability = exp(-abs(time_since_last - predicted_interval) / predicted_interval);
        return min(0.95, max(0.05, probability));
    }
    
    double CalculateCacheValue(const string& query_hash, size_t result_size) {
        auto it = patterns.find(query_hash);
        if (it == patterns.end()) {
            return 0.5; // 默认价值
        }
        
        const auto& pattern = it->second;
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        // 特征归一化
        double freq_score = min(1.0, pattern.frequency / 10.0); // 每小时10次为满分
        double recency_score = exp(-(now - pattern.last_access) / 3600000.0); // 1小时衰减
        double cost_score = min(1.0, pattern.avg_execution_time / 500.0); // 500ms为满分
        double size_score = 1.0 - min(1.0, result_size / (2.0 * 1024 * 1024)); // 2MB惩罚
        double predict_score = PredictAccessProbability(query_hash);
        
        // 加权计算价值
        double value = weights[0] * freq_score +
                      weights[1] * recency_score +
                      weights[2] * cost_score +
                      weights[3] * size_score +
                      weights[4] * predict_score;
        
        return max(0.0, min(1.0, value));
    }
    
    void UpdateWeights(const vector<double>& features, double actual_benefit) {
        adam_step++;
        
        // 计算预测值
        double predicted = 0.0;
        for (size_t i = 0; i < weights.size(); i++) {
            predicted += weights[i] * features[i];
        }
        
        // 计算梯度
        double error = predicted - actual_benefit;
        vector<double> gradients(weights.size());
        for (size_t i = 0; i < weights.size(); i++) {
            gradients[i] = error * features[i];
        }
        
        // Adam更新
        for (size_t i = 0; i < weights.size(); i++) {
            m_weights[i] = beta1 * m_weights[i] + (1 - beta1) * gradients[i];
            v_weights[i] = beta2 * v_weights[i] + (1 - beta2) * gradients[i] * gradients[i];
            
            double m_hat = m_weights[i] / (1 - pow(beta1, adam_step));
            double v_hat = v_weights[i] / (1 - pow(beta2, adam_step));
            
            weights[i] -= learning_rate * m_hat / (sqrt(v_hat) + epsilon);
            weights[i] = max(0.0, min(1.0, weights[i]));
        }
    }
    
private:
    double CalculateQueryComplexity(const string& query) {
        string upper_query = query;
        transform(upper_query.begin(), upper_query.end(), upper_query.begin(), ::toupper);
        
        double complexity = 1.0;
        
        // 统计各种复杂度指标
        complexity += CountOccurrences(upper_query, "JOIN") * 2.0;
        complexity += CountOccurrences(upper_query, "GROUP BY") * 1.5;
        complexity += CountOccurrences(upper_query, "ORDER BY") * 1.2;
        complexity += CountOccurrences(upper_query, "HAVING") * 1.3;
        complexity += CountOccurrences(upper_query, "UNION") * 1.8;
        complexity += CountOccurrences(upper_query, "SUBQUERY") * 2.5;
        
        // 聚合函数
        complexity += (CountOccurrences(upper_query, "SUM(") +
                      CountOccurrences(upper_query, "COUNT(") +
                      CountOccurrences(upper_query, "AVG(") +
                      CountOccurrences(upper_query, "MAX(") +
                      CountOccurrences(upper_query, "MIN(")) * 0.5;
        
        return complexity;
    }
    
    int CountOccurrences(const string& text, const string& pattern) {
        int count = 0;
        size_t pos = 0;
        while ((pos = text.find(pattern, pos)) != string::npos) {
            count++;
            pos += pattern.length();
        }
        return count;
    }
    
public:
    void PrintDetailedStats() {
        cout << "\n=== ML缓存预测器详细统计 ===" << endl;
        cout << "跟踪的查询模式数: " << patterns.size() << endl;
        
        if (!patterns.empty()) {
            double total_frequency = 0.0;
            double total_complexity = 0.0;
            double max_frequency = 0.0;
            int total_accesses = 0;
            
            for (const auto& pair : patterns) {
                const auto& pattern = pair.second;
                total_frequency += pattern.frequency;
                total_complexity += pattern.complexity_score;
                max_frequency = max(max_frequency, pattern.frequency);
                total_accesses += pattern.access_count;
            }
            
            cout << "平均访问频率: " << fixed << setprecision(2) 
                 << total_frequency / patterns.size() << " 次/小时" << endl;
            cout << "最高访问频率: " << fixed << setprecision(2) << max_frequency << " 次/小时" << endl;
            cout << "平均查询复杂度: " << fixed << setprecision(2) 
                 << total_complexity / patterns.size() << endl;
            cout << "总访问次数: " << total_accesses << endl;
            
            // 显示当前权重
            cout << "当前价值评估权重: [";
            for (size_t i = 0; i < weights.size(); i++) {
                cout << fixed << setprecision(3) << weights[i];
                if (i < weights.size() - 1) cout << ", ";
            }
            cout << "]" << endl;
        }
    }
};

// 真实DuckDB缓存测试器
class RealDuckDBCacheTest {
private:
    unique_ptr<DuckDB> db;
    unique_ptr<Connection> conn;
    RealMLCachePredictor ml_predictor;
    
    // 缓存存储
    unordered_map<string, unique_ptr<CacheEntry>> cache;
    size_t max_cache_entries = 30;
    size_t max_cache_memory = 50 * 1024 * 1024; // 50MB
    size_t current_cache_memory = 0;
    
    // 统计信息
    int total_queries = 0;
    int cache_hits = 0;
    int cache_misses = 0;
    double total_execution_time = 0.0;
    double total_cache_time = 0.0;
    vector<QueryExecutionResult> execution_log;
    
public:
    RealDuckDBCacheTest() {
        try {
            db = make_unique<DuckDB>(nullptr);
            conn = make_unique<Connection>(*db);
        } catch (const exception& e) {
            cout << "❌ DuckDB初始化失败: " << e.what() << endl;
        }
    }
    
    bool LoadTPCHData(const string& db_path) {
        try {
            // 尝试连接到现有数据库
            if (!db_path.empty()) {
                db = make_unique<DuckDB>(db_path);
                conn = make_unique<Connection>(*db);
                
                // 测试连接
                auto result = conn->Query("SELECT COUNT(*) FROM information_schema.tables");
                if (result->HasError()) {
                    cout << "⚠️  无法连接到TPC-H数据库，使用内存数据库" << endl;
                    db = make_unique<DuckDB>(nullptr);
                    conn = make_unique<Connection>(*db);
                    return false;
                }
                
                cout << "✅ 成功连接到TPC-H数据库" << endl;
                return true;
            }
        } catch (const exception& e) {
            cout << "⚠️  数据库连接失败: " << e.what() << "，使用内存数据库" << endl;
        }
        
        // 创建示例数据
        CreateSampleData();
        return false;
    }
    
    void CreateSampleData() {
        cout << "创建示例TPC-H数据..." << endl;
        
        try {
            // 创建简化的lineitem表
            conn->Query(R"(
                CREATE TABLE lineitem (
                    l_orderkey INTEGER,
                    l_partkey INTEGER,
                    l_suppkey INTEGER,
                    l_linenumber INTEGER,
                    l_quantity DECIMAL(15,2),
                    l_extendedprice DECIMAL(15,2),
                    l_discount DECIMAL(15,2),
                    l_tax DECIMAL(15,2),
                    l_returnflag CHAR(1),
                    l_linestatus CHAR(1),
                    l_shipdate DATE,
                    l_commitdate DATE,
                    l_receiptdate DATE,
                    l_shipinstruct CHAR(25),
                    l_shipmode CHAR(10),
                    l_comment VARCHAR(44)
                )
            )");
            
            // 插入示例数据
            conn->Query(R"(
                INSERT INTO lineitem VALUES
                (1, 1, 1, 1, 17.0, 21168.23, 0.04, 0.02, 'N', 'O', '1996-03-13', '1996-02-12', '1996-03-22', 'DELIVER IN PERSON', 'TRUCK', 'comment1'),
                (1, 2, 2, 2, 36.0, 45983.16, 0.09, 0.06, 'N', 'O', '1996-04-12', '1996-02-28', '1996-04-20', 'TAKE BACK RETURN', 'MAIL', 'comment2'),
                (2, 3, 3, 1, 8.0, 13309.60, 0.10, 0.02, 'R', 'F', '1997-01-28', '1997-02-02', '1997-02-02', 'DELIVER IN PERSON', 'AIR', 'comment3'),
                (3, 4, 4, 1, 45.0, 54058.05, 0.06, 0.00, 'R', 'F', '1994-02-02', '1994-01-04', '1994-02-23', 'NONE', 'AIR', 'comment4'),
                (3, 5, 5, 2, 49.0, 46796.47, 0.10, 0.00, 'R', 'F', '1993-11-09', '1993-12-20', '1993-11-24', 'TAKE BACK RETURN', 'RAIL', 'comment5')
            )");
            
            // 创建更多数据以便测试
            for (int i = 6; i <= 1000; i++) {
                string insert_sql = "INSERT INTO lineitem VALUES (" +
                    to_string(i) + ", " + to_string(i % 100 + 1) + ", " + to_string(i % 50 + 1) + ", 1, " +
                    to_string(10.0 + (i % 50)) + ", " + to_string(1000.0 + (i % 1000) * 10) + ", " +
                    to_string(0.01 + (i % 10) * 0.01) + ", " + to_string(0.01 + (i % 5) * 0.01) + ", " +
                    "'N', 'O', '1996-01-01', '1996-01-01', '1996-01-01', 'DELIVER IN PERSON', 'TRUCK', 'comment" + to_string(i) + "')";
                conn->Query(insert_sql);
            }
            
            cout << "✅ 示例数据创建完成" << endl;
        } catch (const exception& e) {
            cout << "❌ 示例数据创建失败: " << e.what() << endl;
        }
    }
    
    QueryExecutionResult ExecuteQueryWithCache(const string& query_id, const string& query) {
        total_queries++;
        
        QueryExecutionResult result;
        result.query_id = query_id;
        result.timestamp = to_string(duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count());
        
        // 生成查询哈希
        hash<string> hasher;
        string query_hash = to_string(hasher(query));
        
        auto start_time = high_resolution_clock::now();
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            // 缓存命中
            cache_hits++;
            result.from_cache = true;
            result.success = true;
            
            auto& entry = cache_it->second;
            result.result_rows = entry->result->RowCount();
            result.result_size_bytes = entry->size_bytes;
            
            auto end_time = high_resolution_clock::now();
            result.execution_time_ms = duration_cast<microseconds>(end_time - start_time).count() / 1000.0;
            
            // 更新访问统计
            entry->access_frequency++;
            entry->last_access_time = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
            entry->access_history.push_back(entry->last_access_time);
            
            total_cache_time += result.execution_time_ms;
            
            cout << "[CACHE HIT] " << query_id << " - " << fixed << setprecision(2) 
                 << result.execution_time_ms << "ms (" << result.result_rows << " rows)" << endl;
        } else {
            // 缓存未命中，执行查询
            cache_misses++;
            result.from_cache = false;
            
            try {
                auto query_result = conn->Query(query);
                auto end_time = high_resolution_clock::now();
                result.execution_time_ms = duration_cast<microseconds>(end_time - start_time).count() / 1000.0;
                
                if (query_result->HasError()) {
                    result.success = false;
                    result.error_message = query_result->GetError();
                    cout << "[ERROR] " << query_id << " - " << result.error_message << endl;
                } else {
                    result.success = true;
                    result.result_rows = query_result->RowCount();
                    
                    // 估算结果大小
                    result.result_size_bytes = EstimateResultSize(query_result.get());
                    
                    // 记录访问模式
                    ml_predictor.RecordAccess(query_hash, result.execution_time_ms, query);
                    
                    // 决定是否缓存
                    double cache_value = ml_predictor.CalculateCacheValue(query_hash, result.result_size_bytes);
                    bool should_cache = cache_value > 0.5 && result.execution_time_ms > 10.0; // 阈值可调
                    
                    if (should_cache) {
                        // 检查缓存空间
                        while ((cache.size() >= max_cache_entries || 
                               current_cache_memory + result.result_size_bytes > max_cache_memory) 
                               && !cache.empty()) {
                            EvictLeastValuableEntry();
                        }
                        
                        // 添加到缓存
                        if (cache.size() < max_cache_entries && 
                            current_cache_memory + result.result_size_bytes <= max_cache_memory) {
                            
                            auto cache_entry = make_unique<CacheEntry>(
                                query_hash, 
                                unique_ptr<MaterializedQueryResult>(
                                    static_cast<MaterializedQueryResult*>(query_result.release())
                                ),
                                result.result_size_bytes, 
                                result.execution_time_ms
                            );
                            
                            current_cache_memory += result.result_size_bytes;
                            cache[query_hash] = move(cache_entry);
                            
                            cout << "[CACHED] " << query_id << " - " << fixed << setprecision(2) 
                                 << result.execution_time_ms << "ms (价值: " << setprecision(3) 
                                 << cache_value << ", " << result.result_rows << " rows)" << endl;
                        }
                    } else {
                        cout << "[NOT CACHED] " << query_id << " - " << fixed << setprecision(2) 
                             << result.execution_time_ms << "ms (价值: " << setprecision(3) 
                             << cache_value << ", " << result.result_rows << " rows)" << endl;
                    }
                }
                
                total_execution_time += result.execution_time_ms;
            } catch (const exception& e) {
                result.success = false;
                result.error_message = e.what();
                auto end_time = high_resolution_clock::now();
                result.execution_time_ms = duration_cast<microseconds>(end_time - start_time).count() / 1000.0;
                cout << "[EXCEPTION] " << query_id << " - " << e.what() << endl;
            }
        }
        
        execution_log.push_back(result);
        return result;
    }
    
    void EvictLeastValuableEntry() {
        if (cache.empty()) return;
        
        string worst_key;
        double worst_value = 1.0;
        
        for (const auto& pair : cache) {
            double value = ml_predictor.CalculateCacheValue(pair.first, pair.second->size_bytes);
            if (value < worst_value) {
                worst_value = value;
                worst_key = pair.first;
            }
        }
        
        if (!worst_key.empty()) {
            current_cache_memory -= cache[worst_key]->size_bytes;
            cache.erase(worst_key);
            cout << "[EVICTED] 缓存条目 (价值: " << fixed << setprecision(3) << worst_value << ")" << endl;
        }
    }
    
    size_t EstimateResultSize(QueryResult* result) {
        if (!result) return 0;
        
        size_t estimated_size = 0;
        estimated_size += result->RowCount() * result->ColumnCount() * 20; // 平均每个值20字节
        estimated_size += result->names.size() * 50; // 列名
        
        return estimated_size;
    }
    
    void PrintComprehensiveStats() {
        cout << "\n" << string(60, '=') << endl;
        cout << "DuckDB ML缓存系统综合性能报告" << endl;
        cout << string(60, '=') << endl;
        
        cout << "\n基础统计:" << endl;
        cout << "  总查询数: " << total_queries << endl;
        cout << "  缓存命中数: " << cache_hits << endl;
        cout << "  缓存未命中数: " << cache_misses << endl;
        cout << "  命中率: " << fixed << setprecision(1) 
             << (total_queries > 0 ? 100.0 * cache_hits / total_queries : 0.0) << "%" << endl;
        
        double avg_execution_time = cache_misses > 0 ? total_execution_time / cache_misses : 0.0;
        double avg_cache_time = cache_hits > 0 ? total_cache_time / cache_hits : 0.0;
        double overall_avg_time = total_queries > 0 ? (total_execution_time + total_cache_time) / total_queries : 0.0;
        
        cout << "\n性能指标:" << endl;
        cout << "  平均查询执行时间: " << fixed << setprecision(2) << avg_execution_time << "ms" << endl;
        cout << "  平均缓存访问时间: " << fixed << setprecision(2) << avg_cache_time << "ms" << endl;
        cout << "  总体平均响应时间: " << fixed << setprecision(2) << overall_avg_time << "ms" << endl;
        
        // 计算性能提升
        if (cache_hits > 0 && avg_execution_time > 0) {
            double time_saved = cache_hits * (avg_execution_time - avg_cache_time);
            double improvement_pct = (avg_execution_time - avg_cache_time) / avg_execution_time * 100;
            cout << "  缓存节省时间: " << fixed << setprecision(1) << time_saved << "ms" << endl;
            cout << "  性能提升: " << fixed << setprecision(1) << improvement_pct << "%" << endl;
        }
        
        cout << "\n缓存状态:" << endl;
        cout << "  当前缓存条目数: " << cache.size() << "/" << max_cache_entries << endl;
        cout << "  内存使用: " << current_cache_memory / 1024 << "KB / " 
             << max_cache_memory / 1024 << "KB" << endl;
        cout << "  内存利用率: " << fixed << setprecision(1) 
             << 100.0 * current_cache_memory / max_cache_memory << "%" << endl;
        
        // ML预测器统计
        ml_predictor.PrintDetailedStats();
        
        // 查询类型分析
        AnalyzeQueryTypes();
    }
    
    void AnalyzeQueryTypes() {
        cout << "\n查询类型分析:" << endl;
        
        unordered_map<string, vector<double>> query_performance;
        
        for (const auto& log_entry : execution_log) {
            query_performance[log_entry.query_id].push_back(log_entry.execution_time_ms);
        }
        
        cout << left << setw(8) << "查询ID" << setw(12) << "执行次数" 
             << setw(15) << "平均时间(ms)" << setw(15) << "最快时间(ms)" 
             << setw(15) << "最慢时间(ms)" << endl;
        cout << string(65, '-') << endl;
        
        for (const auto& pair : query_performance) {
            const auto& times = pair.second;
            double avg_time = accumulate(times.begin(), times.end(), 0.0) / times.size();
            double min_time = *min_element(times.begin(), times.end());
            double max_time = *max_element(times.begin(), times.end());
            
            cout << left << setw(8) << pair.first 
                 << setw(12) << times.size()
                 << setw(15) << fixed << setprecision(2) << avg_time
                 << setw(15) << fixed << setprecision(2) << min_time
                 << setw(15) << fixed << setprecision(2) << max_time << endl;
        }
    }
    
    void SaveResults(const string& output_dir) {
        // 保存详细执行日志
        ofstream log_file(output_dir + "/execution_log.csv");
        if (log_file.is_open()) {
            log_file << "query_id,execution_time_ms,result_rows,result_size_bytes,from_cache,success,timestamp\n";
            for (const auto& entry : execution_log) {
                log_file << entry.query_id << "," 
                        << entry.execution_time_ms << ","
                        << entry.result_rows << ","
                        << entry.result_size_bytes << ","
                        << (entry.from_cache ? "true" : "false") << ","
                        << (entry.success ? "true" : "false") << ","
                        << entry.timestamp << "\n";
            }
            log_file.close();
            cout << "\n✅ 执行日志已保存到: " << output_dir << "/execution_log.csv" << endl;
        }
        
        // 保存性能摘要
        ofstream summary_file(output_dir + "/performance_summary.txt");
        if (summary_file.is_open()) {
            summary_file << "DuckDB ML缓存系统性能摘要\n";
            summary_file << "================================\n";
            summary_file << "总查询数: " << total_queries << "\n";
            summary_file << "缓存命中数: " << cache_hits << "\n";
            summary_file << "命中率: " << fixed << setprecision(1) 
                        << (total_queries > 0 ? 100.0 * cache_hits / total_queries : 0.0) << "%\n";
            summary_file << "平均响应时间: " << fixed << setprecision(2) 
                        << (total_queries > 0 ? (total_execution_time + total_cache_time) / total_queries : 0.0) << "ms\n";
            summary_file.close();
            cout << "✅ 性能摘要已保存到: " << output_dir << "/performance_summary.txt" << endl;
        }
    }
};

// 加载TPC-H查询
vector<pair<string, string>> LoadTPCHQueries(const string& query_dir) {
    vector<pair<string, string>> queries;
    
    // 预定义的简化TPC-H查询 (适用于示例数据)
    vector<pair<string, string>> sample_queries = {
        {"q01", R"(
            SELECT 
                l_returnflag,
                l_linestatus,
                sum(l_quantity) AS sum_qty,
                sum(l_extendedprice) AS sum_base_price,
                count(*) AS count_order
            FROM lineitem 
            WHERE l_shipdate <= '1998-09-02'
            GROUP BY l_returnflag, l_linestatus
            ORDER BY l_returnflag, l_linestatus
        )"},
        {"q02", R"(
            SELECT 
                l_orderkey,
                sum(l_extendedprice * (1 - l_discount)) AS revenue
            FROM lineitem
            WHERE l_shipdate >= '1994-01-01'
            GROUP BY l_orderkey
            ORDER BY revenue DESC
            LIMIT 10
        )"},
        {"q03", R"(
            SELECT 
                sum(l_extendedprice * l_discount) AS revenue
            FROM lineitem
            WHERE l_shipdate >= '1994-01-01'
                AND l_shipdate < '1997-01-01'
                AND l_discount BETWEEN 0.05 AND 0.07
                AND l_quantity < 24
        )"},
        {"q04", R"(
            SELECT 
                l_returnflag,
                count(*) as count_orders,
                avg(l_quantity) as avg_qty
            FROM lineitem
            GROUP BY l_returnflag
            ORDER BY l_returnflag
        )"},
        {"q05", R"(
            SELECT 
                l_shipmode,
                sum(l_quantity) as total_qty,
                avg(l_extendedprice) as avg_price
            FROM lineitem
            WHERE l_shipdate >= '1995-01-01'
            GROUP BY l_shipmode
            ORDER BY total_qty DESC
        )"}
    };
    
    // 尝试从文件加载，如果失败则使用示例查询
    for (int i = 1; i <= 5; i++) {
        string query_id = "q" + (i < 10 ? "0" : "") + to_string(i);
        string filename = query_dir + "/" + query_id + ".sql";
        
        ifstream file(filename);
        if (file.is_open()) {
            string query((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
            queries.emplace_back(query_id, query);
        }
    }
    
    // 如果没有加载到文件查询，使用示例查询
    if (queries.empty()) {
        cout << "使用内置示例查询..." << endl;
        queries = sample_queries;
    }
    
    return queries;
}

int main() {
    cout << "=== DuckDB 真实API缓存系统测试 ===" << endl;
    
    // 创建结果目录
    system("mkdir -p cache_test/results");
    
    // 初始化测试器
    RealDuckDBCacheTest cache_test;
    
    // 尝试加载TPC-H数据
    bool has_real_data = cache_test.LoadTPCHData("/Users/max/test/tpc/tpch-sf1.db");
    
    // 加载查询
    auto queries = LoadTPCHQueries("/Users/max/src/duckdb/extension/tpch/dbgen/queries");
    cout << "加载了 " << queries.size() << " 个查询" << endl;
    
    if (queries.empty()) {
        cout << "❌ 无法加载任何查询" << endl;
        return 1;
    }
    
    // 生成测试工作负载
    vector<int> workload;
    random_device rd;
    mt19937 gen(rd());
    
    // 热点查询 (前3个查询)
    vector<int> hot_queries = {0, 1, 2};
    uniform_int_distribution<> hot_dis(0, min(3, static_cast<int>(queries.size())) - 1);
    uniform_int_distribution<> cold_dis(0, queries.size() - 1);
    uniform_real_distribution<> prob_dis(0.0, 1.0);
    
    // 生成工作负载 (80/20规则)
    int num_queries = 100;
    for (int i = 0; i < num_queries; i++) {
        if (prob_dis(gen) < 0.8 && !hot_queries.empty()) {
            workload.push_back(hot_queries[hot_dis(gen)]);
        } else {
            workload.push_back(cold_dis(gen));
        }
    }
    
    cout << "生成了 " << workload.size() << " 次查询的工作负载" << endl;
    cout << "开始执行测试...\n" << endl;
    
    // 执行测试
    auto test_start = high_resolution_clock::now();
    
    for (size_t i = 0; i < workload.size(); i++) {
        int query_idx = workload[i];
        const auto& [query_id, query] = queries[query_idx];
        
        cout << "[" << (i + 1) << "/" << workload.size() << "] ";
        cache_test.ExecuteQueryWithCache(query_id, query);
        
        // 模拟查询间隔
        this_thread::sleep_for(milliseconds(50));
    }
    
    auto test_end = high_resolution_clock::now();
    auto total_test_time = duration_cast<milliseconds>(test_end - test_start).count();
    
    cout << "\n测试完成，总耗时: " << total_test_time << "ms" << endl;
    
    // 打印综合统计
    cache_test.PrintComprehensiveStats();
    
    // 保存结果
    cache_test.SaveResults("cache_test/results");
    
    cout << "\n🎉 DuckDB真实API缓存测试完成！" << endl;
    
    return 0;
}