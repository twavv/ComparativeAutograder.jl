function plot10(fab::Fab)
    return fab.f.(linspace(fab.a, fab.b, 10))
end
