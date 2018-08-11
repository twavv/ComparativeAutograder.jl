using ComparativeAutograder: @solution, @testcase

@solution function adjacency2modularity(A)
    degree_vector = sum(A,2)
    total_edges = sum(degree_vector)
    B = A - degree_vector*degree_vector'/total_edges
    return B
end

@testcase adjacency2modularity(randn(10, 10))
@testcase adjacency2modularity(randn(10, 10))
@testcase adjacency2modularity(randn(10, 10))
