using Serialization

const RUNNER_EXE = realpath("$(@__DIR__)/runner/runner.jl")

struct RunnerOutput
    status::UInt8
    result::Any
    stderr::AbstractString
end

function launch_runner_proc(
    testsuite::TestSuite,
    submissionfile::String,
)
    submissionfile = realpath(submissionfile)
    # proc_in, proc_out, proc_err = Pipe(), Pipe(), Pipe()
    in_pipe, out_pipe, err_pipe = Pipe(), Pipe(), Pipe()
    proc = run(pipeline(
        `$(JULIA_EXE) -O 0 -g 2 $(RUNNER_EXE) $submissionfile`,
        stdin=in_pipe,
        stdout=out_pipe,
        stderr=err_pipe,
    ); wait=false)
    log("Spawned runner process.")
    # Close un-needed halves of pipes.
    # This seems to be necessary for the readstring's below to complete.
    close.([in_pipe.out, out_pipe.in, err_pipe.in])

    serialize(in_pipe, testsuite)

    out_task = @async begin
        try
            deserialize(out_pipe)
        catch e
            log("An error occurred while trying to deserialze runner output:\n$(repr(e))\n$(sprint(showerror, e))")
            TestSuiteResult(
                0.0,
                nothing,
                "Unable to deserialize runner output: $(repr(e))",
                sprint(showerror, e), # backtrace
                "",
                ""
            )
        end
    end
    err_task = @async read(err_pipe, String)
    fetch(proc)
    status = proc.exitcode
    log("out_task: $(repr(out_task))")
    log("err_task: $(repr(err_task))")
    result = fetch(out_task)
    log("Fetched result (from stdout): $(repr(out_task)).")
    err_string = fetch(err_task)
    log("Fetched stderr: $(repr(err_task)).")

    return RunnerOutput(status, result, err_string)
end
