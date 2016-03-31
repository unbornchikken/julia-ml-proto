macro afCall_Arr_Arr(method, holder, func)
	quote
		function $(esc(method)){D, T, N}(arr::AFArray{D, T, N})
			verifyAccess(arr)
			af = arr.af
			result = af.results.ptr
			err = ccall(af.$holder.$func,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}),
				result, arr.ptr)
			assertErr(err)
			array(af, result[])
		end
	end
end

macro afCall_Arr_Arr_Arr_Unsigned(method, holder, func)
	quote
		function $(esc(method)){D, T1, N1, T2, N2}(arr1::AFArray{D, T1, N1}, arr2::AFArray{D, T2, N2}, value)
			verifyAccess(arr1)
			verifyAccess(arr2)
			af = arr1.af
			result = af.results.ptr
			err = ccall(af.$holder.$func,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, UInt32),
				result, arr1.ptr, arr2.ptr, UInt32(value))
			assertErr(err)
			array(af, result[])
		end
	end
end
