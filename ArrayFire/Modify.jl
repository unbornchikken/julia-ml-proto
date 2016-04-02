export moddims

immutable Modify <: AFImpl
	moddims::Ptr{Void}

	function Modify(ptr)
		new(
			Libdl.dlsym(ptr, :af_moddims)
		)
	end
end

function moddims{D, T, N}(arr::AFArray{D, T, N}, dims::DimT...)
	verifyAccess(arr)
	af = arr.af
	ptr = af.results.ptr
	dims2 = collect(dims)
	err = ccall(af.modify.moddims,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{DimT}),
		ptr, arr.ptr, length(dims2), pointer(dims2))
	assertErr(err)
	array(af, T, ptr[], dims...)
end
