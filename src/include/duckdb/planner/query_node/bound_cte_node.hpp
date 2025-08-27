g//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/planner/query_node/bound_cte_node.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/planner/binder.hpp"
#include "duckdb/planner/bound_query_node.hpp"
#include "duckdb/common/types/column_data_collection.hpp"
#include "duckdb/common/bloom_filter.hpp"

namespace duckdb {

class BoundCTENode : public BoundQueryNode {
public:
	static constexpr const QueryNodeType TYPE = QueryNodeType::CTE_NODE;

public:
	BoundCTENode() : BoundQueryNode(QueryNodeType::CTE_NODE), is_cached(false) {
	}

	//! Keep track of the CTE name this node represents
	string ctename;

	//! The cte node
	unique_ptr<BoundQueryNode> query;
	//! The child node
	unique_ptr<BoundQueryNode> child;
	//! Index used by the set operation
	idx_t setop_index;
	//! The binder used by the query side of the CTE
	shared_ptr<Binder> query_binder;
	//! The binder used by the child side of the CTE
	shared_ptr<Binder> child_binder;

	//! Cached result of the CTE
	unique_ptr<ColumnDataCollection> cached_result;
	//! Bloom filter for cache lookup
	BloomFilter bloom_filter;
	//! Whether the CTE result is cached
	bool is_cached;

public:
	idx_t GetRootIndex() override {
		return child->GetRootIndex();
	}
};

} // namespace duckdb
