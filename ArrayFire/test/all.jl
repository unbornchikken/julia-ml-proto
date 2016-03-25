include("../AF.jl")

module AFTest

using AF
using Base.Test

function testOnAllBackends(title, f)
	for b in getSupportedBackends()
		print("DEGIN: $title - $b\n")
		f(ArrayFire{b}())
		print("DONE: $title - $b\n")
	end
end

include("device.jl")
include("array.jl")

end
