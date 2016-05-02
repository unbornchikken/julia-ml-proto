export
    SetRule,
    dnaSize,
    resultSize,
    initialize!,
    decode,
    asValue

immutable SetRule{T} <: SynthRule
    count::Int
    items::Vector{T}
    dnaSize::Int
end

function SetRule{T}(items::Vector{T}, count = 1)
    dnaSize = length(items) * count

    SetRule{T}(count, items, dnaSize)
end

dnaSize(rule::SetRule) = rule.dnaSize

resultSize(rule::SetRule) = rule.count

function initialize!(rule::SetRule, ctx, state) end

function decode(rule::SetRule, pars)
    scope!(pars.ctx) do this
        const depth = length(rule.items)
        dist = moddims(pars.dnaFragment, rule.count, depth)
        rnd = randu(pars.ctx, Float32, rule.count, depth)
        test = rnd ./ maxOf(dist, 0.000001f0)
        max, idx = imax(test, 1)
        pars.result[pars.resultSeq] = idx
    end
end

function asValues(rule::SetRule, values, startIndex)
    result = Vector(resultSize(rule))
    for i in 1:resultSize(rule)
        itemIndex = values[startIndex - 1 + i]
        result[i] = rule.items[Int(round(itemIndex + 1))]
    end
    result
end
