export Backend, CPU, OpenCL, CUDA

abstract Backend

immutable CPU <: Backend end

immutable OpenCL <: Backend end

immutable CUDA <: Backend end
