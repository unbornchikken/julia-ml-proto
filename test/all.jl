include("../GenEvo.jl")

module GenEvoTest

using GenEvo
using Base.Test

function testOnAllContexts(f, title)
    for ctx in [("AF/CPU", ArrayFire{CPU}())]
        print("DEGIN: $title on $(ctx[1])\n")
        scope!(ctx[2]) do this
            f(ctx[2])
        end
        print("DONE: $title on $(ctx[1])\n")
    end
end

include("dna.jl")

end
