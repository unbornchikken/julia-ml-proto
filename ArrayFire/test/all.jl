include("../AF.jl")

module AFTest

using AF
using Base.Test

function testOnAllBackends(f, title)
	for b in getSupportedBackends()
		print("DEGIN: $title - $b\n")
		f(ArrayFire{b}())
		print("DONE: $title - $b\n")
	end
end

include("device.jl")
include("array.jl")
include("binary.jl")
include("unary.jl")
include("create.jl")
include("vectorAlgos.jl")

end
