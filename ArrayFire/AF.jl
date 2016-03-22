module AF

include("AFDefs.jl")
include("AFError.jl")

export
	ArrayFire,
	getSupportedBackends,
	scope!,
	register!

immutable ArrayFire{T<:Backend}
	ptr
	device
	create
	binary
	index
	createHandle
	createArray
	releaseArray
	getDims
	getDataPtr
	getType
	getNumDims
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
			Index(ptr),
			Libdl.dlsym(ptr, :af_create_handle),
			Libdl.dlsym(ptr, :af_create_array),
			Libdl.dlsym(ptr, :af_release_array),
			Libdl.dlsym(ptr, :af_get_dims),
			Libdl.dlsym(ptr, :af_get_data_ptr),
			Libdl.dlsym(ptr, :af_get_type),
			Libdl.dlsym(ptr, :af_get_numdims),
			FreeList(),
			false)
	end
end

function getSupportedBackends()
	backends = Vector{Any}()
	for b in [CPU, CUDA, OpenCL]
		try
			ArrayFire{b}()
			push!(backends, b)
		catch
		end
	end
	backends
end

include("AFArray.jl")
include("AFDevice.jl")
include("Create.jl")
include("Binary.jl")
include("Index.jl")
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
