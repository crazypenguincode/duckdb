#include "duckdb/common/preserved_error.hpp"
#include "duckdb/common/exception.hpp"

namespace duckdb {

PreservedError::PreservedError(const Exception &exception) {
    message = exception.what();
    stack_trace = exception.GetStackTrace();
}

PreservedError::PreservedError(const std::exception &exception) {
    message = exception.what();
    stack_trace = "";
}

} // namespace duckdb