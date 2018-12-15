using Test
using ComparativeAutograder

const ARITHMETIC_SOLUTION = """
function h(x, y, z)
    return x*y, y*z, x*z, x+y+z
end
"""


#@testset "Arithmetic" begin

    cases = [TestCase((randn(), randn(), randn())) for _ in 1:100]
    suite = TestSuite("h", cases)

    soln_path, soln_io = mktemp()
        write(soln_io, ARITHMETIC_SOLUTION)
        close(soln_io)

        sub_path, sub_io = mktemp()
            write(sub_io, """h(x, y, z) = x*y, y*z, x*z, x+y+z""")
            close(sub_io)
                runtestsuite(
                    suite, soln_path, sub_path
                )
            @test sub_stdout != nothing
            @test false == true
        #end
    #end
    close.([soln_io, sub_io])
#end
