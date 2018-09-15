using ComparativeAutograder
using ComparativeAutograder: TestCase

setupcode = @quoteandexecute begin
    struct Fab
        a::Float64
        b::Float64
        f::Function
    end
end

tests = Array{TestCase, 1}()
for f in [sin, cos, tan]
    case = TestCase(Fab(-2pi, 2pi, f))
    push!(tests, case)
end

runtestsuite(TestSuite("plot10", tests, setupcode))
