function adjacency2modularity(A)
   
    degree_vector = sum(A,2)
    
    total_edges = sum(degree_vector)
    
    # purposeful typo to force throwing error
    B = A - degree_vector*degree_vector'/totla_edges
    return B 
end
