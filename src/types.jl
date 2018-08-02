struct FunctionTestCase
    args::Tuple
    kwargs::Dict
    FunctionTestCase(args=(), kwargs=Dict()) = new(args, kwargs)
end

abstract type AbstractTestCaseResult end

struct FunctionTestCaseResult <: AbstractTestCaseResult
    # The returned result. Mutually exclusive with exception.
    result
    # The thrown exception. Mutually exclusive with result.
    exception
    # Elapsed time in seconds.
    elapsed_time::Float64
    # Captured stdout (UTF8 validity not ensured).
    stdout::String
    # Captured stderr (UTF8 validity not ensured).
    stderr::String

    FunctionTestCaseResult(
        result;
        exception=nothing,
        elapsed_time=-1.0,
        stdout="",
        stderr="",
    ) = new(result, exception, elapsed_time, stdout, stderr)
end

struct TestSuite
    tests::Array{FunctionTestCase}
    packages::Array{Symbol}
    TestSuite(tests; packages=[]) = new(tests, packages)
end

struct TestSuiteResult
    # Elapsed time in seconds.
    elapsed_time::Float64
end
