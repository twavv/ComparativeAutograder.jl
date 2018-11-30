using Base.Test
using ComparativeAutograder: calculate_error, TestCaseResult

t1 = TestCaseResult(
    3,
    nothing, nothing,
    0.0, "", ""
)

t2 = TestCaseResult(
    4,
    nothing, nothing,
    0.0, "", ""
)

@test calculate_error(t1, t2) == 1
