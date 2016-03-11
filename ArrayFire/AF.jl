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
			Libdl.dlsym(ptr, :af_create_array))
	end
end

include("AFDevice.jl")
include("AFArray.jl")

end # module
