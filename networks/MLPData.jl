immutable WeightDim
    rows::Int
    cols::Int
    size::Int

    WeightDim(rows, cols) = new(rows, cols, rows * cols)
end

immutable WeightPos{S}
    seq::S
    dims::Tuple{DimT, DimT}
end

WeightPos{S}(seq::S, dims1, dim2) = WeightPos{S}(deq, (dim1, dim2))

immutable MLPData{C, A}
    ctx::C
    numLayers::Int
    weightCount::Int
    empty::A
    weightsArray::A
    signal::Vector{A}
    weights::Vector{WeightPos}
end

function MLPData{C}(ctx::C, weightDims::Vector{WeightDim})
    numLayers = length(dims) + 1
    empty = array(ctx)
    A = typeof(empty)
    weights = Vector{A}()
    signal = Vector{WeightPos}()
    weightCount = map(d -> d.size, weightDims) |> sum
    weightsArray = array(ctx, Float32, weightCount)
    wIdx = 0
    for i in 1:numLayers
        push!(signal, array(ctx))
        if i != numLayers
            dims = weightDims[i]
            push!(weights, WeightPos(seq(ctx, wIdx, wIdx + dims.size - 1), dims.rows, dims.cols))
            wIdx += dims.size
        end
    end
    MLPData{C, A}(ctx, numLayers, weightCount, empty, weightsArray, signal, weights)
end

function release!(mlp::MLPData)
    release!(mlp.weightsArray)
    for s in mlp.signal
        release!(s)
    end
end

function addBias!(mlp::MLPData, input)
    joinArrays(1, constant(mlp.ctx, 1.0f0, dims(input, 0)), input)
end

function predict!(impl, mlp::MLPData, input)
    ann.signal[1][] = input
    for i in 1:mlp.numLayers - 1
        scope!(mlp.ctx) do this
            inVec = makeInputVector(impl, i)
            weights = mlp.weights[i]
            currWeights = moddims(mlp.weightsArray[weights.seq], weights.dims...);
            outVec = matmul(inVec, currWeights)
            mlp.signal[i + 1][] = sigmoid(outVec)
        end
    end
    ann.signal[mlp.numLayers]
end

function setWeights!(mlp::MLPData, weights)
    @assert dims(weights) == dims(mlp.weightsArray)
    mlp.weightsArray[] = weights
end

reset!(mlp::MLPData) = for s in mlp.signal
    s[] = mlp.empty
end

arrayType{C, A}(mlp::MLPData{C, A}) = A
