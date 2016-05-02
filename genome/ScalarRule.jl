export
    ScalarRule,
    dnaSize,
    resultSize,
    initialize!,
    decode,
    asValue

immutable ScalarRule <: SynthRule
    count::Int
    min::Float32
    max::Float32
    round::Bool
    variationCount::Int
    _multi::Nullable{MultiScalarRule}
    dnaSize::Int
    resultSize::Int

    function ScalarRule(;count = 1, min = 0f0, max = 1f0, round = false, variationCount = 1)
        if variationCount > 1
            multi = MultiScalarRule(
                count = count,
                min = min,
                max = max,
                round = round,
                variationCount = variationCount)
            return new(count, min, max, round, variationCount, multi, dnaSize(multi), resultSize(multi))
        end

        new(count, min, max, round, variationCount, Nullable{MultiScalarRule}(), count, count)
    end
end

dnaSize(rule::ScalarRule) = rule.dnaSize

resultSize(rule::ScalarRule) = rule.resultSize

initialize!(rule::ScalarRule, ctx, state) =
    !isnull(rule._multi) && initialize!(get(rule._multi), ctx, state)

function decode(rule::ScalarRule, pars)
    if !isnull(rule._multi)
        return decode(get(rule._multi), pars)
    end

    scope!(pars.ctx) do this
        result = pars.dnaFragment
        if rule.min == 0f0 && rule.max == 1f0
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        else
            const d = rule.max - rule.min
            result = result .* d .+ rule.min
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        end
    end
end

function asValues(rule::ScalarRule, values, startIndex)
    if !isnull(rule._multi)
        return asValues(get(rule._multi), values, startIndex)
    end

    result = Vector(resultSize(rule))
    for i in 1:resultSize(rule)
        result[i] = values[startIndex - 1 + i]
    end
    result
end
