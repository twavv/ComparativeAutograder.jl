@solution function gn(x,w,b,f_a )
    return f_a.(x'*w .+ b) ## TODO: activation_function.(x'*w.+b) 
end
function sigmoid(z) 
    return  1/(1+exp(-z))
end

n = rand(30:100,1)[]
N = rand(30:100,1)[]
@testcase gn(randn(n,N), randn(n), randn(), sigmoid)

n = rand(30:100,1)[]
N = rand(30:100,1)[]
@testcase gn(randn(n,N), randn(n), randn(), sigmoid)

n = rand(30:100,1)[]
N = rand(30:100,1)[]
@testcase gn(randn(n,N), randn(n), randn(), sigmoid)

n = rand(30:100,1)[]
N = rand(30:100,1)[]
@testcase gn(randn(n,N), randn(n), randn(), sigmoid)
