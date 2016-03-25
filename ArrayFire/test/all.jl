include("../AF.jl")

module AFTest

using AF
using Base.Test

function testOnAllBackends(title, f)
	for b in getSupportedBackends()
		print("$title - $b\n")
		af = ArrayFire{b}()
		try
			f(af)
		finally
			release!(af)
		end
	end
end

include("device.jl")
include("array.jl")

end
