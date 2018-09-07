using ComparativeAutograder: @solution, @testcase

@solution function square(x)
    return x^2
end

@testcase square(0)
@testcase square(1)
@testcase square(-1)
@testcase square(3)
@testcase square(randn())
