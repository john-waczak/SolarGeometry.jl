using SolarGeometry
using Documenter

DocMeta.setdocmeta!(SolarGeometry, :DocTestSetup, :(using SolarGeometry); recursive=true)

makedocs(;
    modules=[SolarGeometry],
    authors="John Waczak <john.louis.waczak@gmail.com>",
    repo="https://github.com/john-waczak/SolarGeometry.jl/blob/{commit}{path}#{line}",
    sitename="SolarGeometry.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://john-waczak.github.io/SolarGeometry.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/john-waczak/SolarGeometry.jl",
    devbranch="main",
)
