include("../AF.jl")

module AFTest

using AF
using Base.Test

function testOnAllBackends(title, f)
	for b in getSupportedBackends()
		print("$title - $b")
		f(b)
	end
end

include("device.jl")
include("array.jl")

end
