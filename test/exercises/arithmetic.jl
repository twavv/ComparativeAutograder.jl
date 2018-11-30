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

    mktemp() do soln_path, soln_io
        write(soln_io, ARITHMETIC_SOLUTION)

        mktemp() do sub_path, sub_io
            write(sub_io, """h(x, y, z) = x*y, y*z, x*z, x+y+z""")
            sub_stdout, sub_stderr = @capture_stdstreams runtestsuite(
                suite, soln_path, sub_path
            )
            @test sub_stdout != nothing
            @test false == true
        end
    end
end
