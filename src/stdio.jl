macro capture_stdstreams(expr)
    return quote
        _stdout_orig = Base.stdout
        _stderr_orig = Base.stderr
        _stdout_read, _stdout_write = redirect_stdout()
        _stderr_read, _stderr_write = redirect_stderr()
        _stdout_task = @async read(_stdout_read, String)
        _stderr_task = @async read(_stderr_read, String)

        try
            $(esc(expr))
        finally
            redirect_stdout(_stdout_orig)
            redirect_stderr(_stderr_orig)
            close(_stdout_write)
            close(_stderr_write)
        end

        fetch(_stdout_task), fetch(_stderr_task)
    end
end

function smallrepr(x)
    buf = IOBuffer()
    ctx = IOContext(buf, :limit => true)
    show(ctx, "text/plain", x)
    return String(take!(buf))
end

function truncatestring(x::AbstractString, l::Int=16384)
    if length(x) > l
        return x[1:l] * "...\n[ TRUNCATED ]"
    end
    return x
end

errorstring(e::Exception) = sprint(showerror(e))
errorstring(e::AbstractString) = truncatestring(e)
errorstring(e::Any) = truncatestring(smallrepr(e))
