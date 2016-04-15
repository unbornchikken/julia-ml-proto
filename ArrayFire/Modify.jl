export moddims, joinArrays

immutable Modify <: AFImpl
    moddims::Ptr{Void}
    join::Ptr{Void}
    join_many::Ptr{Void}

    function Modify(ptr)
        new(
            Libdl.dlsym(ptr, :af_moddims),
            Libdl.dlsym(ptr, :af_join),
            Libdl.dlsym(ptr, :af_join_many)
        )
    end
end

function moddims(arr::AFArray, dims::DimT...)
    verifyAccess(arr)
    af = arr.af
    ptr = af.results.ptr
    dims2 = collectDims(af.results.dims, dims)
    err = ccall(af.modify.moddims,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, DimT, Ptr{DimT}),
        ptr, arr.ptr, length(dims2), pointer(dims2))
    assertErr(err)
    array(af, ptr[])
end

@generated function joinArrays{B}(dim::Int, arrays::AFArray{B}...)
    len = length(arrays)
    if len == 1
        :( arrays[1] )
    elseif len == 2
        quote
            arr1 = arrays[1]
            arr2 = arrays[2]
            verifyAccess(arr1)
            verifyAccess(arr2)
            af = arr1.af
            ptr = af.results.ptr
            err = ccall(af.modify.join,
                Cint, (Ptr{Ptr{Void}}, Int32, Ptr{Void}, Ptr{Void}),
                ptr, dim, arr1.ptr, arr2.ptr)
            assertErr(err)
            array(af, ptr[])
        end
    else
        quote
            arrPtrs = map(arr -> (verifyAccess(arr); arr.ptr), collect(arrays))
            af = arrays[1].af
            ptr = af.results.ptr
            err = ccall(af.modify.join_many,
                Cint, (Ptr{Ptr{Void}}, Int32, UInt32, Ptr{Ptr{Void}}),
                ptr, dim, length(arrPtrs), pointer(arrPtrs))
            assertErr(err)
            array(af, ptr[])
        end
    end
end
