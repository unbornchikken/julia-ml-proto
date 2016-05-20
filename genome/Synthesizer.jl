export
    SynthRule,
    Synthesizer,
    SynthesizerOptions,
    DecodeRule,
    define!,
    dnaSize!,
    resultSize!,
    decodeAsContextArray,
    decode,
    decodeAt

abstract SynthRule

typealias StateDict Dict{Symbol, Any}

immutable DecodePars{C, A, S}
    ctx::C
    dnaFragment::A
    result::A
    resultSeq::S
    state
end

DecodePars{C, A, S}(ctx::C, dnaFragment::A, result::A, resultSeq::S, state) =
    DecodePars{C, A, S}(ctx, dnaFragment, result, resultSeq, state)

immutable DecodeRule{R}
    rule::R
    asContextArray::Bool
end

DecodeRule{R}(rule::R) = DecodeRule{R}(rule, false)

DecodeRule{R}(rule::R, asContextArray::Bool) = DecodeRule{R}(rule, asContextArray)

type Synthesizer{C}
    ctx::C
    rules::Vector{SynthRule}
    _states::Vector{StateDict}
    _dnaSize::Nullable{Int}
    _resultSize::Nullable{Int}
end

function Synthesizer{C}(ctx::C)
    Synthesizer{C}(
        ctx,
        Vector{SynthRule}(),
        Vector{StateDict}(),
        Nullable{Int}(),
        Nullable{Int}())
end

function define!(syn::Synthesizer, rule::SynthRule)
    push!(syn.rules, rule)
    state = StateDict()
    push!(syn._states, state)
    initialize!(rule, syn.ctx, state)
    syn._dnaSize = Nullable{Int}()
    syn._resultSize = Nullable{Int}()
end

function dnaSize!(syn::Synthesizer)
    isnull(syn._dnaSize) && (syn._dnaSize = sum(map(rule -> dnaSize(rule), syn.rules)))
    get(syn._dnaSize)
end

function resultSize!(syn::Synthesizer)
    isnull(syn._resultSize) && (syn._resultSize = sum(map(rule -> resultSize(rule), syn.rules)))
    get(syn._resultSize)
end

function decodeAsContextArray{C}(syn::Synthesizer{C}, dna::DNA{C})
    result = constant(syn.ctx, 0f0, resultSize!(syn))

    dnaBeginIndex = 0
    resultBeginIndex = 0

    ruleIndex = 1
    for rule in syn.rules
        scope!(syn.ctx) do this
            const ruleDnaSize = dnaSize(rule)
            const ruleResultSize = resultSize(rule)
            const dnaEndIndex = dnaBeginIndex + ruleDnaSize - 1
            const resultEndIndex = resultBeginIndex + ruleResultSize - 1

            pars = DecodePars(
                syn.ctx,
                dna.array[seq(syn.ctx, dnaBeginIndex, dnaEndIndex)],
                result,
                seq(syn.ctx, resultBeginIndex, resultEndIndex),
                syn._states[ruleIndex]
            )

            decode(rule, pars)

            dnaBeginIndex += ruleDnaSize
            resultBeginIndex += ruleResultSize
            ruleIndex += 1
        end
    end

    eval!(result)
    result
end

function decode{C}(syn::Synthesizer{C}, dna::DNA{C})
    scope!(syn.ctx) do this
        array = Array(decodeAsContextArray(syn, dna))

        result = Vector()
        outputIndex = 1
        for rule in syn.rules
            for value in asValues(rule, array, outputIndex)
                push!(result, value)
            end
            outputIndex += resultSize(rule)
        end
        result
    end
end

function decodeAt(syn::Synthesizer, array, items)
    all = Vector()
    for item in items
        local rule
        if isa(item.rule, Int)
            rule = syn.rules[item.rule]
        elseif isa(item.rule, SynthRule)
            rule = item.rule
        else
            error("Unknown rule: $(item.rule)")
        end

        outputIndex = 0
        found = false
        for curr in syn.rules
            if curr == rule
                scope!(syn.ctx) do this
                    sub = array[seq(syn.ctx, outputIndex, outputIndex + resultSize(rule) - 1)]
                    if item.asContextArray
                        this.result(sub)
                        push!(all, sub)
                    else
                        subValues = Array(sub)
                        result = Vector()
                        for value in asValues(rule, subValues, 1)
                            push!(result, value)
                        end
                        push!(all, result)
                    end
                end
                found = true
                break
            end
            outputIndex += resultSize(curr)
        end
        found || error("Rule hasn't found: $(item.rule)")
    end
    all
end
