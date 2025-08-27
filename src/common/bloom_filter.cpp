#include "duckdb/common/bloom_filter.hpp"
#include "duckdb/common/hash.hpp"
#include "duckdb/common/murmur3.hpp"
#include "duckdb/common/numeric_utils.hpp"
#include "duckdb/common/string_util.hpp"

namespace duckdb {

BloomFilter::BloomFilter(idx_t capacity, double false_positive_probability)
    : size(0), capacity(capacity) {
    Initialize(capacity, false_positive_probability);
}

void BloomFilter::Initialize(idx_t capacity, double false_positive_probability) {
    // Calculate optimal bit array size and number of hash functions
    auto [bit_size, hash_count] = CalculateOptimalParameters(capacity, false_positive_probability);

    bit_array.resize(bit_size, 0);
    hash_functions.resize(hash_count);

    // Initialize hash functions with different seeds
    for (idx_t i = 0; i < hash_count; i++) {
        hash_functions[i] = i * 0x5bd1e995;
    }
}

void BloomFilter::Add(const string_t &key) {
    Add(Hash(key.GetData(), key.GetSize()));
}

void BloomFilter::Add(hash_t hash) {
    for (auto seed : hash_functions) {
        auto combined_hash = MurmurHash3_32(hash ^ seed);
        auto index = combined_hash % bit_array.size();
        bit_array[index] = 1;
    }
    size++;
}

bool BloomFilter::Contains(const string_t &key) const {
    return Contains(Hash(key.GetData(), key.GetSize()));
}

bool BloomFilter::Contains(hash_t hash) const {
    for (auto seed : hash_functions) {
        auto combined_hash = MurmurHash3_32(hash ^ seed);
        auto index = combined_hash % bit_array.size();
        if (!bit_array[index]) {
            return false;
        }
    }
    return true;
}

} // namespace duckdb