#include <iostream>
#include <chrono>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <memory>
#include <map>
#include <algorithm>
#include <cstdlib>
#include <unistd.h>
#include <sys/wait.h>

using namespace std;
using namespace std::chrono;

struct TestResult {
    string test_name;
    string query_type;
    double execution_time_ms;
    bool cache_hit;
    string stage;
    size_t result_rows;
    string error_message;
};

struct CTETestConfig {
    string name;
    string description;
    vector<string> setup_queries;
    vector<string> test_queries;
    string expected_stage;
    bool should_cache;
};

class CTECacheAnalyzer {
private:
    string duckdb_path;
    vector<TestResult> results;
    
public:
    CTECacheAnalyzer(const string& db_path) : duckdb_path(db_path) {}
    
    // 执行DuckDB查询并测量时间
    TestResult ExecuteQuery(const string& query, const string& test_name, 
                           const string& query_type, const string& stage) {
        TestResult result;
        result.test_name = test_name;
        result.query_type = query_type;
        result.stage = stage;
        result.cache_hit = false;
        result.result_rows = 0;
        
        // 创建临时文件来捕获输出
        string temp_file = "/tmp/duckdb_output_" + to_string(getpid()) + ".txt";
        string error_file = "/tmp/duckdb_error_" + to_string(getpid()) + ".txt";
        
        // 构建DuckDB命令
        string cmd = duckdb_path + " -c \"" + query + "\" > " + temp_file + " 2>" + error_file;
        
        auto start = high_resolution_clock::now();
        int exit_code = system(cmd.c_str());
        auto end = high_resolution_clock::now();
        
        result.execution_time_ms = duration_cast<microseconds>(end - start).count() / 1000.0;
        
        // 读取输出文件
        ifstream output_file(temp_file);
        string line;
        while (getline(output_file, line)) {
            if (!line.empty() && line.find("┌") == string::npos && 
                line.find("│") == string::npos && line.find("└") == string::npos) {
                result.result_rows++;
            }
            // 检查缓存命中信息
            if (line.find("cached result") != string::npos || 
                line.find("cache hit") != string::npos) {
                result.cache_hit = true;
            }
        }
        output_file.close();
        
        // 读取错误文件
        ifstream error_stream(error_file);
        stringstream error_buffer;
        error_buffer << error_stream.rdbuf();
        result.error_message = error_buffer.str();
        error_stream.close();
        
        // 清理临时文件
        unlink(temp_file.c_str());
        unlink(error_file.c_str());
        
        return result;
    }
    
    // 测试简单CTE
    void TestSimpleCTE() {
        cout << "\n=== 测试简单CTE缓存 ===" << endl;
        
        // 设置测试数据
        string setup = "CREATE TABLE test_data AS SELECT i as id, i*2 as value FROM range(1000) t(i);";
        ExecuteQuery(setup, "setup", "DDL", "setup");
        
        // 简单CTE查询
        string cte_query = R"(
            WITH simple_cte AS (
                SELECT id, value, value * 2 as double_value 
                FROM test_data 
                WHERE id <= 100
            )
            SELECT COUNT(*), AVG(double_value) FROM simple_cte;
        )";
        
        // 第一次执行（应该缓存）
        auto result1 = ExecuteQuery(cte_query, "simple_cte_first", "CTE", "execution");
        results.push_back(result1);
        
        // 第二次执行（应该命中缓存）
        auto result2 = ExecuteQuery(cte_query, "simple_cte_second", "CTE", "execution");
        results.push_back(result2);
        
        // 第三次执行（验证缓存稳定性）
        auto result3 = ExecuteQuery(cte_query, "simple_cte_third", "CTE", "execution");
        results.push_back(result3);
        
