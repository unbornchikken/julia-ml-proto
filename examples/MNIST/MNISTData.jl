export MNISTData, featureSize, numTrain, numTest

immutable MNISTData{A}
    trainImages::A
    testImages::A
    trainLabels::A
    testLabels::A
end

featureSize(data::MNISTData) = dims(data.trainImages, 0)

numTrain(data::MNISTData) = dims(data.trainImages, 1)

numTest(data::MNISTData) = dims(data.testImages, 1)
