export FFMLP, release!, predict!, setWeights!, reset!

immutable FFMLP{C} <: MLP
    layers::Vector{Int}
    data::MLPData{C}
end

function FFMLP{C}(ctx::C, layers::Vector{Int})
    numLayers = length(layers)
    dims = Vector{WeightDim}()
    for i in 1:numLayers - 1
        rows = (layers[i] + 1)
        cols = layers[i + 1]
        push!(dims, WeightDim(rows, cols))
    end
    FFMLP{C}(layers, MLPData(ctx, dims))
end

makeInputVector(mlp::FFMLP, index) = addBias!(mlp.data, mlp.signal[index])

release!(mlp::FFMLP) = release!(mlp.data)

predict!(mlp::FFMLP, input) = predict!(mlp, mlp.data, input)

setWeights!(mlp::FFMLP, weights) = setWeights!(mlp.data, weights)

reset!(mlp::FFMLP) = reset!(mlp.data)

Base.show(io::IO, mlp::FFMLP) = print(io, "Feed Forward Multiplayer Perceptron\nLayers: $(mlp.layers)\nData: $(mlp.data)")
