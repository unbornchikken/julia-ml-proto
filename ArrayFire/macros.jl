macro afCall_Arr_Arr(method, holder, func)
	quote
		function $(esc(method)){T, N}(arr::AFArray{T, N})
			base = getBase(arr)
			af = base.af
			result = af.results.ptr
			err = ccall(af.$holder.$func,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}),
				result, base.ptr)
			assertErr(err)
			array(af, result[])
		end
	end
end

macro afCall_Arr_Arr_Arr_Unsigned(method, holder, func)
	quote
		function $(esc(method)){T1, N1, T2, N2}(arr1::AFArray{T1, N1}, arr2::AFArray{T2, N2}, value)
			base1 = getBase(arr1)
			af = base1.af
			result = af.results.ptr
			base2 = getBase(arr2)
			err = ccall(af.$holder.$func,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, UInt32),
				result, base1.ptr, base2.ptr, UInt32(value))
			assertErr(err)
			array(af, result[])
		end
	end
end
