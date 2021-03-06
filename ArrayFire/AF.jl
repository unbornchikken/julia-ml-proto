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
include("Results.jl")

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
    moveAndReorder::AFImpl
    statistics::AFImpl

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
    eval::Ptr{Void}
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
            MoveAndReorder(ptr),
            Statistics(ptr),
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
            Libdl.dlsym(ptr, :af_eval),
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
include("MoveAndReorder.jl")
include("Statistics.jl")
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
