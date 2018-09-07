using ArgParse
using ComparativeAutograder: small_repr, truncate_string, TestSuiteError
using JSON

include("./parsetestsuite.jl")
include("./run.jl")

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--grader"
            help = "The grader file."
            default = "./grader.jl"
        "--submission"
            help = "The student submission file to run."
            default = "./submission.jl"
    end

    return parse_args(s)
end

function handle_error(error)
    if isa(error, TestSuiteError)
        JSON.print(Dict(
            "passed" => false,
            "error" => small_repr(error.exception),
        ))
    else
        JSON.print(Dict(
            "passed" => false,
            "error" => small_repr(error),
        ))
    end
end

function main()
    @time parsed_args = parse_commandline()
    @time grader_contents = open(parsed_args["grader"]) do file
        read(file, String)
    end
    @time grader = parse_test_suite(grader_contents)
    println(STDERR, "grader = ", grader)
    result = nothing
    try
        @time result = run_test_suite(
            grader.test_suite,
            grader.solution,
            parsed_args["submission"],
            grader.function_name,
        )
    catch err
        show(STDERR, "text/plain", catch_stacktrace())
        handle_error(err)
        exit(-1)
    end
    println(STDERR, "result = ", result)
    #
    # result = execute_student_test_suite(suite, parsed_args["submission"], parsed_args["function"])
    # println(STDERR, "result: ", result)
    # serialize(STDOUT, result)

    test_results = []
    for test in result.results
        data = Dict(
            "passed" => test.passed,
            "elapsedTime" => test.elapsed_time,
            "stdout" => truncate_string(test.output.stdout),
            "stderr" => truncate_string(test.output.stderr),
        )
        if test.output.exception != nothing
            data["exception"] = small_repr(test.output.exception)
        else
            data["result"] = small_repr(test.output.result)
        end
        push!(test_results, data)
    end

    JSON.print(Dict(
        "passed" => result.passed,
        "elapsedTime" => result.elapsed_time,
        "tests" => test_results,
    ))
end

@time main()
