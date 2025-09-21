#include "duckdb/execution/operator/helper/physical_explain_cache.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/query_cache.hpp"

namespace duckdb {

//===--------------------------------------------------------------------===//
// Source
//===--------------------------------------------------------------------===//
SourceResultType PhysicalExplainCache::GetData(ExecutionContext &context, DataChunk &chunk,
                                               OperatorSourceInput &input) const {
	// Get the query cache from the client context
	auto &cache = context.client.GetQueryCache();
	
	// Get cache explanation info
	auto explain_info = cache.GetExplainInfo();
	
	// Format the explanation based on the requested format
	string explanation = cache.FormatExplainInfo(explain_info, format);
	
	// Set the result in the chunk
	chunk.SetValue(0, 0, Value("query_cache"));
	chunk.SetValue(1, 0, Value(explanation));
	chunk.SetCardinality(1);

	return SourceResultType::FINISHED;
}

} // namespace duckdb