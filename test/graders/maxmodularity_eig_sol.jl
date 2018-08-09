function maxmodularity_eig_sol(B)
    n = size(B,1)
    s = sqrt(n)*eigs(B;nev=1,which=:LR)[2]
    s = sign(s[1])*s # to make s unique
    return s
end