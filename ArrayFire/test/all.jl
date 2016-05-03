include("../AF.jl")

module AFTest

using AF
using Base.Test

function testOnAllBackends(f, title)
    for b in getSupportedBackends()
        println("DEGIN: $title on $b")
        af = ArrayFire{b}()
        scope!(af) do this
            f(af)
        end
        println("PASSED")
    end
end

include("device.jl")
include("array.jl")
include("binary.jl")
include("unary.jl")
include("create.jl")
include("vectorAlgos.jl")
include("modify.jl")
include("reduction.jl")

end
