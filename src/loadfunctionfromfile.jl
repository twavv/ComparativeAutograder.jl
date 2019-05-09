"""
    loadfunctionfromfile(filename, functionname[, injection; modulename])

Loads the specified function from the given file.
Encapsulates the loaded file in a module named `modulename` (which exists in
the `Main` module namespace.)

**Note:** This function is potentially very dangerous; the file is loaded in
entirety, including all side effects.
This means that the loaded file may try to do all kinds of naughty things
(like call `exit()`, overwrite files, etc.).
It should **never** be used outside of a sandbox.
"""
function loadfunctionfromfile(
    filename,
    functionname,
    injection::Union{Expr, Nothing}=nothing;
    modulename=Symbol("_Submission"),
)
    functionname = Symbol(functionname)
    modulename = Symbol(modulename)
    # Note: this function should only be run once during a given Julia process.
    # We can't have specific _Submission namespaces since that would result in
    # things not lining up between common code in the submission and solution.
    # e.g. if we have the Fab type, we need to have _Submission.Fab rather than
    # _Submission4561.Fab so that it has the same name everywhere.
    moduleexpr = :(
        module $modulename
        $(injection)

        include($filename)
        end
    )
    try
        Main.eval(moduleexpr)
        # Note that we need to escape the symbol with `QuoteNode` to prevent
        # the symbol from being directly (literally) interpolated.
        # We want `getfield(_Submission, :functionname)` instead of
        # `getfield(_Submission, functionname)` which will raise an error about
        # functionname not being defined.
        func = @eval Main getfield($modulename, $(QuoteNode(functionname)))
        return func
    catch e
        @debug(
            "Caught exception when trying to load function from file.",
            e, filename, functionname,
        )
        error("Couldn't find function $functionname in file $filename.")
    end
end
