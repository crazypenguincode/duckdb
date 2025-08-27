//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/catalog/table_structure_monitor.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/common/atomic.hpp"
#include "duckdb/common/mutex.hpp"
#include "duckdb/common/thread.hpp"
#include "duckdb/catalog/catalog_entry/table_catalog_entry.hpp"
#include "duckdb/common/unordered_map.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/database.hpp"

namespace duckdb {

class TableStructureMonitor {
public:
    // Initialize the monitor with scan interval in milliseconds
    explicit TableStructureMonitor(DatabaseInstance &db, uint64_t scan_interval_ms = 60000);
    ~TableStructureMonitor();

    // Start the background scanning thread
    void Start();
    // Stop the background scanning thread
    void Stop();

    // Register a table for monitoring
    void RegisterTable(TableCatalogEntry &table);
    // Unregister a table from monitoring
    void UnregisterTable(TableCatalogEntry &table);

    // Check if table structure has changed since last check
    bool HasStructureChanged(TableCatalogEntry &table, uint64_t last_known_version);

private:
    // Background thread function
    void BackgroundThread();

    // Database instance
    DatabaseInstance &db;
    // Scan interval in milliseconds
    uint64_t scan_interval_ms;
    // Background thread
    thread background_thread;
    // Flag to control background thread
    atomic<bool> stop_thread;

    // Mutex for protecting registered_tables
    mutex tables_mutex;
    // Map of registered tables and their last known versions
    unordered_map<TableCatalogEntry*, uint64_t> registered_tables;
};

} // namespace duckdb