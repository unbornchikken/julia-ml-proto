include("Backend.jl")

export
	DeviceInfo,
	DType,
	Dim4,
	DimT,
	f32,
	c32,
	f64,
	c64,
	b8,
	s32,
	u32,
	u8,
	s64,
	u64

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

const AF_MAT_NONE 		= Int32(0)	# Default.
const AF_MAT_TRANS 		= Int32(1)	# Data needs to be transposed.
const AF_MAT_CTRANS 	= Int32(2)	# Data needs to be conjugate tansposed.
const AF_MAT_CONJ 		= Int32(3)	# Data needs to be conjugate.
const AF_MAT_UPPER 		= Int32(4)	# Matrix is upper triangular.
const AF_MAT_LOWER 		= Int32(5)	# Matrix is lower triangular.
const AF_MAT_DIAG_UNIT 	= Int32(6)	# Matrix diagonal contains unitary values.
const AF_MAT_SYM 		= Int32(7)	# Matrix is symmetric.
const AF_MAT_POSDEF		= Int32(8)	# Matrix is positive definite.
const AF_MAT_ORTHOG 	= Int32(9)	# Matrix is orthogonal.
const AF_MAT_TRI_DIAG 	= Int32(10)	# Matrix is tri diagonal.
const AF_MAT_BLOCK_DIAG = Int32(11)	# Matrix is block diagonal.

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

macro sizeRules(len, d)
	quote
		if $len > 3 && $d[4] > 1
			($d[1], $d[2], $d[3], $d[4])
		elseif $len > 2 && $d[3] > 1
			($d[1], $d[2], $d[3])
		elseif $len > 1 && $d[2] > 1
			($d[1], $d[2])
		elseif $len > 0 && $d[1] > 0
			($d[1],)
		else
			()
		end
	end
end

function dimsToSize(d::DimT...)
	len = length(d)
	@sizeRules(len, d)
end

function dimsToSize(d::Dim4)
	len = length(d)
	@sizeRules(len, d)
end

function dimsToSize(d::Tuple)
	len = length(d)
	@sizeRules(len, d)
end

jlLength(dims::Tuple) = length(dimsToSize(dims))

jlLength(dims::DimT...) = length(dimsToSize(dims...))

jlLength(dims::Dim4) = length(dimsToSize(dims))

function afPromote{T,S}(::Type{T},::Type{S})
    if T == S
        return T
    elseif T == Complex{Float64} || S == Complex{Float64}
        return Complex{Float64}
    elseif T == Complex{Float32} || S == Complex{Float32}
        (T == Float64 || S == Float64) && return Complex{Float64}
        return Complex{Float32}
    elseif T == Float64 || S == Float64
        return Float64
    elseif T == Float32 || S == Float32
        return Float32
    elseif T == UInt64 || S == UInt64
        return UInt64
    elseif T == Int64 || S == Int64
        return Int64
    elseif T == UInt32 || S == UInt32
        return UInt32
    elseif T == Int32 || S == Int32
        return Int32
    elseif T == UInt8 || S == UInt8
        return UInt8
    elseif T == Bool || S == Bool
        return Bool
    else
        return Float32
    end
end
