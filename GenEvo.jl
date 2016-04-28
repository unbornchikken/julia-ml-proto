include("ArrayFire/AF.jl")

module GenEvo

using Reexport
@reexport using AF
using Loggig

include("genome/DNA.jl")

end
