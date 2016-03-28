macro afCall_Arr_Arr(method, holder, func, resultT, size)
	quote
		function $(esc(method)){T, N}(arr::AFArrayWithData{T, N})
			result = Ref{Ptr{Void}}()
			base = getBase(arr)
			af = base.af
			err = ccall(af.$holder.$func,
				Cint, (Ptr{Ptr{Void}}, Ptr{Void}),
				result, base.ptr)
			assertErr(err)
			AFArrayWithData{$resultT(T), $size(N)}(af, result[])
		end
	end
end
