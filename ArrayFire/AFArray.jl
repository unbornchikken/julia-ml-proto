export AFArray

abstract AFArray

type AFArrayBase
	af
	ptr
end

type EmptyAFArray <: AFArray
	base

	function EmptyAFArray(af::ArrayFire)
		ptr = Ref{Ptr{Void}}()
		dims = [0, 0, 0, 0]
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, dims, f32)
		assertErr(err)
		new(AFArrayBase(af, ptr[]))
	end
end

type AFArrayWithData{T, N} <: AFArray
	base

	AFArrayWithData(af::ArrayFire, ptr) = new(AFArrayBase(af, ptr))

	function AFArrayWithData(af::ArrayFire, arr::Array{T, N})
		ptr = Ref{Ptr{Void}}()
		dims = collect(size(arr))
		assert(N == length(dims))
		err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, pointer(arr), N, pointer(dims), asDType(T))
		assertErr(err)
		new(AFArrayBase(af, ptr[]))
	end

	function AFArrayWithData(af::ArrayFire, dims...)
		ptr = Ref{Ptr{Void}}()
		dims = collect(dims)
		assert(N == length(dims))
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, N, pointer(dims), asDType(T))
		assertErr(err)
		new(AFArrayBase(af, ptr[]))
	end
end

export array

array(af::ArrayFire) = EmptyAFArray(af)

array{T, N}(af::ArrayFire, arr::Array{T, N}) = AFArrayWithData{T, N}(af, arr)

array{T}(af::ArrayFire, ::Type{T}, dims...) = AFArrayWithData{T, length(dims)}(af, dims...)

getBase(arr::EmptyAFArray) = arr.base

getBase{T, N}(arr::AFArrayWithData{T, N}) = arr.base

function release!(arr)
	base = getBase(arr)
	if (base.ptr != C_NULL)
		err = ccall(base.af.releaseArray, Cint, (Ptr{Void}, ), base.ptr)
		base.ptr = C_NULL
		assertErr(err)
	else
		false
	end
end

assertAlive(arr) = !(getBase(arr).ptr == C_NULL && error("Cannot access to a released array."))
