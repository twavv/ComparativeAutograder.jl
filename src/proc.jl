using Serialization

const RUNNER_EXE = realpath("$(@__DIR__)/runner/runner.jl")

struct RunnerOutput
    status::Int64
    result::Any
    stderr::AbstractString

    RunnerOutput(s::Int64, r::Any, e::Nothing) = new(s, r, "")
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
            log("An error occurred while trying to deserialize runner output:\n$(repr(e))\n$(sprint(showerror, e))")
            return TestSuiteResult(
                0.0,
                nothing,
                "Unable to deserialize runner output: $(repr(e))",
                sprint(showerror, e), # backtrace
                "",
                ""
            )
        end
    end

    # Julia makes it *very* hard to actually get the id of a subprocess, so
    # we generate a random string here to be able to track what logs are comming
    # from what process. Note that we use an alphabetic rather than a number to
    # prevent confusion with the process id.
    log_id = String(rand('a':'z', 6))
    err_lines = Vector{String}()
    err_task = @async begin
        while !eof(err_pipe)
            line = readline(err_pipe)
            log("[Runner $(log_id)] " * line)
        end
    end
    wait(proc)
    status = proc.exitcode
    log("Process ($log_id) exited with status $(status).")
    err_string = join(err_lines, "\n")
    log("out_task: $(repr(out_task))")
    log("err_task: $(repr(err_task))")
    result = fetch(out_task)
    log("Fetched result (from stdout) $(log_id) $(status): $(repr(out_task)).")
    err_string = fetch(err_task)
    log("Fetched stderr: $(repr(err_task)).")

    return RunnerOutput(status, result, err_string)
end
