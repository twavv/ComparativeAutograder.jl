using ComparativeAutograder: FunctionTestCase, TestSuite

cases = []
push!(cases, FunctionTestCase((randn(10, 10), )))
push!(cases, FunctionTestCase((randn(10, 10), )))
push!(cases, FunctionTestCase((randn(10, 10), )))

suite = TestSuite(cases)

submission_file = "/home/travigd/Mynerva/ComparativeAutograder.jl/test/static/adjacency2modularity/student_good.jl"
(so, si, pr) = readandwrite(
    `julia /home/travigd/Mynerva/ComparativeAutograder.jl/src/runner/main.jl --submission $submission_file adjacency2modularity`
)

serialize(si, suite)
print(readstring(so))
wait(pr)
