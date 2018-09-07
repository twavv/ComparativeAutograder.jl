#!/bin/bash -xe

EXERCISE=${1:-"adjacency2modularity"}

julia \
    src/main.jl \
    --grader "./test/static/${EXERCISE}/grader.jl" \
    --submission $(realpath "./test/static/${EXERCISE}/sol.jl")
