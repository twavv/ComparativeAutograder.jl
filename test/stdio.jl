using Test
using ComparativeAutograder
using ComparativeAutograder: @capture_stdstreams, smallrepr, truncatestring, errorstring

@testset "Test @capture_stdstreams" begin
    out, err = @capture_stdstreams begin
        println(stdout, "Hello, stdout!")
        println(stderr, "Hello, stderr!")
    end
    @test out == "Hello, stdout!\n"
    @test err == "Hello, stderr!\n"

    out, err = @capture_stdstreams begin
        @debug "Hello, world."
    end
    @test occursin("Debug:", err)
    @test occursin("Hello, world.", err)
    @test out == ""
end

@testset "Test smallrepr" begin
    # The `repr` of this has length 4001000 and the smallrepr has length 1587.
    onesrepr = smallrepr(ones(1000, 1000))
    @test length(onesrepr) <= 2000
    @test startswith(onesrepr, "1000×1000 Array{Float64,2}:\n")
    @test smallrepr("foo") == "\"foo\""
end

@testset "Test truncatestring" begin
    @test truncatestring("foo") == "foo"
    @test truncatestring("foo", 1) == "f...\n[ TRUNCATED ]"
    foos = repeat("foo", 12345)
    @test length(truncatestring(foos)) < length(foos)
end

function get_exception(f::Function)
    try
        f()
    catch exc
        return exc
    end
    return nothing
end

@testset "Test errorstring" begin
    @test errorstring("foo") == "foo"

    @testset "Test errorstring for builtin exception types." begin
        boundserror = errorstring(get_exception() do
            myarray = [1, 2, 3]
            value = myarray[4]
        end)
        @test occursin("BoundsError", boundserror)
        @test occursin("at index", boundserror)

        errorexception = errorstring(get_exception() do
            error("foo")
        end)
        @test occursin("ErrorException", errorexception)
        @test occursin("foo", errorexception)
    end

    # In Julia, anything can be thrown (including structs, primitives, etc.)
    @testset "Test errorstring for nonstandard exception types." begin
        interror = errorstring(get_exception(() -> throw(123)))
        @test occursin("123", interror)
    end
end
