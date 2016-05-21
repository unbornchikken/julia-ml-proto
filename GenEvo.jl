include("ArrayFire/AF.jl")

module GenEvo

using Reexport
@reexport using AF

import AF: release!, copy, eval!

include("utils.jl")
include("genome/index.jl")
include("algorithms/index.jl")
include("networks/index.jl")
include("data/index.jl");

end
