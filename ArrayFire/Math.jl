import Base: abs, round

export sigmoid, abs, round

immutable Math <: AFImpl
    sigmoid::Ptr{Void}
    abs::Ptr{Void}
    round::Ptr{Void}

    function Math(ptr)
        new(
            Libdl.dlsym(ptr, :af_sigmoid),
            Libdl.dlsym(ptr, :af_abs),
            Libdl.dlsym(ptr, :af_round)
        )
    end
end

@afCall_Arr_Arr(sigmoid, math, sigmoid)

@afCall_Arr_Arr(abs, math, abs)

@afCall_Arr_Arr(round, math, round)
