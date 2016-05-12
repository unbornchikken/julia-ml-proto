import Base: Array, copy

export
    Array,
    AFArray,
    array,
    getBackend,
    empty,
    release!,
    dims,
    host,
    dType,
    jType,
    numdims,
    isEmpty,
    elements,
    copy,
    eval!

type AFArray{B}
    af::ArrayFire{B}
    ptr::Ptr{Void}

    # for empty
    function AFArray(af::ArrayFire{B})
        ptr = af.results.ptr
        dims = [0, 0, 0, 0]
        err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, dims, f32)
        assertErr(err)
        me = new(af, ptr[])
        register!(af, me) || finalizer(me, release!)
        me
    end

    function AFArray(af::ArrayFire{B}, ptr::Ptr{Void}, wrap = true)
        me = new(af, ptr)
        if wrap
            register!(af, me) || finalizer(me, release!)
        end
        me
    end

    function AFArray{T, N}(af::ArrayFire{B}, arr::Array{T, N})
        ptr = af.results.ptr
        dims = collectDims(af.results.dims, size(arr))
        err = ccall(af.createArray, Cint, (Ptr{Ptr{Void}}, Ptr{T}, Cuint, Ptr{DimT}, DType), ptr, pointer(arr), 4, pointer(dims), asDType(T))
        assertErr(err)
        me = new(af, ptr[])
        register!(af, me) || finalizer(me, release!)
        me
    end

    function AFArray{T}(af::ArrayFire{B}, ::Type{T}, dims::DimT...)
        ptr = af.results.ptr
        dims = collectDims(af.results.dims, dims)
        err = ccall(af.createHandle, Cint, (Ptr{Ptr{Void}}, Cuint, Ptr{DimT}, DType), ptr, 4, pointer(dims), asDType(T))
        assertErr(err)
        me = new(af, ptr[])
        register!(af, me) || finalizer(me, release!)
        me
    end
end

array{B}(af::ArrayFire{B}) = AFArray{B}(af)

array{B, T, N}(af::ArrayFire{B}, arr::Array{T, N}) = AFArray{B}(af, arr)

array{B, T}(af::ArrayFire{B}, ::Type{T}, dims::DimT...) = AFArray{B}(af, T, dims...)

array{B, T}(af::ArrayFire{B}, arr::Array{T}, dims::DimT...) = array(af, reshape(arr, dimsToSize(dims...)...))

array{B}(af::ArrayFire{B}, ptr::Ptr{Void}) = AFArray{B}(af, ptr)

getBackend{B}(arr::AFArray{B}) = (verifyAccess(arr); B)

function release!(arr::AFArray)
    if (arr.ptr != C_NULL)
        release!(arr.af, arr.ptr)
        arr.ptr = C_NULL
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

isEmpty(arr::AFArray) = (verifyAccess(arr); isEmpty(arr.af, arr.ptr))

function isEmpty(af::ArrayFire, ptr::Ptr{Void})
    result = af.results.bool
    err = ccall(
        af.isEmpty,
        Cint, (Ptr{Bool}, Ptr{Void}),
        result, ptr)
    assertErr(err)
    result[]
end

dims(arr::AFArray) = (verifyAccess(arr); dims(arr.af, arr.ptr))

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

function dims(arr::AFArray, n)
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

firstDim(arr::AFArray) = (verifyAccess(arr); dims(arr.af, arr.ptr))

function firstDim(af::ArrayFire, ptr::Ptr{Void})
    result = 1
    for dim in dims(af, ptr)
        if dim > 1
            return result
        end
        result += 1
    end
    1
end

function Base.size(arr::AFArray)
    dimsToSize(dims(arr))
end

function dType(arr::AFArray)
    verifyAccess(arr)
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

jType(arr::AFArray) = asJType(Val{dType(arr)})

numdims(arr::AFArray) = (verifyAccess(arr); numdims(arr.af, arr.ptr))

function numdims(af::ArrayFire, ptr::Ptr{Void})
    result = af.results.dType
    err = ccall(
        af.getNumDims,
        Cint, (Ptr{UInt32}, Ptr{Void}),
        result, ptr)
    assertErr(err)
    result[]
end

elements(arr::AFArray) = (verifyAccess(arr); elements(arr.af, arr.ptr))

function elements(af::ArrayFire, ptr::Ptr{Void})
    result = af.results.dim0
    err = ccall(
        af.getElements,
        Cint, (Ptr{DimT}, Ptr{Void}),
        result, ptr)
    assertErr(err)
    result[]
end

function host(arr::AFArray)
    verifyAccess(arr)
    verifyNotEmpty(arr)
    result = Array{jType(arr)}(size(arr)...)
    _host(arr, result)
end

function host{T, N}(arr::AFArray, to::Array{T, N})
    verifyAccess(arr)
    verifyNotEmpty(arr)
    _host(arr, to)
end

function _host{T, N}(arr::AFArray, to::Array{T, N})
    err = ccall(
        arr.af.getDataPtr,
        Cint, (Ptr{T}, Ptr{Void}),
        to, arr.ptr)
    assertErr(err)
    to
end

eval!(arr::AFArray) = (verifyAccess(arr); eval!(arr.af, arr.ptr))

function eval!(af::ArrayFire, ptr::Ptr{Void})
    err = ccall(af.eval, Cint, (Ptr{Void}, ), ptr)
    assertErr(err)
end

Array(arr::AFArray) = host(arr)

copy(arr::AFArray) = arr[]

verifyNotEmpty(arr::AFArray) = isEmpty(arr) && error("Array is empty.")
