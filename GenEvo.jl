include("ArrayFire/AF.jl")

module GenEvo

using Reexport
@reexport using AF

import AF: release!, copy, eval!

include("genome/DNA.jl")
include("genome/Synthesizer.jl")
include("genome/MultiScalarRule.jl")
include("genome/ScalarRule.jl")
include("genome/SetRule.jl")

include("algorithms/algoTypes.jl")
include("algorithms/Comparer.jl")
include("algorithms/ArrayComparer.jl")
include("algorithms/CalculateComparer.jl")
include("algorithms/FastComparer.jl")
include("algorithms/Entity.jl")
include("algorithms/BestEntity.jl")
include("algorithms/Population.jl")
include("algorithms/PopulationManager.jl")
include("algorithms/Epoch.jl")
include("algorithms/GA.jl")
include("algorithms/CrossEntropy.jl")
include("algorithms/PSO.jl")

end
