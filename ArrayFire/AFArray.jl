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

type AFArray{D, T, N}
	af::ArrayFire{D}
	ptr::Ptr{Void}

	function AFArray(af::ArrayFire{D})
		ptr = af.results.ptr
		dims = [0, 0, 0, 0]
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, dims, f32)
		assertErr(err)
		me = new(af, ptr[])
		register!(af, me)
		me
	end

	function AFArray(af::ArrayFire{D}, ptr::Ptr{Void}, wrap = true)
		me = new(af, ptr)
		if wrap
			finalizer(me, release!)
			register!(af, me)
		end
		me
	end

	function AFArray(af::ArrayFire{D}, arr::Array{T, N})
		ptr = af.results.ptr
		dims = collect(size(arr))
		assert(N == length(dims))
		err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, pointer(arr), N, pointer(dims), asDType(T))
		assertErr(err)
		me = new(af, ptr[])
		finalizer(me, release!)
		register!(af, me)
		me
	end

	function AFArray(af::ArrayFire{D}, dims::Int...)
		ptr = af.results.ptr
		dims2 = collect(dims)
		assert(N == length(dims2))
		err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, N, pointer(dims2), asDType(T))
		assertErr(err)
		me = new(af, ptr[])
		finalizer(me, release!)
		register!(af, me)
		me
	end
end

empty{D, T}(af::ArrayFire{D}, ::Type{T}, N::Int) = AFArray{D, T, N}(af)

array{D, T, N}(af::ArrayFire{D}, arr::Array{T, N}) = AFArray{D, T, N}(af, arr)

array{D, T}(af::ArrayFire{D}, ::Type{T}, dims...) = AFArray{D, T, length(dimsToSize(dims...))}(af, dims...)

array{D, T}(af::ArrayFire{D}, arr::Array{T}, dims...) = array(af, reshape(arr, dimsToSize(dims...)...))

array{D, T}(af::ArrayFire{D}, ::Type{T}, N::Int, ptr::Ptr{Void}) = AFArray{D, T, N}(af, ptr)

array{D, T}(af::ArrayFire{D}, ::Type{T}, ptr::Ptr{Void}) = AFArray{D, T, Int(numdims(af, ptr))}(af, ptr)

array{D}(af::ArrayFire{D}, ptr::Ptr{Void}) = AFArray{D, asJType(Val{dType(af, ptr)}), Int(numdims(af, ptr))}(af, ptr)

function release!(arr::AFArray)
	if (arr.ptr != C_NULL)
		release!(arr.af, arr.ptr)
		arr.ptr = C_NULL
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

verifyAccess(arr::AFArray) = arr.ptr == C_NULL && error("Cannot access to a released array.")

isEmpty(arr::AFArray) = verifyAccess(arr); isEmpty(arr.af, arr.ptr)

function isEmpty(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.bool
	err = ccall(
		af.isEmpty,
		Cint, (Ptr{Bool}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

dims(arr::AFArray) = verifyAccess(arr); dims(arr.af, arr.ptr)

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
	verifyAccess(arr)
	af = arr.af
	dim0 = af.results.dim0
	dim1 = af.results.dim1
	dim2 = af.results.dim2
	dim3 = af.results.dim3
	err = ccall(
		af.getDims,
		Cint, (Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{DimT}, Ptr{Void}),
		dim0, dim1, dim2, dim3, arr.ptr)
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
	dType(arr.af, arr.ptr)
end

function dType(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dType
	err = ccall(
		af.getType,
		Cint, (Ptr{DType}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

jType{D, T, N}(arr::AFArray{D, T, N}) = verifyAccess(arr); T

numdims(arr::AFArray) = verifyAccess(arr); numdims(arr.af, arr.ptr)

function numdims(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dType
	err = ccall(
		af.getNumDims,
		Cint, (Ptr{UInt32}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

elements(arr::AFArray) = verifyAccess(arr); elements(arr.af, arr.ptr)

function elements(af::ArrayFire, ptr::Ptr{Void})
	result = af.results.dim0
	err = ccall(
		af.getElements,
		Cint, (Ptr{DimT}, Ptr{Void}),
		result, ptr)
	assertErr(err)
	result[]
end

function host{D, T, N}(arr::AFArray{D, T, N})
	verifyNotEmpty(arr)
	result = Array{T}(size(arr)...)
	_host(arr, result)
end

function host{D, T, N}(arr::AFArray{D, T, N}, to::Array{T, N})
	verifyNotEmpty(arr)
	_host(arr, to)
end

function _host{D, T, N}(arr::AFArray{D, T, N}, to::Array{T, N})
	verifyAccess(arr)
	err = ccall(
		arr.af.getDataPtr,
		Cint, (Ptr{T}, Ptr{Void}),
		to, arr.ptr)
	assertErr(err)
	to
end

verifyNotEmpty{T, N}(arr::AFArray{T, N}) = isEmpty(arr) && error("Array is empty.")
