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
		:(Ptr{Void}(arrayIndex.i1))
	else
		:(Ptr{Void}(arrayIndex.i1 << 32 + arrayIndex.i2))
	end
end

@generated function toArrayIndexData(arr::AFArray)
	base = _base(arr)
	if UInt == UInt32
		:(DummySeqPart(UInt32(base.ptr), 0, 0, 0))
	else
		:(DummySeqPart(UInt32(UInt64(base.ptr) >> 32), UInt32(UInt64(base.ptr) & 0xFFFFFFFF), 0, 0))
	end
end
