using JSON

const NumericallyComparableType = Union{Number, AbstractArray{N}} where {N <: Number}

function calculate_error(solution::TestCaseResult, submission::TestCaseResult)::Float64
    if solution.exception != nothing
        error("Solution code threw an exception.")
    end
    if submission.exception != nothing
        error("Submission code threw an exception.")
    end
    sol = solution.result
    sub = submission.result
    if isa(sol, NumericallyComparableType)
        return calculate_error(sol, sub)
    end
    return sol == sub
end

function output_test_results(solution::TestSuiteResult, submission::TestSuiteResult)
    outfile = get(ENV, "COMPARATIVE_AUTOGRADER_OUTFILE", nothing)
    if outfile == nothing
        output_test_results(STDOUT, solution, submission)
    else
        open(outfile, "w") do f
            output_test_results(f, solution, submission)
        end
    end
end

function output_test_results(
    out::IO,
    solution::TestSuiteResult,
    submission::TestSuiteResult,
)
    output = nothing
    try
        output = generate_test_results_dict(solution, submission)
    catch e
        output = Dict(
            "passed" => false,
            "error" => smallrepr(e),
            "backtrace" => method_exists(showerror, (typeof(e), )) ? truncatestring(sprint(showerror(e))) : "",
        )
    end
    if isa(out, AbstractString)
        error("writing to file not implemented") # todo
    end
    log(output["passed"] ? "Submission passed." : "Submission failed.")
    JSON.print(out, output)
end

function output_error_dict(error::String, backtrace::Union{Void,String}="")
    output_error_dict(STDOUT, error, backtrace)
end

function output_error_dict(out::IO, error::String, backtrace::Union{Void,String}="")
    JSON.print(out, generate_error_dict(error, backtrace))
end

generate_error_dict(error::String, backtrace::Union{Void,String}="") = Dict(
    "passed" => false,
    "error" => error,
    "backtrace" => backtrace == nothing ? "" : backtrace,
)

function generate_test_results_dict(
    solution::TestSuiteResult,
    submission::TestSuiteResult,
)::Dict
    testcase_array = []
    if solution.exception != nothing
        log("Solution threw an exception: $(solution.exception)\n$(chomp(solution.backtrace))")
        return generate_error_dict("Solution threw an exception: $(solution.exception)", solution.backtrace)
    end
    if submission.exception != nothing
        log("Submission threw an exception: $(submission.exception)\n$(chomp(submission.backtrace))")
        return generate_error_dict("Submission threw an exception: $(submission.exception)", submission.backtrace)
    end
    if length(solution.results) != length(submission.results)
        error("Test case dimensions didn't match (solution returned $(length(solution.results)) test cases, submission returned $(length(submission.results))).")
    end
    for (sol, sub) in zip(solution.results, submission.results)
        if sol.exception != nothing
            log("Solution threw an exception on a test case: $(sol.exception)\n$(chomp(sol.backtrace))")
            error("Solution threw an exception on a test case.")
        end
        if sol.result == nothing
            log("Solution returned nothing.")
            error("Solution returned nothing.")
        end
        testcase_dict = Dict(
            "timeElapsed" => sub.time,
            "stdout" => truncatestring(sub.stdout),
            "stderr" => truncatestring(sub.stderr),
        )
        if sub.exception != nothing
            testcase_dict["passed"] = false
            testcase_dict["exception"] = sub.exception
            testcase_dict["backtrace"] = sub.backtrace
        else
            if sub.result == nothing
                log("ERROR(?): result is $(sub.result) and exception is $(sub.exception).")
            end
            error = calculate_error(sol.result, sub.result)
            testcase_dict["delta"] = error
            if error < 1e-5 # todo: no hardcoded constants
                testcase_dict["passed"] = true
            else
                testcase_dict["passed"] = false
            end
            testcase_dict["result"] = smallrepr(sub.result)
        end
        push!(testcase_array, testcase_dict)
    end
    final_output = Dict(
        "passed" => all(testcase["passed"] for testcase in testcase_array),
        "testcases" => testcase_array,
    )
    return final_output
    JSON.print(out, final_output)
end

function calculate_error(a::Number, b::Number)
    return abs(a - b)
end

# Calculate the error between two arrays.
function calculate_error(a::AbstractArray, b::AbstractArray)
    return maximum(calculate_error.(a, b))
end
