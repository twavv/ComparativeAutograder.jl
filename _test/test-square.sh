#!/bin/bash -e

exe="${HOME}/.julia/v0.6/ComparativeAutograder/src/main.jl"

grader=$(realpath "static/square/grader.jl")
submission_good=$(realpath "static/square/submission_good.jl")
submission_bad=$(realpath "static/square/submission_bad.jl")

BOLD=""
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

grade_submission() {
    submission=$1
    output=$(julia --optimize=0 "${exe}" "--grader=$(realpath $grader)" "--submission=$(realpath $submission)")
    if echo "${output}" | jq '{passed}' | grep -q true ; then
        echo "passed"
    else
        echo ${stder} 1>&2
        echo "failed"
    fi
}

should_be() {
    passed=$(grade_submission $1)
    if [ "${passed}" == "$2" ]; then
        echo "${BOLD}${GREEN}OK${NORMAL}: ($1)"
    else
        echo "${BOLD}${RED}FAIL${NORMAL}: ($1) (should be $2, got $passed)."
        exit -1
    fi
}

should_pass() {
    should_be "$1" "passed"
}

should_fail() {
    should_be "$1" "failed"
}

should_pass "${submission_good}"
should_fail "${submission_bad}"
should_fail "static/square/submission_syntax_error.jl"
