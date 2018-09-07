module ComparativeAutograder

__precompile__()

include("./types.jl")
include("./execute.jl")
include("./compare.jl")
include("./helpers.jl")

export FunctionTestCase, FunctionTestCaseOutput
export TestSuite, TestSuiteResult, TestCaseResult

export FunctionTestCase

"""
No-op macro for piece of mind while parsing grader files.

If desired, one may add `using ComparativeAutograder: solution` to the grader
file so that the `@solution` macro doesn't appear to come from nowhere.
"""
macro solution(q)
    return q
end

"""
No-op macro (see above).
"""
macro testcase(q)
    return q
end

end # module
