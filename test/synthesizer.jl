testOnAllContexts("Synthesizer") do ctx
    println("\tconcept: select indices by chance")
    const depth = 2
    const count = 4
    s = range(ctx, Float32, [count])
    dist = randu(ctx, Float32, count, depth)
    rnd = randu(ctx, Float32, count, depth)
    test = rnd ./ maxOf(dist, 0.000001f0)
    idx, max = imax(test, 1)
    idx2 = idx ./ count .+ s
    result = dist[idx2]
    @test dims(result, 0) == count
    @test dims(result, 1) == 1
    println("\tTODO: test values!")

    println("\tscalar rule")
    println("\tset rule")
end
