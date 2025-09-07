#include "duckdb/function/table/system_functions.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/query_cache.hpp"

namespace duckdb {

struct PragmaQueryCacheStatsData : public GlobalTableFunctionState {
	PragmaQueryCacheStatsData() : finished(false) {}
	bool finished;
};

static unique_ptr<FunctionData> PragmaQueryCacheStatsBind(ClientContext &context, TableFunctionBindInput &input,
                                                         vector<LogicalType> &return_types, vector<string> &names) {
	names.emplace_back("total_entries");
	return_types.emplace_back(LogicalType::BIGINT);

	names.emplace_back("total_hits");
	return_types.emplace_back(LogicalType::BIGINT);

	names.emplace_back("total_misses");
	return_types.emplace_back(LogicalType::BIGINT);

	names.emplace_back("hit_rate");
	return_types.emplace_back(LogicalType::DOUBLE);

	names.emplace_back("memory_usage_bytes");
	return_types.emplace_back(LogicalType::BIGINT);

	names.emplace_back("false_positive_rate");
	return_types.emplace_back(LogicalType::DOUBLE);

	names.emplace_back("enabled");
	return_types.emplace_back(LogicalType::BOOLEAN);

	return nullptr;
}

static unique_ptr<GlobalTableFunctionState> PragmaQueryCacheStatsInit(ClientContext &context, TableFunctionInitInput &input) {
	return make_uniq<PragmaQueryCacheStatsData>();
}

static void PragmaQueryCacheStatsFunction(ClientContext &context, TableFunctionInput &data_p, DataChunk &output) {
	auto &state = data_p.global_state->Cast<PragmaQueryCacheStatsData>();
	if (state.finished) {
		return;
	}

	auto stats = context.GetQueryCacheStats();
	
	output.SetCardinality(1);
	output.SetValue(0, 0, Value::BIGINT(stats.total_entries));
	output.SetValue(1, 0, Value::BIGINT(stats.total_hits));
	output.SetValue(2, 0, Value::BIGINT(stats.total_misses));
	output.SetValue(3, 0, Value::DOUBLE(stats.hit_rate));
	output.SetValue(4, 0, Value::BIGINT(stats.memory_usage_bytes));
	output.SetValue(5, 0, Value::DOUBLE(stats.false_positive_rate));
	output.SetValue(6, 0, Value::BOOLEAN(context.GetQueryCache().IsEnabled()));

	state.finished = true;
}

void PragmaQueryCacheStats::RegisterFunction(BuiltinFunctions &set) {
	set.AddFunction(TableFunction("pragma_query_cache_stats", {}, PragmaQueryCacheStatsFunction,
	                              PragmaQueryCacheStatsBind, PragmaQueryCacheStatsInit));
}

} // namespace duckdb