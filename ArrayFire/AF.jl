module AF

include("AFDefs.jl")
include("AFError.jl")

export
	ArrayFire,
	getSupportedBackends,
	scope!,
	register!

include("AFLib.jl")

type ArrayFire{T<:Backend}
	ptr
	device
	create
	binary
	unary
	index
	vectorAlgos
	createHandle
	createArray
	releaseArray
	getDims
	getDataPtr
	getType
	getNumDims
	getElements
	freeList
	batch

	function ArrayFire()
		ptr = getLibPtr(T)
		af = new(
			ptr,
			AFDevice(ptr),
			Create(ptr),
			Binary(ptr),
			Unary(ptr),
			Index(ptr),
			VectorAlgos(ptr),
			Libdl.dlsym(ptr, :af_create_handle),
			Libdl.dlsym(ptr, :af_create_array),
			Libdl.dlsym(ptr, :af_release_array),
			Libdl.dlsym(ptr, :af_get_dims),
			Libdl.dlsym(ptr, :af_get_data_ptr),
			Libdl.dlsym(ptr, :af_get_type),
			Libdl.dlsym(ptr, :af_get_numdims),
			Libdl.dlsym(ptr, :af_get_elements),
			FreeList(),
			false)
		af
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

include("AFDevice.jl")
include("AFArray.jl")
include("macros.jl")
include("Create.jl")
include("Binary.jl")
include("Unary.jl")
include("Index.jl")
include("VectorAlgos.jl")
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
