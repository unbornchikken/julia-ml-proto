libPrefix() = @linux? "lib" : @osx? "lib" : ""

libPostfix() = @linux? ".so" : @osx? ".dylib" : ""

@generated libName{T<:Backend}(::Type{T}) =
	if is(T, CPU)
		:("afcpu")
	elseif is(T, OpenCL)
		:("afopencl")
	else
		:("afcuda")
	end

type AFLib{T<:Backend}
	ptr::Ptr{Void}
	err::Nullable{Exception}
	AFLib() =
		try
			ptr = Libdl.dlopen(string(libPrefix(), libName(T), libPostfix()))
			me = new(ptr, Nullable{Exception}())
			finalizer(me, release!)
			me
		catch err
			me = new(C_NULL, Nullable(err))
			finalizer(me, release!)
			me
		end
end

release!{T<:Backend}(lib::AFLib{T}) = Libdl.dlclose(lib.ptr)

function getLibPtr{T<:Backend}(lib::AFLib{T})
	if isnull(lib.err)
		lib.ptr
	else
		throw(get(lib.err))
	end
end

type AFLibs
	CPU::AFLib{CPU}
	CUDA::AFLib{CUDA}
	OpenCL::AFLib{OpenCL}

	AFLibs() = new(AFLib{CPU}(), AFLib{CUDA}(), AFLib{OpenCL}())
end

global afLibs = AFLibs()

@generated getLibPtr{T<:Backend}(::Type{T}) =
	if is(T, CPU)
		:( getLibPtr(afLibs.CPU) )
	elseif is(T, OpenCL)
		:( getLibPtr(afLibs.OpenCL) )
	else
		:( getLibPtr(afLibs.CUDA) )
	end
