using Documenter
using ACS

makedocs(
    sitename = "ACS.jl",
    format = Documenter.HTML(),
    modules = [ACS],
    pages = [
        "Home" => "index.md",
        "API Functions" => "api/functions.md",
        "Examples" => "examples.md",
        "Contributing" => "contributing.md"
    ],
    remotes = nothing  # Disable remote source links since we're not in a Git repo yet
)

# Uncomment this when ready to deploy to GitHub Pages
# deploydocs(
#     repo = "github.com/USERNAME/ACS.jl.git",
# ) 