#!/usr/bin/env julia
using graderutils: generateCheck, generateTestCase, runTestCases

# Knobs
tol = 1e-8 # Error tolerance
nRandomTests = 10 # Number of random tests
nRange = [20, 30] # Number of parameters

# Random test cases
testCases = []
for _ in 1:nRandomTests
    n = rand(nRange[1]:nRange[2])
    A = randn(n,n)
    A = (A+A') - rand(1:5)*I
       
    push!(testCases, generateTestCase(A; tol=tol))
end

# Run test cases
runTestCases(testCases, @__FILE__)