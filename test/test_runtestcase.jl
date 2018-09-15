using Base.Test
using ComparativeAutograder

return3() = 3
result = runtestcase(return3, TestCase(()))
println(result)
@test result.result == 3
@test result.exception == nothing
@test result.backtrace == nothing
@test result.stdout == ""
@test result.stderr == ""
@test result.time > 0

return3bad() = nonexistantvariable + 8
result = runtestcase(return3bad, TestCase(()))
println(result)
@test result.result == nothing
@test contains(result.exception, "UndefVarError")
@test result.backtrace != nothing

returnsum(x, y) = x + y
result = runtestcase(returnsum, TestCase((3, 4)))
@test result.result == 7
