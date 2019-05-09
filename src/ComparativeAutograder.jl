module ComparativeAutograder

export TestSuite, TestCase, TestSuiteResult, TestCaseResult, runtestcase, @capture_stdstreams, runtestsuite, @quoteandexecute

const RUNNER_CMD = "using ComparativeAutograder: runner_main; runner_main()"
const DEFAULT_TOLERANCE = 1e-5

# Utilities
include("./stdio.jl")

include("./testcase.jl")
include("./testsuite.jl")
include("./runner.jl")
include("./output.jl")

# Implementation
include("./proc.jl")
include("./compare.jl")
include("./loadfunctionfromfile.jl")

end
