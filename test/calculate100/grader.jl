using ComparativeAutograder: runtests, TestCase
include("./declarations.jl")

tests = []

for _ in 1:10
    push!(
        tests,
        TestCase(
            Fab(sin, -randn(), randn())
        )
    )
end

runtests(tests)
