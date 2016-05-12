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
end
