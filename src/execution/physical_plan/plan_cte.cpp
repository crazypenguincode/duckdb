#include "duckdb/common/types/column/column_data_collection.hpp"
#include "duckdb/execution/operator/scan/physical_column_data_scan.hpp"
#include "duckdb/execution/operator/set/physical_cte.hpp"
#include "duckdb/execution/physical_plan_generator.hpp"
#include "duckdb/planner/expression/bound_reference_expression.hpp"
#include "duckdb/planner/operator/logical_cteref.hpp"
#include "duckdb/planner/operator/logical_materialized_cte.hpp"

namespace duckdb {

PhysicalOperator &PhysicalPlanGenerator::CreatePlan(LogicalMaterializedCTE &op) {
	// Create the working_table that the PhysicalCTE will use for evaluation.
	auto working_table = make_uniq<ColumnDataCollection>(context, op.types);

	auto left = CreatePlan(*op.children[0]);
	auto right = CreatePlan(*op.children[1]);

	auto &cte = Make<PhysicalCTE>(op.ctename, op.table_index, op.types, left, right, op.estimated_cardinality, &op.bound_cte);
	return cte;
}

} // namespace duckdb
