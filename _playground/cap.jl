include("/home/travigd/Mynerva/ComparativeAutograder.jl/src/runner/runtestcase.jl")

streams = @capture_stdstreams begin
    println("foo")
    print("bar")
end

println(streams)
