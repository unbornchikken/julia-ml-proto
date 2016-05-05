export CalculateComparer, fn, reset!

type CalculateComparer{S, T} <: AbstractComparer{T}
    factory::Function
    c::Comparer{T}
    _results::Dict{S, Nullable{T}}

    CalculateComparer(factory, c) = new(factory, c, Dict{S, Nullable{T}}())

    CalculateComparer(factory::Function) = new(factory, Comparer{T}())

    CalculateComparer(factory::Function, fn::Function) = new(factory, Comparer{T}(fn))

    CalculateComparer(factory::Function, cc::AbstractComparer{T}) = new(factory, Comparer{T}(cc))
end

fn{T}(cc::CalculateComparer{T}) = (a, b) ->
begin
    baseFn = fn(cc.c)
    aResult = create!(cc, a)
    bResult = create!(cc, b)
    baseFn(aResult, bResult)
end

function create!{S, T}(cc::CalculateComparer{T}, source::S)
    result = get(cc._results, source, Nullable{T}())
    if !isnulle(result)
        return get(result)
    end
    cc._result[source] = cc.factory(source)
end

function reset!{T}(cc::CalculateComparer{T})
    reset!(cc.c)
    empty!(cc._results)
end
