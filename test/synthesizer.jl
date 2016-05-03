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
    firstRule = rule = SetRule(["A", "B", "C"], 3)
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

    println("\tdecode at")
    caResult = decodeAsContextArray(syn, dna)

    @test typeof(caResult) != Vector{Any}

    @test resultSize!(syn) == dims(caResult, 0)
    @test length(size(caResult)) == 1
    @test resultSize!(syn) ==  size(caResult)[1]

    decoded = decodeAt(syn, caResult, [DecodeRule(firstRule), DecodeRule(2, true), DecodeRule(syn.rules[3], false)])
    @test typeof(decoded) == Vector{Any}

    result1 = decoded[1]
    result2 = decoded[2]
    result3 = decoded[3]

    @test isa(result1, Vector{Any})
    @test length(result1) == 3
    for item in result1
        @test item in ["A", "B", "C"]
    end

    result2H = host(result2)
    @test length(result2H) == 3
    @test isa(result2H, Vector{Float32})
    @test result2H[1] == 0.5f0
    @test result2H[2] == 0.6f0
    @test result2H[3] == 0.7f0

    @test isa(result3, Vector{Any})
    @test length(result3) == 2
    @test result3[1] == 51f0
    @test result3[2] == 60f0

    @test_throws BoundsError decodeAt(syn, caResult, [DecodeRule(42)])

    @test_throws ErrorException decodeAt(syn, caResult, [DecodeRule(ScalarRule(count = 3))])
end
