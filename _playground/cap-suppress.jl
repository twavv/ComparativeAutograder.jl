macro capture_out(block)
    quote
        if ccall(:jl_generating_output, Cint, ()) == 0
            original_stdout = STDOUT
            out_rd, out_wr = redirect_stdout()
            out_reader = @async readstring(out_rd)
        end

        try
            $(esc(block))
        finally
            if ccall(:jl_generating_output, Cint, ()) == 0
                redirect_stdout(original_stdout)
                close(out_wr)
            end
        end

        if ccall(:jl_generating_output, Cint, ()) == 0
            fetch(out_reader)
        else
            ""
        end
    end
end

out = @capture_out begin
    println("foo")
end
println(out)
