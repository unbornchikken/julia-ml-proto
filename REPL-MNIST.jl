include("ArrayFire/examples/ML/ANNDemo.jl")
using AF, ANNDemo

af = ArrayFire{CUDA}()

runDemo(af)
