using Documenter, PrivateModules

makedocs(
    sitename = "PrivateModules.jl",
    modules = [PrivateModules],
    format = Documenter.Formats.HTML,
    clean = false,
    pages = Any["Home" => "index.md"],
)

deploydocs(
    target = "build",
    deps = nothing,
    make = nothing,
    repo = "github.com/MichaelHatherly/PrivateModules.jl.git",
)
