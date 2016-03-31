import arr: getindex, setindex!
export getindex, setindex!
export Seq, Span

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

function indexGen{D, T, N, I<:AFIndex}(arr::AFArray{D, T, N}, indices::I...)
	indices2 = collect(indices)
	af = arr.af
	ptr = af.results.ptr
	err = ccall(af.index.indexGen,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{I}),
		ptr, arr.ptr, length(indices2), pointer(indices2))
	assertErr(err)
	array(af, T, ptr[])
end

function assignGen{D, T, N, I<:AFIndex}(arr::AFArray{D, T, N}, rhs::AFArray{D}, indices::I...)
	indices2 = collect(indices)
	arrRhs = _arr(rhs)
	af = arr.af
	ptr = af.results.ptr
	err = ccall(af.index.assignGen,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{I}, Ptr{Void}),
		ptr, arr.ptr, length(indices2), pointer(indices2), arrRhs.ptr)
	assertErr(err)
	ptr[]
end

immutable Span end

function getindex{D, T, N}(arr::AFArray{D, T, N})
	verifyAccess(arr)
	array(arr.af, T, N, retain!(arr.af, arr.ptr))
end

function setindex!{D, T, N}(arr::AFArray{D, T, N}, rhs::AFArray{D, T, N})
	verifyAccess(arr)
	verifyAccess(rhs)
	if arr.ptr != rhs.ptr
		release!(arr)
		arr.ptr = retain!(arr.af, rhs.ptr)
	end
end

@generated function getindex{D, T, N}(arr::AFArray{D, T, N}, args...)
	exp = genIndices(arr, args...)
	:( verifyAccess(arr); $exp; indexGen(arr, indices...) )
end

@generated function setindex!{D, T, N, V}(arr::AFArray{D, T, N}, rhs::V, args...)
	exp = genIndices(arr, args...)
	if rhs <: Real
		quote
			verifyAccess(arr)
			$exp
			val = constant(arr.af, rhs, genDims(arr, indices...)...)
			try
				outPtr = assignGen(arr, val, indices...)
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
			outPtr = assignGen(arr, rhs, indices...)
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

function genIndices{D, T, N}(arr::Type{AFArray{D, T, N}}, args::Type...)
	exp = :( indices = Array{AFIndex}(length(args)) )
	i = 1
	for arg in args
		if is(arg, Seq)
			exp = :( $exp; indices[$i] = SeqIndex(args[$i], arr.af.batch) )
		elseif arg <: AFArray{D}
			exp = :( verifyAccess(args[$i]); $exp; indices[$i] = ArrayIndex(args[$i], arr.af.batch) )
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
		else
			error("Unknown argument type at $i")
		end
		i = i + 1
	end
	exp
end
