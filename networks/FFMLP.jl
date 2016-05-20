export FFMLP, release!, predict!, setWeights!, reset!

immutable FFMLP{C} <: MLP
    layers::Vector{Int}
    net::ANN{C}
end

function FFMLP{C}(ctx::C, layers::Vector{Int})
    numLayers = length(layers)
    dims = Vector{WeightDim}()
    for i in 1:numLayers - 1
        rows = (layers[i] + 1)
        cols = layers[i + 1]
        push!(dims, WeightDim(rows, cols))
    end
    FFMLP{C}(layers, ANN(FFMLP{C}, ctx, dims))
end

makeInputVector(mlp::FFMLP, index) = addBias!(mlp.net, mlp.signal[index])

release!(mlp::FFMLP) = release!(mlp.net)

predict!(mlp::FFMLP, input) = predict!(mlp, mlp.net, input)

setWeights!(mlp::FFMLP, weights) = setWeights!(mlp.net, weights)

reset!(mlp::FFMLP) = reset!(mlp.net)
