import Base: abs

export sigmoid, abs

immutable Math <: AFImpl
    sigmoid::Ptr{Void}
    abs::Ptr{Void}

    function Math(ptr)
        new(
            Libdl.dlsym(ptr, :af_sigmoid),
            Libdl.dlsym(ptr, :af_abs)
        )
    end
end

@afCall_Arr_Arr(sigmoid, math, sigmoid)

@afCall_Arr_Arr(abs, math, abs)
