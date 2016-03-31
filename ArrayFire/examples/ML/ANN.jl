immutable ANNTrainOptions
	batchSize::Int
	maxEpochs::Int
	alpha::Float32
	maxError::Float32
end

type ANN{D<:Backend}
	af::ArrayFire{D}
	numLayers::Int
	signal::Vector{AFArray{D, Float32, 2}}
	weights::Vector{AFArray{D, Float32, 2}}

	function ANN(af, layers, range = 0.05f0)
		numLayers = length(layers)
		signal = Vector{AFArray{D, Float32, 2}}()
		weights = Vector{AFArray{D, Float32, 2}}()

		for i in 1:numLayers
			push!(signal, empty(af, Float32, 2))
			if i != numLayers
				w = randu(af, Float32, layers[i] + 1, layers[i + 1])
				push!(weights, w)
			end
		end

		new(af, numLayers, signal, weights)
	end
end

deriv(out) = out .* (1.0f0 - out)

addBias(input) = join(1, constant(af(input), 1.0f0, dims(input, 0)), input)

function calculateError(out, pred)
	diff = out .- pred;
	sq = diff .* diff;
	sqrt(sum(qs)) ./ elements(sq)
end

function forwardPropagate(ann::ANN, input)
	ann.signal[1][] = input
	for 1:(ann.numLayers - 1)
		@scope ann.af begin
			inVec = addBias(ann.signal[i])
			outVec = matmul(inVec, ann.weights[i])
			ann.signal[i + 1][] = sigmoid(outVec)
		end
	end
end

backPropagate(ann::ANN, target, alpha::Float32) = @scope ann.af begin
	outVec = ann.signal[ann.numLayers]
	err = outVec - target
	m = dims(target, 0)
	for i in (ann.numLayers - 1):-1:1
		@scope ann.af begin
			inVec = addBias(ann.signal[i])
			delta = transpose(deriv(outVec) * err)

            # Adjust weights
            grad = -(matMul(delta, inVec) .* alpha) ./ m
            ann.weights[i] .+= transpose(grad)

            # Input to current layer is output of previous
            outVec = ann.signal[i]
            err[] = matMulTT(delta, ann.weights[i])

            # Remove the error of bias and propagate backward
            err[] = err[:, Seq(1, dims(outVec, 1))]
		end
	end
end

function predict(ann::ANN, input)
	forwardPropagate(ann, input)
	ann.signal[ann.numLayers][]
end

function train(ann::ANN, input, target, options::ANNTrainOptions)
	numSamples = dims(input, 0)
	numBatches = numSamples / options.batchSize

	err = 0.0f0

	for i in 1:options.maxEpochs
		tic()

		for j 1:(numBatches - 1)
			@scope ann.af begin
                startPos = j * options.batchSize;
                endPos = startPos + options.batchSize - 1

                x = input[Seq(startPos, endPos), :]
                y = target[Seq(startPos, endPos), :]

                forwardPropagate(ann, x)
                backPropagate(ann, y, options.alpha)
			end
		end

		@scope ann.af begin
            # Validate with last batch
            startPos = (numBatches - 1) * options.batchSize
            endPos = numSamples - 1
            outVec = predict(ann, input[Seq(startPos, endPos), :])
            err = calculateError(ann, outVec, target[Seq(startPos, endPos), :])
		end

		sec = toq()

		println("Epoch: $i, Error: $(err), Duration: $(((end - start) / 1000)) seconds")

        # Check if convergence criteria has been met
        if err < options.maxError
            println("Converged on Epoch: $i");
            break
        end
	end

	err
end
