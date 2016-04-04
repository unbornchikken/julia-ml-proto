import Base: min, max

export max, maxAll, imax, imaxAll, min, minAll, imin, iminAll

immutable Reduction <: AFImpl
	max::Ptr{Void}
	maxAll::Ptr{Void}
	imax::Ptr{Void}
	imaxAll::Ptr{Void}
	min::Ptr{Void}
	minAll::Ptr{Void}
	imin::Ptr{Void}
	iminAll::Ptr{Void}

	function Reduction(ptr)
		new(
			Libdl.dlsym(ptr, :af_max),
			Libdl.dlsym(ptr, :af_max_all),
			Libdl.dlsym(ptr, :af_imax),
			Libdl.dlsym(ptr, :af_imax_all),
			Libdl.dlsym(ptr, :af_min),
			Libdl.dlsym(ptr, :af_min_all),
			Libdl.dlsym(ptr, :af_imin),
			Libdl.dlsym(ptr, :af_imin_all)
		)
	end
end

macro minMaxRed(regular, all, indexed, indexedAll)
	quote
		function $(esc(regular)){D, T, N}(arr::AFArray{D, T, N}, dim = -1)
			verifyAccess(arr)
			af = arr.af
			result = af.results.ptr
			err = ccall(af.reduction.$regular,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32),
				result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
			assertErr(err)
			array(af, result[])
		end

		function $(esc(all)){D, T<:Real, N}(arr::AFArray{D, T, N})
			verifyAccess(arr)
			af = arr.af
			real = af.results.double
			imag = af.results.double2
			err = ccall(af.reduction.$all,
				Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}),
				real, imag, arr.ptr)
			assertErr(err)
			real[]
		end

		function $(esc(indexed)){D, T, N}(arr::AFArray{D, T, N}, dim = -1)
			verifyAccess(arr)
			af = arr.af
			result = af.results.ptr
			idx = af.results.ptr2
			err = ccall(af.reduction.$indexed,
				Cint, (Ptr{Ptr{Void}}, Ptr{Ptr{Void}}, Ptr{Void}, Int32),
				result, idx, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
			assertErr(err)
			array(af, result[]), array(af, idx[])
		end

		function $(esc(indexedAll)){D, T<:Real, N}(arr::AFArray{D, T, N})
			verifyAccess(arr)
			af = arr.af
			real = af.results.double
			imag = af.results.double2
			idx = af.results.uint
			err = ccall(af.reduction.$indexedAll,
				Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{UInt32}, Ptr{Void}),
				real, imag, idx, arr.ptr)
			assertErr(err)
			real[], idx[]
		end
	end
end

@minMaxRed(max, maxAll, imax, imaxAll)

@minMaxRed(min, minAll, imin, iminAll)
