function load_packages(packages::Array{:Symbol})
    for package in packages
        eval(Expr(:using, package))
    end
end
