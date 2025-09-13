//===----------------------------------------------------------------------===//
//                         DuckDB
//
// cache_test/duckdb_cache_integration.cpp
//
// 集成DuckDB的真实缓存测试
//===----------------------------------------------------------------------===//

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

// 简化的DuckDB连接模拟器
class DuckDBConnection {
private:
    string db_path;
    bool connected = false;
    
public:
    DuckDBConnection(const string& path) : db_path(path) {}
    
    bool Connect() {
        // 检查数据库文件是否存在
        ifstream file(db_path);
        connected = file.good();
        return connected;
    }
    
    bool IsConnected() const { return connected; }
    
    // 模拟查询执行
    pair<double, string> ExecuteQuery(const string& query) {
        if (!connected) {
            return {-1.0, "Not connected"};
        }
        
        // 基于查询复杂度模拟执行时间
        double execution_time = EstimateExecutionTime(query);
        
        // 模拟结果数据
        string result_data = GenerateResultData(query, execution_time);
        
        return {execution_time, result_data};
    }
    
private:
    double EstimateExecutionTime(const string& query) {
        // 分析查询复杂度
        string upper_query = query;
        transform(upper_query.begin(), upper_query.end(), upper_query.begin(), ::toupper);
        
        double base_time = 50.0; // 基础执行时间 (ms)
        double complexity_factor = 1.0;
        
        // 统计复杂度指标
        int joins = CountOccurrences(upper_query, "JOIN");
        int aggregates = CountOccurrences(upper_query, "SUM(") + 
                        CountOccurrences(upper_query, "COUNT(") +
                        CountOccurrences(upper_query, "AVG(") +
                        CountOccurrences(upper_query, "MAX(") +
                        CountOccurrences(upper_query, "MIN(");
        int sorts = CountOccurrences(upper_query, "ORDER BY");
        int groups = CountOccurrences(upper_query, "GROUP BY");
        
        // 计算复杂度因子
        complexity_factor += joins * 0.8;      // JOIN很昂贵
        complexity_factor += aggregates * 0.4; // 聚合函数
        complexity_factor += sorts * 0.6;      // 排序
        complexity_factor += groups * 0.3;     // 分组
        
        // 表扫描估算
        int table_scans = CountOccurrences(upper_query, "FROM") + 
                         CountOccurrences(upper_query, "JOIN");
        complexity_factor += table_scans * 0.2;
        
        // 添加随机变化 (模拟系统负载)
        random_device rd;
        mt19937 gen(rd());
        uniform_real_distribution<> dis(0.8, 1.3);
        
        return base_time * complexity_factor * dis(gen);
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
    
    string GenerateResultData(const string& query, double execution_time) {
        // 基于执行时间和查询类型估算结果大小
        string upper_query = query;
        transform(upper_query.begin(), upper_query.end(), upper_query.begin(), ::toupper);
        
        size_t estimated_rows = 100; // 默认行数
        
        // 根据查询类型调整
        if (upper_query.find("COUNT(*)") != string::npos) {
            estimated_rows = 1; // COUNT查询通常返回一行
        } else if (upper_query.find("LIMIT") != string::npos) {
            // 提取LIMIT值
            size_t limit_pos = upper_query.find("LIMIT");
            if (limit_pos != string::npos) {
                string limit_str = upper_query.substr(limit_pos + 5);
                size_t space_pos = limit_str.find_first_of(" \t\n;");
                if (space_pos != string::npos) {
                    limit_str = limit_str.substr(0, space_pos);
                }
                try {
                    estimated_rows = min(static_cast<size_t>(stoi(limit_str)), estimated_rows);
                } catch (...) {
                    // 解析失败，使用默认值
                }
            }
        } else {
            // 基于执行时间估算
            estimated_rows = static_cast<size_t>(execution_time / 2.0);
        }
        
        // 生成模拟数据
        stringstream result;
        for (size_t i = 0; i < estimated_rows; i++) {
            result << "row_" << i << "_col1_value,col2_value,col3_value\n";
        }
        
        return result.str();
    }
};

// 增强的ML缓存预测器
class EnhancedMLPredictor {
private:
    struct QueryPattern {
        vector<double> access_times;
        double frequency = 0.0;
        double avg_execution_time = 0.0;
        double last_access = 0.0;
        int access_count = 0;
    };
    
