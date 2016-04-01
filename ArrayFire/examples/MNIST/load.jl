immutable Idx
	numDims::Int
	dims
	data
end

toString(idx::Idx) = "numDims: $(idx.numDims)\ndims: $(idx.dims)"

Base.print(io::IOBuffer, idx::Idx) = Base.print(io, toString(idx))

Base.print(idx::Idx) = Base.print(toString(idx))

readIdx{T}(::Type{T}, path) = open(path) do f
	bytes = readbytes(f, 4)

	bytes[3] != 8 && error("Unsupported data type")

	numDims = bytes[4]
	dims = Array{Int}(numDims)
	size = 1;
	for i in 1:numDims
		dim = ntoh(read(f, Int32))
		size *= dim
		dims[i] = dim
	end

	bytes = readbytes(f, size)
	data = Array{T}(size)
	for i in 1:size
		data[i] = convert(T, bytes[i])
	end

	return Idx(numDims, dims, data)
end

include("MNISTData.jl")

loadSubset(af, expandLabels = true, frac = 0.6f0) = scope!(af) do this
	frac = min(frac, 0.8f0)

	cd = dirname(@__FILE__)
	dataRoot = joinpath(cd, "data")
	imageData = readIdx(Float32, joinpath(dataRoot, "images-subset"))
	labelData = readIdx(UInt32, joinpath(dataRoot, "labels-subset"))

	rIDims = reverse(imageData.dims)
	images = array(af, imageData.data, rIDims...)

	r = randu(af, Float32, 10000)
	cond = r .< frac;
	trainIndices = where(cond);
	testIndices = where(!cond);

	trainImages = lookup(images, trainIndices, 2) ./ 255;
    testImages = lookup(images, testIndices, 2) ./ 255;

    numClasses = 10;
    numTrain = dims(trainImages, 2);
    numTest = dims(testImages, 2);

    println("Training sample count: $numTrain");
    println("Test sample count: $numTest");

	local trainLabelsArr, testLabelsArr;

	if expandLabels
	    trainLabels = [0.0f0 for x = 1:numClasses, y = 1:numTrain]
        testLabels = [0.0f0 for x = 1:numClasses, y = 1:numTest]

        assert(jType(trainIndices) == UInt32);
        assert(jType(testIndices) === UInt32);

        hTrainIdx = host(trainIndices);
        hTestIdx = host(testIndices);

		process = (num, indices, labels) ->
			for i in 1:num
				idx = indices[i] + 1
				label = labelData.data[idx]
				assert(label >= 0 && label <= 9)
				labels[label + 1, i] = 1;
			end

		process(numTrain, hTrainIdx, trainLabels)
		process(numTest, hTestIdx, testLabels)

		trainLabelsArr = array(af, trainLabels)
		testLabelsArr = array(af, testLabels)
	else
		labels = array(af, labelData.data)
		trainLabelsArr = labels[trainIndices]
		testLabelsArr = labels[testIndices]
	end

	this.result(trainLabelsArr)
	this.result(testLabelsArr)

	MNISTData(
		numClasses,
		numTrain,
		numTest,
		trainImages,
		testImages,
		trainLabelsArr,
		testLabelsArr)
end
