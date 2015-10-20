module Tests

using PrivateModules
using Base.Test

"M"
@private module M

export f

"f"
f(x) = g(x, 2x)

g(x, y) = x + y

export T

type T end

end

@test M.f(0) == 0
@test_throws UndefVarError M.g(0, 0)
@test typeof(M.T) == DataType

@test stringmime("text/markdown", @doc(M)) == "M\n"
@test stringmime("text/markdown", @doc(M.f)) == "f\n"

@test_throws ErrorException PrivateModules.private(:(x + y))

module A

export f

f(x) = 2x

g(x) = 3x

module B

export h

h(x) = 4x

k(x) = 5x

end

end

macro islocal(x)
    quote
        try
            _ = $(esc(x))
            true
        catch err
            isa(err, UndefRefError)
        end
    end
end

function testscopes(x)
    let
        @local using .A

        @test @islocal(f)
        @test f(x) == 2x
        @test !@islocal(g)
        @test A.g(x) == 3x
    end
    let
        @local using .A, .A.B

        @test @islocal(f)
        @test f(x) == 2x
        @test !@islocal(g)
        @test A.g(x) == 3x

        @test @islocal(h)
        @test h(x) == 4x
        @test !@islocal(k)
        @test B.k(x) == 5x
    end
    let
        @local import .A

        @test !@islocal(f)
        @test !@islocal(g)
    end
    let
        @local import .A, .A.B

        @test !@islocal(f)
        @test !@islocal(g)
        @test !@islocal(h)
        @test !@islocal(k)
    end
    let
        @local importall .A

        @test @islocal(f)
        @test @islocal(g)
    end
    let
        @local importall .A, .A.B

        @test @islocal(f)
        @test @islocal(g)
        @test @islocal(h)
        @test @islocal(k)
    end
    let
        @local import PrivateModules

        @test !@islocal(localimports)
        @test !@islocal(build)
        @test !@islocal(newmodule)
    end
    let
        @local using PrivateModules

        @test !@islocal(localimports)
        @test !@islocal(build)
        @test !@islocal(newmodule)
    end
    let
        @local importall PrivateModules

        @test @islocal(localimports)
        @test @islocal(build)
        @test @islocal(newmodule)
    end
end
testscopes(1)

@test_throws ErrorException PrivateModules.localimports(:(a))

end
