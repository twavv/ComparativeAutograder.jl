using ComparativeAutograder: TestSuite, FunctionTestCase, execute_test_suite

function load_student_function(
        file_path,
        function_name,
        )
    modexpr = quote
        module _StudentSubmission
            include($file_path)
        end
    end
    modexpr.head = :toplevel
    # TODO: better error catching when given invalid input.
    # Redirect STDOUT and STDERR while we load the module.
    origstdout = STDOUT
    origstderr = STDERR
    (stdout_read, stdout_write) = redirect_stdout()
    (stderr_read, stderr_write) = redirect_stderr()
    try
        println(origstderr, "Loading student code...")
        eval(modexpr)
    finally
        println(origstderr, "Cleaning up after loading student submission.")
        redirect_stdout(origstdout)
        redirect_stderr(origstderr)
    end
    # try
    #
    # finally
    #     redirect_stdout(origstdout)
    #     redirect_stderr(origstderr)
    # end
    return getfield(_StudentSubmission, Symbol(function_name))
end

function execute_student_test_suite(test_suite, student_file, function_name)
    println(STDERR, "execute_test_suite: Loading student function.")
    student_func = load_student_function(student_file, function_name)
    println(STDERR, "execute_test_suite: Student function loaded.")
    return execute_test_suite(student_func, test_suite)
end
