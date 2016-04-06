export sigmoid

immutable Math <: AFImpl
	sigmoid::Ptr{Void}

	function Math(ptr)
		new(
			Libdl.dlsym(ptr, :af_sigmoid)
		)
	end
end

afCall_Arr_Arr(sigmoid, math, sigmoid)
