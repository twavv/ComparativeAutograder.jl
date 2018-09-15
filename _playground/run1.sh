cat <<EOF | julia
function sigmoid(z)
    return  1/(1+exp(-z))
end

function gn(x,w,b,f_a )
    return f_a.(x'*w .+ b) ## TODO: activation_function.(x'*w.+b)
end

n = rand(30:100,1)[]
N = rand(30:100,1)[]
gn(randn(n,N), randn(n), randn(), sigmoid)
EOF
