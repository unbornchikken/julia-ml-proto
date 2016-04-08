include("ArrayFire/examples/ML/ANNDemo.jl")
using AF, ANNDemo

af = ArrayFire{CUDA}()

setSeed(af, rand(UInt64))

runDemo(af)
