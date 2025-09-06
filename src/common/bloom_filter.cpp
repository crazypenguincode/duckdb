//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/common/bloom_filter.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/common/bloom_filter.hpp"
#include "duckdb/common/string_util.hpp"
#include <cmath>

namespace duckdb {

BloomFilter::BloomFilter(idx_t size, idx_t num_hash_functions) 
    : bit_array(size, false), num_hash_functions(num_hash_functions), num_elements(0) {
}

void BloomFilter::Add(const string &element) {
    auto hash_values = GetHashValues(element);
    for (auto hash_val : hash_values) {
        bit_array[hash_val % bit_array.size()] = true;
    }
    num_elements++;
}

bool BloomFilter::MightContain(const string &element) const {
    auto hash_values = GetHashValues(element);
    for (auto hash_val : hash_values) {
        if (!bit_array[hash_val % bit_array.size()]) {
            return false;
        }
    }
    return true;
}

void BloomFilter::Clear() {
    std::fill(bit_array.begin(), bit_array.end(), false);
    num_elements = 0;
}

double BloomFilter::GetFalsePositiveRate() const {
    if (num_elements == 0) {
        return 0.0;
    }
    // Formula: (1 - e^(-k*n/m))^k
    // where k = num_hash_functions, n = num_elements, m = bit_array.size()
    double exponent = -static_cast<double>(num_hash_functions * num_elements) / bit_array.size();
    double base = 1.0 - std::exp(exponent);
    return std::pow(base, num_hash_functions);
}

void BloomFilter::Resize(idx_t new_size) {
    bit_array.resize(new_size, false);
    // Note: This clears the filter, which is acceptable for our use case
    Clear();
}

std::vector<idx_t> BloomFilter::GetHashValues(const string &element) const {
    std::vector<idx_t> hash_values;
    hash_values.reserve(num_hash_functions);
    
    // Use different hash functions by combining base hash with different seeds
    idx_t base_val = Hash(element.c_str(), element.length());
    
    for (idx_t i = 0; i < num_hash_functions; i++) {
        // Create different hash values using the base hash and index
        idx_t hash_val = base_val ^ (i * 0x9e3779b9); // Golden ratio constant
        hash_val ^= hash_val >> 16;
        hash_val *= 0x85ebca6b;
        hash_val ^= hash_val >> 13;
        hash_val *= 0xc2b2ae35;
        hash_val ^= hash_val >> 16;
        hash_values.push_back(hash_val);
    }
    
    return hash_values;
}

} // namespace duckdb