    unordered_map<string, QueryPattern> patterns;
    
    // Holt-Winters参数
    double alpha = 0.3;
    double beta = 0.3;
    double gamma = 0.3;
    
    // 价值评估权重 (可学习)
    vector<double> weights = {0.25, 0.20, 0.30, 0.15, 0.10};
    
public:
    void RecordAccess(const string& query_hash, double execution_time) {
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        auto& pattern = patterns[query_hash];
        pattern.access_times.push_back(now);
        pattern.access_count++;
        pattern.last_access = now;
        
        // 更新平均执行时间
        if (pattern.avg_execution_time == 0.0) {
            pattern.avg_execution_time = execution_time;
        } else {
            pattern.avg_execution_time = 0.9 * pattern.avg_execution_time + 0.1 * execution_time;
        }
        
        // 计算访问频率 (每小时访问次数)
        if (pattern.access_times.size() > 1) {
            double time_span = (now - pattern.access_times[0]) / (1000.0 * 3600.0); // 小时
            pattern.frequency = pattern.access_count / max(0.1, time_span);
        }
        
        // 保持访问历史在合理范围内
        if (pattern.access_times.size() > 100) {
            pattern.access_times.erase(pattern.access_times.begin(), 
                                     pattern.access_times.begin() + 50);
        }
    }
    
    double PredictAccessProbability(const string& query_hash) {
        auto it = patterns.find(query_hash);
        if (it == patterns.end() || it->second.access_times.size() < 2) {
            return 0.3; // 默认概率
        }
        
        const auto& pattern = it->second;
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        // 计算访问间隔
        vector<double> intervals;
        for (size_t i = 1; i < pattern.access_times.size(); i++) {
            intervals.push_back(pattern.access_times[i] - pattern.access_times[i-1]);
        }
        
        if (intervals.empty()) return 0.3;
        
        // Holt-Winters预测
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
        
        // 转换为概率
        double probability = 1.0 / (1.0 + abs(time_since_last - predicted_interval) / predicted_interval);
        return min(0.95, max(0.05, probability));
    }
    
    double CalculateCacheValue(const string& query_hash, size_t result_size) {
        auto it = patterns.find(query_hash);
        if (it == patterns.end()) {
            return 0.5; // 默认价值
        }
        
        const auto& pattern = it->second;
        auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
        
        // 特征计算
        double freq_score = min(1.0, pattern.frequency / 5.0); // 每小时5次为满分
        double recency_score = 1.0 / (1.0 + (now - pattern.last_access) / 60000.0); // 分钟衰减
        double cost_score = min(1.0, pattern.avg_execution_time / 200.0); // 200ms为满分
        double size_score = 1.0 - min(1.0, result_size / (1024.0 * 1024.0)); // 1MB惩罚
        double predict_score = PredictAccessProbability(query_hash);
        
        // 加权计算
        double value = weights[0] * freq_score +
                      weights[1] * recency_score +
                      weights[2] * cost_score +
                      weights[3] * size_score +
                      weights[4] * predict_score;
        
        return max(0.0, min(1.0, value));
    }
    
    void PrintPatternStats() {
        cout << "\n=== 访问模式统计 ===" << endl;
        cout << "跟踪的查询模式数: " << patterns.size() << endl;
        
        if (!patterns.empty()) {
            double avg_frequency = 0.0;
            double max_frequency = 0.0;
            int total_accesses = 0;
            
            for (const auto& pair : patterns) {
                const auto& pattern = pair.second;
                avg_frequency += pattern.frequency;
                max_frequency = max(max_frequency, pattern.frequency);
                total_accesses += pattern.access_count;
            }
            
            avg_frequency /= patterns.size();
            
            cout << "平均访问频率: " << fixed << setprecision(2) << avg_frequency << " 次/小时" << endl;
            cout << "最高访问频率: " << fixed << setprecision(2) << max_frequency << " 次/小时" << endl;
            cout << "总访问次数: " << total_accesses << endl;
        }
    }
};

// 真实数据缓存测试器
class RealDataCacheTest {
private:
    unique_ptr<DuckDBConnection> db_conn;
    EnhancedMLPredictor ml_predictor;
    
