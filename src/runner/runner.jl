#!/usr/bin/env julia
# Runner script for ComparativeAutograder.jl.
# Usage: julia runner.jl \
#    /path/to/submission.jl

using JSON, Serialization
using ComparativeAutograder
using ComparativeAutograder: log

const _REAL_STDOUT = stdout
const _REAL_STDERR = stderr

results = Array{TestCaseResult, 1}()

my_stdout, my_stderr = @capture_stdstreams begin
try

    include("./loadfunctionfromfile.jl")

    if length(ARGS) != 1
        println(Base.stderr, "USAGE: runner.jl submission.jl")
        exit(1)
    end

    SUBMISSION_FILE = ARGS[1]
    log(_REAL_STDERR, "Loading test suite from stdin...")
    testsuite = deserialize(Base.stdin)
    log(_REAL_STDERR, "Loaded test suite from stdin.")
    typeassert(testsuite, TestSuite)

    log(_REAL_STDERR, "Loading function from file...")
    func = loadfunctionfromfile(
        SUBMISSION_FILE,
        testsuite.functionname,
        testsuite.setupcode,
    )
    log(_REAL_STDERR, "Loaded function from file.")

    for case in testsuite.cases
        push!(results, runtestcase(func, case))
    end
catch e
    result = TestSuiteResult(
        0.0, # time
        Array{TestCaseResult, 1}(),
        repr(e), # exception
        sprint(showerror, e), # backtrace
        "",
        "",
    )
    log(_REAL_STDERR, "Result:\n $result")
    serialize(_REAL_STDOUT, result)
    # We exit 0 since we designate non-zero status code as unhandled errors.
    exit(0)
end # try / catch

end # @capture_stdstreams

result = TestSuiteResult(
    0.0, # time
    results,
    nothing, # exception
    nothing, # backtrace
    my_stdout,
    my_stderr,
)
log("Result: \n$result")
serialize(Base.stdout, result)
