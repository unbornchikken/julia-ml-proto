export FastComparer, fn, reset!

type FastComparer <: AbstractComparer
    c::Comparer
    _results::Dict{Tuple, Nullable{Int}}

    FastComparer(c) = new(c, Dict{Tuple, Nullable{Int}}())
end

FastComparer() = FastComparer(Comparer())

FastComparer(fn::Function) = FastComparer(Comparer(fn))

FastComparer(ac::AbstractComparer) = FastComparer(Comparer(ac))

fn(fc::FastComparer) = (a, b) ->
begin
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
