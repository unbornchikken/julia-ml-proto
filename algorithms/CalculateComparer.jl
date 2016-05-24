export CalculateComparer, fn, reset!

type CalculateComparer{C<:AbstractComparer} <: AbstractComparer
    factory::Function
    c::C
    _results::Dict{Any, Nullable{Any}}
end

CalculateComparer(factory::Function) = CalculateComparer{Comparer}(factory, Comparer(), Dict{Any, Nullable{Any}}())

CalculateComparer(factory::Function, fn::Function) = CalculateComparer{Comparer}(factory, Comparer(fn), Dict{Any, Nullable{Any}}())

CalculateComparer{C}(factory::Function, c::C) = CalculateComparer{C}(factory, c, Dict{Any, Nullable{Any}}())

fn(cc::CalculateComparer) = (a, b) ->
begin
    baseFn = fn(cc.c)
    aResult = create!(cc, a)
    bResult = create!(cc, b)
    baseFn(aResult, bResult)
end

function create!(cc::CalculateComparer, source)
    result = get(cc._results, source, Nullable{Any}())
    if !isnull(result)
        return get(result)
    end
    cc._results[source] = cc.factory(source)
end

function reset!(cc::CalculateComparer)
    reset!(cc.c)
    empty!(cc._results)
end
