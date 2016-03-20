include("Backend.jl")

export DeviceInfo
export DType
export Dim4
export DimT

immutable DeviceInfo
	id
	name
	platform
	toolkit
	compute
end

function toString(info::DeviceInfo)
	"ID: $(info.id)\nName: $(info.name)\nPlatform: $(info.platform)\nToolkit: $(info.toolkit)\nCompute: $(info.compute)"
end

Base.print(io::IOBuffer, info::DeviceInfo) = Base.print(io, toString(info))
Base.print(info::DeviceInfo) = Base.print(toString(info))

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

asJType(::Type{Val{f32}}) = Float32
asJType(::Type{Val{c32}}) = Complex{Float32}
asJType(::Type{Val{f64}}) = Float64
asJType(::Type{Val{c64}}) = Complex{Float64}
asJType(::Type{Val{b8}}) = Bool
asJType(::Type{Val{s32}}) = Int32
asJType(::Type{Val{u32}}) = UInt32
asJType(::Type{Val{u8}}) = UInt8
asJType(::Type{Val{s64}}) = Int64
asJType(::Type{Val{u64}}) = UInt64

typealias DimT Int64
typealias Dim4 Vector{DimT}

dimsToDim4(dims) =
	if length(dims) == 1
        [dims[1]]
    elseif length(dims) == 2
        [dims[1], dims[2]]
    elseif length(dims) == 3
        [dims[1], dims[2], dims[4]]
    elseif length(dims) == 4
        [dims[1], dims[2], dims[3], dims[4]]
    else
        throw(ArgumentError("Too many dimensions"))
    end

function dimsToSize(d::DimT...)
	len = size(d)
	if len > 3 && d[4] > 1
		(d[1], d[2], d[3], d[4])
	elseif len > 2 && d[3] > 1
		(d[1], d[2], d[3])
	elseif len > 1 && d[2] > 1
		(d[1], d[2])
	elseif len > 0 && d[1] > 1
		(d[1],)
	else
		()
	end
end

function dimsToSize(d::Dim4)
	len = length(d)
	if len > 3 && d[4] > 1
		(d[1], d[2], d[3], d[4])
	elseif len > 2 && d[3] > 1
		(d[1], d[2], d[3])
	elseif len > 1 && d[2] > 1
		(d[1], d[2])
	elseif len > 0 && d[1] > 1
		(d[1],)
	else
		()
	end
end
