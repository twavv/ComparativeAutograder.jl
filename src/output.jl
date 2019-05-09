"""
    results_dict(suite, submission, solution)
    results_dict(testcase, submission, solution)

Convert the test suite or case into a `Dict` form.

This is used to create a `json`able representation of a test suite/case.
"""
function results_dict(
    suite::TestSuite,
    submission::TestSuiteResult,
    solution::TestSuiteResult,
)
    test_cases = [
        results_dict(
            case,
            submission.results[i],
            solution.results[i],
        )
        for (i, case) in enumerate(suite.cases)
    ]
    return Dict(
        "passed" => all(case -> case["passed"], test_cases),
        "testCases" => test_cases,
    )
end

function results_dict(
    case::TestCase,
    submission::TestCaseResult,
    solution::TestCaseResult,
)
    out, err = truncatestring.([submission.stdout, submission.stderr])
    if solution.exception !== nothing
        return Dict(
            "passed" => false,
            "error" => "Solution code threw an exception on the input.",
            "errorDescription" => "$(solution.exception)\n$(solution.backtrace)",
        )
    end
    if submission.exception !== nothing
        return Dict(
            "passed" => false,
            "error" => "Submission code threw an exception on the input.",
            "errorDescription" => "$(submission.exception)\n$(submission.backtrace)",
            "stdout" => out,
            "stderr" => err,
        )
    end

    delta = δ(solution.result, submission.result)
    return Dict(
        "passed" => delta < case.tolerance,
        "delta" => delta,
        "result" => smallrepr(submission.result),
        "stdout" => out,
        "stderr" => err,
    )
end
