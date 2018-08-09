# Convert to array, if necessary. Doesn't copy array, if possible
function toArray(array_like)
    return isa(array_like, AbstractArray) ? array_like : collect(array_like)
end

# Determine if the input array_like object is a vector
function isVector(array_like)
    a = toArray(array_like)
    return (ndims(a) <= 2) && (count(d -> (d != 1), size(a)) <= 1)
end

# Determine if the input is a numeric array_like object
function isNumericArray(array_like)
    return eltype(array_like) <: Number
end


# Standardize array
function standardizeArray(array_like)
    a = toArray(array_like)
    return isVector(a) ? vec(a) : a
end

# Compute max absolute error
function max_abs_error(user, sol)
    return maximum(abs, standardizeArray(user) - standardizeArray(sol))
end