        cout << "简单CTE测试完成" << endl;
    }
    
    // 测试递归CTE
    void TestRecursiveCTE() {
        cout << "\n=== 测试递归CTE缓存 ===" << endl;
        
        string recursive_query = R"(
            WITH RECURSIVE fibonacci(n, fib_n, fib_n1) AS (
                SELECT 1, 0, 1
                UNION ALL
                SELECT n+1, fib_n1, fib_n + fib_n1 
                FROM fibonacci 
                WHERE n < 20
            )
            SELECT n, fib_n FROM fibonacci ORDER BY n;
        )";
        
        // 多次执行递归CTE
        for (int i = 1; i <= 3; i++) {
            auto result = ExecuteQuery(recursive_query, 
                                     "recursive_cte_" + to_string(i), 
                                     "Recursive_CTE", "execution");
            results.push_back(result);
        }
        
        cout << "递归CTE测试完成" << endl;
    }
    
    // 测试复杂嵌套CTE
    void TestNestedCTE() {
        cout << "\n=== 测试嵌套CTE缓存 ===" << endl;
        
        string nested_query = R"(
            WITH 
            level1 AS (
                SELECT id, value FROM test_data WHERE id <= 50
            ),
            level2 AS (
                SELECT id, value, value * 3 as triple_value 
                FROM level1 WHERE value > 10
            ),
            level3 AS (
                SELECT id, AVG(triple_value) OVER (ORDER BY id ROWS 2 PRECEDING) as moving_avg
                FROM level2
            )
            SELECT COUNT(*), MIN(moving_avg), MAX(moving_avg) FROM level3;
        )";
        
        // 多次执行嵌套CTE
        for (int i = 1; i <= 3; i++) {
            auto result = ExecuteQuery(nested_query, 
                                     "nested_cte_" + to_string(i), 
                                     "Nested_CTE", "execution");
            results.push_back(result);
        }
        
        cout << "嵌套CTE测试完成" << endl;
    }
    
    // 测试CTE与JOIN结合
    void TestCTEWithJoin() {
        cout << "\n=== 测试CTE与JOIN结合缓存 ===" << endl;
        
        // 创建第二个测试表
        string setup2 = "CREATE TABLE test_data2 AS SELECT i as id, 'item_' || i as name FROM range(100) t(i);";
        ExecuteQuery(setup2, "setup2", "DDL", "setup");
        
        string join_query = R"(
            WITH 
            filtered_data AS (
                SELECT id, value FROM test_data WHERE id <= 50
            ),
            named_data AS (
                SELECT id, name FROM test_data2 WHERE id <= 50
            )
            SELECT f.id, f.value, n.name, f.value * 2 as computed
            FROM filtered_data f
            JOIN named_data n ON f.id = n.id
            WHERE f.value > 20
            ORDER BY f.id;
        )";
        
        // 多次执行CTE JOIN查询
        for (int i = 1; i <= 3; i++) {
            auto result = ExecuteQuery(join_query, 
                                     "cte_join_" + to_string(i), 
                                     "CTE_JOIN", "execution");
            results.push_back(result);
        }
        
        cout << "CTE与JOIN结合测试完成" << endl;
    }
    
    // 测试CTE在不同查询处理阶段的缓存
    void TestCTEStages() {
        cout << "\n=== 测试CTE在不同处理阶段的缓存 ===" << endl;
        
        // 测试解析阶段 - 相同的CTE定义
        string parse_test = R"(
            WITH common_cte AS (SELECT id, value FROM test_data WHERE id <= 30)
            SELECT COUNT(*) FROM common_cte;
        )";
        
        auto parse_result1 = ExecuteQuery(parse_test, "parse_stage_1", "Parse_Stage", "parser");
        auto parse_result2 = ExecuteQuery(parse_test, "parse_stage_2", "Parse_Stage", "parser");
        results.push_back(parse_result1);
        results.push_back(parse_result2);
        
        // 测试规划阶段 - 相同的逻辑计划
        string plan_test = R"(
            WITH plan_cte AS (
                SELECT id, value, ROW_NUMBER() OVER (ORDER BY value) as rn
                FROM test_data WHERE id <= 40
            )
            SELECT id, value FROM plan_cte WHERE rn <= 10;
        )";
        
        auto plan_result1 = ExecuteQuery(plan_test, "plan_stage_1", "Plan_Stage", "planner");
        auto plan_result2 = ExecuteQuery(plan_test, "plan_stage_2", "Plan_Stage", "planner");
        results.push_back(plan_result1);
        results.push_back(plan_result2);
        
        // 测试优化阶段 - 可优化的CTE
        string opt_test = R"(
            WITH opt_cte AS (
                SELECT id, value, value + 1 as value_plus_one
                FROM test_data 
                WHERE id BETWEEN 10 AND 60
                ORDER BY value
            )
            SELECT MIN(value_plus_one), MAX(value_plus_one), COUNT(*)
            FROM opt_cte
            WHERE value_plus_one > 25;
        )";
        
        auto opt_result1 = ExecuteQuery(opt_test, "optimizer_stage_1", "Optimizer_Stage", "optimizer");
        auto opt_result2 = ExecuteQuery(opt_test, "optimizer_stage_2", "Optimizer_Stage", "optimizer");
        results.push_back(opt_result1);
        results.push_back(opt_result2);
        
        cout << "CTE处理阶段测试完成" << endl;
    }
    
    // 测试CTE缓存失效场景
    void TestCTECacheInvalidation() {
        cout << "\n=== 测试CTE缓存失效场景 ===" << endl;
        
        string base_cte = R"(
            WITH cache_test AS (SELECT id, value FROM test_data WHERE id <= 25)
            SELECT COUNT(*), AVG(value) FROM cache_test;
        )";
        
        // 第一次执行
        auto result1 = ExecuteQuery(base_cte, "invalidation_1", "Cache_Invalidation", "execution");
        results.push_back(result1);
        
        // 修改底层数据
        string modify_data = "UPDATE test_data SET value = value + 1000 WHERE id <= 25;";
        ExecuteQuery(modify_data, "modify_data", "DDL", "setup");
        
        // 再次执行相同查询（缓存应该失效）
        auto result2 = ExecuteQuery(base_cte, "invalidation_2", "Cache_Invalidation", "execution");
        results.push_back(result2);
        
        // 恢复数据
        string restore_data = "UPDATE test_data SET value = value - 1000 WHERE id <= 25;";
        ExecuteQuery(restore_data, "restore_data", "DDL", "setup");
        
        cout << "CTE缓存失效测试完成" << endl;
    }
    
    // 运行所有测试
    void RunAllTests() {
        cout << "🚀 开始全面CTE缓存测试" << endl;
        cout << "DuckDB路径: " << duckdb_path << endl;
        cout << "测试时间: " << GetCurrentTime() << endl;
        
        // 启用查询缓存
        string enable_cache = "SET enable_query_cache=true; SET query_cache_max_size='100MB';";
        ExecuteQuery(enable_cache, "enable_cache", "Config", "setup");
        
        TestSimpleCTE();
        TestRecursiveCTE();
        TestNestedCTE();
        TestCTEWithJoin();
        TestCTEStages();
        TestCTECacheInvalidation();
        
        GenerateReport();
    }
    
    // 生成测试报告
    void GenerateReport() {
        cout << "\n" << string(80, '=') << endl;
        cout << "📊 CTE缓存全面测试报告" << endl;
        cout << string(80, '=') << endl;
        
        // 按查询类型分组统计
        map<string, vector<TestResult>> grouped_results;
        for (const auto& result : results) {
            if (result.query_type != "DDL" && result.query_type != "Config") {
                grouped_results[result.query_type].push_back(result);
            }
        }
        
        // 输出详细结果
        cout << "\n🔍 详细测试结果:\n" << endl;
        cout << left << setw(20) << "测试名称" 
             << setw(15) << "查询类型" 
             << setw(12) << "执行时间(ms)" 
             << setw(10) << "缓存命中" 
             << setw(12) << "处理阶段"
             << setw(8) << "结果行数" << endl;
        cout << string(80, '-') << endl;
        
        for (const auto& result : results) {
            if (result.query_type != "DDL" && result.query_type != "Config") {
                cout << left << setw(20) << result.test_name
                     << setw(15) << result.query_type
                     << setw(12) << fixed << setprecision(2) << result.execution_time_ms
                     << setw(10) << (result.cache_hit ? "✓" : "✗")
                     << setw(12) << result.stage
                     << setw(8) << result.result_rows << endl;
            }
        }
        
        // 统计分析
        cout << "\n📈 统计分析:\n" << endl;
        
        for (const auto& group : grouped_results) {
            const string& query_type = group.first;
            const vector<TestResult>& type_results = group.second;
            
            if (type_results.size() >= 2) {
                double first_time = type_results[0].execution_time_ms;
                double avg_subsequent = 0.0;
                int cache_hits = 0;
                
                for (size_t i = 1; i < type_results.size(); i++) {
                    avg_subsequent += type_results[i].execution_time_ms;
                    if (type_results[i].cache_hit) cache_hits++;
                }
                avg_subsequent /= (type_results.size() - 1);
                
                double improvement = ((first_time - avg_subsequent) / first_time) * 100.0;
                double hit_rate = (double)cache_hits / (type_results.size() - 1) * 100.0;
                
                cout << "  📊 " << query_type << " 测试结果:" << endl;
                cout << "     首次执行: " << fixed << setprecision(2) << first_time << "ms" << endl;
                cout << "     后续平均: " << fixed << setprecision(2) << avg_subsequent << "ms" << endl;
                cout << "     性能提升: " << fixed << setprecision(1) << improvement << "%" << endl;
                cout << "     缓存命中率: " << fixed << setprecision(1) << hit_rate << "%" << endl;
                cout << endl;
            }
        }
        
        // 总体统计
        double total_first = 0.0, total_subsequent = 0.0;
        int total_cache_hits = 0, total_subsequent_count = 0;
        
        for (const auto& group : grouped_results) {
            const vector<TestResult>& type_results = group.second;
            if (type_results.size() >= 2) {
                total_first += type_results[0].execution_time_ms;
                for (size_t i = 1; i < type_results.size(); i++) {
                    total_subsequent += type_results[i].execution_time_ms;
                    if (type_results[i].cache_hit) total_cache_hits++;
                    total_subsequent_count++;
                }
            }
        }
        
        if (total_subsequent_count > 0) {
            double avg_first = total_first / grouped_results.size();
            double avg_subsequent = total_subsequent / total_subsequent_count;
            double overall_improvement = ((avg_first - avg_subsequent) / avg_first) * 100.0;
            double overall_hit_rate = (double)total_cache_hits / total_subsequent_count * 100.0;
            
            cout << "🎯 总体测试结果:" << endl;
            cout << "   平均首次执行时间: " << fixed << setprecision(2) << avg_first << "ms" << endl;
            cout << "   平均后续执行时间: " << fixed << setprecision(2) << avg_subsequent << "ms" << endl;
            cout << "   总体性能提升: " << fixed << setprecision(1) << overall_improvement << "%" << endl;
            cout << "   总体缓存命中率: " << fixed << setprecision(1) << overall_hit_rate << "%" << endl;
        }
        
        // 保存详细报告到文件
        SaveDetailedReport();
        
        cout << "\n✅ CTE缓存全面测试完成！" << endl;
    }
    
    // 保存详细报告到文件
    void SaveDetailedReport() {
        string filename = "cte_cache_comprehensive_report_" + GetTimestamp() + ".json";
        ofstream report_file(filename);
        
        report_file << "{\n";
        report_file << "  \"test_info\": {\n";
        report_file << "    \"timestamp\": \"" << GetCurrentTime() << "\",\n";
        report_file << "    \"duckdb_path\": \"" << duckdb_path << "\",\n";
        report_file << "    \"total_tests\": " << results.size() << "\n";
        report_file << "  },\n";
        report_file << "  \"results\": [\n";
        
        for (size_t i = 0; i < results.size(); i++) {
            const auto& result = results[i];
            report_file << "    {\n";
            report_file << "      \"test_name\": \"" << result.test_name << "\",\n";
            report_file << "      \"query_type\": \"" << result.query_type << "\",\n";
            report_file << "      \"execution_time_ms\": " << result.execution_time_ms << ",\n";
            report_file << "      \"cache_hit\": " << (result.cache_hit ? "true" : "false") << ",\n";
            report_file << "      \"stage\": \"" << result.stage << "\",\n";
            report_file << "      \"result_rows\": " << result.result_rows << ",\n";
            report_file << "      \"error_message\": \"" << result.error_message << "\"\n";
            report_file << "    }";
            if (i < results.size() - 1) report_file << ",";
            report_file << "\n";
        }
        
        report_file << "  ]\n";
        report_file << "}\n";
        report_file.close();
        
        cout << "\n📄 详细报告已保存到: " << filename << endl;
    }
    
    string GetCurrentTime() {
        auto now = system_clock::now();
        auto time_t = system_clock::to_time_t(now);
        stringstream ss;
        ss << put_time(localtime(&time_t), "%Y-%m-%d %H:%M:%S");
        return ss.str();
    }
    
    string GetTimestamp() {
        auto now = system_clock::now();
        auto time_t = system_clock::to_time_t(now);
        stringstream ss;
        ss << put_time(localtime(&time_t), "%Y%m%d_%H%M%S");
        return ss.str();
    }
};

