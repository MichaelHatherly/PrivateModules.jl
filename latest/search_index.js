var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PrivateModules-1",
    "page": "Home",
    "title": "PrivateModules",
    "category": "section",
    "text": "Make unexported symbols private."
},

{
    "location": "index.html#Contents-1",
    "page": "Home",
    "title": "Contents",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "This package is registered in METADATA.jl and so can be installed using Pkg.addPkg.add(\"PrivateModules\")"
},

{
    "location": "index.html#PrivateModules",
    "page": "Home",
    "title": "PrivateModules",
    "category": "Module",
    "text": "Provides an @private macro for hiding unexported symbols and scoped import macro @local.\n\n\n\n"
},

{
    "location": "index.html#PrivateModules.@private",
    "page": "Home",
    "title": "PrivateModules.@private",
    "category": "Macro",
    "text": "Make unexported symbols in a module private.\n\nSignature\n\n@private module ... end\n\nExample\n\nusing PrivateModules\n\n@private module M\n\nexport f\n\nf(x) = g(x, 2x)\n\ng(x, y) = x + y\n\nend\n\nusing .M\n\nf(1)      # works\nM.g(1, 2) # fails\n\n\n\n"
},

{
    "location": "index.html#PrivateModules.@local",
    "page": "Home",
    "title": "PrivateModules.@local",
    "category": "Macro",
    "text": "Local import, importall and using macro.\n\nSignature\n\n@local expression\n\nExamples\n\nfunction func(args...)\n    @local using A, ..B, C.D\n    # ...\nend\n\nExported symbols from A, ..B, and C.D are bound to local constants in func's scope.\n\nfunction func(args...)\n    @local importall A, ..B, C.D\n    # ...\nend\n\nAll symbols from A, ..B, and C.D are bound to local constants in func's scope.\n\nfunction func(args...)\n    @local import A, ..B, C.D\n    # ...\nend\n\nA, B, and D are bound to local constants in func's scope.\n\nNotes\n\nMacros cannot be imported using the @local macro.\nModules listed in @local calls must be literals - not variables.\n\n\n\n"
},

{
    "location": "index.html#Public-Interface-1",
    "page": "Home",
    "title": "Public Interface",
    "category": "section",
    "text": "PrivateModules\n@private\n@local"
},

{
    "location": "index.html#PrivateModules.exports",
    "page": "Home",
    "title": "PrivateModules.exports",
    "category": "Function",
    "text": "Signature\n\nexports(outer, inner)\n\nImport all exported symbols from inner module into outer one and then re-export them.\n\n\n\n"
},

{
    "location": "index.html#Internals-1",
    "page": "Home",
    "title": "Internals",
    "category": "section",
    "text": "PrivateModules.exports"
},

]}
