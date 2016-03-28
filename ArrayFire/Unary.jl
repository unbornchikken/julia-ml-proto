import Base: !
export !

immutable Unary
	not

	function Unary(ptr)
		new(
			Libdl.dlsym(ptr, :af_not)
		)
	end
end

macro unOp(op, cFunc, resultT)
	:( @afCall_Arr_Arr($(esc(op)), unary, $cFunc, $resultT, N -> N) )
end

macro logicUnOp(op, cFunc)
	:( @unOp($(esc(op)), $cFunc, T -> asJType(Val{b8})) )
end

macro arUnOp(op, cFunc)
	:( @unOp($(esc(op)), $cFunc, T -> T) )
end

@logicUnOp(!, not)
