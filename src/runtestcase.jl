using ComparativeAutograder
using ComparativeAutograder: log

struct TestCaseResult
    result::Union{Any, Void}
    # Note: exception is a string to avoid breaking (de)serialize if the
    # exeption happens to reference context-specific data (eg. something in the
    # _Submission module which wouldn't be present in the parent process)
    exception::Union{AbstractString, Void}
    backtrace::Union{AbstractString, Void}
    time::Float64
    stdout::AbstractString
    stderr::AbstractString
end

function runtestcase(f::Function, testcase::TestCase)
    log("Running testcase for function $(repr(f)).")
    result, exception, backtrace = nothing, nothing, nothing
    starttime = Base.time_ns()
    log_io = STDERR
    stdout, stderr = @capture_stdstreams begin
        try
            log(log_io, "Running submission function...")
            result = Base.invokelatest(f, testcase.args...; testcase.kwargs...)
            log(log_io, "Ran submission function successfully.")
        catch e
            log(log_io, "Caught exception while running submission function: $(repr(e))")
            exception = repr(e)
            backtrace = sprint(showerror, e)
        end
    end
    endtime = Base.time_ns()
    elapsedtime = (endtime - starttime) * 1e-9
    log("Ran testcase in $elapsedtime seconds.")
    return TestCaseResult(
        result,
        exception,
        backtrace,
        (endtime - starttime) * 1e-9,
        stdout,
        stderr,
    )
end
