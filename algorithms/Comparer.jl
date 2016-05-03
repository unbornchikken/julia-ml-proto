# abstract Comparer{T}
#
# ltFunction(comparer::Comparer{T}) = (x::T, y::T) -> <(x, y)

immutable Comparer{T}
    lt::Function
end

Comparer{T}() = Comparer{T}((x::T, y::T) -> <(x, y))