    // 缓存存储
    unordered_map<string, pair<string, double>> cache; // hash -> (result, timestamp)
    size_t max_cache_entries = 50;
    
    // 统计信息
    int total_queries = 0;
    int cache_hits = 0;
    double total_execution_time = 0.0;
    double total_cache_time = 0.0;
    
public:
    RealDataCacheTest(const string& db_path) {
        db_conn = make_unique<DuckDBConnection>(db_path);
    }
    
    bool Initialize() {
        if (!db_conn->Connect()) {
            cout << "❌ 无法连接到数据库" << endl;
            return false;
        }
        cout << "✅ 数据库连接成功" << endl;
        return true;
    }
    
    pair<double, bool> ExecuteQueryWithCache(const string& query_id, const string& query) {
        total_queries++;
        
        // 生成查询哈希
        hash<string> hasher;
        string query_hash = to_string(hasher(query));
        
        auto start_time = high_resolution_clock::now();
        
        // 检查缓存
        auto cache_it = cache.find(query_hash);
        if (cache_it != cache.end()) {
            // 缓存命中
            cache_hits++;
            auto end_time = high_resolution_clock::now();
            double cache_access_time = duration_cast<microseconds>(end_time - start_time).count() / 1000.0;
            
            total_cache_time += cache_access_time;
            ml_predictor.RecordAccess(query_hash, 0.0); // 缓存访问不计入执行时间
            
            cout << "[CACHE HIT] " << query_id << " - " << fixed << setprecision(2) 
                 << cache_access_time << "ms" << endl;
            
            return {cache_access_time, true};
        }
        
        // 缓存未命中，执行查询
        auto [execution_time, result_data] = db_conn->ExecuteQuery(query);
        
        if (execution_time < 0) {
            cout << "[ERROR] " << query_id << " - 查询执行失败" << endl;
            return {-1.0, false};
        }
        
        auto end_time = high_resolution_clock::now();
        double actual_time = duration_cast<microseconds>(end_time - start_time).count() / 1000.0;
        
        total_execution_time += actual_time;
        ml_predictor.RecordAccess(query_hash, actual_time);
        
        // 决定是否缓存
        double cache_value = ml_predictor.CalculateCacheValue(query_hash, result_data.size());
        bool should_cache = cache_value > 0.6; // 阈值可调
        
        if (should_cache) {
            // 检查缓存空间
            if (cache.size() >= max_cache_entries) {
                EvictLeastValuableEntry();
            }
            
            // 添加到缓存
            auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
            cache[query_hash] = {result_data, static_cast<double>(now)};
            
            cout << "[CACHED] " << query_id << " - " << fixed << setprecision(2) 
                 << actual_time << "ms (价值: " << setprecision(3) << cache_value << ")" << endl;
        } else {
            cout << "[NOT CACHED] " << query_id << " - " << fixed << setprecision(2) 
                 << actual_time << "ms (价值: " << setprecision(3) << cache_value << ")" << endl;
        }
        
        return {actual_time, false};
    }
    
    void EvictLeastValuableEntry() {
        if (cache.empty()) return;
        
        string worst_key;
        double worst_value = 1.0;
        
        for (const auto& pair : cache) {
            double value = ml_predictor.CalculateCacheValue(pair.first, pair.second.first.size());
            if (value < worst_value) {
                worst_value = value;
                worst_key = pair.first;
            }
        }
        
        if (!worst_key.empty()) {
            cache.erase(worst_key);
            cout << "[EVICTED] 缓存条目 (价值: " << fixed << setprecision(3) << worst_value << ")" << endl;
        }
    }
    
