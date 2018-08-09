#!/bin/bash -xe
julia src/main.jl \
    --grader ./test/static/adjacency2modularity/grader.jl \
    --submission $(realpath ./test/static/adjacency2modularity/sol.jl)
