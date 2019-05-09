export TestCase, runtestsuite

struct TestSuite
    # functionname::Symbol
    cases::Array{TestCase}

    # Common code that should be executed in the grader, solution, and
    # submission contexts.
    # TODO: setupcode doesn't really work right now, oops.
    # This is because the test cases will be defined in terms of the setup
    # code and thus we can't deserialize it. So we'd have to load the setup
    # code separately and load it first.
    # Which I don't want to deal with right now.
    #setupcode::Union{Expr, Nothing}
    setupcode::Nothing
end

TestSuite(cases) = TestSuite(cases, nothing)

struct TestSuiteResult
    # Time elapsed during testing (including the time taken to load the student
    # submission but excluding time taken to setup ComparativeAutograder
    # process internals).
    elapsed_time::Float64

    # The array of produced TestCaseResult's.
    results::Array{TestCaseResult}
end

"""
    runtestsuite(f, suite)

Run the test suite on the specified function.
"""
function runtestsuite(f::Function, suite::TestSuite)::TestSuiteResult
    results = []
    start_time = Base.time()
    for case in suite.cases
        push!(results, runtestcase(f, case))
    end
    end_time = Base.time()
    elapsed_time = end_time - start_time
    @debug "Finished executing TestSuite." elapsed_time
    return TestSuiteResult(
        elapsed_time,
        results,
    )
end
