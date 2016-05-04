type CalculateComparer{S, T} <: AbstractComparer{T}
    factory::Function
    c::Comparer{T}
    _results::Dict{S, Nullable{T}}

    CalculateComparer(factory, c) = new(factory, c, Dict{S, Nullable{T}}())
end

CalculateComparer{T}(factory::Function) = CalculateComparer{T}(factory, Comparer{T}())

CalculateComparer{T}(factory::Function, fn::Function) = CalculateComparer{T}(factory, Comparer{T}(fn))

CalculateComparer{T}(factory::Function, cc::AbstractComparer{T}) = CalculateComparer{T}(factory, Comparer{T}(cc))

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
