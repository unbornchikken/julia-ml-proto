export
	randn,
	randu,
	constant

immutable Create
	randn
	randu
	constant
	constantLong
	constantULong

	function Create(ptr)
		new(
			Libdl.dlsym(ptr, :af_randn),
			Libdl.dlsym(ptr, :af_randu),
			Libdl.dlsym(ptr, :af_constant),
			Libdl.dlsym(ptr, :af_constant_long),
			Libdl.dlsym(ptr, :af_constant_ulong)
		)
	end
end

function randn{T}(af::ArrayFire, ::Type{T}, dims...)
	ptr = Ref{Ptr{Void}}()
	dims = collect(dims)
	err = ccall(af.create.randn,
		Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
		ptr, length(dims), pointer(dims), asDType(T))
	assertErr(err)
	AFArrayWithData{T, dimsToSize(dims)}(af, ptr[])
end

function randu{T}(af::ArrayFire, ::Type{T}, dims...)
	ptr = Ref{Ptr{Void}}()
	dims = collect(dims)
	err = ccall(af.create.randu,
		Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
		ptr, length(dims), pointer(dims), asDType(T))
	assertErr(err)
	AFArrayWithData{T, dimsToSize(dims)}(af, ptr[])
end

function constant{T<:Real}(af::ArrayFire, value::T, dims...)
	ptr = Ref{Ptr{Void}}()
	dims = collect(dims)
	err = ccall(af.create.constant,
		Cint, (Ptr{Ptr{Void}}, Float64, Cuint, Ptr{DimT}, DType),
		ptr, Float64(value), length(dims), pointer(dims), asDType(T))
	assertErr(err)
	AFArrayWithData{T, dimsToSize(dims)}(af, ptr[])
end

function constant(af::ArrayFire, value::Int64, dims...)
	ptr = Ref{Ptr{Void}}()
	dims = collect(dims)
	err = ccall(af.create.constantLong,
		Cint, (Ptr{Ptr{Void}}, Int64, Cuint, Ptr{DimT}, DType),
		ptr, value, length(dims), pointer(dims), asDType(Int64))
	assertErr(err)
	AFArrayWithData{Int64, dimsToSize(dims)}(af, ptr[])
end

function constant(af::ArrayFire, value::UInt64, dims...)
	ptr = Ref{Ptr{Void}}()
	dims = collect(dims)
	err = ccall(af.create.constantLong,
		Cint, (Ptr{Ptr{Void}}, UInt64, Cuint, Ptr{DimT}, DType),
		ptr, value, length(dims), pointer(dims), asDType(UInt64))
	assertErr(err)
	AFArrayWithData{UInt64, dimsToSize(dims)}(af, ptr[])
end
