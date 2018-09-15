using ComparativeAutograder

test_cases = []
for _ in 1:20
    n = rand(20:30)
    push!(test_cases, TestCase((rand(n, n), )))
end

runtestsuite(TestSuite(
    "adjacency2modularity",
    test_cases,
))
