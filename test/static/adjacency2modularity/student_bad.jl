function adjacency2modularity(A)
   
    degree_vector = sum(A,2)
    
    total_edges = sum(degree_vector)
    
    B = A - degree_vector*degree_vector'
    return B 
end
