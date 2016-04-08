include("../MNIST/MNIST.jl")

module ANNDemo

using MNIST, AF

export runDemo

include("ANN.jl")

function accuracy(predicted, target)
	pMaxArray, pMaxIndex = imax(predicted, 1)
	tMaxArray, tMaxIndex = imax(target, 1)
	(100.0f0 * count(pMaxIndex .== tMaxIndex)) / elements(tMaxIndex)
end

function runDemo(af)
	println("Setting up training data.")

	data = loadSubset(af)

    featureSize = DimT(elements(data.trainImages) / data.numTrain);

    println("Reshaping images into feature vectors.")
    trainFeats = transpose(moddims(data.trainImages, featureSize, data.numTrain));
    testFeats = transpose(moddims(data.testImages, featureSize, data.numTest));

	println("Creating targets.")
    trainTarget = transpose(data.trainLabels);
    testTarget = transpose(data.testLabels);

	println("Creating Network.")
    network = ANN(af, [dims(trainFeats, 1), 100, 50, data.numClasses]);

	println("Starting.")

	sec = @elapsed begin
	    train(
			network,
	        trainFeats,
	        trainTarget,
	        ANNTrainOptions(2.0f0, 250, 100, 0.0001f0))
		sync(af)
	end

	# Run the trained network and test accuracy.
    trainOutput = predict(network, trainFeats);
    testOutput = predict(network, testFeats);

    println("Training set:");
    println("Accuracy on training data: $(accuracy(trainOutput, trainTarget))");

    println("Test set:");
    println("Accuracy on testing  data: $(accuracy(testOutput, testTarget))");

    println("Training time: $sec seconds");
end

end
