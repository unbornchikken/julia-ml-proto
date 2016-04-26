include("ArrayFire/examples/ML/ANNDemo.jl")
using AF, ANNDemo

af = ArrayFire{CPU}()

setDevice(af, 0)
setSeed(af, 42)

runDemo(af)
