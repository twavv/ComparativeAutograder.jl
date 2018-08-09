"""
Get a smaller representation of an object.

For example, small_repr(randn(100, 100)) will return a string with ellipses
to indicate entries that were omitted.
"""
function small_repr(x)
    buf = IOBuffer()
    ctx = IOContext(buf, :limit => true)
    show(ctx, "text/plain", x)
    return String(take!(buf))
end

"""
Truncate a string.
Defaults to allowing 16kb before truncation (which is usually more than enough).
"""
function truncate_string(x::AbstractString, len::Int=16384)
    append = "...\n[ TRUNCATED ]"
    if length(x) > len
        return x[1:len] * append
    end
    return x
end
