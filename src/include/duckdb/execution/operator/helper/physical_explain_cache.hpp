//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/execution/operator/helper/physical_explain_cache.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/execution/physical_operator.hpp"
#include "duckdb/common/enums/explain_format.hpp"

namespace duckdb {

//! PhysicalExplainCache represents the EXPLAIN CACHE operator
class PhysicalExplainCache : public PhysicalOperator {
public:
	static constexpr const PhysicalOperatorType TYPE = PhysicalOperatorType::EXPLAIN_CACHE;

public:
	explicit PhysicalExplainCache(vector<LogicalType> types, ExplainFormat format)
	    : PhysicalOperator(PhysicalOperatorType::EXPLAIN_CACHE, std::move(types), 1), format(format) {
	}

	ExplainFormat format;

public:
	// Source interface
	SourceResultType GetData(ExecutionContext &context, DataChunk &chunk,
	                        OperatorSourceInput &input) const override;

	bool IsSource() const override {
		return true;
	}
};

} // namespace duckdb