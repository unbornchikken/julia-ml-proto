include("../MNIST/MNIST.jl")

module MLPDemo

using MNIST, AF, GenEvo

export runDemo

runDemo(ctx) = scope!(ctx) do this
    const batchSize = 1000

    println("Setting up training data.")

    data = loadSubset(ctx)

    println("MNIST Training sample count: $(numTrain(data))")
    println("MNIST Test sample count: $(numTest(data))")
    println("MNIST Feature size: $(featureSize(data))\n")

    const validateSampleCount = numTrain(data) % batchSize
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

    println("Creating Network.\n")
    network = FFMLP(ctx, [featureSize(data), 100, 50, numClasses(data)])
    println(network)

    function fitness(arr)
        setWeights!(network, arr)
    end
end

end
