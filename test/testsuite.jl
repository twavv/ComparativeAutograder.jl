using ComparativeAutograder

@testset "Test runtestsuite" begin
    @testset "test suite for println" begin
        suite = TestSuite([
            TestCase("foo"),
        ])
        output = runtestsuite(println, suite)
        result = output.results[1]
        @test result.result === nothing
        @test result.exception === nothing
        @test result.stdout == "foo\n"
        @test result.stderr == ""
        @test output.elapsed_time > 0.0
    end

    @testset "Test runtestsuite on function that throws" begin
        myfunc = (x::Bool) -> x ? error("Throwing!") : "Not throwing."
        suite = TestSuite([
            TestCase(false),
            TestCase(true),
        ])
        output = runtestsuite(myfunc, suite)

        @test output.results[1].result == "Not throwing."
        @test output.results[2].exception !== nothing
    end
end
