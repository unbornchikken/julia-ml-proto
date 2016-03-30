export
	AFArray,
	NAFArray,
	array,
	empty,
	release!,
	dims,
	host,
	dType,
	jType,
	numdims,
	isEmpty

type AFArrayBase{T<:ArrayFire}
	af::T
	ptr::Ptr{Void}
end

type AFArray{T, N}
	base::AFArrayBase

	function AFArray(af::ArrayFire)
		ptr = af.results.ptr
		dims = [0, 0, 0, 0]
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, dims, f32)
		assertErr(err)
		me = new(AFArrayBase(af, ptr[]))
		register!(af, me)
		me
	end

	function AFArray(af::ArrayFire, ptr::Ptr{Void}, wrap = true)
		me = new(AFArrayBase(af, ptr))
		if wrap
			finalizer(me, release!)
			register!(af, me)
		end
		me
	end

	function AFArray(af::ArrayFire, arr::Array{T, N})
		ptr = af.results.ptr
		dims = collect(size(arr))
		assert(N == length(dims))
		err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, pointer(arr), N, pointer(dims), asDType(T))
		assertErr(err)
		me = new(AFArrayBase(af, ptr[]))
		finalizer(me, release!)
		register!(af, me)
		me
	end

	function AFArray(af::ArrayFire, dims::Int...)
		ptr = af.results.ptr
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

empty{T}(af::ArrayFire, ::Type{T}, N::Int) = AFArray{T, N}(af)

array{T, N}(af::ArrayFire, arr::Array{T, N}) = AFArray{T, N}(af, arr)

array{T}(af::ArrayFire, ::Type{T}, dims...) = AFArray{T, length(dimsToSize(dims...))}(af, dims...)

array{T}(af::ArrayFire, arr::Array{T}, dims...) = array(af, reshape(arr, dimsToSize(dims...)...))

array{T}(af::ArrayFire, ::Type{T}, N::Int, ptr::Ptr{Void}) = AFArray{T, N}(af, ptr)

array{T}(af::ArrayFire, ::Type{T}, ptr::Ptr{Void}) = AFArray{T, Int(numdims(af, ptr))}(af, ptr)

array(af::ArrayFire, ptr::Ptr{Void}) = AFArray{asJType(Val{dType(af, ptr)}), Int(numdims(af, ptr))}(af, ptr)

getBase(arr::AFArray) = arr.base

getAF(arr::AFArray) = getBase(arr).af

function release!(arr::AFArray)
	base = getBase(arr)
	if (base.ptr != C_NULL)
		release!(base.af, base.ptr)
		base.ptr = C_NULL
	else
		false
	end
end

function release!(af, ptr)
	err = ccall(af.releaseArray, Cint, (Ptr{Void}, ), ptr)
	assertErr(err)
end

function retain!(af, ptr)
	result = af.results.ptr
	err = ccall(af.retainArray, Cint, (Ptr{Ptr{Void}}, Ptr{Void}, ), result, ptr)
	assertErr(err)
	result[]
end

function _base(arr::AFArray)
	b = getBase(arr)
	b.ptr == C_NULL && error("Cannot access to a released array.")
	b
end

isEmpty(arr::AFArray) = isEmpty(_base(arr))

isEmpty{T<:ArrayFire}(base::AFArrayBase{T}) = isEmpty(base.af, base.ptr)

function isEmpty(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.bool
	err = ccall(
		af.isEmpty,
		Cint, (Ptr{Bool}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

dims(arr::AFArray) = dims(_base(arr))

dims{T<:ArrayFire}(base::AFArrayBase{T}) = dims(base.af, base.ptr)

function dims(af::ArrayFire, ptr::Ptr{Void})
	dim0 = af.results.dim0
	dim1 = af.results.dim1
	dim2 = af.results.dim2
	dim3 = af.results.dim3
	err = ccall(
		af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, ptr)
	assertErr(err)
	[dim0[], dim1[], dim2[], dim3[]]
end

function dims{T, N}(arr::AFArray{T, N}, n)
	base = _base(arr)
	af = base.af
	dim0 = af.results.dim0
	dim1 = af.results.dim1
	dim2 = af.results.dim2
	dim3 = af.results.dim3
	err = ccall(
		af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, base.ptr)
	assertErr(err)
	if n == 0
		dim0[]
	elseif n == 1
		dim1[]
	elseif n == 2
		dim2[]
	else
		dim3[]
	end
end

function Base.size(arr::AFArray)
	dimsToSize(dims(arr))
end

function dType(arr::AFArray)
	dType(_base(arr))
end

dType{T<:ArrayFire}(base::AFArrayBase{T}) = dType(base.af, base.ptr)

function dType(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dType
	err = ccall(
		af.getType,
		Cint, (Ptr{DType}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

jType(arr::AFArray) = asJType(Val{dType(arr)})

jType{T, N}(arr::AFArray{T, N}) = T

numdims(arr::AFArray) = numdims(_base(arr))

numdims{T<:ArrayFire}(base::AFArrayBase{T}) = numdims(base.af, base.ptr)

function numdims(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dType
	err = ccall(
		af.getNumDims,
		Cint, (Ptr{UInt32}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

elements(arr::AFArray) = elements(_base(arr))

elements{T<:ArrayFire}(base::AFArrayBase{T}) = elements(base.af, base.ptr)

function elements(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dim0
	err = ccall(
		af.getElements,
		Cint, (Ptr{DimT}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

function host{T, N}(arr::AFArray{T, N})
	verifyNotEmpty(arr)
	result = Array{T}(size(arr)...)
	_host(arr, result)
end

function host{T, N}(arr::AFArray{T, N}, to::Array{T, N})
	verifyNotEmpty(arr)
	_host(arr, to)
end

function _host{T, N}(arr::AFArray{T, N}, to::Array{T, N})
	base = _base(arr)
	err = ccall(
		base.af.getDataPtr,
		Cint, (Ptr{T}, Ptr{Void}),
		to, base.ptr)
	assertErr(err)
	to
end

verifyNotEmpty{T, N}(arr::AFArray{T, N}) = isEmpty(arr) && error("Array is empty.")
