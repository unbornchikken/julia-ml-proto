import Base: mean

export mean, stdev

immutable Statistics <: AFImpl
    mean::Ptr{Void}
    stdev::Ptr{Void}

    function Statistics(ptr)
        new(
            Libdl.dlsym(ptr, :af_mean),
            Libdl.dlsym(ptr, :af_stdev)
        )
    end
end

@afCall_Arr_Arr_DimT(mean, statistics, mean, -1)

@afCall_Arr_Arr_DimT(stdev, statistics, stdev, -1)
