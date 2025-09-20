//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/common/bloom_filter.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/common.hpp"
#include "duckdb/common/types/hash.hpp"
#include <vector>
#include <functional>

namespace duckdb {

//! A Bloom Filter implementation for fast membership testing
//! Used to quickly check if a query result might be cached
class BloomFilter {
public:
    //! Constructor with specified size and number of hash functions
    explicit BloomFilter(idx_t size = 1000000, idx_t num_hash_functions = 3);
    
    //! Add an element to the bloom filter
    void Add(const string &element);
    
    //! Check if an element might be in the set (may have false positives)
    bool MightContain(const string &element) const;
    
    //! Clear the bloom filter
    void Clear();
    
    //! Get the current false positive probability
    double GetFalsePositiveRate() const;
    
    //! Resize the bloom filter
    void Resize(idx_t new_size);

public:
    //! The bit array
    std::vector<bool> bit_array;
    
private:
    //! Number of hash functions to use
    idx_t num_hash_functions;
    //! Number of elements added
    idx_t num_elements;
    //! Whether the bloom filter is disabled
    bool disabled;
    
    //! Generate hash values for an element
    std::vector<idx_t> GetHashValues(const string &element) const;
};

} // namespace duckdb