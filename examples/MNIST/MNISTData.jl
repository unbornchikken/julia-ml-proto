export MNISTData, featureSize, numTrain, numTest, numClasses

immutable MNISTData{A}
    trainImages::A
    testImages::A
    trainLabels::A
    testLabels::A
end

featureSize(data::MNISTData) = dims(data.trainImages, 1)

numClasses(data::MNISTData) = dims(data.trainLabels, 1)

numTrain(data::MNISTData) = dims(data.trainImages, 0)

numTest(data::MNISTData) = dims(data.testImages, 0)
