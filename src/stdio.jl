using Logging

"""
    @capture_stdstreams(expr)

Evaluate the specified expression and return a `(stdout, stderr)` tuple.

This macro will attempt to capture every form of output, including via the
`Logging` module (_e.g._ the `@logmsg` and friend macros), but it's unable to
do this with perfect accuracy. Any code that stores a reference to `stdout` or
`stderr` before this is executed will retain those references to the original
streams.
For example, the original log instance may be obtained using
`Logging.global_logger()` because no attempt is made to set the global logger
instance.

# Examples
```julia-repl
julia> out, err = ComparativeAutograder.@capture_stdstreams begin
           println("I'm going to out!")
           println(stderr, "I'm going to err!")
       end
("I'm going to out!\\n", "I'm going to err!\\n")
```
"""
macro capture_stdstreams(expr)
    # We use a whole bunch of `gensym`'s to avoid polluting the namespace
    out, outread, outwrite, outtask = gensym.([:stdout, :outread, :outwrite, :outtask])
    err, errread, errwrite, errtask = gensym.([:stderr, :errread, :errwrite, :errtask])
    return quote
        $out, $err = Base.stdout, Base.stderr
        $outread, $outwrite = redirect_stdout()
        $errread, $errwrite = redirect_stderr()
        $outtask = @async read($outread, String)
        $errtask = @async read($errread, String)

        try
            with_logger(ConsoleLogger(Base.stderr, Logging.Debug)) do
                $(esc(expr))
            end
        catch (e)
            rethrow(e)
        finally
            redirect_stdout($out)
            redirect_stderr($err)
            close.([$outwrite, $errwrite])
        end

        fetch($outtask), fetch($errtask)
    end
end

"""
    smallrepr(x)

Generate a _small_ representation of `x` (_i.e._ what would be printed to the
console so as not to overwhelm the user with output).

# Examples
```julia-repl
julia> print(ComparativeAutograder.smallrepr(ones(2, 100)))
2×100 Array{Float64,2}:
 1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  …  1.0  1.0  1.0  1.0  1.0  1.0  1.0
 1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0     1.0  1.0  1.0  1.0  1.0  1.0  1.0
```
"""
function smallrepr(x)
    buf = IOBuffer()
    ctx = IOContext(buf, :limit => true)
    show(ctx, "text/plain", x)
    return String(take!(buf))
end

"""
    trunctatestring(s[, l])

Take at most `l` characters of `s`; if the `s` is longer than `l`, then `l`
characters are taken and the string `...\n[ TRUNCATED ]` is appended to the end.

# Examples
```julia-repl
julia> println(ComparativeAutograder.truncatestring("foo\nbar\nspam", 5))
foo
b...
[ TRUNCATED ]
```
"""
function truncatestring(s::AbstractString, l::Int=16384)
    if length(s) > l
        return s[1:l] * "...\n[ TRUNCATED ]"
    end
    return s
end

"""
    errorstring(e)

Convert an exception into a human readable version.

# Examples
```julia-repl
julia> exc = nothing
julia> try
           1 + "foo"
       catch e
           global exc
           exc = e
       end
julia> println(errorstring(exc))
MethodError: no method matching +(::Int64, ::String)
Closest candidates are:
  +(::Any, ::Any, !Matched::Any, !Matched::Any...) at operators.jl:502
  +(::T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8}, !Matched::T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8}) where T<:Union{Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8} at int.jl:53
  +(::Union{Int16, Int32, Int64, Int8}, !Matched::BigInt) at gmp.jl:447
  ...
```
"""
errorstring(e::Exception) = sprint(showerror, e)
errorstring(e::ErrorException) = "ErrorException: $(e.msg)"
errorstring(e::AbstractString) = truncatestring(e)
errorstring(e::Any) = truncatestring(smallrepr(e))
