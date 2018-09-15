function loadfunctionfromfile(
    filename::String,
    functionname::String,
    injection::Union{Expr, Void}=nothing,
)
    # Note: this function should only be run once during a given Julia process.
    # We can't have specific _Submission namespaces since that would result in
    # things not lining up between common code in the submission and solution.
    # e.g. if we have the Fab type, we need to have _Submission.Fab rather than
    # _Submission4561.Fab so that it has the same name everywhere.
    modulename = Symbol("_Submission")
    moduleexpr = :(
        module $modulename
        $(injection)

        include($filename)
        end
    )
    try
        eval(moduleexpr)
        func = @eval getfield($modulename, Symbol($functionname))
        return func
    catch
        error("Couldn't find function $functionname in file $filename.")
    end
end
