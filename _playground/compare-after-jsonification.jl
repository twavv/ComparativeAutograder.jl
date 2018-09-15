using JSON

@time A = randn(100, 100)
@time Ajson = json(A)
@time B = JSON.parse(Ajson)
@show typeof(A), typeof(B)
@assert(A == B)
