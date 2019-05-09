using Test
using ComparativeAutograder

@testset "Test runtestcase on built-in functions" begin
    @testset "testcase for println" begin
        case = TestCase("foo")
        result = runtestcase(println, case)
        @test result.result === nothing
        @test result.exception === nothing
        @test result.stdout == "foo\n"
        @test result.stderr == ""
    end

    @testset "Test runtestcase on built-in +" begin
        case = TestCase(1, 2)
        result = runtestcase(+, case)
        @test result.result === 3
        @test result.exception === nothing
        @test result.stdout == ""
        @test result.stderr == ""

        case = TestCase(1, "foo")
        result = runtestcase(+, case)
        @test result.result === nothing
        @test occursin("MethodError", result.exception)
        @test occursin("no method matching", result.backtrace)
        @test result.stdout == ""
        @test result.stderr == ""
    end
end

@testset "Test runtestcase on custom functions" begin
    @testset "testcase on custom add" begin
        add = (x, y) -> x + y
        case = TestCase(3, 4)
        result = runtestcase(add, case)
        @test result.result == 7
        @test result.exception === nothing
    end

    @testset "Test runtestcase on error throwing function" begin
        func = () -> error("I'm a error!")
        case = TestCase()
        result = runtestcase(func, case)
        @test result.result === nothing
        @test occursin("ErrorException", result.exception)
    end
end
