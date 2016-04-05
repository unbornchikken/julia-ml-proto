import Base: .<, .>, .<=, .>=, .==, .!=
export .<, .>, .<=, .>=, .==, .!=, and, or, maxOf, minOf

import Base: .+, .-, .*, ./, .\
export .+, .-, .*, ./, .\

immutable Binary <: AFImpl
	le::Ptr{Void}
	lt::Ptr{Void}
	ge::Ptr{Void}
	gt::Ptr{Void}
	eq::Ptr{Void}
	neq::Ptr{Void}
	and::Ptr{Void}
	or::Ptr{Void}
	add::Ptr{Void}
	sub::Ptr{Void}
	mul::Ptr{Void}
	div::Ptr{Void}
	maxOf::Ptr{Void}
	minOf::Ptr{Void}

	function Binary(ptr)
		new(
			Libdl.dlsym(ptr, :af_le),
			Libdl.dlsym(ptr, :af_lt),
			Libdl.dlsym(ptr, :af_ge),
			Libdl.dlsym(ptr, :af_gt),
			Libdl.dlsym(ptr, :af_eq),
			Libdl.dlsym(ptr, :af_neq),
			Libdl.dlsym(ptr, :af_and),
			Libdl.dlsym(ptr, :af_or),
			Libdl.dlsym(ptr, :af_add),
			Libdl.dlsym(ptr, :af_sub),
			Libdl.dlsym(ptr, :af_mul),
			Libdl.dlsym(ptr, :af_div),
			Libdl.dlsym(ptr, :af_maxof),
			Libdl.dlsym(ptr, :af_minof)
		)
	end
end

macro binOp(op, cFunc, resultT)
	quote
		function $(esc(op)){D, T1, N1, T2, N2}(lhs::AFArray{D, T1, N1}, rhs::AFArray{D, T2, N2})
			verifyAccess(lhs)
			verifyAccess(rhs)
			af = lhs.af
			result = af.results.ptr
			err = ccall(af.binary.$cFunc,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
				result, lhs.ptr, rhs.ptr, af.batch)
			assertErr(err)
			AFArray{D, $resultT(T1, T2), max(N1, N2)}(af, result[])
		end

		function $(esc(op)){D, T, N}(lhs::AFArray{D, T, N}, rhsConst::Number)
			verifyAccess(lhs)
			af = lhs.af
			result = af.results.ptr
			rhs = constant(af, rhsConst, size(lhs)...)
			try
				err = ccall(af.binary.$cFunc,
					Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
					result, lhs.ptr, rhs.ptr, af.batch)
				assertErr(err)
				AFArray{D, $resultT(T, typeof(rhsConst)), N}(af, result[])
			finally
				release!(rhs)
			end
		end

		function $(esc(op)){D, T, N}(lhsConst::Number, rhs::AFArray{D, T, N})
			verifyAccess(rhs)
			af = rhs.af
			result = af.results.ptr
			lhs = constant(af, lhsConst, size(rhs)...)
			try
				err = ccall(af.binary.$cFunc,
					Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
					result, lhs.ptr, rhs.ptr, af.batch)
				assertErr(err)
				AFArray{D, $resultT(typeof(lhsConst), T), N}(af, result[])
			finally
				release!(lhs)
			end
		end
	end
end

macro logicBinOp(op, cFunc)
	:( @binOp($(esc(op)), $cFunc, (lhsT, rhsT) -> asJType(Val{b8})) )
end

macro arBinOp(op, cFunc)
	:( @binOp($(esc(op)), $cFunc, (lhsT, rhsT) -> afPromote(lhsT, rhsT)) )
end

@logicBinOp(.<, lt)
@logicBinOp(.<=, le)
@logicBinOp(.>, gt)
@logicBinOp(.>=, ge)
@logicBinOp(.==, eq)
@logicBinOp(.!=, neq)
@logicBinOp(and, and)
@logicBinOp(or, or)

@arBinOp(.+, add)
@arBinOp(.-, sub)
@arBinOp(.*, mul)
@arBinOp(./, div)
@arBinOp(maxOf, maxOf)
@arBinOp(minOf, minOf)

function .\{T1, N1, T2, N2}(lhs::AFArray{T1, N1}, rhs::AFArray{T2, N2})
	rhs ./ lhs
end

function .\{T, N}(lhs::AFArray{T, N}, rhs::Number)
	rhs ./ lhs
end

function .\{T, N}(lhs::Number, rhs::AFArray{T, N})
	rhs ./ lhs
end
