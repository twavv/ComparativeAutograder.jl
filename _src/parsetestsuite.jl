using ComparativeAutograder: ParsedGrader

"""
Parse a test suite.

Returns a module expression that (when evaluated) contains these fields:
    _COMPARATIVE_AUTOGRADER_TEST_CASES: An array of FunctionTestCase's that
        should be run using the solution and the student submission.
    _COMPARATIVE_AUTOGRADER_SOLUTION_FUNCTION: The solution function.
"""
function parse_test_suite(
        content::AbstractString,
)
    modexpr = parse("""module _TestSuiteSetup\n$(content)\nend""")
    @assert modexpr.head == :module
    modbody = modexpr.args[3]
    pkgs = []
    body = [
        :(using ComparativeAutograder: FunctionTestCase, @solution, @testcase),
        :(_COMPARATIVE_AUTOGRADER_TEST_CASES = Array{FunctionTestCase}([])),
    ]
    soln_func = nothing
    last_func = nothing
    func_calls = []
    function_sym = nothing
    for expr in modbody.args
        if expr.head == :using
            # Add the package to our set of packages.
            pkg = expr.args[1]
            if !in(pkg, pkgs)
                push!(pkgs, pkg)
            end
            push!(body, expr)
        elseif expr.head == :macrocall && expr.args[1] == Symbol("@solution")
            soln_func = expr.args[2]
            function_call = soln_func.args[1]
            function_sym = function_call.args[1]
            push!(body, Expr(
                :function,
                # Function name/signature is expressed as a :call
                Expr(
                    :call,
                    # Function name
                    :_COMPARATIVE_AUTOGRADER_SOLUTION_FUNCTION,
                    # Function arguments
                    function_call.args[2:end]...
                ),
                # Function body
                soln_func.args[2],
            ))
        elseif expr.head == :macrocall && expr.args[1] == Symbol("@testcase")
            parameters = Expr(:parameters)

            # Extract the function call from the macro
            if (expr.args[2].head == :parameters)
                parameters = expr.args[2]
                expr = expr.args[3]
            else
                expr = expr.args[2]
            end
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
            push!(body, Expr(
                :call,
                :push!,
                :_COMPARATIVE_AUTOGRADER_TEST_CASES,
                Expr(
                    :call,
                    :FunctionTestCase,
                    parameters,
                    args,
                    kwargs,
                )
            ))
        else
            push!(body, expr)
        end
    end

    if soln_func == nothing && typeof(last_func) == Expr
        soln_func = last_func
    end

    println(STDERR, "Solution is: ", soln_func)

    block = Expr(:block, body...)
    grader_module = eval(Expr(:module, true, :_TestSetup, block))
    return ParsedGrader(
        TestSuite(
            grader_module._COMPARATIVE_AUTOGRADER_TEST_CASES,
            ;
            packages=pkgs,
        ),
        grader_module._COMPARATIVE_AUTOGRADER_SOLUTION_FUNCTION,
        String(function_sym),
    )
end
