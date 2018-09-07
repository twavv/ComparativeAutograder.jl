function gn(x,w,b,f_a)
    return f_a.(x'*w.+b)
end
