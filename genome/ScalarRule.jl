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

    function ScalarRule(count = 1, min = 0f0, max = 1f0, round = false, variationCount = 1)
        _multi = Nullable{MultiScalarRule}()
        dnaSize = count
        resultSize = count
        if variationCount > 1
            _multi = MultiScalarRule(count, min, max, round, variationCount)
            dnaSize = dnaSize(_multi)
            resultSize = resultSize(_multi)
        end
        new(count, min, max, round, variationCount, _multi, dnaSize, resultSize)
    end
end

dnaSize(rule::ScalarRule) = rule.dnaSize

resultSize(rule::ScalarRule) = rule.resultSize

initialize!(rule::ScalarRule, ctx, state) =
    !isnull(rule._multi) && initialize!(get(rule._multi), ctx, state)

function decode(rule::ScalarRule, pars)
    scope!(pars.ctx) do this
        result = pars.dnaFragment
        if rule.min == 0f0 && rule.max == 1f0
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        else
            const d = rule.max - rule.min
            result = result .* d + rule.min
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        end
    end
end

function asValue(rule::ScalarRule, values, startIndex)
    if !isnull(rule._multi)
        return asValue(rule._multi, values, startIndex)
    end

    result = Vector(rule.resultSize)
    for i in 1:rule.resultSize
        result[i] = values[startIndex + i]
    end
    result
end
