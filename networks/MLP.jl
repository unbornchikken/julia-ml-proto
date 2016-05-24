export MLP, weightCount, release!, predict!, setWeights!

abstract MLP

weightCount(mlp::MLP) = mlp.data.weightCount

release!(mlp::MLP) = release!(mlp.data)

predict!(mlp::MLP, input) = predict!(mlp, mlp.data, input)

setWeights!(mlp::MLP, weights) = setWeights!(mlp.data, weights)
