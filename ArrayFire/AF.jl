module AF

include("AFDefs.jl")
include("AFError.jl")

export ArrayFire
export scope!
export register!

immutable ArrayFire{T<:Backend}
	ptr
	device
	create
	binary
	createHandle
	createArray
	releaseArray
	getDims
	getDataPtr
	freeList
	batch

	function ArrayFire()
		lib = if is(T, OpenCL)
			"afopencl"
		elseif is(T, CUDA)
			"afcuda"
		else
			"afcpu"
		end
		ptr = Libdl.dlopen(lib)
		new(
			ptr,
			AFDevice(ptr),
			Create(ptr),
			Binary(ptr),
			Libdl.dlsym(ptr, :af_create_handle),
			Libdl.dlsym(ptr, :af_create_array),
			Libdl.dlsym(ptr, :af_release_array),
			Libdl.dlsym(ptr, :af_get_dims),
			Libdl.dlsym(ptr, :af_get_data_ptr),
			FreeList(),
			false)
	end
end

include("AFArray.jl")
include("AFDevice.jl")
include("Create.jl")
include("Binary.jl")
include("FreeList.jl")

immutable ScopeHandle
	result::Function
	register::Function
end

function scope!(pred, af::ArrayFire)
	newScope!(af.freeList)
	try
		h = ScopeHandle(arr -> markResult!(af.freeList, arr), arr -> register!(af.freeList, arr))
		pred(h)
	finally
		endScope!(af.freeList)
	end
end

function register!(af::ArrayFire, arr::AFArray)
	register!(af.freeList, arr)
end

end # module
