abstract AbstractComparer{T}

immutable Comparer{T} <: AbstractComparer{T}
    fn::Function
    reset::Nullable{Function}
end

Comparer{T}() = Comparer{T}((x::T, y::T) -> <(x, y), Nullable{Function}())

Comparer{T}(fn::Function) = Comparer{T}(fn, Nullable{Function}())

Comparer{T}(ac::AbstractComparer{T}) = Comparer{T}(fn(ac), () -> reset!(ac))

fn{T}(c::Comparer{T}) = c.fn

reset!{T}(c::Comparer{T}) = !isnull(c.reset) && c.reset()
