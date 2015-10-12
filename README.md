<!-- Generated by Docile.jl -->

# PrivateModules

[![Build Status](https://travis-ci.org/MichaelHatherly/PrivateModules.jl.svg?branch=master)](https://travis-ci.org/MichaelHatherly/PrivateModules.jl) [![Build status](https://ci.appveyor.com/api/projects/status/4w78oghp9pdqtguy?svg=true)](https://ci.appveyor.com/project/MichaelHatherly/privatemodules-jl) [![Coverage Status](http://codecov.io/github/MichaelHatherly/PrivateModules.jl/coverage.svg?branch=master)](http://codecov.io/github/MichaelHatherly/PrivateModules.jl?branch=master)

<a name="Main.PrivateModules"></a>

```
PrivateModules
```

Provides an `@private` macro for hiding unexported symbols.

<hr/>

<a name="PrivateModules.@private"></a>

```
@private module ... end
```

Make unexported symbols in a module private.

**Example**

```julia
using PrivateModules

@private module M

export f

f(x) = g(x, 2x)

g(x, y) = x + y

end

using .M

f(1)      # works
M.g(1, 2) # fails
```
