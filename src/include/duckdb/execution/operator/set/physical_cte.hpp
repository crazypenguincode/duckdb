//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/execution/operator/set/physical_cte.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/execution/physical_operator.hpp"
#include "duckdb/planner/bound_tokens.hpp"
#include "duckdb/common/types/column/column_data_collection.hpp"

namespace duckdb {

class BoundCTENode;

//! PhysicalCTE represents the materialized CTE operator
class PhysicalCTE : public PhysicalOperator {
public:
	static constexpr const PhysicalOperatorType TYPE = PhysicalOperatorType::CTE;

public:
	PhysicalCTE(string ctename, idx_t table_index, vector<LogicalType> types, PhysicalOperator &top,
	           PhysicalOperator &bottom, idx_t estimated_cardinality, optional_ptr<BoundCTENode> bound_cte = nullptr);
	~PhysicalCTE() override;

	string ctename;
	idx_t table_index;
	unique_ptr<ColumnDataCollection> working_table;
	vector<optional_ptr<PhysicalOperator>> cte_scans;
	optional_ptr<BoundCTENode> bound_cte;

public:
	// Sink interface
	unique_ptr<GlobalSinkState> GetGlobalSinkState(ClientContext &context) const override;
	unique_ptr<LocalSinkState> GetLocalSinkState(ExecutionContext &context) const override;
	SinkResultType Sink(ExecutionContext &context, DataChunk &chunk, OperatorSinkInput &input) const override;
	SinkCombineResultType Combine(ExecutionContext &context, OperatorSinkCombineInput &input) const override;

	void BuildPipelines(Pipeline &current, MetaPipeline &meta_pipeline) override;
	vector<const_reference<PhysicalOperator>> GetSources() const override;
	InsertionOrderPreservingMap<string> ParamsToString() const override;
};

} // namespace duckdb
