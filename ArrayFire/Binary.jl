import Base: .<

immutable Binary
	le
	lt
	ge
	gt

	function Binary(ptr)
		new(
			Libdl.dlsym(ptr, :af_le),
			Libdl.dlsym(ptr, :af_lt),
			Libdl.dlsym(ptr, :af_ge),
			Libdl.dlsym(ptr, :af_gt)
		)
	end
end

function .<{T, N, M}(lhs::AFArrayWithData{T, N}, rhs::AFArrayWithData{T, M})
	result = Ref{Ptr{Void}}()
	lhsBase = getBase(lhs)
	rhsBase = getBase(rhs)
	af = lhsBase.af
	err = ccall(af.binary.lt,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
		result, lhsBase.ptr, rhsBase.ptr, af.batch)
	assertErr(err)
	AFArrayWithData{asJType(Val{b8}), max(M, N)}(af, result[])
end
