function execute_test_suite(func::Function, suite::TestSuite)
    results = Array{FunctionTestCaseOutput}([])
    for case in suite.tests
        println(STDERR, "execute_test_suite: Running test case...")
        push!(results, execute_test_case(func, case))
        println(STDERR, "execute_test_suite: Test case complete.")
    end
    return results
end

function execute_test_case(func::Function, test_case::FunctionTestCase)
    origstdout = STDOUT
    origstderr = STDERR
    (stdout_read, stdout_write) = redirect_stdout()
    (stderr_read, stderr_write) = redirect_stderr()
    result = nothing
    exception = nothing
    backtrace = nothing
    start_time = Base.time_ns()
    try
        # We use invokelatest here because the student submission function is
        # defined AFTER this function is defined, and Julia will scream if you
        # try to call it without invokelatest.
        # https://docs.julialang.org/en/stable/stdlib/base/#Base.invokelatest
        # Background for why invokelatest is necessary (I don't fully
        # comprehend it myself):
        # https://github.com/JuliaLang/julia/issues/21356
        result = Base.invokelatest(func, test_case.args...; test_case.kwargs...)
    catch exc
        exception = exc
        backtrace = sprint(showerror, exc)
    end
    end_time = Base.time_ns()
    # Calculate elapsed time in seconds.
    elapsed_time = (end_time - start_time) * 1e-9
    redirect_stdout(origstdout)
    redirect_stderr(origstderr)
    close(stdout_read)
    close(stderr_read)
    if exception != nothing
        print(STDERR, "Exception! ")
        println(STDERR, exception)
        println(STDERR, backtrace)
    end
    return FunctionTestCaseOutput(
        result;
        exception=exception,
        elapsed_time=elapsed_time,
        stdout=readstring(stdout_read),
        stderr=readstring(stderr_read),
    )
end
