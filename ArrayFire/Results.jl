type Results
    ptr::Ref{Ptr{Void}}
    ptr2::Ref{Ptr{Void}}
    dim0::Ref{DimT}
    dim1::Ref{DimT}
    dim2::Ref{DimT}
    dim3::Ref{DimT}
    dims::Vector{DimT}
    pointers::Vector{Ptr{Void}}
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
    Vector{Ptr{Void}}(4),
    Ref{DType}(0),
    Ref{Bool}(false),
    Ref{Float64}(0.0),
    Ref{Float64}(0.0),
    Ref{UInt32}(0))

function collectDims(dims::Vector{DimT}, values)
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

function collectArrayPointers(ptrs::Vector{Ptr{Void}}, arrays)
    idx = 1
    for arr in arrays
        verifyAccess(arr)
        ptrs[idx] = arr.ptr
        idx += 1
    end
    return idx - 1, ptrs
end
