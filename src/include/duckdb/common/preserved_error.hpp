#pragma once

#include "duckdb/common/exception.hpp"
#include "duckdb/common/string_util.hpp"

namespace duckdb {

class PreservedError {
public:
    PreservedError() = default;
    explicit PreservedError(const Exception &exception);
    explicit PreservedError(const std::exception &exception);

    const string &Message() const { return message; }
    const string &StackTrace() const { return stack_trace; }

private:
    string message;
    string stack_trace;
};

} // namespace duckdb