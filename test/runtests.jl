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

end
