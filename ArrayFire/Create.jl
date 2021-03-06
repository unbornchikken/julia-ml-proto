import Base: randn,transpose,transpose!,range

export
    randn,
    randu,
    constant,
    lookup,
    transpose,
    transpose!,
	range

immutable Create <: AFImpl
    randn::Ptr{Void}
    randu::Ptr{Void}
    constant::Ptr{Void}
    constantLong::Ptr{Void}
    constantULong::Ptr{Void}
    lookup::Ptr{Void}
    transpose::Ptr{Void}
    transposeInPlace::Ptr{Void}
	range::Ptr{Void}

    function Create(ptr)
        new(
            Libdl.dlsym(ptr, :af_randn),
            Libdl.dlsym(ptr, :af_randu),
            Libdl.dlsym(ptr, :af_constant),
            Libdl.dlsym(ptr, :af_constant_long),
            Libdl.dlsym(ptr, :af_constant_ulong),
            Libdl.dlsym(ptr, :af_lookup),
            Libdl.dlsym(ptr, :af_transpose),
            Libdl.dlsym(ptr, :af_transpose_inplace),
			Libdl.dlsym(ptr, :af_range)
        )
    end
end

function randn{B, T}(af::ArrayFire{B}, ::Type{T}, dims::DimT...)
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.create.randn,
        Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
        ptr, length(dims2), pointer(dims2), asDType(T))
    assertErr(err)
    AFArray{B}(af, ptr[])
end

function randu{B, T}(af::ArrayFire{B}, ::Type{T}, dims::DimT...)
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.create.randu,
        Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType),
        ptr, length(dims2), pointer(dims2), asDType(T))
    assertErr(err)
    AFArray{B}(af, ptr[])
end

function constant{B, T<:Real}(af::ArrayFire{B}, value::T, dims::DimT...)
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.create.constant,
        Cint, (Ptr{Ptr{Void}}, Float64, Cuint, Ptr{DimT}, DType),
        ptr, Float64(value), length(dims2), pointer(dims2), asDType(T))
    assertErr(err)
    AFArray{B}(af, ptr[])
end

function constant{B}(af::ArrayFire{B}, value::Int64, dims::DimT...)
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.create.constantLong,
        Cint, (Ptr{Ptr{Void}}, Int64, Cuint, Ptr{DimT}, DType),
        ptr, value, length(dims2), pointer(dims2), asDType(Int64))
    assertErr(err)
    AFArray{B}(af, ptr[])
end

function constant{B}(af::ArrayFire{B}, value::UInt64, dims::DimT...)
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.create.constantLong,
        Cint, (Ptr{Ptr{Void}}, UInt64, Cuint, Ptr{DimT}, DType),
        ptr, value, length(dims2), pointer(dims2), asDType(UInt64))
    assertErr(err)
    AFArray{B}(af, ptr[])
end

@afCall_Arr_Arr_Arr_Unsigned(lookup, create, lookup)

@afCall_Arr_Arr_Bool(transpose, create, transpose, false)

function transpose!{B}(arr::AFArray{B}, conjugate::Bool = false)
    verifyAccess(arr)
    af = arr.af
    err = ccall(af.create.transposeInPlace,
        Cint, (Ptr{Void}, Bool),
        arr.ptr, conjugate)
    assertErr(err)
    arr
end

function range{B, T}(af::ArrayFire{B}, ::Type{T}, dims::Dim4, seqDim = 0)
    ptr = af.results.ptr
    err = ccall(af.create.range,
        Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, Cint, DType),
        ptr, length(dims), pointer(dims), seqDim, asDType(T))
    assertErr(err)
    AFArray{B}(af, ptr[])
end