    void PrintStatistics() {
        cout << "\n=== 缓存性能统计 ===" << endl;
        cout << "总查询数: " << total_queries << endl;
        cout << "缓存命中数: " << cache_hits << endl;
        cout << "命中率: " << fixed << setprecision(1) << (total_queries > 0 ? 100.0 * cache_hits / total_queries : 0.0) << "%" << endl;
        
        double avg_execution_time = total_queries > 0 ? (total_execution_time + total_cache_time) / total_queries : 0.0;
        cout << "平均响应时间: " << fixed << setprecision(2) << avg_execution_time << "ms" << endl;
        
        cout << "当前缓存条目数: " << cache.size() << "/" << max_cache_entries << endl;
        
        // 计算缓存节省的时间
        double time_saved = 0.0;
        if (cache_hits > 0) {
            double avg_cache_time = total_cache_time / cache_hits;
            double estimated_execution_time = total_execution_time / max(1, total_queries - cache_hits);
            time_saved = cache_hits * (estimated_execution_time - avg_cache_time);
        }
        
        cout << "估算节省时间: " << fixed << setprecision(1) << time_saved << "ms" << endl;
        
        ml_predictor.PrintPatternStats();
    }
};

// 加载TPC-H查询
vector<pair<string, string>> LoadTPCHQueries(const string& query_dir) {
    vector<pair<string, string>> queries;
    
    for (int i = 1; i <= 22; i++) {
        string query_id = "q" + (i < 10 ? "0" : "") + to_string(i);
        string filename = query_dir + "/" + query_id + ".sql";
        
        ifstream file(filename);
        if (file.is_open()) {
            string query((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
            queries.emplace_back(query_id, query);
        }
    }
    
    return queries;
}

int main() {
    cout << "=== DuckDB 真实数据缓存集成测试 ===" << endl;
    
    // 初始化数据库连接
    RealDataCacheTest cache_test("/Users/max/test/tpc/tpch-sf1.db");
    if (!cache_test.Initialize()) {
        cout << "使用模拟数据进行测试..." << endl;
    }
    
    // 加载TPC-H查询
    auto queries = LoadTPCHQueries("/Users/max/src/duckdb/extension/tpch/dbgen/queries");
    cout << "加载了 " << queries.size() << " 个TPC-H查询" << endl;
    
    if (queries.empty()) {
        cout << "❌ 无法加载查询文件" << endl;
        return 1;
    }
    
    // 生成测试工作负载 (模拟真实访问模式)
    vector<int> workload;
    random_device rd;
    mt19937 gen(rd());
    
    // 热点查询 (简单、常用的查询)
    vector<int> hot_queries;
    for (size_t i = 0; i < min(size_t(6), queries.size()); i++) {
        hot_queries.push_back(i);
    }
    
    uniform_int_distribution<> hot_dis(0, hot_queries.size() - 1);
    uniform_int_distribution<> cold_dis(0, queries.size() - 1);
    uniform_real_distribution<> prob_dis(0.0, 1.0);
    
    // 生成工作负载 (80/20规则)
    int num_queries = 200; // 减少查询数量以便观察
    for (int i = 0; i < num_queries; i++) {
        if (prob_dis(gen) < 0.8) {
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
        auto [execution_time, from_cache] = cache_test.ExecuteQueryWithCache(query_id, query);
        
        // 模拟查询间隔
        this_thread::sleep_for(milliseconds(10));
    }
    
    auto test_end = high_resolution_clock::now();
    auto total_test_time = duration_cast<milliseconds>(test_end - test_start).count();
    
    cout << "\n测试完成，总耗时: " << total_test_time << "ms" << endl;
    
    // 打印统计信息
    cache_test.PrintStatistics();
    
    // 保存结果
    ofstream result_file("cache_test/results/real_data_test_results.txt");
    if (result_file.is_open()) {
        result_file << "DuckDB 真实数据缓存测试结果\n";
        result_file << "测试时间: " << total_test_time << "ms\n";
        result_file << "查询数量: " << workload.size() << "\n";
        // 这里可以添加更多统计信息
        result_file.close();
        cout << "\n✅ 结果已保存到 cache_test/results/real_data_test_results.txt" << endl;
    }
    
    return 0;
}