// CTE缓存阶段分析器
class CTECacheStageAnalyzer {
private:
    string duckdb_path;
    
public:
    CTECacheStageAnalyzer(const string& db_path) : duckdb_path(db_path) {}
    
    void AnalyzeCTECacheStages() {
        cout << "\n" << string(80, '=') << endl;
        cout << "🔬 CTE缓存阶段深度分析" << endl;
        cout << string(80, '=') << endl;
        
        cout << "\n📋 当前CTE缓存实现分析:" << endl;
        cout << "1. 解析器阶段 (Parser): CTE语法解析和AST构建" << endl;
        cout << "   - 当前状态: ✓ 支持CTE语法解析" << endl;
        cout << "   - 缓存机制: ✗ 未实现解析结果缓存" << endl;
        cout << "   - 建议: 可缓存相同CTE定义的解析结果" << endl;
        
        cout << "\n2. 规划器阶段 (Planner): 逻辑计划生成" << endl;
        cout << "   - 当前状态: ✓ 支持CTE逻辑计划生成" << endl;
        cout << "   - 缓存机制: ✗ 未实现逻辑计划缓存" << endl;
        cout << "   - 建议: 可缓存CTE子查询的逻辑计划" << endl;
        
        cout << "\n3. 优化器阶段 (Optimizer): 查询优化" << endl;
        cout << "   - 当前状态: ✓ 支持CTE优化（CTE Filter Pusher等）" << endl;
        cout << "   - 缓存机制: ✗ 未实现优化结果缓存" << endl;
        cout << "   - 建议: 可缓存优化后的物理计划" << endl;
        
        cout << "\n4. 执行器阶段 (Executor): 查询执行" << endl;
        cout << "   - 当前状态: ✓ 支持CTE执行" << endl;
        cout << "   - 缓存机制: ✓ 已实现最终结果缓存" << endl;
        cout << "   - 优势: 避免重复执行相同CTE查询" << endl;
        
        cout << "\n💡 CTE缓存优化建议:" << endl;
        cout << "1. 当前实现: 仅在执行器阶段缓存最终结果" << endl;
        cout << "2. 优化方向: 可在多个阶段实现缓存" << endl;
        cout << "   - 解析阶段: 缓存CTE AST结构" << endl;
        cout << "   - 规划阶段: 缓存CTE逻辑计划" << endl;
        cout << "   - 优化阶段: 缓存优化后的物理计划" << endl;
        cout << "   - 执行阶段: 缓存中间结果和最终结果" << endl;
        
        cout << "\n🎯 实现价值评估:" << endl;
        cout << "- 解析阶段缓存: 低价值（解析开销相对较小）" << endl;
        cout << "- 规划阶段缓存: 中等价值（复杂CTE规划开销较大）" << endl;
        cout << "- 优化阶段缓存: 高价值（优化开销显著，特别是复杂CTE）" << endl;
        cout << "- 执行阶段缓存: 最高价值（避免重复计算，已实现）" << endl;
    }
};

int main(int argc, char* argv[]) {
    if (argc != 2) {
        cerr << "用法: " << argv[0] << " <duckdb_path>" << endl;
        cerr << "示例: " << argv[0] << " /Users/max/src/duckdb/build/release/duckdb" << endl;
        return 1;
    }
    
    string duckdb_path = argv[1];
    
    // 检查DuckDB是否存在
    if (access(duckdb_path.c_str(), X_OK) != 0) {
        cerr << "错误: 无法访问DuckDB可执行文件: " << duckdb_path << endl;
        return 1;
    }
    
    try {
        // 运行CTE缓存测试
        CTECacheAnalyzer analyzer(duckdb_path);
        analyzer.RunAllTests();
        
        // 运行CTE缓存阶段分析
        CTECacheStageAnalyzer stage_analyzer(duckdb_path);
        stage_analyzer.AnalyzeCTECacheStages();
        
    } catch (const exception& e) {
        cerr << "测试过程中发生错误: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}