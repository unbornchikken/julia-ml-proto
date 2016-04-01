export MNISTData

immutable MNISTData{D}
	numClasses::Int
	numTrain::Int
	numTest::Int
	trainImages::AFArray{D, Float32, 3}
	testImages::AFArray{D, Float32, 3}
	trainLabels::AFArray{D}
	testLabels::AFArray{D}
end
