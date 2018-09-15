#include("./common.jl")
type Fab
    f::Function
    a
    b
end
#include("./submission.jl")
function plot10(fab::Fab)
    return fab.f.(linspace(fab.a, fab.b, 10))
end

@time tests = deserialize(STDIN)
@time results = [
    plot10(fab)
    for fab in tests
]
println(results)
