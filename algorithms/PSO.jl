export PSO, start!, step!

immutable PSO{C, A} <: PopulationBasedOptAlgo{C}
    ctx::C
    populationSize::Int
    dnaSize::Int
    vMax::Float32
    w::Float32
    c1::Float32
    c2::Float32
    mutationChance::Float32
    mutationStrength::Float32
    comparer::AbstractComparer
    popMan::PopulationManager
    pBests::Vector{Entity}
    velocities::Vector{A}
end

PSO(
    ctx,
    dnaSize,
    comparer::AbstractComparer,
    decode::Function;
    populationSize = 100,
    vMax = 0.1f0,
    w = 0.8f0,
    c1 = 2f0,
    c2 = 2f0,
    mutationChance = 0.02f0,
    mutationStrength = 0.05f0) =
PSO(
    ctx,
    populationSize,
    dnaSize,
    vMax,
    w,
    c1,
    c2,
    mutationChance,
    mutationStrength,
    comparer,
    PopulationManager(
        ctx,
        populationSize,
        dnaSize,
        comparer,
        dna -> begin
            dna2 = normalized(dna)
            local result
            try
                result = decode(dna2)
            finally
                if result != dna2
                    release!(dna2)
                end
            end
            result
        end),
    Vector{Entity}(),
    [(x -> array(ctx))(x) for x in 1:populationSize])

function start!(pso::PSO)
    reset!(pso.comparer)
    randomize!(pso.popMan)
    for idx in 1:pso.populationSize
        push!(pso.pBests, copy(pso.popMan.population[idx]))
        scope!(pso.ctx) do this
            pso.velocities[idx][] = randu(pso.ctx, Float32, pso.dnaSize) .* (pso.vMax * 2) .- pso.vMax
        end
    end
end

function step!(pso::PSO)
    reset!(pso.comparer)

    candidate = createCandidate(pso.popMan)

    population = pso.popMan.population
    gBest = get(pso.popMan.best).dna.array
    for idx in 1:pso.populationSize
        pBest = pso.pBests[idx]
        dna = scope!(pso.ctx) do this
            rnd1 = randu(pso.ctx, Float32, pso.dnaSize)
            rnd2 = randu(pso.ctx, Float32, pso.dnaSize)
            loc = population[idx].dna.array
            vel = pso.velocities[idx]
            newVel = (pso.w .* vel) .+ (rnd1 .* pso.c1) .* (pBest.dna.array .- loc) .+ (rnd2 .* pso.c2) .* (gBest .- loc)
            newVel = maxOf(newVel, -pso.vMax)
            newVel = minOf(newVel, pso.vMax)
            vel[] = newVel
            eval!(vel)
            loc = loc .+ vel
            childDNA = DNA(pso.ctx, loc)
            this.result(childDNA.array)
            mutate!(childDNA, pso.mutationChance, pso.mutationStrength)
        end
        entity = push!(candidate, dna)
        if pso.comparer(entity.body, pBest.body)
            release!(pBest)
            pso.pBests[idx] = copy(entity)
        end
    end

    set!(pso.popMan, candidate, true)
end
