include("examples/mlp/MLPDemo.jl")
using AF, MLPDemo

af = ArrayFire{CPU}()

runDemo(af)
