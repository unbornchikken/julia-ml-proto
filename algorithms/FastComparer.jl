export FastComparer, fn, reset!

type FastComparer{T} <: AbstractComparer{T}
    c::Comparer{T}
    _results::Dict{Tuple{T, T}, Nullable{Int}}

    FastComparer(c) = new(c, Dict{Tuple{T, T}, Nullable{Int}}())
end

FastComparer{T}() = FastComparer{T}(Comparer{T}())

FastComparer{T}(fn::Function) = FastComparer{T}(Comparer{T}(fn))

FastComparer{T}(ac::AbstractComparer{T}) = FastComparer{T}(Comparer{T}(ac))

fn{T}(fc::FastComparer{T}) = (a, b) ->
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

function reset!{T}(fc::FastComparer{T})
    reset!(fc.c)
    empty!(fc._results)
end
