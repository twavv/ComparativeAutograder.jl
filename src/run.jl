using JSON
using ComparativeAutograder
using ComparativeAutograder: execute_test_suite, max_abs_error, TestSuiteError
function load_packages(packages::Array{:Symbol})
    for package in packages
        eval(Expr(:using, package))
    end
end

function launch_grader_proc(
        test_suite::TestSuite,
        student_file::AbstractString,
        function_name::AbstractString,
)
    cmd = `julia $(@__DIR__)/runner/main.jl --submission $student_file $function_name`
    proc_in = Pipe()
    proc_out = Pipe()
    proc_err = Pipe()

    println(STDERR, "Spawning command: ", cmd)
    proc = spawn(cmd, (proc_in, proc_out, STDERR))
    serialize(proc_in, test_suite)
    println(STDERR, "proc_out", proc_out)
    # wait(proc)
    result = deserialize(proc_out)
    # @show result
    if typeof(result) == TestSuiteError
        println(STDERR, "ERROR! ", result.exception)
        throw(result)
    end
    wait(proc)
    if proc.exitcode != 0
        println(STDERR, "ERROR! Student grading process returned code ", proc.exitcode)
        exit(-1)
    end
    return result
end

function grade_solution(
        test_suite::TestSuite,
        f::Function,
)
    return execute_test_suite(f, test_suite)
end

function run_test_cases(
        test_suite::TestSuite,
        soln_func::Function,
        student_file::AbstractString,
        function_name::AbstractString,
)
    student_task = @async launch_grader_proc(test_suite, student_file, function_name)
    soln_task = @async grade_solution(test_suite, soln_func)
    student_result = wait(student_task)
    soln_result = wait(soln_task)
    # @show student_result
    # @show soln_result
    return (student_result, soln_result)
end

function run_test_suite(
        test_suite::TestSuite,
        soln_func::Function,
        student_file::AbstractString,
        function_name::AbstractString,
)
    start_time = time_ns()
    student_results = Array{TestCaseResult}([]);
    student_outputs, soln_results = run_test_cases(test_suite, soln_func, student_file, function_name)
    end_time = time_ns()
    elapsed_time = (end_time - start_time) / 1e9
    @assert length(student_outputs) == length(soln_results)
    passed_vec = Array{Bool}([])
    for i in 1:length(test_suite.tests)
        # TODO: better error handling here
        @assert soln_results[i].exception == nothing
        test_case = test_suite.tests[i]
        student_output = student_outputs[i]
        error = max_abs_error(
            student_output.result,
            soln_results[i].result,
        )
        passed_case = (
            student_output.exception == nothing
            && error < test_case.tolerance
        )
        push!(student_results, TestCaseResult(
            passed_case,
            student_output,
            error,
        ))
        push!(passed_vec, passed_case)
    end
    @assert length(passed_vec) > 0
    result = TestSuiteResult(
        all(passed_vec),
        student_results,
        suite=test_suite,
        ;
        elapsed_time=elapsed_time,
    )
    return result
end
