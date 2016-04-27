include("ArrayFire/AF.jl")

module GenEvo

using Reexport

@reexport using AF

include("genome/DNA.jl")

end
