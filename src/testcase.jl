export TestCase, runtestcase

"""
    TestCase(args[, kwargs[, tolerance]])
    TestCase(args...; kwargs...[, _tolerance])

Construct a test case.

The `args` and `kwargs` are passed to the function that will be tested.
The `tolerance` is the allowable difference between the result of the testcase
and the desired result (_e.g._ the result of the instructor function).

Note that the `tolerance` is only used when the result of the test case is
something that has a natural real valued difference between two instances; for
example the difference between two real vectors is the infinity (max) norm.
See the `compare` function for more details.

# Examples
```julia-repl
julia> TestCase([1, 2, 3])
TestCase(Any[1, 2, 3], Dict{Symbol,Any}(), 1.0e-5)

julia> TestCase([1, 2, 3], Dict(:foo => "bar"))
TestCase(Any[1, 2, 3], Dict{Symbol,Any}(:foo=>"bar"), 1.0e-5)

julia> TestCase(1, 2, 3; foo="bar", _tolerance=1e-9)
TestCase(Any[1, 2, 3], Dict{Symbol,Any}(:foo=>"bar"), 1.0e-9)
```
"""
struct TestCase
    args::Array{Any}
    kwargs::Dict{Symbol, Any}

    # Maximum numeric error tolerance.
    # This is calculated according to calculate_error.
    tolerance::Float64

    # This needs to be an inner constructor to account for when the varargs
    # constructor is used with three arguments.
    TestCase(args::Array, kwargs::Dict=Dict(), tolerance::Float64=DEFAULT_TOLERANCE) = new(
        convert(Array{Any}, args),
        convert(Dict{Symbol, Any}, kwargs),
        tolerance,
    )
end

TestCase(args...; tolerance=DEFAULT_TOLERANCE, kwargs...) = TestCase(
    Array{Any}([args...]),
    convert(Dict{Symbol, Any}, kwargs),
    tolerance,
)

struct TestCaseResult
    result::Union{Any, Nothing}
    # Note: exception is a string to avoid breaking (de)serialize if the
    # exeption happens to reference context-specific data (eg. something in the
    # _Submission module which wouldn't be present in the parent process)
    exception::Union{String, Nothing}
    backtrace::Union{String, Nothing}
    time::Float64
    stdout::String
    stderr::String
end

"""
    runtestcase(f::Function, testcase::TestCase)::TestCaseResult

Run the given test case on the specified function.
"""
function runtestcase(f::Function, testcase::TestCase)::TestCaseResult
    @debug("Running testcase for function $(repr(f)).")
    result, exception, backtrace = nothing, nothing, nothing

    start_ns = Base.time_ns()
    sub_stdout, sub_stderr = @capture_stdstreams begin
        try
            result = Base.invokelatest(f, testcase.args...; testcase.kwargs...)
        catch e
            exception = repr(e)
            backtrace = sprint(showerror, e)
        end
    end
    end_ns = Base.time_ns()

    # Get the elapsed time in seconds (1e-9 converts from nanoseconds)
    elapsedtime = (end_ns - start_ns) * 1e-9
    @debug "Finished running testcase." result exception elapsedtime

    return TestCaseResult(
        result, exception, backtrace,
        elapsedtime, sub_stdout, sub_stderr,
    )
end
