export FastComparer, fn, reset!

type FastComparer{C<:AbstractComparer} <: AbstractComparer
    c::AbstractComparer
    _results::Dict{Tuple, Nullable{Int}}
end

FastComparer() = FastComparer{Comparer}(Comparer())

FastComparer{C}(c::C) = FastComparer{C}(c, Dict{Tuple, Nullable{Int}}())

FastComparer(fn::Function) = FastComparer{Comparer}(Comparer(fn))

fn(fc::FastComparer) = (a, b) -> compare(fc, a, b) < 0

function compare(fc::FastComparer, a, b)
    key1 = (a, b)
    result = get(fc._results, key1, Nullable{Int}())
    if !isnull(result)
        return get(result)
    end

    key2 = (b, a)
    result = get(fc._results, key2, Nullable{Int}())
    if !isnull(result)
        return -get(result)
    end

    baseFn = fn(fc.c)
    result = 0
    if baseFn(a, b)
        # a < b
        result = -1
    elseif baseFn(b, a)
        # b < a
        result = 1
    end
    fc._results[key1] = result
end

function reset!(fc::FastComparer)
    reset!(fc.c)
    empty!(fc._results)
end
