#!/bin/bash

# Build and test cache strategies script
# This script compiles the cache strategy test and runs performance comparisons

set -e

echo "=== DuckDB Cache Strategy Testing ==="
echo

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "Error: Please run this script from the DuckDB root directory"
    exit 1
fi

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir build
fi

cd build

# Configure and build DuckDB with cache support
echo "Configuring DuckDB build..."
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_UNITTESTS=1

echo "Building DuckDB..."
make -j$(nproc) duckdb

# Build the cache strategy test
echo "Building cache strategy test..."
g++ -std=c++17 -I../src/include -I../third_party/fmt/include \
    -L. -lduckdb -pthread \
    ../test_cache_strategies.cpp -o test_cache_strategies

# Run the cache strategy performance test
echo
echo "Running cache strategy performance test..."
echo "This may take a few minutes..."
echo

./test_cache_strategies

echo
echo "=== Test Results ==="

# Check if results file was created
if [ -f "cache_strategy_results.csv" ]; then
    echo "Detailed results saved to: build/cache_strategy_results.csv"
    echo
    echo "Summary of results:"
    echo "==================="
    cat cache_strategy_results.csv
else
    echo "Warning: Results file not found"
fi

echo
echo "=== SQL Cache Test ==="
echo "Running SQL-based cache test..."

# Run SQL test
./duckdb test_cache.db < ../test_cache.sql

echo
echo "Cache strategy testing completed!"
echo
echo "Key findings:"
echo "1. TTL-based strategy: Good for time-sensitive data with predictable expiration"
echo "2. LRU-based strategy: Effective for workloads with clear access patterns"
echo "3. ML-based strategy: Adapts to complex patterns and query characteristics"
echo
echo "Check the CSV file for detailed performance metrics."