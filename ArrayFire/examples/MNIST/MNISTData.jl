export MNISTData

immutable MNISTData{B}
	numClasses::Int
	numTrain::Int
	numTest::Int
	trainImages::AFArray{B}
	testImages::AFArray{B}
	trainLabels::AFArray{B}
	testLabels::AFArray{B}
end
