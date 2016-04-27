import Base: .<, .>, .<=, .>=, .==, .!=
export .<, .>, .<=, .>=, .==, .!=, and, or, maxOf, minOf

import Base: .+, .-, .*, ./, .\, .%
export .+, .-, .*, ./, .\, .%

export addAssign!,subAssign!,divAssign!,mulAssign!,modAssign!

immutable Binary <: AFImpl
    le::Ptr{Void}
    lt::Ptr{Void}
    ge::Ptr{Void}
    gt::Ptr{Void}
    eq::Ptr{Void}
    neq::Ptr{Void}
    and::Ptr{Void}
    or::Ptr{Void}
    add::Ptr{Void}
    sub::Ptr{Void}
    mul::Ptr{Void}
    div::Ptr{Void}
    maxOf::Ptr{Void}
    minOf::Ptr{Void}
    mod::Ptr{Void}

    function Binary(ptr)
        new(
            Libdl.dlsym(ptr, :af_le),
            Libdl.dlsym(ptr, :af_lt),
            Libdl.dlsym(ptr, :af_ge),
            Libdl.dlsym(ptr, :af_gt),
            Libdl.dlsym(ptr, :af_eq),
            Libdl.dlsym(ptr, :af_neq),
            Libdl.dlsym(ptr, :af_and),
            Libdl.dlsym(ptr, :af_or),
            Libdl.dlsym(ptr, :af_add),
            Libdl.dlsym(ptr, :af_sub),
            Libdl.dlsym(ptr, :af_mul),
            Libdl.dlsym(ptr, :af_div),
            Libdl.dlsym(ptr, :af_maxof),
            Libdl.dlsym(ptr, :af_minof),
            Libdl.dlsym(ptr, :af_mod)
        )
    end
end

macro binOp(op, cFunc)
    quote
        function $(esc(op)){B}(lhs::AFArray{B}, rhs::AFArray{B})
            verifyAccess(lhs)
            verifyAccess(rhs)
            af = lhs.af
            result = af.results.ptr
            err = ccall(af.binary.$cFunc,
                Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                result, lhs.ptr, rhs.ptr, af.batch)
            assertErr(err)
            AFArray{B}(af, result[])
        end

        function $(esc(op)){B}(lhs::AFArray{B}, rhsConst::Number)
            verifyAccess(lhs)
            af = lhs.af
            result = af.results.ptr
            rhs = constant(af, rhsConst, size(lhs)...)
            try
                err = ccall(af.binary.$cFunc,
                    Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                    result, lhs.ptr, rhs.ptr, af.batch)
                assertErr(err)
                AFArray{B}(af, result[])
            finally
                release!(rhs)
            end
        end

        function $(esc(op)){B}(lhsConst::Number, rhs::AFArray{B})
            verifyAccess(rhs)
            af = rhs.af
            result = af.results.ptr
            lhs = constant(af, lhsConst, size(rhs)...)
            try
                err = ccall(af.binary.$cFunc,
                    Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                    result, lhs.ptr, rhs.ptr, af.batch)
                assertErr(err)
                AFArray{B}(af, result[])
            finally
                release!(lhs)
            end
        end
    end
end

@binOp(.<, lt)
@binOp(.<=, le)
@binOp(.>, gt)
@binOp(.>=, ge)
@binOp(.==, eq)
@binOp(.!=, neq)
@binOp(and, and)
@binOp(or, or)

@binOp(.+, add)
@binOp(.-, sub)
@binOp(.*, mul)
@binOp(./, div)
@binOp(.%, mod)
@binOp(maxOf, maxOf)
@binOp(minOf, minOf)

function .\{B}(lhs::AFArray{B}, rhs::AFArray{B})
    rhs ./ lhs
end

function .\(lhs::AFArray, rhs::Number)
    rhs ./ lhs
end

function .\(lhs::Number, rhs::AFArray)
    rhs ./ lhs
end

macro binOpAssign(op, cFunc)
    quote
        function $(esc(op)){B}(lhs::AFArray{B}, rhs::AFArray{B})
            verifyAccess(lhs)
            verifyAccess(rhs)
            af = lhs.af
            result = af.results.ptr
            err = ccall(af.binary.$cFunc,
                Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                result, lhs.ptr, rhs.ptr, af.batch)
            assertErr(err)
            updatePtr(lhs, result[])
        end

        function $(esc(op)){B}(lhs::AFArray{B}, rhsConst::Number)
            verifyAccess(lhs)
            af = lhs.af
            result = af.results.ptr
            rhs = constant(af, rhsConst, size(lhs)...)
            try
                err = ccall(af.binary.$cFunc,
                    Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                    result, lhs.ptr, rhs.ptr, af.batch)
                assertErr(err)
                updatePtr(lhs, result[])
            finally
                release!(rhs)
            end
        end

        function $(esc(op)){B}(lhsConst::Number, rhs::AFArray{B})
            verifyAccess(rhs)
            af = rhs.af
            result = af.results.ptr
            lhs = constant(af, lhsConst, size(rhs)...)
            try
                err = ccall(af.binary.$cFunc,
                    Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Bool),
                    result, lhs.ptr, rhs.ptr, af.batch)
                assertErr(err)
                updatePtr(lhs, result[])
            finally
                release!(lhs)
            end
        end
    end
end

function updatePtr(arr::AFArray, ptr::Ptr{Void})
    if ptr != arr.ptr
        release!(arr.af, arr.ptr)
        arr.ptr = ptr
    end
end

@binOpAssign(addAssign!, add)
@binOpAssign(subAssign!, sub)
@binOpAssign(mulAssign!, mul)
@binOpAssign(divAssign!, div)
@binOpAssign(modAssign!, mod)
