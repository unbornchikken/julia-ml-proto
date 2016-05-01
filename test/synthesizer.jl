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
    define!(syn, SetRule(["A", "B", "C"], 3))

    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.1f0)
    push!(genes, 0.9f0)
    push!(genes, 0.9f0)
    push!(genes, 0.9f0)

    define!(syn, ScalarRule(count = 3))

    push!(genes, 0.5f0)
    push!(genes, 0.6f0)
    push!(genes, 0.7f0)

    define!(syn, ScalarRule(count = 3, round = true, min = 1f0, max = 100f0))

    push!(genes, 0.5f0)
    push!(genes, 0.6f0)

    define!(syn, ScalarRule(count = 2, round = true, min = 1, max = 100, variationCount = 2))

    push!(genes, 0.001f0)
    push!(genes, 0.01f0)
    push!(genes, 0.99f0)
    push!(genes, 0.59f0)

    push!(genes, 0.1f0)
    push!(genes, 0.19f0)
    push!(genes, 0.12f0)
    push!(genes, 0.2f0)

    # let dna = genevo.genome.createDNA(genes);
    # let result = yield synth.decodeAsync(dna);
    #
    # assert(_.isArray(result));
    # assert.equal(synth.dnaSize, dna.size);
    # assert.equal(synth.resultSize, result.length);
    #
    # let i = 0;
    # assert(_.contains(["A", "B", "C"], result[i++]));
    # assert(_.contains(["A", "B", "C"], result[i++]));
    # assert(_.contains(["A", "B", "C"], result[i++]));
    #
    # assert.equal(_.round(result[i++], 2), 0.5);
    # assert.equal(_.round(result[i++], 2), 0.6);
    # assert.equal(_.round(result[i++], 2), 0.7);
    #
    # assert.equal(result[i++], 51);
    # assert.equal(result[i++], 60);
    #
    # assert(_.contains([1, 2, 59, 99], result[i++]));
    # assert(_.contains([1, 2, 59, 99], result[i++]));
end
