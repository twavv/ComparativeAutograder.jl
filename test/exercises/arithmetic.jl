using JSON
using Test
using ComparativeAutograder

const ARITHMETIC_SOLUTION = """
function h(x, y, z)
    return x*y, y*z, x*z, x+y+z
end
"""


@testset "Arithmetic" begin

    cases = [TestCase((randn(), randn(), randn())) for _ in 1:100]
    suite = TestSuite("h", cases)

    soln_path, soln_io = mktemp()
    sub_path, sub_io = mktemp()
    sub_stdout, sub_stderr = nothing, nothing

    try
        write(soln_io, ARITHMETIC_SOLUTION)
        close(soln_io)
        write(sub_io, """h(x, y, z) = x*y, y*z, x*z, x+y+z""")
        close(sub_io)
        sub_stdout, sub_stderr = @capture_stdstreams runtestsuite(
            suite, soln_path, sub_path
        )
    finally
        rm.((soln_path, sub_path))
    end

    @test sub_stdout != nothing
    sub_data = JSON.parse(sub_stdout)
    @test sub_data["passed"] == true
end
