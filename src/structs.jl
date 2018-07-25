struct FunctionTestCase
    args::Tuple
    kwargs::Dict
    FunctionTestCase(args=(), kwargs=Dict()) = new(args, kwargs)
end

abstract type AbstractTestCaseResult end

struct FunctionTestCaseResult <: AbstractTestCaseResult
    elapsed_time::Float64
    result
end

struct TestSuite
    packages::Array{Symbol}
    tests::Array{FunctionTestCase}
end

struct TestSuiteResult
    time_elapsed::Float64
end
