module AF

include("AFDefs.jl")
include("AFError.jl")

export ArrayFire

immutable ArrayFire
	backend::Backend
	ptr
	device
	createHandle
	createArray
	releaseArray
	freeList

	function ArrayFire(backend)
		lib = if backend == OpenCL
			"afopencl"
		elseif backend == CUDA
			"afcuda"
		else
			"afcpu"
		end
		ptr = Libdl.dlopen(lib)
		new(
			backend,
			ptr,
			AFDevice(ptr),
			Libdl.dlsym(ptr, :af_create_handle),
			Libdl.dlsym(ptr, :af_create_array),
			Libdl.dlsym(ptr, :af_release_array),
			FreeList())
	end
end

include("AFDevice.jl")
include("AFArray.jl")
include("FreeList.jl")

function scope!(pred, af::ArrayFire)
	newScope!(af.freeList)
	try
		pred(arr -> markResult!(af.freeList, arr))
	finally
		endScope!(af.freeList)
	end
end

function register!(af::ArrayFire, arr::AFArray)
	register!(af.freeList, arr)
end

end # module
