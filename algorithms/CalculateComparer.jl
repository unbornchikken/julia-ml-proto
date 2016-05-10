export CalculateComparer, fn, reset!

type CalculateComparer{S} <: AbstractComparer
    factory::Function
    c::Comparer
    _results::Dict{S, Nullable{Any}}

    CalculateComparer(factory, c) = new(factory, c, Dict{S, Nullable{Any}}())

    CalculateComparer(factory::Function) = new(factory, Comparer())

    CalculateComparer(factory::Function, fn::Function) = new(factory, Comparer(fn))

    CalculateComparer(factory::Function, cc::AbstractComparer) = new(factory, Comparer(cc))
end

fn(cc::CalculateComparer) = (a, b) ->
begin
    baseFn = fn(cc.c)
    aResult = create!(cc, a)
    bResult = create!(cc, b)
    baseFn(aResult, bResult)
end

function create!{S}(cc::CalculateComparer, source::S)
    result = get(cc._results, source, Nullable{Any}())
    if !isnulle(result)
        return get(result)
    end
    cc._result[source] = cc.factory(source)
end

function reset!(cc::CalculateComparer)
    reset!(cc.c)
    empty!(cc._results)
end
