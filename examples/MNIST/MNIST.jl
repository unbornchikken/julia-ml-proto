module MNIST

import Base.convert

immutable Idx
	numDims::Int
	dims
	data
end

function convert(::Type{AbstractString}, idx::Idx)
	"numDims: $(idx.numDims)\ndims: $(idx.dims)"
end

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

end
