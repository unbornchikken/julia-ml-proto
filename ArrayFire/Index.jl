import Base: getindex, setindex!
export getindex, setindex!
export seq, span, row, rows, col, cols, seqBegin, seqEnd

immutable Index <: AFImpl
    indexGen::Ptr{Void}
    assignGen::Ptr{Void}

    function Index(ptr)
        new(
            Libdl.dlsym(ptr, :af_index_gen),
            Libdl.dlsym(ptr, :af_assign_gen)
        )
    end
end

immutable Seq
    afBegin::Float64
    afEnd::Float64
    afStep::Float64
end

Seq(i::Real) = Seq(i, i, 1)
Seq(b::Real, e::Real) = Seq(b, e, 1)

seq(af::ArrayFire, v) = Seq(v)
seq(af::ArrayFire, v1, v2) = Seq(v1, v2)
seq(af::ArrayFire, v1, v2, v3) = Seq(v1, v2, v3)

seqBegin(seq::Seq) = Int(floor(seq.afBegin))
seqEnd(seq::Seq) = Int(floor(seq.afEnd))

immutable Col
    index::Int
end

col(af::ArrayFire, index) = Col(index)

immutable Cols
    firstIndex::Int
    lastIndex::Int
end

cols(af::ArrayFire, firstIndex, lastIndex) = Cols(firstIndex, lastIndex)

immutable Row
    index::Int
end

row(af::ArrayFire, index) = Row(index)

immutable Rows
    firstIndex::Int
    lastIndex::Int
end

rows(af::ArrayFire, firstIndex, lastIndex) = Rows(firstIndex, lastIndex)

immutable DummySeq
    i1::UInt32
    i2::UInt32
    i3::UInt32
    i4::UInt32
    i5::UInt32
    i6::UInt32
end

abstract AFIndex

immutable SeqIndex <: AFIndex
    seq::Seq
    isSeq::Bool
    isBatch::Bool

    SeqIndex(s::Seq, isBatch::Bool = false) = new(s, true, isBatch)
    SeqIndex(i::Real, isBatch::Bool = false) = new(Seq(i), true, isBatch)
    SeqIndex(b::Real, e::Real, isBatch::Bool = false) = new(Seq(b, e), true, isBatch)
    SeqIndex(b::Real, e::Real, s::Real, isBatch::Bool = false) = new(Seq(b, e, s), true, isBatch)
end

immutable ArrayIndex <: AFIndex
    data::DummySeq
    isSeq::Bool
    isBatch::Bool

    ArrayIndex(arr::AFArray, isBatch::Bool = false) = new(toArrayIndexData(arr), false, isBatch)
end

@generated function ptr(arrayIndex::ArrayIndex)
    if UInt == UInt32
        :(reinterpret(Ptr{Void}, arrayIndex.data.i1))
    else
        :(reinterpret(Ptr{Void}, UInt64(arrayIndex.data.i2) << 32 + UInt64(arrayIndex.data.i1)))
    end
end

@generated function toArrayIndexData(arr::AFArray)
    if UInt == UInt32
        :(DummySeq(reinterpret(UInt32, arr.ptr), 0, 0, 0, 0, 0))
    else
        :(DummySeq(UInt32(reinterpret(UInt64, arr.ptr) & 0xFFFFFFFF),
            UInt32(reinterpret(UInt64, arr.ptr) >> 32), 0, 0, 0, 0))
    end
end

function indexGen{I<:AFIndex}(arr::AFArray, indices::Vector{I})
    af = arr.af
    ptr = af.results.ptr
    err = ccall(af.index.indexGen,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{I}),
        ptr, arr.ptr, length(indices), pointer(indices))
    assertErr(err)
    array(af, ptr[])
end

function assignGen{B, I<:AFIndex}(arr::AFArray{B}, rhs::AFArray{B}, indices::Vector{I})
    af = arr.af
    ptr = af.results.ptr
    err = ccall(af.index.assignGen,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{I}, Ptr{Void}),
        ptr, arr.ptr, length(indices), pointer(indices), rhs.ptr)
    assertErr(err)
    ptr[]
end

immutable Span end

span(af::ArrayFire) = Span()

