testOnAllContexts("GA") do ctx
    println("\tsolves a simple problem")
    testSimpleProblem(
        comparer ->
        begin
            ga = GA(ctx, 60, comparer, dna -> dna)
            @test ga.dnaSize == 60
            @test ga.populationSize == 100
            @test ga.mutationChance == 0.02f0
            @test ga.mutationStrength == 0.05f0
            @test ga.selectionStdDev == 0.25f0
            @test ga.keepElitesRate == 0.05f0
            ga
        end)

    println("\tsolves a problem with synthesizer")
    testSimpleProblem(
        ctx,
        (comparer, synth) ->
        begin
            ga = GA(
                ctx,
                dnaSize!(synth),
                comparer,
                dna -> decode(synth, dna),
                mutationChance = 0.05f0,
                selectionStdDev = 0.3f0)
            @test ga.dnaSize == dnaSize!(synth)
            @test ga.populationSize == 100
            @test ga.mutationChance == 0.05f0
            @test ga.mutationStrength == 0.05f0
            @test ga.selectionStdDev == 0.3f0
            @test ga.keepElitesRate == 0.05f0
            ga
        end)
end
