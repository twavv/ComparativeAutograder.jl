struct TestSuiteResult
    # Time elapsed during testing (including the time taken to load the student
    # submission but excluding time taken to setup ComparativeAutograder
    # process internals).
    time::Float64

    # The array of produced TestCaseResult's.
    # May be nothing if and only if exception is not nothing.
    results::Union{AbstractArray{TestCaseResult}, Nothing}

    # A string representation of the exception (if any) that occurred while
    # executing the test suite as a whole.
    # This includes things like not being able to find the specified function
    # from a student submission but does NOT include exceptions raised for
    # individual test cases (even if every test case failed).
    # This should also be used to signal an exception that occurred within the
    # ComparativeAutograder internals (in which case the process status/exit
    # code should be non-zero).
    # May be nothing if and only if results is not nothing.
    # Note: exception is a string to avoid breaking (de)serialize if the
    # exeption happens to reference context-specific data (eg. something in the
    # _Submission module which wouldn't be present in the parent process).
    exception::Union{AbstractString, Nothing}
    # Backtrace of the exception; set if and only if exception is set.
    backtrace::Union{AbstractString, Nothing}

    stdout::AbstractString
    stderr::AbstractString
end

# TRAVIS YOU FUCK FACE, READ ME
# Okay, so, to be fair, runtestsuite/runtestcase aren't appropriately named
# because they sound like they should do similar things, but they don't:
# runtestcase simply takes a function and a TestCase and executes it in the
# calling Julia process, but runtestsuite starts subprocesses. We can't name
# runtestsuite "runtests" because Base.runtests is a very popular thing indeed.
# Maybe change runtestcase to executetestcase? We could also have an
# executetestsuite method that the runner could call (this might also make
# testing a bit easier).

# ALSO: we could either have runtestsuite output a JSON string or write to a
# file; this could be controlled by a kwarg, or, if not specified, by looking
# for an environment variable called something like
# "COMPARATIVE_AUTOGRADER_OUTFILE". This would get around issues where doing a
# simple println(...) in the setup/grader code corrupts the entire output.
function runtestsuite(
    testsuite::TestSuite,
    solution_filename::Union{AbstractString,Nothing}=nothing,
    submission_filename::Union{AbstractString,Nothing}=nothing,
)#::TestSuiteResult
    if solution_filename == nothing
        solution_filename = ARGS[1]
    end
    if submission_filename == nothing
        submission_filename = ARGS[2]
    end
    log("Running test suite for function $(testsuite.functionname) in file $submission_filename.")
    writetestsuite(testsuite)
    submission_task = @async launch_runner_proc(testsuite, submission_filename)
    solution_task = @async launch_runner_proc(testsuite, solution_filename)
    submission_result = wait(submission_task)
    solution_result = wait(solution_task)
    #log(submission_result)
    # TODO: raise an error if either subprocess returned nonzero
    log("Sumbission runner status: $(submission_result.status).")
    log("Solution runner status: $(solution_result.status).")
    if solution_result.status != 0
        log("Solution runner exited with nonzero status code.")
        log("Solution runner stderr:\n$(chomp(solution_result.stderr))")
    end
    if submission_result.status != 0
        log("Submission runner exited with nonzero status code.")
        log("Solution runner stderr:\n$(chomp(submission_result.stderr))")
    end
    if solution_result.status != 0 || submission_result.status != 0
        output_error_dict(
            "A runner subprocess exited non-zero "
            * "(solution: $(solution_result.status), "
            * "submission: $(submission_result.status))."
        )
        exit(1)
    end
    # return compare_testsuiteresults(submission_result, solution_result)
    output_test_results(solution_result.result, submission_result.result)
end

function writetestsuite(testsuite::TestSuite)::String
    (path, io) = mktemp()
    serialize(io, testsuite)
    close(io)
    log("Wrote testsuite to $path.")
    return path
end
