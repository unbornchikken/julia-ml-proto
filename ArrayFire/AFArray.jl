export
	AFArray,
	array,
	release!,
	dims,
	host,
	aftype,
	numdims

abstract AFArray

type AFArrayBase{T<:ArrayFire}
	af::T
	ptr::Ptr{Void}
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

type AFArrayWithData{T<:Number, N} <: AFArray
	base

	AFArrayWithData(af::ArrayFire, ptr::Ptr{Void}) = new(AFArrayBase(af, ptr))

	function AFArrayWithData(af::ArrayFire, arr::Array{T, N})
		ptr = Ref{Ptr{Void}}()
		dims = collect(size(arr))
		assert(N == length(dims))
		err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, pointer(arr), N, pointer(dims), asDType(T))
		assertErr(err)
		me = new(AFArrayBase(af, ptr[]))
		finalizer(me, release!)
		register!(af, me)
		me
	end

	function AFArrayWithData(af::ArrayFire, dims::Int...)
		ptr = Ref{Ptr{Void}}()
		dims2 = collect(dims)
		assert(N == length(dims2))
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, N, pointer(dims2), asDType(T))
		assertErr(err)
		me = new(AFArrayBase(af, ptr[]))
		finalizer(me, release!)
		register!(af, me)
		me
	end
end

array(af::ArrayFire) = EmptyAFArray(af)

array{T, N}(af::ArrayFire, arr::Array{T, N}) = AFArrayWithData{T, N}(af, arr)

array{T}(af::ArrayFire, ::Type{T}, dims...) = AFArrayWithData{T, length(dimsToSize(dims...))}(af, dims...)

array{T}(af::ArrayFire, arr::Array{T}, dims...) = array(af, reshape(arr, dimsToSize(dims...)...))

array{T}(af::ArrayFire, ::Type{T}, ptr::Ptr{Void}) = AFArrayWithData{T, Int(numdims(af, ptr))}(af, ptr)

getBase(arr::EmptyAFArray) = arr.base

getBase{T, N}(arr::AFArrayWithData{T, N}) = arr.base

function release!(arr::AFArray)
	base = getBase(arr)
	if (base.ptr != C_NULL)
		err = ccall(base.af.releaseArray, Cint, (Ptr{Void}, ), base.ptr)
		base.ptr = C_NULL
		assertErr(err)
	else
		false
	end
end

function _base(arr::AFArray)
	b = getBase(arr)
	b.ptr == C_NULL && error("Cannot access to a released array.")
	b
end

dims{T, N}(arr::AFArrayWithData{T, N}) = dims(_base(arr))

dims{T<:ArrayFire}(base::AFArrayBase{T}) = dims(base.af, base.ptr)

function dims(af::ArrayFire, ptr::Ptr{Void})
	dim0 = Ref{DimT}()
	dim1 = Ref{DimT}()
	dim2 = Ref{DimT}()
	dim3 = Ref{DimT}()
	err = ccall(
		af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, ptr)
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
	dimsToSize(dims(arr))
end

aftype{T, N}(arr::AFArrayWithData{T, N}) = asDType(T)

numdims(arr::AFArray) = numdims(_base(arr))

numdims{T<:ArrayFire}(base::AFArrayBase{T}) = numdims(base.af, base.ptr)

function numdims(af::ArrayFire, ptr::Ptr{Void})
	result = Ref{UInt32}()
	err = ccall(
		af.getNumDims,
		Cint, (Ptr{UInt32}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

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
