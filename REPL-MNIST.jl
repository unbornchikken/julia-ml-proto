include("ArrayFire/AF.jl")
include("GenEvo.jl")

import AF: ArrayFire, Backend

af = ArrayFire(0)
r = loadSubset(af)
