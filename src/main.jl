using ArgParse
using ComparativeAutograder: small_repr, truncate_string
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

function main()
    parsed_args = parse_commandline()
    grader_contents = open(parsed_args["grader"]) do file
        read(file, String)
    end
    grader = parse_test_suite(grader_contents)
    println(STDERR, "grader = ", grader)
    result = run_test_suite(
        grader.test_suite,
        grader.solution,
        parsed_args["submission"],
        grader.function_name,
    )
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

main()
