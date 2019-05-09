using Test
using ComparativeAutograder
using ComparativeAutograder: results_dict

@testset "Test results_dict" begin
    @testset "Test results_dict with add method." begin
        add = (x, y) -> x + y
        suite = TestSuite([
            TestCase(1, 2),
            TestCase(-1, 0),
        ])
        result_sub = runtestsuite(add, suite)
        result_sol = runtestsuite(+, suite)

        output = results_dict(suite, result_sub, result_sol)
        @test output["passed"] == true
        @test length(output["testCases"]) == 2

        @test output["testCases"][1]["passed"] == true
        @test output["testCases"][1]["passed"] == true
    end
end
