import Base: .<,.>,.<=,.>=,==,!=
export .<,.>,.<=,.>=,==,!=,and,or

immutable Binary
	le
	lt
	ge
	gt
	eq
	neq
	and
	or

	function Binary(ptr)
		new(
			Libdl.dlsym(ptr, :af_le),
			Libdl.dlsym(ptr, :af_lt),
			Libdl.dlsym(ptr, :af_ge),
			Libdl.dlsym(ptr, :af_gt),
			Libdl.dlsym(ptr, :af_eq),
			Libdl.dlsym(ptr, :af_neq),
			Libdl.dlsym(ptr, :af_and),
			Libdl.dlsym(ptr, :af_or)
		)
	end
end

macro binOp(op, cFunc, resultT)
	quote
		function $(esc(op)){T1, N1, T2, N2}(lhs::AFArrayWithData{T1, N1}, rhs::AFArrayWithData{T2, N2})
			result = Ref{Ptr{Void}}()
			lhsBase = getBase(lhs)
			rhsBase = getBase(rhs)
			af = lhsBase.af
			err = ccall(af.binary.$cFunc,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
				result, lhsBase.ptr, rhsBase.ptr, af.batch)
			assertErr(err)
			AFArrayWithData{$resultT, max(N1, N2)}(af, result[])
		end

		function $(esc(op)){T, N}(lhs::AFArrayWithData{T, N}, rhsConst::Number)
			result = Ref{Ptr{Void}}()
			lhsBase = getBase(lhs)
			af = lhsBase.af
			rhs = constant(af, rhsConst, size(lhs)...)
			try
				rhsBase = getBase(rhs)
				err = ccall(af.binary.$cFunc,
					Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
					result, lhsBase.ptr, rhsBase.ptr, af.batch)
				assertErr(err)
				AFArrayWithData{$resultT, N}(af, result[])
			finally
				release!(rhs)
			end
		end

		function $(esc(op)){T, N}(lhsConst::Number, rhs::AFArrayWithData{T, N})
			result = Ref{Ptr{Void}}()
			rhsBase = getBase(rhs)
			af = rhsBase.af
			lhs = constant(af, lhsConst, size(rhs)...)
			try
				lhsBase = getBase(lhs)
				err = ccall(af.binary.$cFunc,
					Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
					result, lhsBase.ptr, rhsBase.ptr, af.batch)
				assertErr(err)
				AFArrayWithData{$resultT, N}(af, result[])
			finally
				release!(lhs)
			end
		end
	end
end

macro logicBinOp(op, cFunc)
	:( @binOp($(esc(op)), $cFunc, asJType(Val{b8})) )
end

@logicBinOp(.<, lt)
@logicBinOp(.<=, le)
@logicBinOp(.>, gt)
@logicBinOp(.>=, ge)
@logicBinOp(==, eq)
@logicBinOp(!=, neq)
@logicBinOp(and, and)
@logicBinOp(or, or)
