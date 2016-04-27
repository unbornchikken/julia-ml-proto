import Base: select

export select

immutable MoveAndReorder <: AFImpl
    select::Ptr{Void}
    selectScalarR::Ptr{Void}
    selectScalarL::Ptr{Void}

    function MoveAndReorder(ptr)
        new(
            Libdl.dlsym(ptr, :af_select),
            Libdl.dlsym(ptr, :af_select_scalar_r),
            Libdl.dlsym(ptr, :af_select_scalar_l)
        )
    end
end

function select{B}(cond::AFArray{B}, a::AFArray{B}, b::AFArray{B})
    verifyAccess(cond)
    verifyAccess(a)
    verifyAccess(b)
    af = cond.af
    result = af.results.ptr
    err = ccall(af.moveAndReorder.select,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Ptr{Void}),
        result, cond.ptr, a.ptr, b.ptr)
    assertErr(err)
    array(af, result[])
end

function select{B}(cond::AFArray{B}, a::Real, b::AFArray{B})
    verifyAccess(cond)
    verifyAccess(b)
    af = cond.af
    result = af.results.ptr
    err = ccall(af.moveAndReorder.selectScalarL,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Float64, Ptr{Void}),
        result, cond.ptr, a, b.ptr)
    assertErr(err)
    array(af, result[])
end

function select{B}(cond::AFArray{B}, a::AFArray{B}, b::Real)
    verifyAccess(cond)
    verifyAccess(a)
    af = cond.af
    result = af.results.ptr
    err = ccall(af.moveAndReorder.selectScalarR,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Float64),
        result, cond.ptr, a.ptr, b)
    assertErr(err)
    array(af, result[])
end