function getindex(arr::AFArray)
    verifyAccess(arr)
    array(arr.af, retain!(arr.af, arr.ptr))
end

function setindex!{B}(arr::AFArray{B}, rhs::AFArray{B})
    verifyAccess(arr)
    verifyAccess(rhs)
    if arr.ptr != rhs.ptr
        release!(arr)
        arr.ptr = retain!(arr.af, rhs.ptr)
    end
end

@generated function getindex(arr::AFArray, args...)
    exp = genIndices(arr, args...)
    :( verifyAccess(arr); $exp; indexGen(arr, indices) )
end

@generated function setindex!{V}(arr::AFArray, rhs::V, args...)
    exp = genIndices(arr, args...)
    if rhs <: Real
        quote
            verifyAccess(arr)
            $exp
            val = constant(arr.af, rhs, genDims(arr, indices...)...)
            try
                outPtr = assignGen(arr, val, indices)
                if arr.ptr != outPtr
                    release!(arr)
                    arr.ptr = outPtr
                end
            finally
                release!(val)
            end
        end
    else
        quote
            verifyAccess(arr)
            $exp
            outPtr = assignGen(arr, rhs, indices)
            if arr.ptr != outPtr
                release!(arr)
                arr.ptr = outPtr
            end
        end
    end
end

function genDims(arr::AFArray, i::ArrayIndex)
    Dim4([elements(arr.af, ptr(i)), 1, 1, 1])
end

function genDims(arr::AFArray, indices::SeqIndex...)
    arrDims = dims(arr)
    result = Dim4([1, 1, 1, 1])
    idx = 1
    for i in indices
        if i.seq.afStep == 0
            # span
            result[idx] = arrDims[idx]
        else
            result[idx] = i.seq.afEnd - i.seq.afBegin + 1
        end
        idx += 1
    end
    result
end

function genIndices{B}(arr::Type{AFArray{B}}, args::Type...)
    if length(args) == 1 && args[1] <: AFArray{B}
        return :( indices = Vector{ArrayIndex}([ArrayIndex(args[1])]) )
    end
    exp = :( indices = Vector{SeqIndex}(length(args)) )
    i = 1
    for arg in args
        if is(arg, Seq)
            exp = :( $exp; indices[$i] = SeqIndex(args[$i], arr.af.batch) )
        elseif is(arg, Int)
            exp = :( $exp; indices[$i] = SeqIndex(args[$i] > 0 ? args[$i] - 1 : args[$i], arr.af.batch) )
        elseif is(arg, UnitRange{Int})
            exp = :( $exp; indices[$i] =
                SeqIndex(
                    args[$i].start > 0 ? args[$i].start - 1 : args[$i].start,
                    args[$i].stop > 0 ? args[$i].stop - 1 : args[$i].stop, arr.af.batch) )
        elseif is(arg, Colon)
            exp = :( $exp; indices[$i] = SeqIndex(1, 1, 0, arr.af.batch) )
        elseif is(arg, Span)
            exp = :( $exp; indices[$i] = SeqIndex(1, 1, 0, arr.af.batch) )
        elseif is(arg, Row)
            exp = quote
                $exp
                indices[$i] = SeqIndex(args[$i].index, arr.af.batch)
                push!(indices, SeqIndex(1, 1, 0, arr.af.batch))
            end
            break
        elseif is(arg, Rows)
            exp = quote
                $exp
                indices[$i] = SeqIndex(args[$i].firstIndex, args[$i].lastIndex, arr.af.batch)
                push!(indices, SeqIndex(1, 1, 0, arr.af.batch))
            end
            break
        elseif is(arg, Col)
            exp = quote
                $exp
                indices[$i] = SeqIndex(1, 1, 0, arr.af.batch)
                push!(indices, SeqIndex(args[$i].index, arr.af.batch))
            end
            break
        elseif is(arg, Cols)
            exp = quote
                $exp
                indices[$i] = SeqIndex(1, 1, 0, arr.af.batch)
                push!(indices, SeqIndex(args[$i].firstIndex, args[$i].lastIndex, arr.af.batch))
            end
            break
        else
            error("Unknown arguments: $args")
        end
        i = i + 1
    end
    exp
end
