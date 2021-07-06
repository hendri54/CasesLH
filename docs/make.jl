using CasesLH
using Documenter

DocMeta.setdocmeta!(CasesLH, :DocTestSetup, :(using CasesLH); recursive=true)

makedocs(;
    modules=[CasesLH],
    authors="hendri54 <hendricksl@protonmail.com> and contributors",
    repo="https://github.com/hendri54/CasesLH.jl/blob/{commit}{path}#{line}",
    sitename="CasesLH.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
