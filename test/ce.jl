testOnAllContexts("CrossEntropy") do ctx
    println("\tsolves a simple problem")
    testSimpleProblem(
        comparer ->
        begin
            ce = CrossEntropy(ctx, 60, comparer, dna -> dna)
            @test ce.dnaSize == 60
            @test ce.populationSize == 100
            @test ce.mutationChance == 0.05f0
            @test ce.mutationStrength == 0.02f0
            @test ce.selectionStdDev == 0.3f0
            @test ce.keepElitesRate == 0.05f0
            ce
        end)

    println("\tsolves a problem with synthesizer")
    testSimpleProblem(
        ctx,
        (comparer, synth) ->
        begin
            ce = CrossEntropy(
                ctx,
                dnaSize!(synth),
                comparer,
                dna -> decode(synth, dna),
                mutationChance = 0.05f0,
                selectionStdDev = 0.3f0)
            @test ce.dnaSize == dnaSize!(synth)
            @test ce.populationSize == 100
            @test ce.mutationChance == 0.05f0
            @test ce.mutationStrength == 0.02f0
            @test ce.selectionStdDev == 0.3f0
            @test ce.keepElitesRate == 0.05f0
            ce
        end)
end
