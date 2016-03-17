include("../../GenEvo.jl")

module MNIST

using GenEvo

immutable Idx
	numDims::Int
	dims
	data
end

function toString(idx::Idx)
	"numDims: $(idx.numDims)\ndims: $(idx.dims)"
end

Base.print(io::IOBuffer, idx::Idx) = Base.print(io, toString(idx))
Base.print(idx::Idx) = Base.print(toString(idx))

function readIdx{T}(::Type{T}, path)
	open(path) do f
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
end

function loadSubset(ctx, expandLabels = true, frac = 0.6f0)
	frac = min(frac, 0.8f0)

	cd = dirname(@__FILE__)
	dataRoot = joinpath(cd, "data")
	imageData = readIdx(Float32, joinpath(dataRoot, "images-subset"))
	labelData = readIdx(UInt32, joinpath(dataRoot, "labels-subset"))

	rIDims = reverse(imageData.dims)
	images = array(ctx, imageData.data, rIDims...)

	r = randu(Float32, 10000)
	cond = r .< frac;
	trainIndices = where(cond);
	testIndices = where(!cond);

	trainImages = lookup(images, trainIndices, 2) ./ 255;
    testImages = lookup(images, testIndices, 2) ./ 255;

    numClasses = 10;
    numTrain = dims(trainImages, 2);
    numTest = dims(testImages, 2);

    print("Training sample count: $numTrain");
    print("Test sample count: $numTest");

	#
    # let trainLabels;
    # let testLabels;
	#
    # if (expandLabels) {
    #     trainLabels = af.constant(0, numClasses, numTrain, af.dType.f32);
    #     testLabels = af.constant(0, numClasses, numTest, af.dType.f32);
	#
    #     assert(trainIndices.type() === af.dType.u32);
    #     assert(testIndices.type() === af.dType.u32);
	#
    #     let hTrainIdx = yield trainIndices.hostAsync();
    #     let hTestIdx = yield testIndices.hostAsync();
	#
    #     for (let i = 0; i < numTrain; i++) {
    #         let idx = uint.get(hTrainIdx, i * uint.size);
    #         let label = uint.get(labelData.data, idx * uint.size);
    #         assert(label >= 0 && label <= 9);
    #         trainLabels.set(label, i, 1);
    #     }
	#
    #     for (let i = 0; i < numTest; i++) {
    #         let idx = uint.get(hTestIdx, i * uint.size);
    #         let label = uint.get(labelData.data, idx * uint.size);
    #         assert(label >= 0 && label <= 9);
    #         testLabels.set(label, i, 1);
    #     }
    # }
    # else {
    #     let labels = yield AFArray.createAsync(labelData.dims[0], af.dType.u32, labelData.data);
    #     trainLabels = labels.at(trainIndices);
    #     testLabels = labels.at(testIndices);
    # }
	#
    # return {
    #     numClasses,
    #     numTrain,
    #     numTest,
    #     trainImages: trainImages,
    #     testImages: testImages,
    #     trainLabels: trainLabels,
    #     testLabels: testLabels
    # };
end

end
