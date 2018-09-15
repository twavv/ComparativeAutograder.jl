#!/usr/bin/env julia
# Runner script for ComparativeAutograder.jl.
# Usage: julia runner.jl \
#    /path/to/submission.jl

using JSON
using ComparativeAutograder
using ComparativeAutograder: log

_STDOUT = STDOUT
_STDERR = STDERR

results = Array{TestCaseResult, 1}()

stdout, stderr = @capture_stdstreams begin
try

    include("./loadfunctionfromfile.jl")

    if length(ARGS) != 1
        println(STDERR, "USAGE: runner.jl submission.jl")
        exit(1)
    end

    SUBMISSION_FILE = ARGS[1]
    log(_STDERR, "Loading test suite from stdin...")
    testsuite = deserialize(STDIN)
    log(_STDERR, "Loaded test suite from stdin.")
    typeassert(testsuite, TestSuite)

    log(_STDERR, "Loading function from file...")
    func = loadfunctionfromfile(
        SUBMISSION_FILE,
        testsuite.functionname,
        testsuite.setupcode,
    )
    log(_STDERR, "Loaded function from file.")

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
    log(_STDERR, "Result:\n $result")
    serialize(_STDOUT, result)
    # We exit 0 since we designate non-zero status code as unhandled errors.
    exit(0)
end # try / catch

end # @capture_stdstreams

result = TestSuiteResult(
    0.0, # time
    results,
    nothing, # exception
    nothing, # backtrace
    stdout,
    stderr,
)
log("Result: \n$result")
serialize(STDOUT, result)
