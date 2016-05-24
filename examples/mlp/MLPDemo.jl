include("../MNIST/MNIST.jl")

module MLPDemo

using MNIST, GenEvo

export runDemo

runDemo(ctx) = scope!(ctx) do this
    const batchSize = 1000

    println("Setting up training data.")

    data = loadSubset(ctx)

    println("MNIST Training sample count: $(numTrain(data))")
    println("MNIST Test sample count: $(numTest(data))")
    println("MNIST Feature size: $(featureSize(data))")

    validateSampleCount = numTrain(data) % batchSize
    if validateSampleCount < 10
        validateSampleCount += batchSize
    end
    const trainSampleCount = numTrain(data) - validateSampleCount

    println("Training sample count: $trainSampleCount")
    println("Validate sample count: $validateSampleCount")

    const trainImages = data.trainImages[seq(ctx, 0, trainSampleCount - 1), :]
    const trainLabels = data.trainLabels[seq(ctx, 0, trainSampleCount - 1), :]
    @assert dims(trainImages, 0) == trainSampleCount

    const validateImages = data.trainImages[seq(ctx, trainSampleCount, numTrain(data) - 1), :]
    const validateLabels = data.trainLabels[seq(ctx, trainSampleCount, numTrain(data) - 1), :]
    @assert dims(validateImages, 0) == validateSampleCount

    batcher = ForwardBatcher(ctx, trainImages, trainLabels, batchSize)

    println("Creating Network.")
    network = FFMLP(ctx, [featureSize(data), 100, 50, numClasses(data)])
    println(network)

    bestMSE = 2f0
    function fitness(arr)
        setWeights!(network, arr)
        batchInputs, batchTargets = current(batcher)
        output = predict!(network, batchInputs)
        mse = calculateMSE(ctx, output, batchTargets)
        bestMSE = min(bestMSE, mse)
        mse
    end

    println("Initializing algorithms.")

    const synth = Synthesizer(ctx)
    define!(synth, ScalarRule(count = weightCount(network), min = -0.7f0, max = 0.7f0, variationCount = 1))

    const algo = CrossEntropy(
        ctx,
        dnaSize!(synth),
        CalculateComparer(fitness),
        dna -> decodeAsContextArray(synth, dna),
        populationSize = 30,
        mutationChance = 0.03f0,
        mutationStrength = 0.1f0,
        selectionStdDev = 0.3f0,
        keepElitesRate = 0.05f0)

    next!(batcher)
    start!(algo)

    println("Starting optimization loop.")
    const maxIterations = 300
    t = time()
    sec = @elapsed for i in 1:maxIterations
        next!(batcher)
        lastTime = @elapsed step!(algo)
        now = time()
        if now - t >= 5.0
            println(i, ". ",lastTime," : " ,bestMSE)
            t = now
        end
        sync(ctx)
    end

    println("\nDONE.\n\nResults:\n")

    trainOutput = predict!(network, trainImages)

    println("Training set:")
    println("Accuracy on training data: $(accuracy(ctx, trainOutput, trainLabels))")

    validateOutput = predict!(network, validateImages)

    println("Validation set:")
    println("Accuracy on testing  data: $(accuracy(ctx, validateOutput, validateLabels))")

    println("Training time: $sec seconds")
end

function calculateMSE(ctx, output, target)
    scope!(ctx) do this
        dif = output .- target
        sq = dif .* dif
        s = sum(Float32, sq)
        s / elements(output)
    end
end

function accuracy(ctx, predicted, target)
    scope!(ctx) do this
        pMaxArray, pMaxIndex = imax(predicted, 1)
        tMaxArray, tMaxIndex = imax(target, 1)
        (100.0f0 * count(Float32, pMaxIndex .== tMaxIndex)) / elements(tMaxIndex)
    end
end

end
