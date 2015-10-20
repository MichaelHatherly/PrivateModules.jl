__precompile__()

"""
    PrivateModules

Provides an `@private` macro for hiding unexported symbols and scoped import macro `@local`.
"""
module PrivateModules

using Base.Meta, Compat


# Private module macro. #

export @private

"""
    @private module ... end

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
"""
macro private(x) private(x) end

function private(x)
    isexpr(x, :module) || error("not a valid module expression:\n\n$x")

    # Rename module.
    outer = x.args[2]
    inner = symbol(outer, "#private")
    x.args[2] = inner

    # Change `eval` module reference to new inner module.
    x.args[end].args[1].args[end].args[end].args[2] = inner

    # Build outer module.
    out = :(module $outer end)
    push!(out.args[end].args,
        x,                                   # Original module.
        :($(exports)($outer, $inner)),       # Exported symbols.
        macroexpand(:(Base.@__doc__ $outer)) # Documentation.
    )

    Expr(:toplevel, esc(out))
end

"""
    exports(outer, inner)

Import all exported symbols from `inner` module into `outer` one and then re-export them.
"""
function exports(outer, inner)
    symbols = names(inner)
    imports = [Expr(:import, :., module_name(inner), s) for s in symbols]
    eval(outer, Expr(:toplevel, imports...))
    eval(outer, Expr(:toplevel, Expr(:export, symbols...)))
end


# Local imports macro. #

export @local

@eval macro $(:local)(x) localimports(x) end
"""
    @local expression

Local `import`, `importall` and `using` macro.

**Examples**

```julia
function func(args...)
    @local using A, ..B, C.D
    # ...
end
```

Exported symbols from `A`, `..B`, and `C.D` are bound to local constants in `func`'s scope.

```julia
function func(args...)
    @local importall A, ..B, C.D
    # ...
end
```

All symbols from `A`, `..B`, and `C.D` are bound to local constants in `func`'s scope.

```julia
function func(args...)
    @local import A, ..B, C.D
    # ...
end
```

`A`, `B`, and `D` are bound to local constants in `func`'s scope.

**Notes**

- Macros cannot be imported using the `@local` macro.
- Modules listed in `@local` calls must be literals - not variables.
"""
:(@local)

function localimports(x)
    isexpr(x, :toplevel)  ? build(x)          :
    isexpr(x, :import)    ? build(x, nothing) :
    isexpr(x, :using)     ? build(x, false)   :
    isexpr(x, :importall) ? build(x, true)    :
    error("invalid expression given: '@local $x'.")
end

function build(x, flag)
    x.args[1] === :. && unshift!(x.args, :.) # Relative modules are off by one.
    object, name = newmodule(current_module(), x)
    symbols = flag ≡ nothing ? [name] : filter(Base.isidentifier, names(object, flag))
    esc(Expr(:block, [:(const $x = $object.$x) for x in symbols]...))
end
build(x) = Expr(:block, [:(@local $arg) for arg in x.args]...)

function newmodule(parent, x)
    name = gensym("<local-module>")
    eval(parent, :(module $name end))
    anon = getfield(parent, name)
    eval(anon, Expr(:import, x.args...))
    getfield(anon, x.args[end]), x.args[end]
end

end # module
