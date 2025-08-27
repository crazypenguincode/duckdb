//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/catalog/table_structure_monitor.cpp
//
//
//===----------------------------------------------------------------------===//

#include "duckdb/catalog/table_structure_monitor.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/database.hpp"
#include "duckdb/common/chrono.hpp"

namespace duckdb {

TableStructureMonitor::TableStructureMonitor(DatabaseInstance &db, uint64_t scan_interval_ms)
    : db(db), scan_interval_ms(scan_interval_ms), stop_thread(false) {
}

TableStructureMonitor::~TableStructureMonitor() {
    Stop();
}

void TableStructureMonitor::Start() {
    if (background_thread.joinable()) {
        return;
    }
    stop_thread = false;
    background_thread = thread([this]() { this->BackgroundThread(); });
}

void TableStructureMonitor::Stop() {
    if (!background_thread.joinable()) {
        return;
    }
    stop_thread = true;
    background_thread.join();
}

void TableStructureMonitor::RegisterTable(TableCatalogEntry &table) {
    lock_guard<mutex> lock(tables_mutex);
    registered_tables[&table] = table.GetVersion();
}

void TableStructureMonitor::UnregisterTable(TableCatalogEntry &table) {
    lock_guard<mutex> lock(tables_mutex);
    registered_tables.erase(&table);
}

bool TableStructureMonitor::HasStructureChanged(TableCatalogEntry &table, uint64_t last_known_version) {
    return table.GetVersion() != last_known_version;
}

void TableStructureMonitor::BackgroundThread() {
    while (!stop_thread) {
        // Sleep for scan interval
        std::this_thread::sleep_for(std::chrono::milliseconds(scan_interval_ms));

        // Scan all registered tables
        lock_guard<mutex> lock(tables_mutex);
        for (auto &entry : registered_tables) {
            auto table = entry.first;
            auto &last_version = entry.second;
            uint64_t current_version = table->GetVersion();
            if (current_version != last_version) {
                // Table structure changed
                last_version = current_version;
                // TODO: Notify listeners or update caches
            }
        }
    }
}

} // namespace duckdb