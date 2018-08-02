using ArgParse
using ComparativeAutograder

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
    parsed_args = parse_commandline()
    suite = deserialize(STDIN)
    # TODO: serialize result to STDOUT
    @assert typeof(suite) == TestSuite
    execute_test_suite(suite, parsed_args["submission"], parsed_args["function"])
end

main()
