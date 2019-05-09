"""
    RunnerInput(suite, graderfile, submissionfile, outfile)

A bundle of data that is used by a runner process to execute a test suite on a
code submission.
* `suite` is the `TestSuite` to be executed.
* `submissionfile` is the filename of the submission; it should be an absolute
    path.
* `outfile` is the filename to output the `serialize`'d `RunnerOutput`'.
"""
struct RunnerInput
    suite::TestSuite
    subfile::String
    funcname::Symbol
    outfile::String
end

"""
    RunnerOuput(result)

A bundle of data that is outputted by the runner processes.
This is currently just a vessel for `TestSuiteResult` but we could feasibly
add other information to this bundle that doesn't necessarily belong on the
`result` itself (e.g. execution metadata).
"""
struct RunnerOutput
    result::TestSuiteResult
end

"""
    runner_main(input; main=true)

Execute the runner.
If `main` is true, writes the `serialize`'d `RunnerOutput` to the file
specified in the `input` argument and the process will exit when this method
returns.
This function is potentially unsafe (it loads probably untrusted code) and so
should **never** be run outside of a sandbox.

This is mean to be the main entrypoint for runner subprocesses.
"""
function runner_main(input::RunnerInput; exit=true, write=true)
    try
        func = loadfunctionfromfile(
            input.subfile,
            input.funcname,
            nothing,
        )
        @debug "Loaded submission function." name=input.funcname file=input.subfile
        suite_result = runtestsuite(func, input.suite)
        output = RunnerOutput(suite_result)
        if write
            @debug "Writing runner output to file: $(input.outfile)"
            serialize(input.outfile, output)
        end
        exit && Base.exit(0)
        return output
    catch e
        @error "Unhandled error in runner." exception=(e, catch_backtrace())
        exit ? Base.exit(1) : rethrow(e)
    end
    # We should never get here™.
    error("Unanticipated control flow.")
end

function runner_main()
    input_path = get(ARGS, 1, nothing)
    if input_path === nothing
        @error "The serialized input file must be specified as the first command line argument."
        exit(1)
    end

    input = nothing
    try
        input = open(io -> deserialize(io), input_path, "r")
        typeassert(input, RunnerInput)
    catch exc
        @error "Unable to deserialize input file." exception=exc
        exit(1)
    end

    runner_main(input)

    # The `runner_main` function should always exit.
    error("Unanticipated control flow.")
end
