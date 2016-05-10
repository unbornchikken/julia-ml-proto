export GA, start!, step!, best

immutable GA{C} <: PopulationBasedOptAlgo{C}
    ctx::C
    populationSize::Int
    dnaSize::Int
    mutationChance::Float32
    mutationStrength::Float32
    selectionStdDev::Float32
    keepElitesRate::Float32
    popMan::PopulationManager
end

GA{C}(
    ctx::C,
    dnaSize,
    comparer::Comparer,
    decode::Function;
    populationSize = 100f0,
    mutationChance = 0.02f0,
    mutationStrength = 0.05f0,
    selectionStdDev = 0.25f0,
    keepElitesRate = 0.05f0) =
new(
    ctx,
    dnaSize,
    populationSize,
    mutationChance,
    mutationStrength,
    selectionStdDev,
    keepElitesRate,
    PopulationManager(
        ctx,
        populationSize,
        dnaSize,
        comparer,
        decode))

start!(ga::GA) = randomize!(ga.popMan)

function step!(ga::GA)
    candidate = createCandidate(ga.popMan)
    keepElites!(ga.popMan, candidates, ga.keepElitesRate)
    while length(candidate) < ga.popMan.populationSize
        push!(candidate, createChildDNA(ga))
    end
    set!(ga.popMan, candidate)
end

best(ga::GA) = get(ga.popMan.best)

function createChildDNA(ga::GA)
    parent1Index, parent2Index = chooseParentIndices(ga.popMan, ga.selectionStdDev)
    parent1 = ga.popMan.population[parent1Index]
    parent2 = ga.popMan.population[parent2Index]
    childDNA = crossover(parent1.dna, parent2.dna)
    mutate!(childDNA, ga.mutationChance, ga.mutationStrength)
end
