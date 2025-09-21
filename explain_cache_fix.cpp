// 修复 EXPLAIN 语句缓存状态显示的完整解决方案

// 1. 在 QueryInfo 结构体的构造函数中初始化新字段
QueryInfo::QueryInfo() : cache_hit(false), is_explain_query(false) {
}

// 2. 修改 QueryProfiler::SetCacheInfo 方法
void QueryProfiler::SetCacheInfo(bool cache_hit, const string &cache_key) {
	lock_guard<std::mutex> guard(lock);
	query_info.cache_hit = cache_hit;
	query_info.cache_key = cache_key;
	
	// 如果这是一个 EXPLAIN 查询，标记它
	if (is_explain_analyze) {
		query_info.is_explain_query = true;
	}
}

// 3. 修改 ToString 方法以正确显示缓存状态
string QueryProfiler::ToString(ProfilerPrintFormat format) const {
	switch (format) {
		case ProfilerPrintFormat::QUERY_TREE:
		case ProfilerPrintFormat::QUERY_TREE_OPTIMIZER: {
			std::ostringstream str;
			QueryTreeToStream(str);
			
			// 添加缓存信息到输出
			if (query_info.is_explain_query) {
				str << "\n┌─────────────────────────────────────┐\n";
				str << "│ EXPLAIN Query Cache Information     │\n";
				str << "├─────────────────────────────────────┤\n";
				str << "│ Underlying Query Cache Hit: " << (query_info.cache_hit ? "YES" : "NO") << "     │\n";
				if (!query_info.cache_key.empty()) {
					str << "│ Cache Key: " << query_info.cache_key.substr(0, 20) << "...│\n";
				}
				str << "│ Cache Stats:                        │\n";
				str << "│   Total Entries: " << query_info.cache_stats.total_entries << "               │\n";
				str << "│   Total Hits: " << query_info.cache_stats.total_hits << "                  │\n";
				str << "│   Total Misses: " << query_info.cache_stats.total_misses << "                │\n";
				str << "│   Hit Rate: " << std::fixed << std::setprecision(2) << query_info.cache_stats.hit_rate << "%                │\n";
				str << "└─────────────────────────────────────┘\n";
			} else if (query_info.cache_hit) {
				str << "\n┌─────────────────────────────────────┐\n";
				str << "│ Query served from cache             │\n";
				str << "└─────────────────────────────────────┘\n";
			}
			
			return str.str();
		}
		case ProfilerPrintFormat::JSON:
			return ToJSON();
		default:
			throw InternalException("Unknown ProfilerPrintFormat");
	}
}

// 4. 在查询执行时正确设置缓存信息
// 这需要在 ClientContext 或相关的查询执行代码中调用
void SetExplainQueryCacheInfo(QueryProfiler &profiler, bool underlying_cache_hit, const string &cache_key) {
	profiler.SetCacheInfo(underlying_cache_hit, cache_key);
}