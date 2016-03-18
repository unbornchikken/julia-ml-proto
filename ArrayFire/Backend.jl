export Backend
export CPU
export OpenCL
export CUDA

abstract Backend

immutable CPU <: Backend end

immutable OpenCL <: Backend end

immutable CUDA <: Backend end
