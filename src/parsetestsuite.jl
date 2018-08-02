function parse_test_suite(function_name::AbstractString, content::AbstractString)
    function_sym = Symbol(function_name)
    modexpr = parse("""module _TestSuiteSetup\n$(content)\nend""")
    @assert modexpr.head == :module
    modbody = modexpr.args[3]
    pkgs = []
    body = [
        :(_COMPARATIVE_AUTOGRADER_TEST_CASES = []),
    ]
    for expr in modbody.args
        if expr.head == :using
            pkg = expr.args[1]
            if !in(pkg, pkgs)
                push!(pkgs, pkg)
            end
            push!(body, expr)
        elseif expr.head == :call && expr.args[1] == function_sym
            # First, we extract the parameters as symbols
            args = []
            kwargs = []
            if (length(expr.args) > 1 && typeof(expr.args[2]) == Expr && expr.args[2].head == :parameters)
                # Keyword arguments occupy index 2, positional arguments occupy
                # indices 3+
                for kwarg_pair in expr.args[2].args
                    # Should be a Symbol
                    key = kwarg_pair.args[1]
                    # May be a Symbol or Expr
                    value = kwarg_pair.args[2]
                    push!(kwargs, :($(String(key)) => $value))
                end
                args = expr.args[3:end]
            else
                # No keyword arguments, positional arguments occupy indices 2+
                args = expr.args[2:end]
            end

            # Then, we evaluate them.
            # Or, more accurately, we change our list/dict of Symbols/Exprs,
            # created above, to expressions that will evaluate to the values
            # references by aforementioned Symbols/Exprs.
            kwargs = Expr(:call, :Dict, kwargs...)
            args = Expr(:tuple, args...)
            push!(body, Expr(:call, :push!, :_COMPARATIVE_AUTOGRADER_TEST_CASES, args, kwargs))
        else
            push!(body, expr)
        end
    end

    block = Expr(:block, body...)
    return Expr(:module, true, :_TestSetup, block)
end
