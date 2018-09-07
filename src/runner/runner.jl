# Runner script for ComparativeAutograder.jl.
# Usage: julia runner.jl \
#    /path/to/submission.jl \
#    /path/to/testsuite.jld \
#    /path/to/output.jld

using ComparativeAutograder
using Serializer: deserialize

include("./loadfunctionfromfile.jl")

SUBMISSION_FILE = ARGS[1]
TESTSUITE_FILE = ARGS[2]
OUTPUT_FILE = ARGS[3]

deserializefile(filename::String) = open(filename) do io
    deserialize(io)
end
testsuite = deserializefile(TESTSUITE_FILE)
typeassert(testsuite, TestSuite)

func = loadfunctionfromfile(
    SUBMISSION_FILE,
    testsuite.functionname,
    testsuite.setupcode,
)

println(func)
