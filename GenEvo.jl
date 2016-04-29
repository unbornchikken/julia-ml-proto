include("ArrayFire/AF.jl")

module GenEvo

using Reexport
@reexport using AF

include("genome/DNA.jl")
include("genome/Synthesizer.jl")
include("genome/MultiScalarRule.jl")
include("genome/ScalarRule.jl")
include("genome/SetRule.jl")

end
