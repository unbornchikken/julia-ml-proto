testOnAllContexts("Synthesizer") do ctx
    println("\tconcept: select indices by chance")
    const depth = 2
    const count = 4
    s = range(ctx, UInt32, [count])
    values = moddims(range(ctx, Float32, [count * depth]), count, depth)
    dist = randu(ctx, Float32, count, depth)
    rnd = randu(ctx, Float32, count, depth)
    test = rnd ./ maxOf(dist, 0.000001f0)
    max, idx = imax(test, 1)
    idx2 = idx .* count .+ s
    result = values[idx2]
    @test dims(result, 0) == count
    @test dims(result, 1) == 1
    @test host(result) == [0.0f0,1.0f0,6.0f0,3.0f0]

    println("\tscalar rule")
    println("\tset rule")
end
