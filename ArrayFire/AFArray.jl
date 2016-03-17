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
		me = new(AFArrayBase(af, ptr[]))
		register!(af, me)
		me
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
		me = new(AFArrayBase(af, ptr[]))
		register!(af, me)
		me
	end

	function AFArrayWithData(af::ArrayFire, dims...)
		ptr = Ref{Ptr{Void}}()
		dims = collect(dims)
		assert(N == length(dims))
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, N, pointer(dims), asDType(T))
		assertErr(err)
		me = new(AFArrayBase(af, ptr[]))
		register!(af, me)
		me
	end
end

export array

array(af::ArrayFire) = EmptyAFArray(af)

array{T, N}(af::ArrayFire, arr::Array{T, N}) = AFArrayWithData{T, N}(af, arr)

array{T}(af::ArrayFire, ::Type{T}, dims...) = AFArrayWithData{T, length(dims)}(af, dims...)

array{T}(af::ArrayFire, arr::Array{T}, dims...) = array(af, reshape(arr, dims))

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

function _base(arr)
	b = getBase(arr)
	b.ptr == C_NULL && error("Cannot access to a released array.")
	b
end

export dims

function dims{T, N}(arr::AFArrayWithData{T, N})
	dim0 = Ref{DimT}()
	dim1 = Ref{DimT}()
	dim2 = Ref{DimT}()
	dim3 = Ref{DimT}()
	base = _base(arr)
	err = ccall(
		base.af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, base.ptr)
	assertErr(err)
	[dim0[], dim1[], dim2[], dim3[]]
end

function dims{T, N}(arr::AFArrayWithData{T, N}, n)
	dim0 = Ref{DimT}()
	dim1 = Ref{DimT}()
	dim2 = Ref{DimT}()
	dim3 = Ref{DimT}()
	base = _base(arr)
	err = ccall(
		base.af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, base.ptr)
	assertErr(err)
	if n == 1
		dim0[]
	elseif n == 2
		dim1[]
	elseif n == 3
		dim2[]
	else
		dim3[]
	end
end

dims(arr::EmptyAFArray) = [0, 0, 0, 0]

dims(arr::EmptyAFArray, n) = 0

function Base.size(arr::AFArray)
	d = dims(arr)
	if d[4] > 1
		(d[1], d[2], d[3], d[4])
	elseif d[3] > 1
		(d[1], d[2], d[3])
	elseif d[2] > 1
		(d[1], d[2])
	elseif d[1] > 1
		(d[1],)
	else
		()
	end
end

export host

function host{T, N}(arr::AFArrayWithData{T, N})
	result = Array{T}(size(arr)...)
	host(arr, result)
end

function host{T, N}(arr::AFArrayWithData{T, N}, to::Array{T, N})
	base = _base(arr)
	err = ccall(
		base.af.getDataPtr,
		Cint, (Ptr{T}, Ptr{Void}),
		to, base.ptr)
	assertErr(err)
	to
end
