module ComparativeAutograder

DEFAULT_TOLERANCE = 1e-5

function args_to_array(args)::Array{Any}
    if args isa Tuple
        # Convert tuple to array.
        return [args for arg in args]
    elseif args isa AbstractArray
        # Leave as array.
        return args
    else
        # Convert single argument to array with one element.
        return [args]
    end
end

struct TestCase
    args::AbstractArray{Any}
    kwargs::Dict{Symbol}

    # Maximum numeric error tolerance.
    # This is calculated according to calculate_error.
    tolerance::Union{Float64, Void}

    TestCase(
        args::Any,
        kwargs::Dict{Symbol}=Dict{Symbol, Any}()
        ;
        tolerance::Float64=DEFAULT_TOLERANCE,
    ) = new(
        args_to_array(args),
        kwargs,
        tolerance,
    )
end

struct TestSuite
    functionname::String
    cases::AbstractArray{TestCase}

    # Common code that should be executed in the grader, solution, and
    # submission contexts.
    setupcode::Union{Expr, Void}

    TestSuite(
        functionname::String,
        cases::AbstractArray{TestCase},
        setupcode::Union{Expr, Void}=nothing,
    ) = new(
        functionname,
        cases,
        setupcode,
    )
end

export TestSuite, TestCase

function runtestsuite(testsuite::TestSuite)
    println(testsuite)
end

function writetestsuite(testsuite::TestSuite)::String
    (path, io) = mktemp()
    serialize(io, testsuite)
    close(io)
    return path
end

macro quoteandexecute(block)
    Core.eval(block)
    # Whatever a macro returns in then eval`d, so we have to quote it again so
    # that the eval yields a quote as desired.
    return Expr(:quote, block)
end

function calculate_error(a::Number, b::Number)
    return abs(a - b)
end

# Calculate the error between two arrays.
function calculate_error(a::AbstractArray, b::AbstractArray)
    return maximum(calculate_error.(a, b))
end

export runtestsuite, @quoteandexecute

end
