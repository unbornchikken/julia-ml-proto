export GA, start!, step!

immutable GA{C} <: PopulationBasedOptAlgo{C}
    ctx::C
    populationSize::Int
    dnaSize::Int
    mutationChance::Float32
    mutationStrength::Float32
    selectionStdDev::Float32
    keepElitesRate::Float32
    comparer::AbstractComparer
    popMan::PopulationManager
end

GA(
    ctx,
    dnaSize,
    comparer::AbstractComparer,
    decode::Function;
    populationSize = 100,
    mutationChance = 0.02f0,
    mutationStrength = 0.05f0,
    selectionStdDev = 0.25f0,
    keepElitesRate = 0.05f0) =
GA(
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
        decode))

start!(ga::GA) = (reset!(ga.comparer); randomize!(ga.popMan))

function step!(ga::GA)
    reset!(ga.comparer)
    candidate = createCandidate(ga.popMan)
    keepElites!(ga.popMan, candidate, ga.keepElitesRate)
    while length(candidate) < ga.popMan.populationSize
        push!(candidate, createChildDNA(ga))
    end
    set!(ga.popMan, candidate)
end

function createChildDNA(ga::GA)
    parent1Index, parent2Index = chooseParentIndices(ga.popMan, ga.selectionStdDev)
    parent1 = ga.popMan.population[parent1Index]
    parent2 = ga.popMan.population[parent2Index]
    childDNA = crossover(parent1.dna, parent2.dna)
    mutate!(childDNA, ga.mutationChance, ga.mutationStrength)
end
