import Base: getindex, setindex!
export getindex, setindex!
export Seq, Span

immutable Index
	indexGen

	function Index(ptr)
		new(
			Libdl.dlsym(ptr, :af_index_gen)
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
		:(DummySeq(reinterpret(UInt32, _base(arr).ptr), 0, 0, 0, 0, 0))
	else
		:(
			base = _base(arr);
			DummySeq(UInt32(reinterpret(UInt64, base.ptr) & 0xFFFFFFFF), UInt32(reinterpret(UInt64, base.ptr) >> 32), 0, 0, 0, 0)
		)
	end
end

function index{T, N, I<:AFIndex}(arr::AFArrayWithData{T, N}, indices::I...)
	ptr = Ref{Ptr{Void}}()
	indices2 = collect(indices)
	base = _base(arr)
	err = ccall(base.af.index.indexGen,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{I}),
		ptr, base.ptr, length(indices2), pointer(indices2))
	assertErr(err)
	array(base.af, T, ptr[])
end

immutable Span end

@generated function getindex{T, N}(arr::AFArrayWithData{T, N}, args...)
	exp = :(base = _base(arr); indices = Array{AFIndex}(length(args)))
	i = 1
	for arg in args
		if is(arg, Seq)
			exp = :( $exp; indices[$i] = SeqIndex(args[$i], base.af.batch) )
		elseif arg <: AFArray
			exp = :( $exp; indices[$i] = ArrayIndex(args[$i], base.af.batch) )
		elseif is(arg, Int)
			exp = :( $exp; indices[$i] = SeqIndex(args[$i] > 0 ? args[$i] - 1 : args[$i], base.af.batch) )
		elseif is(arg, UnitRange{Int})
			exp = :( $exp; indices[$i] =
				SeqIndex(
					args[$i].start > 0 ? args[$i].start - 1 : args[$i].start,
					args[$i].stop > 0 ? args[$i].stop - 1 : args[$i].stop, base.af.batch) )
		elseif is(arg, Colon)
			exp = :( $exp; indices[$i] = SeqIndex(1, 1, 0, base.af.batch) )
		elseif is(arg, Span)
			exp = :( $exp; indices[$i] = SeqIndex(1, 1, 0, base.af.batch) )
		else
			error("Unknown argument type at $i")
		end
		i = i + 1
	end
	:( $exp; index(arr, indices...) )
end
