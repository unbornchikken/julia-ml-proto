export CrossEntropy, start!, step!, release!

immutable CrossEntropy{C, A} <: PopulationBasedOptAlgo{C}
    ctx::C
    populationSize::Int
    dnaSize::Int
    mutationChance::Float32
    mutationStrength::Float32
    selectionStdDev::Float32
    keepElitesRate::Float32
    comparer::AbstractComparer
    popMan::PopulationManager
    offsprings::A
end

CrossEntropy(
    ctx,
    dnaSize,
    comparer::AbstractComparer,
    decode::Function;
    populationSize = 100,
    mutationChance = 0.05f0,
    mutationStrength = 0.02f0,
    selectionStdDev = 0.3f0,
    keepElitesRate = 0.05f0) =
CrossEntropy(
    ctx,
    populationSize,
    dnaSize,
    mutationChance,
    mutationStrength,
    selectionStdDev,
    keepElitesRate,
    comparer,
    PopulationManager(
        ctx,
        populationSize,
        dnaSize,
        comparer,
        decode),
    array(ctx, Float32, dnaSize, populationSize))

release!(ce::CrossEntropy) = (release!(ce.popMan); release!(ce.offsprings))

function start!(ce::CrossEntropy)
    reset!(ce.comparer)
    ce.offsprings[:,:] = 0f0
    randomize!(ce.popMan)
end

function step!(ce::CrossEntropy)
    reset!(ce.comparer)

    for i in 1:ce.populationSize
        parentIndex = chooseParentIndex(ce.popMan, ce.selectionStdDev);
        parent = ce.popMan.population[parentIndex]
        ce.offsprings[Col(i - 1)] = parent.dna.array;
    end

    candidate = createCandidate(ce.popMan)
    keepElites!(ce.popMan, candidate, ce.keepElitesRate)

    _mean = mean(ce.offsprings, 1)
    stdDev = stdev(ce.offsprings, 1)
    try
        while length(candidate) < ce.populationSize
            push!(candidate, scope!(ce.ctx) do this
                rnd = randn(ce.ctx, Float32, ce.dnaSize)
                dnaArray = rnd .* stdDev .+ _mean
                childDNA = DNA(ce.ctx, dnaArray)
                this.result(childDNA.array)
                mutate!(childDNA, ce.mutationChance, ce.mutationStrength)
            end)
        end
    finally
        release!(_mean)
        release!(stdDev)
    end

    set!(ce.popMan, candidate)
end
