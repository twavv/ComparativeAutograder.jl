include("./common.jl")

tests = [
    Fab(sin, -5*abs(randn()), 5*abs(randn()))
    for _ in 1:10
]
serialize(STDOUT, tests)
