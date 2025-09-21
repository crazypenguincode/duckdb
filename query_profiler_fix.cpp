// 在 QueryProfiler 类中添加以下方法实现

void QueryProfiler::SetExplainCacheInfo(bool cache_hit, const string &cache_key) {
	lock_guard<std::mutex> guard(lock);
	query_info.cache_hit = cache_hit;
	query_info.cache_key = cache_key;
	query_info.is_explain_query = true;
}

// 修改 ToJSON 方法以正确显示 EXPLAIN 查询的缓存状态
string QueryProfiler::ToJSON() const {
	std::ostringstream str;
	str << "{\n";
	
	// ... 其他 JSON 输出代码 ...
	
	// 修改缓存信息输出部分
	if (query_info.is_explain_query) {
		str << "  \"cache_info\": {\n";
		str << "    \"explain_query\": true,\n";
		str << "    \"underlying_query_cache_hit\": " << (query_info.cache_hit ? "true" : "false") << ",\n";
		if (!query_info.cache_key.empty()) {
			str << "    \"cache_key\": \"" << JSONSanitize(query_info.cache_key) << "\",\n";
		}
		str << "    \"cache_stats\": {\n";
		str << "      \"total_entries\": " << query_info.cache_stats.total_entries << ",\n";
		str << "      \"total_hits\": " << query_info.cache_stats.total_hits << ",\n";
		str << "      \"total_misses\": " << query_info.cache_stats.total_misses << ",\n";
		str << "      \"hit_rate\": " << query_info.cache_stats.hit_rate << "\n";
		str << "    }\n";
		str << "  },\n";
	} else {
		// 原有的缓存信息输出逻辑
		str << "  \"cache_hit\": " << (query_info.cache_hit ? "true" : "false") << ",\n";
		if (!query_info.cache_key.empty()) {
			str << "  \"cache_key\": \"" << JSONSanitize(query_info.cache_key) << "\",\n";
		}
	}
	
	// ... 其他 JSON 输出代码 ...
	
	str << "}\n";
	return str.str();
}