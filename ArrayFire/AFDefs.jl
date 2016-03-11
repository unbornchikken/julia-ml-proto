export Backend

@enum Backend Default CPU CUDA OpenCL

export DeviceInfo

immutable DeviceInfo
	id
	name
	platform
	toolkit
	compute
end

export DType, f32, c32, f64, c64, b8, s32, u32, u8, s64, u64

typealias DType UInt32
const f32 = DType(0) # 32-bit floating point values
const c32 = DType(1) # 32-bit complex floating point values
const f64 = DType(2) # 64-bit complex floating point values
const c64 = DType(3) # 64-bit complex floating point values
const b8  = DType(4) #  8-bit boolean values
const s32 = DType(5) # 32-bit signed integral values
const u32 = DType(6) # 32-bit unsigned integral values
const u8  = DType(7) #  8-bit unsigned integral values
const s64 = DType(8) # 64-bit signed integral values
const u64 = DType(9) # 64-bit unsigned integral values

export asDType

asDType(::Type{Float32})          = f32
asDType(::Type{Complex{Float32}}) = c32
asDType(::Type{Float64})          = f64
asDType(::Type{Complex{Float64}}) = c64
asDType(::Type{Bool})             = b8
asDType(::Type{Int32})            = s32
asDType(::Type{UInt32})           = u32
asDType(::Type{UInt8})            = u8
asDType(::Type{Int64})            = s64
asDType(::Type{UInt64})           = u64

export asJType

function asJType(dtype)
    if dtype == f32
        return Float32
    elseif dtype == c32
        return Complex{Float32}
    elseif dtype == f64
        return Float64
    elseif dtype == c64
        return Complex{Float64}
    elseif dtype == b8
        return Bool
    elseif dtype == s32
        return Int32
    elseif dtype == u32
        return UInt32
    elseif dtype == u8
        return UInt8
    elseif dtype == s64
        return Int64
    elseif dtype == u64
        return UInt64
    end
end

export Dim4, DimT

typealias DimT Int64
typealias Dim4 Vector{DimT}
