export MNISTData

immutable MNISTData{D, TL<:AFArray{D}}
	numClasses::Int
	numTrain::Int
	numTest::Int
	trainImages::AFArray{D, Float32, 2}
	testImages::AFArray{D, Float32, 2}
	trainLabels::TL
	testLabels::TL
end
