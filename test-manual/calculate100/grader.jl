using ComparativeAutograder

#setupcode = @quoteandexecute begin
#    struct Fab
#        f::Function
#        a::Float64
#        b::Float64
#    end
#end

tests = Array{TestCase, 1}()

for _ in 1:10
    push!(
        tests,
        TestCase(
            (sin, -randn(), randn())
        )
    )
end

testsuite = TestSuite(
    "calculate100",
    tests,
)

runtestsuite(testsuite)
