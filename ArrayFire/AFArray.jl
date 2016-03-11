export AFArray

abstract AFArray

immutable EmptyAFArray <: AFArray
	af
	ptr

	function EmptyAFArray(af::ArrayFire)
		ptr = Ref{Ptr{Void}}()
		dims = [0, 0, 0, 0]
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, dims, f32)
		assertErr(err)
		new(af, ptr)
	end
end

immutable AFArrayWithData{T, N} <: AFArray
	af
	ptr

	function AFArrayWithData(af::ArrayFire, arr::Array{T, N})
		ptr = Ref{Ptr{Void}}()
		dims = collect(size(arr))
		assert(N == length(dims))
		err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, arr, N, dims, asDType(T))
		assertErr(err)
		new(af, ptr)
	end

	function AFArrayWithData(af::ArrayFire, dims...)
		ptr = Ref{Ptr{Void}}()
		dims = collect(dims)
		assert(N == length(dims))
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, N, dims, asDType(T))
		assertErr(err)
		new(af, ptr)
	end
end

export array

array(af::ArrayFire) = EmptyAFArray(af)

array{T, N}(af::ArrayFire, arr::Array{T, N}) = AFArrayWithData{T, N}(af, arr)

array{T}(af::ArrayFire, ::Type{T}, dims...) = AFArrayWithData{T, length(dims)}(af, dims...)

dimsToDim4(dims) =
	if length(dims) == 1
        [dims[1]]
    elseif length(dims) == 2
        [dims[1], dims[2]]
    elseif length(dims) == 3
        [dims[1], dims[2], dims[4]]
    elseif length(dims) == 4
        [dims[1], dims[2], dims[3], dims[4]]
    else
        throw(ArgumentError("Too many dimensions"))
    end
