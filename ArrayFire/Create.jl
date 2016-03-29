import Base.randn

export
	randn,
	randu,
	constant,
	lookup

immutable Create <: AFImpl
	randn::Ptr{Void}
	randu::Ptr{Void}
	constant::Ptr{Void}
	constantLong::Ptr{Void}
	constantULong::Ptr{Void}
	lookup::Ptr{Void}

	function Create(ptr)
		new(
			Libdl.dlsym(ptr, :af_randn),
			Libdl.dlsym(ptr, :af_randu),
			Libdl.dlsym(ptr, :af_constant),
			Libdl.dlsym(ptr, :af_constant_long),
			Libdl.dlsym(ptr, :af_constant_ulong),
			Libdl.dlsym(ptr, :af_lookup)
		)
	end
end

function randn{T}(af::ArrayFire, ::Type{T}, dims...)
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.create.randn,
		Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
		ptr, length(dims2), pointer(dims2), asDType(T))
	assertErr(err)
	AFArray{T, jlLength(dims)}(af, ptr[])
end

function randu{T}(af::ArrayFire, ::Type{T}, dims...)
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.create.randu,
		Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
		ptr, length(dims2), pointer(dims2), asDType(T))
	assertErr(err)
	AFArray{T, jlLength(dims)}(af, ptr[])
end

function constant{T<:Real}(af::ArrayFire, value::T, dims...)
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.create.constant,
		Cint, (Ptr{Ptr{Void}}, Float64, Cuint, Ptr{DimT}, DType),
		ptr, Float64(value), length(dims2), pointer(dims2), asDType(T))
	assertErr(err)
	AFArray{T, jlLength(dims)}(af, ptr[])
end

function constant(af::ArrayFire, value::Int64, dims...)
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.create.constantLong,
		Cint, (Ptr{Ptr{Void}}, Int64, Cuint, Ptr{DimT}, DType),
		ptr, value, length(dims2), pointer(dims2), asDType(Int64))
	assertErr(err)
	AFArray{Int64, jlLength(dims)}(af, ptr[])
end

function constant(af::ArrayFire, value::UInt64, dims...)
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.create.constantLong,
		Cint, (Ptr{Ptr{Void}}, UInt64, Cuint, Ptr{DimT}, DType),
		ptr, value, length(dims2), pointer(dims2), asDType(UInt64))
	assertErr(err)
	AFArray{UInt64, jlLength(dims)}(af, ptr[])
end

@afCall_Arr_Arr_Arr_Unsigned(lookup, create, lookup)
