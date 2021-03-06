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

WeightPos{S}(seq::S, dim1, dim2) = WeightPos{S}(seq, (dim1, dim2))

Base.show(io::IO, pos::WeightPos) = print(io, "< Size: $(pos.dims), Seq: $((seqBegin(pos.seq),seqEnd(pos.seq))) >")

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
    numLayers = length(weightDims) + 1
    empty = array(ctx)
    A = typeof(empty)
    weights = Vector{WeightPos}()
    signal = Vector{A}()
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

Base.show(io::IO, mlp::MLPData) = print(io, "Weight Count: $(mlp.weightCount)\nWeight Layout: $(mlp.weights)")

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
    mlp.signal[1][] = input
    const eof = mlp.numLayers - 1
    for i in 1:eof
        scope!(mlp.ctx) do this
            inVec = makeInputVector(impl, i)
            weights = mlp.weights[i]
            currWeights = moddims(mlp.weightsArray[weights.seq], weights.dims...)
            outVec = matmul(inVec, currWeights)
            if i == eof
                mlp.signal[i + 1][] = sigmoid(outVec)
            else
                mlp.signal[i + 1][] = sin(outVec ./ 4f0)
            end
        end
    end
    mlp.signal[mlp.numLayers]
end

function setWeights!(mlp::MLPData, weights)
    @assert dims(weights) == dims(mlp.weightsArray)
    mlp.weightsArray[] = weights
end

reset!(mlp::MLPData) = for s in mlp.signal
    s[] = mlp.empty
end

arrayType{C, A}(mlp::MLPData{C, A}) = A
