import Base: getindex, setindex!
export getindex, setindex!

immutable Index
	indexGen

	function Index(ptr)
		new(
			Libdl.dlsym(ptr, :af_index_gen)
		)
	end
end

immutable SeqPart
	afBegin::Float64
	afEnd::Float64
	afStep::Float64
end

immutable DummySeqPart
	i1::UInt32
	i2::UInt32
	i3::UInt32
	i4::UInt32
	i5::UInt32
	i6::UInt32
end

abstract AFIndex

immutable SeqIndex <: AFIndex
	seq::SeqPart
	isSeq::Bool
	isBatch::Bool

	SeqIndex(i::Real, isBatch::Bool = false) = new(SeqPart(i, i, 1), true, isBatch)
	SeqIndex(b::Real, e::Real, isBatch::Bool = false) = new(SeqPart(b, e, 1), true, isBatch)
	SeqIndex(b::Real, e::Real, s::Real, isBatch::Bool = false) = new(SeqPart(b, e, s), true, isBatch)
end

immutable ArrayIndex <: AFIndex
	data::DummySeqPart
	isSeq::Bool
	isBatch::Bool

	ArrayIndex(arr::AFArray, isBatch::Bool = false) = new(toArrayIndexData(arr), false, isBatch)
end

@generated function ptr(arrayIndex::ArrayIndex)
	if UInt == UInt32
		:(reinterpret(Ptr{Void}, arrayIndex.data.i1))
	else
		:(reinterpret(Ptr{Void}, UInt64(arrayIndex.data.i1) << 32 + UInt64(arrayIndex.data.i2)))
	end
end

@generated function toArrayIndexData(arr::AFArray)
	if UInt == UInt32
		:(DummySeqPart(reinterpret(UInt32, _base(arr).ptr), 0, 0, 0, 0, 0))
	else
		:(
			base = _base(arr);
			DummySeqPart(UInt32(reinterpret(UInt64, base.ptr) >> 32), UInt32(reinterpret(UInt64, base.ptr) & 0xFFFFFFFF), 0, 0, 0, 0)
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
