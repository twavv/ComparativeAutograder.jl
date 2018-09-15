using ComparativeAutograder

tests = Array{TestCase, 1}()

for _ in 1:10
    push!(
        tests,
        TestCase((rand(), ))
    )
end

testsuite = TestSuite(
    "square",
    tests,
)

runtestsuite(testsuite)
