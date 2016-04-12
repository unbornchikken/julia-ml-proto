macro afCall_Arr_Arr(method, holder, func)
    quote
        function $(esc(method)){B}(arr::AFArray{B})
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
        function $(esc(method)){B}(arr1::AFArray{B}, arr2::AFArray{B}, value)
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

macro afCall_Arr_Arr_Bool(method, holder, func, default)
    quote
        function $(esc(method)){B}(arr::AFArray{B}, value::Bool = $default)
            verifyAccess(arr)
            af = arr.af
            result = af.results.ptr
            err = ccall(af.$holder.$func,
                Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Bool),
                result, arr.ptr, value)
            assertErr(err)
            array(af, result[])
        end
    end
end
