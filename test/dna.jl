testOnAllContexts("DNA") do ctx
    println("\tconstruct:")

    println("\tcreate from a number")

    dna = DNA(ctx, 42)
    @test length(dna) == 42
    values = Array(dna)
    @test typeof(values) == Vector{Float32}
    @test length(values) == 42
    for value in values
        @test value == 0f0
    end

    println("\tcreate from an context's array")

    arr = constant(ctx, 1f0, 42)
    dna = DNA(ctx, arr)
    @test length(dna) == 42
    values = Array(dna)
    @test typeof(values) == Vector{Float32}
    @test length(values) == 42
    for value in values
        @test value == 1f0
    end

    println("\tcrate from another dna")

    dna2 = DNA(dna)
    @test length(dna2) == 42
    values = Array(dna2)
    @test typeof(values) == Vector{Float32}
    @test length(values) == 42
    for value in values
        @test value == 1f0
    end

    println("\tcrate from Vector{Float32}")

    values = [1f0, 2f0, 3f0]
    dna = DNA(ctx, values)
    @test length(dna) == 3
    values2 = Array(dna)
    @test values == values2

    println("\trandomize uniformly")

    dna = DNA(ctx, 100)
    randomizeUniform!(dna, 100)
    @test length(dna) == 100

    values = Array(dna)
    sum = 0f0
    lo = false
    hi = false
    for value in values
        @test value >= 0f0 && value < 100f0
        sum += value
        if value < 50f0
            lo = true
        else
            hi = true
        end
    end
    @test sum > 0f0
    @test lo && hi

    println("\tcrossover")

    dna1 = DNA(ctx, 100)
    randomizeUniform!(dna1, 100)
    dna2 = DNA(ctx, 100)
    randomizeUniform!(dna2, 100)
    child = crossover(dna1, dna2)
    @test length(child) == 100

    values1 = Array(dna1)
    values2 = Array(dna2)
    values = Array(child)

    found1 = 0
    found2 = 0
    invalid = 0
    for i in 1:100
        if values[i] == values1[i]
            found1 += 1
        elseif values[i] == values2[i]
            found2 += 1
        else
            invalid += 1
        end
    end
    @test found1 > 10
    @test found2 > 10
    @test invalid == 0

    println("\tmutate")

    dna = DNA(ctx, 1000) # filled with zero
    mutate!(dna, 0.05f0, 0.1f0) # 5% chance of 0.1 = +/-0.05
    values = Array(dna)
    count = 0
    for value in values
        @test value >= -0.05f0 && value <= 0.5f0
        if value != 0f0
            count += 1
        end
    end
    @test count > 20 && count < 80

    println("\tnormalized")

    function verify(a)
        @test a[1] == 0.5f0
        @test a[2] == 0f0
        @test a[3] == 0.5f0
        @test a[4] == 0.75f0
        @test a[5] == 1f0
        @test a[6] == 0.5f0
        @test a[7] == 0.25f0
        @test a[8] == 0f0
        @test a[9] == 0.25f0
        @test a[10] == 0.5f0
        @test a[11] == 1f0
        @test a[12] == 0.75f0
        @test a[13] == 0.5f0
        @test a[14] == 0f0
        @test a[15] == 0.5f0
    end

    dna = DNA(ctx, [
        -2.5f0,         # 0.5
        -2f0,           # 0
        -1.5f0,         # 0.5
        -1.25f0,        # 0.75
        -1f0,           # 1
        -0.5f0,         # 0.5
        -0.25f0,        # 0.25
        0f0,            # 0
        0.25f0,         # 0.25
        0.5f0,          # 0.5
        1f0,            # 1
        1.25f0,         # 0.75
        1.5f0,          # 0.5
        2f0,            # 0
        2.5f0           # 0.5
    ])

    dna2 = normalized(dna)
    @test length(dna2) == 15
    values = Array(dna2)
    @test length(values) == 15
    verify(values)

    println("\tnormalize!")

    values = Array(dna)
    @test_throws ErrorException verify(values)
    normalize!(dna)
    values = Array(dna)
    verify(values)
end
