# Package development
## How to CODE
In general, we prefer using [Juno](http://docs.junolab.org/latest/man/installation.html).
Jupyter notebooks with [IJulia](https://github.com/JuliaLang/IJulia.jl) kernel is suited for writting simple code, but it is well known as hard to be version controlled.

Coding in `vim` directly is not recommended since running code line by line is nessesary for debuging Julia programs (There is no `jdb`!).

## How to develop a Project
### Start a new project
https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Creating-your-own-projects-1

##### comments
* `activate .` sould be used when you are going to change the dependancy of a project in current folder (i.e. changing `./Project.toml`).
* `uuid` contains the information of both package name and version number.

### setup continuous integration
To run a test, type `julia test/runtests.jl`.
To setup continuous integration for your tests and documents, you need
1. [get started](https://docs.travis-ci.com/user/getting-started/) with Travis-ci,
2. [configure `.travis.yml`](https://docs.travis-ci.com/user/customizing-the-build/)
3. [setup julia build](https://docs.travis-ci.com/user/languages/julia/),
4. [add building status badge](https://docs.travis-ci.com/user/status-images/)
5. setup [CodeCov](https://codecov.io/) to ensure test coverage,
7. use [Documenter](https://github.com/JuliaDocs/Documenter.jl/blob/master/docs/src/man/hosting.md) to deploy documents.
8. it is interesting to see how other projects (e.g. [FunnyTN](https://github.com/QuantumBFS/FunnyTN.jl)) works.

### Register your package
See [METADATA](https://github.com/JuliaLang/METADATA.jl) for detail.
