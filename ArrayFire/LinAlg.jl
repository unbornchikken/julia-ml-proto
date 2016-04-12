export matmul, matmulTT, matmulNT, matmulTN

immutable LinAlg <: AFImpl
    matmul::Ptr{Void}

    function LinAlg(ptr)
        new(
            Libdl.dlsym(ptr, :af_matmul)
        )
    end
end

function matmul{B}(
    lhs::AFArray{B},
    rhs::AFArray{B},
    optLhs = AF_MAT_NONE,
    optRhs = AF_MAT_NONE)
    verifyAccess(lhs)
    verifyAccess(rhs)
    af = lhs.af
    result = af.results.ptr
    err = ccall(af.linAlg.matmul,
        Cint, (Ptr{Ptr{Void}}, Ptr{Void}, Ptr{Void}, Int32, Int32),
        result, lhs.ptr, rhs.ptr, optLhs, optRhs)
    assertErr(err)
    array(af, result[])
end

matmulTT(lhs, rhs) = matmul(lhs, rhs, AF_MAT_TRANS, AF_MAT_TRANS)

matmulTN(lhs, rhs) = matmul(lhs, rhs, AF_MAT_TRANS, AF_MAT_NONE)

matmulNT(lhs, rhs) = matmul(lhs, rhs, AF_MAT_NONE, AF_MAT_TRANS)
