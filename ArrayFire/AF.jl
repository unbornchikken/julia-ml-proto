module AF

include("AFDefs.jl")
include("AFError.jl")

export
    ArrayFire,
    getBackend,
    getSupportedBackends,
    scope!,
    @scope,
    register!

abstract AFImpl

include("AFLib.jl")

type Results
    ptr::Ref{Ptr{Void}}
    ptr2::Ref{Ptr{Void}}
    dim0::Ref{DimT}
    dim1::Ref{DimT}
    dim2::Ref{DimT}
    dim3::Ref{DimT}
    dims::Vector{DimT}
    dType::Ref{DType}
    bool::Ref{Bool}
    double::Ref{Float64}
    double2::Ref{Float64}
    uint::Ref{UInt32}
end

Results() = Results(
    Ref{Ptr{Void}}(C_NULL),
    Ref{Ptr{Void}}(C_NULL),
    Ref{DimT}(0),
    Ref{DimT}(0),
    Ref{DimT}(0),
    Ref{DimT}(0),
    Vector{DimT}(4),
    Ref{DType}(0),
    Ref{Bool}(false),
    Ref{Float64}(0.0),
    Ref{Float64}(0.0),
    Ref{UInt32}(0))

function fill(dims::Vector{DimT}, values::DimT...)
    idx = 1
    for v in values
        dims[idx] = v
        idx += 1
    end
    for idx2 in idx:4
        dims[idx2] = 1
    end
    dims
end

type ArrayFire{T<:Backend}
    ptr::Ptr{Void}
    device::AFImpl
    create::AFImpl
    binary::AFImpl
    unary::AFImpl
    index::AFImpl
    vectorAlgos::AFImpl
    modify::AFImpl
    reduction::AFImpl
    math::AFImpl
    linAlg::AFImpl
    createHandle::Ptr{Void}
    createArray::Ptr{Void}
    retainArray::Ptr{Void}
    releaseArray::Ptr{Void}
    getDims::Ptr{Void}
    getDataPtr::Ptr{Void}
    getType::Ptr{Void}
    getNumDims::Ptr{Void}
    getElements::Ptr{Void}
    isEmpty::Ptr{Void}
    freeList::AFImpl
    batch::Bool
    results::Results

    function ArrayFire()
        ptr = getLibPtr(T)
        new(
            ptr,
            AFDevice(ptr),
            Create(ptr),
            Binary(ptr),
            Unary(ptr),
            Index(ptr),
            VectorAlgos(ptr),
            Modify(ptr),
            Reduction(ptr),
            Math(ptr),
            LinAlg(ptr),
            Libdl.dlsym(ptr, :af_create_handle),
            Libdl.dlsym(ptr, :af_create_array),
            Libdl.dlsym(ptr, :af_retain_array),
            Libdl.dlsym(ptr, :af_release_array),
            Libdl.dlsym(ptr, :af_get_dims),
            Libdl.dlsym(ptr, :af_get_data_ptr),
            Libdl.dlsym(ptr, :af_get_type),
            Libdl.dlsym(ptr, :af_get_numdims),
            Libdl.dlsym(ptr, :af_get_elements),
            Libdl.dlsym(ptr, :af_is_empty),
            FreeList(),
            false,
            Results())
    end
end

getBackend{T<:Backend}(af::ArrayFire{T}) = T

function getSupportedBackends()
    backends = Vector{Any}()
    for b in [CPU, CUDA, OpenCL]
        try
            ArrayFire{b}()
            push!(backends, b)
        catch
        end
    end
    backends
end

include("AFDevice.jl")
include("AFArray.jl")
include("macros.jl")
include("Create.jl")
include("Binary.jl")
include("Unary.jl")
include("Index.jl")
include("VectorAlgos.jl")
include("Modify.jl")
include("Reduction.jl")
include("Math.jl")
include("LinAlg.jl")
include("FreeList.jl")

immutable ScopeHandle
    result::Function
    register::Function
end

function scope!(pred, af::ArrayFire)
    newScope!(af.freeList)
    try
        h = ScopeHandle(arr -> markResult!(af.freeList, arr), arr -> register!(af.freeList, arr))
        pred(h)
    finally
        endScope!(af.freeList)
    end
end

function register!(af::ArrayFire, arr::AFArray)
    register!(af.freeList, arr)
end

macro scope(af, expr)
    :( scope!(this -> $expr, $af) )
end

end # module
