using Serialization

struct RunnerProcResult
    exitcode::Int64
    result::Union{RunnerOutput, Nothing}
    stdout::AbstractString
    stderr::AbstractString
end

RunnerProcResult(s::Int64, r::Any, e::Nothing) = RunnerProcResult(s, r, "")

function readpipe!(p::Pipe)
    close(p.in)
    return read(p, String)
end

"""
    launch_runner_proc(testsuite, submissionfile, functionname[; debug])

Launch a runner subprocess and get the resulting `RunnerProcResult`.

**Note:** This function uses `deserialize` and so bugs may cause the Julia
process to crash without warning (no error, no backtrace, etc.) if the
serialized input is invalid.
"""
function launch_runner_proc(
    testsuite::TestSuite,
    submissionfile::String,
    functionname::Union{AbstractString, Symbol},
    ;
    debug::String=get(ENV, "JULIA_DEBUG", ""),
)
    functionname = Symbol(functionname)
    input_path, output_path = tempname(), tempname()
    runner_input = RunnerInput(testsuite, submissionfile, functionname, output_path)

    # Julia makes it *very* hard to actually get the id of a subprocess, so
    # we generate a random string here to be able to track what logs are comming
    # from what process. Note that we use an alphabetic rather than a number to
    # prevent confusion with the process id.
    log_id = String(rand('a':'z', 6))
    try
        open(io -> serialize(io, runner_input), input_path, "w")

        @debug "Launching runner subprocess." submissionfile JULIA_EXE
        submissionfile = realpath(submissionfile)
        # proc_in, proc_out, proc_err = Pipe(), Pipe(), Pipe()
        stdout_pipe, stderr_pipe = Pipe(), Pipe()
        # jl_cmd = "using ComparativeAutograder: runner_main; runner_main()"
        jl_env = copy(ENV)
        jl_env["JULIA_DEBUG"] = debug
        proc = run(pipeline(
            Cmd(`$(Base.julia_cmd()) -e $RUNNER_CMD $input_path`, env=jl_env),
            stdout=stdout_pipe,
            stderr=stderr_pipe,
        ); wait=false)
        @debug "Spawned runner process."

        stdout_task = @async readpipe!(stdout_pipe)
        stderr_task = @async readpipe!(stderr_pipe)

        # Wait for the subprocess to complete.
        wait(proc)
        status = proc.exitcode
        @debug "Runner process ($log_id) exited." status stdout_task stderr_task
        stdout_str, stderr_str = fetch.([stdout_task, stderr_task])

        # Fetch the RunnerOutput.
        runner_output = nothing
        try
            runner_output = open(io -> deserialize(io), output_path, "r")
            typeassert(runner_output, RunnerOutput)
        catch exc
            @error "An error occurred while trying to read the runner output file." exc
        end

        return RunnerProcResult(status, runner_output, stdout_str, stderr_str)
    finally
        rm.([input_path, output_path], force=true)
    end
end
