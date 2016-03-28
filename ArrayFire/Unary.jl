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

macro unOp(op, cFunc)
	:( @afCall_Arr_Arr($(esc(op)), unary, $cFunc) )
end

macro logicUnOp(op, cFunc)
	:( @unOp($(esc(op)), $cFunc) )
end

macro arUnOp(op, cFunc)
	:( @unOp($(esc(op)), $cFunc) )
end

@logicUnOp(!, not)
