immutable ANNTrainOptions
    alpha::Float32
    maxEpochs::Int
    batchSize::Int
    maxError::Float32
end

type ANN{B<:Backend}
    af::ArrayFire{B}
    numLayers::Int
    signal::Vector{AFArray{B}}
    weights::Vector{AFArray{B}}
end

function ANN{B}(af::ArrayFire{B}, layers::Vector{Int}, range = 0.05f0)
    numLayers = length(layers)
    signal = Vector{AFArray{B}}()
    weights = Vector{AFArray{B}}()

    for i in 1:numLayers
        push!(signal, array(af))
        if i != numLayers
            w = randu(af, Float32, layers[i] + 1, layers[i + 1]) .* range .- (range / 2.0f0)
            push!(weights, w)
        end
    end

    ANN(af, numLayers, signal, weights)
end

function deriv(out)
    out .* (1.0f0 .- out)
end

function addBias(ann::ANN, input)
    joinArrays(1, constant(ann.af, 1.0f0, dims(input, 0)), input)
end

function calculateError(out, pred)
    diff = out .- pred;
    sq = diff .* diff;
    sqrt(sum(Float32, sq)) / elements(sq)
end

function forwardPropagate(ann::ANN, input)
    ann.signal[1][] = input
    for i in 1:ann.numLayers - 1
        scope!(ann.af) do this
            inVec = addBias(ann, ann.signal[i])
            outVec = matmul(inVec, ann.weights[i])
            ann.signal[i + 1][] = sigmoid(outVec)
        end
    end
end

backPropagate(ann::ANN, target, alpha::Float32) = scope!(ann.af) do this
    outVec = ann.signal[ann.numLayers]
    err = outVec .- target
    m = dims(target, 0)
    for i in ann.numLayers - 1:-1:1
        scope!(ann.af) do this
            inVec = addBias(ann, ann.signal[i])
            delta = transpose(deriv(outVec) .* err)

            # Adjust weights
            grad = (-alpha .* matmul(delta, inVec)) ./ m
            addAssign!(ann.weights[i], transpose(grad))

            # Input to current layer is output of previous
            outVec = ann.signal[i]
            allErr = matmulTT(delta, ann.weights[i])

            # Remove the error of bias and propagate backward
            err[] = allErr[:, seq(ann.af, 1, dims(outVec, 1))]
        end
    end
end

function predict(ann::ANN, input)
    forwardPropagate(ann, input)
    ann.signal[ann.numLayers][]
end

function train(ann::ANN, input, target, options::ANNTrainOptions)
    af = ann.af
    numSamples = dims(input, 0)
    numBatches = Int(floor(numSamples / options.batchSize))

    err = 0.0f0
    allSec = 0.0f0

    sync(af)

    for i in 1:options.maxEpochs
        scope!(af) do this
            sec = @elapsed begin
                for j in 0:numBatches - 2
                    scope!(af) do this
                        startPos = j * options.batchSize
                        endPos = startPos + options.batchSize - 1

                        x = input[seq(af, startPos, endPos), :]
                        y = target[seq(af, startPos, endPos), :]

                        forwardPropagate(ann, x)
                        backPropagate(ann, y, options.alpha)
                    end
                end

                # Validate with last batch
                startPos = (numBatches - 1) * options.batchSize
                endPos = numSamples - 1

                outVec = predict(ann, input[seq(af, startPos, endPos), :])
                err = calculateError(outVec, target[seq(af, startPos, endPos), :])
            end

            allSec += sec;

            if i % 10 == 0
                println("Epoch: $i, Error: $err, Duration: $allSec seconds")
                allSec = 0.0f0
            end
        end

        # Check if convergence criteria has been met
        if err < options.maxError
            println("Converged on Epoch: $i");
            break
        end
    end

    err
end
