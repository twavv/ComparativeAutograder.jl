using ComparativeAutograder: TestSuite, FunctionTestCase

function load_student_function(
        file_path,
        function_name,
        )
    modexpr = quote
        module _StudentSubmission
            include($file_path)
        end
    end
    modexpr.head = :toplevel
    # TODO: better error catching when given invalid input.
    # Redirect STDOUT and STDERR while we load the module.
    origstdout = STDOUT
    origstderr = STDERR
    redirect_stdout()
    redirect_stdout()
    eval(modexpr)
    redirect_stdout(origstdout)
    redirect_stderr(origstderr)
    return getfield(_StudentSubmission, Symbol(function_name))
end

function execute_test_suite(suite::TestSuite, student_file, function_name)
    println("execute_test_suite: Loading student function.")
    student_func = load_student_function(student_file, function_name)
    println("execute_test_suite: Student function loaded.")
    results = []
    for case in suite.tests
        println("execute_test_suite: Running test case...")
        push!(results, execute_test_case(student_func, case))
        println("execute_test_suite: Test case complete.")
    end
    @show results
end

function execute_test_case(func, test_case::FunctionTestCase)
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
        print("Exception! ")
        println(exception)
        println(backtrace)
    end
    return FunctionTestCaseResult(
        result;
        exception=exception,
        elapsed_time=elapsed_time,
        stdout=readstring(stdout_read),
        stderr=readstring(stderr_read),
    )
end
