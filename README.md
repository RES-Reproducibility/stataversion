# stataversion

This contains code to accompany a blog post on stata versioning issues.

## How to use

1. [download julia](https://github.com/JuliaLang/juliaup)
2. clone this repo `somewhere`
3. `cd somewhere`
4. launch julia with associated project in `somewhere`: `julia --project=.`
5. get dependencies: `] instantiate`
6. type: `include("runblog.jl")` to load code.
7. type: `run()` to run. You need to have the [docker](https://www.docker.com) daemon running.