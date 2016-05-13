function testSimpleProblem(algoFactory)
    const maxIteration = 50
    const target = 42.0f0
    const treshold = 0.1f0
    const fitnessFunction = dna -> abs(target - sum(Float32, dna.array))

    epoch = Epoch(algoFactory(CalculateComparer(fitnessFunction)))
    @test length(epoch.algo.popMan.population) == 0
    @test isnull(best(epoch.algo))
    start!(epoch)
    @test !isnull(best(epoch.algo))

    found = false
    lastFitness = 100000.0f0
    while step!(epoch) < maxIteration
        bestEntity = best(epoch.algo)
        @test !isnull(bestEntity)
        @test isa(get(bestEntity).dna, DNA)
        @test isa(get(bestEntity).body, DNA)
        @test host(get(bestEntity).dna.array) == host(get(bestEntity).body.array)
        bestFitness = fitnessFunction(get(bestEntity).dna)
        @test typeof(bestFitness) == Float32
        @test bestFitness <= lastFitness
        lastFitness = bestFitness
        if bestFitness < treshold
            found = true
            break
        end
    end

    @test found
    @test epoch.itertaionNo > 0

    println("\t- fitness: $lastFitness")
    println("\t- itertaion: $(epoch.itertaionNo)")
end

fitnessOfCOOL(values) =
    (Char(values[1]) == 'C' ? 0 : 1) +
    (Char(values[2]) == 'O' ? 0 : 1) +
    (Char(values[3]) == 'O' ? 0 : 1) +
    (Char(values[4]) == 'L' ? 0 : 1)

function testSimpleProblem(ctx, algoFactory)
    const maxIteration = 100

    synth = Synthesizer(ctx)
    define!(synth, SetRule(collect('A':'Z'), 4))
    epoch = Epoch(algoFactory(CalculateComparer(fitnessOfCOOL), synth))
    @test length(epoch.algo.popMan.population) == 0
    @test isnull(best(epoch.algo))
    start!(epoch)
    @test !isnull(best(epoch.algo))

    found = false
    lastFitness = 1000
    str = ""
    while step!(epoch) < maxIteration
        bestEntity = best(epoch.algo)
        @test !isnull(bestEntity)
        @test isa(get(bestEntity).dna, DNA)
        @test isa(get(bestEntity).body, Vector{Any})
        str = string(get(bestEntity).body...)
        @test length(str) == 4
        bestFitness = fitnessOfCOOL(get(bestEntity).body)
        @test bestFitness <= lastFitness
        lastFitness = bestFitness
        if str == "COOL"
            found = true
            break
        end
    end

    @test lastFitness < 4
    @test epoch.itertaionNo > 0

    println("\t- fitness: $lastFitness")
    println("\t- result: $str")
    println("\t- itertaion: $(epoch.itertaionNo)")
end
