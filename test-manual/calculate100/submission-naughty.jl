println("foo!")
println(STDERR, "bar!")
function calculate100(f, a, b)
    println("f: $f")
    println("a: $a, b: $b")
    return f.(linspace(a, b, 100))
end
