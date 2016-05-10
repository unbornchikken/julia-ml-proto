export AbstractComparer, Comparer, fn, reset!

abstract AbstractComparer

call(c::AbstractComparer, x, y) = fn(c)(x, y)

immutable Comparer <: AbstractComparer
    fn::Function
    reset::Nullable{Function}
end

Comparer() = Comparer((x, y) -> <(x, y), Nullable{Function}())

Comparer(fn::Function) = Comparer(fn, Nullable{Function}())

Comparer(ac::AbstractComparer) = Comparer(fn(ac), () -> reset!(ac))

fn(c::Comparer) = c.fn

reset!(c::Comparer) = !isnull(c.reset) && c.reset()
