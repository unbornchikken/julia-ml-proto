import Base: min, max, sum

export max, maxAll, imax, imaxAll, min, minAll, imin, iminAll, sum, sumAll

immutable Reduction <: AFImpl
	max::Ptr{Void}
	maxAll::Ptr{Void}
	imax::Ptr{Void}
	imaxAll::Ptr{Void}
	min::Ptr{Void}
	minAll::Ptr{Void}
	imin::Ptr{Void}
	iminAll::Ptr{Void}
	sum::Ptr{Void}
	sumNan::Ptr{Void}
	sumAll::Ptr{Void}
	sumNanAll::Ptr{Void}

	function Reduction(ptr)
		new(
			Libdl.dlsym(ptr, :af_max),
			Libdl.dlsym(ptr, :af_max_all),
			Libdl.dlsym(ptr, :af_imax),
			Libdl.dlsym(ptr, :af_imax_all),
			Libdl.dlsym(ptr, :af_min),
			Libdl.dlsym(ptr, :af_min_all),
			Libdl.dlsym(ptr, :af_imin),
			Libdl.dlsym(ptr, :af_imin_all),
			Libdl.dlsym(ptr, :af_sum),
			Libdl.dlsym(ptr, :af_sum_nan),
			Libdl.dlsym(ptr, :af_sum_all),
			Libdl.dlsym(ptr, :af_sum_nan_all)
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
			array(af, T, result[])
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
			array(af, T, result[]), array(af, UInt32, idx[])
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

function sum{D, T, N}(arr::AFArray{D, T, N}, dim::Int = -1)
	verifyAccess(arr)
	af = arr.af
	result = af.results.ptr
	err = ccall(af.reduction.sum,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32),
		result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim))
	assertErr(err)
	array(af, result[])
end

function sum{D, T<:Union{Float32,Float64}, N}(arr::AFArray{D, T, N}, dim::Int, nanVal::T)
	verifyAccess(arr)
	af = arr.af
	result = af.results.ptr
	err = ccall(af.reduction.sumNan,
		Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Int32, Float64),
		result, arr.ptr, Int32(dim < 0 ? firstDim(af, arr.ptr) - 1 : dim), nanVal)
	assertErr(err)
	array(af, result[])
end

function sumAll{D, T<:Real, N}(arr::AFArray{D, T, N})
	verifyAccess(arr)
	af = arr.af
	real = af.results.double
	imag = af.results.double2
	err = ccall(af.reduction.sumAll,
		Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}),
		real, imag, arr.ptr)
	assertErr(err)
	real[]
end

function sumAll{D, T<:Union{Float32,Float64}, N}(arr::AFArray{D, T, N}, nanVal::T)
	verifyAccess(arr)
	af = arr.af
	real = af.results.double
	imag = af.results.double2
	err = ccall(af.reduction.sumNanAll,
		Cint, (Ptr{Float64}, Ptr{Float64}, Ptr{Void}, Float64),
		real, imag, arr.ptr, nanVal)
	assertErr(err)
	real[]
end
