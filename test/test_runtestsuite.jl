using Base.Test, JSON
using ComparativeAutograder

return3good_code = "return3() = 3"

submission_name, submission_fp  = mktemp()
solution_name, solution_fp  = mktemp()
write.([submission_fp, solution_fp], return3good_code)
close.([submission_fp, solution_fp])
testsuite = TestSuite(
    "return3",
    # two tests, each with no args and no kwargs
    [TestCase(()), TestCase(())]
)

test_stdout, test_stderr = @capture_stdstreams begin
    runtestsuite(testsuite, submission_name, submission_name)
end
println(test_stderr)
rm.([submission_name, solution_name])
result = JSON.parse(test_stdout)
