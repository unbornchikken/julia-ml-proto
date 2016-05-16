testOnAllContexts("PSO") do ctx
    println("\tsolves a simple problem")
    testSimpleProblem(
        comparer ->
        begin
            pso = PSO(ctx, 60, comparer, dna -> dna)
            @test pso.dnaSize == 60
            @test pso.populationSize == 100
            @test pso.vMax == 0.1f0
            @test pso.w == 0.8f0
            @test pso.c1 == 2f0
            @test pso.c2 == 2f0
            @test pso.mutationChance == 0.02f0
            @test pso.mutationStrength == 0.05f0
            pso
        end)

    println("\tsolves a problem with synthesizer")
    testSimpleProblem(
        ctx,
        (comparer, synth) ->
        begin
            pso = PSO(
                ctx,
                dnaSize!(synth),
                comparer,
                dna -> decode(synth, dna),
                vMax = 0.9f0,
                w = 0.2f0,
                mutationChance = 0.05f0,
                mutationStrength = 0.01f0)
            @test pso.dnaSize == dnaSize!(synth)
            @test pso.populationSize == 100
            @test pso.vMax == 0.9f0
            @test pso.w == 0.2f0
            @test pso.c1 == 2f0
            @test pso.c2 == 2f0
            @test pso.mutationChance == 0.05f0
            @test pso.mutationStrength == 0.01f0
            pso
        end)
end
