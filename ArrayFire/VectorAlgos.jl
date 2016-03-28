export where

immutable VectorAlgos <: AFImpl
	where::Ptr{Void}

	function VectorAlgos(ptr)
		new(
			Libdl.dlsym(ptr, :af_where)
		)
	end
end

@afCall_Arr_Arr(where, vectorAlgos, where)
