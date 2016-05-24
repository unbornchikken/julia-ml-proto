export FFMLP, reset!

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

makeInputVector(mlp::FFMLP, index) = addBias!(mlp.data, mlp.data.signal[index])

reset!(mlp::FFMLP) = nothing

Base.show(io::IO, mlp::FFMLP) = print(io, "Feed Forward Multiplayer Perceptron\nLayers: $(mlp.layers)\nData: $(mlp.data)")
