__precompile__()

"""
Provides an [`@private`](@ref) macro for hiding unexported symbols and scoped import macro
[`@local`](@ref).
"""
module PrivateModules

using Base.Meta, Compat


# Private module macro. #

export @private

"""
Make unexported symbols in a module private.

**Signature**

```julia
@private module ... end
```

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
    inner = Symbol(outer, "#private")
    x.args[2] = inner

    # The inner module's `eval` should eval inside the inner module, not the outer one.
    unshift!(x.args[end].args, :(eval{T}(x::T) = Core.eval($inner, x)))

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
**Signature**

```julia
exports(outer, inner)
```

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
Local `import`, `importall` and `using` macro.

**Signature**

```julia
@local expression
```

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

- Macros cannot be imported using the [`@local`](@ref) macro.
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
    build(newmodule(current_module(), x)..., flag)
end
build(x) = Expr(:block, [:(@local $arg) for arg in x.args]...)

function build(object :: Module, name, flag)
    symbols = flag ≡ nothing ? [name] : filter(Base.isidentifier, names(object, flag))
    esc(Expr(:block, [:(const $x = $object.$x) for x in symbols]...))
end
build(object, name, flag) = esc(:(const $name = $object))

function newmodule(parent, x)
    name = gensym("<local-module>")
    eval(parent, :(module $name end))
    anon = getfield(parent, name)
    eval(anon, Expr(:import, x.args...))
    getfield(anon, x.args[end]), x.args[end]
end

end # module
