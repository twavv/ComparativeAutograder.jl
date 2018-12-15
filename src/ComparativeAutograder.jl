module ComparativeAutograder

export TestSuite, TestCase, TestSuiteResult, TestCaseResult, runtestcase, @capture_stdstreams, runtestsuite, @quoteandexecute

const JULIA_EXE = normpath(joinpath(Sys.BINDIR, Base.julia_exename()))
const DEFAULT_TOLERANCE = 1e-5

log(io::IO, args...) = println(io, "[ComparativeAutograder] ", args...)
log(args...) = log(Base.stderr, args...)

function args_to_array(args)::Array{Any}
    if args isa Tuple
        # Convert tuple to array.
        return [arg for arg in args]
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
    tolerance::Union{Float64, Nothing}

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
    # TODO: setupcode doesn't really work right now, oops.
    # This is because the test cases will be defined in terms of the setup
    # code and thus we can't deserialize it. So we'd have to load the setup
    # code separately and load it first.
    # Which I don't want to deal with right now.
    #setupcode::Union{Expr, Nothing}
    setupcode::Nothing

    TestSuite(
        functionname::String,
        cases::AbstractArray{TestCase},
        setupcode::Union{Expr, Nothing}=nothing,
    ) = new(
        functionname,
        cases,
        setupcode,
    )

    TestSuite(
        functionname,
        cases::AbstractArray,
        setupcode::Union{Expr, Nothing}=nothing,
    ) = TestSuite(
        functionname,
        convert(Array{TestCase, 1}, cases),
        setupcode,
    )
end

function runrunner(testsuite::TestSuite, submissionfile::AbstractString)

end



macro quoteandexecute(block)
    Core.eval(block)
    # Whatever a macro returns in then eval`d, so we have to quote it again so
    # that the eval yields a quote as desired.
    return Expr(:quote, block)
end

include("./proc.jl")
include("./stdio.jl")
include("./runtestcase.jl")
include("./runtestsuite.jl")
include("./compare.jl")

end
