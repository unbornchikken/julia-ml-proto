export
    MultiScalarRule,
    dnaSize,
    resultSize,
    initialize!,
    decode,
    asValue

immutable MultiScalarRule <: SynthRule
    count::Int
    min::Float32
    max::Float32
    round::Bool
    variationCount::Int
    dnaSize::Int

    function MultiScalarRule(count = 1, min = 0f0, max = 1f0, round = false, variationCount = 2)
        dnaSize = variationCount * count * 2

        new(count, min, max, round, variationCount, dnaSize)
    end
end

dnaSize(rule::MultiScalarRule) = rule.dnaSize

resultSize(rule::MultiScalarRule) = rule.count

function initialize!(rule::MultiScalarRule, ctx, state)
    state[:s] = range(ctx, Float32, rule.count, 0)
end

function decode(rule::MultiScalarRule, pars)
    scope!(pars.ctx) do this
        const blockSize = rule.count * rule.depth
        values = moddims(pars.dnaFragment[Seq(0, blockSize - 1)], rule.count, rule.depth)
        dist = moddims(pars.dnaFragment[Seq(blockSize, blockSize * 2 - 1)], rule.count, rule.depth)
        rnd = randu(pars.ctx, Float32, rule.count, rule.depth)
        test = rnd ./ max(dist, 0.000001f0)
        idx, max = imax(test, 1)
        idx2 = idx .* rule.count .+ pars.state[:s]
        result = values[idx2]

        if rule.min == 0f0 && rule.max == 1f0
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        else
            const d = rule.max - rule.min
            result = result .* d + rule.min
            pars.result[pars.resultSeq] = rule.round ? round(result) : result
        end
    end
end

function asValue(rule::MultiScalarRule, values, startIndex)
    result = Vector(rule.resultSize)
    for i in 1:rule.resultSize
        result[i] = values[startIndex + i]
    end
    result
end
