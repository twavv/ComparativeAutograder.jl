using Serialization
using Test

using ComparativeAutograder
using ComparativeAutograder: TestSuite, TestCase, launch_runner_proc, readpipe!

const ADD_INT_FUNCTION_SRC = """
function add(x::Int, y::Int)
    x + y
end
"""

@testset "Test subprocess runner" begin
    mktemp() do sub_path, sub_io
        write(sub_io, ADD_INT_FUNCTION_SRC)
        close(sub_io)

        suite = TestSuite([
            TestCase(1, 2),
            TestCase(3, 4),
            TestCase(1.23, 1.45),
        ])

        proc = launch_runner_proc(suite, sub_path, "add"; debug="all")
        if proc.exitcode != 0
            @info "Printing runner stdout."
            println(proc.stdout)
            @info "Printing runner stderr."
            println(proc.stderr)
        end
        @test proc.exitcode == 0
        @test proc.stderr != ""

        result::TestSuiteResult = proc.result.result
        @test result.results[1].result == 3
        @test result.results[2].result == 7
        @test result.results[3].result === nothing
        @test occursin("MethodError", result.results[3].exception)
    end
end
