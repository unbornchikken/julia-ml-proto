include("../GenEvo.jl")

module GenEvoTest

using GenEvo
using Base.Test

function testOnAllContexts(f, title)
    for ctx in [("AF/CPU", ArrayFire{CPU}())]
        println("BEGIN: $title on $(ctx[1])")
        scope!(ctx[2]) do this
            f(ctx[2])
        end
        println("PASSED")
    end
end

# include("dna.jl")
# include("synthesizer.jl")
# include("comparers.jl")
include("optAlgoTests.jl")
include("ga.jl")

end
