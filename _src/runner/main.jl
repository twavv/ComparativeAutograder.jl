using ArgParse
using ComparativeAutograder
using ComparativeAutograder: TestSuiteError

include("./execute.jl")

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--submission"
            help = "The student submission file to run."
            default = "./submission.jl"
        "function"
            help = "The name of the function within the student submission to run."
            required = true
    end

    return parse_args(s)
end

function main()
    old_stdout = STDOUT
    parsed_args = parse_commandline()
    suite = deserialize(STDIN)
    try
        # TODO: serialize result to STDOUT
        @assert typeof(suite) == TestSuite
        result = execute_student_test_suite(suite, parsed_args["submission"], parsed_args["function"])
        println(STDERR, "result: ", result)
        serialize(old_stdout, result)
    catch exc
        println(STDERR, "Caught exception: ", exc)
        serialize(old_stdout, TestSuiteError(exc))
        exit(-1)
    end
end

main()
