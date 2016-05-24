include("examples/mlp/MLPDemo.jl")
using AF, MLPDemo

af = ArrayFire{CUDA}()

runDemo(af)
