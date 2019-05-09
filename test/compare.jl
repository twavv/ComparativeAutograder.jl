using Test
using ComparativeAutograder
using ComparativeAutograder: δ

const TOLERANCE = 1e-9

@testset "Test δ function" begin
    @test δ(0, 1) < 1.0 + TOLERANCE
    @test δ(0, 0) < TOLERANCE

    a = ones(10, 10)
    b = ones(10, 10)
    @test δ(a, b) < TOLERANCE
    b[5, 9] += 0.0001
    @test δ(a, b) > TOLERANCE

    @test δ(true, true) < TOLERANCE
    @test δ(true, false) > TOLERANCE

    @test δ(nothing, nothing) < TOLERANCE
    @test δ(nothing, "foo") > TOLERANCE
    @test δ("foo", nothing) > TOLERANCE
    @test δ("foo", "bar") > TOLERANCE
    @test δ("bar", "bar") < TOLERANCE
end

@testset "Test δ function for TestCaseResults" begin
    @testset "Test δ function for simple TestCaseResults" begin
        add = (x, y) -> x + y
        case = TestCase(1, 3)
        out1 = runtestcase(+, case)
        out2 = runtestcase(add, case)
        @test δ(out1, out2) < TOLERANCE
    end

    @testset "Test δ function for exception'd TestCaseResults" begin
        throwerr = (args...) -> error("Error!")
        out = runtestcase(throwerr, TestCase())
        @test_throws Exception δ(out, out)
    end
end
