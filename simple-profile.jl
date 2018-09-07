println(ARGS)
argquote = quote
ARGS = [
    "--grader",
    "./test/static/adjacency2modularity/grader.jl",
    "--submission",
    "/home/travigd/Mynerva/ComparativeAutograder.jl/test/static/adjacency2modularity/sol.jl",
]
end
Core.eval(Core, argquote)
println(ARGS)


include("./src/main.jl")
