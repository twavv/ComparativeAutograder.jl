using Serialization
using Test

using ComparativeAutograder
using ComparativeAutograder: RunnerInput, runner_main

@testset "Test runner_main" begin
    func_body = """
        function add(a, b)
            a + b
        end
        """
    suite = TestSuite([
        TestCase(1, 2),
        TestCase("foo", "bar"),
    ])
    subfile = tempname()
    outfile = tempname()
    runner_input = RunnerInput(
        suite,
        subfile,
        :add,
        outfile,
    )

    routput, foutput = nothing, nothing
    try
        open(io -> write(io, func_body), subfile, "w")
        runner_output = runner_main(runner_input; exit=false, write=true)

        # The result is returned but it is also written to file.
        # We will check both.
        routput = runner_output
        foutput = open(io -> deserialize(io), outfile)
    finally
        # pass
        # rm.((subfile, outfile); force=true)
    end

    @test routput !== nothing
    @test foutput !== nothing

    for output in (routput, foutput)
        cases = output.result.results
        @test cases[1].result == 3
        @test occursin("MethodError", cases[2].exception)
    end
end

@testset "Test subprocess runner invalid invokation" begin
    @testset "Test subprocess runner with invalid usage" begin
        @test_throws Exception run(`$(Base.julia_cmd()) -e $(ComparativeAutograder.RUNNER_CMD)`)
    end

    @testset "Test subprocess runner with nonexistant input file" begin
        @test_throws Exception run(`$(Base.julia_cmd()) -e $(ComparativeAutograder.RUNNER_CMD) $(tempname())`)
    end
end
