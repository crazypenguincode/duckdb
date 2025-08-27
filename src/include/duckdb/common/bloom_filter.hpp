#pragma once

#include "duckdb/common/types.hpp"
#include "duckdb/common/vector.hpp"
#include "duckdb/common/array.hpp"

namespace duckdb {

class BloomFilter {
public:
    BloomFilter(idx_t capacity, double false_positive_probability = 0.01);

    void Add(const string_t &key);
    void Add(hash_t hash);

    bool Contains(const string_t &key) const;
    bool Contains(hash_t hash) const;

    idx_t Size() const { return size; }
    idx_t Capacity() const { return capacity; }

private:
    void Initialize(idx_t capacity, double false_positive_probability);
    vector<uint8_t> bit_array;
    vector<hash_t> hash_functions;
    idx_t size;
    idx_t capacity;
};

} // namespace duckdb