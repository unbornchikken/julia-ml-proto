export RecMLP, reset!

immutable RecMLP{C} <: MLP
    layers::Vector{Int}
    data::MLPData{C}
end

function RecMLP{C}(ctx::C, layers::Vector{Int})
    numLayers = length(layers)
    dims = Vector{WeightDim}()
    for i in 1:numLayers - 1
        rows = (layers[i] + 1)
        for next in i + 1:numLayers
            rows += layers[next]
        end
        cols = layers[i + 1]
        push!(dims, WeightDim(rows, cols))
    end
    RecMLP{C}(layers, MLPData(RecMLP{C}, ctx, dims))
end

function makeInputVector(mlp::RecMLP, index)
    input = addBias!(mlp.data, mlp.data.signal[index])
    batchSize = dims(input, 0)
    outputs = Nullable{arrayType(mlp.data)}()
    for next in index + 1:mlp.data.numLayers
        output = mlp.data.signal[next]
        outputSize = mlp.layers[next]
        if isEmpty(output)
            output = constant(mlp.data.ctx, 0f0, batchSize, outputSize)
        elseif dims(output, 0) != batchSize
            error("Size of batches must be the same. Last batch size was $(dims(output, 0)) and current is $batchSize.")
        end
        outputs = isnull(outputs) ? output : joinArrays(1, get(outputs), output)
    end
    joinArrays(1, input, get(outputs))
end

reset!(mlp::RecMLP) = reset!(mlp.data)
