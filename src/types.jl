struct FunctionTestCase
    args::Tuple
    kwargs::Dict
    tolerance::Float64
    FunctionTestCase(args=(), kwargs=Dict(); tolerance=1e-5) = new(args, kwargs, tolerance)
end

struct FunctionTestCaseOutput
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

    FunctionTestCaseOutput(
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
    TestSuite(
        tests::Array{FunctionTestCase}
        ;
        packages=[]
    ) = new(tests, packages)
end

struct TestSuiteError
    exception
end

struct TestCaseResult
    passed::Bool
    output::FunctionTestCaseOutput
    elapsed_time::Float64
    error::Union{Float64, Void}

    TestCaseResult(
        passed::Bool,
        output::FunctionTestCaseOutput,
        error=nothing,
    ) = new(
        passed,
        output,
        output.elapsed_time,
        error,
    )
end

struct TestSuiteResult
    passed::Bool
    results::Array{TestCaseResult}
    test_suite::Union{TestSuite, Void}
    # Elapsed time in seconds.
    elapsed_time::Float64

    TestSuiteResult(
        passed::Bool,
        results::Array{TestCaseResult}
        ;
        suite=nothing,
        elapsed_time=-1.0
    ) = new(passed, results, suite, elapsed_time)
end

struct ParsedGrader
    test_suite::TestSuite
    solution::Function
    function_name::String
end
