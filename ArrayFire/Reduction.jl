import Base: min, max, sum, count

export max, imax, min, imin, sum, count

immutable Reduction <: AFImpl
    max::Ptr{Void}
    maxAll::Ptr{Void}
    imax::Ptr{Void}
    imaxAll::Ptr{Void}
    min::Ptr{Void}
    minAll::Ptr{Void}
    imin::Ptr{Void}
    iminAll::Ptr{Void}
    sum::Ptr{Void}
    sumNan::Ptr{Void}
    sumAll::Ptr{Void}
    sumNanAll::Ptr{Void}
    count::Ptr{Void}
    countAll::Ptr{Void}

    function Reduction(ptr)
        new(
            Libdl.dlsym(ptr, :af_max),
            Libdl.dlsym(ptr, :af_max_all),
            Libdl.dlsym(ptr, :af_imax),
            Libdl.dlsym(ptr, :af_imax_all),
            Libdl.dlsym(ptr, :af_min),
            Libdl.dlsym(ptr, :af_min_all),
            Libdl.dlsym(ptr, :af_imin),
            Libdl.dlsym(ptr, :af_imin_all),
            Libdl.dlsym(ptr, :af_sum),
            Libdl.dlsym(ptr, :af_sum_nan),
            Libdl.dlsym(ptr, :af_sum_all),
            Libdl.dlsym(ptr, :af_sum_nan_all),
            Libdl.dlsym(ptr, :af_count),
            Libdl.dlsym(ptr, :af_count_all)
        )
    end
end

macro minMaxRed(regular, all, indexed, indexedAll)
    quote
        function $(esc(regular))(arr::AFArray, dim = -1)
            verifyAccess(arr)
            af = arr.af
            result = af.results.ptr
            err = ccall(af.reduction.$regular,
                Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32),
                result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
            assertErr(err)
            array(af, result[])
        end

        function $(esc(regular)){T<:Real}(::Type{T}, arr::AFArray)
            verifyAccess(arr)
            af = arr.af
            real = af.results.double
            imag = af.results.double2
            err = ccall(af.reduction.$all,
                Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}),
                real, imag, arr.ptr)
            assertErr(err)
            T(real[])
        end

        function $(esc(indexed))(arr::AFArray, dim = -1)
            verifyAccess(arr)
            af = arr.af
            result = af.results.ptr
            idx = af.results.ptr2
            err = ccall(af.reduction.$indexed,
                Cint, (Ptr{Ptr{Void}}, Ptr{Ptr{Void}}, Ptr{Void}, Int32),
                result, idx, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
            assertErr(err)
            array(af, result[]), array(af, idx[])
        end

        function $(esc(indexed)){T<:Real}(::Type{T}, arr::AFArray)
            verifyAccess(arr)
            af = arr.af
            real = af.results.double
            imag = af.results.double2
            idx = af.results.uint
            err = ccall(af.reduction.$indexedAll,
                Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{UInt32}, Ptr{Void}),
                real, imag, idx, arr.ptr)
            assertErr(err)
            T(real[]), idx[]
        end
    end
end

@minMaxRed(max, maxAll, imax, imaxAll)

@minMaxRed(min, minAll, imin, imaxAll)

function sum(arr::AFArray, dim::Int = -1)
    verifyAccess(arr)
    af = arr.af
    result = af.results.ptr
    err = ccall(af.reduction.sum,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32),
        result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
    assertErr(err)
    array(af, result[])
end

function sum{T<:Union{Float32,Float64}}(arr::AFArray, dim::Int, nanVal::T)
    verifyAccess(arr)
    af = arr.af
    result = af.results.ptr
    err = ccall(af.reduction.sumNan,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32, Float64),
        result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim), nanVal)
    assertErr(err)
    array(af, result[])
end

function sum{T<:Real}(::Type{T}, arr::AFArray)
    verifyAccess(arr)
    af = arr.af
    real = af.results.double
    imag = af.results.double2
    err = ccall(af.reduction.sumAll,
        Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}),
        real, imag, arr.ptr)
    assertErr(err)
    T(real[])
end

function sum{T<:Union{Float32,Float64}}(arr::AFArray, nanVal::T)
    verifyAccess(arr)
    af = arr.af
    real = af.results.double
    imag = af.results.double2
    err = ccall(af.reduction.sumNanAll,
        Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}, Float64),
        real, imag, arr.ptr, nanVal)
    assertErr(err)
    real[]
end

function count(arr::AFArray, dim::Int = -1)
    verifyAccess(arr)
    af = arr.af
    result = af.results.ptr
    err = ccall(af.reduction.count,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32),
        result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
    assertErr(err)
    array(af, result[])
end

function count{T<:Real}(::Type{T}, arr::AFArray)
    verifyAccess(arr)
    af = arr.af
    real = af.results.double
    imag = af.results.double2
    err = ccall(af.reduction.countAll,
        Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}),
        real, imag, arr.ptr)
    assertErr(err)
    T(real[])
end
