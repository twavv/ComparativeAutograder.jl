orig_stdout = STDOUT
sr, sw = redirect_stdout()

println("hello")
println("world")

redirect_stdout(orig_stdout)

println(sr)
