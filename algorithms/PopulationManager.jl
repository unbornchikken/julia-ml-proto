export
    PopulationManager,
    createCandidate,
    randomize!,
    chooseParentIndex,
    keepElites!,
    set!

type PopulationManager
    population::Population
    populationSize::Int
    dnaSize::Int
    best::BestEntity
end

PopulationManager(ctx, populationSize::Int, dnaSize::Int, comparer::AbstractComparer, decode::Function) =
    PopulationManager(Population(ctx, comparer, decode), populationSize, dnaSize, BestEntity(comparer))

createCandidate(popMan::PopulationManager) =
    Population(popMan.population.ctx, popMan.population.comparer, popMan.population.decode)

function randomize!(popMan::PopulationManager)
    set!(popMan.best, randomize!(popMan.population, popMan.populationSize, popMan.dnaSize))
end

function chooseParentIndices(popMan::PopulationManager, stdDev::Float32)
    idx1 = chooseParentIndex(popMan, stdDev)
    idx2 = chooseParentIndex(popMan, stdDev)
    while idx1 == idx2
        idx2 = chooseParentIndex(popMan, stdDev)
    end
    idx1, idx2
end

chooseParentIndex(popMan::PopulationManager, stdDev::Float32) =
    chooseParentIndex(stdDev, length(popMan.population))

function chooseParentIndex(stdDev::Float32, size::Int)
    v = abs(randn() * stdDev)
    v = v - floor(v)
    Int(floor(v * size)) + 1
end

function keepElites!(popMan::PopulationManager, candidatePop::Population, rate::Float32)
    keep = Int(rate < 1.0 ? round(length(popMan.populationSize) * rate) : round(rate))
    for i in 1:keep
        push!(candidatePop, copy(popMan.population[i]))
    end
end

function set!(popMan::PopulationManager, candidatePop::Population, noSort = false)
    if noSort == false # sort
        update!(popMan.best, sort!(candidatePop))
    else
        bestOf = candidatePop[1]
        for entity in candidatePop.entities # TODO: support iteration in Population
            if entity != bestOf && popMan.population.comparer(entity.body, bestOf.body)
                bestOf = entity
            end
        end
        update!(popMan.best, bestOf)
    end
    release!(popMan.population)
    popMan.population = candidatePop
end
