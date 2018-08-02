#!/usr/bin/env julia

# ComparativeAutograder.jl Runner Script
# Usage: julia runner.jl /path/to/submission.jl function_name

using ArgParse
using ComparativeAutograder

module StudentSubmission
include(ARGS[1])
end

student_function = getfield(StudentSubmission, Symbol(ARGS[2]))

test_suite = deserialize(STDIN)
assert(typeof(test_suite) == TestSuite)

function run_test_case(case::TestCase, f::Function)
    return f(case.args...; case.kwargs...)
end

results = [run_test_case(case, student_function) for case in test_cases]
serialize(STDOUT, results)
