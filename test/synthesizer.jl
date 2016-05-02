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
    @test host(result) == [0.0f0, 1.0f0, 6.0f0, 3.0f0]

    println("\tSynthesizer + scalar and set rule")

    syn = Synthesizer(ctx)
    genes = Vector{Float32}()
    rule = SetRule(["A", "B", "C"], 3)
    define!(syn, rule)
    @test resultSize(rule) == 3
    @test dnaSize(rule) == 9

    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.9f0)
    push!(genes, 0.9f0)
    push!(genes, 0.9f0)

    rule = ScalarRule(count = 3)
    define!(syn, rule)
    @test resultSize(rule) == 3
    @test dnaSize(rule) == 3

    push!(genes, 0.5f0)
    push!(genes, 0.6f0)
    push!(genes, 0.7f0)

    rule = ScalarRule(count = 2, round = true, min = 1f0, max = 100f0)
    define!(syn, rule)
    @test resultSize(rule) == 2
    @test dnaSize(rule) == 2

    push!(genes, 0.5f0)
    push!(genes, 0.6f0)

    rule = ScalarRule(count = 2, round = true, min = 1, max = 100, variationCount = 2)
    define!(syn, rule)
    @test resultSize(rule) == 2
    @test dnaSize(rule) == 2 * 2 * 2

    push!(genes, 0.001f0)
    push!(genes, 0.01f0)
    push!(genes, 0.99f0)
    push!(genes, 0.59f0)

    push!(genes, 0.1f0)
    push!(genes, 0.19f0)
    push!(genes, 0.12f0)
    push!(genes, 0.2f0)

    dna = DNA(ctx, genes)
    result = decode(syn, dna)

    @test typeof(result) == Vector{Any}

    @test dnaSize!(syn) == length(dna)
    @test resultSize!(syn) == length(result)

    i = 0

    @test result[i += 1] in ["A", "B", "C"]
    @test result[i += 1] in ["A", "B", "C"]
    @test result[i += 1] in ["A", "B", "C"]

    @test result[i += 1] == 0.5f0
    @test result[i += 1] == 0.6f0
    @test result[i += 1] == 0.7f0

    @test result[i += 1] == 51f0
    @test result[i += 1] == 60f0

    @test result[i += 1] in [1, 2, 59, 99]
    @test result[i += 1] in [1, 2, 59, 99]

    println("TODO: test decodeAt")
end
